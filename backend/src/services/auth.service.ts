/** Service: Dang ky / Dang nhap / Ho so (Nguoi 2 - Module Authentication) */
import bcrypt from 'bcryptjs';
import { userRepository, UserRow } from '../repositories/user.repository';
import { AppError } from '../utils/AppError';
import { signToken } from '../middleware/auth.middleware';

const SALT_ROUNDS = 10;

function toPublicUser(u: UserRow) {
  return {
    id: u.userId,
    userId: u.userId,
    name: u.fullName,
    fullName: u.fullName,
    email: u.email,
    phone: u.phone,
    role: u.role,
    status: u.status,
    createdAt: u.createdAt,
  };
}

export const authService = {
  async register(input: { fullName: string; email: string; password: string; phone?: string | null }) {
    const existing = await userRepository.findByEmail(input.email);
    if (existing) throw AppError.conflict('Email đã được sử dụng', 'EMAIL_EXISTS');

    const passwordHash = await bcrypt.hash(input.password, SALT_ROUNDS);
    const userId = await userRepository.create({
      fullName: input.fullName,
      email: input.email,
      passwordHash,
      phone: input.phone ?? null,
    });
    const user = (await userRepository.findById(userId))!;
    const token = signToken({ userId, email: user.email, role: user.role, fullName: user.fullName });
    return { token, user: toPublicUser(user) };
  },

  async login(email: string, password: string) {
    const user = await userRepository.findByEmail(email);
    // Thong bao chung chung de khong lo email nao ton tai
    if (!user || !(await bcrypt.compare(password, user.passwordHash).catch(() => false))) {
      throw AppError.unauthorized('Email hoặc mật khẩu không đúng', 'INVALID_CREDENTIALS');
    }
    if (user.status === 'LOCKED') {
      throw AppError.forbidden('Tài khoản đã bị khóa, vui lòng liên hệ quản trị viên', 'ACCOUNT_LOCKED');
    }
    const token = signToken({ userId: user.userId, email: user.email, role: user.role, fullName: user.fullName });
    return { token, user: toPublicUser(user) };
  },

  async me(userId: number) {
    const user = await userRepository.findById(userId);
    if (!user) throw AppError.notFound('Không tìm thấy người dùng', 'USER_NOT_FOUND');
    return toPublicUser(user);
  },

  async updateProfile(userId: number, data: { fullName?: string; phone?: string | null }) {
    await userRepository.update(userId, data);
    return this.me(userId);
  },

  async changePassword(userId: number, currentPassword: string, newPassword: string) {
    const hash = await userRepository.getPasswordHash(userId);
    if (!hash || !(await bcrypt.compare(currentPassword, hash).catch(() => false))) {
      throw AppError.badRequest('Mật khẩu hiện tại không đúng', 'WRONG_PASSWORD');
    }
    await userRepository.update(userId, { passwordHash: await bcrypt.hash(newPassword, SALT_ROUNDS) });
  },

  toPublicUser,
};
