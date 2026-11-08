/** Gom tat ca router duoi tien to /api/v1 */
import { Request, Response, Router } from 'express';
import authRoutes from './auth.routes';
import transportRoutes from './transport.routes';
import attractionRoutes from './attraction.routes';
import routingRoutes from './routing.routes';
import ticketRoutes from './ticket.routes';
import paymentRoutes from './payment.routes';
import adminRoutes from './admin.routes';

const api = Router();

api.get('/health', (_req: Request, res: Response) => {
  res.json({ success: true, data: { status: 'OK', time: new Date().toISOString() }, message: 'Success' });
});

api.use(authRoutes);
api.use(transportRoutes);
api.use(attractionRoutes);
api.use(routingRoutes);
api.use(ticketRoutes);
api.use(paymentRoutes);
api.use('/admin', adminRoutes);

export default api;
