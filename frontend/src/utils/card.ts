/** Kiem tra / dinh dang so the phia client (backend kiem tra lai lan nua) */
import { CardKind } from '../types';

export type CardBrand = 'VISA' | 'MASTERCARD' | 'JCB' | 'AMEX' | 'NAPAS' | 'UNKNOWN';

export const digitsOnly = (s: string) => s.replace(/\D/g, '');

export function detectBrand(num: string): CardBrand {
  if (/^9704/.test(num)) return 'NAPAS';
  if (/^4/.test(num)) return 'VISA';
  if (/^(5[1-5]|2(2[2-9]|[3-6]\d|7[01]|720))/.test(num)) return 'MASTERCARD';
  if (/^35(2[89]|[3-8]\d)/.test(num)) return 'JCB';
  if (/^3[47]/.test(num)) return 'AMEX';
  return 'UNKNOWN';
}

export const BRAND_LABEL: Record<CardBrand, string> = {
  VISA: 'VISA',
  MASTERCARD: 'Mastercard',
  JCB: 'JCB',
  AMEX: 'AMEX',
  NAPAS: 'NAPAS',
  UNKNOWN: '',
};

export function luhnValid(num: string) {
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

export const maxDigits = (brand: CardBrand) => (brand === 'AMEX' ? 15 : 19);

/** 4242424242424242 -> "4242 4242 4242 4242" (AMEX: 4-6-5) */
export function formatCardNumber(raw: string) {
  const brand = detectBrand(raw);
  const d = raw.slice(0, maxDigits(brand));
  if (brand === 'AMEX') return [d.slice(0, 4), d.slice(4, 10), d.slice(10)].filter(Boolean).join(' ');
  return d.replace(/(.{4})/g, '$1 ').trim();
}

/** "0128" -> "01/28" */
export function formatMonthYear(raw: string) {
  const d = digitsOnly(raw).slice(0, 4);
  if (d.length === 1 && Number(d) > 1) return `0${d}/`;
  return d.length > 2 ? `${d.slice(0, 2)}/${d.slice(2)}` : d;
}

/** Ten in tren the: chu in hoa khong dau */
export const toCardHolder = (s: string) =>
  s
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .toUpperCase()
    .replace(/[^A-Z ]/g, '')
    .replace(/\s{2,}/g, ' ')
    .slice(0, 50);

export interface CardForm {
  cardKind: CardKind;
  cardNumber: string; // chi chu so
  cardHolder: string;
  expiry: string; // MM/YY
  cvv: string;
  bankBin: string;
}

export function validateCardForm(f: CardForm, now = new Date()) {
  const e: Record<string, string> = {};
  const brand = detectBrand(f.cardNumber);
  if (f.cardKind === 'DOMESTIC') {
    if (!f.bankBin) e.bankBin = 'Chọn ngân hàng phát hành thẻ';
    if (brand !== 'NAPAS' || ![16, 19].includes(f.cardNumber.length)) e.cardNumber = 'Thẻ ATM nội địa có 16 hoặc 19 số, bắt đầu bằng 9704';
  } else {
    if (!['VISA', 'MASTERCARD', 'JCB', 'AMEX'].includes(brand)) e.cardNumber = 'Chỉ nhận thẻ Visa, Mastercard, JCB, American Express';
    else if (f.cardNumber.length < 13 || !luhnValid(f.cardNumber)) e.cardNumber = 'Số thẻ không hợp lệ';
    const len = brand === 'AMEX' ? 4 : 3;
    if (!new RegExp(`^\\d{${len}}$`).test(f.cvv)) e.cvv = `CVV gồm ${len} chữ số ở mặt sau thẻ`;
  }
  if (!/^[A-Z ]{2,50}$/.test(f.cardHolder.trim())) e.cardHolder = 'Nhập tên in trên thẻ (không dấu)';
  const m = /^(\d{2})\/(\d{2})$/.exec(f.expiry);
  const ym = now.getFullYear() * 12 + now.getMonth() + 1;
  if (!m || Number(m[1]) < 1 || Number(m[1]) > 12) e.expiry = 'Định dạng MM/YY';
  else {
    const v = (2000 + Number(m[2])) * 12 + Number(m[1]);
    if (f.cardKind === 'INTERNATIONAL' && v < ym) e.expiry = 'Thẻ đã hết hạn';
    if (f.cardKind === 'DOMESTIC' && v > ym) e.expiry = 'Ngày phát hành không thể ở tương lai';
  }
  return e;
}
