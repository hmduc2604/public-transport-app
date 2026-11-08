/** /api/v1/auth/*  va  /api/v1/users/me */
import { Router } from 'express';
import { authController } from '../controllers/auth.controller';
import { authenticate } from '../middleware/auth.middleware';
import { asyncHandler as h } from '../utils/asyncHandler';
import { rateLimit } from '../middleware/rateLimit.middleware';

const MIN = 60 * 1000;
/** Dang nhap SAI qua 10 lan / 15 phut / IP -> tam khoa */
const loginLimit = rateLimit({
  windowMs: 15 * MIN,
  max: 10,
  message: 'Bạn đã nhập sai quá nhiều lần.',
  errorCode: 'TOO_MANY_LOGIN_ATTEMPTS',
  countWhen: (status) => status === 401,
});
/** Gui ma xac nhan (email / SMS ton phi): toi da 10 lan / gio / IP */
const sendCodeLimit = rateLimit({
  windowMs: 60 * MIN,
  max: 10,
  message: 'Bạn đã yêu cầu gửi mã quá nhiều lần.',
  errorCode: 'TOO_MANY_CODE_REQUESTS',
  countWhen: (status) => status < 400,
});
/** Nhap ma xac nhan: toi da 30 lan / 15 phut / IP */
/** Doi mat khau: nhap sai mat khau hien tai qua 10 lan / 15 phut */
const passwordLimit = rateLimit({
  windowMs: 15 * MIN,
  max: 10,
  message: 'Bạn đã nhập sai mật khẩu quá nhiều lần.',
  errorCode: 'TOO_MANY_LOGIN_ATTEMPTS',
  countWhen: (status) => status === 400,
});
const verifyLimit = rateLimit({ windowMs: 15 * MIN, max: 30, message: 'Bạn đã thử quá nhiều lần.', countWhen: (s) => s >= 400 });

const router = Router();

router.get('/auth/verification-channels', h(authController.channels));
router.post('/auth/register', sendCodeLimit, h(authController.register));
router.post('/auth/register/verify', verifyLimit, h(authController.verify));
router.post('/auth/register/resend', sendCodeLimit, h(authController.resend));
router.post('/auth/login', loginLimit, h(authController.login));
router.post('/auth/logout', h(authController.logout));

router.get('/users/me', authenticate, h(authController.me));
router.put('/users/me', authenticate, h(authController.updateMe));
router.put('/users/me/password', authenticate, passwordLimit, h(authController.changePassword));

export default router;
