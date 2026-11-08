/**
 * Chan trang khi chua dang nhap: hien thong bao kem nut Dang nhap / Dang ky.
 * Dang nhap / dang ky xong se quay lai dung trang nguoi dung dinh xem.
 * (Khac ProtectedRoute: khong chuyen trang ngay ma giai thich ly do truoc)
 */
import { ReactNode } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Loading } from './Feedback';

interface Props {
  children: ReactNode;
  icon?: string;
  title: string;
  message: string;
  /** Loi ich khi dang nhap (hien dang danh sach) */
  perks?: string[];
}

export function LoginRequired({ children, icon = '🔒', title, message, perks = [] }: Props) {
  const { user, loading } = useAuth();
  const location = useLocation();
  if (loading) return <Loading />;
  if (user) return <>{children}</>;

  const from = location.pathname + location.search;
  return (
    <div className="auth-page">
      <div className="card auth-card login-gate" role="alert">
        <div className="login-gate-icon" aria-hidden>
          {icon}
        </div>
        <h1>{title}</h1>
        <p className="muted">{message}</p>
        {perks.length > 0 && (
          <ul className="login-gate-perks">
            {perks.map((p) => (
              <li key={p}>{p}</li>
            ))}
          </ul>
        )}
        <div className="login-gate-actions">
          <Link to="/login" state={{ from }} className="btn btn-primary btn-block">
            Đăng nhập
          </Link>
          <Link to="/register" state={{ from }} className="btn btn-ghost btn-block">
            Đăng ký tài khoản mới
          </Link>
        </div>
        <Link to="/" className="small login-gate-back">
          ← Quay lại trang Khám phá
        </Link>
      </div>
    </div>
  );
}
