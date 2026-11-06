/**
 * ==========================================================================
 *  MULTI-MODAL ROUTE PLANNER
 * ==========================================================================
 * Pipeline (dung nhu tai lieu do an):
 *
 *   Origin + Destination
 *        │
 *        ▼
 *   Find nearest stations      -> accessCandidates()
 *        │
 *        ▼
 *   Build transport graph      -> buildTransitNetwork()  (cache o service)
 *        │
 *        ▼
 *   Apply user preference      -> makeWeight()
 *        │
 *        ▼
 *   Dijkstra                   -> dijkstra()
 *        │
 *        ▼
 *   Generate candidates        -> chay 4 tieu chi + phuong an thay the
 *        │
 *        ▼
 *   Rank routes / Top 3        -> planRoutes()
 *
 * File nay la THUAN THUAT TOAN: khong goi database, khong phu thuoc Express
 * -> test doc lap duoc (xem tests/routing.test.ts).
 * ==========================================================================
 */
import { Graph, GraphEdge, NodeId } from './graph';
import { dijkstra, PathEdge } from './dijkstra';
import { ROUTING_CONFIG, RoutingConfig } from '../config/routing.config';
import { haversineMeters } from '../utils/geo';
import { minutesToTime, timeToMinutes } from '../utils/time';
import {
  AttractionAccess,
  DepartureIndex,
  FareRule,
  RouteStop,
  Station,
  TransitRoute,
  TransportMode,
  toTransportMode,
} from '../types/transport.types';
import {
  Place,
  ResolvedLocation,
  RoutePreference,
  RouteResult,
  RouteStep,
  ROUTE_PREFERENCES,
} from '../types/routing.types';

/* ------------------------------------------------------------------------ */
/*  1. Du lieu dau vao va mang luoi da xay dung                              */
/* ------------------------------------------------------------------------ */

export interface TransitNetworkData {
  stations: Station[];
  routes: TransitRoute[];
  routeStops: RouteStop[];
  fareRules: FareRule[];
  attractionAccess: AttractionAccess[];
  departures: DepartureIndex;
}

/** 1 "line" = 1 tuyen trong bang Routes, hoac 1 he thong xe dap/xe dien dung chung */
export interface LineInfo {
  key: string;
  routeId?: number;
  routeCode: string;
  routeName: string;
  mode: TransportMode;
  transportTypeId: number;
  shared: boolean;
  /** stationId -> StopOrder (de biet chieu di) */
  stopOrder: Map<number, number>;
}

export interface TransitNetwork {
  graph: Graph;
  stations: Map<number, Station>;
  lines: Map<string, LineInfo>;
  fares: Map<string, number>;
  attractionAccess: Map<number, AttractionAccess[]>;
  departures: DepartureIndex;
  builtAt: Date;
}

const SHARED_MODES: TransportMode[] = ['BICYCLE', 'ELECTRIC_VEHICLE'];

const MODE_LABEL: Record<TransportMode, string> = {
  WALK: 'Đi bộ',
  BUS: 'Xe buýt',
  METRO: 'Metro',
  BICYCLE: 'Xe đạp công cộng',
  ELECTRIC_VEHICLE: 'Xe điện',
};

const round1 = (n: number) => Math.round(n * 10) / 10;

/* ------------------------------------------------------------------------ */
/*  2. BUILD GRAPH                                                           */
/* ------------------------------------------------------------------------ */

export function buildTransitNetwork(data: TransitNetworkData, cfg: RoutingConfig = ROUTING_CONFIG): TransitNetwork {
  const graph = new Graph();
  const stations = new Map<number, Station>();
  const lines = new Map<string, LineInfo>();

  for (const s of data.stations) {
    if (s.status !== 'ACTIVE') continue;
    const station: Station = { ...s, mode: s.mode ?? toTransportMode(s.transportTypeName) };
    stations.set(s.stationId, station);
    graph.addNode(NodeId.station(s.stationId));
  }

  const walkMeters = (a: Station, b: Station) =>
    haversineMeters(a.latitude, a.longitude, b.latitude, b.longitude) * cfg.walkDetourFactor;

  /** Them canh BOARD + ALIGHT cho 1 tram cua 1 line (chi them 1 lan) */
  const connectStop = (line: LineInfo, stationId: number, added: Set<string>) => {
    const key = `${line.key}:${stationId}`;
    if (added.has(key)) return;
    added.add(key);
    graph.addEdge(NodeId.station(stationId), {
      to: NodeId.onLine(line.key, stationId),
      kind: 'BOARD',
      mode: line.mode,
      duration: cfg.waitMinutes[line.mode],
      distance: 0,
      fare: cfg.defaultFare[line.mode],
      lineKey: line.key,
      fromStationId: stationId,
      toStationId: stationId,
    });
    graph.addEdge(NodeId.onLine(line.key, stationId), {
      to: NodeId.station(stationId),
      kind: 'ALIGHT',
      mode: line.mode,
      duration: 0,
      distance: 0,
      fare: 0,
      lineKey: line.key,
      fromStationId: stationId,
      toStationId: stationId,
    });
  };

  /** Them canh RIDE 2 chieu giua 2 tram lien ke cua 1 line */
  const connectRide = (line: LineInfo, a: Station, b: Station, distance: number, dwell: number) => {
    const duration = round1(distance / cfg.speedMPerMin[line.mode] + dwell);
    for (const [x, y] of [
      [a, b],
      [b, a],
    ] as const) {
      graph.addEdge(NodeId.onLine(line.key, x.stationId), {
        to: NodeId.onLine(line.key, y.stationId),
        kind: 'RIDE',
        mode: line.mode,
        duration,
        distance: Math.round(distance),
        fare: 0,
        lineKey: line.key,
        fromStationId: x.stationId,
        toStationId: y.stationId,
      });
    }
  };

  // 2.1 Cac tuyen co dinh (bang Routes + RouteStations)
  //     Gia dinh: moi tuyen chay ca 2 chieu.
  const stopsByRoute = new Map<number, RouteStop[]>();
  for (const rs of data.routeStops) {
    if (!stopsByRoute.has(rs.routeId)) stopsByRoute.set(rs.routeId, []);
    stopsByRoute.get(rs.routeId)!.push(rs);
  }
  const added = new Set<string>();

  for (const route of data.routes) {
    if (route.status !== 'ACTIVE') continue;
    const stops = (stopsByRoute.get(route.routeId) ?? [])
      .filter((s) => stations.has(s.stationId))
      .sort((a, b) => a.stopOrder - b.stopOrder);
    if (stops.length < 2) continue;

    const line: LineInfo = {
      key: String(route.routeId),
      routeId: route.routeId,
      routeCode: route.routeCode,
      routeName: route.routeName,
      mode: route.mode ?? toTransportMode(route.transportTypeName),
      transportTypeId: route.transportTypeId,
      shared: false,
      stopOrder: new Map(stops.map((s) => [s.stationId, s.stopOrder])),
    };
    lines.set(line.key, line);

    for (let i = 0; i < stops.length; i++) {
      connectStop(line, stops[i].stationId, added);
      if (i === 0) continue;
      const prev = stops[i - 1];
      const cur = stops[i];
      const a = stations.get(prev.stationId)!;
      const b = stations.get(cur.stationId)!;
      let distance =
        prev.distanceFromStart !== null && cur.distanceFromStart !== null
          ? cur.distanceFromStart - prev.distanceFromStart
          : 0;
      if (!(distance > 0)) {
        distance = haversineMeters(a.latitude, a.longitude, b.latitude, b.longitude) * cfg.rideDetourFactor;
      }
      connectRide(line, a, b, distance, cfg.dwellMinutesPerStop);
    }
  }

  // 2.2 Xe dap / xe dien dung chung: lay xe tram nay, tra o tram cung loai bat ky
  for (const mode of SHARED_MODES) {
    const group = [...stations.values()].filter((s) => s.mode === mode);
    if (group.length < 2) continue;
    const line: LineInfo = {
      key: `SHARE-${mode}`,
      routeCode: mode === 'BICYCLE' ? 'BIKE-SHARE' : 'EV-SHARE',
      routeName: mode === 'BICYCLE' ? 'Xe đạp công cộng (trả tại trạm bất kỳ)' : 'Xe điện công cộng (trả tại trạm bất kỳ)',
      mode,
      transportTypeId: group[0].transportTypeId,
      shared: true,
      stopOrder: new Map(),
    };
    lines.set(line.key, line);
    group.forEach((s) => connectStop(line, s.stationId, added));
    for (let i = 0; i < group.length; i++) {
      for (let j = i + 1; j < group.length; j++) {
        const d = haversineMeters(group[i].latitude, group[i].longitude, group[j].latitude, group[j].longitude);
        if (d <= cfg.sharedMobilityMaxM) connectRide(line, group[i], group[j], d * cfg.rideDetourFactor, 0);
      }
    }
  }

  // 2.3 Canh di bo chuyen tram (2 tram gan nhau)
  const list = [...stations.values()];
  for (let i = 0; i < list.length; i++) {
    for (let j = i + 1; j < list.length; j++) {
      const d = walkMeters(list[i], list[j]);
      if (d > cfg.transferRadiusM) continue;
      const duration = round1(d / cfg.speedMPerMin.WALK);
      for (const [x, y] of [
        [list[i], list[j]],
        [list[j], list[i]],
      ] as const) {
        graph.addEdge(NodeId.station(x.stationId), {
          to: NodeId.station(y.stationId),
          kind: 'WALK',
          mode: 'WALK',
          duration,
          distance: Math.round(d),
          fare: 0,
          fromStationId: x.stationId,
          toStationId: y.stationId,
        });
      }
    }
  }

  // 2.4 Bang gia + du lieu diem tham quan
  const fares = new Map<string, number>();
  for (const f of data.fareRules) fares.set(`${f.transportTypeId}:${f.fromStationId}:${f.toStationId}`, f.price);

  const attractionAccess = new Map<number, AttractionAccess[]>();
  for (const a of data.attractionAccess) {
    if (!attractionAccess.has(a.attractionId)) attractionAccess.set(a.attractionId, []);
    attractionAccess.get(a.attractionId)!.push(a);
  }

  return { graph, stations, lines, fares, attractionAccess, departures: data.departures, builtAt: new Date() };
}

/* ------------------------------------------------------------------------ */
/*  3. FIND NEAREST STATIONS (diem di / den -> cac tram ung vien)            */
/* ------------------------------------------------------------------------ */

interface AccessCandidate {
  stationId: number;
  distance: number;
  duration: number;
}

export function accessCandidates(
  net: TransitNetwork,
  loc: ResolvedLocation,
  cfg: RoutingConfig = ROUTING_CONFIG,
): AccessCandidate[] {
  const byStation = new Map<number, AccessCandidate>();

  const all = [...net.stations.values()]
    .map((s) => {
      const distance = haversineMeters(loc.latitude, loc.longitude, s.latitude, s.longitude) * cfg.walkDetourFactor;
      return { stationId: s.stationId, distance, duration: distance / cfg.speedMPerMin.WALK };
    })
    .sort((a, b) => a.distance - b.distance);

  all.forEach((c, idx) => {
    if (idx < cfg.minAccessStations || (c.distance <= cfg.accessRadiusM && idx < cfg.maxAccessStations)) {
      byStation.set(c.stationId, c);
    }
  });

  // Diem tham quan: uu tien du lieu AttractionStations (khoang cach di bo thuc te)
  if (loc.attractionId) {
    for (const a of net.attractionAccess.get(loc.attractionId) ?? []) {
      if (!net.stations.has(a.stationId)) continue;
      const distance = a.walkingDistance ?? byStation.get(a.stationId)?.distance ?? 0;
      byStation.set(a.stationId, {
        stationId: a.stationId,
        distance,
        duration: a.walkingDuration ?? distance / cfg.speedMPerMin.WALK,
      });
    }
  }

  // Nguoi dung chon dung 1 tram
  if (loc.stationId && net.stations.has(loc.stationId)) {
    byStation.set(loc.stationId, { stationId: loc.stationId, distance: 0, duration: 0 });
  }

  return [...byStation.values()];
}

/* ------------------------------------------------------------------------ */
/*  4. APPLY USER PREFERENCE (ham trong so cho Dijkstra)                     */
/* ------------------------------------------------------------------------ */

interface WeightOptions {
  coveredTypes: Set<number>;
  penalizedLines?: Set<string>;
}

export function makeWeight(
  pref: RoutePreference,
  net: TransitNetwork,
  opts: WeightOptions,
  cfg: RoutingConfig = ROUTING_CONFIG,
) {
  return (e: GraphEdge): number => {
    const line = e.lineKey ? net.lines.get(e.lineKey) : undefined;
    const fare = e.kind === 'BOARD' && line && !opts.coveredTypes.has(line.transportTypeId) ? e.fare : 0;
    const walk = e.kind === 'WALK' ? e.distance : 0;
    const isBoard = e.kind === 'BOARD';

    let w: number;
    switch (pref) {
      case 'CHEAPEST':
        // 1 phut = 30d, 1m di bo = 5d (de khong bat nguoi dung di bo qua xa chi de tiet kiem)
        w = fare + e.duration * 30 + walk * 5;
        break;
      case 'LEAST_WALKING':
        // 1 phut = 3m di bo
        w = walk + e.duration * 3 + (isBoard ? 1 : 0);
        break;
      case 'FEWEST_TRANSFERS':
        w = e.duration + (isBoard ? cfg.transferPenaltyMinutes : 0);
        break;
      case 'FASTEST':
      default:
        w = e.duration + (isBoard ? 0.5 : 0);
    }

    // Dung khi sinh phuong an thay the: "ne" cac tuyen da dung o phuong an truoc
    if (isBoard && opts.penalizedLines?.has(e.lineKey!)) {
      w += pref === 'CHEAPEST' ? 20000 : pref === 'LEAST_WALKING' ? 2000 : 25;
    }
    return w;
  };
}

/* ------------------------------------------------------------------------ */
/*  5. PATH -> STEPS  (gop cac canh lien tiep thanh cac buoc de hien thi)    */
/* ------------------------------------------------------------------------ */

function formatDistance(m: number): string {
  return m < 1000 ? `${Math.round(m)} m` : `${(m / 1000).toFixed(1).replace('.', ',')} km`;
}

function lookupFare(net: TransitNetwork, line: LineInfo, fromId: number, toId: number, cfg: RoutingConfig): number {
  return (
    net.fares.get(`${line.transportTypeId}:${fromId}:${toId}`) ??
    net.fares.get(`${line.transportTypeId}:${toId}:${fromId}`) ??
    cfg.defaultFare[line.mode]
  );
}

interface StepDraft extends RouteStep {
  boardStationId?: number;
  elapsedAtBoard?: number;
  lineKey?: string;
}

export function pathToSteps(
  edges: PathEdge[],
  net: TransitNetwork,
  origin: ResolvedLocation,
  destination: ResolvedLocation,
  departureMinutes: number,
  coveredTypes: Set<number>,
  cfg: RoutingConfig = ROUTING_CONFIG,
): RouteStep[] {
  const placeOf = (node: string): Place => {
    if (node === NodeId.ORIGIN) {
      return { name: origin.name, latitude: origin.latitude, longitude: origin.longitude, stationId: origin.stationId };
    }
    if (node === NodeId.DEST) {
      return {
        name: destination.name,
        latitude: destination.latitude,
        longitude: destination.longitude,
        stationId: destination.stationId,
      };
    }
    const s = net.stations.get(NodeId.stationOf(node)!)!;
    return { name: s.stationName, latitude: s.latitude, longitude: s.longitude, stationId: s.stationId };
  };

  const steps: StepDraft[] = [];
  let cur: StepDraft | null = null;
  let elapsed = 0;

  const close = () => {
    if (cur) steps.push(cur);
    cur = null;
  };

  for (const { from, edge } of edges) {
    switch (edge.kind) {
      case 'WALK': {
        const to = placeOf(edge.to);
        if (cur && cur.mode === 'WALK') {
          cur.to = to;
          cur.distance += edge.distance;
          cur.duration += edge.duration;
          cur.path.push([to.latitude, to.longitude]);
        } else {
          close();
          const fromPlace = placeOf(from);
          cur = {
            mode: 'WALK',
            from: fromPlace,
            to,
            duration: edge.duration,
            distance: edge.distance,
            fare: 0,
            path: [
              [fromPlace.latitude, fromPlace.longitude],
              [to.latitude, to.longitude],
            ],
            instruction: '',
          };
        }
        break;
      }
      case 'BOARD': {
        close();
        const line = net.lines.get(edge.lineKey!)!;
        const p = placeOf(from);
        cur = {
          mode: line.mode,
          from: p,
          to: p,
          routeId: line.routeId,
          routeCode: line.routeCode,
          routeName: line.routeName,
          transportTypeId: line.transportTypeId,
          stops: [p],
          duration: 0,
          waitTime: edge.duration,
          distance: 0,
          fare: 0,
          path: [[p.latitude, p.longitude]],
          instruction: '',
          boardStationId: edge.fromStationId,
          elapsedAtBoard: elapsed,
          lineKey: line.key,
        };
        break;
      }
      case 'RIDE': {
        if (!cur) break;
        const to = placeOf(edge.to);
        cur.to = to;
        cur.distance += edge.distance;
        cur.duration += edge.duration;
        cur.stops!.push(to);
        cur.path.push([to.latitude, to.longitude]);
        break;
      }
      case 'ALIGHT': {
        if (!cur) break;
        const line = net.lines.get(cur.lineKey!)!;
        const alightId = edge.toStationId!;
        cur.fare = lookupFare(net, line, cur.boardStationId!, alightId, cfg);
        cur.coveredByPass = coveredTypes.has(line.transportTypeId);
        cur.numStops = cur.stops!.length - 1;

        // Gio xe sap toi (chi tuyen co dinh, di dung chieu cua lich trinh)
        if (!line.shared && line.routeId) {
          const o1 = line.stopOrder.get(cur.boardStationId!) ?? 0;
          const o2 = line.stopOrder.get(alightId) ?? 0;
          if (o2 > o1) {
            const clock = departureMinutes + (cur.elapsedAtBoard ?? 0);
            const list = net.departures[`${line.routeId}:${cur.boardStationId}`] ?? [];
            cur.nextDepartures = list.filter((t) => timeToMinutes(t) >= clock).slice(0, 3);
          }
        }
        close();
        break;
      }
    }
    elapsed += edge.duration;
  }
  close();

  // Lam tron + bo buoc di bo ~0m (vd: diem di trung voi tram) + viet huong dan
  return steps
    .filter((s) => !(s.mode === 'WALK' && s.distance < 5))
    .map((s) => {
      const step: RouteStep = {
        mode: s.mode,
        from: s.from,
        to: s.to,
        routeId: s.routeId,
        routeCode: s.routeCode,
        routeName: s.routeName,
        transportTypeId: s.transportTypeId,
        stops: s.stops,
        numStops: s.numStops,
        duration: Math.max(1, Math.round(s.duration)),
        waitTime: s.waitTime !== undefined ? Math.round(s.waitTime) : undefined,
        distance: Math.round(s.distance),
        fare: Math.round(s.fare),
        coveredByPass: s.coveredByPass,
        nextDepartures: s.nextDepartures,
        path: s.path,
        instruction: '',
      };
      if (step.mode === 'WALK') {
        step.instruction = `Đi bộ ${formatDistance(step.distance)} đến ${step.to.name}`;
      } else if (step.mode === 'BICYCLE' || step.mode === 'ELECTRIC_VEHICLE') {
        step.instruction = `${MODE_LABEL[step.mode]}: lấy xe tại ${step.from.name}, trả xe tại ${step.to.name} (${formatDistance(step.distance)})`;
      } else {
        step.instruction = `Đi ${MODE_LABEL[step.mode]} ${step.routeCode} từ ${step.from.name} đến ${step.to.name} (${step.numStops} trạm)`;
      }
      return step;
    });
}

/* ------------------------------------------------------------------------ */
/*  6. PLAN ROUTES  (chay nhieu tieu chi -> loai trung -> xep hang -> Top N) */
/* ------------------------------------------------------------------------ */

export interface PlanQuery {
  origin: ResolvedLocation;
  destination: ResolvedLocation;
  preference: RoutePreference;
  /** gio xuat phat, tinh bang phut tu 00:00 */
  departureMinutes: number;
  /** TransportTypeId ma nguoi dung dang co ve thang con han */
  passTransportTypeIds?: number[];
}

export interface PlanOutput {
  routes: RouteResult[];
  visitedNodes: number;
}

function signatureOf(steps: RouteStep[]): string {
  return steps
    .map((s) => (s.mode === 'WALK' ? 'W' : `${s.routeCode}:${s.from.stationId}>${s.to.stationId}`))
    .join('|');
}

function hashId(s: string): string {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (Math.imul(31, h) + s.charCodeAt(i)) | 0;
  return 'R' + (h >>> 0).toString(36).toUpperCase();
}

function summarize(steps: RouteStep[], pref: RoutePreference, coveredTypes: Set<number>): RouteResult {
  const ride = steps.filter((s) => s.mode !== 'WALK');
  const walk = steps.filter((s) => s.mode === 'WALK');
  const totalFare = ride.reduce((sum, s) => sum + s.fare, 0);
  const fareToPay = ride.reduce(
    (sum, s) => sum + (s.transportTypeId && coveredTypes.has(s.transportTypeId) ? 0 : s.fare),
    0,
  );
  const waitingTime = ride.reduce((sum, s) => sum + (s.waitTime ?? 0), 0);
  const totalDuration = steps.reduce((sum, s) => sum + s.duration + (s.waitTime ?? 0), 0);
  const signature = signatureOf(steps);

  return {
    id: hashId(signature),
    preference: pref,
    labels: [],
    totalDuration,
    totalDistance: steps.reduce((sum, s) => sum + s.distance, 0),
    totalFare,
    fareToPay,
    walkingDistance: walk.reduce((sum, s) => sum + s.distance, 0),
    walkingDuration: walk.reduce((sum, s) => sum + s.duration, 0),
    waitingTime,
    transfers: Math.max(0, ride.length - 1),
    modes: [...new Set(steps.map((s) => s.mode))],
    steps,
    summary: steps.map((s) => (s.mode === 'WALK' ? 'Đi bộ' : s.routeCode)).join(' → '),
  };
}

export function planRoutes(net: TransitNetwork, query: PlanQuery, cfg: RoutingConfig = ROUTING_CONFIG): PlanOutput {
  const { origin, destination } = query;
  const coveredTypes = new Set(query.passTransportTypeIds ?? []);

  // 6.1 Canh tam thoi cho truy van nay (khong lam ban graph dung chung)
  const extra = new Map<string, GraphEdge[]>();
  const addExtra = (from: string, e: GraphEdge) => {
    if (!extra.has(from)) extra.set(from, []);
    extra.get(from)!.push(e);
  };

  for (const c of accessCandidates(net, origin, cfg)) {
    addExtra(NodeId.ORIGIN, {
      to: NodeId.station(c.stationId),
      kind: 'WALK',
      mode: 'WALK',
      duration: round1(c.duration),
      distance: Math.round(c.distance),
      fare: 0,
      toStationId: c.stationId,
    });
  }
  for (const c of accessCandidates(net, destination, cfg)) {
    addExtra(NodeId.station(c.stationId), {
      to: NodeId.DEST,
      kind: 'WALK',
      mode: 'WALK',
      duration: round1(c.duration),
      distance: Math.round(c.distance),
      fare: 0,
      fromStationId: c.stationId,
    });
  }
  const direct =
    haversineMeters(origin.latitude, origin.longitude, destination.latitude, destination.longitude) *
    cfg.walkDetourFactor;
  if (direct <= cfg.maxDirectWalkM) {
    addExtra(NodeId.ORIGIN, {
      to: NodeId.DEST,
      kind: 'WALK',
      mode: 'WALK',
      duration: round1(direct / cfg.speedMPerMin.WALK),
      distance: Math.round(direct),
      fare: 0,
    });
  }

  const neighbors = (node: string): GraphEdge[] => {
    const base = net.graph.neighbors(node);
    const more = extra.get(node);
    return more ? base.concat(more) : base;
  };

  // 6.2 Sinh cac phuong an ung vien
  const results: RouteResult[] = [];
  const seen = new Set<string>();
  let visitedNodes = 0;

  const run = (pref: RoutePreference, penalizedLines?: Set<string>) => {
    const found = dijkstra(
      NodeId.ORIGIN,
      NodeId.DEST,
      neighbors,
      makeWeight(pref, net, { coveredTypes, penalizedLines }, cfg),
    );
    if (!found) return;
    visitedNodes += found.visited;
    const steps = pathToSteps(found.edges, net, origin, destination, query.departureMinutes, coveredTypes, cfg);
    if (steps.length === 0) return;
    const sig = signatureOf(steps);
    if (seen.has(sig)) return;
    seen.add(sig);
    results.push(summarize(steps, pref, coveredTypes));
  };

  // Tieu chi nguoi dung chon chay truoc -> luon la phuong an dau tien
  run(query.preference);
  for (const p of ROUTE_PREFERENCES) if (p !== query.preference) run(p);

  // Chua du Top N -> tim phuong an thay the bang cach "ne" tuyen da dung
  for (let i = 0; i < results.length && results.length < cfg.maxResults + 2; i++) {
    const lineKeys = new Set(
      results[i].steps
        .filter((s) => s.mode !== 'WALK')
        .map((s) => (s.routeId ? String(s.routeId) : `SHARE-${s.mode}`)),
    );
    if (lineKeys.size === 0) continue;
    run(query.preference, lineKeys);
  }

  // 6.3 Xep hang: giu phuong an theo tieu chi nguoi dung o dau, phan con lai
  //     sap theo diem tong hop (thoi gian + quy doi tien + di bo + chuyen tuyen)
  const [first, ...rest] = results;
  const score = (r: RouteResult) =>
    r.totalDuration + r.fareToPay / 1000 + r.walkingDistance / 100 + r.transfers * 5;
  rest.sort((a, b) => score(a) - score(b));
  const top = first ? [first, ...rest].slice(0, cfg.maxResults) : [];

  // 6.4 Gan nhan "Nhanh nhat / Re nhat / It di bo / It chuyen tuyen"
  const metric: Record<RoutePreference, (r: RouteResult) => number> = {
    FASTEST: (r) => r.totalDuration,
    CHEAPEST: (r) => r.fareToPay,
    LEAST_WALKING: (r) => r.walkingDistance,
    FEWEST_TRANSFERS: (r) => r.transfers,
  };
  for (const p of ROUTE_PREFERENCES) {
    if (top.length === 0) break;
    const best = Math.min(...top.map(metric[p]));
    const winner = top.find((r) => metric[p](r) === best);
    winner?.labels.push(p);
  }

  return { routes: top, visitedNodes };
}

export function describeDeparture(minutes: number): string {
  return minutesToTime(minutes);
}
