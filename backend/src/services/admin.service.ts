/**
 * Service: ADMIN (Nguoi 3)
 * CRUD toan bo du lieu he thong + thong ke.
 *
 * Quy uoc xoa:
 *   - Du lieu "goc" co nhieu bang tham chieu (TransportType, Station, Route,
 *     TicketType, Attraction) -> XOA MEM: Status = 'INACTIVE'
 *     (giu lich su ve, don hang, lich trinh khong bi vo FK)
 *   - Du lieu "la" (Vehicle, Trip, FareRule) -> XOA THAT; neu dang duoc
 *     tham chieu SQL tra loi 547 -> error.middleware tra 409 CONSTRAINT_VIOLATION
 *
 * Moi thay doi anh huong toi do thi giao thong deu goi
 * routingService.invalidate() de graph duoc xay lai.
 */
import { userRepository } from '../repositories/user.repository';
import { transportRepository } from '../repositories/transport.repository';
import { stationRepository } from '../repositories/station.repository';
import { routeRepository, RouteStopInput } from '../repositories/route.repository';
import { tripRepository, TripInput } from '../repositories/trip.repository';
import { ticketRepository } from '../repositories/ticket.repository';
import { fareRuleRepository } from '../repositories/fareRule.repository';
import { attractionRepository } from '../repositories/attraction.repository';
import { orderRepository } from '../repositories/order.repository';
import { paymentRepository } from '../repositories/payment.repository';
import { statisticsRepository } from '../repositories/statistics.repository';
import { routingService } from './routing.service';
import { ticketService } from './ticket.service';
import { paymentService } from './payment.service';
import { invalidateUserCache } from '../middleware/auth.middleware';
import { normalizeVnPhone } from '../utils/phone';
import { AppError } from '../utils/AppError';
import { paginated } from '../utils/apiResponse';
import { AuthUser } from '../types/express';
import { toTransportMode } from '../types/transport.types';

function ensure<T>(value: T | null | undefined | false, message: string, code: string): T {
  if (!value) throw AppError.notFound(message, code);
  return value as T;
}

type Page = { page: number; pageSize: number; offset: number };

/**
 * Bo suu tap anh tren form admin: moi dong 1 anh
 *   URL | chu thich | tac gia / giay phep | link trang nguon
 */
function imagesToText(images: any[]): string {
  return images.map((i) => [i.imageUrl, i.caption ?? '', i.credit ?? '', i.sourceUrl ?? ''].join(' | ')).join('\n');
}
function textToImages(text: string) {
  return text
    .split(/\r?\n/)
    .map((line) => line.split('|').map((s) => s.trim()))
    .filter((p) => p[0])
    .map(([imageUrl, caption, credit, sourceUrl]) => ({
      imageUrl,
      caption: caption || null,
      credit: credit || null,
      sourceUrl: sourceUrl || null,
    }));
}

/* ---------- Kiem tra chuyen: cung loai phuong tien, thoi gian hop ly, xe khong chay 2 chuyen cung luc ---------- */
const MAX_TRIP_MINUTES = 6 * 60;
const toMin = (t: string) => {
  const [h, m] = t.split(':').map(Number);
  return h * 60 + m;
};
/** Khoang [bat dau, ket thuc] theo phut; qua nua dem -> ket thuc + 1440 */
const tripSpan = (dep: string, arr: string) => {
  const s = toMin(dep);
  let e = toMin(arr);
  if (e <= s) e += 1440;
  return [s, e] as const;
};

async function checkTrip(t: TripInput, selfId?: number) {
  const route = ensure(await routeRepository.getById(t.routeId), 'Tuyến không tồn tại', 'ROUTE_NOT_FOUND');
  const vehicle = ensure(await transportRepository.getVehicle(t.vehicleId), 'Phương tiện không tồn tại', 'VEHICLE_NOT_FOUND');
  if (route.transportTypeId !== vehicle.transportTypeId) {
    throw AppError.badRequest('Phương tiện không cùng loại với tuyến', 'VEHICLE_TYPE_MISMATCH');
  }
  const [s, e] = tripSpan(t.departureTime, t.arrivalTime);
  if (e - s > MAX_TRIP_MINUTES) {
    throw AppError.badRequest('Giờ đến phải sau giờ xuất phát (một chuyến tối đa 6 giờ)', 'INVALID_TRIP_TIME', {
      arrivalTime: 'Giờ đến phải sau giờ xuất phát',
    });
  }
  if (t.status === 'CANCELLED') return;
  const others = await tripRepository.list({ vehicleId: t.vehicleId, limit: 5000 });
  for (const o of others) {
    if (o.tripId === selfId || o.status === 'CANCELLED') continue;
    const [os, oe] = tripSpan(o.departureTime, o.arrivalTime);
    // so sanh ca truong hop lech 1 ngay (chuyen qua nua dem)
    const overlap = [-1440, 0, 1440].some((d) => s < oe + d && os + d < e);
    if (overlap) {
      throw AppError.conflict(
        `Phương tiện ${vehicle.vehicleCode ?? ''} đang chạy chuyến ${o.tripCode} (${o.departureTime} - ${o.arrivalTime}) trùng giờ`,
        'VEHICLE_SCHEDULE_CONFLICT',
      );
    }
  }
}

export const adminService = {
  /* ======================= USERS ======================= */
  async listUsers(q: Page & { search?: string; role?: string; status?: string }) {
    const r = await userRepository.list(q);
    return paginated(r.items, r.total, q.page, q.pageSize);
  },

  async getUser(id: number) {
    return ensure(await userRepository.findById(id), 'Không tìm thấy người dùng', 'USER_NOT_FOUND');
  },

  async updateUser(id: number, data: { fullName?: string; phone?: string; role?: string; status?: string }, actor: AuthUser) {
    await this.getUser(id);
    if (id === actor.userId && (data.role === 'USER' || data.status === 'LOCKED')) {
      throw AppError.badRequest('Không thể tự hạ quyền hoặc tự khóa tài khoản của chính mình', 'SELF_MODIFICATION');
    }
    if (data.phone) {
      const phone = normalizeVnPhone(data.phone);
      if (!phone) throw AppError.badRequest('Số điện thoại không hợp lệ (vd: 0912345678)', 'INVALID_PHONE');
      data = { ...data, phone };
    }
    await userRepository.update(id, data);
    invalidateUserCache(id);
    return this.getUser(id);
  },

  /* ======================= TRANSPORT TYPES ======================= */
  listTransportTypes: () => transportRepository.listTypes(true),

  async createTransportType(data: any) {
    const id = await transportRepository.createType(data);
    return transportRepository.getType(id);
  },

  async updateTransportType(id: number, data: any) {
    ensure(await transportRepository.updateType(id, data), 'Không tìm thấy loại phương tiện', 'TRANSPORT_TYPE_NOT_FOUND');
    routingService.invalidate();
    return transportRepository.getType(id);
  },

  async deleteTransportType(id: number) {
    ensure(await transportRepository.updateType(id, { status: 'INACTIVE' }), 'Không tìm thấy loại phương tiện', 'TRANSPORT_TYPE_NOT_FOUND');
    routingService.invalidate();
  },

  /* ======================= VEHICLES ======================= */
  listVehicles: (q: { transportTypeId?: number; status?: string; search?: string }) => transportRepository.listVehicles(q),

  async createVehicle(data: any) {
    ensure(await transportRepository.getType(data.transportTypeId), 'Loại phương tiện không tồn tại', 'TRANSPORT_TYPE_NOT_FOUND');
    const id = await transportRepository.createVehicle(data);
    return transportRepository.getVehicle(id);
  },

  async updateVehicle(id: number, data: any) {
    ensure(await transportRepository.updateVehicle(id, data), 'Không tìm thấy phương tiện', 'VEHICLE_NOT_FOUND');
    return transportRepository.getVehicle(id);
  },

  async deleteVehicle(id: number) {
    ensure(await transportRepository.deleteVehicle(id), 'Không tìm thấy phương tiện', 'VEHICLE_NOT_FOUND');
  },

  /* ======================= STATIONS ======================= */
  async listStations(q: { transportTypeId?: number; search?: string }) {
    const list = await stationRepository.list({ ...q, includeInactive: true });
    return list.map((s: any) => ({ ...s, mode: toTransportMode(s.transportTypeName) }));
  },

  async createStation(data: any) {
    ensure(await transportRepository.getType(data.transportTypeId), 'Loại phương tiện không tồn tại', 'TRANSPORT_TYPE_NOT_FOUND');
    const id = await stationRepository.create(data);
    routingService.invalidate();
    return stationRepository.getById(id);
  },

  async updateStation(id: number, data: any) {
    ensure(await stationRepository.update(id, data), 'Không tìm thấy trạm', 'STATION_NOT_FOUND');
    routingService.invalidate();
    return stationRepository.getById(id);
  },

  async deleteStation(id: number) {
    ensure(await stationRepository.update(id, { status: 'INACTIVE' }), 'Không tìm thấy trạm', 'STATION_NOT_FOUND');
    routingService.invalidate();
  },

  /* ======================= ROUTES ======================= */
  async listRoutes(q: { transportTypeId?: number; search?: string }) {
    const list = await routeRepository.list({ ...q, includeInactive: true });
    return list.map((r: any) => ({ ...r, mode: toTransportMode(r.transportTypeName) }));
  },

  async getRoute(id: number) {
    const route = ensure(await routeRepository.getById(id), 'Không tìm thấy tuyến', 'ROUTE_NOT_FOUND');
    return { ...route, stations: await routeRepository.stations(id) };
  },

  async createRoute(data: any) {
    ensure(await transportRepository.getType(data.transportTypeId), 'Loại phương tiện không tồn tại', 'TRANSPORT_TYPE_NOT_FOUND');
    const { stations, ...routeData } = data;
    const id = await routeRepository.create(routeData);
    if (Array.isArray(stations) && stations.length > 0) await this.replaceRouteStations(id, stations);
    routingService.invalidate();
    return this.getRoute(id);
  },

  async updateRoute(id: number, data: any) {
    const { stations, ...routeData } = data;
    ensure(await routeRepository.update(id, routeData), 'Không tìm thấy tuyến', 'ROUTE_NOT_FOUND');
    if (Array.isArray(stations)) await this.replaceRouteStations(id, stations);
    routingService.invalidate();
    return this.getRoute(id);
  },

  async deleteRoute(id: number) {
    ensure(await routeRepository.update(id, { status: 'INACTIVE' }), 'Không tìm thấy tuyến', 'ROUTE_NOT_FOUND');
    routingService.invalidate();
  },

  async replaceRouteStations(routeId: number, stops: RouteStopInput[]) {
    ensure(await routeRepository.getById(routeId), 'Không tìm thấy tuyến', 'ROUTE_NOT_FOUND');
    if (stops.length < 2) throw AppError.badRequest('Một tuyến cần ít nhất 2 trạm', 'ROUTE_NEEDS_2_STATIONS');
    const ids = stops.map((s) => Number(s.stationId));
    if (ids.some((x) => !Number.isInteger(x) || x <= 0)) throw AppError.badRequest('stationId không hợp lệ', 'VALIDATION_ERROR');
    for (let i = 1; i < ids.length; i++) {
      if (ids[i] === ids[i - 1]) throw AppError.badRequest('Hai trạm liên tiếp không được trùng nhau', 'DUPLICATE_STOP');
    }
    for (const sid of new Set(ids)) {
      ensure(await stationRepository.getById(sid), `Trạm #${sid} không tồn tại`, 'STATION_NOT_FOUND');
    }
    await routeRepository.replaceStations(
      routeId,
      stops.map((s) => ({
        stationId: Number(s.stationId),
        distanceFromStart:
          s.distanceFromStart === undefined || s.distanceFromStart === null ? null : Number(s.distanceFromStart),
      })),
    );
    routingService.invalidate();
    return routeRepository.stations(routeId);
  },

  /* ======================= TRIPS (Schedules) ======================= */
  listTrips: (q: { routeId?: number; status?: string }) => tripRepository.list({ ...q, limit: 3000 }),

  async getTrip(id: number) {
    const trip = ensure(await tripRepository.getById(id), 'Không tìm thấy chuyến', 'TRIP_NOT_FOUND');
    return { ...trip, stopTimes: await tripRepository.stopTimes(id) };
  },

  async createTrip(data: TripInput) {
    await checkTrip(data);
    const id = await tripRepository.create(data);
    routingService.invalidate();
    return this.getTrip(id);
  },

  async updateTrip(id: number, data: Partial<TripInput>) {
    const cur = ensure(await tripRepository.getById(id), 'Không tìm thấy chuyến', 'TRIP_NOT_FOUND');
    await checkTrip({ ...cur, ...Object.fromEntries(Object.entries(data).filter(([, v]) => v !== undefined)) } as TripInput, id);
    ensure(await tripRepository.update(id, data), 'Không tìm thấy chuyến', 'TRIP_NOT_FOUND');
    routingService.invalidate();
    return this.getTrip(id);
  },

  async deleteTrip(id: number) {
    ensure(await tripRepository.delete(id), 'Không tìm thấy chuyến', 'TRIP_NOT_FOUND');
    routingService.invalidate();
  },

  /* ======================= TICKET TYPES ======================= */
  listTicketTypes: () => ticketRepository.listTypes({ includeInactive: true }),

  async createTicketType(data: any) {
    ensure(await transportRepository.getType(data.transportTypeId), 'Loại phương tiện không tồn tại', 'TRANSPORT_TYPE_NOT_FOUND');
    const id = await ticketRepository.createType(data);
    return ticketRepository.getType(id);
  },

  async updateTicketType(id: number, data: any) {
    ensure(await ticketRepository.updateType(id, data), 'Không tìm thấy loại vé', 'TICKET_TYPE_NOT_FOUND');
    return ticketRepository.getType(id);
  },

  async deleteTicketType(id: number) {
    ensure(await ticketRepository.updateType(id, { status: 'INACTIVE' }), 'Không tìm thấy loại vé', 'TICKET_TYPE_NOT_FOUND');
  },

  /* ======================= FARE RULES ======================= */
  listFareRules: (transportTypeId?: number) => fareRuleRepository.list(transportTypeId),

  async createFareRule(data: any) {
    if (data.fromStationId === data.toStationId) throw AppError.badRequest('Trạm đi và trạm đến phải khác nhau', 'SAME_STATION');
    const id = await fareRuleRepository.create(data);
    routingService.invalidate();
    return fareRuleRepository.getById(id);
  },

  async updateFareRule(id: number, data: any) {
    ensure(await fareRuleRepository.update(id, data), 'Không tìm thấy quy tắc giá', 'FARE_RULE_NOT_FOUND');
    routingService.invalidate();
    return fareRuleRepository.getById(id);
  },

  async deleteFareRule(id: number) {
    ensure(await fareRuleRepository.delete(id), 'Không tìm thấy quy tắc giá', 'FARE_RULE_NOT_FOUND');
    routingService.invalidate();
  },

  /* ======================= ATTRACTIONS ======================= */
  async listAttractions(q: { category?: string; search?: string }) {
    const [rows, images] = await Promise.all([
      attractionRepository.list({ ...q, includeInactive: true, sort: 'popular' }),
      attractionRepository.allImages(),
    ]);
    return rows.map((a: any) => ({
      ...a,
      imagesText: imagesToText(images.filter((i) => i.attractionId === a.attractionId)),
    }));
  },

  async getAttraction(id: number) {
    const a = ensure(await attractionRepository.getById(id), 'Không tìm thấy địa điểm', 'ATTRACTION_NOT_FOUND');
    const [nearbyStations, images] = await Promise.all([
      attractionRepository.nearbyStations(id),
      attractionRepository.images(id),
    ]);
    return { ...a, nearbyStations, images, imagesText: imagesToText(images) };
  },

  async createAttraction(data: any) {
    const { stations, imagesText, ...rest } = data;
    const id = await attractionRepository.create(rest);
    if (Array.isArray(stations)) await attractionRepository.replaceStations(id, stations);
    if (typeof imagesText === 'string') await attractionRepository.replaceImages(id, textToImages(imagesText));
    routingService.invalidate();
    return this.getAttraction(id);
  },

  async updateAttraction(id: number, data: any) {
    const { stations, imagesText, ...rest } = data;
    ensure(await attractionRepository.update(id, rest), 'Không tìm thấy địa điểm', 'ATTRACTION_NOT_FOUND');
    if (Array.isArray(stations)) await attractionRepository.replaceStations(id, stations);
    if (typeof imagesText === 'string') await attractionRepository.replaceImages(id, textToImages(imagesText));
    routingService.invalidate();
    return this.getAttraction(id);
  },

  async deleteAttraction(id: number) {
    ensure(await attractionRepository.update(id, { status: 'INACTIVE' }), 'Không tìm thấy địa điểm', 'ATTRACTION_NOT_FOUND');
  },

  /* ======================= ORDERS / TICKETS / PAYMENTS ======================= */
  async listOrders(q: Page & { search?: string; status?: string }) {
    const r = await orderRepository.listAll(q);
    return paginated(r.items, r.total, q.page, q.pageSize);
  },

  async getOrder(id: number) {
    return ensure(await orderRepository.getById(id), 'Không tìm thấy đơn hàng', 'ORDER_NOT_FOUND');
  },

  async cancelOrder(id: number) {
    const order = await this.getOrder(id);
    if (order.status !== 'PENDING') throw AppError.conflict('Chỉ hủy được đơn PENDING', 'ORDER_NOT_PENDING');
    await orderRepository.updateStatus(id, 'CANCELLED');
    await paymentRepository.cancelPendingForOrder(id, 'Quản trị viên đã hủy đơn hàng');
    return this.getOrder(id);
  },

  async listTickets(q: Page & { search?: string; status?: string; type?: string }) {
    await ticketRepository.expireOverdue();
    const r = await ticketRepository.listAll(q);
    return paginated(r.items, r.total, q.page, q.pageSize);
  },

  async updateTicketStatus(id: number, status: string) {
    ensure(await ticketRepository.updateStatus(id, status), 'Không tìm thấy vé', 'TICKET_NOT_FOUND');
    return ticketRepository.getById(id);
  },

  verifyTicket: (qrData: string, markUsed: boolean) => ticketService.verify(qrData, markUsed),

  async listPayments(q: Page & { status?: string; method?: string; search?: string }) {
    const r = await paymentService.listAll(q);
    return paginated(r.items, r.total, q.page, q.pageSize);
  },
  confirmTransfer: (admin: AuthUser, id: number, bankReference?: string | null) => paymentService.confirmTransfer(admin, id, bankReference),
  rejectTransfer: (admin: AuthUser, id: number, note?: string | null) => paymentService.rejectTransfer(admin, id, note),
  paymentSettings: async () => ({ ...(await paymentService.getSettings()), banks: (await paymentService.methods()).banks }),
  updatePaymentSettings: (input: any) => paymentService.updateSettings(input),
  clearPaymentSettings: () => paymentService.clearSettings(),

  /* ======================= STATISTICS / SYSTEM ======================= */
  statistics: (days: number) => statisticsRepository.overview(days),

  async rebuildRoutingGraph() {
    routingService.invalidate();
    return routingService.networkInfo();
  },
};
