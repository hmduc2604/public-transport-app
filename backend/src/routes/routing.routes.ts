/** Tim duong - khong bat buoc dang nhap (dang nhap thi duoc tinh ve thang) */
import { Router } from 'express';
import { routingController as c } from '../controllers/routing.controller';
import { optionalAuth } from '../middleware/auth.middleware';
import { asyncHandler as h } from '../utils/asyncHandler';

const router = Router();

router.post('/routing/search', optionalAuth, h(c.search));
router.post('/routing/find', optionalAuth, h(c.search)); // ten cu trong tai lieu v2
router.get('/routing/network', h(c.networkInfo));

export default router;
