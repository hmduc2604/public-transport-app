import { Request, Response } from 'express';
import { attractionService } from '../services/attraction.service';
import { ok } from '../utils/apiResponse';
import { AppError } from '../utils/AppError';
import { optionalNumber, optionalString, parseId } from '../utils/validators';
import { isValidLatLng } from '../utils/geo';

export const attractionController = {
  /** GET /attractions?category=&search=&sort=popular|name|newest */
  async list(req: Request, res: Response) {
    return ok(
      res,
      await attractionService.list({
        category: optionalString(req.query.category),
        search: optionalString(req.query.search),
        sort: optionalString(req.query.sort),
      }),
    );
  },

  async featured(req: Request, res: Response) {
    return ok(res, await attractionService.featured(Math.min(20, optionalNumber(req.query.limit) ?? 8)));
  },

  async categories(_req: Request, res: Response) {
    return ok(res, await attractionService.categories());
  },

  /** GET /attractions/recommend?categories=Di tích,Bảo tàng&lat=&lng=&limit= */
  async recommend(req: Request, res: Response) {
    const lat = optionalNumber(req.query.lat);
    const lng = optionalNumber(req.query.lng);
    const hasLoc = isValidLatLng(lat, lng);
    const categories = (optionalString(req.query.categories) ?? optionalString(req.query.category) ?? '')
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);
    return ok(
      res,
      await attractionService.recommend({
        categories,
        lat: hasLoc ? lat : undefined,
        lng: hasLoc ? lng : undefined,
        limit: Math.min(20, optionalNumber(req.query.limit) ?? 8),
      }),
    );
  },

  async nearby(req: Request, res: Response) {
    const lat = optionalNumber(req.query.lat);
    const lng = optionalNumber(req.query.lng);
    if (!isValidLatLng(lat, lng)) throw AppError.badRequest('Cần lat và lng hợp lệ', 'INVALID_LOCATION');
    return ok(
      res,
      await attractionService.nearby(lat!, lng!, Math.min(20, optionalNumber(req.query.radius) ?? 2), Math.min(50, optionalNumber(req.query.limit) ?? 10)),
    );
  },

  async detail(req: Request, res: Response) {
    return ok(res, await attractionService.detail(parseId(req.params.id)));
  },

  async nearbyStations(req: Request, res: Response) {
    return ok(res, await attractionService.nearbyStations(parseId(req.params.id)));
  },
};
