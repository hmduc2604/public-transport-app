/** Diem tham quan - cac route co ten co dinh dat TRUOC /:id */
import { Router } from 'express';
import { attractionController as c } from '../controllers/attraction.controller';
import { asyncHandler as h } from '../utils/asyncHandler';
import { optionalAuth } from '../middleware/auth.middleware';
import { rateLimit } from '../middleware/rateLimit.middleware';

/** Goi y AI co the goi Gemini -> gioi han 60 lan / 10 phut moi nguoi dung (hoac IP) */
const suggestLimit = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 60,
  message: 'Bạn yêu cầu gợi ý quá nhiều lần.',
  errorCode: 'AI_TOO_MANY_REQUESTS',
  key: (req) => `suggest:${req.user?.userId ?? req.ip}`,
});

const router = Router();

router.get('/attractions', h(c.list));
router.get('/attractions/featured', h(c.featured));
router.get('/attractions/categories', h(c.categories));
router.get('/attractions/recommend', h(c.recommend));
router.get('/attractions/suggestions', optionalAuth, suggestLimit, h(c.suggestions));
router.get('/attractions/nearby', h(c.nearby));
router.get('/attractions/:id', optionalAuth, h(c.detail));
router.get('/attractions/:id/nearby-stations', h(c.nearbyStations));

export default router;
