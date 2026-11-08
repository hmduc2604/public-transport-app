/**
 * Service: Routing (Nguoi 1 - Module C)
 *
 *   Controller -> RoutingService -> (cache) TransitNetwork -> planRoutes -> Dijkstra
 *
 * Graph duoc xay 1 lan tu DB va CACHE trong RAM.
 * Khi Admin them/sua/xoa tram, tuyen, gia ve... admin.service goi invalidate()
 * de lan tim duong tiep theo xay lai graph moi.
 */
import {
  accessCandidates,
  buildTransitNetwork,
  planRoutes,
  rankRoutes,
  summarize,
  TransitNetwork,
} from '../algorithms/routing';
import { ROUTING_CONFIG } from '../config/routing.config';
import { enrichSteps, walkingMatrix } from './roadGeometry.service';
import { transitNetworkRepository } from '../repositories/transitNetwork.repository';
import { stationRepository } from '../repositories/station.repository';
import { attractionRepository } from '../repositories/attraction.repository';
import { ticketRepository } from '../repositories/ticket.repository';
import { AppError } from '../utils/AppError';
import { isValidLatLng } from '../utils/geo';
import { currentHanoiTime, minutesToTime, timeToMinutes } from '../utils/time';
import {
  LocationInput,
  ResolvedLocation,
  RoutePreference,
  RoutingSearchResult,
  ROUTE_PREFERENCES,
} from '../types/routing.types';

const CACHE_TTL_MS = 10 * 60 * 1000; // tu lam moi sau 10 phut

let cached: TransitNetwork | null = null;
let building: Promise<TransitNetwork> | null = null;

async function getNetwork(): Promise<TransitNetwork> {
  if (cached && Date.now() - cached.builtAt.getTime() < CACHE_TTL_MS) return cached;
  if (!building) {
    building = transitNetworkRepository
      .load()
      .then((data) => {
        cached = buildTransitNetwork(data);
        console.log(
          `[Routing] Graph built: ${cached.graph.nodeCount} nodes, ${cached.graph.edgeCount} edges, ${cached.lines.size} lines`,
        );
        return cached;
      })
      .finally(() => {
        building = null;
      });
  }
  return building;
}

async function resolveLocation(input: LocationInput | undefined, label: string): Promise<ResolvedLocation> {
  if (!input || typeof input !== 'object') {
    throw AppError.badRequest(`Thiếu ${label}`, 'INVALID_LOCATION');
  }
  if (input.stationId) {
    const s = await stationRepository.getById(Number(input.stationId));
    if (!s) throw AppError.notFound(`Không tìm thấy trạm (${label})`, 'STATION_NOT_FOUND');
    return { name: input.name || s.stationName, latitude: s.latitude, longitude: s.longitude, stationId: s.stationId };
  }
  if (input.attractionId) {
    const a = await attractionRepository.getById(Number(input.attractionId));
    if (!a) throw AppError.notFound(`Không tìm thấy địa điểm (${label})`, 'ATTRACTION_NOT_FOUND');
    return { name: input.name || a.name, latitude: a.latitude, longitude: a.longitude, attractionId: a.attractionId };
  }
  const lat = Number(input.latitude);
  const lng = Number(input.longitude);
  if (!isValidLatLng(lat, lng)) {
    throw AppError.badRequest(`${label} cần latitude/longitude hợp lệ, hoặc stationId, hoặc attractionId`, 'INVALID_LOCATION');
  }
  const a = ROUTING_CONFIG.serviceArea;
  if (lat < a.minLat || lat > a.maxLat || lng < a.minLng || lng > a.maxLng) {
    throw AppError.badRequest(`${label[0].toUpperCase()}${label.slice(1)} nằm ngoài khu vực Hà Nội mà hệ thống hỗ trợ`, 'OUT_OF_SERVICE_AREA');
  }
  return { name: input.name || `${lat.toFixed(5)}, ${lng.toFixed(5)}`, latitude: lat, longitude: lng };
}

export const routingService = {
  invalidate() {
    cached = null;
  },

  async networkInfo() {
    const net = await getNetwork();
    return {
      builtAt: net.builtAt,
      stations: net.stations.size,
      lines: net.lines.size,
      nodes: net.graph.nodeCount,
      edges: net.graph.edgeCount,
    };
  },

  async search(
    body: { origin?: LocationInput; destination?: LocationInput; preference?: string; departureTime?: string },
    userId?: number,
  ): Promise<RoutingSearchResult> {
    const preference = String(body.preference || 'FASTEST').toUpperCase() as RoutePreference;
    if (!ROUTE_PREFERENCES.includes(preference)) {
      throw AppError.badRequest(`preference phải là: ${ROUTE_PREFERENCES.join(', ')}`, 'INVALID_PREFERENCE');
    }

    const [origin, destination] = await Promise.all([
      resolveLocation(body.origin, 'điểm đi'),
      resolveLocation(body.destination, 'điểm đến'),
    ]);

    if (body.departureTime && !/^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/.test(String(body.departureTime))) {
      throw AppError.badRequest('Giờ khởi hành phải có dạng HH:mm (00:00 - 23:59)', 'INVALID_TIME');
    }
    const departure = body.departureTime ? String(body.departureTime).slice(0, 5) : currentHanoiTime();
    const net = await getNetwork();
    const passTransportTypeIds = userId ? await ticketRepository.activePassTransportTypes(userId) : [];

    const t0 = Date.now();

    // B1. Quang duong di bo THUC TE (duong pho) toi cac tram ung vien -> dua vao Dijkstra
    const station = (id: number) => net.stations.get(id)!;
    const originCands = accessCandidates(net, origin).map((c) => station(c.stationId));
    const destCands = accessCandidates(net, destination).map((c) => station(c.stationId));
    const walk = await walkingMatrix(origin, destination, originCands, destCands);

    // B2. Dijkstra theo tieu chi + sinh phuong an thay the
    const coveredTypes = new Set(passTransportTypeIds);
    const plan = planRoutes(net, {
      origin,
      destination,
      preference,
      departureMinutes: timeToMinutes(departure),
      passTransportTypeIds,
      walkOverrides: walk ?? undefined,
    });

    // B3. Ve lai moi phuong an theo duong pho that, tinh lai tong thoi gian / di bo,
    //     roi XEP HANG LAI theo tieu chi nguoi dung chon -> lay Top N
    // (chi ve cac phuong an co kha nang duoc hien thi: Top N + 2 du phong -> it request hon)
    const shortlist = plan.candidates.slice(0, ROUTING_CONFIG.maxResults + 2);
    const enriched = await Promise.all(
      shortlist.map(async (r) => {
        const e = await enrichSteps(r.steps);
        return { route: summarize(e.steps, r.preference, coveredTypes), road: e.roadGeometry };
      }),
    );
    // Bo phuong an "chi di bo" qua xa (vd. 3 km) khi da co phuong an di xe
    const all = enriched.map((x) => x.route);
    const isLongWalk = (r: (typeof all)[number]) =>
      r.steps.every((st) => st.mode === 'WALK') && r.walkingDistance > ROUTING_CONFIG.maxDirectWalkM;
    const usable = all.some((r) => !isLongWalk(r)) ? all.filter((r) => !isLongWalk(r)) : all;
    const routes = rankRoutes(usable, preference, ROUTING_CONFIG.maxResults);
    const roadGeometry = Boolean(walk) && enriched.every((x) => x.road);
    const computeTimeMs = Date.now() - t0;

    if (routes.length === 0) {
      throw AppError.notFound('Không tìm thấy lộ trình phù hợp giữa hai điểm này', 'NO_ROUTE_FOUND');
    }

    return {
      origin,
      destination,
      preference,
      departureTime: minutesToTime(timeToMinutes(departure)),
      routes,
      stats: { graphNodes: net.graph.nodeCount, graphEdges: net.graph.edgeCount, computeTimeMs, roadGeometry },
    };
  },
};
