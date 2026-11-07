/**
 * Service: Chi duong theo DUONG PHO THAT bang OSRM (Open Source Routing Machine).
 *
 * May chu (theo thu tu uu tien, xem routing.config.ts):
 *   1. OSRM chay tren may bang Docker (osrm-setup.bat) - ban do duong Ha Noi
 *        :5001 di bo   :5002 xe dap / xe dien   :5003 o to (xe buyt)
 *   2. May chu cong cong https://routing.openstreetmap.de (du phong, co gioi han tan suat)
 *
 * 2 viec:
 *  1. walkingMatrix(): quang duong di bo thuc te tu diem di / diem den toi cac tram
 *     ung vien -> dua vao Dijkstra (tieu chi "It di bo", "Nhanh nhat" chinh xac hon).
 *  2. enrichRoute(): ve lai tung buoc theo duong pho, cap nhat quang duong / thoi gian
 *     di bo, xe dap, xe dien theo so lieu thuc te.
 *
 * Moi loi mang / timeout -> tra ve null, routing van chay voi uoc luong duong chim bay.
 */
import { ROUTING_CONFIG } from '../config/routing.config';
import { instructionFor } from '../algorithms/routing';
import { haversineMeters } from '../utils/geo';
import { RouteStep } from '../types/routing.types';
import { TransportMode } from '../types/transport.types';

type LatLng = [number, number]; // [lat, lng]
interface Pt {
  latitude: number;
  longitude: number;
}

const cfg = ROUTING_CONFIG.roadRouting;

/* ----------------------------- cache don gian ----------------------------- */
const CACHE_MAX = 3000;
const cache = new Map<string, any>();
function cacheGet(key: string) {
  if (!cache.has(key)) return undefined;
  const v = cache.get(key);
  cache.delete(key); // LRU: dua len cuoi
  cache.set(key, v);
  return v;
}
function cacheSet(key: string, value: any) {
  cache.set(key, value);
  if (cache.size > CACHE_MAX) cache.delete(cache.keys().next().value as string);
}

/* --------- gioi han so request dong thoi (lich su voi may chu cong cong) --------- */
const MAX_CONCURRENT = 6;
let active = 0;
const queue: (() => void)[] = [];
async function withSlot<T>(fn: () => Promise<T>): Promise<T> {
  if (active >= MAX_CONCURRENT) await new Promise<void>((resolve) => queue.push(resolve));
  active++;
  try {
    return await fn();
  } finally {
    active--;
    queue.shift()?.();
  }
}

const coord = (p: Pt) => `${p.longitude.toFixed(6)},${p.latitude.toFixed(6)}`;

/** Request dang chay -> request trung URL dung chung 1 promise (vd. xe dap & xe dien chung doan di bo) */
const inFlight = new Map<string, Promise<any | null>>();
/** May chu dang loi -> thoi diem duoc thu lai */
const downUntil = new Map<string, number>();

const isLocal = (base: string) => /\/\/(localhost|127\.0\.0\.1)/.test(base);

/** null = loi mang / may chu (thu may chu khac); { noRoute } = may chu tra loi nhung khong co duong */
async function fetchJson(base: string, url: string): Promise<any | null> {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), isLocal(base) ? cfg.localTimeoutMs : cfg.publicTimeoutMs);
  const t0 = Date.now();
  try {
    const res = await fetch(url, { signal: ctrl.signal, headers: { 'User-Agent': 'HanoiGo-student-project/1.0' } });
    if (res.ok) {
      const json: any = await res.json();
      return json.code === 'Ok' ? json : { noRoute: json.code };
    }
    if (res.status === 400) return { noRoute: `HTTP 400` };
    console.warn(`[OSRM] ${base}: HTTP ${res.status} sau ${Date.now() - t0} ms`);
  } catch (err) {
    const e = err as any;
    console.warn(`[OSRM] ${base}: ${e?.cause?.code ?? e?.name ?? 'Error'} sau ${Date.now() - t0} ms`);
  } finally {
    clearTimeout(timer);
  }
  downUntil.set(base, Date.now() + cfg.downCooldownMs);
  return null;
}

async function osrm(service: 'route' | 'table', mode: TransportMode, points: Pt[], query: string): Promise<any | null> {
  if (!cfg.enabled) return null;
  const path = `/${service}/v1/driving/${points.map(coord).join(';')}?${query}`;
  const key = `${mode}${path}`;
  const hit = cacheGet(key);
  if (hit !== undefined) return hit;
  if (inFlight.has(key)) return inFlight.get(key)!;

  const p = withSlot(async () => {
    for (const base of cfg.servers[mode] ?? []) {
      if ((downUntil.get(base) ?? 0) > Date.now()) continue;
      const json = await fetchJson(base, base + path);
      if (json === null) continue; // may chu loi -> thu may chu tiep theo
      if (json.noRoute) return null;
      cacheSet(key, json);
      return json;
    }
    return null;
  });
  inFlight.set(key, p);
  try {
    return await p;
  } finally {
    inFlight.delete(key);
  }
}

const toLatLng = (c: [number, number]): LatLng => [c[1], c[0]];

/* ------------------------- 1. ma tran di bo ------------------------------- */

export interface WalkingMatrix {
  /** met: diem di -> tram */
  origin: Map<number, number>;
  /** met: tram -> diem den */
  destination: Map<number, number>;
  /** met: di bo thang diem di -> diem den */
  direct?: number;
}

/**
 * 1 request OSRM /table (profile di bo): 2 nguon (diem di, diem den) x tat ca tram ung vien.
 * Duong di bo coi nhu 2 chieu bang nhau. Cong them doan tu toa do toi mep duong gan nhat.
 */
export async function walkingMatrix(
  origin: Pt,
  destination: Pt,
  originStations: { stationId: number; latitude: number; longitude: number }[],
  destStations: { stationId: number; latitude: number; longitude: number }[],
): Promise<WalkingMatrix | null> {
  const points: Pt[] = [origin, destination, ...originStations, ...destStations];
  const json = await osrm('table', 'WALK', points, 'sources=0;1&annotations=distance');
  if (!json?.distances) return null;

  const snap: number[] = (json.destinations ?? []).map((d: any) => Number(d.distance) || 0);
  const srcSnap: number[] = (json.sources ?? []).map((d: any) => Number(d.distance) || 0);
  const dist = (row: number, col: number): number | undefined => {
    const v = json.distances[row]?.[col];
    return typeof v === 'number' ? Math.round(v + (srcSnap[row] ?? 0) + (snap[col] ?? 0)) : undefined;
  };

  const out: WalkingMatrix = { origin: new Map(), destination: new Map(), direct: dist(0, 1) };
  originStations.forEach((s, i) => {
    const d = dist(0, 2 + i);
    if (d !== undefined) out.origin.set(s.stationId, d);
  });
  destStations.forEach((s, i) => {
    const d = dist(1, 2 + originStations.length + i);
    if (d !== undefined) out.destination.set(s.stationId, d);
  });
  return out;
}

/* ---------------------- 2. ve lai tung buoc theo duong pho ------------------ */

/** Duong di 2 diem (di bo / xe dap / xe dien) */
async function pointToPoint(mode: TransportMode, from: Pt, to: Pt) {
  if (!cfg.servers[mode]) return null;
  const json = await osrm('route', mode, [from, to], 'overview=full&geometries=geojson');
  const r = json?.routes?.[0];
  if (!r) return null;
  const snap = (json.waypoints ?? []).reduce((sum: number, w: any) => sum + (Number(w.distance) || 0), 0);
  const path: LatLng[] = [
    [from.latitude, from.longitude],
    ...r.geometry.coordinates.map(toLatLng),
    [to.latitude, to.longitude],
  ];
  return { path, distance: Math.round(r.distance + snap) };
}

/**
 * Xe buyt: duong o to di qua lan luot cac tram cua buoc.
 * Doan nao bi "bat nham" sang lan duong nguoc chieu (vong rat xa) -> noi thang doan do.
 */
async function busPath(stops: Pt[]): Promise<LatLng[] | null> {
  if (stops.length < 2) return null;
  const json = await osrm('route', 'BUS', stops, 'overview=false&steps=true&geometries=geojson');
  const legs: any[] | undefined = json?.routes?.[0]?.legs;
  if (!legs || legs.length !== stops.length - 1) return null;

  const path: LatLng[] = [[stops[0].latitude, stops[0].longitude]];
  legs.forEach((leg, i) => {
    const a = stops[i];
    const b = stops[i + 1];
    const straight = haversineMeters(a.latitude, a.longitude, b.latitude, b.longitude);
    if (leg.distance > straight * cfg.maxLegDetourRatio + 400) {
      path.push([b.latitude, b.longitude]);
      return;
    }
    for (const st of leg.steps ?? []) for (const c of st.geometry?.coordinates ?? []) path.push(toLatLng(c));
    path.push([b.latitude, b.longitude]);
  });
  return path;
}

/**
 * Cap nhat 1 buoc: path theo duong pho; di bo / xe dap / xe dien con cap nhat
 * quang duong + thoi gian thuc te. Tra ve [buoc moi, co dung duong pho khong].
 */
async function enrichStep(step: RouteStep): Promise<[RouteStep, boolean]> {
  if (step.mode === 'METRO') return [step, true]; // tuyen tren cao: noi thang giua cac ga

  if (step.mode === 'BUS') {
    const stops = step.stops && step.stops.length >= 2 ? step.stops : [step.from, step.to];
    const path = await busPath(stops);
    return path ? [{ ...step, path }, true] : [step, false];
  }

  // WALK, BICYCLE, ELECTRIC_VEHICLE
  const r = await pointToPoint(step.mode, step.from, step.to);
  if (!r) return [step, false];
  const speed = ROUTING_CONFIG.speedMPerMin[step.mode];
  const next: RouteStep = {
    ...step,
    path: r.path,
    distance: r.distance,
    duration: Math.max(1, Math.round(r.distance / speed)),
  };
  next.instruction = instructionFor(next);
  return [next, true];
}

/** Ve lai ca lo trinh. roadGeometry=false neu co buoc nao phai dung duong thang do loi mang */
export async function enrichSteps(steps: RouteStep[]): Promise<{ steps: RouteStep[]; roadGeometry: boolean }> {
  const results = await Promise.all(steps.map(enrichStep));
  return { steps: results.map((r) => r[0]), roadGeometry: results.every((r) => r[1]) };
}
