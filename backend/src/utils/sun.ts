/**
 * Gio mat troi moc / lan trong ngay (thuat toan NOAA rut gon, sai so ~1-2 phut).
 * Dung cho Tro ly AI: "ngam hoang hon o Ho Tay" -> biet hom nay mat troi lan luc may gio.
 */
const RAD = Math.PI / 180;

function fmt(minutes: number) {
  const m = ((Math.round(minutes) % 1440) + 1440) % 1440;
  return `${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`;
}

/**
 * @param date  ngay can tinh
 * @param lat   vi do (do)
 * @param lng   kinh do (do, phia dong la duong)
 * @param tz    mui gio (gio), Ha Noi = 7
 */
export function sunTimes(date: Date, lat: number, lng: number, tz = 7): { sunrise: string; sunset: string } {
  const local = new Date(date.getTime() + tz * 3600_000);
  const dayOfYear = Math.floor((local.getTime() - Date.UTC(local.getUTCFullYear(), 0, 0)) / 86400_000);
  const g = ((2 * Math.PI) / 365) * (dayOfYear - 1); // goc nam (radian), tinh luc giua trua
  const eqTime =
    229.18 *
    (0.000075 + 0.001868 * Math.cos(g) - 0.032077 * Math.sin(g) - 0.014615 * Math.cos(2 * g) - 0.040849 * Math.sin(2 * g));
  const decl =
    0.006918 -
    0.399912 * Math.cos(g) +
    0.070257 * Math.sin(g) -
    0.006758 * Math.cos(2 * g) +
    0.000907 * Math.sin(2 * g) -
    0.002697 * Math.cos(3 * g) +
    0.00148 * Math.sin(3 * g);
  const cosH = Math.cos(90.833 * RAD) / (Math.cos(lat * RAD) * Math.cos(decl)) - Math.tan(lat * RAD) * Math.tan(decl);
  const ha = Math.acos(Math.max(-1, Math.min(1, cosH))) / RAD;
  const noon = 720 - 4 * lng - eqTime + tz * 60;
  return { sunrise: fmt(noon - 4 * ha), sunset: fmt(noon + 4 * ha) };
}
