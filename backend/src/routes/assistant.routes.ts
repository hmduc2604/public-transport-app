/** Tro ly AI lap lo trinh - bat buoc dang nhap (moi lan hoi ton luot goi Gemini) */
import { Router } from 'express';
import { assistantController as c } from '../controllers/assistant.controller';
import { authenticate } from '../middleware/auth.middleware';
import { rateLimit } from '../middleware/rateLimit.middleware';
import { asyncHandler as h } from '../utils/asyncHandler';

const router = Router();

/** Moi tai khoan toi da 40 cau hoi / 10 phut (bao ve han muc khoa Gemini) */
const chatLimit = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 40,
  message: 'Bạn đã hỏi trợ lý AI quá nhiều lần.',
  errorCode: 'AI_TOO_MANY_REQUESTS',
  key: (req) => `ai:${req.user?.userId ?? req.ip}`,
});

router.get('/assistant/status', authenticate, h(c.status));
router.post('/assistant/chat', authenticate, chatLimit, h(c.chat));

export default router;
