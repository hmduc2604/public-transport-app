import { api } from './api';
import { Attraction, AttractionDetail } from '../types';

export const attractionApi = {
  list: (q?: { category?: string; search?: string; sort?: string }) => api.get<Attraction[]>('/attractions', q),
  featured: (limit = 8) => api.get<Attraction[]>('/attractions/featured', { limit }),
  categories: () => api.get<{ category: string; total: number }[]>('/attractions/categories'),
  recommend: (q: { categories?: string; lat?: number; lng?: number; limit?: number }) =>
    api.get<Attraction[]>('/attractions/recommend', q),
  detail: (id: number) => api.get<AttractionDetail>(`/attractions/${id}`),
};
