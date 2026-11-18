/**
 * TU VAN CHON VE (AI)  -  POST /api/v1/tickets/advice   +   cong cu recommend_ticket cua tro ly
 *
 *   Nguoi dung ta thoi quen bang loi ("di lam tu Cau Giay den Ho Guom, thu 2 - thu 6")
 *        │  Gemini (function calling) TACH thoi quen: so luot / tuan theo phuong tien, tuyen di lam thuong xuyen
 *        ▼
 *   He thong TINH (khong phai AI): tuyen di lam -> bo tim duong cua nhom -> gia tung chang theo phuong tien
 *        so luot / thang x gia luot  so voi  gia ve thang  -> nen mua ve thang hay ve luot, tiet kiem bao nhieu
 *        ▼
 *   Gemini viet 2 - 4 cau giai thich tu dung cac con so da tinh (khong tu tinh / bia so)
 *
 * Khong ta thoi quen -> dua tren ve luot da mua 30 ngay qua.
 * Khong co GEMINI_API_KEY / Gemini loi -> tach thoi quen bang tu khoa + giai thich theo mau (van dung so lieu that).
 */
import { AppError } from '../../utils/AppError';
import { gemini, GeminiPart } from './gemini.client';
import { placeSearchService } from './placeSearch.service';
import { ticketService } from '../ticket.service';
import { routingService } from '../routing.service';
import { tripHistoryRepository } from '../../repositories/tripHistory.repository';
import { TransportMode } from '../../types/transport.types';
import { LocationInput, RouteResult, RoutingSearchResult } from '../../types/routing.types';

export type RideMode = Exclude<TransportMode, 'WALK'>;
export const RIDE_MODES: RideMode[] = ['BUS', 'METRO', 'BICYCLE', 'ELECTRIC_VEHICLE'];
const MODE_VI: Record<RideMode, string> = {
  BUS: 'Xe buýt',
  METRO: 'Metro',
  BICYCLE: 'Xe đạp công cộng',
  ELECTRIC_VEHICLE: 'Xe điện công cộng',
};
/** 1 thang = 30 ngay = 30/7 tuan */
const WEEKS_PER_MONTH = 30 / 7;
const HISTORY_DAYS = 30;

export interface HabitInput {
  /** So luot / tuan theo phuong tien (1 luot = 1 lan len xe / tau) */
  trips?: { mode: RideMode; perWeek: number }[];
  /** Tuyen di thuong xuyen (di lam / di hoc): he thong tu tim lo trinh de biet phuong tien + gia */
  commute?: { origin: string; destination: string; daysPerWeek: number; roundTrip: boolean };
  /** AI chua du thong tin -> cau hoi lai nguoi dung */
  unclear?: string | null;
}

interface TypeRef {
  ticketTypeId: number;
  name: string;
  price: number;
}

export interface AdviceItem {
  mode: RideMode;
  label: string;
  ridesPerMonth: number;
  /** Gia trung binh 1 luot (theo bang gia chang neu tinh tu tuyen di lam) */
  farePerRide: number;
  /** Tien mua ve luot cho so luot / thang */
  singleCost: number;
  single: TypeRef | null;
  pass: TypeRef | null;
  /** Tu bao nhieu luot / thang thi ve thang re hon */
  breakEvenRides: number | null;
  /** singleCost - gia ve thang (> 0: ve thang loi hon) */
  saving: number | null;
  verdict: 'BUY_PASS' | 'KEEP_SINGLE' | 'HAS_PASS' | 'SINGLE_ONLY';
  activePass?: { name: string; daysLeft: number };
}

export interface TicketAdvice {
  basis: 'habit' | 'history' | 'none';
  /** Thoi quen he thong hieu duoc (hien cho nguoi dung kiem tra) */
  understood: string[];
  commute?: {
    from: string;
    to: string;
    minutes: number;
    farePerTrip: number;
    tripsPerMonth: number;
    summary: string;
    /** Chi phi / thang cua lo trinh nay khi chon ve tot nhat */
    monthlyCost: number;
    /** Lo trinh nhanh nhat (neu khac va ton hon lo trinh dung de tinh) */
    fastest?: { minutes: number; summary: string; monthlyCost: number };
    error?: string;
  };
  items: AdviceItem[];
  totals: { singleOnly: number; best: number; saving: number };
  buy: TypeRef[];
  summary: string;
  explanation: string;
  question?: string | null;
  history: { days: number; singleTickets: number; spent: number; trips: number };
  mode: 'ai' | 'basic';
  notice?: string;
  model?: string | null;
}

const vnd = (n: number) => `${Math.round(n).toLocaleString('vi-VN')}đ`;
const fold = (s: string) =>
  s
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd');

/* ============================== Tach thoi quen ============================== */

const HABIT_TOOL = {
  functionDeclarations: [
    {
      name: 'record_travel_habit',
      description: 'Ghi lại thói quen đi lại bằng phương tiện công cộng mà người dùng vừa mô tả.',
      parameters: {
        type: 'object',
        properties: {
          trips: {
            type: 'array',
            description:
              'Số LƯỢT đi mỗi tuần theo phương tiện mà người dùng nêu rõ (1 lượt = 1 lần lên xe/tàu; "mỗi ngày 2 lượt, 5 ngày/tuần" = 10). ' +
              'Không ghi lại phần đã mô tả bằng tuyến đi làm (commute_*), chỉ ghi các chuyến khác.',
            items: {
              type: 'object',
              properties: {
                mode: { type: 'string', enum: RIDE_MODES, description: 'BUS = xe buýt, METRO = tàu điện / Metro, BICYCLE = xe đạp công cộng, ELECTRIC_VEHICLE = xe điện công cộng' },
                per_week: { type: 'number', description: 'Số lượt mỗi tuần' },
              },
              required: ['mode', 'per_week'],
            },
          },
          commute_origin: { type: 'string', description: 'Nơi đi của chuyến thường xuyên (đi làm, đi học) nếu người dùng nêu: tên địa điểm / khu vực / địa chỉ ở Hà Nội' },
          commute_destination: { type: 'string', description: 'Nơi đến của chuyến thường xuyên' },
          commute_days_per_week: { type: 'number', description: 'Số ngày mỗi tuần đi tuyến đó ("thứ 2 - thứ 6" = 5, "hằng ngày" = 7). Không nói rõ thì đi làm / đi học = 5.' },
          commute_round_trip: { type: 'boolean', description: 'true nếu đi rồi về trong ngày (đi làm, đi học thường là true)' },
          unclear: { type: 'string', description: 'Chỉ điền khi chưa đủ thông tin để tư vấn: 1 câu hỏi lại ngắn bằng tiếng Việt' },
        },
      },
    },
  ],
};

async function parseHabitAi(text: string): Promise<{ habit: HabitInput; model: string }> {
  const r = await gemini.generate({
    systemInstruction: {
      parts: [
        {
          text:
            'Bạn đọc mô tả thói quen đi lại bằng phương tiện công cộng ở Hà Nội của người dùng và gọi record_travel_habit. ' +
            'Chỉ điền điều người dùng nói hoặc suy ra trực tiếp (vd. "đi làm bằng Metro, thứ 2 - thứ 6" = METRO 10 lượt/tuần). ' +
            'Có nơi đi và nơi đến cụ thể thì điền commute_* (hệ thống tự tìm lộ trình), không đoán thêm phương tiện cho chuyến đó. ' +
            '"Thỉnh thoảng" ≈ 2 lượt/tuần, "cuối tuần" = 2 ngày. Không bịa số liệu.',
        },
      ],
    },
    contents: [{ role: 'user', parts: [{ text }] }],
    tools: [HABIT_TOOL],
    toolConfig: { functionCallingConfig: { mode: 'ANY', allowedFunctionNames: ['record_travel_habit'] } },
  });
  const call = r.parts.find((p: GeminiPart) => p.functionCall)?.functionCall;
  const a = (call?.args ?? {}) as Record<string, any>;
  return { habit: normalizeHabit(a), model: r.model };
}

/** Tham so tu AI (record_travel_habit / recommend_ticket) -> HabitInput hop le */
export function normalizeHabit(a: Record<string, any>): HabitInput {
  const trips = (Array.isArray(a.trips) ? a.trips : [])
    .map((t: any) => ({ mode: String(t?.mode ?? '').toUpperCase() as RideMode, perWeek: Number(t?.per_week ?? t?.perWeek) }))
    .filter((t: { mode: RideMode; perWeek: number }) => RIDE_MODES.includes(t.mode) && Number.isFinite(t.perWeek) && t.perWeek > 0)
    .map((t: { mode: RideMode; perWeek: number }) => ({ mode: t.mode, perWeek: Math.min(70, t.perWeek) }));
  const origin = typeof a.commute_origin === 'string' ? a.commute_origin.trim().slice(0, 150) : '';
  const destination = typeof a.commute_destination === 'string' ? a.commute_destination.trim().slice(0, 150) : '';
  const days = Number(a.commute_days_per_week);
  const habit: HabitInput = { trips };
  if (origin && destination) {
    habit.commute = {
      origin,
      destination,
      daysPerWeek: Number.isFinite(days) && days > 0 ? Math.min(7, days) : 5,
      roundTrip: a.commute_round_trip !== false,
    };
  }
  if (typeof a.unclear === 'string' && a.unclear.trim()) habit.unclear = a.unclear.trim().slice(0, 300);
  return habit;
}

/** Khong co AI: tach bang tu khoa ("metro 2 luot moi ngay, 5 ngay/tuan", "tu A den B") */
const UNCLEAR_QUESTION =
  'Bạn đi phương tiện gì và khoảng bao nhiêu lượt mỗi tuần? Ví dụ: "Metro 2 lượt mỗi ngày, 5 ngày/tuần" hoặc "đi làm từ Cầu Giấy đến Hồ Gươm".';

export function parseHabitBasic(text: string): HabitInput {
  const f = fold(text);
  const num = (re: RegExp) => {
    const m = re.exec(f);
    return m ? Number(m[1].replace(',', '.')) : undefined;
  };
  const perDay = num(/(\d+(?:[.,]\d+)?)\s*(?:luot|chuyen|lan)\s*(?:\/|moi|mot|1)?\s*ngay/) ?? (/(di|ve)\s*(lam|hoc)|khu hoi|di ve/.test(f) ? 2 : undefined);
  const perWeekDirect = num(/(\d+(?:[.,]\d+)?)\s*(?:luot|chuyen|lan)\s*(?:\/|moi|mot|1)?\s*tuan/);
  let days = num(/(\d)\s*ngay\s*(?:\/|moi|mot|1)?\s*tuan/);
  if (days === undefined) {
    if (/thu\s*2\s*(?:-|den|toi|–)\s*thu\s*6|ngay\s*(?:di\s*)?lam|di\s*lam|di\s*hoc/.test(f)) days = 5;
    else if (/hang\s*ngay|moi\s*ngay|ngay\s*nao\s*cung/.test(f)) days = 7;
    else if (/cuoi\s*tuan/.test(f)) days = 2;
  }
  const perWeek = perWeekDirect ?? (perDay !== undefined ? perDay * (days ?? 5) : undefined);

  const modes: RideMode[] = [];
  if (/metro|tau\s*dien|duong\s*sat|tau\s*cao\s*toc/.test(f)) modes.push('METRO');
  if (/xe\s*buyt|\bbus\b|\bbuyt\b/.test(f)) modes.push('BUS');
  if (/xe\s*dap/.test(f)) modes.push('BICYCLE');
  if (/xe\s*dien/.test(f)) modes.push('ELECTRIC_VEHICLE');

  const habit: HabitInput = { trips: [] };
  // "tu Cau Giay den Ho Guom" (lay nguyen van tieng Viet co dau tu cau goc)
  const m = /từ\s+(.+?)\s+(?:đến|tới|lên|ra|về|sang)\s+(.+?)(?:[,.;]|\s+(?:bằng|mỗi|hằng|hàng|thứ|từ\s+thứ|\d)|$)/i.exec(text);
  if (m && m[1].trim().length >= 2 && m[2].trim().length >= 2 && !/^thứ\s*\d/i.test(m[1].trim())) {
    habit.commute = { origin: m[1].trim(), destination: m[2].trim(), daysPerWeek: days ?? 5, roundTrip: !/mot\s*chieu/.test(f) };
  } else if (modes.length && perWeek) {
    // Nhieu phuong tien ma chi co 1 con so -> chia deu
    habit.trips = modes.map((mode) => ({ mode, perWeek: Math.round((perWeek / modes.length) * 10) / 10 }));
  }
  if (!habit.commute && !habit.trips?.length) {
    habit.unclear = UNCLEAR_QUESTION;
  }
  return habit;
}

/* ============================== Tinh toan ============================== */

/** Ten dia diem / ref cua tro ly ("attraction:11", "station:5", "geo:21.03,105.85", "21.03,105.85") -> diem cho bo tim duong */
async function resolvePlace(text: string): Promise<LocationInput> {
  const v = text.trim();
  let m = /^attraction:\s*(\d+)\b/i.exec(v);
  if (m) return { attractionId: Number(m[1]) };
  m = /^station:\s*(\d+)\b/i.exec(v);
  if (m) return { stationId: Number(m[1]) };
  m = /^(?:geo:)?\s*(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)\s*$/i.exec(v);
  if (m) return { latitude: Number(m[1]), longitude: Number(m[2]), name: 'Vị trí của bạn' };
  const [best] = await placeSearchService.find(v, 1);
  if (!best) throw new AppError(404, `Không tìm thấy "${text}" ở Hà Nội`, 'PLACE_NOT_FOUND');
  const [kind, id] = best.ref.split(':');
  if (kind === 'attraction') return { attractionId: Number(id), name: best.name };
  if (kind === 'station') return { stationId: Number(id), name: best.name };
  return { latitude: best.latitude, longitude: best.longitude, name: best.name };
}

type Usage = Map<RideMode, { rides: number; spend: number }>;
const addUsage = (u: Usage, mode: RideMode, rides: number, spend: number) => {
  const cur = u.get(mode) ?? { rides: 0, spend: 0 };
  u.set(mode, { rides: cur.rides + rides, spend: cur.spend + spend });
};

const routeSummary = (r: RouteResult) =>
  r.steps.map((s) => (s.mode === 'WALK' ? 'Đi bộ' : `${MODE_VI[s.mode as RideMode] ?? s.mode} ${s.routeCode ?? ''}`.trim())).join(' → ');

/**
 * Tuyen di lam: tim lo trinh (nhanh nhat + re nhat, gia day du - khong tru ve thang dang co),
 * moi phuong an tinh chi phi / thang khi chon ve tot nhat cho tung phuong tien,
 * chon phuong an RE NHAT trong so cac phuong an cham hon nhanh nhat toi da 20 phut.
 */
async function commuteUsage(
  c: NonNullable<HabitInput['commute']>,
  usage: Usage,
  passPrice: (mode: RideMode) => number | null,
): Promise<TicketAdvice['commute']> {
  const tripsPerMonth = Math.round(c.daysPerWeek * WEEKS_PER_MONTH * (c.roundTrip ? 2 : 1));
  try {
    const [o, d] = await Promise.all([resolvePlace(c.origin), resolvePlace(c.destination)]);
    const searches = await Promise.allSettled(
      (['FASTEST', 'CHEAPEST'] as const).map((preference) => routingService.search({ origin: o, destination: d, preference, departureTime: '07:30' })),
    );
    const found = searches.filter((x): x is PromiseFulfilledResult<RoutingSearchResult> => x.status === 'fulfilled').map((x) => x.value);
    if (found.length === 0) throw (searches[0] as PromiseRejectedResult).reason;
    const seen = new Set<string>();
    const options = found.flatMap((res) => res.routes).filter((r) => !seen.has(r.id) && seen.add(r.id));
    const evaluate = (r: RouteResult) => {
      const perMode = new Map<RideMode, number>();
      for (const st of r.steps) if (st.mode !== 'WALK') perMode.set(st.mode as RideMode, (perMode.get(st.mode as RideMode) ?? 0) + st.fare);
      let monthly = 0;
      for (const [mode, fare] of perMode) {
        const single = fare * tripsPerMonth;
        const pass = passPrice(mode);
        monthly += pass !== null ? Math.min(single, pass) : single;
      }
      return { r, monthly, fare: [...perMode.values()].reduce((a, b) => a + b, 0) };
    };
    const evals = options.map(evaluate);
    const fastest = evals.reduce((a, b) => (b.r.totalDuration < a.r.totalDuration ? b : a));
    const chosen = evals
      .filter((e) => e.r.totalDuration <= fastest.r.totalDuration + 20)
      .reduce((a, b) => (b.monthly < a.monthly || (b.monthly === a.monthly && b.r.totalDuration < a.r.totalDuration) ? b : a));
    for (const st of chosen.r.steps) {
      if (st.mode !== 'WALK') addUsage(usage, st.mode as RideMode, tripsPerMonth, st.fare * tripsPerMonth);
    }
    return {
      from: found[0].origin.name,
      to: found[0].destination.name,
      minutes: chosen.r.totalDuration,
      farePerTrip: chosen.fare,
      tripsPerMonth,
      summary: routeSummary(chosen.r),
      monthlyCost: chosen.monthly,
      ...(chosen !== fastest && fastest.monthly > chosen.monthly
        ? { fastest: { minutes: fastest.r.totalDuration, summary: routeSummary(fastest.r), monthlyCost: fastest.monthly } }
        : {}),
    };
  } catch (e: any) {
    return {
      from: c.origin,
      to: c.destination,
      minutes: 0,
      farePerTrip: 0,
      tripsPerMonth,
      summary: '',
      monthlyCost: 0,
      error: e instanceof AppError ? e.message : 'Không tìm được lộ trình cho tuyến này',
    };
  }
}

function describeHabit(h: HabitInput, commute?: TicketAdvice['commute']): string[] {
  const out: string[] = [];
  if (h.commute) {
    const from = commute?.from ?? h.commute.origin;
    const to = commute?.to ?? h.commute.destination;
    out.push(`${h.commute.roundTrip ? `Khứ hồi ${from} ⇄ ${to}` : `Một chiều ${from} → ${to}`}, ${h.commute.daysPerWeek} ngày/tuần`);
  }
  for (const t of h.trips ?? []) out.push(`${MODE_VI[t.mode]}: ${Math.round(t.perWeek * 10) / 10} lượt/tuần`);
  return out;
}

function basicExplanation(a: Omit<TicketAdvice, 'explanation' | 'mode'>): string {
  if (a.items.length === 0) return a.summary;
  const c = a.commute;
  const route =
    c && !c.error
      ? [
          `- Tuyến ${c.from} → ${c.to}: ${c.summary} (${c.minutes} phút, ${vnd(c.farePerTrip)}/chuyến, khoảng ${c.tripsPerMonth} chuyến/tháng).`,
          ...(c.fastest ? [`- Lộ trình nhanh nhất (${c.fastest.summary}, ${c.fastest.minutes} phút) tốn khoảng ${vnd(c.fastest.monthlyCost)}/tháng, đắt hơn ${vnd(c.fastest.monthlyCost - c.monthlyCost)}.`] : []),
        ]
      : [];
  const lines = a.items.map((it) => {
    const base = `${it.label}: khoảng ${it.ridesPerMonth} lượt/tháng, mua vé lượt hết ${vnd(it.singleCost)}`;
    if (it.verdict === 'HAS_PASS') return `- ${base}. Bạn đang có **${it.activePass?.name}** (còn ${it.activePass?.daysLeft} ngày).`;
    if (it.verdict === 'SINGLE_ONLY') return `- ${base} (chưa có vé tháng cho phương tiện này).`;
    if (it.verdict === 'BUY_PASS') return `- ${base}, đắt hơn **${it.pass!.name}** (${vnd(it.pass!.price)}) **${vnd(it.saving!)}** → nên mua vé tháng.`;
    return `- ${base}, rẻ hơn ${it.pass!.name} (${vnd(it.pass!.price)}). Vé tháng chỉ có lợi từ khoảng **${it.breakEvenRides} lượt/tháng**.`;
  });
  return [a.summary, ...route, ...lines].join('\n');
}

async function explainAi(a: Omit<TicketAdvice, 'explanation' | 'mode'>): Promise<{ text: string; model: string }> {
  const data = {
    can_cu: a.basis === 'habit' ? 'thói quen người dùng mô tả' : `vé lượt đã mua ${HISTORY_DAYS} ngày qua`,
    thoi_quen: a.understood,
    tuyen_thuong_xuyen:
      a.commute && !a.commute.error
        ? {
            tu: a.commute.from,
            den: a.commute.to,
            lo_trinh_dung_de_tinh: a.commute.summary,
            phut: a.commute.minutes,
            gia_moi_chuyen: a.commute.farePerTrip,
            so_chuyen_moi_thang: a.commute.tripsPerMonth,
            ...(a.commute.fastest
              ? { lo_trinh_nhanh_nhat_nhung_ton_hon: { lo_trinh: a.commute.fastest.summary, phut: a.commute.fastest.minutes, chi_phi_moi_thang: a.commute.fastest.monthlyCost } }
              : {}),
          }
        : undefined,
    tung_phuong_tien: a.items.map((it) => ({
      phuong_tien: it.label,
      luot_moi_thang: it.ridesPerMonth,
      tien_mua_ve_luot: it.singleCost,
      ve_thang: it.pass ? { ten: it.pass.name, gia: it.pass.price } : null,
      hoa_von_tu_luot: it.breakEvenRides,
      chenh_lech: it.saving,
      ket_luan: { BUY_PASS: 'nên mua vé tháng', KEEP_SINGLE: 'nên tiếp tục mua vé lượt', HAS_PASS: 'đang có vé tháng', SINGLE_ONLY: 'chỉ có vé lượt' }[it.verdict],
      ve_thang_dang_co: it.activePass,
    })),
    tong: { chi_ve_luot: a.totals.singleOnly, phuong_an_tot_nhat: a.totals.best, tiet_kiem: a.totals.saving },
  };
  const r = await gemini.generate({
    systemInstruction: {
      parts: [
        {
          text:
            'Bạn là nhân viên tư vấn vé của HanoiGo (vé xe buýt, Metro, xe đạp và xe điện công cộng ở Hà Nội). ' +
            'Viết 2 – 4 câu tiếng Việt thân thiện: nên mua vé gì, tiết kiệm bao nhiêu mỗi tháng, và một lưu ý hữu ích (vd. từ bao nhiêu lượt thì vé tháng có lợi). ' +
            'Có tuyến đi thường xuyên thì nói ngắn lộ trình dùng để tính (đi phương tiện / tuyến nào); có lộ trình nhanh hơn nhưng tốn hơn thì nhắc 1 câu so sánh. ' +
            'CHỈ dùng đúng các con số trong dữ liệu (đơn vị đồng, viết dạng 200.000đ), không tự tính số mới, không bịa giá hay tuyến. ' +
            'In đậm kết luận chính bằng **...**. Không dùng bảng, tiêu đề, liên kết. Không nhắc tới "dữ liệu JSON".',
        },
      ],
    },
    contents: [{ role: 'user', parts: [{ text: JSON.stringify(data) }] }],
  });
  const text = r.parts
    .filter((p) => typeof p.text === 'string' && !p.thought)
    .map((p) => p.text)
    .join('')
    .trim();
  if (!text) throw new AppError(502, 'AI không trả lời', 'AI_ERROR');
  return { text, model: r.model };
}

export const ticketAdvisorService = {
  /**
   * habitText: mo ta bang loi (trang Mua ve) | habit: da tach san (tro ly AI goi cong cu)
   * explain: false -> khong goi Gemini viet giai thich (tro ly tu dien giai)
   */
  async advise(input: { userId: number; habitText?: string; habit?: HabitInput; explain?: boolean }): Promise<TicketAdvice> {
    let aiUsed = false;
    let model: string | null = null;
    let notice: string | undefined;

    // 1. Thoi quen
    let habit: HabitInput | null = input.habit ?? null;
    const text = input.habitText?.trim();
    if (!habit && text) {
      if (gemini.configured()) {
        try {
          const p = await parseHabitAi(text);
          habit = p.habit;
          model = p.model;
          aiUsed = true;
        } catch (e: any) {
          console.warn(`[AI] Tu van ve: khong tach duoc thoi quen bang AI (${e?.errorCode ?? e?.message}) -> dung tu khoa`);
          notice = 'Trợ lý AI đang bận, hệ thống hiểu mô tả của bạn theo từ khóa.';
          habit = parseHabitBasic(text);
        }
      } else {
        habit = parseHabitBasic(text);
        notice = 'Chưa cấu hình GEMINI_API_KEY: hệ thống hiểu mô tả của bạn theo từ khóa.';
      }
    }
    const hasHabit = Boolean(habit && (habit.commute || habit.trips?.length));
    // Nguoi dung co mo ta nhung chua du thong tin -> hoi lai, khong lang le tu van theo lich su mua ve
    if (text && !hasHabit && !habit?.unclear) habit = { ...(habit ?? {}), unclear: UNCLEAR_QUESTION };
    const askBack = !hasHabit && Boolean(habit?.unclear);

    // 2. Ve da mua 30 ngay qua + ve thang dang co + bang gia
    const [types, tickets, trips] = await Promise.all([
      ticketService.ticketTypes({}),
      ticketService.myTickets(input.userId),
      tripHistoryRepository.listByUser(input.userId, 200),
    ]);
    const since = Date.now() - HISTORY_DAYS * 86_400_000;
    const recent = tickets.filter((t: any) => t.status !== 'CANCELLED' && new Date(t.validFrom).getTime() >= since);
    const recentSingles = recent.filter((t: any) => t.type === 'SINGLE');
    const history = {
      days: HISTORY_DAYS,
      singleTickets: recentSingles.length,
      spent: recentSingles.reduce((s: number, t: any) => s + Number(t.price), 0),
      trips: trips.filter((t: any) => t.startedAt && new Date(t.startedAt).getTime() >= since).length,
    };
    const typeOf = (mode: RideMode, kind: 'SINGLE' | 'MONTHLY'): TypeRef | null => {
      const t = types
        .filter((x: any) => x.mode === mode && x.type === kind)
        .sort((p: any, q: any) => p.price - q.price)[0];
      return t ? { ticketTypeId: t.ticketTypeId, name: t.name, price: Number(t.price) } : null;
    };
    const activePasses = new Map<RideMode, { name: string; daysLeft: number }>();
    for (const t of tickets as any[]) {
      if (t.type !== 'MONTHLY' || t.status !== 'ACTIVE' || !t.isValidNow) continue;
      const daysLeft = Math.max(1, Math.ceil(Number(t.remainingMinutes) / 1440));
      const cur = activePasses.get(t.mode);
      if (!cur || cur.daysLeft < daysLeft) activePasses.set(t.mode, { name: t.ticketTypeName, daysLeft });
    }

    // 3. So luot / thang moi phuong tien
    const usage: Usage = new Map();
    let commute: TicketAdvice['commute'];
    if (hasHabit) {
      if (habit!.commute) commute = await commuteUsage(habit!.commute, usage, (m) => typeOf(m, 'MONTHLY')?.price ?? null);
      for (const t of habit!.trips ?? []) {
        const rides = Math.round(t.perWeek * WEEKS_PER_MONTH);
        addUsage(usage, t.mode, rides, rides * (typeOf(t.mode, 'SINGLE')?.price ?? 0));
      }
    } else if (!askBack) {
      for (const t of recentSingles as any[]) addUsage(usage, t.mode, 1, Number(t.price));
    }

    // 4. So sanh ve luot / ve thang
    const items: AdviceItem[] = [];
    for (const mode of RIDE_MODES) {
      const u = usage.get(mode);
      const active = activePasses.get(mode);
      if ((!u || u.rides <= 0) && (!active || askBack)) continue;
      const single = typeOf(mode, 'SINGLE');
      const pass = typeOf(mode, 'MONTHLY');
      const rides = Math.round(u?.rides ?? 0);
      const singleCost = Math.round(u?.spend ?? 0);
      const farePerRide = rides > 0 ? Math.round(singleCost / rides) : single?.price ?? 0;
      const breakEvenRides = pass && farePerRide > 0 ? Math.ceil(pass.price / farePerRide) : null;
      const saving = pass ? singleCost - pass.price : null;
      const verdict: AdviceItem['verdict'] = active ? 'HAS_PASS' : !pass ? 'SINGLE_ONLY' : (saving ?? 0) > 0 ? 'BUY_PASS' : 'KEEP_SINGLE';
      items.push({ mode, label: MODE_VI[mode], ridesPerMonth: rides, farePerRide, singleCost, single, pass, breakEvenRides, saving, verdict, ...(active ? { activePass: active } : {}) });
    }

    const singleOnly = items.reduce((s, it) => s + it.singleCost, 0);
    const best = items.reduce((s, it) => s + (it.pass && it.verdict !== 'SINGLE_ONLY' ? Math.min(it.singleCost, it.pass.price) : it.singleCost), 0);
    const buy = items.filter((it) => it.verdict === 'BUY_PASS').map((it) => it.pass!);
    const basis: TicketAdvice['basis'] = hasHabit ? 'habit' : items.length ? 'history' : 'none';
    const saved = singleOnly - best;

    let summary: string;
    if (items.length === 0 && commute?.error) {
      summary = `Không tìm được lộ trình ${commute.from} → ${commute.to}: ${commute.error}. Bạn thử ghi tên địa điểm cụ thể hơn nhé.`;
    } else if (items.length === 0 && commute && commute.farePerTrip === 0) {
      summary = `Tuyến ${commute.from} → ${commute.to} khá gần, hệ thống gợi ý đi bộ (${commute.minutes} phút) nên chưa cần mua vé.`;
    } else if (items.length === 0 && askBack) {
      summary = 'Mình chưa hiểu rõ thói quen đi lại của bạn nên chưa tư vấn được.';
    } else if (items.length === 0) {
      summary = hasHabit
        ? 'Chưa tính được chi phí cho thói quen này. Bạn thử ghi rõ phương tiện và số lượt mỗi tuần nhé.'
        : `Bạn chưa mua vé lượt nào trong ${HISTORY_DAYS} ngày qua. Hãy mô tả thói quen đi lại (đi phương tiện gì, bao nhiêu lượt mỗi tuần) để được tư vấn.`;
    } else if (buy.length) {
      summary = `Nên mua ${buy.map((b) => b.name).join(' và ')}: tiết kiệm khoảng ${vnd(saved)} mỗi tháng so với mua vé lượt.`;
    } else if (items.every((it) => it.verdict === 'HAS_PASS')) {
      summary = 'Bạn đã có vé tháng cho các phương tiện hay đi, chưa cần mua thêm.';
    } else {
      summary = `Nên tiếp tục mua vé lượt: khoảng ${vnd(singleOnly)} mỗi tháng, rẻ hơn vé tháng với số lượt hiện tại.`;
    }

    const base: Omit<TicketAdvice, 'explanation' | 'mode'> = {
      basis,
      understood: hasHabit ? describeHabit(habit!, commute) : [],
      ...(commute ? { commute } : {}),
      items,
      totals: { singleOnly, best, saving: saved },
      buy,
      summary,
      question: askBack ? habit!.unclear : null,
      history,
    };

    // 5. Giai thich
    let explanation = basicExplanation(base);
    if (input.explain !== false && items.length > 0 && gemini.configured()) {
      try {
        const r = await explainAi(base);
        explanation = r.text;
        model = r.model;
        aiUsed = true;
      } catch (e: any) {
        console.warn(`[AI] Tu van ve: khong viet duoc giai thich (${e?.errorCode ?? e?.message}) -> dung mau`);
        notice = notice ?? 'Trợ lý AI đang bận, phần giải thích được tạo tự động từ số liệu.';
      }
    }
    if (base.question && items.length === 0) explanation = base.question;

    console.log(`[AI] tu van ve user=${input.userId} basis=${basis} items=${items.map((i) => `${i.mode}:${i.ridesPerMonth}:${i.verdict}`).join(',') || '-'} ai=${aiUsed}`);
    return { ...base, explanation, mode: aiUsed ? 'ai' : 'basic', ...(notice ? { notice } : {}), model };
  },
};
