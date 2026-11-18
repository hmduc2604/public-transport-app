import { useEffect, useState } from 'react';
import { Link, NavLink, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Icon, IconName } from '../components/Icon';
import { ThemeMenu, UserMenu } from '../components/HeaderMenus';

export function MainLayout() {
  const { user } = useAuth();
  const location = useLocation();
  const [menuOpen, setMenuOpen] = useState(false);

  // Doi trang -> dong menu tren dien thoai
  useEffect(() => setMenuOpen(false), [location.pathname]);

  const nav: { to: string; label: string; icon: IconName; end?: boolean }[] = [
    { to: '/', label: 'Khám phá', icon: 'compass', end: true },
    { to: '/map', label: 'Tìm đường', icon: 'map' },
    { to: '/assistant', label: 'Trợ lý AI', icon: 'sparkles' },
    { to: '/tickets/buy', label: 'Mua vé', icon: 'ticket' },
    ...(user
      ? [
          { to: '/tickets', label: 'Vé của tôi', icon: 'qr' as IconName, end: true },
          { to: '/history', label: 'Lịch sử', icon: 'history' as IconName },
        ]
      : []),
  ];

  return (
    <div className="app-shell">
      <a href="#main" className="skip-link">
        Bỏ qua thanh điều hướng
      </a>
      <header className="topbar">
        <Link to="/" className="brand" aria-label="HanoiGo – trang chủ">
          <img src="/favicon.svg" alt="" width={30} height={30} />
          <span>
            Hanoi<b>Go</b>
          </span>
        </Link>
        <nav className={`nav${menuOpen ? ' open' : ''}`} aria-label="Điều hướng chính" onClick={() => setMenuOpen(false)}>
          {nav.map((n) => (
            <NavLink key={n.to} to={n.to} end={n.end} className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}>
              <Icon name={n.icon} size={18} />
              {n.label}
            </NavLink>
          ))}
          {user?.role === 'ADMIN' && (
            <NavLink to="/admin" className="nav-link nav-admin">
              <Icon name="shield" size={18} />
              Quản trị
            </NavLink>
          )}
        </nav>
        <div className="topbar-tools">
          <ThemeMenu />
          {user ? (
            <UserMenu />
          ) : (
            <>
              <Link to="/login" className="btn btn-sm btn-ghost">
                Đăng nhập
              </Link>
              <Link to="/register" className="btn btn-sm btn-primary hide-xs">
                Đăng ký
              </Link>
            </>
          )}
          <button
            className="icon-btn nav-toggle"
            onClick={() => setMenuOpen((v) => !v)}
            aria-label={menuOpen ? 'Đóng menu' : 'Mở menu'}
            aria-expanded={menuOpen}
          >
            <Icon name={menuOpen ? 'close' : 'menu'} size={22} />
          </button>
        </div>
      </header>
      <main className="main" id="main">
        <Outlet />
      </main>
    </div>
  );
}
