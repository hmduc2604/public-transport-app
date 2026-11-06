/**
 * Boc controller async de loi (throw) duoc chuyen toi error.middleware
 * thay vi lam treo request. Express 4 khong tu bat loi cua Promise.
 */
import { NextFunction, Request, RequestHandler, Response } from 'express';

export const asyncHandler =
  (fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>): RequestHandler =>
  (req, res, next) => {
    fn(req, res, next).catch(next);
  };
