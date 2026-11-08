/** Service: Don hang (Nguoi 2 - Module Ticket/Payment). Thanh toan: xem payment.service.ts */
import { orderRepository } from '../repositories/order.repository';
import { ticketRepository } from '../repositories/ticket.repository';
import { paymentRepository } from '../repositories/payment.repository';
import { AppError } from '../utils/AppError';
import { AuthUser } from '../types/express';

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
    await paymentRepository.expireOverdue();
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
    await paymentRepository.cancelPendingForOrder(orderId, 'Khách đã hủy đơn hàng');
    return orderRepository.getById(orderId);
  },
};
