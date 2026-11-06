/** Dinh dang hien thi */
export const formatMoney = (n: number | null | undefined) =>
  n === null || n === undefined ? '—' : `${Math.round(n).toLocaleString('vi-VN')}đ`;

export const formatMinutes = (m: number) => {
  if (m < 60) return `${Math.round(m)} phút`;
  const h = Math.floor(m / 60);
  const r = Math.round(m % 60);
  return r ? `${h} giờ ${r} phút` : `${h} giờ`;
};

export const formatDistance = (m: number) =>
  m < 1000 ? `${Math.round(m)} m` : `${(m / 1000).toFixed(1).replace('.', ',')} km`;

export const formatDateTime = (s: string | null | undefined) =>
  s ? new Date(s).toLocaleString('vi-VN', { hour: '2-digit', minute: '2-digit', day: '2-digit', month: '2-digit', year: 'numeric' }) : '—';

export const formatDate = (s: string | null | undefined) => (s ? new Date(s).toLocaleDateString('vi-VN') : '—');

export const nowHHmm = () => {
  const d = new Date();
  return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
};

export const durationLabel = (minutes: number | null) => {
  if (!minutes) return '';
  if (minutes >= 43200) return `${Math.round(minutes / 1440)} ngày`;
  if (minutes >= 1440) return `${Math.round(minutes / 1440)} ngày`;
  if (minutes >= 60) return `${Math.round(minutes / 60)} giờ`;
  return `${minutes} phút`;
};
