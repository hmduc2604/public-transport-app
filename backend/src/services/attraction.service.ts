/**
 * Service: Diem tham quan + Goi y dia diem (de xuat cua Nguoi 1)
 *
 * Goi y theo cong thuc:   S = 0.5P + 0.3C + 0.2D
 *   P: PopularityScore (0-100)
 *   C: 100 neu dung loai dia diem nguoi dung quan tam, nguoc lai 0
 *   D: diem gan vi tri nguoi dung (0-100), 100 khi dung tai cho, 0 khi xa >= 5km
 * Khong co vi tri -> bo D; khong chon loai -> bo C (chia lai trong so).
 */
import { attractionRepository } from '../repositories/attraction.repository';
import { AppError } from '../utils/AppError';
import { haversineMeters } from '../utils/geo';
import { toTransportMode } from '../types/transport.types';

function splitHighlights(a: any) {
  return {
    ...a,
    highlights: a.highlights ? String(a.highlights).split('|').map((s: string) => s.trim()).filter(Boolean) : [],
  };
}

export const attractionService = {
  async list(opts: { category?: string; search?: string; sort?: string }) {
    return (await attractionRepository.list(opts)).map(splitHighlights);
  },

  async featured(limit = 8) {
    return (await attractionRepository.featured(limit)).map(splitHighlights);
  },

  categories: () => attractionRepository.categories(),

  async detail(id: number) {
    const a = await attractionRepository.getById(id);
    if (!a || a.status !== 'ACTIVE') throw AppError.notFound('Không tìm thấy địa điểm', 'ATTRACTION_NOT_FOUND');
    const stations = await attractionRepository.nearbyStations(id);
    return {
      ...splitHighlights(a),
      nearbyStations: stations.map((s: any) => ({ ...s, mode: toTransportMode(s.transportTypeName) })),
    };
  },

  async nearbyStations(id: number) {
    const a = await attractionRepository.getById(id);
    if (!a) throw AppError.notFound('Không tìm thấy địa điểm', 'ATTRACTION_NOT_FOUND');
    const stations = await attractionRepository.nearbyStations(id);
    return stations.map((s: any) => ({ ...s, mode: toTransportMode(s.transportTypeName) }));
  },

  async nearby(lat: number, lng: number, radiusKm = 2, limit = 10) {
    const rows = await attractionRepository.nearby(lat, lng, radiusKm, limit);
    return rows.map((r: any) => ({ ...splitHighlights(r), distanceMeters: Math.round(r.distanceKm * 1000) }));
  },

  async recommend(opts: { categories?: string[]; lat?: number; lng?: number; limit?: number }) {
    const all = await attractionRepository.list({});
    const cats = (opts.categories ?? []).map((c) => c.toLowerCase());
    const hasLoc = opts.lat !== undefined && opts.lng !== undefined;
    const hasCat = cats.length > 0;

    // Trong so goc 0.5 / 0.3 / 0.2, chuan hoa lai khi thieu tieu chi
    let wP = 0.5;
    let wC = hasCat ? 0.3 : 0;
    let wD = hasLoc ? 0.2 : 0;
    const sum = wP + wC + wD;
    wP /= sum;
    wC /= sum;
    wD /= sum;

    const scored = all.map((a: any) => {
      const P = Math.max(0, Math.min(100, a.popularityScore ?? 50));
      const C = hasCat && cats.includes(String(a.category ?? '').toLowerCase()) ? 100 : 0;
      let D = 0;
      let distanceMeters: number | undefined;
      if (hasLoc) {
        distanceMeters = Math.round(haversineMeters(opts.lat!, opts.lng!, a.latitude, a.longitude));
        D = Math.max(0, 100 - (distanceMeters / 5000) * 100);
      }
      const score = Math.round((wP * P + wC * C + wD * D) * 10) / 10;
      return { ...splitHighlights(a), score, scoreDetail: { P, C, D: Math.round(D), weights: { wP, wC, wD } }, distanceMeters };
    });

    scored.sort((x: any, y: any) => y.score - x.score);
    return scored.slice(0, opts.limit ?? 8);
  },
};
