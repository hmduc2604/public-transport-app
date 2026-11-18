/**
 * Doc khung gio mo cua tu HoursSummary (+ OpeningHours day du), CO TINH MUA, cuoi tuan va ngay nghi:
 *   "8:00 – 17:00"                              -> [[480, 1020]]
 *   "7:30 – 11:30, 13:30 – 18:00"               -> 2 khung
 *   "7:30 – 17:30 (đông: 8:00 – 17:00)"         -> thang 11 - 3 dung gio mua dong
 *   "7:00 – 18:00 (cuối tuần đến 21:00)"        -> thu Bay, Chu nhat dong cua luc 21:00
 *   "10:00 – 22:00 (cuối tuần từ 9:30)"         -> thu Bay, Chu nhat mo cua tu 9:30
 *   "8:00 – 17:00 (nghỉ T2, T6)", "Nghỉ thứ Hai" -> hom nay la ngay nghi
 * Thang 4 va 10 la giao mua (moi di tich doi gio mot ngay khac nhau) -> khong chac -> windows = null.
 */
const WEEKDAYS = ['chủ nhật', 'thứ hai', 'thứ ba', 'thứ tư', 'thứ năm', 'thứ sáu', 'thứ bảy'];
const DAY_TOKENS: [RegExp, number][] = [
  [/chủ nhật|\bcn\b/, 0],
  [/thứ hai|\bt2\b/, 1],
  [/thứ ba|\bt3\b/, 2],
  [/thứ tư|\bt4\b/, 3],
  [/thứ năm|\bt5\b/, 4],
  [/thứ sáu|\bt6\b/, 5],
  [/thứ bảy|\bt7\b/, 6],
];

function hanoiParts(date: Date) {
  const parts = new Intl.DateTimeFormat('en-US', { timeZone: 'Asia/Ho_Chi_Minh', month: 'numeric', weekday: 'short' }).formatToParts(date);
  const month = Number(parts.find((p) => p.type === 'month')?.value ?? date.getMonth() + 1);
  const wd = parts.find((p) => p.type === 'weekday')?.value ?? 'Sun';
  const weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].indexOf(wd);
  return { month, weekday: weekday < 0 ? date.getDay() : weekday };
}

const parseWindows = (text: string): [number, number][] =>
  [...text.matchAll(/(\d{1,2})[:h](\d{2})\s*[–-]\s*(\d{1,2})[:h](\d{2})/g)].map((m) => [Number(m[1]) * 60 + Number(m[2]), Number(m[3]) * 60 + Number(m[4])]);

export interface OpeningDay {
  /** Ten ngay hom nay neu hom nay la ngay nghi co dinh ("thứ hai") */
  closedToday: string | null;
  /** Cac khung gio mo cua hom nay (phut tu 0:00); null = khong doc duoc / khong chac */
  windows: [number, number][] | null;
  season: 'summer' | 'winter' | 'transition' | null;
}

export function openingDay(summary: string | null | undefined, fullText?: string | null, date = new Date()): OpeningDay {
  const { month, weekday } = hanoiParts(date);
  const all = `${summary ?? ''} ${fullText ?? ''}`.toLowerCase();

  // Ngay nghi co dinh trong tuan; "nghỉ thứ Hai đầu tiên của tháng" -> khong chac -> bo qua
  let closedToday: string | null = null;
  const closed = /(?:nghỉ|đóng cửa)\s+((?:(?:vào|các|ngày)\s+)*(?:(?:thứ\s*(?:hai|ba|tư|năm|sáu|bảy)|chủ nhật|t[2-7]|cn)(?:\s*(?:,|và|&)\s*)?)+)(\s*đầu tiên)?/i.exec(all);
  if (closed && !closed[2]) {
    const days = DAY_TOKENS.filter(([re]) => re.test(closed[1])).map(([, d]) => d);
    if (days.includes(weekday)) closedToday = WEEKDAYS[weekday];
  }
  if (!summary) return { closedToday, windows: null, season: null };

  // Mua dong / mua he
  let season: OpeningDay['season'] = null;
  let windows: [number, number][];
  const winterPart = /\(\s*(?:mùa\s*)?đông\s*:?\s*([^)]*)\)/i.exec(summary)?.[1];
  const main = parseWindows(summary.replace(/\([^)]*\)/g, ''));
  if (winterPart) {
    if (month === 4 || month === 10) return { closedToday, windows: null, season: 'transition' };
    const winter = month >= 11 || month <= 3;
    season = winter ? 'winter' : 'summer';
    windows = winter ? parseWindows(winterPart) : main;
  } else {
    windows = main;
  }
  if (windows.length === 0) return { closedToday, windows: null, season };

  // Cuoi tuan mo som / dong muon hon
  if (weekday === 0 || weekday === 6) {
    const to = /cuối tuần\s*(?:mở\s*)?(?:đến|tới)\s*(\d{1,2})[:h](\d{2})/i.exec(summary);
    const from = /cuối tuần\s*(?:mở\s*)?từ\s*(\d{1,2})[:h](\d{2})/i.exec(summary);
    windows = windows.map((w) => [...w] as [number, number]);
    if (to) windows[windows.length - 1][1] = Number(to[1]) * 60 + Number(to[2]);
    if (from) windows[0][0] = Number(from[1]) * 60 + Number(from[2]);
  }
  return { closedToday, windows, season };
}
