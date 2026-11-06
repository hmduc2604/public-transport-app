/** Service: Don hang + Thanh toan mo phong (Nguoi 2 - Module Ticket/Payment) */
import { orderRepository } from '../repositories/order.repository';
import { ticketRepository } from '../repositories/ticket.repository';
import { paymentRepository, TicketToIssue } from '../repositories/payment.repository';
import { AppError } from '../utils/AppError';
import { AuthUser } from '../types/express';
import { buildQrPayload, generateTicketCode, generateTransactionCode } from '../utils/qr';

const MAX_QUANTITY_PER_ITEM = 10;

export const orderService = {
  /**
   * POST /orders  { items: [{ ticketTypeId, quantity }] }
   * Gia luon lay tu DB (khong tin gia client gui len).
   */
  async create(userId: number, rawItems: { ticketTypeId: number; quantity?: number }[]) {
    if (!Array.isArray(rawItems) || rawItems.length === 0) {
      throw AppError.badRequest('Đơn hàng cần ít nhất 1 loại vé', 'EMPTY_ORDER');
    }
    // Gop cac dong trung loai ve
    const merged = new Map<number, number>();
    for (const it of rawItems) {
      const id = Number(it.ticketTypeId);
      const qty = Number(it.quantity ?? 1);
      if (!Number.isInteger(id) || id <= 0) throw AppError.badRequest('ticketTypeId không hợp lệ', 'VALIDATION_ERROR');
      if (!Number.isInteger(qty) || qty < 1) throw AppError.badRequest('quantity phải >= 1', 'VALIDATION_ERROR');
      merged.set(id, (merged.get(id) ?? 0) + qty);
    }

    const items = [];
    for (const [ticketTypeId, quantity] of merged) {
      const type = await ticketRepository.getType(ticketTypeId);
      if (!type || type.status !== 'ACTIVE') {
        throw AppError.notFound(`Loại vé #${ticketTypeId} không tồn tại hoặc đã ngừng bán`, 'TICKET_TYPE_NOT_FOUND');
      }
      const max = type.type === 'MONTHLY' ? 1 : MAX_QUANTITY_PER_ITEM;
      if (quantity > max) {
        throw AppError.badRequest(`Mỗi đơn chỉ mua tối đa ${max} "${type.name}"`, 'QUANTITY_LIMIT');
      }
      items.push({ ticketTypeId, quantity, unitPrice: Number(type.price) });
    }

    const orderId = await orderRepository.create(userId, items);
    return orderRepository.getById(orderId);
  },

  async getOrder(orderId: number, user: AuthUser) {
    const order = await orderRepository.getById(orderId);
    if (!order) throw AppError.notFound('Không tìm thấy đơn hàng', 'ORDER_NOT_FOUND');
    if (order.userId !== user.userId && user.role !== 'ADMIN') {
      throw AppError.forbidden('Đơn hàng không thuộc về bạn', 'ORDER_FORBIDDEN');
    }
    return order;
  },

  myOrders: (userId: number) => orderRepository.listByUser(userId),

  async cancel(orderId: number, user: AuthUser) {
    const order = await this.getOrder(orderId, user);
    if (order.status !== 'PENDING') {
      throw AppError.conflict('Chỉ hủy được đơn hàng đang chờ thanh toán', 'ORDER_NOT_PENDING');
    }
    await orderRepository.updateStatus(orderId, 'CANCELLED');
    return orderRepository.getById(orderId);
  },

  /**
   * POST /payments { orderId, method: 'MOCK', simulate?: 'SUCCESS' | 'FAILED' }
   *   Payment SUCCESS -> Create Ticket -> Generate QR -> Return Ticket
   */
  async pay(user: AuthUser, orderId: number, simulate: 'SUCCESS' | 'FAILED' = 'SUCCESS') {
    const result = await paymentRepository.processMockPayment({
      orderId,
      userId: user.userId,
      success: simulate === 'SUCCESS',
      transactionCode: generateTransactionCode(),
      buildTickets: (details) => {
        const out: TicketToIssue[] = [];
        for (const d of details) {
          for (let i = 0; i < d.quantity; i++) {
            const ticketCode = generateTicketCode();
            out.push({
              ticketTypeId: d.ticketTypeId,
              ticketCode,
              qrCode: buildQrPayload(ticketCode),
              durationMinutes: d.durationMinutes,
            });
          }
        }
        return out;
      },
    });

    const order = await orderRepository.getById(orderId);
    return {
      paymentId: result.paymentId,
      orderId,
      amount: result.amount,
      status: result.status,
      ticketIds: result.ticketIds,
      order,
    };
  },
};
