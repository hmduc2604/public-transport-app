/** Menu tren thanh dieu huong: chon giao dien (Sang / Toi / Theo thiet bi) va menu tai khoan */
import { ReactNode, useEffect, useRef, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Icon } from './Icon';
import { THEME_OPTIONS, useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';

/** Mo / dong menu: bam ra ngoai hoac phim Esc thi dong, tra focus ve nut */
function useMenu() {
  const [open, setOpen] = useState(false);
  const wrap = useRef<HTMLDivElement>(null);
  const btn = useRef<HTMLButtonElement>(null);
  useEffect(() => {
    if (!open) return;
    const onDown = (e: MouseEvent | TouchEvent) => {
      if (wrap.current && !wrap.current.contains(e.target as Node)) setOpen(false);
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        setOpen(false);
        btn.current?.focus();
      }
    };
    document.addEventListener('mousedown', onDown);
    document.addEventListener('touchstart', onDown);
    document.addEventListener('keydown', onKey);
    return () => {
      document.removeEventListener('mousedown', onDown);
      document.removeEventListener('touchstart', onDown);
      document.removeEventListener('keydown', onKey);
    };
  }, [open]);
  return { open, setOpen, wrap, btn };
}

function ThemeItems({ onPick }: { onPick?: () => void }) {
  const { pref, setPref } = useTheme();
  return (
    <>
      {THEME_OPTIONS.map((o) => (
        <button
          key={o.value}
          type="button"
          role="menuitemradio"
          aria-checked={pref === o.value}
          className={`menu-item${pref === o.value ? ' on' : ''}`}
          onClick={() => {
            setPref(o.value);
            onPick?.();
          }}
        >
          <Icon name={o.icon} size={18} />
          {o.label}
          {pref === o.value && <Icon name="check" size={16} className="menu-check" />}
        </button>
      ))}
    </>
  );
}

export function ThemeMenu() {
  const { theme } = useTheme();
  const m = useMenu();
  return (
    <div className="menu-wrap" ref={m.wrap}>
      <button
        ref={m.btn}
        type="button"
        className="theme-btn"
        aria-haspopup="menu"
        aria-expanded={m.open}
        aria-label={`Giao diện: ${theme === 'dark' ? 'tối' : 'sáng'}. Đổi giao diện`}
        title="Đổi giao diện sáng / tối"
        onClick={() => m.setOpen((v) => !v)}
      >
        <Icon name={theme === 'dark' ? 'moon' : 'sun'} size={19} />
      </button>
      {m.open && (
        <div className="menu" role="menu" aria-label="Giao diện">
          <div className="menu-label">Giao diện</div>
          <ThemeItems onPick={() => m.setOpen(false)} />
        </div>
      )}
    </div>
  );
}

const initials = (name: string) => {
  const parts = name.trim().split(/\s+/);
  return (parts[parts.length - 1]?.[0] ?? '?').toUpperCase();
};

export function UserMenu() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const m = useMenu();
  if (!user) return null;
  const close = () => m.setOpen(false);
  const item = (to: string, icon: Parameters<typeof Icon>[0]['name'], label: ReactNode) => (
    <Link to={to} role="menuitem" className="menu-item" onClick={close}>
      <Icon name={icon} size={18} />
      {label}
    </Link>
  );
  return (
    <div className="menu-wrap" ref={m.wrap}>
      <button ref={m.btn} type="button" className="menu-btn" aria-haspopup="menu" aria-expanded={m.open} onClick={() => m.setOpen((v) => !v)}>
        <span className="avatar-sm" aria-hidden>
          {initials(user.fullName)}
        </span>
        <span className="menu-name">{user.fullName.split(' ').slice(-1)[0]}</span>
        <Icon name="chevronDown" size={16} />
      </button>
      {m.open && (
        <div className="menu" role="menu" aria-label="Tài khoản">
          <div className="menu-head">
            <strong>{user.fullName}</strong>
            <span className="muted small">{user.email}</span>
          </div>
          {item('/profile', 'user', 'Tài khoản của tôi')}
          {item('/tickets', 'qr', 'Vé của tôi')}
          {item('/history', 'history', 'Lịch sử chuyến đi')}
          {user.role === 'ADMIN' && item('/admin', 'shield', 'Trang quản trị')}
          <div className="menu-sep" />
          <button
            type="button"
            role="menuitem"
            className="menu-item"
            onClick={() => {
              close();
              logout();
              navigate('/');
            }}
          >
            <Icon name="logout" size={18} />
            Đăng xuất
          </button>
        </div>
      )}
    </div>
  );
}

/** Chon giao dien dang 3 nut (trang Tai khoan, thanh ben trang quan tri) */
export function ThemeSwitch({ variant = 'cards' }: { variant?: 'cards' | 'compact' }) {
  const { pref, setPref } = useTheme();
  if (variant === 'compact') {
    return (
      <div className="admin-theme" role="radiogroup" aria-label="Giao diện">
        {THEME_OPTIONS.map((o) => (
          <button key={o.value} type="button" role="radio" aria-checked={pref === o.value} className={pref === o.value ? 'on' : ''} onClick={() => setPref(o.value)} title={o.label}>
            <Icon name={o.icon} size={15} />
            {o.value === 'system' ? 'Tự động' : o.label}
          </button>
        ))}
      </div>
    );
  }
  return (
    <div className="theme-options" role="radiogroup" aria-label="Giao diện">
      {THEME_OPTIONS.map((o) => (
        <button key={o.value} type="button" role="radio" aria-checked={pref === o.value} className={`theme-option${pref === o.value ? ' on' : ''}`} onClick={() => setPref(o.value)}>
          <span className={`theme-swatch ${o.value}`} aria-hidden>
            <i />
            <i />
          </span>
          <span className="theme-option-label">
            <Icon name={o.icon} size={16} />
            {o.label}
          </span>
        </button>
      ))}
    </div>
  );
}
