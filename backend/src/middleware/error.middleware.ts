/**
 * Xu ly loi tap trung -> luon tra JSON dung API contract:
 *   { "success": false, "message": "...", "errorCode": "..." }
 */
import { NextFunction, Request, Response } from 'express';
import { AppError } from '../utils/AppError';
import { env } from '../config/env';

export function notFoundHandler(req: Request, _res: Response, next: NextFunction) {
  next(AppError.notFound(`Không tìm thấy API: ${req.method} ${req.originalUrl}`, 'API_NOT_FOUND'));
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function errorHandler(err: any, _req: Request, res: Response, _next: NextFunction) {
  // 1. Loi nghiep vu do minh chu dong throw
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
      errorCode: err.errorCode,
      ...(err.details ? { details: err.details } : {}),
    });
  }

  // 2. JSON body sai cu phap
  if (err?.type === 'entity.parse.failed') {
    return res.status(400).json({ success: false, message: 'JSON không hợp lệ', errorCode: 'INVALID_JSON' });
  }

  // 3. Loi tu SQL Server (mssql)
  const sqlNumber: number | undefined = err?.number ?? err?.originalError?.info?.number;
  if (sqlNumber === 2627 || sqlNumber === 2601) {
    return res.status(409).json({
      success: false,
      message: 'Dữ liệu bị trùng (mã/email đã tồn tại)',
      errorCode: 'DUPLICATE_VALUE',
    });
  }
  if (sqlNumber === 547) {
    return res.status(409).json({
      success: false,
      message: 'Không thể thực hiện vì dữ liệu đang được tham chiếu hoặc vi phạm ràng buộc',
      errorCode: 'CONSTRAINT_VIOLATION',
    });
  }
  if (['ELOGIN', 'ESOCKET', 'ETIMEOUT', 'ECONNCLOSED', 'EINSTLOOKUP'].includes(err?.code)) {
    console.error('[DB]', err.message);
    return res.status(503).json({
      success: false,
      message: 'Không kết nối được cơ sở dữ liệu',
      errorCode: 'DB_UNAVAILABLE',
    });
  }

  // 4. Loi khong luong truoc
  console.error('[ERROR]', err);
  return res.status(500).json({
    success: false,
    message: env.nodeEnv === 'production' ? 'Internal Server Error' : err?.message || 'Internal Server Error',
    errorCode: 'INTERNAL_ERROR',
  });
}
