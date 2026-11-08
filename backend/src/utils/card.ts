/**
 * Kiem tra thong tin the (thanh toan the MO PHONG).
 * Khong luu so the day du / CVV: chi giu hang the + 4 so cuoi.
 */
export type CardKind = 'INTERNATIONAL' | 'DOMESTIC';
export type CardBrand = 'VISA' | 'MASTERCARD' | 'JCB' | 'AMEX' | 'NAPAS' | 'UNKNOWN';

export const digitsOnly = (s: string) => String(s ?? '').replace(/\D/g, '');

export function luhnValid(num: string): boolean {
  let sum = 0;
  let dbl = false;
  for (let i = num.length - 1; i >= 0; i--) {
    let d = num.charCodeAt(i) - 48;
    if (dbl) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
    dbl = !dbl;
  }
  return num.length > 0 && sum % 10 === 0;
}

export function detectBrand(num: string): CardBrand {
  if (/^9704/.test(num)) return 'NAPAS';
  if (/^4/.test(num)) return 'VISA';
  if (/^(5[1-5]|2(2[2-9]|[3-6]\d|7[01]|720))/.test(num)) return 'MASTERCARD';
  if (/^35(2[89]|[3-8]\d)/.test(num)) return 'JCB';
  if (/^3[47]/.test(num)) return 'AMEX';
  return 'UNKNOWN';
}

/** "MM/YY" -> {month, year4} hoac null */
export function parseMonthYear(s: string): { month: number; year: number } | null {
  const m = /^(\d{2})\s*\/\s*(\d{2})$/.exec(String(s ?? '').trim());
  if (!m) return null;
  const month = Number(m[1]);
  if (month < 1 || month > 12) return null;
  return { month, year: 2000 + Number(m[2]) };
}

export interface CardInput {
  cardKind: CardKind;
  cardNumber: string;
  cardHolder: string;
  /** Quoc te: ngay het han MM/YY. Noi dia: ngay phat hanh MM/YY */
  expiry: string;
  cvv?: string;
  bankBin?: string;
}

/** Tra ve danh sach loi theo tung truong (rong = hop le) */
export function validateCard(c: CardInput, now = new Date()) {
  const errors: Record<string, string> = {};
  const num = digitsOnly(c.cardNumber);
  const brand = detectBrand(num);

  if (c.cardKind === 'DOMESTIC') {
    if (brand !== 'NAPAS' || !(num.length === 16 || num.length === 19)) {
      errors.cardNumber = 'Thẻ ATM nội địa (NAPAS) có 16 hoặc 19 số, bắt đầu bằng 9704';
    }
    if (!c.bankBin) errors.bankBin = 'Vui lòng chọn ngân hàng phát hành';
  } else {
    if (!['VISA', 'MASTERCARD', 'JCB', 'AMEX'].includes(brand)) errors.cardNumber = 'Chỉ hỗ trợ thẻ Visa, Mastercard, JCB, American Express';
    else if (num.length < 13 || num.length > 19 || !luhnValid(num)) errors.cardNumber = 'Số thẻ không hợp lệ';
    const cvvLen = brand === 'AMEX' ? 4 : 3;
    if (!new RegExp(`^\\d{${cvvLen}}$`).test(String(c.cvv ?? ''))) errors.cvv = `Mã CVV gồm ${cvvLen} chữ số ở mặt sau thẻ`;
  }

  const holder = String(c.cardHolder ?? '').trim();
  if (!/^[A-Za-z ]{2,50}$/.test(holder)) errors.cardHolder = 'Tên in trên thẻ: chữ in hoa không dấu (vd: NGUYEN VAN A)';

  const my = parseMonthYear(c.expiry);
  const ym = now.getFullYear() * 12 + now.getMonth() + 1;
  if (!my) errors.expiry = 'Định dạng MM/YY';
  else if (c.cardKind === 'INTERNATIONAL' && my.year * 12 + my.month < ym) errors.expiry = 'Thẻ đã hết hạn';
  else if (c.cardKind === 'DOMESTIC' && my.year * 12 + my.month > ym) errors.expiry = 'Ngày phát hành không được ở tương lai';

  return { valid: Object.keys(errors).length === 0, errors, brand, last4: num.slice(-4), number: num };
}

/**
 * Cong thanh toan MO PHONG (khong ket noi ngan hang that):
 *   4000 0000 0000 0002 -> the bi tu choi
 *   4000 0000 0000 9995 -> so du khong du
 *   9704 ... 0002 (noi dia, so cuoi 0002) -> the bi tu choi
 *   con lai -> duyet
 */
export function mockGatewayDecision(num: string): { approved: boolean; reason?: string } {
  if (num === '4000000000000002' || (num.startsWith('9704') && num.endsWith('0002'))) {
    return { approved: false, reason: 'Ngân hàng từ chối giao dịch. Vui lòng dùng thẻ khác.' };
  }
  if (num === '4000000000009995') return { approved: false, reason: 'Số dư tài khoản không đủ để thanh toán.' };
  return { approved: true };
}
