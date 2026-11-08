/**
 * Dinh tuyen frontend (theo tai lieu muc 11 - Frontend routing)
 *
 *  /login /register /  /map  /attractions/:id
 *  /tickets/buy  /payment/:orderId (/card, /transfer)  /tickets  /tickets/:id  /history  /profile
 *  /admin/...
 */
import { ReactElement } from 'react';
import { Navigate, Route, Routes } from 'react-router-dom';
import { MainLayout } from './layouts/MainLayout';
import { AdminLayout } from './layouts/AdminLayout';
import { ProtectedRoute } from './components/ProtectedRoute';
import { LoginRequired } from './components/LoginRequired';
import { GuestOnly } from './components/GuestOnly';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import HomePage from './pages/HomePage';
import AttractionDetailPage from './pages/AttractionDetailPage';
import MapPage from './pages/MapPage';
import BuyTicketPage from './pages/BuyTicketPage';
import PaymentPage from './pages/PaymentPage';
import CardPaymentPage from './pages/CardPaymentPage';
import TransferPaymentPage from './pages/TransferPaymentPage';
import TicketsPage from './pages/TicketsPage';
import TicketDetailPage from './pages/TicketDetailPage';
import HistoryPage from './pages/HistoryPage';
import ProfilePage from './pages/ProfilePage';
import NotFoundPage from './pages/NotFoundPage';
import DashboardPage from './pages/admin/DashboardPage';
import UsersPage from './pages/admin/UsersPage';
import OrdersPage from './pages/admin/OrdersPage';
import TicketsAdminPage from './pages/admin/TicketsAdminPage';
import PaymentsAdminPage from './pages/admin/PaymentsAdminPage';
import {
  AttractionsAdminPage,
  FareRulesPage,
  RoutesPage,
  SchedulesPage,
  StationsPage,
  TicketTypesPage,
  TransportTypesPage,
  VehiclesPage,
} from './pages/admin/ResourcePages';

const auth = (el: ReactElement) => <ProtectedRoute>{el}</ProtectedRoute>;

/** Xem chi tiet dia diem / chi duong: chua dang nhap -> hien thong bao dang nhap hoac dang ky */
const attractionGate = (el: ReactElement) => (
  <LoginRequired
    icon="🏛️"
    title="Đăng nhập để xem thông tin địa điểm"
    message="Thông tin chi tiết địa điểm chỉ dành cho thành viên HanoiGo. Đăng nhập hoặc tạo tài khoản miễn phí để xem tiếp."
    perks={['Giờ mở cửa, giá vé, lưu ý khi tham quan', 'Bộ sưu tập ảnh của địa điểm', 'Trạm xe buýt, Metro, xe đạp gần nhất và chỉ đường đến nơi']}
  >
    {el}
  </LoginRequired>
);
const mapGate = (el: ReactElement) => (
  <LoginRequired
    icon="🧭"
    title="Đăng nhập để dùng bản đồ và chỉ đường"
    message="Tính năng tìm lộ trình chỉ dành cho thành viên HanoiGo. Đăng nhập hoặc tạo tài khoản miễn phí để bắt đầu."
    perks={['Tìm đường bằng xe buýt, Metro, xe đạp, xe điện theo đường phố thật', 'Chọn tiêu chí: nhanh nhất, rẻ nhất, ít đi bộ, ít chuyển tuyến', 'Lưu lịch sử chuyến đi và mua vé ngay trên lộ trình']}
  >
    {el}
  </LoginRequired>
);

export default function App() {
  return (
    <Routes>
      <Route element={<MainLayout />}>
        <Route path="/" element={<HomePage />} />
        <Route path="/home" element={<Navigate to="/" replace />} />
        <Route path="/login" element={<GuestOnly><LoginPage /></GuestOnly>} />
        <Route path="/register" element={<GuestOnly><RegisterPage /></GuestOnly>} />
        <Route path="/map" element={mapGate(<MapPage />)} />
        <Route path="/search" element={<Navigate to="/map" replace />} />
        <Route path="/attractions/:id" element={attractionGate(<AttractionDetailPage />)} />
        <Route path="/tickets/buy" element={<BuyTicketPage />} />
        <Route path="/payment/:orderId" element={auth(<PaymentPage />)} />
        <Route path="/payment/:orderId/card" element={auth(<CardPaymentPage />)} />
        <Route path="/payment/:orderId/transfer" element={auth(<TransferPaymentPage />)} />
        <Route path="/tickets" element={auth(<TicketsPage />)} />
        <Route path="/tickets/:id" element={auth(<TicketDetailPage />)} />
        <Route path="/qr/:id" element={auth(<TicketDetailPage />)} />
        <Route path="/history" element={auth(<HistoryPage />)} />
        <Route path="/profile" element={auth(<ProfilePage />)} />
        <Route path="*" element={<NotFoundPage />} />
      </Route>

      <Route
        path="/admin"
        element={
          <ProtectedRoute adminOnly>
            <AdminLayout />
          </ProtectedRoute>
        }
      >
        <Route index element={<DashboardPage />} />
        <Route path="users" element={<UsersPage />} />
        <Route path="transport-types" element={<TransportTypesPage />} />
        <Route path="transports" element={<Navigate to="/admin/transport-types" replace />} />
        <Route path="vehicles" element={<VehiclesPage />} />
        <Route path="stations" element={<StationsPage />} />
        <Route path="routes" element={<RoutesPage />} />
        <Route path="schedules" element={<SchedulesPage />} />
        <Route path="attractions" element={<AttractionsAdminPage />} />
        <Route path="ticket-types" element={<TicketTypesPage />} />
        <Route path="fares" element={<FareRulesPage />} />
        <Route path="orders" element={<OrdersPage />} />
        <Route path="tickets" element={<TicketsAdminPage />} />
        <Route path="payments" element={<PaymentsAdminPage />} />
      </Route>
    </Routes>
  );
}
