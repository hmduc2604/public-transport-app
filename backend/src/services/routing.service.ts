/**
 * Service: Routing (Nguoi 1 - Module C)
 *
 *   Controller -> RoutingService -> (cache) TransitNetwork -> planRoutes -> Dijkstra
 *
 * Graph duoc xay 1 lan tu DB va CACHE trong RAM.
 * Khi Admin them/sua/xoa tram, tuyen, gia ve... admin.service goi invalidate()
 * de lan tim duong tiep theo xay lai graph moi.
 */
import { buildTransitNetwork, planRoutes, TransitNetwork } from '../algorithms/routing';
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

    const departure = body.departureTime && /^\d{2}:\d{2}/.test(body.departureTime) ? body.departureTime.slice(0, 5) : currentHanoiTime();
    const net = await getNetwork();
    const passTransportTypeIds = userId ? await ticketRepository.activePassTransportTypes(userId) : [];

    const t0 = Date.now();
    const { routes } = planRoutes(net, {
      origin,
      destination,
      preference,
      departureMinutes: timeToMinutes(departure),
      passTransportTypeIds,
    });
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
      stats: { graphNodes: net.graph.nodeCount, graphEdges: net.graph.edgeCount, computeTimeMs },
    };
  },
};
