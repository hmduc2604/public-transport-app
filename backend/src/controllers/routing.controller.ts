/**
 * POST /api/v1/routing/search
 * Controller KHONG chua thuat toan - chi nhan request va goi routingService.
 */
import { Request, Response } from 'express';
import { routingService } from '../services/routing.service';
import { ok } from '../utils/apiResponse';
import { recommendationService } from '../services/recommendation.service';

export const routingController = {
  async search(req: Request, res: Response) {
    const result = await routingService.search(req.body ?? {}, req.user?.userId);
    // Tim duong toi 1 dia diem = quan tam manh -> dung cho goi y theo so thich
    recommendationService.track(req.user?.userId, result.destination.attractionId, 'ROUTE');
    return ok(res, result, `Tìm thấy ${result.routes.length} lộ trình`);
  },

  async networkInfo(_req: Request, res: Response) {
    return ok(res, await routingService.networkInfo());
  },
};
