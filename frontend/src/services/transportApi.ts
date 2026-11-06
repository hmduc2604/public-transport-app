import { api } from './api';
import { RouteStationItem, Station, StationDetail, TransitRoute, TransportType, Trip } from '../types';

export const transportApi = {
  transportTypes: () => api.get<TransportType[]>('/transport-types'),
  stations: (q?: { transportTypeId?: number; search?: string }) => api.get<Station[]>('/stations', q),
  station: (id: number) => api.get<StationDetail>(`/stations/${id}`),
  nearbyStations: (lat: number, lng: number, radius = 1) => api.get<Station[]>('/stations/nearby', { lat, lng, radius }),
  routes: (q?: { transportTypeId?: number; search?: string }) => api.get<TransitRoute[]>('/routes', q),
  route: (id: number) => api.get<TransitRoute & { stations: RouteStationItem[] }>(`/routes/${id}`),
  routeTrips: (id: number, upcoming = false) => api.get<Trip[]>(`/routes/${id}/trips`, { upcoming }),
};
