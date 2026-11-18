/**
 * Goi y dia diem theo so thich (AI)  -  GET /attractions/suggestions
 *
 *  1. Moi dia diem -> 1 vector ngu nghia (Gemini embedding) tu ten, loai, mo ta, diem noi bat, lich su, meo.
 *     Tinh 1 lan, luu bang AttractionEmbeddings; noi dung doi (admin sua) -> tu tinh lai (so ContentHash).
 *  2. So thich nguoi dung nhap ("thich lich su, chup anh") -> vector truy van  => Q = do giong (cosine)
 *  3. Lich su quan tam (xem chi tiet, tim duong toi, tro ly goi y) -> vector "ho so" = trung binh co trong so
 *     (tim duong x2, gan day nang hon: chu ky ban ra 30 ngay)  => H = do giong voi ho so
 *  4. Diem tong:  S = 0.5Q + 0.25H + 0.15C + 0.15D + 0.1P   (thieu thanh phan nao -> bo, chia lai trong so)
 *        C: dung loai nguoi dung chon, D: gan vi tri (0 khi >= 5 km), P: do noi bat
 *  5. Kem ly do de nguoi dung hieu vi sao duoc goi y (co so thich -> Gemini viet 1 cau giai thich).
 *
 * Khong co GEMINI_API_KEY / Gemini loi -> tu ha xuong che do co ban: so khop tu khoa (co tu dong nghia).
 */
import crypto from 'crypto';
import { env } from '../config/env';
import { attractionRepository } from '../repositories/attraction.repository';
import { aiDataRepository, InterestRow } from '../repositories/aiData.repository';
import { cosine, gemini } from './ai/gemini.client';
import { haversineMeters } from '../utils/geo';

export interface SuggestionInput {
  userId?: number;
  query?: string;
  categories?: string[];
  lat?: number;
  lng?: number;
  limit?: number;
  excludeIds?: number[];
  /** false: khong goi Gemini viet ly do (dung khi tro ly AI goi, tro ly tu dien giai) */
  explain?: boolean;
}

export interface SuggestionItem {
  attractionId: number;
  name: string;
  category: string | null;
  imageUrl: string | null;
  address: string | null;
  hoursSummary: string | null;
  priceFrom: string | null;
  visitDuration: string | null;
  latitude: number;
  longitude: number;
  highlights: string[];
  imageCount: number;
  score: number;
  reason: string;
  reasons: string[];
  distanceMeters?: number;
  seen: boolean;
  scoreDetail: Record<string, number>;
}

export interface SuggestionResult {
  mode: 'ai' | 'basic';
  /** Cac dia diem trong lich su dung de ca nhan hoa (toi da 3) */
  basedOn: string[];
  query: string | null;
  items: SuggestionItem[];
  notice?: string;
}

const fold = (s: string) =>
  s
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd');

const splitPipe = (v: unknown) => (v ? String(v).split('|').map((s) => s.trim()).filter(Boolean) : []);

function docText(a: any): string {
  return [
    `${a.name} (${a.category ?? 'Địa điểm'}) - ${a.address ?? 'Hà Nội'}.`,
    a.description,
    splitPipe(a.highlights).length ? `Điểm nổi bật: ${splitPipe(a.highlights).join('; ')}.` : '',
    a.history ? String(a.history).slice(0, 700) : '',
    a.bestTime ? `Thời điểm đẹp: ${a.bestTime}.` : '',
    splitPipe(a.tips).length ? `Kinh nghiệm: ${splitPipe(a.tips).join('; ')}.` : '',
  ]
    .filter(Boolean)
    .join('\n');
}

const contentHash = (text: string) =>
  crypto.createHash('sha256').update(`${env.ai.embeddingModel}|${env.ai.embeddingDimensions}|${text}`).digest('hex');

/* ---------------- Vector dia diem (cache RAM + bang AttractionEmbeddings) ---------------- */
let vecCache: Map<number, { hash: string; vec: number[] }> | null = null;
let embedding: Promise<void> | null = null;

async function attractionVectors(all: any[]): Promise<Map<number, number[]>> {
  if (!vecCache) {
    const stored = await aiDataRepository.embeddings(env.ai.embeddingModel);
    vecCache = new Map(stored.map((s) => [s.attractionId, { hash: s.contentHash, vec: s.vector }]));
  }
  const cache = vecCache;
  const docs = all.map((a) => ({ a, text: docText(a) }));
  const missing = docs.filter((d) => cache.get(d.a.attractionId)?.hash !== contentHash(d.text));
  if (missing.length > 0) {
    if (!embedding) {
      embedding = (async () => {
        const vecs = await gemini.embed(missing.map((d) => d.text), 'document');
        for (let i = 0; i < missing.length; i++) {
          const hash = contentHash(missing[i].text);
          cache.set(missing[i].a.attractionId, { hash, vec: vecs[i] });
          await aiDataRepository.saveEmbedding({ attractionId: missing[i].a.attractionId, model: env.ai.embeddingModel, contentHash: hash, vector: vecs[i] });
        }
        console.log(`[AI] Embedded ${missing.length} attraction(s) with ${env.ai.embeddingModel}`);
      })().finally(() => {
        embedding = null;
      });
    }
    await embedding;
  }
  const out = new Map<number, number[]>();
  for (const d of docs) {
    const c = cache.get(d.a.attractionId);
    if (c) out.set(d.a.attractionId, c.vec);
  }
  return out;
}

const queryCache = new Map<string, number[]>();
async function queryVector(q: string): Promise<number[]> {
  const key = fold(q.trim()).replace(/\s+/g, ' ');
  const hit = queryCache.get(key);
  if (hit) return hit;
  const [v] = await gemini.embed([q.trim()], 'query');
  if (queryCache.size > 300) queryCache.clear();
  queryCache.set(key, v);
  return v;
}

/* ---------------- Che do co ban: tu khoa + tu dong nghia ---------------- */
const SYNONYMS: Record<string, string[]> = {
  'lich su': ['di tich', 'bao tang', 'hoang thanh', 'lich su', 'chien tranh', 'trieu', 'van mieu', 'nha tu', 'quan su', 'khang chien', 'cua o'],
  'van hoa': ['van hoa', 'truyen thong', 'dan toc', 'nghe thuat', 'mua roi', 'sach', 'gom', 'nha co', 'phu nu'],
  'kien truc': ['kien truc', 'phap', 'nha hat', 'cau', 'dong duong', 'thap', 'gothic', 'nha tho', 'toa nha'],
  'chup anh': ['chup anh', 'song ao', 'canh', 'hoang hon', 'kien truc', 'ho'],
  'am thuc': ['an', 'am thuc', 'bia', 'cho', 'quan', 'do nuong', 'pho'],
  'thien nhien': ['ho', 'cay', 'xanh', 'hoang hon', 'song', 'mat nuoc', 'cong vien', 'vuon thu', 'dong vat'],
  'tam linh': ['chua', 'den', 'phat', 'tam linh', 'tho', 'nha tho', 'thanh duong', 'thanh mau', 'tu tran'],
  've dem': ['dem', 'bia', 'pho', 'den', 'toi'],
  'tre em': ['tre em', 'mua roi', 'bao tang', 'gia dinh', 'vui choi', 'cong vien', 'thuy cung', 'vuon thu', 'khung long', 'tro choi', 'xiec', 'may bay'],
  'mua sam': ['cho', 'mua', 'hang', 'sach', 'trung tam thuong mai', 'cua hang', 'mall'],
  'yen tinh': ['yen tinh', 'ho', 'chua', 'vuon', 'thu thai'],
  'nghe thuat': ['nghe thuat', 'my thuat', 'mua roi', 'nha hat', 'tranh', 'xiec', 'gom'],
};

function keywordTerms(q: string): string[] {
  const f = fold(q);
  const terms = new Set<string>();
  for (const [k, list] of Object.entries(SYNONYMS)) if (f.includes(k)) list.forEach((t) => terms.add(t));
  f.split(/[^a-z0-9]+/)
    .filter((w) => w.length >= 3 && !['thich', 'muon', 'toi', 'minh', 'nhung', 'noi', 'cho', 'cac', 'va', 'voi', 'mot', 'di'].includes(w))
    .forEach((w) => terms.add(w));
  return [...terms];
}

function keywordScore(terms: string[], text: string): number {
  if (terms.length === 0) return 0;
  const f = fold(text);
  let hit = 0;
  for (const t of terms) if (f.includes(t)) hit++;
  return hit / terms.length;
}

/** Diem noi bat khop nhat voi so thich (de lam ly do) */
function bestHighlight(a: any, terms: string[]): string | null {
  const hl = splitPipe(a.highlights);
  if (hl.length === 0) return null;
  let best = hl[0];
  let bestScore = -1;
  for (const h of hl) {
    const s = keywordScore(terms, h);
    if (s > bestScore) {
      best = h;
      bestScore = s;
    }
  }
  return bestScore > 0 ? best : null;
}

/* ---------------- Ho so so thich tu lich su ---------------- */
const SOURCE_WEIGHT: Record<string, number> = { ROUTE: 2, ASSISTANT: 1.5, VIEW: 1 };

function interestWeights(rows: InterestRow[]): Map<number, number> {
  const w = new Map<number, number>();
  for (const r of rows) {
    const x = (SOURCE_WEIGHT[r.source] ?? 1) * Math.pow(0.5, r.daysAgo / 30);
    w.set(r.attractionId, (w.get(r.attractionId) ?? 0) + x);
  }
  return w;
}

const minmax = (values: number[]) => {
  const lo = Math.min(...values);
  const hi = Math.max(...values);
  return (v: number) => (hi - lo < 1e-9 ? 0.5 : Math.max(0, Math.min(1, (v - lo) / (hi - lo))));
};

/* ---------------- Gemini viet ly do (co so thich) ---------------- */
const explainCache = new Map<string, Record<number, string>>();

async function aiReasons(query: string, items: { a: any }[]): Promise<Record<number, string>> {
  const key = `${fold(query)}|${items.map((i) => i.a.attractionId).join(',')}`;
  const hit = explainCache.get(key);
  if (hit) return hit;
  const list = items
    .map((i) => `- id ${i.a.attractionId}: ${i.a.name} (${i.a.category}). ${i.a.description ?? ''} Nổi bật: ${splitPipe(i.a.highlights).slice(0, 4).join('; ')}`)
    .join('\n');
  const prompt =
    `Người dùng ở Hà Nội cho biết sở thích: "${query.slice(0, 300)}".\n` +
    `Với mỗi địa điểm dưới đây, viết đúng 1 câu tiếng Việt (tối đa 22 từ) giải thích vì sao nơi này hợp với sở thích đó, ` +
    `dựa vào thông tin cho sẵn, không bịa thêm chi tiết.\n${list}\n\n` +
    `Chỉ trả về JSON dạng {"<id>": "<câu giải thích>", ...}, không thêm chữ nào khác.`;
  const run = gemini.generate({ contents: [{ role: 'user', parts: [{ text: prompt }] }], generationConfig: { responseMimeType: 'application/json' } });
  const timeout = new Promise<null>((resolve) => setTimeout(() => resolve(null), 9000));
  const r = await Promise.race([run, timeout]);
  if (!r) return {};
  const text = r.parts.filter((p) => p.text && !p.thought).map((p) => p.text).join('');
  try {
    const parsed = JSON.parse(text.replace(/^```(json)?|```$/g, '').trim());
    const out: Record<number, string> = {};
    for (const [id, s] of Object.entries(parsed)) if (typeof s === 'string' && s.trim()) out[Number(id)] = s.trim().slice(0, 200);
    if (explainCache.size > 200) explainCache.clear();
    explainCache.set(key, out);
    return out;
  } catch {
    return {};
  }
}

export const recommendationService = {
  /** Ghi nhan quan tam (khong lam hong request chinh neu loi) */
  track(userId: number | undefined, attractionId: number | undefined, source: 'VIEW' | 'ROUTE' | 'ASSISTANT') {
    if (!userId || !attractionId) return;
    aiDataRepository.addInterest(userId, attractionId, source).catch((e) => console.warn('[AI] track interest failed:', e?.message ?? e));
  },

  async suggest(input: SuggestionInput): Promise<SuggestionResult> {
    const query = input.query?.trim().slice(0, 300) || null;
    const limit = Math.max(1, Math.min(20, input.limit ?? 6));
    const cats = (input.categories ?? []).map((c) => c.toLowerCase());
    const hasLoc = input.lat !== undefined && input.lng !== undefined;
    const exclude = new Set(input.excludeIds ?? []);

    const [all, counts, rows] = await Promise.all([
      attractionRepository.list({}),
      attractionRepository.imageCounts(),
      input.userId ? aiDataRepository.interests(input.userId) : Promise.resolve([] as InterestRow[]),
    ]);
    const weights = interestWeights(rows);
    const byId = new Map<number, any>(all.map((a: any) => [a.attractionId, a]));

    // ---- 1. Vector (AI) hoac tu khoa (co ban)
    let mode: 'ai' | 'basic' = 'basic';
    let notice: string | undefined;
    let vecs = new Map<number, number[]>();
    let qVec: number[] | null = null;
    if (gemini.configured()) {
      try {
        vecs = await attractionVectors(all);
        if (query) qVec = await queryVector(query);
        mode = 'ai';
      } catch (e: any) {
        notice = 'AI tạm thời không dùng được, đang gợi ý theo từ khóa.';
        console.warn('[AI] suggestions fallback to keywords:', e?.message ?? e);
        vecs = new Map();
        qVec = null;
      }
    } else {
      notice = 'Chưa cấu hình GEMINI_API_KEY: đang gợi ý theo từ khóa.';
    }

    // Vector ho so = trung binh co trong so cac dia diem da quan tam
    let profile: number[] | null = null;
    if (mode === 'ai' && weights.size > 0) {
      const dim = env.ai.embeddingDimensions;
      const acc = new Array(dim).fill(0);
      let total = 0;
      for (const [id, w] of weights) {
        const v = vecs.get(id);
        if (!v) continue;
        for (let i = 0; i < Math.min(dim, v.length); i++) acc[i] += v[i] * w;
        total += w;
      }
      if (total > 0) {
        const n = Math.sqrt(acc.reduce((s, x) => s + x * x, 0));
        profile = n > 0 ? acc.map((x) => x / n) : null;
      }
    }
    // Che do co ban: ho so = cac loai dia diem da quan tam
    const catWeight = new Map<string, number>();
    for (const [id, w] of weights) {
      const c = String(byId.get(id)?.category ?? '').toLowerCase();
      if (c) catWeight.set(c, (catWeight.get(c) ?? 0) + w);
    }
    const maxCatW = Math.max(0, ...catWeight.values());

    const terms = query ? keywordTerms(query) : [];
    const candidates = all.filter((a: any) => !exclude.has(a.attractionId));

    const raw = candidates.map((a: any) => {
      const v = vecs.get(a.attractionId);
      const q = query ? (qVec && v ? cosine(qVec, v) : keywordScore(terms, docText(a))) : 0;
      const h = weights.size > 0 ? (profile && v ? cosine(profile, v) : maxCatW > 0 ? (catWeight.get(String(a.category ?? '').toLowerCase()) ?? 0) / maxCatW : 0) : 0;
      return { a, q, h };
    });
    const nq = minmax(raw.map((r) => r.q));
    // "Danh cho ban": so sanh giua cac noi CHUA xem (noi da xem dung lam ho so, luon giong nhat)
    const unseen = raw.filter((r) => !weights.has(r.a.attractionId));
    const nh = minmax((!query && unseen.length > 0 ? unseen : raw).map((r) => r.h));

    // Trong so, bo thanh phan khong co roi chia lai
    const w = {
      q: query ? 0.5 : 0,
      h: weights.size > 0 ? 0.25 : 0,
      c: cats.length > 0 ? 0.15 : 0,
      d: hasLoc ? 0.15 : 0,
      p: 0.1,
    };
    if (!query && weights.size === 0 && cats.length === 0) w.p = 0.6; // chua co gi -> chu yeu theo do noi bat
    const sum = w.q + w.h + w.c + w.d + w.p;

    const scored = raw.map(({ a, q, h }) => {
      const Q = query ? nq(q) : 0;
      const H = weights.size > 0 ? nh(h) : 0;
      const C = cats.length > 0 && cats.includes(String(a.category ?? '').toLowerCase()) ? 1 : 0;
      let D = 0;
      let distanceMeters: number | undefined;
      if (hasLoc) {
        distanceMeters = Math.round(haversineMeters(input.lat!, input.lng!, a.latitude, a.longitude));
        D = Math.max(0, 1 - distanceMeters / 5000);
      }
      const P = Math.max(0, Math.min(100, a.popularityScore ?? 50)) / 100;
      let score = (w.q * Q + w.h * H + w.c * C + w.d * D + w.p * P) / sum;
      const seen = weights.has(a.attractionId);
      return { a, Q, H, C, D, P, score, distanceMeters, seen, rawQ: q };
    });
    // "Danh cho ban" (khong nhap so thich): goi y noi MOI giong noi da xem; noi da xem chi de lap cho trong
    scored.sort((x, y) => (!query ? Number(x.seen) - Number(y.seen) : 0) || y.score - x.score);
    const top = scored.slice(0, limit);

    // ---- 2. Ly do goi y
    const viewedIds = [...weights.entries()].sort((x, y) => y[1] - x[1]).map(([id]) => id);
    const basedOn = viewedIds.slice(0, 3).map((id) => byId.get(id)?.name).filter(Boolean) as string[];
    const llmReasons =
      mode === 'ai' && query && input.explain !== false
        ? await aiReasons(query, top).catch(() => ({}) as Record<number, string>)
        : ({} as Record<number, string>);

    const items: SuggestionItem[] = top.map((s) => {
      const a = s.a;
      const reasons: string[] = [];
      if (llmReasons[a.attractionId]) reasons.push(llmReasons[a.attractionId]);
      else if (query && s.Q >= 0.55) {
        const hl = bestHighlight(a, terms);
        reasons.push(hl ? `Hợp với “${query}”: ${hl}` : `Hợp với “${query}”`);
      }
      if (weights.size > 0 && s.H >= 0.6 && !s.seen) {
        // Dia diem da quan tam giong nhat (khac chinh no)
        let similar: string | null = null;
        let best = -1;
        const v = vecs.get(a.attractionId);
        for (const id of viewedIds.slice(0, 10)) {
          if (id === a.attractionId) continue;
          const other = vecs.get(id);
          const sim = v && other ? cosine(v, other) : String(byId.get(id)?.category) === String(a.category) ? 1 : 0;
          if (sim > best) {
            best = sim;
            similar = byId.get(id)?.name ?? null;
          }
        }
        if (similar && best > 0) reasons.push(`Giống ${similar} mà bạn đã quan tâm`);
      }
      if (s.C) reasons.push(`Đúng loại bạn chọn: ${a.category}`);
      if (s.distanceMeters !== undefined) reasons.push(`Cách bạn ${s.distanceMeters < 1000 ? `${s.distanceMeters} m` : `${(s.distanceMeters / 1000).toFixed(1).replace('.', ',')} km`}`);
      if (reasons.length === 0) reasons.push(s.seen ? 'Bạn đã quan tâm nơi này gần đây' : 'Được nhiều du khách ghé thăm');
      return {
        attractionId: a.attractionId,
        name: a.name,
        category: a.category,
        imageUrl: a.imageUrl,
        address: a.address,
        hoursSummary: a.hoursSummary,
        priceFrom: a.priceFrom,
        visitDuration: a.visitDuration,
        latitude: a.latitude,
        longitude: a.longitude,
        highlights: splitPipe(a.highlights),
        imageCount: counts.get(a.attractionId) ?? 0,
        score: Math.round(s.score * 1000) / 10,
        reason: reasons.slice(0, 2).join(' · '),
        reasons,
        distanceMeters: s.distanceMeters,
        seen: s.seen,
        scoreDetail: {
          query: Math.round(s.Q * 100),
          history: Math.round(s.H * 100),
          category: s.C * 100,
          distance: Math.round(s.D * 100),
          popularity: Math.round(s.P * 100),
          similarity: Math.round(s.rawQ * 1000) / 1000,
        },
      };
    });

    return { mode, basedOn, query, items, ...(notice ? { notice } : {}) };
  },
};
