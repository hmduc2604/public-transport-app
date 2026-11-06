/** Controller ADMIN - moi route deu da qua authenticate + requireAdmin */
import { Request, Response } from 'express';
import { adminService } from '../services/admin.service';
import { ok, created } from '../utils/apiResponse';
import { optionalNumber, optionalString, parseId, parsePagination, validate } from '../utils/validators';
import { schemas } from '../validations/schemas';
import { Schema } from '../utils/validators';

const id = (req: Request) => parseId(req.params.id);
const body = (req: Request, schema: Schema, partial = false) => validate<any>(req.body, schema, partial);

export const adminController = {
  /* ---------- Users ---------- */
  listUsers: async (req: Request, res: Response) =>
    ok(
      res,
      await adminService.listUsers({
        ...parsePagination(req.query),
        search: optionalString(req.query.search),
        role: optionalString(req.query.role)?.toUpperCase(),
        status: optionalString(req.query.status)?.toUpperCase(),
      }),
    ),
  getUser: async (req: Request, res: Response) => ok(res, await adminService.getUser(id(req))),
  updateUser: async (req: Request, res: Response) =>
    ok(res, await adminService.updateUser(id(req), body(req, schemas.adminUser, true), req.user!), 'Cập nhật thành công'),

  /* ---------- Transport types ---------- */
  listTransportTypes: async (_req: Request, res: Response) => ok(res, await adminService.listTransportTypes()),
  createTransportType: async (req: Request, res: Response) =>
    created(res, await adminService.createTransportType(body(req, schemas.transportType))),
  updateTransportType: async (req: Request, res: Response) =>
    ok(res, await adminService.updateTransportType(id(req), body(req, schemas.transportType, true))),
  deleteTransportType: async (req: Request, res: Response) => {
    await adminService.deleteTransportType(id(req));
    return ok(res, null, 'Đã ngừng hoạt động loại phương tiện');
  },

  /* ---------- Vehicles ---------- */
  listVehicles: async (req: Request, res: Response) =>
    ok(
      res,
      await adminService.listVehicles({
        transportTypeId: optionalNumber(req.query.transportTypeId),
        status: optionalString(req.query.status)?.toUpperCase(),
        search: optionalString(req.query.search),
      }),
    ),
  createVehicle: async (req: Request, res: Response) => created(res, await adminService.createVehicle(body(req, schemas.vehicle))),
  updateVehicle: async (req: Request, res: Response) =>
    ok(res, await adminService.updateVehicle(id(req), body(req, schemas.vehicle, true))),
  deleteVehicle: async (req: Request, res: Response) => {
    await adminService.deleteVehicle(id(req));
    return ok(res, null, 'Đã xóa phương tiện');
  },

  /* ---------- Stations ---------- */
  listStations: async (req: Request, res: Response) =>
    ok(
      res,
      await adminService.listStations({
        transportTypeId: optionalNumber(req.query.transportTypeId),
        search: optionalString(req.query.search),
      }),
    ),
  createStation: async (req: Request, res: Response) => created(res, await adminService.createStation(body(req, schemas.station))),
  updateStation: async (req: Request, res: Response) =>
    ok(res, await adminService.updateStation(id(req), body(req, schemas.station, true))),
  deleteStation: async (req: Request, res: Response) => {
    await adminService.deleteStation(id(req));
    return ok(res, null, 'Đã ngừng hoạt động trạm');
  },

  /* ---------- Routes ---------- */
  listRoutes: async (req: Request, res: Response) =>
    ok(
      res,
      await adminService.listRoutes({
        transportTypeId: optionalNumber(req.query.transportTypeId),
        search: optionalString(req.query.search),
      }),
    ),
  getRoute: async (req: Request, res: Response) => ok(res, await adminService.getRoute(id(req))),
  createRoute: async (req: Request, res: Response) => created(res, await adminService.createRoute(body(req, schemas.route))),
  updateRoute: async (req: Request, res: Response) => ok(res, await adminService.updateRoute(id(req), body(req, schemas.route, true))),
  deleteRoute: async (req: Request, res: Response) => {
    await adminService.deleteRoute(id(req));
    return ok(res, null, 'Đã ngừng hoạt động tuyến');
  },
  getRouteStations: async (req: Request, res: Response) => ok(res, (await adminService.getRoute(id(req))).stations),
  replaceRouteStations: async (req: Request, res: Response) => {
    const { stations } = body(req, schemas.routeStations);
    return ok(res, await adminService.replaceRouteStations(id(req), stations), 'Đã cập nhật danh sách trạm');
  },

  /* ---------- Trips / Schedules ---------- */
  listTrips: async (req: Request, res: Response) =>
    ok(
      res,
      await adminService.listTrips({
        routeId: optionalNumber(req.query.routeId),
        status: optionalString(req.query.status)?.toUpperCase(),
      }),
    ),
  getTrip: async (req: Request, res: Response) => ok(res, await adminService.getTrip(id(req))),
  createTrip: async (req: Request, res: Response) => created(res, await adminService.createTrip(body(req, schemas.trip))),
  updateTrip: async (req: Request, res: Response) => ok(res, await adminService.updateTrip(id(req), body(req, schemas.trip, true))),
  deleteTrip: async (req: Request, res: Response) => {
    await adminService.deleteTrip(id(req));
    return ok(res, null, 'Đã xóa chuyến');
  },

  /* ---------- Ticket types ---------- */
  listTicketTypes: async (_req: Request, res: Response) => ok(res, await adminService.listTicketTypes()),
  createTicketType: async (req: Request, res: Response) =>
    created(res, await adminService.createTicketType(body(req, schemas.ticketType))),
  updateTicketType: async (req: Request, res: Response) =>
    ok(res, await adminService.updateTicketType(id(req), body(req, schemas.ticketType, true))),
  deleteTicketType: async (req: Request, res: Response) => {
    await adminService.deleteTicketType(id(req));
    return ok(res, null, 'Đã ngừng bán loại vé');
  },

  /* ---------- Fare rules ---------- */
  listFareRules: async (req: Request, res: Response) =>
    ok(res, await adminService.listFareRules(optionalNumber(req.query.transportTypeId))),
  createFareRule: async (req: Request, res: Response) => created(res, await adminService.createFareRule(body(req, schemas.fareRule))),
  updateFareRule: async (req: Request, res: Response) =>
    ok(res, await adminService.updateFareRule(id(req), body(req, schemas.fareRule, true))),
  deleteFareRule: async (req: Request, res: Response) => {
    await adminService.deleteFareRule(id(req));
    return ok(res, null, 'Đã xóa quy tắc giá');
  },

  /* ---------- Attractions ---------- */
  listAttractions: async (req: Request, res: Response) =>
    ok(
      res,
      await adminService.listAttractions({
        category: optionalString(req.query.category),
        search: optionalString(req.query.search),
      }),
    ),
  getAttraction: async (req: Request, res: Response) => ok(res, await adminService.getAttraction(id(req))),
  createAttraction: async (req: Request, res: Response) =>
    created(res, await adminService.createAttraction(body(req, schemas.attraction))),
  updateAttraction: async (req: Request, res: Response) =>
    ok(res, await adminService.updateAttraction(id(req), body(req, schemas.attraction, true))),
  deleteAttraction: async (req: Request, res: Response) => {
    await adminService.deleteAttraction(id(req));
    return ok(res, null, 'Đã ẩn địa điểm');
  },

  /* ---------- Orders / Tickets / Payments ---------- */
  listOrders: async (req: Request, res: Response) =>
    ok(
      res,
      await adminService.listOrders({
        ...parsePagination(req.query),
        search: optionalString(req.query.search),
        status: optionalString(req.query.status)?.toUpperCase(),
      }),
    ),
  getOrder: async (req: Request, res: Response) => ok(res, await adminService.getOrder(id(req))),
  cancelOrder: async (req: Request, res: Response) => ok(res, await adminService.cancelOrder(id(req)), 'Đã hủy đơn'),

  listTickets: async (req: Request, res: Response) =>
    ok(
      res,
      await adminService.listTickets({
        ...parsePagination(req.query),
        search: optionalString(req.query.search),
        status: optionalString(req.query.status)?.toUpperCase(),
        type: optionalString(req.query.type)?.toUpperCase(),
      }),
    ),
  updateTicketStatus: async (req: Request, res: Response) =>
    ok(res, await adminService.updateTicketStatus(id(req), body(req, schemas.ticketStatus).status)),
  verifyTicket: async (req: Request, res: Response) => {
    const { qrData, markUsed } = body(req, schemas.verifyTicket);
    return ok(res, await adminService.verifyTicket(qrData, markUsed !== false));
  },

  listPayments: async (req: Request, res: Response) =>
    ok(
      res,
      await adminService.listPayments({
        ...parsePagination(req.query),
        status: optionalString(req.query.status)?.toUpperCase(),
      }),
    ),

  /* ---------- Statistics / System ---------- */
  statistics: async (req: Request, res: Response) =>
    ok(res, await adminService.statistics(Math.min(365, Math.max(1, optionalNumber(req.query.days) ?? 30)))),
  rebuildGraph: async (_req: Request, res: Response) =>
    ok(res, await adminService.rebuildRoutingGraph(), 'Đã xây lại graph tìm đường'),
};
