import { api } from './api';
import { LocationInput, RoutePreference, RoutingSearchResult } from '../types';

export const routeApi = {
  /** POST /routing/search - API quan trong nhat cua de tai */
  search: (origin: LocationInput, destination: LocationInput, preference: RoutePreference, departureTime?: string) =>
    api.post<RoutingSearchResult>('/routing/search', { origin, destination, preference, departureTime }),
};
