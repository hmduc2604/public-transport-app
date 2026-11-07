/**
 * Tham so cua thuat toan tim duong (Routing).
 * Gom 1 cho de de giai thich khi bao ve va de chinh khi thu nghiem.
 *
 * Toc do dung chung voi 02_seed.sql (sinh StopTimes):
 *   Bus 20 km/h, Metro 35 km/h, Xe dap 12 km/h, Xe dien 18 km/h, Di bo 4.8 km/h
 */
import { TransportMode } from '../types/transport.types';

export const ROUTING_CONFIG = {
  /** Toc do di chuyen (met / phut) */
  speedMPerMin: {
    WALK: 80,
    BUS: 333,
    METRO: 583,
    BICYCLE: 200,
    ELECTRIC_VEHICLE: 300,
  } as Record<TransportMode, number>,

  /** Thoi gian cho trung binh khi len xe (phut) = headway / 2 */
  waitMinutes: {
    WALK: 0,
    BUS: 8,
    METRO: 4,
    BICYCLE: 2, // thoi gian mo khoa / lay xe
    ELECTRIC_VEHICLE: 4,
  } as Record<TransportMode, number>,

  /** Thoi gian dung moi tram (phut) */
  dwellMinutesPerStop: 1,

  /** Gia ve mac dinh moi lan len xe neu khong co FareRule (VND)
   *  Bus: dong gia 7.000d/luot (bang gia pho bien cac tuyen buyt Ha Noi) */
  defaultFare: {
    WALK: 0,
    BUS: 7000,
    METRO: 12000,
    BICYCLE: 5000,
    ELECTRIC_VEHICLE: 10000,
  } as Record<TransportMode, number>,

  /** He so duong vong khi uoc luong quang duong di bo tu duong chim bay */
  walkDetourFactor: 1.25,
  /** He so duong vong cho quang duong xe chay khi thieu DistanceFromStart */
  rideDetourFactor: 1.3,

  /** Ban kinh tim tram gan diem di / diem den (met) */
  accessRadiusM: 1500,
  /** So tram gan nhat toi thieu duoc xet (ke ca khi xa hon ban kinh) */
  minAccessStations: 3,
  /** So tram gan nhat toi da duoc xet */
  maxAccessStations: 8,
  /**
   * Ngoai ra, moi loai phuong tien lay them toi da N tram gan nhat trong ban kinh
   * accessRadiusM -> diem dung bus day dac khong "che" mat ga Metro / tram xe dap.
   */
  perModeAccessStations: 2,
  /** Khoang cach toi da de di bo chuyen tram (met) */
  transferRadiusM: 600,
  /** Khoang cach toi da de goi y di bo thang tu diem di toi diem den (met) */
  maxDirectWalkM: 1500,

  /**
   * Xe dap / xe dien cong cong: duoc lay xe o tram bat ky va tra o tram
   * cung loai khac trong ban kinh nay (met) - mo phong he thong bike-sharing.
   */
  sharedMobilityMaxM: 4000,

  /** Phat moi lan len xe trong che do FEWEST_TRANSFERS (phut quy doi) */
  transferPenaltyMinutes: 20,

  /** So phuong an tra ve */
  maxResults: 3,

  /**
   * Chi duong theo DUONG PHO THAT (OSRM - Open Source Routing Machine, du lieu OpenStreetMap).
   *  - Truoc khi tim: lay quang duong di bo thuc te tu diem di / den toi cac tram ung vien
   *  - Sau khi tim: ve lai tung buoc theo duong pho (di bo, xe dap, xe dien, xe buyt)
   * Metro di tren cao -> giu duong noi thang giua cac ga.
   *
   * Thu tu may chu: OSRM chay tren may (osrm-setup.bat, Docker) -> may chu cong cong
   * routing.openstreetmap.de (du phong). Khong ket noi duoc -> uoc luong duong chim bay.
   */
  roadRouting: {
    enabled: process.env.ROAD_ROUTING !== 'false',
    servers: {
      WALK: [
        process.env.OSRM_FOOT_URL || 'http://localhost:5001',
        'https://routing.openstreetmap.de/routed-foot',
      ],
      BICYCLE: [
        process.env.OSRM_BIKE_URL || 'http://localhost:5002',
        'https://routing.openstreetmap.de/routed-bike',
      ],
      ELECTRIC_VEHICLE: [
        process.env.OSRM_BIKE_URL || 'http://localhost:5002',
        'https://routing.openstreetmap.de/routed-bike',
      ],
      BUS: [
        process.env.OSRM_CAR_URL || 'http://localhost:5003',
        'https://routing.openstreetmap.de/routed-car',
      ],
    } as Partial<Record<TransportMode, string[]>>,
    /** Timeout moi request (ms): may chu tren may / may chu cong cong */
    localTimeoutMs: 3000,
    publicTimeoutMs: 6000,
    /** May chu loi -> bo qua trong khoang thoi gian nay (ms) roi moi thu lai */
    downCooldownMs: 60000,
    /** Doan xe buyt giua 2 tram dai hon (thang x he so + 400m) -> coi la loi bat duong, ve thang */
    maxLegDetourRatio: 2.5,
  },
};

export type RoutingConfig = typeof ROUTING_CONFIG;
