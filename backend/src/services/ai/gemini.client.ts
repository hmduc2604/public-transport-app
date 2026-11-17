/**
 * Client goi Google Gemini API (REST, khong dung SDK) - dung chung cho:
 *   - Tro ly lap lo trinh (generateContent + function calling)
 *   - Goi y dia diem (embedContent: bien mo ta dia diem / so thich thanh vector)
 *
 * Khoa:  GEMINI_API_KEY trong backend/.env.local, gui qua header x-goog-api-key
 *        (ho tro ca khoa moi dang "AQ." lan khoa cu "AIza").
 * Model: thu lan luot env.ai.models, nho model dau tien goi duoc (khoa mien phi co the
 *        khong duoc dung mot so model -> 404 / 429 "limit: 0" -> tu chuyen model ke tiep).
 */
import { env } from '../../config/env';
import { AppError } from '../../utils/AppError';

export interface GeminiFunctionCall {
  id?: string;
  name: string;
  args?: Record<string, unknown>;
}

export interface GeminiPart {
  text?: string;
  thought?: boolean;
  /** Phai gui tra NGUYEN VAN khi tiep tuc luot goi ham (Gemini 3+ bat buoc) */
  thoughtSignature?: string;
  functionCall?: GeminiFunctionCall;
  functionResponse?: { id?: string; name: string; response: Record<string, unknown> };
}

export interface GeminiContent {
  role: 'user' | 'model';
  parts: GeminiPart[];
}

export interface GenerateRequest {
  contents: GeminiContent[];
  systemInstruction?: { parts: { text: string }[] };
  tools?: unknown[];
  toolConfig?: unknown;
  generationConfig?: Record<string, unknown>;
}

export interface GenerateResult {
  model: string;
  parts: GeminiPart[];
  finishReason?: string;
  usage?: { promptTokenCount?: number; candidatesTokenCount?: number; totalTokenCount?: number };
}

export class GeminiHttpError extends Error {
  constructor(
    public status: number,
    message: string,
  ) {
    super(message);
    this.name = 'GeminiHttpError';
  }
}

async function call(method: 'GET' | 'POST', path: string, body?: unknown, timeoutMs = env.ai.timeoutMs): Promise<any> {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), timeoutMs);
  try {
    const res = await fetch(`${env.ai.baseUrl}/${path}`, {
      method,
      headers: { 'Content-Type': 'application/json', 'x-goog-api-key': env.ai.geminiApiKey },
      body: body === undefined ? undefined : JSON.stringify(body),
      signal: ctrl.signal,
    });
    const text = await res.text();
    if (!res.ok) {
      let message = text;
      try {
        const err = JSON.parse(text)?.error;
        message = err?.message ?? text;
        // 429: ghi them loai han muc (theo phut / theo ngay) de biet nen bo qua model bao lau
        const details: any[] = Array.isArray(err?.details) ? err.details : [];
        const quota = details.flatMap((d) => (Array.isArray(d?.violations) ? d.violations : [])).map((v: any) => v?.quotaId).filter(Boolean);
        const retry = details.find((d) => d?.retryDelay)?.retryDelay;
        if (quota.length || retry) message += ` [${[...new Set(quota)].join(', ')}${retry ? ` retry ${retry}` : ''}]`;
      } catch {
        /* giu nguyen text */
      }
      throw new GeminiHttpError(res.status, String(message).slice(0, 900));
    }
    return text ? JSON.parse(text) : {};
  } catch (e: any) {
    if (e instanceof GeminiHttpError) throw e;
    if (e?.name === 'AbortError') throw new GeminiHttpError(504, 'Gemini phản hồi quá lâu');
    throw new GeminiHttpError(503, `Không kết nối được Gemini: ${e?.cause?.code ?? e?.message ?? e}`);
  } finally {
    clearTimeout(timer);
  }
}

/** Doi loi Gemini -> AppError (thong bao tieng Viet, khong lo khoa) */
export function toAppError(e: unknown): AppError {
  if (e instanceof AppError) return e;
  if (e instanceof GeminiHttpError) {
    console.warn(`[AI] Gemini ${e.status}: ${e.message}`);
    if (e.status === 401 || e.status === 403 || (e.status === 400 && /api key|API_KEY|credential|authenticat/i.test(e.message))) {
      return new AppError(503, 'Khóa Gemini không hợp lệ hoặc chưa được phép dùng Gemini API. Kiểm tra GEMINI_API_KEY trong backend/.env.local.', 'AI_KEY_INVALID');
    }
    if (e.status === 429) return new AppError(429, 'Trợ lý AI đang quá tải (hết lượt gọi Gemini). Vui lòng thử lại sau ít phút.', 'AI_RATE_LIMITED');
    if (e.status === 504) return new AppError(504, 'Trợ lý AI phản hồi quá lâu, vui lòng thử lại.', 'AI_TIMEOUT');
    if (e.status === 503 && /high demand|overload|unavailable/i.test(e.message)) {
      return new AppError(503, 'Gemini đang quá tải (lỗi phía Google). Bạn thử lại sau ít phút nhé.', 'AI_UNAVAILABLE');
    }
    if (e.status === 503) return new AppError(503, 'Không kết nối được dịch vụ AI. Kiểm tra mạng của máy chạy backend.', 'AI_UNAVAILABLE');
    return new AppError(502, 'Dịch vụ AI gặp lỗi, vui lòng thử lại.', 'AI_ERROR');
  }
  console.error('[AI] Unexpected error:', e);
  return new AppError(502, 'Dịch vụ AI gặp lỗi, vui lòng thử lại.', 'AI_ERROR');
}

/* ------------------------------ Chon model ------------------------------ */

const LIST_TTL_MS = 6 * 60 * 60 * 1000;
let listed: { at: number; models: string[] } | null = null;
/** Model goi thanh cong gan nhat -> thu truoc o lan sau */
let working: string | null = null;
/** Model bi tu choi (khong ton tai / khong co quota) -> bo qua 30 phut */
const skipped = new Map<string, number>();
/** Model khong nhan thinkingConfig -> lan sau khong gui */
const noThinking = new Set<string>();

/** Gemini 3+ : them muc suy nghi (low) de tra loi nhanh hon */
function withThinking(model: string, req: GenerateRequest): GenerateRequest {
  if (!env.ai.thinkingLevel || noThinking.has(model) || !/^gemini-([3-9]|\d{2,})/.test(model)) return req;
  return {
    ...req,
    generationConfig: { ...(req.generationConfig ?? {}), thinkingConfig: { thinkingLevel: env.ai.thinkingLevel } },
  };
}

async function availableModels(): Promise<string[]> {
  if (listed && Date.now() - listed.at < LIST_TTL_MS) return listed.models;
  try {
    const r = await call('GET', 'models?pageSize=1000', undefined, 15000);
    const models: string[] = (r.models ?? [])
      .filter((m: any) => (m.supportedGenerationMethods ?? []).includes('generateContent'))
      .map((m: any) => String(m.name).replace(/^models\//, ''));
    listed = { at: Date.now(), models };
    return models;
  } catch (e) {
    if (e instanceof GeminiHttpError && (e.status === 401 || e.status === 403 || e.status === 400)) throw e;
    return []; // khong liet ke duoc -> van thu danh sach mac dinh
  }
}

async function candidateModels(): Promise<string[]> {
  const available = await availableModels();
  const preferred = env.ai.models;
  let order: string[];
  if (available.length === 0) order = preferred;
  else {
    order = preferred.filter((m) => available.includes(m));
    if (order.length === 0) {
      // Khong co model nao trong danh sach uu tien -> lay model "flash" van ban bat ky
      order = available.filter((m) => /flash/.test(m) && !/image|tts|live|audio|transcribe|embedding/.test(m));
    }
    if (order.length === 0) order = preferred;
  }
  if (working && order.includes(working)) order = [working, ...order.filter((m) => m !== working)];
  const now = Date.now();
  const usable = order.filter((m) => (skipped.get(m) ?? 0) < now);
  return usable.length ? usable : order;
}

export const gemini = {
  configured(): boolean {
    return env.ai.geminiApiKey.length > 0;
  },

  status() {
    return {
      configured: this.configured(),
      model: working,
      embeddingModel: env.ai.embeddingModel,
      availableModels: listed?.models.length ?? null,
    };
  },

  /** generateContent - tu chuyen sang model ke tiep neu model hien tai khong dung duoc */
  async generate(req: GenerateRequest, opts: { prefer?: string | null } = {}): Promise<GenerateResult> {
    if (!this.configured()) {
      throw new AppError(503, 'Trợ lý AI chưa được cấu hình: thêm GEMINI_API_KEY vào backend/.env.local rồi khởi động lại backend.', 'AI_NOT_CONFIGURED');
    }
    let models = await candidateModels();
    // Cung 1 cuoc hoi dap nen giu 1 model (chu ky suy nghi cua model nay chi model do doc duoc)
    if (opts.prefer && models.includes(opts.prefer)) models = [opts.prefer, ...models.filter((m) => m !== opts.prefer)];
    let lastError: unknown = null;
    // Thu toi da 3 model / lan goi (tranh 1 cau hoi phai cho qua lau khi Gemini qua tai).
    // Con model du phong thi chi cho toi da 12 giay (model khoe tra loi trong vai giay), lan thu cuoi cho du thoi gian.
    const tries = models.slice(0, 3);
    for (const [i, model] of tries.entries()) {
      const timeoutMs = i < tries.length - 1 ? Math.min(env.ai.timeoutMs, 12_000) : env.ai.timeoutMs;
      try {
        let data: any;
        try {
          data = await call('POST', `models/${encodeURIComponent(model)}:generateContent`, withThinking(model, req), timeoutMs);
        } catch (e) {
          // Model khong ho tro muc suy nghi da chon -> goi lai khong kem thinkingConfig
          if (e instanceof GeminiHttpError && e.status === 400 && /thinking/i.test(e.message) && !noThinking.has(model)) {
            noThinking.add(model);
            data = await call('POST', `models/${encodeURIComponent(model)}:generateContent`, req, timeoutMs);
          } else throw e;
        }
        working = model;
        const cand = data.candidates?.[0];
        return {
          model,
          parts: (cand?.content?.parts ?? []) as GeminiPart[],
          finishReason: cand?.finishReason ?? data.promptFeedback?.blockReason,
          usage: data.usageMetadata,
        };
      } catch (e) {
        lastError = e;
        if (e instanceof GeminiHttpError) {
          const quota = /\[([^\]]*)\]\s*$/.exec(e.message)?.[1];
          console.warn(`[AI] ${model} loi ${e.status}: ${e.message.slice(0, 110)}${quota ? ` [${quota}]` : ''} -> thu model khac`);
        }
        if (e instanceof GeminiHttpError) {
          const modelProblem =
            e.status === 404 || (e.status === 429 && /limit: 0\b/.test(e.message)) || (e.status === 400 && /not supported|not found|unsupported/i.test(e.message));
          if (modelProblem) {
            skipped.set(model, Date.now() + 30 * 60 * 1000);
            if (working === model) working = null;
            continue;
          }
          if (e.status === 429) {
            // Het luot: bo qua model den khi Google cho goi lai (retryDelay), toi da 24 gio;
            // khong co retryDelay: theo ngay -> 1 gio, theo phut -> 1 phut
            const retrySec = Number(/retry (\d+(?:\.\d+)?)s/.exec(e.message)?.[1]);
            const waitMs = Number.isFinite(retrySec) && retrySec > 0
              ? Math.min(Math.max(retrySec, 60), 24 * 3600) * 1000
              : (/per ?day/i.test(e.message) ? 60 : 1) * 60 * 1000;
            skipped.set(model, Date.now() + waitMs);
            if (working === model) working = null;
            continue;
          }
          if (e.status === 504) {
            // Model nay dang cham bat thuong -> tam bo qua 30 phut
            skipped.set(model, Date.now() + 30 * 60 * 1000);
            if (working === model) working = null;
            continue;
          }
          // 503 "high demand": model dang qua tai -> tam bo qua 2 phut, dung model khac
          if (e.status === 503) skipped.set(model, Date.now() + 2 * 60 * 1000);
          if (e.status === 429 || e.status >= 500) continue; // qua tai -> thu model khac
        }
        throw toAppError(e);
      }
    }
    throw toAppError(lastError);
  },

  /**
   * Embedding cho nhieu doan van ban, tra ve vector da chuan hoa (do dai = 1).
   * kind: 'document' (mo ta dia diem) | 'query' (so thich nguoi dung nhap)
   */
  async embed(texts: string[], kind: 'document' | 'query'): Promise<number[][]> {
    if (!this.configured()) throw new AppError(503, 'Chưa cấu hình GEMINI_API_KEY', 'AI_NOT_CONFIGURED');
    if (texts.length === 0) return [];
    const model = env.ai.embeddingModel;
    const v2 = /embedding-2/.test(model);
    const request = (text: string) => {
      const body: Record<string, unknown> = {
        model: `models/${model}`,
        content: { parts: [{ text: v2 ? (kind === 'query' ? `task: search result | query: ${text}` : `title: none | text: ${text}`) : text }] },
        outputDimensionality: env.ai.embeddingDimensions,
      };
      if (!v2) body.taskType = kind === 'query' ? 'RETRIEVAL_QUERY' : 'RETRIEVAL_DOCUMENT';
      return body;
    };
    const out: number[][] = [];
    try {
      for (let i = 0; i < texts.length; i += 50) {
        const chunk = texts.slice(i, i + 50);
        try {
          const r = await call('POST', `models/${encodeURIComponent(model)}:batchEmbedContents`, { requests: chunk.map(request) });
          out.push(...(r.embeddings ?? []).map((e: any) => normalize(e.values ?? [])));
        } catch (e) {
          if (!(e instanceof GeminiHttpError) || ![400, 404].includes(e.status)) throw e;
          // Model khong ho tro batch -> goi tung doan
          for (const t of chunk) {
            const { model: _m, ...single } = request(t);
            const r = await call('POST', `models/${encodeURIComponent(model)}:embedContent`, single);
            out.push(normalize(r.embedding?.values ?? r.embeddings?.[0]?.values ?? []));
          }
        }
      }
    } catch (e) {
      throw toAppError(e);
    }
    if (out.length !== texts.length || out.some((v) => v.length === 0)) {
      throw new AppError(502, 'Gemini trả về embedding không hợp lệ', 'AI_ERROR');
    }
    return out;
  },
};

export function normalize(v: number[]): number[] {
  const n = Math.sqrt(v.reduce((s, x) => s + x * x, 0));
  return n > 0 ? v.map((x) => x / n) : v;
}

/** Hai vector da chuan hoa -> cosine = tich vo huong */
export function cosine(a: number[], b: number[]): number {
  let s = 0;
  const n = Math.min(a.length, b.length);
  for (let i = 0; i < n; i++) s += a[i] * b[i];
  return s;
}
