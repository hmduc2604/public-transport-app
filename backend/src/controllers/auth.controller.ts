/** Controller chi: nhan request -> validate -> goi service -> tra response */
import { Request, Response } from 'express';
import { authService } from '../services/auth.service';
import { ok, created } from '../utils/apiResponse';
import { validate } from '../utils/validators';
import { schemas } from '../validations/schemas';

export const authController = {
  async register(req: Request, res: Response) {
    const data = validate<{ fullName: string; email: string; password: string; phone?: string }>(req.body, schemas.register);
    const result = await authService.register(data);
    return created(res, result, 'Register successfully');
  },

  async login(req: Request, res: Response) {
    const { email, password } = validate<{ email: string; password: string }>(req.body, schemas.login);
    return ok(res, await authService.login(email, password), 'Login successfully');
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
