/** /api/v1/auth/*  va  /api/v1/users/me */
import { Router } from 'express';
import { authController } from '../controllers/auth.controller';
import { authenticate } from '../middleware/auth.middleware';
import { asyncHandler as h } from '../utils/asyncHandler';

const router = Router();

router.get('/auth/verification-channels', h(authController.channels));
router.post('/auth/register', h(authController.register));
router.post('/auth/register/verify', h(authController.verify));
router.post('/auth/register/resend', h(authController.resend));
router.post('/auth/login', h(authController.login));
router.post('/auth/logout', h(authController.logout));

router.get('/users/me', authenticate, h(authController.me));
router.put('/users/me', authenticate, h(authController.updateMe));
router.put('/users/me/password', authenticate, h(authController.changePassword));

export default router;
