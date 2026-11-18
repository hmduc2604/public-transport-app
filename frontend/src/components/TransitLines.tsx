import { MODE_META } from '../utils/modes';

/**
 * Hinh nen o dau trang: 4 tuyen (Bus, Metro, xe dap, xe dien) chay song song kieu so do tau dien,
 * moi tuyen mot mau nhu tren ban do. Ve 1 lan khi mo trang (tat neu nguoi dung giam chuyen dong).
 */
export function TransitLines() {
  const lines = [
    { mode: 'BICYCLE', d: 'M880 -20 V100 L968 188 H1240', cls: 'hl-4' },
    { mode: 'BUS', d: 'M640 -20 V110 L740 210 H1240', cls: '' },
    { mode: 'METRO', d: 'M560 470 L798 232 H1240', cls: 'hl-2' },
    { mode: 'ELECTRIC_VEHICLE', d: 'M760 470 L976 254 H1240', cls: 'hl-3' },
  ] as const;
  return (
    <svg className="hero-lines" viewBox="0 0 1200 440" preserveAspectRatio="xMaxYMid slice" aria-hidden focusable="false">
      {lines.map((l) => (
        <path key={l.mode} className={`hl-path ${l.cls}`} d={l.d} pathLength={1} style={{ stroke: MODE_META[l.mode].color }} />
      ))}
      <rect x="1068" y="176" width="24" height="90" rx="12" className="hl-station" />
      <circle cx="640" cy="40" r="8" />
      <circle cx="880" cy="40" r="8" />
      <circle cx="680" cy="350" r="8" />
      <circle cx="860" cy="370" r="8" />
    </svg>
  );
}
