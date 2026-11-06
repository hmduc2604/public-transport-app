/** Kieu du lieu dung chung cho module Transport / Routing */

export type TransportMode = 'WALK' | 'BUS' | 'METRO' | 'BICYCLE' | 'ELECTRIC_VEHICLE';

/** Chuyen ten TransportTypes.Name trong DB -> ma phuong tien dung trong code */
export function toTransportMode(name: string | null | undefined): TransportMode {
  const n = (name || '').toLowerCase();
  if (n.includes('metro') || n.includes('tàu')) return 'METRO';
  if (n.includes('bicycle') || n.includes('bike') || n.includes('đạp')) return 'BICYCLE';
  if (n.includes('electric') || n.includes('ev') || n.includes('điện')) return 'ELECTRIC_VEHICLE';
  return 'BUS';
}

export interface Station {
  stationId: number;
  stationCode: string;
  stationName: string;
  latitude: number;
  longitude: number;
  address: string | null;
  transportTypeId: number;
  transportTypeName?: string;
  mode?: TransportMode;
  status: string;
}

export interface RouteStop {
  routeId: number;
  stationId: number;
  stopOrder: number;
  distanceFromStart: number | null;
}

export interface TransitRoute {
  routeId: number;
  routeCode: string;
  routeName: string;
  transportTypeId: number;
  transportTypeName: string;
  mode: TransportMode;
  status: string;
}

export interface FareRule {
  transportTypeId: number;
  fromStationId: number;
  toStationId: number;
  price: number;
}

export interface AttractionAccess {
  attractionId: number;
  stationId: number;
  walkingDistance: number | null;
  walkingDuration: number | null;
}

/** Gio xe chay tai 1 tram cua 1 tuyen (de tinh nextDepartures) */
export interface DepartureIndex {
  /** key = `${routeId}:${stationId}` -> danh sach gio di dang 'HH:mm', da sap xep */
  [key: string]: string[];
}
