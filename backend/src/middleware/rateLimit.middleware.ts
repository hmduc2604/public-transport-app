/**
 * Gioi han tan suat don gian (luu trong RAM) - chong do mat khau / spam gui ma xac nhan.
 *   countWhen: chi dem cac response thoa dieu kien (vd. dang nhap SAI -> 401)
 * Chay 1 tien trinh backend la du; neu chay nhieu tien trinh can chuyen sang Redis.
 */
import { NextFunction, Request, Response } from 'express';

interface Options {
  windowMs: number;
  max: number;
  message: string;
  errorCode?: string;
  /** Khoa phan biet (mac dinh: IP) */
  key?: (req: Request) => string;
  /** Response nao duoc tinh vao gioi han (mac dinh: tat ca) */
  countWhen?: (status: number) => boolean;
}

export function rateLimit(opts: Options) {
  const hits = new Map<string, { count: number; resetAt: number }>();
  const keyOf = opts.key ?? ((req: Request) => req.ip || req.socket.remoteAddress || 'unknown');

  return (req: Request, res: Response, next: NextFunction) => {
    const now = Date.now();
    if (hits.size > 10000) for (const [k, v] of hits) if (v.resetAt <= now) hits.delete(k);
    const key = keyOf(req);
    let entry = hits.get(key);
    if (!entry || entry.resetAt <= now) {
      entry = { count: 0, resetAt: now + opts.windowMs };
      hits.set(key, entry);
    }
    if (entry.count >= opts.max) {
      const retryAfter = Math.ceil((entry.resetAt - now) / 1000);
      res.setHeader('Retry-After', String(retryAfter));
      return res.status(429).json({
        success: false,
        message: `${opts.message} Thử lại sau ${Math.ceil(retryAfter / 60)} phút.`,
        errorCode: opts.errorCode ?? 'TOO_MANY_REQUESTS',
      });
    }
    const e = entry;
    res.on('finish', () => {
      if (!opts.countWhen || opts.countWhen(res.statusCode)) e.count++;
    });
    next();
  };
}
