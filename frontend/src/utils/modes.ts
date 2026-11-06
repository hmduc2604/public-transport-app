/** Mau sac / nhan / bieu tuong cho tung phuong tien (dung chung Map, RouteCard, Ticket) */
import { RoutePreference, TransportMode } from '../types';

export const MODE_META: Record<TransportMode, { label: string; short: string; icon: string; color: string }> = {
  WALK: { label: 'Đi bộ', short: 'Đi bộ', icon: '🚶', color: '#6b7280' },
  BUS: { label: 'Xe buýt', short: 'Bus', icon: '🚌', color: '#1d6fd1' },
  METRO: { label: 'Metro', short: 'Metro', icon: '🚇', color: '#d43f3a' },
  BICYCLE: { label: 'Xe đạp công cộng', short: 'Xe đạp', icon: '🚲', color: '#1e9e5a' },
  ELECTRIC_VEHICLE: { label: 'Xe điện', short: 'Xe điện', icon: '🛺', color: '#8a4fd6' },
};

export const PREFERENCE_META: Record<RoutePreference, { label: string; icon: string; hint: string }> = {
  FASTEST: { label: 'Nhanh nhất', icon: '⚡', hint: 'Tổng thời gian ngắn nhất' },
  CHEAPEST: { label: 'Rẻ nhất', icon: '💰', hint: 'Tổng tiền vé thấp nhất' },
  LEAST_WALKING: { label: 'Ít đi bộ', icon: '🦶', hint: 'Quãng đường đi bộ ngắn nhất' },
  FEWEST_TRANSFERS: { label: 'Ít chuyển tuyến', icon: '🔁', hint: 'Hạn chế đổi phương tiện' },
};

export const STATUS_LABEL: Record<string, string> = {
  ACTIVE: 'Còn hiệu lực',
  USED: 'Đã sử dụng',
  EXPIRED: 'Hết hạn',
  CANCELLED: 'Đã hủy',
  PENDING: 'Chờ thanh toán',
  PAID: 'Đã thanh toán',
  SUCCESS: 'Thành công',
  FAILED: 'Thất bại',
  INACTIVE: 'Ngừng hoạt động',
  LOCKED: 'Đã khóa',
  MAINTENANCE: 'Bảo trì',
  SCHEDULED: 'Theo lịch',
  RUNNING: 'Đang chạy',
  COMPLETED: 'Hoàn thành',
};
