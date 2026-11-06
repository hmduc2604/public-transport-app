/** Public API cho ban do: loai phuong tien, tram, tuyen, chuyen */
import { Router } from 'express';
import { transportController as c } from '../controllers/transport.controller';
import { asyncHandler as h } from '../utils/asyncHandler';

const router = Router();

router.get('/transport-types', h(c.transportTypes));

// Luu y: /stations/nearby phai dat TRUOC /stations/:id
router.get('/stations', h(c.stations));
router.get('/stations/nearby', h(c.nearbyStations));
router.get('/stations/:id', h(c.stationDetail));
router.get('/search/stations', h(c.stations)); // ?keyword=Hoan Kiem

router.get('/routes', h(c.routes));
router.get('/routes/:id', h(c.routeDetail));
router.get('/routes/:id/stations', h(c.routeStations));
router.get('/routes/:id/trips', h(c.routeTrips));

router.get('/trips/:id', h(c.tripDetail));

export default router;
