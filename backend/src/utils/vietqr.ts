/**
 * Tao ma VietQR (chuan Napas 247 / EMVCo Merchant-Presented QR) de chuyen khoan ngan hang.
 * Moi app ngan hang Viet Nam quet duoc: tu dien san ngan hang, so tai khoan, so tien, noi dung.
 *
 * Cau truc TLV (tag 2 so + do dai 2 so + gia tri):
 *   00 "01"                      Payload format
 *   01 "12"                      QR dong (co so tien, dung 1 lan cho 1 don)
 *   38 { 00 "A000000727"         GUID Napas
 *        01 { 00 BIN, 01 STK }   Ngan hang + so tai khoan nguoi nhan
 *        02 "QRIBFTTA" }         Dich vu: chuyen nhanh 24/7 toi tai khoan
 *   53 "704"                     VND
 *   54 so tien                   Chi chu so, khong dau cham
 *   58 "VN"
 *   62 { 08 noi dung }           Noi dung chuyen khoan (khong dau)
 *   63 CRC16-CCITT-FALSE         poly 0x1021, init 0xFFFF, tinh ca "6304"
 */

const tlv = (tag: string, value: string) => {
  if (value.length > 99) throw new Error(`VietQR: truong ${tag} dai qua 99 ky tu`);
  return tag + String(value.length).padStart(2, '0') + value;
};

export function crc16(input: string): string {
  let crc = 0xffff;
  for (let i = 0; i < input.length; i++) {
    crc ^= input.charCodeAt(i) << 8;
    for (let b = 0; b < 8; b++) crc = crc & 0x8000 ? ((crc << 1) ^ 0x1021) & 0xffff : (crc << 1) & 0xffff;
  }
  return crc.toString(16).toUpperCase().padStart(4, '0');
}

/** Bo dau tieng Viet, chi giu A-Z 0-9 va khoang trang (an toan cho moi ngan hang) */
export const toAsciiContent = (s: string) =>
  s
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .replace(/[^A-Za-z0-9 ]/g, '')
    .toUpperCase()
    .trim();

export function buildVietQrPayload(p: { bin: string; accountNo: string; amount?: number; content?: string }): string {
  const beneficiary = tlv('00', p.bin) + tlv('01', p.accountNo);
  const merchant = tlv('00', 'A000000727') + tlv('01', beneficiary) + tlv('02', 'QRIBFTTA');
  let s = tlv('00', '01') + tlv('01', p.amount ? '12' : '11') + tlv('38', merchant) + tlv('53', '704');
  if (p.amount) s += tlv('54', String(Math.round(p.amount)));
  s += tlv('58', 'VN');
  if (p.content) s += tlv('62', tlv('08', toAsciiContent(p.content).slice(0, 50)));
  s += '6304';
  return s + crc16(s);
}

/** Ngan hang pho bien: ma BIN theo Napas (dung trong VietQR) */
export const BANKS: { bin: string; code: string; name: string }[] = [
  { bin: '970436', code: 'VCB', name: 'Vietcombank' },
  { bin: '970415', code: 'CTG', name: 'VietinBank' },
  { bin: '970418', code: 'BIDV', name: 'BIDV' },
  { bin: '970405', code: 'AGR', name: 'Agribank' },
  { bin: '970407', code: 'TCB', name: 'Techcombank' },
  { bin: '970422', code: 'MB', name: 'MB Bank' },
  { bin: '970416', code: 'ACB', name: 'ACB' },
  { bin: '970432', code: 'VPB', name: 'VPBank' },
  { bin: '970423', code: 'TPB', name: 'TPBank' },
  { bin: '970403', code: 'STB', name: 'Sacombank' },
  { bin: '970437', code: 'HDB', name: 'HDBank' },
  { bin: '970441', code: 'VIB', name: 'VIB' },
  { bin: '970443', code: 'SHB', name: 'SHB' },
  { bin: '970431', code: 'EIB', name: 'Eximbank' },
  { bin: '970426', code: 'MSB', name: 'MSB' },
  { bin: '970440', code: 'SEAB', name: 'SeABank' },
  { bin: '970448', code: 'OCB', name: 'OCB' },
  { bin: '970449', code: 'LPB', name: 'LPBank' },
  { bin: '970428', code: 'NAB', name: 'Nam A Bank' },
  { bin: '970409', code: 'BAB', name: 'Bac A Bank' },
];

export const bankByBin = (bin: string) => BANKS.find((b) => b.bin === bin) ?? null;
