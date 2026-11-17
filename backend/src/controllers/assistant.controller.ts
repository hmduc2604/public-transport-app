import { Request, Response } from 'express';
import { assistantService, AssistantHistoryItem } from '../services/ai/assistant.service';
import { ok } from '../utils/apiResponse';
import { AppError } from '../utils/AppError';
import { isValidLatLng } from '../utils/geo';

export const assistantController = {
  /** GET /assistant/status - frontend biet tro ly da bat chua */
  async status(_req: Request, res: Response) {
    return ok(res, assistantService.status());
  },

  /**
   * POST /assistant/chat
   * { message, history?: [{ role: 'user'|'assistant', text, routes? }], location?: { latitude, longitude } }
   */
  async chat(req: Request, res: Response) {
    const body = req.body ?? {};
    const message = typeof body.message === 'string' ? body.message.trim() : '';
    if (!message) throw AppError.badRequest('Hãy nhập câu hỏi', 'VALIDATION_ERROR');
    if (message.length > 1000) throw AppError.badRequest('Câu hỏi tối đa 1000 ký tự', 'VALIDATION_ERROR');

    const history: AssistantHistoryItem[] = Array.isArray(body.history)
      ? body.history
          .slice(-20)
          .filter((h: any) => h && (h.role === 'user' || h.role === 'assistant') && typeof h.text === 'string')
          .map((h: any) => ({
            role: h.role,
            text: h.text.slice(0, 2000),
            routes: Array.isArray(h.routes)
              ? h.routes.slice(0, 4).map((r: any) => ({
                  from: String(r?.from ?? '').slice(0, 120),
                  to: String(r?.to ?? '').slice(0, 120),
                  fromRef: typeof r?.fromRef === 'string' ? r.fromRef.slice(0, 60) : undefined,
                  toRef: typeof r?.toRef === 'string' ? r.toRef.slice(0, 60) : undefined,
                  preference: typeof r?.preference === 'string' ? r.preference.slice(0, 30) : undefined,
                }))
              : undefined,
          }))
      : [];

    const lat = Number(body.location?.latitude);
    const lng = Number(body.location?.longitude);
    const location = body.location && isValidLatLng(lat, lng) ? { latitude: lat, longitude: lng } : null;

    return ok(res, await assistantService.chat({ userId: req.user!.userId, message, history, location }));
  },
};
