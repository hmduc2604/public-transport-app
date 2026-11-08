import { Request, Response } from 'express';
import { paymentService } from '../services/payment.service';
import { ok, created } from '../utils/apiResponse';
import { parseId, validate } from '../utils/validators';
import { schemas } from '../validations/schemas';
import { CardInput } from '../utils/card';

export const paymentController = {
  methods: async (_req: Request, res: Response) => ok(res, await paymentService.methods()),

  async payByCard(req: Request, res: Response) {
    const { orderId, ...card } = validate<CardInput & { orderId: number }>(req.body, schemas.cardPayment);
    const result = await paymentService.payByCard(req.user!, orderId, card);
    return result.status === 'SUCCESS'
      ? created(res, result, 'Thanh toán thẻ thành công')
      : ok(res, result, result.message || 'Giao dịch thẻ bị từ chối');
  },

  async createTransfer(req: Request, res: Response) {
    const { orderId } = validate<{ orderId: number }>(req.body, schemas.bankTransfer);
    return created(res, await paymentService.createTransfer(req.user!, orderId), 'Đã tạo mã QR chuyển khoản');
  },

  getPayment: async (req: Request, res: Response) => ok(res, await paymentService.getPayment(req.user!, parseId(req.params.id))),

  notifyTransferred: async (req: Request, res: Response) =>
    ok(
      res,
      await paymentService.notifyTransferred(req.user!, parseId(req.params.id)),
      'Đã ghi nhận. Vé sẽ được phát hành ngay khi hệ thống xác nhận tiền đã về tài khoản.',
    ),

  /** SePay luon can HTTP 200 + {success:true} khi da nhan */
  async sepayWebhook(req: Request, res: Response) {
    const result = await paymentService.sepayWebhook(req.headers.authorization, req.body);
    return res.status(200).json({ success: true, data: result, message: 'OK' });
  },
};
