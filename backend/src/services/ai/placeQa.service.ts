/**
 * HOI DAP NGAY TREN TRANG DIA DIEM (AI)  -  POST /api/v1/attractions/:id/ask
 *
 *   Cau hoi cua khach ("Bay gio con mo cua khong?", "Co hop voi tre em khong?")
 *        ▼
 *   Gemini CHI duoc dung thong tin cua dia diem trong database (mo ta, lich su, gio mo cua, gia ve, thong tin nhanh,
 *   moc lich su, kinh nghiem, tram gan, dia diem lan can) + gio hien tai o Ha Noi  -> khong tu bia so lieu.
 *   Khong co thong tin -> noi ro la HanoiGo chua co, goi y dieu lien quan.
 *        ▼
 *   Cau tra loi ngan + toi da 3 cau hoi goi y tiep theo
 *
 * Khong co AI / AI loi (het luot, qua tai) -> tra loi nhanh theo tu khoa tu chinh du lieu do.
 * Cau hoi khong phu thuoc gio (gia ve, lich su...) duoc nho 30 phut de tiet kiem luot goi Gemini.
 */
import crypto from 'crypto';
import { attractionService } from '../attraction.service';
import { gemini, GeminiContent } from './gemini.client';
import { recommendationService } from '../recommendation.service';
import { minutesToTime, timeToMinutes, currentHanoiTime } from '../../utils/time';
import { openingDay } from '../../utils/openingHours';

export interface PlaceAnswer {
  answer: string;
  followUps: string[];
  mode: 'ai' | 'basic';
  notice?: string;
  model?: string | null;
  cached?: boolean;
}

export interface PlaceQaHistory {
  question: string;
  answer: string;
}

const MODE_VI: Record<string, string> = { BUS: 'xe buýt', METRO: 'Metro', BICYCLE: 'xe đạp công cộng', ELECTRIC_VEHICLE: 'xe điện công cộng' };
const DEFAULT_QUESTIONS = [
  'Bây giờ còn mở cửa không?',
  'Giá vé bao nhiêu?',
  'Nên đi vào lúc nào?',
  'Có phù hợp với trẻ em không?',
  'Đi xe buýt đến đây thế nào?',
  'Gần đây có gì tham quan tiếp?',
];

const fold = (s: string) =>
  s
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd')
    .replace(/[^a-z0-9\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

/** Cau hoi phu thuoc thoi diem hoi -> khong nho cau tra loi */
const TIME_SENSITIVE = /mo cua|dong cua|bay gio|luc nay|hom nay|toi nay|sang nay|chieu nay|con kip|now|open|today|tonight/;

/** Trang thai luc hoi theo gio mo cua (co tinh mua dong / he va ngay nghi trong tuan) */
export function openStatus(summary: string | null | undefined, fullText: string | null | undefined, now: number, date = new Date()): string | null {
  const d = openingDay(summary, fullText, date);
  if (d.closedToday) return `hôm nay (${d.closedToday}) là ngày nghỉ`;
  if (!d.windows) return null;
  const wins = d.windows;
  const season = d.season === 'winter' ? ' (giờ mùa đông)' : d.season === 'summer' ? ' (giờ mùa hè)' : '';
  const inside = wins.find(([o, c]) => now >= o && now < c);
  if (inside) return `đang trong giờ mở cửa${season}, đóng lúc ${minutesToTime(inside[1])} (còn ${inside[1] - now} phút)`;
  const later = wins.find(([o]) => o > now);
  if (later) return `đang ngoài giờ mở cửa${season}, ${later === wins[0] ? 'mở cửa' : 'mở cửa lại'} lúc ${minutesToTime(later[0])}`;
  return `đã hết giờ mở cửa hôm nay${season}, đóng lúc ${minutesToTime(wins[wins.length - 1][1])}`;
}

function hanoiNow() {
  const label = new Intl.DateTimeFormat('vi-VN', {
    timeZone: 'Asia/Ho_Chi_Minh',
    weekday: 'long',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).format(new Date());
  return { label, minutes: timeToMinutes(currentHanoiTime()) };
}

/** Du lieu cua dia diem -> van ban cho Gemini (phan "tinh", khong gom gio hien tai) */
function buildContext(a: any): string {
  const L: string[] = [];
  const add = (label: string, v: unknown) => {
    if (v !== null && v !== undefined && String(v).trim()) L.push(`${label}: ${String(v).trim()}`);
  };
  const list = (label: string, items: string[]) => {
    if (items.length) L.push(`${label}:`, ...items.map((x) => `- ${x}`));
  };
  add('Tên địa điểm', a.name);
  add('Loại', a.category);
  add('Địa chỉ', a.address);
  add('Giới thiệu', a.description);
  add('Lịch sử', a.history);
  add('Giờ mở cửa', a.openingHours);
  add('Giờ mở cửa (tóm tắt)', a.hoursSummary);
  add('Giá vé', a.ticketPrice);
  add('Giá vé (tóm tắt)', a.priceFrom);
  add('Thời gian tham quan gợi ý', a.visitDuration);
  add('Thời điểm đẹp nhất', a.bestTime);
  list('Điểm nổi bật', a.highlights ?? []);
  list('Thông tin nhanh', (a.facts ?? []).map((f: any) => `${f.label}: ${f.value}`));
  list('Các mốc lịch sử', (a.timeline ?? []).map((t: any) => `${t.year}: ${t.event}`));
  list('Kinh nghiệm tham quan', a.tips ?? []);
  list(
    'Trạm phương tiện công cộng gần (đi bộ tới địa điểm)',
    (a.nearbyStations ?? []).slice(0, 6).map(
      (s: any) =>
        `${s.stationName} (${MODE_VI[s.mode] ?? s.mode}), ${s.walkingDuration} phút đi bộ (${s.walkingDistance} m)` +
        (s.routes?.length ? `, tuyến dừng: ${s.routes.slice(0, 8).map((r: any) => r.routeCode).join(', ')}` : ''),
    ),
  );
  list(
    'Địa điểm tham quan lân cận',
    (a.nearbyAttractions ?? []).map((n: any) => `${n.name} (${n.category ?? 'Địa điểm'}), cách ${n.distanceMeters} m, khoảng ${n.walkingMinutes} phút đi bộ`),
  );
  return L.join('\n');
}

const ANSWER_TOOL = {
  functionDeclarations: [
    {
      name: 'answer',
      description: 'Trả lời câu hỏi của khách về địa điểm.',
      parameters: {
        type: 'object',
        properties: {
          answer: { type: 'string', description: 'Câu trả lời ngắn gọn (1 – 4 câu hoặc vài gạch đầu dòng "- "), in đậm thông tin chính bằng **...**' },
          follow_ups: {
            type: 'array',
            items: { type: 'string' },
            description: 'Tối đa 3 câu hỏi ngắn khách có thể hỏi tiếp mà DỮ LIỆU trả lời được (cùng ngôn ngữ với câu hỏi), không lặp câu vừa hỏi',
          },
        },
        required: ['answer'],
      },
    },
  ],
};

/* ---------------- Tra loi nhanh theo tu khoa (khong co AI) ---------------- */
function basicAnswer(a: any, question: string, status: string | null): string {
  const f = fold(question);
  const bullets = (items: string[]) => items.map((x) => `- ${x}`).join('\n');
  const none = 'HanoiGo chưa có thông tin này.';
  if (/mo cua|dong cua|may gio|gio mo|gio dong|khung gio|open|hours/.test(f)) {
    return `**Giờ mở cửa:** ${a.openingHours ?? a.hoursSummary ?? none}${status ? `\nLúc này địa điểm ${status}.` : ''}`;
  }
  if (/\bve\b|gia|bao nhieu tien|mien phi|ton phi|price|ticket|fee/.test(f)) return `**Giá vé:** ${a.ticketPrice ?? a.priceFrom ?? none}`;
  if (/bao lau|mat bao|thoi gian tham quan|tham quan trong|how long/.test(f)) return `**Thời gian tham quan gợi ý:** ${a.visitDuration ?? none}`;
  if (/luc nao|khi nao|thoi diem|mua nao|gio nao dep|best time/.test(f)) return `**Thời điểm đẹp nhất:** ${a.bestTime ?? none}`;
  if (/xe buyt|\bbus\b|metro|tram|tuyen|duong di|di den|den day|toi day|di the nao|di bang|how to get/.test(f)) {
    const st = (a.nearbyStations ?? []).slice(0, 3);
    if (!st.length) return `${none} Bạn bấm **Tìm đường đến đây** để hệ thống tìm lộ trình từ vị trí của bạn.`;
    return `Các trạm gần **${a.name}**:\n${bullets(
      st.map((s: any) => `${s.stationName} (${MODE_VI[s.mode] ?? s.mode}), ${s.walkingDuration} phút đi bộ${s.routes?.length ? `, tuyến ${s.routes.slice(0, 5).map((r: any) => r.routeCode).join(', ')}` : ''}`),
    )}\nBấm **Tìm đường đến đây** để có lộ trình từ vị trí của bạn.`;
  }
  if (/gan day|lan can|xung quanh|gan do|di tiep|nearby/.test(f)) {
    const n = a.nearbyAttractions ?? [];
    return n.length
      ? `Gần **${a.name}** có:\n${bullets(n.map((x: any) => `${x.name}: ${x.distanceMeters} m, khoảng ${x.walkingMinutes} phút đi bộ`))}`
      : 'Chưa có địa điểm tham quan nào trong bán kính 3 km.';
  }
  if (/tre em|tre nho|em be|con nho|nguoi gia|meo|luu y|kinh nghiem|trang phuc|chuan bi|nen mang|can biet|tips/.test(f)) {
    return (a.tips ?? []).length ? `**Kinh nghiệm tham quan:**\n${bullets(a.tips.slice(0, 5))}` : none;
  }
  if (/lich su|nam nao|xay dung|thanh lap|ra doi|co tu|history|built/.test(f)) {
    const t = (a.timeline ?? []).slice(0, 4).map((x: any) => `${x.year}: ${x.event}`);
    return a.history || t.length ? `${a.history ?? ''}${t.length ? `\n${bullets(t)}` : ''}`.trim() : none;
  }
  const hl = (a.highlights ?? []).slice(0, 3);
  return `${a.description ?? ''}${hl.length ? `\n**Điểm nổi bật:**\n${bullets(hl)}` : ''}`.trim() || none;
}

/* ---------------- Bo nho dem cau tra loi ---------------- */
const CACHE_TTL_MS = 30 * 60 * 1000;
const cache = new Map<string, { at: number; value: PlaceAnswer }>();
function cacheGet(key: string) {
  const hit = cache.get(key);
  if (!hit) return null;
  if (Date.now() - hit.at > CACHE_TTL_MS) {
    cache.delete(key);
    return null;
  }
  return hit.value;
}
function cacheSet(key: string, value: PlaceAnswer) {
  if (cache.size >= 300) cache.delete(cache.keys().next().value as string);
  cache.set(key, { at: Date.now(), value });
}

export const placeQaService = {
  async ask(input: { userId: number; attractionId: number; question: string; history?: PlaceQaHistory[] }): Promise<PlaceAnswer> {
    const a: any = await attractionService.detail(input.attractionId);
    const question = input.question.trim();
    const history = (input.history ?? []).slice(-3);
    const now = hanoiNow();
    const status = openStatus(a.hoursSummary ?? a.openingHours, a.openingHours, now.minutes);
    const context = buildContext(a);
    const asked = fold(question);
    const followDefault = DEFAULT_QUESTIONS.filter((q) => fold(q) !== asked).slice(0, 3);
    recommendationService.track(input.userId, a.attractionId, 'ASSISTANT');

    const basic = (notice?: string): PlaceAnswer => ({
      answer: basicAnswer(a, question, status),
      followUps: followDefault,
      mode: 'basic',
      ...(notice ? { notice } : {}),
    });
    if (!gemini.configured()) return basic('Chưa cấu hình GEMINI_API_KEY: câu trả lời lấy trực tiếp từ thông tin địa điểm.');

    const cacheKey =
      history.length === 0 && !TIME_SENSITIVE.test(asked)
        ? `${a.attractionId}:${crypto.createHash('sha1').update(context).digest('hex').slice(0, 12)}:${asked}`
        : null;
    const hit = cacheKey ? cacheGet(cacheKey) : null;
    if (hit) return { ...hit, cached: true };

    const system = [
      `Bạn là hướng dẫn viên của HanoiGo, trả lời câu hỏi của khách về địa điểm "${a.name}" ở Hà Nội.`,
      `Bây giờ ở Hà Nội: ${now.label}.${status ? ` Theo giờ mở cửa, lúc này địa điểm ${status}.` : ''}`,
      'QUY TẮC:',
      '1. CHỈ dùng thông tin trong phần DỮ LIỆU bên dưới và giờ hiện tại. Không bịa thêm giờ mở cửa, giá vé, sự kiện, năm, số liệu hay tên tuyến xe.',
      '2. Dữ liệu không có câu trả lời thì nói rõ "HanoiGo chưa có thông tin này" rồi gợi ý điều liên quan mà dữ liệu có.',
      '3. Hỏi còn mở cửa không: dựa vào trạng thái lúc này ở trên (đã tính mùa hè / mùa đông và ngày nghỉ). Không có trạng thái thì tự xét giờ mở cửa theo hôm nay (mùa đông thường từ tháng 11 đến tháng 3), nói rõ nếu không chắc.',
      '4. Hỏi cách đi đến: nêu trạm gần nhất, tuyến, số phút đi bộ và nhắc bấm nút "Tìm đường đến đây" để có lộ trình từ vị trí của khách.',
      '5. Câu hỏi không liên quan đến địa điểm, tham quan hay đi lại thì từ chối lịch sự trong 1 câu.',
      '6. Trả lời ngắn gọn, thân thiện, bằng ngôn ngữ của câu hỏi (mặc định tiếng Việt). Chỉ dùng **in đậm** và gạch đầu dòng "- ", không bảng, tiêu đề, liên kết.',
      '7. Luôn trả lời bằng cách gọi hàm answer.',
      '',
      'DỮ LIỆU:',
      context,
    ].join('\n');

    const contents: GeminiContent[] = [];
    for (const h of history) {
      contents.push({ role: 'user', parts: [{ text: h.question.slice(0, 300) }] });
      contents.push({ role: 'model', parts: [{ text: h.answer.slice(0, 1500) }] });
    }
    contents.push({ role: 'user', parts: [{ text: question }] });

    try {
      const r = await gemini.generate({
        systemInstruction: { parts: [{ text: system }] },
        contents,
        tools: [ANSWER_TOOL],
        toolConfig: { functionCallingConfig: { mode: 'ANY', allowedFunctionNames: ['answer'] } },
      });
      const args = (r.parts.find((p) => p.functionCall)?.functionCall?.args ?? {}) as Record<string, any>;
      const text =
        typeof args.answer === 'string' && args.answer.trim()
          ? args.answer.trim()
          : r.parts
              .filter((p) => typeof p.text === 'string' && !p.thought)
              .map((p) => p.text)
              .join('')
              .trim();
      if (!text) return basic('Trợ lý AI chưa trả lời được, đây là thông tin có sẵn của địa điểm.');
      const followUps = (Array.isArray(args.follow_ups) ? args.follow_ups : [])
        .filter((q: unknown): q is string => typeof q === 'string' && q.trim().length > 1 && fold(q) !== asked)
        .map((q: string) => q.trim().slice(0, 120))
        .slice(0, 3);
      const value: PlaceAnswer = { answer: text, followUps: followUps.length ? followUps : followDefault, mode: 'ai', model: r.model };
      if (cacheKey) cacheSet(cacheKey, value);
      console.log(`[AI] hoi dap dia diem #${a.attractionId} user=${input.userId} model=${r.model}`);
      return value;
    } catch (e: any) {
      console.warn(`[AI] Hoi dap dia diem #${a.attractionId}: ${e?.errorCode ?? e?.message} -> tra loi theo tu khoa`);
      return basic('Trợ lý AI đang bận, câu trả lời lấy trực tiếp từ thông tin địa điểm.');
    }
  },
};
