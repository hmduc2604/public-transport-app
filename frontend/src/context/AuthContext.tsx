/** Luu trang thai dang nhap toan ung dung (JWT luu trong localStorage) */
import { createContext, ReactNode, useCallback, useContext, useEffect, useMemo, useState } from 'react';
import { RegisterInput, User, VerificationInfo } from '../types';
import { authApi } from '../services/authApi';
import { ApiError, setUnauthorizedHandler, tokenStore } from '../services/api';

interface AuthState {
  user: User | null;
  loading: boolean;
  /** identifier: email hoac so dien thoai */
  login: (identifier: string, password: string) => Promise<User>;
  /** Dang ky buoc 1: gui ma xac nhan (chua tao tai khoan) */
  register: (data: RegisterInput) => Promise<VerificationInfo>;
  /** Dang ky buoc 2: nhap ma dung -> tao tai khoan va dang nhap */
  verifyRegistration: (verificationId: string, code: string) => Promise<User>;
  logout: () => void;
  refresh: () => Promise<void>;
  setUser: (u: User) => void;
}

const AuthContext = createContext<AuthState | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  const logout = useCallback(() => {
    authApi.logout().catch(() => undefined);
    tokenStore.clear();
    setUser(null);
  }, []);

  const refresh = useCallback(async () => {
    if (!tokenStore.get()) {
      setUser(null);
      return;
    }
    try {
      setUser(await authApi.me());
    } catch (e) {
      // Chi dang xuat khi token thuc su sai / het han / tai khoan bi khoa (401).
      // Mat mang hoac backend dang khoi dong lai -> giu token, lan sau thu lai.
      if (e instanceof ApiError && e.status === 401) tokenStore.clear();
      setUser(null);
    }
  }, []);

  useEffect(() => {
    setUnauthorizedHandler(() => {
      tokenStore.clear();
      setUser(null);
    });
    refresh().finally(() => setLoading(false));
  }, [refresh]);

  const value = useMemo<AuthState>(
    () => ({
      user,
      loading,
      setUser,
      logout,
      refresh,
      login: async (identifier, password) => {
        const r = await authApi.login(identifier, password);
        tokenStore.set(r.token);
        setUser(r.user);
        return r.user;
      },
      register: (data) => authApi.register(data),
      verifyRegistration: async (verificationId, code) => {
        const r = await authApi.verifyRegistration(verificationId, code);
        tokenStore.set(r.token);
        setUser(r.user);
        return r.user;
      },
    }),
    [user, loading, logout, refresh],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider');
  return ctx;
}
