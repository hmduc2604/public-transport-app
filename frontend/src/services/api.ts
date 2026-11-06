/**
 * HTTP client dung chung: tu gan JWT, tu boc { success, data, message }.
 * Loi tu backend -> throw ApiError (co errorCode de hien thi / xu ly).
 */
import { ApiEnvelope } from '../types';

const BASE_URL = (import.meta.env.VITE_API_URL as string | undefined)?.replace(/\/$/, '') || '/api/v1';
const TOKEN_KEY = 'pta_token';

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public errorCode?: string,
    public details?: Record<string, string>,
  ) {
    super(message);
  }
}

export const tokenStore = {
  get: () => {
    try {
      return localStorage.getItem(TOKEN_KEY);
    } catch {
      return null;
    }
  },
  set: (t: string) => {
    try {
      localStorage.setItem(TOKEN_KEY, t);
    } catch {
      /* ignore */
    }
  },
  clear: () => {
    try {
      localStorage.removeItem(TOKEN_KEY);
    } catch {
      /* ignore */
    }
  },
};

type Query = Record<string, string | number | boolean | undefined | null>;

function buildUrl(path: string, query?: Query) {
  const url = `${BASE_URL}${path}`;
  if (!query) return url;
  const qs = Object.entries(query)
    .filter(([, v]) => v !== undefined && v !== null && v !== '')
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(String(v))}`)
    .join('&');
  return qs ? `${url}?${qs}` : url;
}

let onUnauthorized: (() => void) | null = null;
export function setUnauthorizedHandler(fn: () => void) {
  onUnauthorized = fn;
}

async function request<T>(method: string, path: string, body?: unknown, query?: Query): Promise<T> {
  const headers: Record<string, string> = { Accept: 'application/json' };
  if (body !== undefined) headers['Content-Type'] = 'application/json';
  const token = tokenStore.get();
  if (token) headers.Authorization = `Bearer ${token}`;

  let res: Response;
  try {
    res = await fetch(buildUrl(path, query), {
      method,
      headers,
      body: body !== undefined ? JSON.stringify(body) : undefined,
    });
  } catch {
    throw new ApiError('Không kết nối được máy chủ. Backend đã chạy chưa?', 0, 'NETWORK_ERROR');
  }

  let json: ApiEnvelope<T> | null = null;
  try {
    json = await res.json();
  } catch {
    /* response khong phai JSON */
  }

  if (!res.ok || !json || json.success === false) {
    if (res.status === 401 && token && onUnauthorized) onUnauthorized();
    throw new ApiError(json?.message || `Lỗi ${res.status}`, res.status, json?.errorCode, json?.details);
  }
  return json.data;
}

export const api = {
  get: <T>(path: string, query?: Query) => request<T>('GET', path, undefined, query),
  post: <T>(path: string, body?: unknown) => request<T>('POST', path, body ?? {}),
  put: <T>(path: string, body?: unknown) => request<T>('PUT', path, body ?? {}),
  patch: <T>(path: string, body?: unknown) => request<T>('PATCH', path, body ?? {}),
  delete: <T>(path: string) => request<T>('DELETE', path),
};

export function errorMessage(err: unknown): string {
  if (err instanceof ApiError) {
    if (err.details) return `${err.message}: ${Object.values(err.details).join('; ')}`;
    return err.message;
  }
  return err instanceof Error ? err.message : 'Đã có lỗi xảy ra';
}
