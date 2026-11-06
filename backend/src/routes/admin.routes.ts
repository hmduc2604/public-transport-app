/**
 * /api/v1/admin/*  - TAT CA deu yeu cau: dang nhap + Role = ADMIN
 */
import { Router } from 'express';
import { adminController as c } from '../controllers/admin.controller';
import { authenticate } from '../middleware/auth.middleware';
import { requireAdmin } from '../middleware/admin.middleware';
import { asyncHandler as h } from '../utils/asyncHandler';

const router = Router();
router.use(authenticate, requireAdmin);

/** Dang ky nhanh bo CRUD chuan: GET list, GET :id, POST, PUT :id, DELETE :id */
function crud(
  path: string,
  handlers: { list: any; get?: any; create: any; update: any; remove: any },
) {
  router.get(path, h(handlers.list));
  if (handlers.get) router.get(`${path}/:id`, h(handlers.get));
  router.post(path, h(handlers.create));
  router.put(`${path}/:id`, h(handlers.update));
  router.delete(`${path}/:id`, h(handlers.remove));
}

// Users (khong xoa user - chi khoa)
router.get('/users', h(c.listUsers));
router.get('/users/:id', h(c.getUser));
router.put('/users/:id', h(c.updateUser));

crud('/transport-types', { list: c.listTransportTypes, create: c.createTransportType, update: c.updateTransportType, remove: c.deleteTransportType });
crud('/vehicles', { list: c.listVehicles, create: c.createVehicle, update: c.updateVehicle, remove: c.deleteVehicle });
crud('/stations', { list: c.listStations, create: c.createStation, update: c.updateStation, remove: c.deleteStation });
crud('/routes', { list: c.listRoutes, get: c.getRoute, create: c.createRoute, update: c.updateRoute, remove: c.deleteRoute });
router.get('/routes/:id/stations', h(c.getRouteStations));
router.put('/routes/:id/stations', h(c.replaceRouteStations));

crud('/trips', { list: c.listTrips, get: c.getTrip, create: c.createTrip, update: c.updateTrip, remove: c.deleteTrip });
crud('/schedules', { list: c.listTrips, get: c.getTrip, create: c.createTrip, update: c.updateTrip, remove: c.deleteTrip }); // alias theo tai lieu v2
crud('/ticket-types', { list: c.listTicketTypes, create: c.createTicketType, update: c.updateTicketType, remove: c.deleteTicketType });
crud('/fare-rules', { list: c.listFareRules, create: c.createFareRule, update: c.updateFareRule, remove: c.deleteFareRule });
crud('/fares', { list: c.listFareRules, create: c.createFareRule, update: c.updateFareRule, remove: c.deleteFareRule }); // alias
crud('/attractions', { list: c.listAttractions, get: c.getAttraction, create: c.createAttraction, update: c.updateAttraction, remove: c.deleteAttraction });

router.get('/orders', h(c.listOrders));
router.get('/orders/:id', h(c.getOrder));
router.post('/orders/:id/cancel', h(c.cancelOrder));

router.get('/tickets', h(c.listTickets));
router.post('/tickets/verify', h(c.verifyTicket));
router.patch('/tickets/:id/status', h(c.updateTicketStatus));

router.get('/payments', h(c.listPayments));

router.get('/statistics', h(c.statistics));
router.post('/routing/rebuild', h(c.rebuildGraph));

export default router;
