/** Luu trang thai dang nhap toan ung dung (JWT luu trong localStorage) */
import { createContext, ReactNode, useCallback, useContext, useEffect, useMemo, useState } from 'react';
import { User } from '../types';
import { authApi } from '../services/authApi';
import { setUnauthorizedHandler, tokenStore } from '../services/api';

interface AuthState {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<User>;
  register: (data: { fullName: string; email: string; password: string; phone?: string }) => Promise<User>;
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
    } catch {
      tokenStore.clear();
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
      login: async (email, password) => {
        const r = await authApi.login(email, password);
        tokenStore.set(r.token);
        setUser(r.user);
        return r.user;
      },
      register: async (data) => {
        const r = await authApi.register(data);
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
