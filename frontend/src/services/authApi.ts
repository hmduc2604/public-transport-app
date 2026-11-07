import { api } from './api';
import { AuthResponse, RegisterInput, User, VerificationChannels, VerificationInfo } from '../types';

export const authApi = {
  /** Dang nhap bang email hoac so dien thoai */
  login: (identifier: string, password: string) => api.post<AuthResponse>('/auth/login', { identifier, password }),
  /** Kenh nhan ma dang dung duoc (email / SMS) */
  channels: () => api.get<VerificationChannels>('/auth/verification-channels'),
  /** Dang ky buoc 1: gui ma xac nhan qua email hoac SMS */
  register: (data: RegisterInput) => api.post<VerificationInfo>('/auth/register', data),
  /** Dang ky buoc 2: nhap ma -> tao tai khoan + token */
  verifyRegistration: (verificationId: string, code: string) =>
    api.post<AuthResponse>('/auth/register/verify', { verificationId, code }),
  resendCode: (verificationId: string) => api.post<VerificationInfo>('/auth/register/resend', { verificationId }),
  logout: () => api.post<null>('/auth/logout'),
  me: () => api.get<User>('/users/me'),
  updateMe: (data: { fullName?: string; phone?: string }) => api.put<User>('/users/me', data),
  changePassword: (currentPassword: string, newPassword: string) =>
    api.put<null>('/users/me/password', { currentPassword, newPassword }),
};
