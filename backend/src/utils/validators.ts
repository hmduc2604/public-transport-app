/**
 * Bo validate nho gon (khong dung thu vien ngoai) de de doc va de giai thich.
 * Neu du lieu sai -> throw AppError 400 VALIDATION_ERROR kem danh sach loi.
 */
import { AppError } from './AppError';

export type Rule =
  | { type: 'string'; required?: boolean; min?: number; max?: number; pattern?: RegExp; label?: string }
  | { type: 'number'; required?: boolean; min?: number; max?: number; integer?: boolean; label?: string }
  | { type: 'boolean'; required?: boolean; label?: string }
  | { type: 'enum'; required?: boolean; values: readonly string[]; label?: string }
  | { type: 'email'; required?: boolean; label?: string }
  | { type: 'time'; required?: boolean; label?: string } // HH:mm hoac HH:mm:ss
  | { type: 'array'; required?: boolean; min?: number; label?: string };

export type Schema = Record<string, Rule>;

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const TIME_RE = /^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/;

/**
 * Kiem tra `body` theo `schema`, tra ve object chi chua cac field trong schema
 * (field thua bi loai bo -> tranh mass-assignment, vd: client tu gui Role=ADMIN).
 * partial = true: dung cho PUT/PATCH, bo qua field required.
 */
export function validate<T = Record<string, any>>(body: any, schema: Schema, partial = false): T {
  const errors: Record<string, string> = {};
  const out: Record<string, any> = {};
  const src = body ?? {};

  for (const [key, rule] of Object.entries(schema)) {
    let value = src[key];
    const label = rule.label || key;
    const isEmpty = value === undefined || value === null || value === '';

    if (isEmpty) {
      if (rule.required && !partial) errors[key] = `${label} là bắt buộc`;
      else if (value === null || value === '') out[key] = null; // cho phep xoa gia tri
      continue;
    }

    switch (rule.type) {
      case 'string': {
        if (typeof value !== 'string') value = String(value);
        value = value.trim();
        if (rule.min !== undefined && value.length < rule.min) errors[key] = `${label} tối thiểu ${rule.min} ký tự`;
        else if (rule.max !== undefined && value.length > rule.max) errors[key] = `${label} tối đa ${rule.max} ký tự`;
        else if (rule.pattern && !rule.pattern.test(value)) errors[key] = `${label} không đúng định dạng`;
        break;
      }
      case 'email': {
        value = String(value).trim().toLowerCase();
        if (!EMAIL_RE.test(value)) errors[key] = `${label} không hợp lệ`;
        break;
      }
      case 'number': {
        const n = typeof value === 'number' ? value : Number(value);
        if (!Number.isFinite(n)) errors[key] = `${label} phải là số`;
        else if (rule.integer && !Number.isInteger(n)) errors[key] = `${label} phải là số nguyên`;
        else if (rule.min !== undefined && n < rule.min) errors[key] = `${label} phải >= ${rule.min}`;
        else if (rule.max !== undefined && n > rule.max) errors[key] = `${label} phải <= ${rule.max}`;
        value = n;
        break;
      }
      case 'boolean': {
        if (typeof value === 'string') value = ['true', '1'].includes(value.toLowerCase());
        else value = Boolean(value);
        break;
      }
      case 'enum': {
        value = String(value).toUpperCase();
        if (!rule.values.includes(value)) errors[key] = `${label} phải là một trong: ${rule.values.join(', ')}`;
        break;
      }
      case 'time': {
        value = String(value).trim();
        if (!TIME_RE.test(value)) errors[key] = `${label} phải có dạng HH:mm`;
        break;
      }
      case 'array': {
        if (!Array.isArray(value)) errors[key] = `${label} phải là mảng`;
        else if (rule.min !== undefined && value.length < rule.min) errors[key] = `${label} cần ít nhất ${rule.min} phần tử`;
        break;
      }
    }
    out[key] = value;
  }

  if (Object.keys(errors).length > 0) {
    throw AppError.badRequest('Dữ liệu không hợp lệ', 'VALIDATION_ERROR', errors);
  }
  return out as T;
}

/** Doc :id tu URL, bao loi 400 neu khong phai so nguyen duong */
export function parseId(value: unknown, name = 'id'): number {
  const n = Number(value);
  if (!Number.isInteger(n) || n <= 0) {
    throw AppError.badRequest(`${name} không hợp lệ`, 'INVALID_ID');
  }
  return n;
}

/** Doc tham so phan trang ?page=&pageSize= */
export function parsePagination(query: any, defaultSize = 20) {
  const page = Math.max(1, parseInt(query.page, 10) || 1);
  const pageSize = Math.min(100, Math.max(1, parseInt(query.pageSize, 10) || defaultSize));
  return { page, pageSize, offset: (page - 1) * pageSize };
}

export function optionalNumber(value: unknown): number | undefined {
  if (value === undefined || value === null || value === '') return undefined;
  const n = Number(value);
  return Number.isFinite(n) ? n : undefined;
}

export function optionalString(value: unknown): string | undefined {
  if (typeof value !== 'string') return undefined;
  const s = value.trim();
  return s === '' ? undefined : s;
}
