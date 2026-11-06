/**
 * Chuan hoa response thanh cong theo API contract:
 *   { "success": true, "data": {...}, "message": "Success" }
 */
import { Response } from 'express';

export function ok<T>(res: Response, data: T, message = 'Success', status = 200) {
  return res.status(status).json({ success: true, data, message });
}

export function created<T>(res: Response, data: T, message = 'Created') {
  return ok(res, data, message, 201);
}

export interface Paginated<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export function paginated<T>(items: T[], total: number, page: number, pageSize: number): Paginated<T> {
  return { items, total, page, pageSize, totalPages: Math.max(1, Math.ceil(total / pageSize)) };
}
