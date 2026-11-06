import { useState } from 'react';
import { Link, NavLink, Outlet, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export function MainLayout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [menuOpen, setMenuOpen] = useState(false);

  const nav = [
    { to: '/', label: 'Khám phá', end: true },
    { to: '/map', label: 'Bản đồ & Tìm đường' },
    { to: '/tickets/buy', label: 'Mua vé' },
    ...(user ? [{ to: '/tickets', label: 'Vé của tôi', end: true }, { to: '/history', label: 'Lịch sử' }] : []),
  ];

  return (
    <div className="app-shell">
      <header className="topbar">
        <Link to="/" className="brand">
          <img src="/favicon.svg" alt="" width={28} height={28} />
          <span>
            Hanoi<b>Go</b>
          </span>
        </Link>
        <button className="icon-btn nav-toggle" onClick={() => setMenuOpen((v) => !v)} aria-label="Menu">
          ☰
        </button>
        <nav className={`nav${menuOpen ? ' open' : ''}`} onClick={() => setMenuOpen(false)}>
          {nav.map((n) => (
            <NavLink key={n.to} to={n.to} end={n.end} className={({ isActive }) => `nav-link${isActive ? ' active' : ''}`}>
              {n.label}
            </NavLink>
          ))}
          {user?.role === 'ADMIN' && (
            <NavLink to="/admin" className="nav-link nav-admin">
              Quản trị
            </NavLink>
          )}
          <div className="nav-user">
            {user ? (
              <>
                <NavLink to="/profile" className="nav-link">
                  👤 {user.fullName.split(' ').slice(-1)[0]}
                </NavLink>
                <button
                  className="btn btn-sm btn-ghost"
                  onClick={() => {
                    logout();
                    navigate('/');
                  }}
                >
                  Đăng xuất
                </button>
              </>
            ) : (
              <>
                <Link to="/login" className="btn btn-sm btn-ghost">
                  Đăng nhập
                </Link>
                <Link to="/register" className="btn btn-sm btn-primary">
                  Đăng ký
                </Link>
              </>
            )}
          </div>
        </nav>
      </header>
      <main className="main">
        <Outlet />
      </main>
    </div>
  );
}
