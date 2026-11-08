/**
 * Thanh toan: THE NGAN HANG (mo phong) + CHUYEN KHOAN QR (VietQR)
 *   GET  /payments/methods
 *   POST /payments/card            { orderId, cardKind, cardNumber, cardHolder, expiry, cvv?, bankBin? }
 *   POST /payments/bank-transfer   { orderId }      -> Payment PENDING + QR
 *   GET  /payments/:id                              -> trang thai (frontend hoi dinh ky)
 *   POST /payments/:id/transferred                  -> khach bao da chuyen (van PENDING)
 *   POST /payments/webhooks/sepay                   -> SePay bao tien ve (Authorization: Apikey ...)
 */
import { Router } from 'express';
import { paymentController as c } from '../controllers/payment.controller';
import { authenticate } from '../middleware/auth.middleware';
import { asyncHandler as h } from '../utils/asyncHandler';

const router = Router();

router.get('/payments/methods', h(c.methods));
router.post('/payments/webhooks/sepay', h(c.sepayWebhook));
router.post('/payments/card', authenticate, h(c.payByCard));
router.post('/payments/bank-transfer', authenticate, h(c.createTransfer));
router.get('/payments/:id', authenticate, h(c.getPayment));
router.post('/payments/:id/transferred', authenticate, h(c.notifyTransferred));

export default router;
