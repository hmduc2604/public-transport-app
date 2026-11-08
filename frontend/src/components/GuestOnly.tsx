/** Trang danh cho khach (dang nhap / dang ky): da dang nhap thi chuyen ve trang dang dinh xem / trang chu */
import { ReactElement } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export function GuestOnly({ children }: { children: ReactElement }) {
  const { user, loading } = useAuth();
  const location = useLocation();
  if (loading || !user) return children;
  const from = (location.state as { from?: string } | null)?.from;
  return <Navigate to={from || (user.role === 'ADMIN' ? '/admin' : '/')} replace />;
}
