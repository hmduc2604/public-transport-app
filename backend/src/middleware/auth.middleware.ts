/**
 * Xac thuc JWT.
 *   Header: Authorization: Bearer <token>
 *
 * - authenticate : bat buoc dang nhap (401 neu thieu / sai token)
 * - optionalAuth : co token thi gan req.user, khong co van cho qua
 *                  (vd: routing - neu dang nhap se tinh ve thang)
 *
 * Moi request deu doi chieu lai voi bang Users (cache 15 giay): tai khoan bi KHOA
 * hoac bi doi quyen se mat quyen ngay, khong phai doi token het han (7 ngay).
 */
import { NextFunction, Request, Response } from 'express';
import jwt, { SignOptions } from 'jsonwebtoken';
import { env } from '../config/env';
import { AppError } from '../utils/AppError';
import { AuthUser } from '../types/express';
import { userRepository } from '../repositories/user.repository';

const USER_CACHE_MS = 15_000;
const userCache = new Map<number, { at: number; user: AuthUser | null }>();

/** Trang thai / quyen HIEN TAI cua user trong DB (null = khong ton tai hoac da bi khoa) */
async function currentUser(userId: number): Promise<AuthUser | null> {
  const hit = userCache.get(userId);
  if (hit && Date.now() - hit.at < USER_CACHE_MS) return hit.user;
  const u = await userRepository.findById(userId);
  const user = u && u.status === 'ACTIVE' ? { userId: u.userId, email: u.email, role: u.role, fullName: u.fullName } : null;
  if (userCache.size > 5000) userCache.clear();
  userCache.set(userId, { at: Date.now(), user });
  return user;
}

/** Goi khi admin khoa / doi quyen user de co hieu luc ngay */
export function invalidateUserCache(userId: number) {
  userCache.delete(userId);
}

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
  let payload: AuthUser;
  try {
    payload = decode(token);
  } catch (err) {
    return next(err);
  }
  currentUser(payload.userId)
    .then((user) => {
      if (!user) return next(AppError.unauthorized('Tài khoản đã bị khóa hoặc không còn tồn tại', 'ACCOUNT_INACTIVE'));
      req.user = user;
      next();
    })
    .catch(next);
}

export function optionalAuth(req: Request, _res: Response, next: NextFunction) {
  const token = extractToken(req);
  if (!token) return next();
  let payload: AuthUser;
  try {
    payload = decode(token);
  } catch {
    return next(); // token loi -> coi nhu khach, khong chan request
  }
  currentUser(payload.userId)
    .then((user) => {
      if (user) req.user = user;
      next();
    })
    .catch(() => next());
}
