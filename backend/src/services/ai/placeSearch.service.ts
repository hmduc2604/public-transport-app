/**
 * Tim dia diem theo ten cho Tro ly AI: "Hồ Gươm", "Lăng Bác", "ga Cát Linh", "Đại học Bách khoa"...
 *   1. 20 dia diem tham quan (kem ten goi quen thuoc) + 571 tram trong database - so khop khong dau
 *   2. Khong thay -> tra dia chi bang OpenStreetMap Nominatim (gioi han trong vung Ha Noi he thong ho tro)
 * Moi ket qua co "ref" de truyen cho cong cu tim duong:  attraction:ID | station:ID | geo:lat,lng
 */
import { env } from '../../config/env';
import { ROUTING_CONFIG } from '../../config/routing.config';
import { attractionRepository } from '../../repositories/attraction.repository';
import { stationRepository } from '../../repositories/station.repository';
import { toTransportMode } from '../../types/transport.types';

export interface PlaceCandidate {
  ref: string;
  name: string;
  kind: 'ATTRACTION' | 'STATION' | 'ADDRESS';
  detail: string;
  latitude: number;
  longitude: number;
  score: number;
}

export const fold = (s: string) =>
  s
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd')
    .replace(/[^a-z0-9 ]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

/** Ten goi quen thuoc -> ten dia diem trong database */
const ALIASES: Record<string, string> = {
  'ho guom': 'Hồ Hoàn Kiếm',
  'bo ho': 'Hồ Hoàn Kiếm',
  'thap rua': 'Hồ Hoàn Kiếm',
  'lang bac': 'Lăng Chủ tịch Hồ Chí Minh',
  'lang chu tich': 'Lăng Chủ tịch Hồ Chí Minh',
  'pho bia': 'Phố Tạ Hiện',
  'pho tay': 'Phố Tạ Hiện',
  'nga tu quoc te': 'Phố Tạ Hiện',
  'mua roi nuoc': 'Nhà hát Múa rối Thăng Long',
  'mua roi': 'Nhà hát Múa rối Thăng Long',
  'quoc tu giam': 'Văn Miếu - Quốc Tử Giám',
  'hoang thanh': 'Hoàng thành Thăng Long',
  'hoa lo': 'Nhà tù Hỏa Lò',
  'nha tu': 'Nhà tù Hỏa Lò',
  'ba dinh': 'Quảng trường Ba Đình',
  'pho co': 'Phố cổ Hà Nội',
  '36 pho phuong': 'Phố cổ Hà Nội',
  'dong xuan': 'Chợ Đồng Xuân',
  'tran quoc': 'Chùa Trấn Quốc',
  'mot cot': 'Chùa Một Cột',
  'long bien': 'Cầu Long Biên',
  'nha hat lon': 'Nhà hát Lớn Hà Nội',
  'dan toc hoc': 'Bảo tàng Dân tộc học Việt Nam',
  'my thuat': 'Bảo tàng Mỹ thuật Việt Nam',
  'bao tang lich su': 'Bảo tàng Lịch sử Quốc gia',
  'pho sach': 'Phố sách Hà Nội',
  'ngoc son': 'Đền Ngọc Sơn',
};

const STOP_WORDS = new Set(['tram', 'xe', 'buyt', 'bus', 'ga', 'pho', 'duong', 'so', 'ha', 'noi', 'cua', 'o', 'tai', 'den', 'tu']);

function similarity(q: string, name: string): number {
  if (!q || !name) return 0;
  if (q === name) return 1;
  if (name.includes(q)) return 0.92 - Math.min(0.2, (name.length - q.length) / 200);
  if (q.includes(name) && name.length >= 4) return 0.85;
  const qt = q.split(' ').filter((t) => !STOP_WORDS.has(t));
  const nt = new Set(name.split(' '));
  if (qt.length === 0) return 0;
  const hit = qt.filter((t) => nt.has(t)).length;
  return (hit / qt.length) * 0.8;
}

/* -------- Cache danh sach dia diem + tram (10 phut) -------- */
let catalog: { at: number; attractions: any[]; stations: any[] } | null = null;
async function getCatalog() {
  if (catalog && Date.now() - catalog.at < 10 * 60 * 1000) return catalog;
  const [attractions, stations] = await Promise.all([attractionRepository.list({}), stationRepository.list({})]);
  catalog = { at: Date.now(), attractions, stations };
  return catalog;
}

/* -------- Nominatim (OpenStreetMap): toi da 1 request / giay, co cache -------- */
const geoCache = new Map<string, PlaceCandidate[]>();
let lastGeoAt = 0;

async function geocode(query: string): Promise<PlaceCandidate[]> {
  if (env.ai.geocoder === 'off') return [];
  const key = fold(query);
  const hit = geoCache.get(key);
  if (hit) return hit;
  const wait = lastGeoAt + 1100 - Date.now();
  if (wait > 0) await new Promise((r) => setTimeout(r, wait));
  lastGeoAt = Date.now();
  const a = ROUTING_CONFIG.serviceArea;
  const url =
    'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=4&countrycodes=vn&accept-language=vi&bounded=1' +
    `&viewbox=${a.minLng},${a.maxLat},${a.maxLng},${a.minLat}&q=${encodeURIComponent(query)}`;
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), 8000);
  try {
    const res = await fetch(url, { headers: { 'User-Agent': 'HanoiGo/1.0 (do an tot nghiep - tro ly lap lo trinh)' }, signal: ctrl.signal });
    if (!res.ok) return [];
    const rows = (await res.json()) as any[];
    const out: PlaceCandidate[] = rows.map((r) => {
      const parts = String(r.display_name ?? '').split(',').map((s: string) => s.trim());
      const lat = Number(r.lat);
      const lng = Number(r.lon);
      return {
        ref: `geo:${lat.toFixed(6)},${lng.toFixed(6)}`,
        name: r.name || parts[0] || query,
        kind: 'ADDRESS' as const,
        detail: parts.slice(1, 4).join(', '),
        latitude: lat,
        longitude: lng,
        score: 0.6,
      };
    });
    if (geoCache.size > 500) geoCache.clear();
    geoCache.set(key, out);
    return out;
  } catch {
    return [];
  } finally {
    clearTimeout(timer);
  }
}

const MODE_VI: Record<string, string> = { BUS: 'Trạm xe buýt', METRO: 'Ga Metro', BICYCLE: 'Trạm xe đạp công cộng', ELECTRIC_VEHICLE: 'Trạm xe điện công cộng' };

export const placeSearchService = {
  async find(query: string, limit = 5): Promise<PlaceCandidate[]> {
    const q = fold(query);
    if (!q) return [];
    const { attractions, stations } = await getCatalog();
    const out: PlaceCandidate[] = [];

    const aliasName = Object.entries(ALIASES).find(([k]) => q.includes(k))?.[1];
    for (const a of attractions) {
      let s = similarity(q, fold(a.name));
      if (aliasName && a.name === aliasName) s = Math.max(s, 0.95);
      if (s >= 0.45)
        out.push({
          ref: `attraction:${a.attractionId}`,
          name: a.name,
          kind: 'ATTRACTION',
          detail: `${a.category ?? 'Địa điểm'} · ${a.address ?? ''}`,
          latitude: a.latitude,
          longitude: a.longitude,
          score: Math.min(1, s + 0.05),
        });
    }
    for (const st of stations) {
      const s = similarity(q, fold(st.stationName));
      if (s >= 0.5)
        out.push({
          ref: `station:${st.stationId}`,
          name: st.stationName,
          kind: 'STATION',
          detail: MODE_VI[toTransportMode(st.transportTypeName)] ?? 'Trạm',
          latitude: st.latitude,
          longitude: st.longitude,
          score: s,
        });
    }
    out.sort((x, y) => y.score - x.score);
    // Khong co ket qua du tot trong database -> tra dia chi tren ban do
    if (out.length === 0 || out[0].score < 0.75) {
      const geo = await geocode(query);
      out.push(...geo);
      out.sort((x, y) => y.score - x.score);
    }
    return out.slice(0, limit);
  },

  /** Danh sach 20 dia diem (ref + ten) dua vao loi dan cho AI */
  async attractionCatalog(): Promise<{ ref: string; name: string; category: string | null }[]> {
    const { attractions } = await getCatalog();
    return attractions.map((a) => ({ ref: `attraction:${a.attractionId}`, name: a.name, category: a.category }));
  },
};
