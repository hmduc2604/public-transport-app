/**
 * Xac thuc JWT.
 *   Header: Authorization: Bearer <token>
 *
 * - authenticate : bat buoc dang nhap (401 neu thieu / sai token)
 * - optionalAuth : co token thi gan req.user, khong co van cho qua
 *                  (vd: routing - neu dang nhap se tinh ve thang)
 */
import { NextFunction, Request, Response } from 'express';
import jwt, { SignOptions } from 'jsonwebtoken';
import { env } from '../config/env';
import { AppError } from '../utils/AppError';
import { AuthUser } from '../types/express';

export interface JwtPayload extends AuthUser {
  iat?: number;
  exp?: number;
}

export function signToken(user: AuthUser): string {
  return jwt.sign(
    { userId: user.userId, email: user.email, role: user.role, fullName: user.fullName },
    env.jwt.secret,
    { expiresIn: env.jwt.expiresIn } as SignOptions,
  );
}

function extractToken(req: Request): string | null {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) return null;
  return header.slice(7).trim() || null;
}

function decode(token: string): AuthUser {
  try {
    const payload = jwt.verify(token, env.jwt.secret) as JwtPayload;
    return {
      userId: payload.userId,
      email: payload.email,
      role: payload.role,
      fullName: payload.fullName,
    };
  } catch (err: any) {
    if (err?.name === 'TokenExpiredError') {
      throw AppError.unauthorized('Phiên đăng nhập đã hết hạn', 'TOKEN_EXPIRED');
    }
    throw AppError.unauthorized('Token không hợp lệ', 'INVALID_TOKEN');
  }
}

export function authenticate(req: Request, _res: Response, next: NextFunction) {
  const token = extractToken(req);
  if (!token) return next(AppError.unauthorized('Vui lòng đăng nhập', 'UNAUTHORIZED'));
  try {
    req.user = decode(token);
    next();
  } catch (err) {
    next(err);
  }
}

export function optionalAuth(req: Request, _res: Response, next: NextFunction) {
  const token = extractToken(req);
  if (token) {
    try {
      req.user = decode(token);
    } catch {
      // token loi -> coi nhu khach, khong chan request
    }
  }
  next();
}
