/** Service: Loai ve, Ve cua toi, QR (Nguoi 2 - Module Ticket) */
import { ticketRepository } from '../repositories/ticket.repository';
import { AppError } from '../utils/AppError';
import { AuthUser } from '../types/express';
import { buildQrPayload, parseQrPayload, qrToDataUrl } from '../utils/qr';
import { toTransportMode } from '../types/transport.types';

function decorate(t: any) {
  // isValidNow / remainingMinutes da duoc tinh trong SQL (ticket.repository.ts)
  return {
    ...t,
    mode: toTransportMode(t.transportTypeName),
    qrPayload: buildQrPayload(t.ticketCode),
    isValidNow: Boolean(t.isValidNow),
    remainingMinutes: Number(t.remainingMinutes ?? 0),
  };
}

export const ticketService = {
  async ticketTypes(opts: { type?: string; transportTypeId?: number }) {
    const list = await ticketRepository.listTypes(opts);
    return list.map((t: any) => ({ ...t, mode: toTransportMode(t.transportTypeName) }));
  },

  async myTickets(userId: number, status?: string) {
    await ticketRepository.expireOverdue();
    return (await ticketRepository.listByUser(userId, status)).map(decorate);
  },

  async getTicket(ticketId: number, user: AuthUser) {
    await ticketRepository.expireOverdue();
    const t = await ticketRepository.getById(ticketId);
    if (!t) throw AppError.notFound('Không tìm thấy vé', 'TICKET_NOT_FOUND');
    if (t.userId !== user.userId && user.role !== 'ADMIN') {
      throw AppError.forbidden('Vé không thuộc về bạn', 'TICKET_FORBIDDEN');
    }
    return decorate(t);
  },

  /** GET /tickets/:id/qr -> anh QR dang data URL (frontend dung <img src=...>) */
  async getQr(ticketId: number, user: AuthUser) {
    const t = await this.getTicket(ticketId, user);
    const payload = t.qrCode && String(t.qrCode).startsWith('PTA|') ? t.qrCode : t.qrPayload;
    return { ticketId: t.ticketId, ticketCode: t.ticketCode, payload, image: await qrToDataUrl(payload), status: t.status };
  },

  /**
   * Soat ve (Admin / nhan vien): quet QR -> kiem tra -> ve luot chuyen USED.
   * Ve thang van ACTIVE den khi het han.
   */
  async verify(qrData: string, markUsed = true) {
    const parsed = parseQrPayload(qrData);
    if (!parsed.valid) {
      return { valid: false, reason: 'QR không hợp lệ (sai chữ ký)', ticket: null };
    }
    await ticketRepository.expireOverdue();
    const t = await ticketRepository.getByCode(parsed.ticketCode);
    if (!t) return { valid: false, reason: 'Không tìm thấy vé', ticket: null };

    const ticket = decorate(t);
    if (t.status !== 'ACTIVE') return { valid: false, reason: `Vé đang ở trạng thái ${t.status}`, ticket };
    if (!ticket.isValidNow) return { valid: false, reason: 'Vé chưa đến hoặc đã quá thời gian hiệu lực', ticket };

    if (markUsed && t.type === 'SINGLE') {
      await ticketRepository.updateStatus(t.ticketId, 'USED');
      ticket.status = 'USED';
    }
    return { valid: true, reason: t.type === 'SINGLE' ? 'Vé lượt hợp lệ - đã ghi nhận sử dụng' : 'Vé tháng hợp lệ', ticket };
  },
};
