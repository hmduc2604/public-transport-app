/**
 * TRO LY AI LAP LO TRINH  -  POST /api/v1/assistant/chat
 *
 *   Nguoi dung (tieng Viet tu nhien)
 *        │  "Mình ở Hồ Gươm, muốn đi Văn Miếu rồi ra Hồ Tây, đi bộ ít thôi"
 *        ▼
 *   Gemini (function calling) ──goi cong cu──>  find_places / plan_route / suggest_places / get_place_info / get_ticket_prices
 *        ▲                                              │
 *        └──────────── ket qua THAT tu database + thuat toan Dijkstra cua nhom ┘
 *        ▼
 *   Cau tra loi + the lo trinh (mo tren ban do) + the dia diem
 *
 * AI chi lam 2 viec: HIEU cau hoi (tach diem di/den, tieu chi, gio) va DIEN GIAI ket qua.
 * Moi lo trinh, thoi gian, gia ve deu lay tu cong cu -> AI khong tu bia tuyen xe / gia ve.
 * Khong gui email, so dien thoai, ho ten nguoi dung cho Gemini.
 */
import { AppError } from '../../utils/AppError';
import { gemini, GeminiContent, GeminiFunctionCall, GeminiPart } from './gemini.client';
import { placeSearchService, PlaceCandidate } from './placeSearch.service';
import { routingService } from '../routing.service';
import { attractionService } from '../attraction.service';
import { ticketService } from '../ticket.service';
import { recommendationService } from '../recommendation.service';
import { stationRepository } from '../../repositories/station.repository';
import { ROUTING_CONFIG } from '../../config/routing.config';
import { LocationInput, RoutePreference, RouteResult } from '../../types/routing.types';
import { toTransportMode } from '../../types/transport.types';
import { sunTimes } from '../../utils/sun';
import { openingDay } from '../../utils/openingHours';
import { currentHanoiTime, minutesToTime, timeToMinutes } from '../../utils/time';
import { normalizeHabit, RIDE_MODES, TicketAdvice, ticketAdvisorService } from './ticketAdvisor.service';

/* ============================== Kieu du lieu ============================== */
export interface AssistantHistoryItem {
  role: 'user' | 'assistant';
  text: string;
  /** Lo trinh da tim o luot do (de AI hieu "con cach nao it di bo hon khong?") */
  routes?: { from: string; to: string; fromRef?: string; toRef?: string; preference?: string }[];
}

export interface AssistantRouteSet {
  id: number;
  fromRef: string;
  toRef: string;
  from: string;
  to: string;
  preference: RoutePreference;
  departureTime: string;
  routes: (Omit<RouteResult, 'steps'> & { steps: Omit<RouteResult['steps'][number], 'path' | 'stops'>[] })[];
}

export interface AssistantPlaceCard {
  attractionId: number;
  name: string;
  category: string | null;
  imageUrl: string | null;
  hoursSummary: string | null;
  priceFrom: string | null;
  reason?: string;
}

export interface AssistantReply {
  reply: string;
  routes: AssistantRouteSet[];
  places: AssistantPlaceCard[];
  /** Ket qua cong cu recommend_ticket (the tu van chon ve) */
  ticketAdvice: TicketAdvice | null;
  toolCalls: { name: string; ok: boolean }[];
  model: string | null;
  elapsedMs: number;
}

const PREF_LABEL: Record<RoutePreference, string> = {
  FASTEST: 'Nhanh nhất',
  CHEAPEST: 'Rẻ nhất',
  LEAST_WALKING: 'Ít đi bộ',
  FEWEST_TRANSFERS: 'Ít chuyển tuyến',
};
const PREFS = Object.keys(PREF_LABEL) as RoutePreference[];
const MODE_VI: Record<string, string> = { BUS: 'Xe buýt', METRO: 'Metro', BICYCLE: 'Xe đạp công cộng', ELECTRIC_VEHICLE: 'Xe điện công cộng' };
const MAX_ROUNDS = 6;
/** Sau ~40 giay ma AI van con goi cong cu -> bat buoc tra loi voi du lieu da co */
const SOFT_DEADLINE_MS = 40_000;

/* ============================== Khai bao cong cu ============================== */
const placeParam = (what: string) => ({
  type: 'string',
  description:
    `${what}: dùng ref "attraction:ID", "station:ID", "geo:VĨ_ĐỘ,KINH_ĐỘ", hoặc "me" (vị trí hiện tại của người dùng). ` +
    'Có thể ghi tên địa điểm, hệ thống sẽ tự tìm.',
});

const TOOLS = [
  {
    functionDeclarations: [
      {
        name: 'find_places',
        description:
          'Tìm địa điểm, trạm xe buýt / ga Metro / trạm xe đạp, xe điện, hoặc địa chỉ ở Hà Nội theo tên. Trả về danh sách kèm ref để dùng cho plan_route. ' +
          'Không cần gọi với các địa điểm tham quan đã có ref trong lời dặn.',
        parameters: {
          type: 'object',
          properties: { query: { type: 'string', description: 'Tên hoặc địa chỉ, ví dụ "ga Cát Linh", "Đại học Bách khoa Hà Nội", "số 1 Tràng Tiền"' } },
          required: ['query'],
        },
      },
      {
        name: 'plan_route',
        description:
          'Tìm lộ trình bằng phương tiện công cộng (xe buýt, Metro, xe đạp và xe điện công cộng, đi bộ) giữa 2 điểm ở Hà Nội bằng thuật toán của hệ thống. ' +
          'Trả về tối đa 3 phương án với thời gian, chi phí, quãng đi bộ, số lần chuyển tuyến và từng bước đi. Lịch trình từ 3 điểm trở lên thì dùng plan_itinerary.',
        parameters: {
          type: 'object',
          properties: {
            origin: placeParam('Điểm đi'),
            destination: placeParam('Điểm đến'),
            preference: {
              type: 'string',
              enum: PREFS,
              description: 'FASTEST = nhanh nhất (mặc định), CHEAPEST = rẻ nhất, LEAST_WALKING = ít đi bộ, FEWEST_TRANSFERS = ít chuyển tuyến',
            },
            departure_time: { type: 'string', description: 'Giờ khởi hành HH:mm (bỏ trống = bây giờ)' },
          },
          required: ['origin', 'destination'],
        },
      },
      {
        name: 'plan_itinerary',
        description:
          'Lập LỊCH TRÌNH nhiều điểm trong ngày (từ 3 điểm, hoặc khi người dùng muốn "lên lịch"): hệ thống tìm lộ trình từng chặng NỐI TIẾP nhau, ' +
          'tự tính giờ đến / giờ rời mỗi điểm (giờ rời = giờ đến + thời gian ở lại) và cảnh báo điểm có thể đã đóng cửa. Gọi 1 lần thay cho nhiều plan_route.',
        parameters: {
          type: 'object',
          properties: {
            stops: {
              type: 'array',
              items: { type: 'string' },
              description: 'Các điểm theo ĐÚNG thứ tự đi (ref hoặc tên), 2 - 6 điểm. Điểm đầu có thể là nơi xuất phát ("me", khách sạn...) hoặc điểm tham quan đầu tiên.',
            },
            start_time: { type: 'string', description: 'Giờ bắt đầu ở điểm đầu tiên, HH:mm. Bỏ trống = bây giờ.' },
            visit_first_stop: {
              type: 'boolean',
              description:
                'true nếu điểm đầu cũng là nơi tham quan (vd. "lịch trình: Văn Miếu → Hoàng thành → …"); false nếu đó chỉ là nơi xuất phát (vd. "mình ở Nhà hát Lớn, muốn đi…", "từ khách sạn", "me").',
            },
            visit_minutes: {
              type: 'array',
              items: { type: 'integer' },
              description:
                'Số phút ở lại MỖI điểm, cùng thứ tự với stops (điểm xuất phát không tham quan thì để 0). Bỏ trống = dùng thời gian tham quan gợi ý của từng địa điểm.',
            },
            preference: { type: 'string', enum: PREFS, description: 'Tiêu chí tìm đường cho mọi chặng (mặc định FASTEST)' },
          },
          required: ['stops', 'visit_first_stop'],
        },
      },
      {
        name: 'suggest_places',
        description:
          'Gợi ý địa điểm tham quan ở Hà Nội hợp với sở thích người dùng (kết hợp lịch sử các địa điểm họ đã quan tâm), có thể ưu tiên gần một điểm.',
        parameters: {
          type: 'object',
          properties: {
            interests: { type: 'string', description: 'Sở thích bằng lời của người dùng, ví dụ "lịch sử, kiến trúc Pháp, chụp ảnh"' },
            near: { type: 'string', description: 'Ưu tiên gần điểm này (ref hoặc "me"), có thể bỏ trống' },
            limit: { type: 'integer', description: 'Số gợi ý, 1 - 6 (mặc định 4)' },
          },
        },
      },
      {
        name: 'get_place_info',
        description:
          'Thông tin chi tiết một địa điểm tham quan (giờ mở cửa, giá vé, thời gian tham quan, thời điểm đẹp, điểm nổi bật, kinh nghiệm, trạm gần nhất) hoặc một trạm (các tuyến đi qua).',
        parameters: { type: 'object', properties: { place: placeParam('Địa điểm') }, required: ['place'] },
      },
      {
        name: 'get_ticket_prices',
        description: 'Bảng giá vé lượt và vé tháng đang bán trên HanoiGo theo loại phương tiện.',
        parameters: {
          type: 'object',
          properties: { mode: { type: 'string', enum: ['BUS', 'METRO', 'BICYCLE', 'ELECTRIC_VEHICLE'], description: 'Bỏ trống = tất cả' } },
        },
      },
      {
        name: 'recommend_ticket',
        description:
          'Tư vấn nên mua VÉ THÁNG hay VÉ LƯỢT (và tiết kiệm bao nhiêu mỗi tháng) theo thói quen đi lại của người dùng: số lượt mỗi tuần theo phương tiện, ' +
          'hoặc tuyến đi thường xuyên (hệ thống tự tìm lộ trình và giá từng chặng). Không truyền thói quen nào thì dùng vé lượt người dùng đã mua 30 ngày qua.',
        parameters: {
          type: 'object',
          properties: {
            trips: {
              type: 'array',
              description: 'Số lượt mỗi tuần theo phương tiện người dùng nêu (1 lượt = 1 lần lên xe/tàu; "mỗi ngày 2 lượt, 5 ngày/tuần" = 10). Không ghi lại chuyến đã mô tả bằng commute_*.',
              items: {
                type: 'object',
                properties: {
                  mode: { type: 'string', enum: RIDE_MODES },
                  per_week: { type: 'number', description: 'Số lượt mỗi tuần' },
                },
                required: ['mode', 'per_week'],
              },
            },
            commute_origin: placeParam('Nơi đi của tuyến đi thường xuyên (đi làm, đi học)'),
            commute_destination: placeParam('Nơi đến của tuyến đi thường xuyên'),
            commute_days_per_week: { type: 'number', description: 'Số ngày mỗi tuần đi tuyến đó (mặc định 5)' },
            commute_round_trip: { type: 'boolean', description: 'Đi và về trong ngày (mặc định true)' },
          },
        },
      },
    ],
  },
];

/* ============================== Thuc thi cong cu ============================== */
type Resolved = { input: LocationInput; ref: string; name: string; attractionId?: number; stationId?: number; latitude?: number; longitude?: number };

class ToolContext {
  routes: AssistantRouteSet[] = [];
  /** So thu tu the lo trinh - cap NGAY khi AI goi (cac chang chay song song nhung giu dung thu tu) */
  private routeSeq = 0;
  places = new Map<number, AssistantPlaceCard>();
  ticketAdvice: TicketAdvice | null = null;
  calls: { name: string; ok: boolean }[] = [];

  constructor(
    private userId: number,
    private location: { latitude: number; longitude: number } | null,
  ) {}

  async resolve(value: unknown, label: string): Promise<Resolved> {
    // Bo the HTML / ky tu thua ma model doi khi chen vao ("attraction:1<span>Hồ Hoàn Kiếm</span>")
    const v = String(value ?? '').replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();
    if (!v) throw new AppError(400, `Thiếu ${label}`);
    if (/^(me|vi tri hien tai|vị trí hiện tại|current)$/i.test(v)) {
      if (!this.location) throw new AppError(400, 'Người dùng chưa bật "Dùng vị trí của tôi" nên chưa biết vị trí hiện tại');
      const { latitude, longitude } = this.location;
      return { input: { latitude, longitude, name: 'Vị trí của bạn' }, ref: `geo:${latitude.toFixed(6)},${longitude.toFixed(6)}`, name: 'Vị trí của bạn', latitude, longitude };
    }
    let m = /^attraction:\s*(\d+)\b/i.exec(v);
    if (m) return { input: { attractionId: Number(m[1]) }, ref: `attraction:${m[1]}`, name: v, attractionId: Number(m[1]) };
    m = /^station:\s*(\d+)\b/i.exec(v);
    if (m) return { input: { stationId: Number(m[1]) }, ref: `station:${m[1]}`, name: v, stationId: Number(m[1]) };
    m = /^geo:\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)/i.exec(v);
    if (m) {
      const latitude = Number(m[1]);
      const longitude = Number(m[2]);
      return { input: { latitude, longitude, name: 'Điểm đã chọn' }, ref: `geo:${latitude},${longitude}`, name: 'Điểm đã chọn', latitude, longitude };
    }
    // Ten dia diem -> tu tim
    const [best] = await placeSearchService.find(v, 1);
    if (!best) throw new AppError(404, `Không tìm thấy "${v}" ở Hà Nội. Hãy hỏi người dùng địa chỉ cụ thể hơn.`);
    return this.fromCandidate(best);
  }

  fromCandidate(c: PlaceCandidate): Resolved {
    const [kind, id] = c.ref.split(':');
    if (kind === 'attraction') return { input: { attractionId: Number(id), name: c.name }, ref: c.ref, name: c.name, attractionId: Number(id) };
    if (kind === 'station') return { input: { stationId: Number(id), name: c.name }, ref: c.ref, name: c.name, stationId: Number(id) };
    return { input: { latitude: c.latitude, longitude: c.longitude, name: c.name }, ref: c.ref, name: c.name, latitude: c.latitude, longitude: c.longitude };
  }

  addPlace(a: any, reason?: string) {
    if (!a?.attractionId || this.places.has(a.attractionId)) return;
    this.places.set(a.attractionId, {
      attractionId: a.attractionId,
      name: a.name,
      category: a.category ?? null,
      imageUrl: a.imageUrl ?? null,
      hoursSummary: a.hoursSummary ?? null,
      priceFrom: a.priceFrom ?? null,
      reason,
    });
  }

  async run(call: GeminiFunctionCall): Promise<Record<string, unknown>> {
    const args = (call.args ?? {}) as Record<string, any>;
    try {
      let result: Record<string, unknown>;
      switch (call.name) {
        case 'find_places':
          result = await this.findPlaces(args);
          break;
        case 'plan_route':
          result = await this.planRoute(args);
          break;
        case 'plan_itinerary':
          result = await this.planItinerary(args);
          break;
        case 'suggest_places':
          result = await this.suggestPlaces(args);
          break;
        case 'get_place_info':
          result = await this.placeInfo(args);
          break;
        case 'get_ticket_prices':
          result = await this.ticketPrices(args);
          break;
        case 'recommend_ticket':
          result = await this.recommendTicket(args);
          break;
        default:
          throw new AppError(400, `Không có công cụ ${call.name}`);
      }
      this.calls.push({ name: call.name, ok: true });
      return result;
    } catch (e: any) {
      this.calls.push({ name: call.name, ok: false });
      if (!(e instanceof AppError)) console.error(`[AI] Tool ${call.name} failed:`, e);
      // Tra loi cho AI de no giai thich / hoi lai nguoi dung (khong lam hong ca cuoc tro chuyen)
      return { error: e instanceof AppError ? e.message : 'Lỗi hệ thống khi thực hiện công cụ', code: e?.errorCode ?? 'TOOL_ERROR' };
    }
  }

  private async findPlaces(args: Record<string, any>) {
    const found = await placeSearchService.find(String(args.query ?? '').slice(0, 200), 5);
    if (found.length === 0) return { results: [], note: 'Không tìm thấy, hãy hỏi người dùng địa chỉ cụ thể hơn' };
    return {
      results: found.map((c) => ({ ref: c.ref, name: c.name, type: c.kind, detail: c.detail })),
    };
  }

  /** Tim lo trinh 1 chang va luu "the lo trinh" (id cap san de cac the giu dung thu tu) */
  private async leg(id: number, o: Resolved, d: Resolved, preference: RoutePreference, departureTime?: string) {
    const result = await routingService.search({ origin: o.input, destination: d.input, preference, departureTime }, this.userId);
    if (d.attractionId) recommendationService.track(this.userId, d.attractionId, 'ROUTE');
    this.routes.push({
      id,
      fromRef: o.ref,
      toRef: d.ref,
      from: result.origin.name,
      to: result.destination.name,
      preference,
      departureTime: result.departureTime,
      routes: result.routes.map((r) => ({ ...r, steps: r.steps.map(({ path: _p, stops: _s, ...st }) => st) })),
    });
    return result;
  }

  private async planRoute(args: Record<string, any>) {
    const id = ++this.routeSeq;
    const [o, d] = await Promise.all([this.resolve(args.origin, 'điểm đi'), this.resolve(args.destination, 'điểm đến')]);
    const preference: RoutePreference = PREFS.includes(args.preference) ? args.preference : 'FASTEST';
    const departureTime = HHMM.test(String(args.departure_time ?? '')) ? String(args.departure_time) : undefined;
    const result = await this.leg(id, o, d, preference, departureTime);
    return {
      route_card: id,
      from: result.origin.name,
      to: result.destination.name,
      departure_time: result.departureTime,
      preference: PREF_LABEL[preference],
      options: result.routes.slice(0, 3).map((r, i) => ({
        option: i + 1,
        labels: r.labels.map((l) => PREF_LABEL[l]),
        total_minutes: r.totalDuration,
        arrive_at: addMinutes(result.departureTime, r.totalDuration),
        cost_vnd: r.totalFare,
        cost_to_pay_vnd: r.fareToPay,
        walking_m: r.walkingDistance,
        transfers: r.transfers,
        waiting_minutes: r.waitingTime,
        steps: r.steps.map(stepText),
      })),
    };
  }

  /** Lich trinh nhieu diem: cac chang tinh NOI TIEP (gio di chang sau = gio den + thoi gian o lai) */
  private async planItinerary(args: Record<string, any>) {
    const raw: unknown[] = Array.isArray(args.stops) ? args.stops.slice(0, 6) : [];
    if (raw.length < 2) throw new AppError(400, 'Lịch trình cần ít nhất 2 điểm');
    const preference: RoutePreference = PREFS.includes(args.preference) ? args.preference : 'FASTEST';
    const ids = raw.slice(1).map(() => ++this.routeSeq);
    const stops = await Promise.all(raw.map((v, i) => this.resolve(v, `điểm thứ ${i + 1}`)));
    const infos = await Promise.all(stops.map((s) => (s.attractionId ? attractionService.detail(s.attractionId).catch(() => null) : null)));
    const visits: unknown[] = Array.isArray(args.visit_minutes) ? args.visit_minutes : [];
    const start = HHMM.test(String(args.start_time ?? '')) ? String(args.start_time) : currentHanoiTime();

    let clock = timeToMinutes(start);
    let travel = 0;
    let cost = 0;
    const schedule: Record<string, unknown>[] = [];
    const legs: Record<string, unknown>[] = [];
    for (let i = 0; i < stops.length; i++) {
      const s = stops[i];
      const info: any = infos[i];
      if (info) this.addPlace(info);
      const given = Number(visits[i]);
      // Diem dau chi la noi xuat phat ("minh o Nha hat Lon...") -> khong tinh thoi gian tham quan
      const startOnly = i === 0 && (args.visit_first_stop === false || (args.visit_first_stop === undefined && !info));
      const stay = startOnly
        ? 0
        : visits[i] !== undefined && visits[i] !== null && Number.isFinite(given)
          ? Math.max(0, Math.min(600, Math.round(given)))
          : info ? visitMinutes(info.visitDuration) : 0;
      const arrive = clock;
      clock += stay;
      schedule.push({
        order: i + 1,
        stop: info?.name ?? s.name,
        ref: s.ref,
        [i === 0 ? 'start' : 'arrive']: minutesToTime(arrive),
        leave: minutesToTime(clock),
        stay_minutes: stay,
        ...(info ? { opening_hours: info.openingHours ?? info.hoursSummary ?? null, ticket: info.ticketPrice ?? null } : {}),
        ...(stay > 0 && info ? { warning: hoursWarning(info.hoursSummary, arrive, clock, info.openingHours) } : {}),
      });
      if (i === stops.length - 1) break;
      const next = stops[i + 1];
      let result;
      try {
        result = await this.leg(ids[i], s, next, preference, minutesToTime(clock));
      } catch (e: any) {
        throw new AppError(e?.statusCode ?? 404, `Chặng ${i + 1} (${info?.name ?? s.name} → ${infos[i + 1]?.name ?? next.name}): ${e?.message ?? 'không tìm được lộ trình'}`);
      }
      const best = result.routes[0];
      legs.push({
        route_card: ids[i],
        from: result.origin.name,
        to: result.destination.name,
        depart: minutesToTime(clock),
        arrive: minutesToTime(clock + best.totalDuration),
        minutes: best.totalDuration,
        cost_vnd: best.fareToPay,
        walking_m: best.walkingDistance,
        transfers: best.transfers,
        steps: best.steps.map(stepText),
        other_options: result.routes.slice(1, 3).map((r) => `${r.totalDuration} phút, ${r.fareToPay.toLocaleString('vi-VN')}đ, đi bộ ${r.walkingDistance} m`),
      });
      clock += best.totalDuration;
      travel += best.totalDuration;
      cost += best.fareToPay;
    }
    return {
      preference: PREF_LABEL[preference],
      schedule,
      legs,
      total: {
        start,
        end: minutesToTime(clock),
        travel_minutes: travel,
        cost_vnd: cost,
        ...(clock >= 1440 ? { warning: 'Lịch trình kéo dài qua nửa đêm' } : {}),
      },
    };
  }

  private async suggestPlaces(args: Record<string, any>) {
    let lat: number | undefined;
    let lng: number | undefined;
    if (args.near) {
      try {
        const n = await this.resolve(args.near, 'điểm gần');
        if (n.latitude !== undefined && n.longitude !== undefined) {
          lat = n.latitude;
          lng = n.longitude;
        } else if (n.attractionId) {
          const a = await attractionService.detail(n.attractionId);
          lat = a.latitude;
          lng = a.longitude;
        } else if (n.stationId) {
          const s = await stationRepository.getById(n.stationId);
          lat = s?.latitude;
          lng = s?.longitude;
        }
      } catch {
        /* khong xac dinh duoc diem gan -> bo qua tieu chi khoang cach */
      }
    }
    const r = await recommendationService.suggest({
      userId: this.userId,
      query: args.interests ? String(args.interests) : undefined,
      lat,
      lng,
      limit: Math.max(1, Math.min(6, Number(args.limit) || 4)),
      explain: false,
    });
    r.items.forEach((it) => this.addPlace(it, it.reason));
    return {
      personalized_from_history: r.basedOn,
      results: r.items.map((it) => ({
        ref: `attraction:${it.attractionId}`,
        name: it.name,
        category: it.category,
        why: it.reasons.join('; '),
        hours: it.hoursSummary,
        price: it.priceFrom,
        visit_duration: it.visitDuration,
        distance_m: it.distanceMeters,
        highlights: it.highlights.slice(0, 3),
      })),
    };
  }

  private async placeInfo(args: Record<string, any>) {
    const p = await this.resolve(args.place, 'địa điểm');
    if (p.attractionId) {
      const a = await attractionService.detail(p.attractionId);
      this.addPlace(a);
      recommendationService.track(this.userId, a.attractionId, 'ASSISTANT');
      return {
        ref: `attraction:${a.attractionId}`,
        name: a.name,
        category: a.category,
        address: a.address,
        opening_hours: a.openingHours,
        ticket_price: a.ticketPrice,
        visit_duration: a.visitDuration,
        best_time: a.bestTime,
        description: a.description,
        highlights: (a.highlights ?? []).slice(0, 5),
        tips: (a.tips ?? []).slice(0, 4),
        facts: (a.facts ?? []).slice(0, 4).map((f: any) => `${f.label}: ${f.value}`),
        nearby_stations: (a.nearbyStations ?? []).slice(0, 5).map((s: any) => ({
          ref: `station:${s.stationId}`,
          name: s.stationName,
          type: MODE_VI[s.mode] ?? s.mode,
          walk_minutes: s.walkingDuration,
          lines: (s.routes ?? []).map((r: any) => r.routeCode),
        })),
      };
    }
    if (p.stationId) {
      const [s, routes] = await Promise.all([stationRepository.getById(p.stationId), stationRepository.routesOfStation(p.stationId)]);
      if (!s) throw new AppError(404, 'Không tìm thấy trạm');
      return {
        ref: `station:${s.stationId}`,
        name: s.stationName,
        type: MODE_VI[toTransportMode(s.transportTypeName)] ?? 'Trạm',
        address: s.address,
        lines: routes.map((r: any) => `${r.routeCode} - ${r.routeName}`),
      };
    }
    return { ref: p.ref, name: p.name, note: 'Đây là một địa chỉ trên bản đồ, không có thông tin tham quan.' };
  }

  /** Tu van chon ve: dung chung bo tinh cua trang Mua ve (tro ly tu dien giai -> explain: false) */
  private async recommendTicket(args: Record<string, any>) {
    const habit = normalizeHabit({
      ...args,
      // ref "attraction:ID" / "me" -> ten de bo tim dia diem hieu
      commute_origin: refName(args.commute_origin, this.location),
      commute_destination: refName(args.commute_destination, this.location),
    });
    const has = Boolean(habit.commute || habit.trips?.length);
    const a = await ticketAdvisorService.advise({ userId: this.userId, habit: has ? habit : undefined, explain: false });
    this.ticketAdvice = a;
    const VERDICT: Record<string, string> = { BUY_PASS: 'nên mua vé tháng', KEEP_SINGLE: 'nên mua vé lượt', HAS_PASS: 'đang có vé tháng', SINGLE_ONLY: 'chỉ có vé lượt' };
    return {
      based_on: a.basis === 'habit' ? 'thói quen người dùng nêu' : a.basis === 'history' ? `vé lượt đã mua ${a.history.days} ngày qua` : 'chưa có dữ liệu',
      understood: a.understood,
      ...(a.commute ? { commute: a.commute } : {}),
      per_vehicle: a.items.map((it) => ({
        vehicle: it.label,
        rides_per_month: it.ridesPerMonth,
        single_tickets_cost_vnd: it.singleCost,
        monthly_pass: it.pass ? { name: it.pass.name, price_vnd: it.pass.price } : null,
        break_even_rides: it.breakEvenRides,
        saving_vnd: it.saving,
        verdict: VERDICT[it.verdict],
        ...(it.activePass ? { active_pass: it.activePass } : {}),
      })),
      totals_vnd: a.totals,
      summary: a.summary,
      note:
        'Thẻ tư vấn vé (có nút mua vé) hiện ngay dưới câu trả lời. HanoiGo chỉ bán đúng các loại vé trong kết quả này (mỗi phương tiện tối đa 1 loại vé tháng): ' +
        'không nhắc vé 1 tuyến / liên tuyến, vé ưu tiên hay giá nào khác. Chưa biết thói quen thì hỏi người dùng đi phương tiện gì, bao nhiêu lượt mỗi tuần.',
    };
  }

  private async ticketPrices(args: Record<string, any>) {
    const list = await ticketService.ticketTypes({});
    const mode = typeof args.mode === 'string' ? args.mode.toUpperCase() : null;
    return {
      ticket_types: list
        .filter((t: any) => !mode || t.mode === mode)
        .map((t: any) => ({
          name: t.name,
          vehicle: MODE_VI[t.mode] ?? t.transportTypeName,
          kind: t.type === 'MONTHLY' ? 'Vé tháng' : 'Vé lượt',
          price_vnd: t.price,
          valid_minutes: t.durationMinutes,
        })),
      note: 'Chi phí từng lộ trình (theo bảng giá chặng) có trong kết quả plan_route. Có vé tháng thì đoạn đi phương tiện đó được miễn phí.',
    };
  }
}

/** Ref cua tro ly -> ten / toa do de bo tu van ve tim dia diem ("attraction:11" giu nguyen: placeSearch hieu ref) */
function refName(v: unknown, location: { latitude: number; longitude: number } | null): string | undefined {
  const s = String(v ?? '').replace(/<[^>]*>/g, ' ').trim();
  if (!s) return undefined;
  if (/^(me|vị trí hiện tại|vi tri hien tai)$/i.test(s)) return location ? `${location.latitude},${location.longitude}` : undefined;
  return s;
}

function addMinutes(hhmm: string, minutes: number) {
  const [h, m] = hhmm.split(':').map(Number);
  const t = (((h * 60 + m + Math.round(minutes)) % 1440) + 1440) % 1440;
  return `${String(Math.floor(t / 60)).padStart(2, '0')}:${String(t % 60).padStart(2, '0')}`;
}

const HHMM = /^([01]\d|2[0-3]):[0-5]\d$/;

/** 1 buoc lo trinh -> 1 dong ngan cho AI */
function stepText(st: RouteResult['steps'][number]) {
  let s = `${st.instruction} (${st.duration} phút`;
  if (st.waitTime) s += `, chờ ~${st.waitTime} phút`;
  if (st.fare) s += `, ${st.fare.toLocaleString('vi-VN')}đ`;
  s += ')';
  if (st.nextDepartures?.length) s += `; chuyến kế tiếp: ${st.nextDepartures.slice(0, 3).join(', ')}`;
  return s;
}

/** "1,5 – 2 giờ" -> 105 phut, "30 – 45 phút" -> 40, "Nửa ngày" -> 180 (lay trung binh, lam tron 5 phut) */
export function visitMinutes(text?: string | null): number {
  if (!text) return 60;
  if (/nửa ngày/i.test(text)) return 180;
  const m = /(\d+(?:[.,]\d+)?)(?:\s*[–-]\s*(\d+(?:[.,]\d+)?))?\s*(giờ|tiếng|phút)/i.exec(text);
  if (!m) return 60;
  const a = parseFloat(m[1].replace(',', '.'));
  const b = m[2] ? parseFloat(m[2].replace(',', '.')) : a;
  const v = ((a + b) / 2) * (/phút/i.test(m[3]) ? 1 : 60);
  return Math.max(10, Math.round(v / 5) * 5);
}

/**
 * Canh bao gio mo cua tu HoursSummary ("8:00 – 17:00", "7:30 – 11:30, 13:30 – 18:00").
 * Bo phan trong ngoac (ghi chu mua / cuoi tuan); khong co khung gio ro rang -> khong canh bao.
 */
export function hoursWarning(summary: string | null | undefined, arrive: number, leave: number, fullText?: string | null): string | undefined {
  if (!summary) return undefined;
  // Co tinh gio mua dong / mua he va ngay nghi trong tuan (utils/openingHours.ts)
  // (lich trinh co the cho ngay mai -> khong canh bao ngay nghi trong tuan, chi dung khung gio dung mua)
  const wins = openingDay(summary, fullText).windows;
  if (!wins || wins.length === 0) return undefined;
  const t = (x: number) => minutesToTime(x);
  const a = arrive % 1440;
  const l = a + (leave - arrive);
  const inside = wins.find(([o, c]) => a >= o && a < c);
  if (inside) {
    return l > inside[1] ? `Đóng cửa lúc ${t(inside[1])}, chỉ còn ${inside[1] - a} phút tham quan` : undefined;
  }
  const later = wins.find(([o]) => o > a);
  if (later) return `Đến lúc ${t(a)} nhưng ${later === wins[0] ? 'mở cửa' : 'mở cửa lại'} lúc ${t(later[0])} (giờ mở cửa: ${summary})`;
  return `Đến lúc ${t(a)} là đã đóng cửa (giờ mở cửa: ${summary})`;
}

/** Bo ma noi bo (attraction:7, station:12, geo:...) neu AI lo viet vao cau tra loi */
const stripRefs = (text: string) =>
  text
    .replace(/\s*[([](?:attraction|station|geo):[^)\]]*[)\]]/g, '')
    .replace(/\b(?:attraction|station):\d+\b/g, '')
    .replace(/[ \t]+([,.;:!?])/g, '$1');

/* ============================== Loi dan cho AI ============================== */
async function systemPrompt(hasLocation: boolean) {
  const catalog = await placeSearchService.attractionCatalog();
  const now = new Intl.DateTimeFormat('vi-VN', {
    timeZone: 'Asia/Ho_Chi_Minh',
    weekday: 'long',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).format(new Date());
  const sun = sunTimes(new Date(), 21.0285, 105.8542, 7);
  return [
    'Bạn là "Trợ lý HanoiGo", trợ lý lập lộ trình đi lại bằng phương tiện công cộng ở Hà Nội (xe buýt, Metro, xe đạp và xe điện công cộng, đi bộ) và giới thiệu địa điểm tham quan.',
    `Bây giờ ở Hà Nội: ${now}. Hôm nay mặt trời mọc lúc ${sun.sunrise}, lặn lúc ${sun.sunset}.`,
    hasLocation
      ? 'Người dùng ĐÃ bật vị trí hiện tại: khi họ nói "ở đây", "chỗ tôi", "từ vị trí của tôi" thì dùng ref "me".'
      : 'Người dùng CHƯA bật vị trí hiện tại: nếu họ muốn đi "từ đây" thì hỏi họ đang ở đâu hoặc nhắc bật nút "Dùng vị trí của tôi".',
    '',
    'Các địa điểm tham quan có sẵn (dùng ref trực tiếp, không cần find_places):',
    ...catalog.map((c) => `- ${c.ref}: ${c.name} (${c.category ?? 'Địa điểm'})`),
    '',
    'QUY TẮC:',
    '1. Lộ trình, thời gian, giờ xe, chi phí, giá vé, giờ mở cửa: LUÔN lấy từ công cụ. Không tự bịa số tuyến xe, tên trạm, tên phố, hướng rẽ hay giá tiền. Không ghi mã ref (attraction:..., station:...) trong câu trả lời.',
    '2. Thiếu điểm đi hoặc điểm đến thì hỏi lại đúng 1 câu ngắn. Tên mơ hồ (vd. "ga", "chợ") thì dùng find_places rồi hỏi người dùng chọn nếu có nhiều kết quả khác nhau.',
    '3. Tiêu chí: "nhanh" → FASTEST, "rẻ/tiết kiệm" → CHEAPEST, "ít đi bộ/mỏi chân/trời nóng/mưa" → LEAST_WALKING, "ít đổi xe/ít chuyển" → FEWEST_TRANSFERS. Không nói gì → FASTEST.',
    '4. Lịch trình từ 3 điểm hoặc "lên lịch / lịch trình": gọi plan_itinerary MỘT lần (không gọi nhiều plan_route, không cần get_place_info trước). Hôm nay thì start_time không sớm hơn bây giờ. "Ngắm hoàng hôn" → đến nơi trước giờ mặt trời lặn 15–20 phút; "bình minh" → trước giờ mặt trời mọc: nếu kết quả không kịp thì giảm visit_minutes hoặc đổi start_time rồi gọi lại 1 lần. Kết quả có warning (đóng cửa...) thì đổi thứ tự / giờ và gọi lại 1 lần, hoặc nói rõ cho người dùng. Mọi giờ đến, giờ rời trong câu trả lời phải lấy ĐÚNG từ kết quả công cụ.',
    '5. Hỏi nên đi đâu, gợi ý theo sở thích → suggest_places (truyền nguyên văn sở thích). Hỏi giờ mở cửa, giá vé tham quan, nên đi lúc nào → get_place_info. Hỏi giá vé xe → get_ticket_prices. Hỏi nên mua vé tháng hay vé lượt, mua vé gì cho tiết kiệm → recommend_ticket (truyền thói quen nếu người dùng đã nêu; chưa nêu thì gọi không tham số để dùng vé đã mua 30 ngày qua) rồi nêu kết luận và số tiền tiết kiệm.',
    '6. Trả lời bằng tiếng Việt, ngắn gọn, thân thiện. Với lộ trình: nêu phương án tốt nhất trước (tổng thời gian, giờ đến, chi phí, quãng đi bộ, số lần chuyển), rồi các bước chính (lên/xuống ở trạm nào, tuyến số mấy). Nhắc ngắn rằng có thể bấm "Xem trên bản đồ" ở thẻ lộ trình bên dưới. Không liệt kê lại toàn bộ dữ liệu.',
    '7. Chỉ dùng **in đậm** và gạch đầu dòng "- ", không dùng bảng, tiêu đề hay liên kết.',
    '8. Công cụ trả về lỗi (ngoài vùng hỗ trợ, không có lộ trình, không tìm thấy) thì giải thích dễ hiểu và đề xuất cách khác.',
    '9. Chỉ gợi ý đi lại bằng phương tiện có trong HanoiGo (xe buýt, Metro, xe đạp / xe điện công cộng, đi bộ), không gợi ý taxi, xe ôm, xe riêng. Không kịp giờ (đóng cửa, hoàng hôn) thì đề xuất bỏ bớt / đổi thứ tự điểm và tính lại bằng công cụ.',
    '10. Chỉ hỗ trợ đi lại và tham quan ở Hà Nội trên HanoiGo. Câu hỏi ngoài phạm vi thì từ chối lịch sự trong 1 câu và gợi ý điều bạn làm được. Không hỏi thông tin cá nhân.',
  ].join('\n');
}

/* ============================== Hoi thoai ============================== */
function historyToContents(history: AssistantHistoryItem[]): GeminiContent[] {
  const out: GeminiContent[] = [];
  for (const h of history.slice(-12)) {
    let text = String(h.text ?? '').slice(0, 2000).trim();
    if (!text) continue;
    if (h.role === 'assistant' && h.routes?.length) {
      const notes = h.routes
        .slice(0, 4)
        .map((r) => `từ ${r.from}${r.fromRef ? ` [${r.fromRef}]` : ''} đến ${r.to}${r.toRef ? ` [${r.toRef}]` : ''}${r.preference ? `, tiêu chí ${r.preference}` : ''}`)
        .join('; ');
      text += `\n\n(Ghi chú hệ thống: lượt này đã tìm lộ trình ${notes}.)`;
    }
    const role = h.role === 'assistant' ? 'model' : 'user';
    const last = out[out.length - 1];
    if (last && last.role === role) last.parts.push({ text });
    else out.push({ role, parts: [{ text }] });
  }
  while (out.length && out[0].role !== 'user') out.shift();
  return out;
}

const visibleText = (parts: GeminiPart[]) =>
  parts
    .filter((p) => typeof p.text === 'string' && !p.thought)
    .map((p) => p.text)
    .join('')
    .trim();

export const assistantService = {
  status() {
    return gemini.status();
  },

  async chat(input: {
    userId: number;
    message: string;
    history?: AssistantHistoryItem[];
    location?: { latitude: number; longitude: number } | null;
  }): Promise<AssistantReply> {
    const t0 = Date.now();
    let location = input.location ?? null;
    const area = ROUTING_CONFIG.serviceArea;
    if (location && (location.latitude < area.minLat || location.latitude > area.maxLat || location.longitude < area.minLng || location.longitude > area.maxLng)) {
      location = null; // vi tri ngoai Ha Noi -> coi nhu chua co
    }
    const ctx = new ToolContext(input.userId, location);
    const contents: GeminiContent[] = [...historyToContents(input.history ?? []), { role: 'user', parts: [{ text: input.message }] }];
    const systemInstruction = { parts: [{ text: await systemPrompt(Boolean(location)) }] };

    let reply = '';
    let model: string | null = null;
    for (let round = 0; round < MAX_ROUNDS; round++) {
      // Vong cuoi: khong cho goi cong cu nua -> bat buoc tra loi
      const last = round === MAX_ROUNDS - 1 || Date.now() - t0 > SOFT_DEADLINE_MS;
      const r = await gemini.generate(
        {
          systemInstruction,
          contents,
          tools: TOOLS,
          ...(last ? { toolConfig: { functionCallingConfig: { mode: 'NONE' } } } : {}),
        },
        { prefer: model },
      );
      model = r.model;
      const calls = r.parts.filter((p) => p.functionCall);
      if (calls.length === 0) {
        reply = stripRefs(visibleText(r.parts));
        if (!reply && r.finishReason && r.finishReason !== 'STOP') {
          console.warn(`[AI] Empty reply, finishReason=${r.finishReason}`);
        }
        break;
      }
      // Giu NGUYEN cac part cua model (co thoughtSignature) roi gui ket qua cong cu
      contents.push({ role: 'model', parts: r.parts });
      console.log(`[AI] round ${round + 1}: ${calls.map((p) => `${p.functionCall!.name}(${JSON.stringify(p.functionCall!.args ?? {}).slice(0, 160)})`).join(' | ')}`);
      const results = await Promise.all(calls.map((p) => ctx.run(p.functionCall!)));
      contents.push({
        role: 'user',
        parts: calls.map((p, i) => ({
          functionResponse: { ...(p.functionCall!.id ? { id: p.functionCall!.id } : {}), name: p.functionCall!.name, response: results[i] },
        })),
      });
    }

    if (!reply) {
      reply = ctx.routes.length
        ? 'Mình đã tìm được lộ trình, bạn xem các phương án trong thẻ bên dưới nhé.'
        : 'Xin lỗi, mình chưa xử lý được câu này. Bạn thử nói rõ điểm đi, điểm đến hoặc điều bạn muốn tìm nhé.';
    }
    console.log(`[AI] chat user=${input.userId} model=${model} tools=${ctx.calls.map((c) => c.name).join(',') || '-'} ${Date.now() - t0}ms`);
    return {
      reply,
      routes: [...ctx.routes].sort((a, b) => a.id - b.id),
      places: [...ctx.places.values()].slice(0, 6),
      ticketAdvice: ctx.ticketAdvice,
      toolCalls: ctx.calls,
      model,
      elapsedMs: Date.now() - t0,
    };
  },
};
