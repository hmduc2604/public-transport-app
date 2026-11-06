/** Kieu du lieu cho API tim duong POST /api/v1/routing/search */
import { TransportMode } from './transport.types';

export type RoutePreference = 'FASTEST' | 'CHEAPEST' | 'LEAST_WALKING' | 'FEWEST_TRANSFERS';

export const ROUTE_PREFERENCES: RoutePreference[] = [
  'FASTEST',
  'CHEAPEST',
  'LEAST_WALKING',
  'FEWEST_TRANSFERS',
];

/** Diem di / diem den: 1 trong 3 cach - toa do, tram, hoac diem tham quan */
export interface LocationInput {
  latitude?: number;
  longitude?: number;
  stationId?: number;
  attractionId?: number;
  name?: string;
}

/** Diem da duoc "giai" ra toa do cu the */
export interface ResolvedLocation {
  name: string;
  latitude: number;
  longitude: number;
  stationId?: number;
  attractionId?: number;
}

export interface Place {
  name: string;
  latitude: number;
  longitude: number;
  stationId?: number;
}

export interface RouteStep {
  mode: TransportMode;
  from: Place;
  to: Place;
  routeId?: number;
  routeCode?: string;
  routeName?: string;
  transportTypeId?: number;
  /** cac tram di qua (ke ca tram len / xuong) */
  stops?: Place[];
  numStops?: number;
  /** phut */
  duration: number;
  /** phut cho xe (chi voi buoc di xe) */
  waitTime?: number;
  /** met */
  distance: number;
  /** VND */
  fare: number;
  /** true neu nguoi dung da co ve thang cho loai phuong tien nay */
  coveredByPass?: boolean;
  /** cac gio xe sap toi tai tram len (HH:mm) */
  nextDepartures?: string[];
  /** toa do de frontend ve polyline: [lat, lng][] */
  path: [number, number][];
  instruction: string;
}

export interface RouteResult {
  id: string;
  preference: RoutePreference;
  /** nhan hien thi: Nhanh nhat / Re nhat / ... */
  labels: RoutePreference[];
  totalDuration: number;
  totalDistance: number;
  totalFare: number;
  /** so tien phai tra sau khi tru ve thang (neu dang nhap) */
  fareToPay: number;
  walkingDistance: number;
  walkingDuration: number;
  waitingTime: number;
  transfers: number;
  modes: TransportMode[];
  steps: RouteStep[];
  summary: string;
}

export interface RoutingSearchResult {
  origin: ResolvedLocation;
  destination: ResolvedLocation;
  preference: RoutePreference;
  departureTime: string;
  routes: RouteResult[];
  stats: {
    graphNodes: number;
    graphEdges: number;
    computeTimeMs: number;
  };
}
