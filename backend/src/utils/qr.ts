/**
 * QR ve dien tu.
 * Noi dung QR:  PTA|<TicketCode>|<chu ky HMAC-SHA256 8 ky tu>
 * -> Nhan vien soat ve quet QR, backend kiem tra chu ky => chong lam gia QR.
 */
import crypto from 'crypto';
import QRCode from 'qrcode';
import { env } from '../config/env';

const PREFIX = 'PTA';

function sign(ticketCode: string): string {
  return crypto.createHmac('sha256', env.qrSecret).update(ticketCode).digest('hex').slice(0, 8).toUpperCase();
}

export function buildQrPayload(ticketCode: string): string {
  return `${PREFIX}|${ticketCode}|${sign(ticketCode)}`;
}

/** Tra ve TicketCode neu QR hop le, nguoc lai null. Chap nhan ca chuoi TicketCode tran. */
export function parseQrPayload(payload: string): { ticketCode: string; signed: boolean; valid: boolean } {
  const parts = payload.trim().split('|');
  if (parts.length === 3 && parts[0] === PREFIX) {
    const [, code, sig] = parts;
    const expected = Buffer.from(sign(code));
    const given = Buffer.from(String(sig).toUpperCase());
    const valid = given.length === expected.length && crypto.timingSafeEqual(expected, given);
    return { ticketCode: code, signed: true, valid };
  }
  return { ticketCode: payload.trim(), signed: false, valid: true };
}

export function qrToDataUrl(payload: string): Promise<string> {
  return QRCode.toDataURL(payload, { errorCorrectionLevel: 'M', margin: 1, width: 320 });
}

/** Ma ve: TK-YYMMDD-XXXXXX (ngau nhien, gan nhu khong trung) */
export function generateTicketCode(): string {
  const d = new Date();
  const ymd = `${String(d.getFullYear()).slice(2)}${String(d.getMonth() + 1).padStart(2, '0')}${String(d.getDate()).padStart(2, '0')}`;
  return `TK-${ymd}-${crypto.randomBytes(4).toString('hex').toUpperCase().slice(0, 6)}`;
}

export function generateTransactionCode(): string {
  return `MOCK-${Date.now()}-${crypto.randomBytes(3).toString('hex').toUpperCase()}`;
}
