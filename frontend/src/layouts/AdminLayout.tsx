import { Link, NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const GROUPS = [
  { title: 'Tổng quan', items: [{ to: '/admin', label: '📊 Dashboard', end: true }] },
  {
    title: 'Giao thông',
    items: [
      { to: '/admin/transport-types', label: '🚦 Loại phương tiện' },
      { to: '/admin/vehicles', label: '🚌 Phương tiện' },
      { to: '/admin/stations', label: '🚏 Trạm' },
      { to: '/admin/routes', label: '🛤️ Tuyến' },
      { to: '/admin/schedules', label: '🕒 Lịch trình' },
      { to: '/admin/attractions', label: '📍 Điểm tham quan' },
    ],
  },
  {
    title: 'Vé & Doanh thu',
    items: [
      { to: '/admin/ticket-types', label: '🎫 Loại vé' },
      { to: '/admin/fares', label: '💵 Bảng giá' },
      { to: '/admin/orders', label: '🧾 Đơn hàng' },
      { to: '/admin/tickets', label: '🔍 Vé & Soát vé' },
    ],
  },
  { title: 'Hệ thống', items: [{ to: '/admin/users', label: '👥 Người dùng' }] },
];

export function AdminLayout() {
  const { user } = useAuth();
  return (
    <div className="admin-shell">
      <aside className="admin-side">
        <Link to="/" className="brand brand-light">
          <img src="/favicon.svg" alt="" width={26} height={26} />
          <span>
            Hanoi<b>Go</b> Admin
          </span>
        </Link>
        {GROUPS.map((g) => (
          <div key={g.title} className="admin-group">
            <div className="admin-group-title">{g.title}</div>
            {g.items.map((i) => (
              <NavLink key={i.to} to={i.to} end={(i as any).end} className={({ isActive }) => `admin-link${isActive ? ' active' : ''}`}>
                {i.label}
              </NavLink>
            ))}
          </div>
        ))}
        <div className="admin-side-foot">
          <div className="small">{user?.fullName}</div>
          <Link to="/" className="small">
            ← Về trang người dùng
          </Link>
        </div>
      </aside>
      <main className="admin-main">
        <Outlet />
      </main>
    </div>
  );
}
