/** Khung trang Dang nhap / Dang ky: ben trai hinh 4 tuyen + gioi thieu ngan, ben phai la form */
import { ReactNode } from 'react';
import { TransitLines } from './TransitLines';

export function AuthShell({ children }: { children: ReactNode }) {
  return (
    <div className="auth-page">
      <div className="auth-shell">
        <aside className="auth-art">
          <TransitLines />
          <div className="auth-art-text">
            <p className="auth-art-brand">
              Hanoi<b>Go</b>
            </p>
            <h2>Đi khắp Hà Nội bằng giao thông công cộng</h2>
            <p>Tìm đường kết hợp xe buýt, Metro, xe đạp và xe điện, mua vé, lưu lại các chuyến đi trong một tài khoản.</p>
          </div>
        </aside>
        {children}
      </div>
    </div>
  );
}
