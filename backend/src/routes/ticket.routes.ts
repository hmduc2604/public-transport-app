/** Ve, don hang, lich su - (Nguoi 2). Thanh toan: payment.routes.ts */
import { Router } from 'express';
import { ticketController as c } from '../controllers/ticket.controller';
import { authenticate } from '../middleware/auth.middleware';
import { rateLimit } from '../middleware/rateLimit.middleware';
import { asyncHandler as h } from '../utils/asyncHandler';

const router = Router();

/** Tu van chon ve goi Gemini (toi da 2 luot / lan) -> moi tai khoan 20 lan / 10 phut */
const adviceLimit = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 20,
  message: 'Bạn nhờ tư vấn chọn vé quá nhiều lần.',
  errorCode: 'AI_TOO_MANY_REQUESTS',
  key: (req) => `advice:${req.user?.userId ?? req.ip}`,
});

// Public
router.get('/ticket-types', h(c.ticketTypes));

// Can dang nhap
router.get('/tickets/me', authenticate, h(c.myTickets));
router.get('/tickets/my', authenticate, h(c.myTickets)); // alias
router.post('/tickets/advice', authenticate, adviceLimit, h(c.advice));
router.post('/tickets', authenticate, h(c.quickBuy));
router.get('/tickets/:id', authenticate, h(c.ticketDetail));
router.get('/tickets/:id/qr', authenticate, h(c.ticketQr));

router.post('/orders', authenticate, h(c.createOrder));
router.get('/orders/me', authenticate, h(c.myOrders));
router.get('/orders/:id', authenticate, h(c.orderDetail));
router.post('/orders/:id/cancel', authenticate, h(c.cancelOrder));

router.get('/trip-histories', authenticate, h(c.tripHistories));
router.post('/trip-histories', authenticate, h(c.createTripHistory));
router.patch('/trip-histories/:id/complete', authenticate, h(c.completeTripHistory));
router.delete('/trip-histories/:id', authenticate, h(c.deleteTripHistory));

export default router;
