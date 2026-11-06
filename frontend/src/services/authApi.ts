import { api } from './api';
import { AuthResponse, User } from '../types';

export const authApi = {
  login: (email: string, password: string) => api.post<AuthResponse>('/auth/login', { email, password }),
  register: (data: { fullName: string; email: string; password: string; phone?: string }) =>
    api.post<AuthResponse>('/auth/register', data),
  logout: () => api.post<null>('/auth/logout'),
  me: () => api.get<User>('/users/me'),
  updateMe: (data: { fullName?: string; phone?: string }) => api.put<User>('/users/me', data),
  changePassword: (currentPassword: string, newPassword: string) =>
    api.put<null>('/users/me/password', { currentPassword, newPassword }),
};
