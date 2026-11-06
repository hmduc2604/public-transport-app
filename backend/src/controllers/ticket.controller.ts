import { Request, Response } from 'express';
import { ticketService } from '../services/ticket.service';
import { orderService } from '../services/order.service';
import { tripHistoryService } from '../services/tripHistory.service';
import { ok, created } from '../utils/apiResponse';
import { optionalNumber, optionalString, parseId, validate } from '../utils/validators';
import { schemas } from '../validations/schemas';

export const ticketController = {
  /* ---------- Ticket types ---------- */
  async ticketTypes(req: Request, res: Response) {
    return ok(
      res,
      await ticketService.ticketTypes({
        type: optionalString(req.query.type)?.toUpperCase(),
        transportTypeId: optionalNumber(req.query.transportTypeId),
      }),
    );
  },

  /* ---------- Tickets ---------- */
  async myTickets(req: Request, res: Response) {
    return ok(res, await ticketService.myTickets(req.user!.userId, optionalString(req.query.status)?.toUpperCase()));
  },

  async ticketDetail(req: Request, res: Response) {
    return ok(res, await ticketService.getTicket(parseId(req.params.id), req.user!));
  },

  async ticketQr(req: Request, res: Response) {
    return ok(res, await ticketService.getQr(parseId(req.params.id), req.user!));
  },

  /* ---------- Orders ---------- */
  async createOrder(req: Request, res: Response) {
    const { items } = validate<{ items: { ticketTypeId: number; quantity?: number }[] }>(req.body, schemas.createOrder);
    return created(res, await orderService.create(req.user!.userId, items), 'Tạo đơn hàng thành công');
  },

  /**
   * Mua nhanh 1 loai ve (tuong thich API cu POST /tickets { ticketTypeId, quantity }).
   * Tao Order PENDING -> frontend chuyen sang trang thanh toan.
   */
  async quickBuy(req: Request, res: Response) {
    const ticketTypeId = parseId(req.body?.ticketTypeId, 'ticketTypeId');
    const quantity = optionalNumber(req.body?.quantity) ?? 1;
    return created(res, await orderService.create(req.user!.userId, [{ ticketTypeId, quantity }]), 'Tạo đơn hàng thành công');
  },

  async myOrders(req: Request, res: Response) {
    return ok(res, await orderService.myOrders(req.user!.userId));
  },

  async orderDetail(req: Request, res: Response) {
    return ok(res, await orderService.getOrder(parseId(req.params.id), req.user!));
  },

  async cancelOrder(req: Request, res: Response) {
    return ok(res, await orderService.cancel(parseId(req.params.id), req.user!), 'Đã hủy đơn hàng');
  },

  /* ---------- Payments ---------- */
  async pay(req: Request, res: Response) {
    const { orderId, simulate } = validate<{ orderId: number; simulate?: 'SUCCESS' | 'FAILED' }>(req.body, schemas.payment);
    const result = await orderService.pay(req.user!, orderId, simulate ?? 'SUCCESS');
    return ok(
      res,
      result,
      result.status === 'SUCCESS' ? 'Thanh toán thành công' : 'Thanh toán thất bại (mô phỏng)',
      result.status === 'SUCCESS' ? 201 : 200,
    );
  },

  /* ---------- Trip histories ---------- */
  async tripHistories(req: Request, res: Response) {
    return ok(res, await tripHistoryService.list(req.user!.userId));
  },

  async createTripHistory(req: Request, res: Response) {
    const data = validate<{ origin: string; destination: string; startedAt?: string; completedAt?: string }>(
      req.body,
      schemas.tripHistory,
    );
    return created(res, await tripHistoryService.create(req.user!.userId, { ...data, routeData: req.body?.routeData }));
  },

  async completeTripHistory(req: Request, res: Response) {
    await tripHistoryService.complete(parseId(req.params.id), req.user!.userId);
    return ok(res, null, 'Đã hoàn thành chuyến đi');
  },

  async deleteTripHistory(req: Request, res: Response) {
    await tripHistoryService.remove(parseId(req.params.id), req.user!.userId);
    return ok(res, null, 'Đã xóa');
  },
};
