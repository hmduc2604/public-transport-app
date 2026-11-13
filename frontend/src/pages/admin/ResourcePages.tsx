/**
 * Cac trang quan tri dung CrudPage (cau hinh cot + truong form).
 * Them 1 bang moi chi can them 1 component nho o day.
 */
import { useState } from 'react';
import { CrudPage, Option } from './CrudPage';
import { adminApi } from '../../services/adminApi';
import { StatusBadge } from '../../components/Feedback';
import { ModeBadge } from '../../components/ModeBadge';
import { Modal } from '../../components/Modal';
import { RouteStationsEditor } from './RouteStationsEditor';
import { formatMoney, durationLabel } from '../../utils/format';
import { STATUS_LABEL } from '../../utils/modes';

/* ---------- Bo nap lua chon dung chung ---------- */
const transportTypeOptions = () =>
  adminApi.transportTypes.list().then((l: any[]) => l.map((t) => ({ value: t.transportTypeId, label: t.name }) as Option));
const stationOptions = () =>
  adminApi.stations
    .list()
    .then((l: any[]) => l.map((s) => ({ value: s.stationId, label: `${s.stationName} (${s.stationCode})` }) as Option));
const routeOptions = () =>
  adminApi.routes.list().then((l: any[]) => l.map((r) => ({ value: r.routeId, label: `${r.routeCode} - ${r.routeName}` }) as Option));
const vehicleOptions = () =>
  adminApi.vehicles
    .list()
    .then((l: any[]) => l.map((v) => ({ value: v.vehicleId, label: `${v.vehicleCode} (${v.transportTypeName})` }) as Option));

const ACTIVE_OPTIONS: Option[] = [
  { value: 'ACTIVE', label: 'Hoạt động' },
  { value: 'INACTIVE', label: 'Ngừng hoạt động' },
];

const status = (row: any) => <StatusBadge status={row.status} label={STATUS_LABEL[row.status] ?? row.status} />;

/* ===================== LOAI PHUONG TIEN ===================== */
export function TransportTypesPage() {
  return (
    <CrudPage
      title="Loại phương tiện"
      subtitle="Bus, Metro, Xe đạp, Xe điện. Xóa = chuyển sang ngừng hoạt động."
      idKey="transportTypeId"
      api={adminApi.transportTypes}
      searchable={false}
      columns={[
        { key: 'transportTypeId', label: 'ID' },
        { key: 'name', label: 'Tên' },
        { key: 'description', label: 'Mô tả' },
        { key: 'stationCount', label: 'Số trạm', className: 'right' },
        { key: 'routeCount', label: 'Số tuyến', className: 'right' },
        { key: 'vehicleCount', label: 'Số xe', className: 'right' },
        { key: 'status', label: 'Trạng thái', render: status },
      ]}
      fields={[
        { name: 'name', label: 'Tên', required: true },
        { name: 'description', label: 'Mô tả' },
        { name: 'status', label: 'Trạng thái', type: 'select', options: ACTIVE_OPTIONS, only: 'edit' },
      ]}
      deleteLabel="Ngừng"
    />
  );
}

/* ===================== PHUONG TIEN ===================== */
export function VehiclesPage() {
  return (
    <CrudPage
      title="Phương tiện"
      idKey="vehicleId"
      api={adminApi.vehicles}
      filters={[
        { name: 'transportTypeId', label: 'Loại', optionsLoader: transportTypeOptions },
        {
          name: 'status',
          label: 'Trạng thái',
          options: [
            { value: 'ACTIVE', label: 'Hoạt động' },
            { value: 'MAINTENANCE', label: 'Bảo trì' },
            { value: 'INACTIVE', label: 'Ngừng' },
          ],
        },
      ]}
      columns={[
        { key: 'vehicleCode', label: 'Mã' },
        { key: 'vehicleName', label: 'Tên' },
        { key: 'transportTypeName', label: 'Loại' },
        { key: 'capacity', label: 'Sức chứa', className: 'right' },
        { key: 'tripCount', label: 'Số chuyến', className: 'right' },
        { key: 'status', label: 'Trạng thái', render: status },
      ]}
      fields={[
        { name: 'vehicleCode', label: 'Mã phương tiện', required: true, placeholder: 'BUS-09' },
        { name: 'vehicleName', label: 'Tên phương tiện' },
        { name: 'transportTypeId', label: 'Loại phương tiện', type: 'select', required: true, optionsLoader: transportTypeOptions },
        { name: 'capacity', label: 'Sức chứa', type: 'number' },
        {
          name: 'status',
          label: 'Trạng thái',
          type: 'select',
          defaultValue: 'ACTIVE',
          options: [
            { value: 'ACTIVE', label: 'Hoạt động' },
            { value: 'MAINTENANCE', label: 'Bảo trì' },
            { value: 'INACTIVE', label: 'Ngừng' },
          ],
        },
      ]}
      deleteConfirm="Xóa phương tiện? (Không xóa được nếu phương tiện đã có chuyến)"
    />
  );
}

/* ===================== TRAM ===================== */
export function StationsPage() {
  return (
    <CrudPage
      title="Trạm"
      subtitle="Thay đổi trạm sẽ tự cập nhật graph tìm đường."
      idKey="stationId"
      api={adminApi.stations}
      filters={[{ name: 'transportTypeId', label: 'Loại', optionsLoader: transportTypeOptions }]}
      columns={[
        { key: 'stationCode', label: 'Mã' },
        { key: 'stationName', label: 'Tên trạm' },
        { key: 'mode', label: 'Loại', render: (r: any) => <ModeBadge mode={r.mode} small /> },
        { key: 'coords', label: 'Tọa độ', render: (r: any) => <span className="mono small">{r.latitude.toFixed(5)}, {r.longitude.toFixed(5)}</span> },
        { key: 'address', label: 'Địa chỉ' },
        { key: 'status', label: 'Trạng thái', render: status },
      ]}
      fields={[
        { name: 'stationCode', label: 'Mã trạm', required: true, placeholder: 'BUS-ST13' },
        { name: 'stationName', label: 'Tên trạm', required: true },
        { name: 'transportTypeId', label: 'Loại phương tiện', type: 'select', required: true, optionsLoader: transportTypeOptions },
        { name: 'latitude', label: 'Vĩ độ (lat)', type: 'number', required: true, placeholder: '21.0285' },
        { name: 'longitude', label: 'Kinh độ (lng)', type: 'number', required: true, placeholder: '105.8542' },
        { name: 'address', label: 'Địa chỉ', full: true },
        { name: 'status', label: 'Trạng thái', type: 'select', options: ACTIVE_OPTIONS, only: 'edit' },
      ]}
      deleteLabel="Ngừng"
    />
  );
}

/* ===================== TUYEN ===================== */
export function RoutesPage() {
  const [editingStops, setEditingStops] = useState<{ routeId: number; routeCode: string; reload: () => void } | null>(null);
  return (
    <>
      <CrudPage
        title="Tuyến"
        subtitle="Bấm “Trạm” để sắp xếp thứ tự các trạm dừng của tuyến."
        idKey="routeId"
        api={adminApi.routes}
        filters={[{ name: 'transportTypeId', label: 'Loại', optionsLoader: transportTypeOptions }]}
        columns={[
          { key: 'routeCode', label: 'Mã', render: (r: any) => <strong>{r.routeCode}</strong> },
          { key: 'routeName', label: 'Tên tuyến' },
          { key: 'mode', label: 'Loại', render: (r: any) => <ModeBadge mode={r.mode} small /> },
          { key: 'ends', label: 'Đầu → Cuối', render: (r: any) => <span className="small">{r.startStationName ?? '—'} → {r.endStationName ?? '—'}</span> },
          { key: 'stopCount', label: 'Trạm', className: 'right' },
          { key: 'tripCount', label: 'Chuyến', className: 'right' },
          { key: 'status', label: 'Trạng thái', render: status },
        ]}
        fields={[
          { name: 'routeCode', label: 'Mã tuyến', required: true, placeholder: 'BUS12' },
          { name: 'routeName', label: 'Tên tuyến', required: true },
          { name: 'transportTypeId', label: 'Loại phương tiện', type: 'select', required: true, optionsLoader: transportTypeOptions },
          { name: 'description', label: 'Mô tả', type: 'textarea' },
          { name: 'status', label: 'Trạng thái', type: 'select', options: ACTIVE_OPTIONS, only: 'edit' },
        ]}
        rowActions={(row: any, reload) => (
          <button className="btn btn-xs btn-ghost" onClick={() => setEditingStops({ routeId: row.routeId, routeCode: row.routeCode, reload })}>
            Trạm
          </button>
        )}
        deleteLabel="Ngừng"
      />
      {editingStops && (
        <Modal title={`Trạm dừng của tuyến ${editingStops.routeCode}`} onClose={() => setEditingStops(null)} wide>
          <RouteStationsEditor
            routeId={editingStops.routeId}
            onSaved={() => {
              editingStops.reload();
              setEditingStops(null);
            }}
          />
        </Modal>
      )}
    </>
  );
}

/* ===================== LICH TRINH (TRIPS) ===================== */
export function SchedulesPage() {
  return (
    <CrudPage
      title="Lịch trình chuyến"
      subtitle="Khi lưu, hệ thống tự sinh giờ đến từng trạm (StopTimes) theo khoảng cách."
      idKey="tripId"
      api={adminApi.trips}
      searchable={false}
      filters={[
        { name: 'routeId', label: 'Tuyến', optionsLoader: routeOptions },
        {
          name: 'status',
          label: 'Trạng thái',
          options: ['SCHEDULED', 'RUNNING', 'COMPLETED', 'CANCELLED'].map((s) => ({ value: s, label: STATUS_LABEL[s] })),
        },
      ]}
      columns={[
        { key: 'tripCode', label: 'Mã chuyến', render: (r: any) => <span className="mono">{r.tripCode}</span> },
        { key: 'routeCode', label: 'Tuyến' },
        { key: 'vehicleCode', label: 'Xe' },
        { key: 'departureTime', label: 'Xuất phát' },
        { key: 'arrivalTime', label: 'Đến nơi' },
        { key: 'status', label: 'Trạng thái', render: status },
      ]}
      fields={[
        { name: 'tripCode', label: 'Mã chuyến', required: true, placeholder: '09A-T051' },
        { name: 'routeId', label: 'Tuyến', type: 'select', required: true, optionsLoader: routeOptions },
        { name: 'vehicleId', label: 'Phương tiện', type: 'select', required: true, optionsLoader: vehicleOptions },
        { name: 'departureTime', label: 'Giờ xuất phát', type: 'time', required: true },
        { name: 'arrivalTime', label: 'Giờ đến', type: 'time', required: true },
        {
          name: 'status',
          label: 'Trạng thái',
          type: 'select',
          defaultValue: 'SCHEDULED',
          options: ['SCHEDULED', 'RUNNING', 'COMPLETED', 'CANCELLED'].map((s) => ({ value: s, label: STATUS_LABEL[s] })),
        },
      ]}
    />
  );
}

/* ===================== LOAI VE ===================== */
export function TicketTypesPage() {
  return (
    <CrudPage
      title="Loại vé"
      idKey="ticketTypeId"
      api={adminApi.ticketTypes}
      searchable={false}
      columns={[
        { key: 'name', label: 'Tên vé', render: (r: any) => <strong>{r.name}</strong> },
        { key: 'transportTypeName', label: 'Phương tiện' },
        { key: 'type', label: 'Kiểu', render: (r: any) => (r.type === 'MONTHLY' ? 'Vé tháng' : 'Vé lượt') },
        { key: 'price', label: 'Giá', className: 'right', render: (r: any) => formatMoney(r.price) },
        { key: 'durationMinutes', label: 'Thời hạn', render: (r: any) => durationLabel(r.durationMinutes) },
        { key: 'status', label: 'Trạng thái', render: status },
      ]}
      fields={[
        { name: 'name', label: 'Tên loại vé', required: true },
        { name: 'transportTypeId', label: 'Phương tiện', type: 'select', required: true, optionsLoader: transportTypeOptions },
        {
          name: 'type',
          label: 'Kiểu vé',
          type: 'select',
          required: true,
          options: [
            { value: 'SINGLE', label: 'Vé lượt' },
            { value: 'MONTHLY', label: 'Vé tháng' },
          ],
        },
        { name: 'price', label: 'Giá (VND)', type: 'number', required: true, step: '1000' },
        { name: 'durationMinutes', label: 'Thời hạn (phút) - vé tháng = 43200', type: 'number' },
        { name: 'description', label: 'Mô tả', type: 'textarea' },
        { name: 'status', label: 'Trạng thái', type: 'select', options: ACTIVE_OPTIONS, only: 'edit' },
      ]}
      deleteLabel="Ngừng bán"
    />
  );
}

/* ===================== BANG GIA (FARE RULES) ===================== */
export function FareRulesPage() {
  return (
    <CrudPage
      title="Bảng giá theo chặng"
      subtitle="Giá cho cặp trạm đi - đến. Cặp chưa có giá sẽ dùng giá mặc định theo phương tiện."
      idKey="fareRuleId"
      api={adminApi.fareRules}
      searchable={false}
      filters={[{ name: 'transportTypeId', label: 'Loại', optionsLoader: transportTypeOptions }]}
      columns={[
        { key: 'transportTypeName', label: 'Phương tiện' },
        { key: 'fromStationName', label: 'Từ trạm' },
        { key: 'toStationName', label: 'Đến trạm' },
        { key: 'price', label: 'Giá', className: 'right', render: (r: any) => formatMoney(r.price) },
      ]}
      fields={[
        { name: 'transportTypeId', label: 'Phương tiện', type: 'select', required: true, optionsLoader: transportTypeOptions },
        { name: 'fromStationId', label: 'Từ trạm', type: 'select', required: true, optionsLoader: stationOptions },
        { name: 'toStationId', label: 'Đến trạm', type: 'select', required: true, optionsLoader: stationOptions },
        { name: 'price', label: 'Giá (VND)', type: 'number', required: true, step: '1000' },
      ]}
    />
  );
}

/* ===================== DIEM THAM QUAN ===================== */
/** "Nhan | Gia tri" moi dong: bo dong trong, chuan hoa khoang trang quanh dau | */
const cleanPairLines = (v: unknown) =>
  typeof v === 'string'
    ? v
        .split(/\r?\n/)
        .map((line) => line.split('|').map((s) => s.trim()).join(' | '))
        .filter((line) => line.replace(/[|\s]/g, '') !== '')
        .join('\n')
    : v;

export function AttractionsAdminPage() {
  return (
    <CrudPage
      title="Điểm tham quan"
      idKey="attractionId"
      api={adminApi.attractions}
      columns={[
        { key: 'name', label: 'Tên', render: (r: any) => <strong>{r.name}</strong> },
        { key: 'category', label: 'Loại' },
        { key: 'popularityScore', label: 'Điểm nổi bật', className: 'right' },
        { key: 'address', label: 'Địa chỉ' },
        { key: 'status', label: 'Trạng thái', render: status },
      ]}
      fields={[
        { name: 'name', label: 'Tên địa điểm', required: true },
        { name: 'category', label: 'Loại (Di tích, Bảo tàng...)' },
        { name: 'latitude', label: 'Vĩ độ', type: 'number', required: true },
        { name: 'longitude', label: 'Kinh độ', type: 'number', required: true },
        { name: 'address', label: 'Địa chỉ', full: true },
        { name: 'description', label: 'Giới thiệu', type: 'textarea' },
        { name: 'history', label: 'Lịch sử', type: 'textarea' },
        { name: 'highlights', label: 'Điểm nổi bật (cách nhau bởi dấu |)', type: 'textarea' },
        { name: 'facts', label: 'Thông tin nhanh — mỗi dòng: Nhãn | Giá trị (vd: Khởi dựng | Năm 1070)', type: 'textarea' },
        { name: 'timeline', label: 'Mốc lịch sử — mỗi dòng: Năm | Sự kiện', type: 'textarea' },
        { name: 'openingHours', label: 'Giờ mở cửa (chi tiết)', type: 'textarea' },
        { name: 'hoursSummary', label: 'Giờ mở cửa (rút gọn, hiện trên thẻ)' },
        { name: 'ticketPrice', label: 'Giá vé (chi tiết)', type: 'textarea' },
        { name: 'priceFrom', label: 'Giá vé từ (vd: 30.000đ, Miễn phí)' },
        { name: 'visitDuration', label: 'Thời gian tham quan gợi ý' },
        { name: 'bestTime', label: 'Thời điểm đẹp nhất' },
        { name: 'tips', label: 'Lưu ý (cách nhau bởi dấu |)', type: 'textarea' },
        { name: 'imageUrl', label: 'Ảnh (URL hoặc /images/attractions/...)' },
        { name: 'imageCredit', label: 'Nguồn ảnh (tác giả / giấy phép)' },
        { name: 'imageSourceUrl', label: 'Link trang nguồn ảnh', full: true },
        {
          name: 'imagesText',
          label: 'Bộ sưu tập ảnh — mỗi dòng: URL | chú thích | tác giả / giấy phép | link nguồn',
          type: 'textarea',
        },
        { name: 'popularityScore', label: 'Điểm nổi bật (0-100)', type: 'number', defaultValue: 50 },
        { name: 'status', label: 'Trạng thái', type: 'select', options: ACTIVE_OPTIONS, only: 'edit' },
      ]}
      toPayload={(data) => ({
        ...data,
        highlights: typeof data.highlights === 'string' ? data.highlights.split('|').map((s: string) => s.trim()).filter(Boolean).join('|') : data.highlights,
        tips: typeof data.tips === 'string' ? data.tips.split('|').map((s: string) => s.trim()).filter(Boolean).join('|') : data.tips,
        facts: cleanPairLines(data.facts),
        timeline: cleanPairLines(data.timeline),
      })}
      deleteLabel="Ẩn"
    />
  );
}
