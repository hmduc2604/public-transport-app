/** Controller chi: nhan request -> validate -> goi service -> tra response */
import { Request, Response } from 'express';
import { authService } from '../services/auth.service';
import { ok, created } from '../utils/apiResponse';
import { AppError } from '../utils/AppError';
import { validate } from '../utils/validators';
import { schemas } from '../validations/schemas';

export const authController = {
  /** GET /auth/verification-channels: kenh nhan ma nao dang dung duoc */
  async channels(_req: Request, res: Response) {
    return ok(res, authService.verificationChannels());
  },

  /** POST /auth/register: buoc 1 - gui ma xac nhan (chua tao tai khoan) */
  async register(req: Request, res: Response) {
    const data = validate<{ fullName: string; email: string; phone: string; password: string; channel: 'EMAIL' | 'SMS' }>(
      req.body,
      schemas.register,
    );
    const result = await authService.startRegistration(data);
    const where = data.channel === 'EMAIL' ? 'email' : 'số điện thoại';
    return ok(res, result, `Đã gửi mã xác nhận tới ${where} ${result.destination}`);
  },

  /** POST /auth/register/verify: buoc 2 - nhap ma -> tao tai khoan */
  async verify(req: Request, res: Response) {
    const { verificationId, code } = validate<{ verificationId: string; code: string }>(req.body, schemas.verifyCode);
    return created(res, await authService.verifyRegistration(verificationId, code), 'Đăng ký thành công');
  },

  /** POST /auth/register/resend */
  async resend(req: Request, res: Response) {
    const { verificationId } = validate<{ verificationId: string }>(req.body, schemas.resendCode);
    const result = await authService.resendRegistrationCode(verificationId);
    return ok(res, result, `Đã gửi lại mã tới ${result.destination}`);
  },

  async login(req: Request, res: Response) {
    const { identifier, email, password } = validate<{ identifier?: string; email?: string; password: string }>(
      req.body,
      schemas.login,
    );
    const id = identifier || email;
    if (!id) throw AppError.badRequest('Vui lòng nhập email hoặc số điện thoại', 'VALIDATION_ERROR');
    return ok(res, await authService.login(id, password), 'Login successfully');
  },

  /** JWT stateless: client chi can xoa token. API nay de frontend goi cho dung luong. */
  async logout(_req: Request, res: Response) {
    return ok(res, null, 'Logout successfully');
  },

  async me(req: Request, res: Response) {
    return ok(res, await authService.me(req.user!.userId));
  },

  async updateMe(req: Request, res: Response) {
    const data = validate(req.body, schemas.updateProfile, true);
    return ok(res, await authService.updateProfile(req.user!.userId, data), 'Cập nhật hồ sơ thành công');
  },

  async changePassword(req: Request, res: Response) {
    const { currentPassword, newPassword } = validate<{ currentPassword: string; newPassword: string }>(
      req.body,
      schemas.changePassword,
    );
    await authService.changePassword(req.user!.userId, currentPassword, newPassword);
    return ok(res, null, 'Đổi mật khẩu thành công');
  },
};
