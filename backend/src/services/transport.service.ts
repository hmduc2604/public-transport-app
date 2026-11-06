/** Service: Transport (Nguoi 1 - Map) - loai phuong tien, tram, tuyen, chuyen */
import { transportRepository } from '../repositories/transport.repository';
import { stationRepository } from '../repositories/station.repository';
import { routeRepository } from '../repositories/route.repository';
import { tripRepository } from '../repositories/trip.repository';
import { AppError } from '../utils/AppError';
import { toTransportMode } from '../types/transport.types';
import { currentHanoiTime } from '../utils/time';

const withMode = <T extends { transportTypeName?: string }>(x: T) => ({ ...x, mode: toTransportMode(x.transportTypeName) });

export const transportService = {
  async transportTypes() {
    const list = await transportRepository.listTypes();
    return list.map((t: any) => ({ ...t, mode: toTransportMode(t.name) }));
  },

  /* ---------- Stations ---------- */
  async stations(opts: { transportTypeId?: number; search?: string }) {
    return (await stationRepository.list(opts)).map(withMode);
  },

  async stationDetail(id: number) {
    const station = await stationRepository.getById(id);
    if (!station) throw AppError.notFound('Không tìm thấy trạm', 'STATION_NOT_FOUND');
    const [routes, attractions] = await Promise.all([
      stationRepository.routesOfStation(id),
      stationRepository.attractionsOfStation(id),
    ]);
    return { ...withMode(station), routes: routes.map(withMode), attractions };
  },

  async nearbyStations(lat: number, lng: number, radiusKm = 1, limit = 10, transportTypeId?: number) {
    const rows = await stationRepository.nearby(lat, lng, radiusKm, limit, transportTypeId);
    return rows.map((r: any) => ({ ...withMode(r), distanceMeters: Math.round(r.distanceKm * 1000) }));
  },

  /* ---------- Routes ---------- */
  async routes(opts: { transportTypeId?: number; search?: string }) {
    return (await routeRepository.list(opts)).map(withMode);
  },

  async routeDetail(id: number) {
    const route = await routeRepository.getById(id);
    if (!route) throw AppError.notFound('Không tìm thấy tuyến', 'ROUTE_NOT_FOUND');
    const stations = await routeRepository.stations(id);
    return { ...withMode(route), stations };
  },

  async routeStations(id: number) {
    const route = await routeRepository.getById(id);
    if (!route) throw AppError.notFound('Không tìm thấy tuyến', 'ROUTE_NOT_FOUND');
    return routeRepository.stations(id);
  },

  async routeTrips(id: number, upcomingOnly = false) {
    const route = await routeRepository.getById(id);
    if (!route) throw AppError.notFound('Không tìm thấy tuyến', 'ROUTE_NOT_FOUND');
    const trips = await tripRepository.list({ routeId: id });
    if (!upcomingOnly) return trips;
    const now = currentHanoiTime();
    return trips.filter((t: any) => t.departureTime >= now);
  },

  async tripDetail(id: number) {
    const trip = await tripRepository.getById(id);
    if (!trip) throw AppError.notFound('Không tìm thấy chuyến', 'TRIP_NOT_FOUND');
    return { ...trip, stopTimes: await tripRepository.stopTimes(id) };
  },
};
