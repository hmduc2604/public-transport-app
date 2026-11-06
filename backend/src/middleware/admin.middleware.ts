/**
 * Phan quyen RBAC - dat SAU authenticate.
 *   router.use(authenticate, requireRole('ADMIN'))
 */
import { NextFunction, Request, Response } from 'express';
import { AppError } from '../utils/AppError';

export function requireRole(...roles: Array<'USER' | 'ADMIN'>) {
  return (req: Request, _res: Response, next: NextFunction) => {
    if (!req.user) return next(AppError.unauthorized());
    if (!roles.includes(req.user.role)) {
      return next(AppError.forbidden('Bạn không có quyền truy cập chức năng này', 'FORBIDDEN'));
    }
    next();
  };
}

export const requireAdmin = requireRole('ADMIN');
