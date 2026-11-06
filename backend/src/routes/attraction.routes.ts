/** Diem tham quan - cac route co ten co dinh dat TRUOC /:id */
import { Router } from 'express';
import { attractionController as c } from '../controllers/attraction.controller';
import { asyncHandler as h } from '../utils/asyncHandler';

const router = Router();

router.get('/attractions', h(c.list));
router.get('/attractions/featured', h(c.featured));
router.get('/attractions/categories', h(c.categories));
router.get('/attractions/recommend', h(c.recommend));
router.get('/attractions/nearby', h(c.nearby));
router.get('/attractions/:id', h(c.detail));
router.get('/attractions/:id/nearby-stations', h(c.nearbyStations));

export default router;
