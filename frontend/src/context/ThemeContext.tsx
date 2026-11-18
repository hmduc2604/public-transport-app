/**
 * Che do giao dien Sang / Toi / Theo thiet bi.
 *  - Luu lua chon o localStorage ('pta_theme'); "Theo thiet bi" = xoa khoa, doc prefers-color-scheme.
 *  - Gan data-theme="light|dark" len <html>; index.css doi bo mau theo thuoc tinh nay.
 *  - index.html co doan script nho gan san data-theme truoc khi React chay -> khong nhay trang khi tai trang.
 */
import { createContext, ReactNode, useCallback, useContext, useEffect, useLayoutEffect, useMemo, useState } from 'react';

export type ThemePref = 'light' | 'dark' | 'system';
export type Theme = 'light' | 'dark';

const KEY = 'pta_theme';
const THEME_COLOR: Record<Theme, string> = { light: '#f5f5f1', dark: '#0c1422' };

function readPref(): ThemePref {
  try {
    const v = localStorage.getItem(KEY);
    return v === 'light' || v === 'dark' ? v : 'system';
  } catch {
    return 'system';
  }
}
const darkQuery = () => (typeof window !== 'undefined' && window.matchMedia ? window.matchMedia('(prefers-color-scheme: dark)') : null);

interface ThemeCtx {
  /** Lua chon cua nguoi dung */
  pref: ThemePref;
  /** Giao dien dang hien thi */
  theme: Theme;
  setPref: (p: ThemePref) => void;
  toggle: () => void;
}

const Ctx = createContext<ThemeCtx | null>(null);

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [pref, setPrefState] = useState<ThemePref>(readPref);
  const [systemDark, setSystemDark] = useState(() => darkQuery()?.matches ?? false);

  useEffect(() => {
    const q = darkQuery();
    if (!q) return;
    const on = (e: MediaQueryListEvent) => setSystemDark(e.matches);
    q.addEventListener?.('change', on);
    return () => q.removeEventListener?.('change', on);
  }, []);

  const theme: Theme = pref === 'system' ? (systemDark ? 'dark' : 'light') : pref;

  useLayoutEffect(() => {
    const root = document.documentElement;
    root.dataset.theme = theme;
    document.querySelector('meta[name="theme-color"]')?.setAttribute('content', THEME_COLOR[theme]);
  }, [theme]);

  const setPref = useCallback((p: ThemePref) => {
    // Chuyen mau nhe khi nguoi dung doi (lop .theme-switching trong index.css)
    const root = document.documentElement;
    root.classList.add('theme-switching');
    window.setTimeout(() => root.classList.remove('theme-switching'), 320);
    setPrefState(p);
    try {
      if (p === 'system') localStorage.removeItem(KEY);
      else localStorage.setItem(KEY, p);
    } catch {
      /* trinh duyet chan localStorage: van doi trong phien hien tai */
    }
  }, []);

  const value = useMemo<ThemeCtx>(
    () => ({ pref, theme, setPref, toggle: () => setPref(theme === 'dark' ? 'light' : 'dark') }),
    [pref, theme, setPref],
  );
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useTheme() {
  const c = useContext(Ctx);
  if (!c) throw new Error('useTheme phai nam trong ThemeProvider');
  return c;
}

export const THEME_OPTIONS: { value: ThemePref; label: string; icon: 'sun' | 'moon' | 'monitor' }[] = [
  { value: 'light', label: 'Sáng', icon: 'sun' },
  { value: 'dark', label: 'Tối', icon: 'moon' },
  { value: 'system', label: 'Theo thiết bị', icon: 'monitor' },
];
