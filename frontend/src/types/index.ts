/** Kieu du lieu khop voi response cua backend (/api/v1) */

export type TransportMode = 'WALK' | 'BUS' | 'METRO' | 'BICYCLE' | 'ELECTRIC_VEHICLE';
export type RoutePreference = 'FASTEST' | 'CHEAPEST' | 'LEAST_WALKING' | 'FEWEST_TRANSFERS';

export interface ApiEnvelope<T> {
  success: boolean;
  data: T;
  message: string;
  errorCode?: string;
  details?: Record<string, string>;
}

export interface Paginated<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

/* ---------- User ---------- */
export interface User {
  id: number;
  userId: number;
  name: string;
  fullName: string;
  email: string;
  phone: string | null;
  role: 'USER' | 'ADMIN';
  status: 'ACTIVE' | 'LOCKED';
  createdAt: string;
}

export interface AuthResponse {
  token: string;
  user: User;
}

/* ---------- Transport ---------- */
export interface TransportType {
  transportTypeId: number;
  name: string;
  description: string | null;
  status: string;
  mode: TransportMode;
  stationCount?: number;
  routeCount?: number;
  vehicleCount?: number;
}

export interface Station {
  stationId: number;
  stationCode: string;
  stationName: string;
  latitude: number;
  longitude: number;
  address: string | null;
  transportTypeId: number;
  transportTypeName: string;
  mode: TransportMode;
  status: string;
  distanceMeters?: number;
}

export interface StationDetail extends Station {
  routes: { routeId: number; routeCode: string; routeName: string; mode: TransportMode; stopOrder: number }[];
  attractions: { attractionId: number; name: string; category: string; walkingDistance: number; walkingDuration: number }[];
}

export interface TransitRoute {
  routeId: number;
  routeCode: string;
  routeName: string;
  transportTypeId: number;
  transportTypeName: string;
  mode: TransportMode;
  description: string | null;
  startStationName: string | null;
  endStationName: string | null;
  stopCount: number;
  tripCount: number;
  status: string;
}

export interface RouteStationItem {
  routeStationId: number;
  stopOrder: number;
  distanceFromStart: number | null;
  stationId: number;
  stationCode: string;
  stationName: string;
  latitude: number;
  longitude: number;
}

export interface Trip {
  tripId: number;
  routeId: number;
  routeCode: string;
  routeName: string;
  vehicleId: number;
  vehicleCode: string;
  tripCode: string;
  departureTime: string;
  arrivalTime: string;
  status: string;
}

/* ---------- Attractions ---------- */
export interface Attraction {
  attractionId: number;
  name: string;
  description: string | null;
  history: string | null;
  highlights: string[];
  address: string | null;
  latitude: number;
  longitude: number;
  category: string | null;
  openingHours: string | null;
  ticketPrice: string | null;
  imageUrl: string | null;
  popularityScore: number;
  status: string;
  distanceMeters?: number;
  score?: number;
}

export interface AttractionDetail extends Attraction {
  nearbyStations: (Station & { walkingDistance: number; walkingDuration: number })[];
}

/* ---------- Routing ---------- */
export interface Place {
  name: string;
  latitude: number;
  longitude: number;
  stationId?: number;
}

export interface LocationInput {
  latitude?: number;
  longitude?: number;
  stationId?: number;
  attractionId?: number;
  name?: string;
}

export interface RouteStep {
  mode: TransportMode;
  from: Place;
  to: Place;
  routeId?: number;
  routeCode?: string;
  routeName?: string;
  transportTypeId?: number;
  stops?: Place[];
  numStops?: number;
  duration: number;
  waitTime?: number;
  distance: number;
  fare: number;
  coveredByPass?: boolean;
  nextDepartures?: string[];
  path: [number, number][];
  instruction: string;
}

export interface RouteResult {
  id: string;
  preference: RoutePreference;
  labels: RoutePreference[];
  totalDuration: number;
  totalDistance: number;
  totalFare: number;
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
  origin: Place & { attractionId?: number };
  destination: Place & { attractionId?: number };
  preference: RoutePreference;
  departureTime: string;
  routes: RouteResult[];
  stats: { graphNodes: number; graphEdges: number; computeTimeMs: number };
}

/* ---------- Tickets / Orders ---------- */
export interface TicketType {
  ticketTypeId: number;
  name: string;
  transportTypeId: number;
  transportTypeName: string;
  mode: TransportMode;
  type: 'SINGLE' | 'MONTHLY';
  price: number;
  durationMinutes: number | null;
  description: string | null;
  status: string;
}

export type TicketStatus = 'ACTIVE' | 'USED' | 'EXPIRED' | 'CANCELLED';

export interface Ticket {
  ticketId: number;
  orderId: number;
  ticketCode: string;
  validFrom: string;
  validTo: string;
  status: TicketStatus;
  ticketTypeId: number;
  ticketTypeName: string;
  type: 'SINGLE' | 'MONTHLY';
  price: number;
  transportTypeId: number;
  transportTypeName: string;
  mode: TransportMode;
  userName?: string;
  userEmail?: string;
  qrPayload: string;
  isValidNow: boolean;
  remainingMinutes: number;
}

export interface OrderItem {
  orderDetailId: number;
  ticketTypeId: number;
  ticketTypeName: string;
  type: 'SINGLE' | 'MONTHLY';
  durationMinutes: number | null;
  transportTypeName: string;
  quantity: number;
  unitPrice: number;
  subtotal: number;
}

export interface Order {
  orderId: number;
  userId: number;
  userName: string;
  userEmail: string;
  totalAmount: number;
  status: 'PENDING' | 'PAID' | 'CANCELLED';
  createdAt: string;
  paymentStatus: string | null;
  ticketCount: number;
  itemsSummary?: string;
  items?: OrderItem[];
  payments?: { paymentId: number; amount: number; status: string; transactionCode: string | null; paidAt: string | null }[];
  tickets?: { ticketId: number; ticketCode: string; status: TicketStatus; validFrom: string; validTo: string }[];
}

export interface PaymentResult {
  paymentId: number;
  orderId: number;
  amount: number;
  status: 'SUCCESS' | 'FAILED';
  ticketIds: number[];
  order: Order;
}

export interface TripHistory {
  tripHistoryId: number;
  origin: string;
  destination: string;
  routeData: any;
  startedAt: string | null;
  completedAt: string | null;
}

/* ---------- Admin ---------- */
export interface Statistics {
  overview: Record<string, number>;
  revenueByDay: { date: string; revenue: number; payments: number }[];
  ticketsByType: { ticketTypeId: number; name: string; type: string; transportTypeName: string; ticketsSold: number; revenue: number }[];
  ticketsByStatus: { status: string; total: number }[];
  transportSummary: { transportTypeId: number; name: string; stations: number; routes: number; vehicles: number }[];
  topDestinations: { destination: string; total: number }[];
  recentOrders: { orderId: number; userName: string; totalAmount: number; status: string; createdAt: string }[];
}
