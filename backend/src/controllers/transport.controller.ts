import { Request, Response } from 'express';
import { transportService } from '../services/transport.service';
import { ok } from '../utils/apiResponse';
import { AppError } from '../utils/AppError';
import { optionalNumber, optionalString, parseId } from '../utils/validators';
import { isValidLatLng } from '../utils/geo';

export const transportController = {
  async transportTypes(_req: Request, res: Response) {
    return ok(res, await transportService.transportTypes());
  },

  async stations(req: Request, res: Response) {
    return ok(
      res,
      await transportService.stations({
        transportTypeId: optionalNumber(req.query.transportTypeId),
        search: optionalString(req.query.search) ?? optionalString(req.query.keyword),
      }),
    );
  },

  /** GET /stations/nearby?lat=&lng=&radius=1&limit=10&transportTypeId= */
  async nearbyStations(req: Request, res: Response) {
    const lat = optionalNumber(req.query.lat ?? req.query.latitude);
    const lng = optionalNumber(req.query.lng ?? req.query.longitude);
    if (!isValidLatLng(lat, lng)) throw AppError.badRequest('Cần lat và lng hợp lệ', 'INVALID_LOCATION');
    const radius = Math.min(20, optionalNumber(req.query.radius) ?? 1);
    const limit = Math.min(50, optionalNumber(req.query.limit) ?? 10);
    return ok(res, await transportService.nearbyStations(lat!, lng!, radius, limit, optionalNumber(req.query.transportTypeId)));
  },

  async stationDetail(req: Request, res: Response) {
    return ok(res, await transportService.stationDetail(parseId(req.params.id)));
  },

  async routes(req: Request, res: Response) {
    return ok(
      res,
      await transportService.routes({
        transportTypeId: optionalNumber(req.query.transportTypeId),
        search: optionalString(req.query.search),
      }),
    );
  },

  async routeDetail(req: Request, res: Response) {
    return ok(res, await transportService.routeDetail(parseId(req.params.id)));
  },

  async routeStations(req: Request, res: Response) {
    return ok(res, await transportService.routeStations(parseId(req.params.id)));
  },

  /** GET /routes/:id/trips?upcoming=true */
  async routeTrips(req: Request, res: Response) {
    return ok(res, await transportService.routeTrips(parseId(req.params.id), req.query.upcoming === 'true'));
  },

  async tripDetail(req: Request, res: Response) {
    return ok(res, await transportService.tripDetail(parseId(req.params.id)));
  },
};
