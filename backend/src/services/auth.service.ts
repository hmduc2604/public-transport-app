/** Service: Dang ky / Dang nhap / Ho so (Nguoi 2 - Module Authentication) */
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { userRepository, UserRow } from '../repositories/user.repository';
import { verificationRepository } from '../repositories/verification.repository';
import { notificationService } from './notification.service';
import { AppError } from '../utils/AppError';
import { signToken } from '../middleware/auth.middleware';
import { env } from '../config/env';
import { maskEmail, maskPhone, normalizeVnPhone } from '../utils/phone';

export type VerifyChannel = 'EMAIL' | 'SMS';

interface RegisterPayload {
  fullName: string;
  email: string;
  phone: string;
  passwordHash: string;
}

/** Ma 6 so ngau nhien (crypto, khong dung Math.random) */
const newCode = () => String(crypto.randomInt(0, 10 ** env.otp.length)).padStart(env.otp.length, '0');

/** Chi luu hash cua ma trong DB: sha256(id|ma|secret) */
const hashCode = (verificationId: string, code: string) =>
  crypto.createHash('sha256').update(`${verificationId}|${code}|${env.jwt.secret}`).digest('hex');

const sameHash = (a: string, b: string) =>
  a.length === b.length && crypto.timingSafeEqual(Buffer.from(a, 'hex'), Buffer.from(b, 'hex'));

const SALT_ROUNDS = 10;

function toPublicUser(u: UserRow) {
  return {
    id: u.userId,
    userId: u.userId,
    name: u.fullName,
    fullName: u.fullName,
    email: u.email,
    phone: u.phone,
    emailVerified: Boolean(u.emailVerifiedAt),
    phoneVerified: Boolean(u.phoneVerifiedAt),
    role: u.role,
    status: u.status,
    createdAt: u.createdAt,
  };
}

export const authService = {
  /** Cac kenh nhan ma dang dung duoc (frontend an/hien lua chon) */
  verificationChannels() {
    return {
      email: notificationService.emailConfigured(),
      sms: notificationService.smsConfigured(),
      ttlMinutes: env.otp.ttlMinutes,
      resendSeconds: env.otp.resendSeconds,
    };
  },

  /**
   * Dang ky - buoc 1: kiem tra thong tin, luu tam (chua tao tai khoan) va GUI MA XAC NHAN
   * qua kenh nguoi dung chon (EMAIL hoac SMS).
   */
  async startRegistration(input: { fullName: string; email: string; phone: string; password: string; channel: VerifyChannel }) {
    const phone = normalizeVnPhone(input.phone);
    if (!phone) throw AppError.badRequest('Số điện thoại không hợp lệ (vd: 0912345678)', 'INVALID_PHONE');
    if (await userRepository.findByEmail(input.email)) throw AppError.conflict('Email đã được sử dụng', 'EMAIL_EXISTS');
    if (await userRepository.findByPhone(phone)) throw AppError.conflict('Số điện thoại đã được sử dụng', 'PHONE_EXISTS');

    const destination = input.channel === 'EMAIL' ? input.email : phone;
    if ((await verificationRepository.sendsLastHour(destination)) >= env.otp.maxSendsPerHour) {
      throw new AppError(429, 'Bạn đã yêu cầu quá nhiều mã, vui lòng thử lại sau 1 giờ', 'TOO_MANY_CODES');
    }

    const payload: RegisterPayload = {
      fullName: input.fullName,
      email: input.email,
      phone,
      passwordHash: await bcrypt.hash(input.password, SALT_ROUNDS),
    };
    const verificationId = crypto.randomUUID();
    const code = newCode();

    // Gui truoc, luu sau: gui loi thi khong de lai ban ghi rac
    await this.deliver(input.channel, destination, payload.fullName, code);
    await verificationRepository.create({
      verificationId,
      purpose: 'REGISTER',
      channel: input.channel,
      destination,
      codeHash: hashCode(verificationId, code),
      payload: JSON.stringify(payload),
      ttlMinutes: env.otp.ttlMinutes,
    });
    verificationRepository.cleanup().catch(() => undefined);

    return this.describe(verificationId, input.channel, destination);
  },

  /** Dang ky - gui lai ma (sau resendSeconds giay) */
  async resendRegistrationCode(verificationId: string) {
    const v = await verificationRepository.get(verificationId);
    if (!v || v.purpose !== 'REGISTER' || v.verifiedAt) {
      throw AppError.notFound('Phiên xác nhận không tồn tại hoặc đã hoàn tất, vui lòng đăng ký lại', 'VERIFICATION_NOT_FOUND');
    }
    const wait = env.otp.resendSeconds - v.secondsSinceSent;
    if (wait > 0) throw new AppError(429, `Vui lòng đợi ${wait} giây trước khi gửi lại mã`, 'RESEND_TOO_SOON');
    if ((await verificationRepository.sendsLastHour(v.destination)) >= env.otp.maxSendsPerHour) {
      throw new AppError(429, 'Bạn đã yêu cầu quá nhiều mã, vui lòng thử lại sau 1 giờ', 'TOO_MANY_CODES');
    }
    const payload: RegisterPayload = JSON.parse(v.payload);
    const code = newCode();
    await this.deliver(v.channel, v.destination, payload.fullName, code);
    await verificationRepository.renew(verificationId, hashCode(verificationId, code), env.otp.ttlMinutes);
    return this.describe(verificationId, v.channel, v.destination);
  },

  /** Dang ky - buoc 2: nhap ma dung -> TAO TAI KHOAN trong DB va dang nhap luon */
  async verifyRegistration(verificationId: string, code: string) {
    const v = await verificationRepository.get(verificationId);
    if (!v || v.purpose !== 'REGISTER' || v.verifiedAt) {
      throw AppError.notFound('Phiên xác nhận không tồn tại hoặc đã hoàn tất, vui lòng đăng ký lại', 'VERIFICATION_NOT_FOUND');
    }
    if (v.isExpired) throw AppError.badRequest('Mã xác nhận đã hết hạn, vui lòng bấm "Gửi lại mã"', 'CODE_EXPIRED');
    if (v.attempts >= env.otp.maxAttempts) {
      throw new AppError(429, 'Bạn đã nhập sai quá nhiều lần, vui lòng bấm "Gửi lại mã" để nhận mã mới', 'TOO_MANY_ATTEMPTS');
    }
    if (!sameHash(hashCode(verificationId, code.trim()), v.codeHash)) {
      await verificationRepository.incrementAttempts(verificationId);
      const left = env.otp.maxAttempts - v.attempts - 1;
      throw AppError.badRequest(`Mã xác nhận không đúng${left > 0 ? `, còn ${left} lần thử` : ''}`, 'INVALID_CODE');
    }

    const p: RegisterPayload = JSON.parse(v.payload);
    // Kiem tra lai (co the da co nguoi dang ky trong luc cho xac nhan)
    if (await userRepository.findByEmail(p.email)) throw AppError.conflict('Email đã được sử dụng', 'EMAIL_EXISTS');
    if (await userRepository.findByPhone(p.phone)) throw AppError.conflict('Số điện thoại đã được sử dụng', 'PHONE_EXISTS');

    const now = new Date();
    const userId = await userRepository.create({
      fullName: p.fullName,
      email: p.email,
      phone: p.phone,
      passwordHash: p.passwordHash,
      emailVerifiedAt: v.channel === 'EMAIL' ? now : null,
      phoneVerifiedAt: v.channel === 'SMS' ? now : null,
    });
    await verificationRepository.markVerified(verificationId);

    const user = (await userRepository.findById(userId))!;
    const token = signToken({ userId, email: user.email, role: user.role, fullName: user.fullName });
    return { token, user: toPublicUser(user) };
  },

  async deliver(channel: VerifyChannel, destination: string, fullName: string, code: string) {
    if (channel === 'EMAIL') await notificationService.sendVerificationEmail(destination, fullName, code, env.otp.ttlMinutes);
    else await notificationService.sendVerificationSms(destination, code, env.otp.ttlMinutes);
  },

  describe(verificationId: string, channel: VerifyChannel, destination: string) {
    return {
      verificationId,
      channel,
      destination: channel === 'EMAIL' ? maskEmail(destination) : maskPhone(destination),
      expiresInSeconds: env.otp.ttlMinutes * 60,
      resendInSeconds: env.otp.resendSeconds,
    };
  },

  /** Dang nhap bang email HOAC so dien thoai */
  async login(identifier: string, password: string) {
    const id = identifier.trim();
    const phone = id.includes('@') ? null : normalizeVnPhone(id);
    const user = id.includes('@') ? await userRepository.findByEmail(id.toLowerCase()) : phone ? await userRepository.findByPhone(phone) : null;
    // Thong bao chung chung de khong lo tai khoan nao ton tai
    if (!user || !(await bcrypt.compare(password, user.passwordHash).catch(() => false))) {
      throw AppError.unauthorized('Email/số điện thoại hoặc mật khẩu không đúng', 'INVALID_CREDENTIALS');
    }
    if (user.status === 'LOCKED') {
      throw AppError.forbidden('Tài khoản đã bị khóa, vui lòng liên hệ quản trị viên', 'ACCOUNT_LOCKED');
    }
    const token = signToken({ userId: user.userId, email: user.email, role: user.role, fullName: user.fullName });
    return { token, user: toPublicUser((await userRepository.findById(user.userId))!) };
  },

  async me(userId: number) {
    const user = await userRepository.findById(userId);
    if (!user) throw AppError.notFound('Không tìm thấy người dùng', 'USER_NOT_FOUND');
    return toPublicUser(user);
  },

  async updateProfile(userId: number, data: { fullName?: string; phone?: string | null }) {
    if (data.phone) {
      const phone = normalizeVnPhone(data.phone);
      if (!phone) throw AppError.badRequest('Số điện thoại không hợp lệ (vd: 0912345678)', 'INVALID_PHONE');
      const other = await userRepository.findByPhone(phone);
      if (other && other.userId !== userId) throw AppError.conflict('Số điện thoại đã được sử dụng', 'PHONE_EXISTS');
      const current = await userRepository.findById(userId);
      // Doi so khac -> so moi chua duoc xac nhan
      data = { ...data, phone, ...(current?.phone !== phone ? { phoneVerifiedAt: null } : {}) } as any;
    }
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
