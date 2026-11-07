/** Schema validate du lieu dau vao cho tung API (dung voi utils/validators.validate) */
import { Schema } from '../utils/validators';

const STATUS_ACTIVE = ['ACTIVE', 'INACTIVE'] as const;

export const schemas = {
  /* ---------- Auth ---------- */
  /** Dang ky buoc 1: gui ma xac nhan qua EMAIL hoac SMS */
  register: {
    fullName: { type: 'string', required: true, min: 2, max: 100, label: 'Họ tên' },
    email: { type: 'email', required: true, label: 'Email' },
    phone: { type: 'string', required: true, max: 20, pattern: /^[0-9+\-\s.()]{9,20}$/, label: 'Số điện thoại' },
    password: { type: 'string', required: true, min: 6, max: 100, label: 'Mật khẩu' },
    channel: { type: 'enum', required: true, values: ['EMAIL', 'SMS'], label: 'Cách nhận mã' },
  } as Schema,

  /** Dang ky buoc 2: nhap ma */
  verifyCode: {
    verificationId: { type: 'string', required: true, max: 36, label: 'Phiên xác nhận' },
    code: { type: 'string', required: true, min: 4, max: 10, pattern: /^\d+$/, label: 'Mã xác nhận' },
  } as Schema,

  resendCode: {
    verificationId: { type: 'string', required: true, max: 36, label: 'Phiên xác nhận' },
  } as Schema,

  /** Dang nhap bang email hoac so dien thoai (giu field 'email' cho client cu) */
  login: {
    identifier: { type: 'string', max: 150, label: 'Email hoặc số điện thoại' },
    email: { type: 'string', max: 150, label: 'Email' },
    password: { type: 'string', required: true, label: 'Mật khẩu' },
  } as Schema,

  updateProfile: {
    fullName: { type: 'string', min: 2, max: 100, label: 'Họ tên' },
    phone: { type: 'string', max: 20, pattern: /^[0-9+\-\s.()]{9,20}$/, label: 'Số điện thoại' },
  } as Schema,

  changePassword: {
    currentPassword: { type: 'string', required: true, label: 'Mật khẩu hiện tại' },
    newPassword: { type: 'string', required: true, min: 6, max: 100, label: 'Mật khẩu mới' },
  } as Schema,

  /* ---------- Orders / Payments / History ---------- */
  createOrder: {
    items: { type: 'array', required: true, min: 1, label: 'Danh sách vé' },
  } as Schema,

  payment: {
    orderId: { type: 'number', required: true, integer: true, min: 1, label: 'orderId' },
    method: { type: 'enum', values: ['MOCK'], label: 'Phương thức' },
    simulate: { type: 'enum', values: ['SUCCESS', 'FAILED'], label: 'simulate' },
  } as Schema,

  tripHistory: {
    origin: { type: 'string', required: true, max: 255, label: 'Điểm đi' },
    destination: { type: 'string', required: true, max: 255, label: 'Điểm đến' },
    startedAt: { type: 'string' },
    completedAt: { type: 'string' },
  } as Schema,

  /* ---------- Admin ---------- */
  adminUser: {
    fullName: { type: 'string', min: 2, max: 100, label: 'Họ tên' },
    phone: { type: 'string', max: 20, label: 'Số điện thoại' },
    role: { type: 'enum', values: ['USER', 'ADMIN'], label: 'Vai trò' },
    status: { type: 'enum', values: ['ACTIVE', 'LOCKED'], label: 'Trạng thái' },
  } as Schema,

  transportType: {
    name: { type: 'string', required: true, max: 50, label: 'Tên' },
    description: { type: 'string', max: 255, label: 'Mô tả' },
    status: { type: 'enum', values: STATUS_ACTIVE, label: 'Trạng thái' },
  } as Schema,

  vehicle: {
    transportTypeId: { type: 'number', required: true, integer: true, min: 1, label: 'Loại phương tiện' },
    vehicleCode: { type: 'string', required: true, max: 50, label: 'Mã phương tiện' },
    vehicleName: { type: 'string', max: 100, label: 'Tên phương tiện' },
    capacity: { type: 'number', integer: true, min: 1, max: 5000, label: 'Sức chứa' },
    status: { type: 'enum', values: ['ACTIVE', 'INACTIVE', 'MAINTENANCE'], label: 'Trạng thái' },
  } as Schema,

  station: {
    stationCode: { type: 'string', required: true, max: 50, label: 'Mã trạm' },
    stationName: { type: 'string', required: true, max: 150, label: 'Tên trạm' },
    latitude: { type: 'number', required: true, min: -90, max: 90, label: 'Vĩ độ' },
    longitude: { type: 'number', required: true, min: -180, max: 180, label: 'Kinh độ' },
    address: { type: 'string', max: 255, label: 'Địa chỉ' },
    transportTypeId: { type: 'number', required: true, integer: true, min: 1, label: 'Loại phương tiện' },
    status: { type: 'enum', values: STATUS_ACTIVE, label: 'Trạng thái' },
  } as Schema,

  route: {
    routeCode: { type: 'string', required: true, max: 50, label: 'Mã tuyến' },
    routeName: { type: 'string', required: true, max: 150, label: 'Tên tuyến' },
    transportTypeId: { type: 'number', required: true, integer: true, min: 1, label: 'Loại phương tiện' },
    description: { type: 'string', max: 500, label: 'Mô tả' },
    status: { type: 'enum', values: STATUS_ACTIVE, label: 'Trạng thái' },
    stations: { type: 'array', label: 'Danh sách trạm' },
  } as Schema,

  routeStations: {
    stations: { type: 'array', required: true, min: 2, label: 'Danh sách trạm' },
  } as Schema,

  trip: {
    routeId: { type: 'number', required: true, integer: true, min: 1, label: 'Tuyến' },
    vehicleId: { type: 'number', required: true, integer: true, min: 1, label: 'Phương tiện' },
    tripCode: { type: 'string', required: true, max: 50, label: 'Mã chuyến' },
    departureTime: { type: 'time', required: true, label: 'Giờ xuất phát' },
    arrivalTime: { type: 'time', required: true, label: 'Giờ đến' },
    status: { type: 'enum', values: ['SCHEDULED', 'RUNNING', 'COMPLETED', 'CANCELLED'], label: 'Trạng thái' },
  } as Schema,

  ticketType: {
    name: { type: 'string', required: true, max: 100, label: 'Tên loại vé' },
    transportTypeId: { type: 'number', required: true, integer: true, min: 1, label: 'Loại phương tiện' },
    type: { type: 'enum', required: true, values: ['SINGLE', 'MONTHLY'], label: 'Kiểu vé' },
    price: { type: 'number', required: true, min: 0, max: 100000000, label: 'Giá' },
    durationMinutes: { type: 'number', integer: true, min: 1, label: 'Thời hạn (phút)' },
    description: { type: 'string', max: 500, label: 'Mô tả' },
    status: { type: 'enum', values: STATUS_ACTIVE, label: 'Trạng thái' },
  } as Schema,

  fareRule: {
    transportTypeId: { type: 'number', required: true, integer: true, min: 1, label: 'Loại phương tiện' },
    fromStationId: { type: 'number', required: true, integer: true, min: 1, label: 'Trạm đi' },
    toStationId: { type: 'number', required: true, integer: true, min: 1, label: 'Trạm đến' },
    price: { type: 'number', required: true, min: 0, label: 'Giá' },
  } as Schema,

  attraction: {
    name: { type: 'string', required: true, max: 200, label: 'Tên địa điểm' },
    description: { type: 'string', max: 1000, label: 'Giới thiệu' },
    history: { type: 'string', label: 'Lịch sử' },
    highlights: { type: 'string', label: 'Điểm nổi bật' },
    address: { type: 'string', max: 255, label: 'Địa chỉ' },
    latitude: { type: 'number', required: true, min: -90, max: 90, label: 'Vĩ độ' },
    longitude: { type: 'number', required: true, min: -180, max: 180, label: 'Kinh độ' },
    category: { type: 'string', max: 100, label: 'Loại địa điểm' },
    openingHours: { type: 'string', max: 500, label: 'Giờ mở cửa' },
    ticketPrice: { type: 'string', max: 500, label: 'Giá vé' },
    imageUrl: { type: 'string', max: 500, label: 'Ảnh' },
    imageCredit: { type: 'string', max: 300, label: 'Nguồn ảnh (tác giả / giấy phép)' },
    imageSourceUrl: { type: 'string', max: 500, label: 'Link trang nguồn ảnh' },
    hoursSummary: { type: 'string', max: 100, label: 'Giờ mở cửa (rút gọn)' },
    priceFrom: { type: 'string', max: 50, label: 'Giá vé từ' },
    visitDuration: { type: 'string', max: 100, label: 'Thời gian tham quan' },
    bestTime: { type: 'string', max: 300, label: 'Thời điểm đẹp nhất' },
    tips: { type: 'string', label: 'Lưu ý' },
    imagesText: { type: 'string', label: 'Bộ sưu tập ảnh' },
    popularityScore: { type: 'number', integer: true, min: 0, max: 100, label: 'Điểm nổi bật' },
    status: { type: 'enum', values: STATUS_ACTIVE, label: 'Trạng thái' },
    stations: { type: 'array', label: 'Trạm gần' },
  } as Schema,

  ticketStatus: {
    status: { type: 'enum', required: true, values: ['ACTIVE', 'USED', 'EXPIRED', 'CANCELLED'], label: 'Trạng thái' },
  } as Schema,

  verifyTicket: {
    qrData: { type: 'string', required: true, max: 500, label: 'Nội dung QR' },
    markUsed: { type: 'boolean' },
  } as Schema,
};
