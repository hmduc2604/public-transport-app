/** Tien ich xu ly thoi gian (mui gio Viet Nam UTC+7) */

/** Gio hien tai o Ha Noi dang 'HH:mm' */
export function currentHanoiTime(date = new Date()): string {
  const parts = new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Asia/Ho_Chi_Minh',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).formatToParts(date);
  const hh = parts.find((p) => p.type === 'hour')?.value ?? '00';
  const mm = parts.find((p) => p.type === 'minute')?.value ?? '00';
  return `${hh === '24' ? '00' : hh}:${mm}`;
}

/**
 * mssql tra cot TIME ve dang Date (ngay 1970-01-01, gio UTC).
 * Ham nay doi ve chuoi 'HH:mm'.
 */
export function formatSqlTime(value: unknown): string | null {
  if (value === null || value === undefined) return null;
  if (value instanceof Date) {
    const hh = String(value.getUTCHours()).padStart(2, '0');
    const mm = String(value.getUTCMinutes()).padStart(2, '0');
    return `${hh}:${mm}`;
  }
  const s = String(value);
  return s.length >= 5 ? s.slice(0, 5) : s;
}

/** 'HH:mm' -> so phut tu 00:00 */
export function timeToMinutes(hhmm: string): number {
  const [h, m] = hhmm.split(':').map(Number);
  return h * 60 + m;
}

/** so phut -> 'HH:mm' (tu dong quay vong qua nua dem) */
export function minutesToTime(total: number): string {
  const t = ((Math.round(total) % 1440) + 1440) % 1440;
  return `${String(Math.floor(t / 60)).padStart(2, '0')}:${String(t % 60).padStart(2, '0')}`;
}
