/**
 * O nhap diem di / diem den: goi y tu danh sach diem tham quan + tram,
 * hoac dung vi tri hien tai (GPS), hoac chon tren ban do (o MapPage).
 */
import { useMemo, useRef, useState } from 'react';
import { Attraction, LocationInput, Place, Station } from '../types';
import { MODE_META } from '../utils/modes';
import { categoryIcon } from './AttractionCard';

export interface PickedLocation {
  input: LocationInput;
  place: Place;
}

interface Option {
  key: string;
  label: string;
  sub: string;
  icon: string;
  value: PickedLocation;
}

const normalize = (s: string) =>
  s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/đ/g, 'd');

export function LocationPicker({
  label,
  marker,
  value,
  onChange,
  stations,
  attractions,
  onPickOnMap,
  picking,
}: {
  label: string;
  marker: 'A' | 'B';
  value: PickedLocation | null;
  onChange: (v: PickedLocation | null) => void;
  stations: Station[];
  attractions: Attraction[];
  onPickOnMap?: () => void;
  picking?: boolean;
}) {
  const [text, setText] = useState('');
  const [open, setOpen] = useState(false);
  const [locating, setLocating] = useState(false);
  const blurTimer = useRef<number>();

  const options = useMemo<Option[]>(() => {
    const q = normalize(text.trim());
    const attr: Option[] = attractions.map((a) => ({
      key: `a${a.attractionId}`,
      label: a.name,
      sub: a.category ?? 'Địa điểm',
      icon: categoryIcon(a.category),
      value: {
        input: { attractionId: a.attractionId, name: a.name },
        place: { name: a.name, latitude: a.latitude, longitude: a.longitude },
      },
    }));
    const st: Option[] = stations.map((s) => ({
      key: `s${s.stationId}`,
      label: s.stationName,
      sub: `${MODE_META[s.mode].label} · ${s.stationCode}`,
      icon: MODE_META[s.mode].icon,
      value: {
        input: { stationId: s.stationId, name: s.stationName },
        place: { name: s.stationName, latitude: s.latitude, longitude: s.longitude, stationId: s.stationId },
      },
    }));
    const all = [...attr, ...st];
    if (!q) return all.slice(0, 8);
    return all.filter((o) => normalize(`${o.label} ${o.sub}`).includes(q)).slice(0, 10);
  }, [text, stations, attractions]);

  const useMyLocation = () => {
    if (!navigator.geolocation) return alert('Trình duyệt không hỗ trợ định vị');
    setLocating(true);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setLocating(false);
        const { latitude, longitude } = pos.coords;
        onChange({
          input: { latitude, longitude, name: 'Vị trí của tôi' },
          place: { name: 'Vị trí của tôi', latitude, longitude },
        });
        setOpen(false);
      },
      () => {
        setLocating(false);
        alert('Không lấy được vị trí. Hãy cho phép quyền định vị hoặc chọn trên bản đồ.');
      },
      { enableHighAccuracy: true, timeout: 8000 },
    );
  };

  return (
    <div className="loc-picker">
      <label className="loc-label">
        <span className={`loc-marker loc-marker-${marker}`}>{marker}</span> {label}
      </label>
      {value ? (
        <div className="loc-selected">
          <span className="loc-selected-name">{value.place.name}</span>
          <button className="icon-btn" onClick={() => onChange(null)} aria-label="Bỏ chọn">
            ✕
          </button>
        </div>
      ) : (
        <div className="loc-input-wrap">
          <input
            className="input"
            placeholder="Nhập tên địa điểm hoặc trạm..."
            value={text}
            onChange={(e) => {
              setText(e.target.value);
              setOpen(true);
            }}
            onFocus={() => setOpen(true)}
            onBlur={() => {
              blurTimer.current = window.setTimeout(() => setOpen(false), 150);
            }}
          />
          {open && (
            <ul className="loc-options" onMouseDown={() => window.clearTimeout(blurTimer.current)}>
              <li className="loc-option loc-option-action" onMouseDown={useMyLocation}>
                <span>📡</span>
                <div>
                  <div>{locating ? 'Đang định vị...' : 'Dùng vị trí hiện tại'}</div>
                </div>
              </li>
              {onPickOnMap && (
                <li
                  className="loc-option loc-option-action"
                  onMouseDown={() => {
                    setOpen(false);
                    onPickOnMap();
                  }}
                >
                  <span>🗺️</span>
                  <div>Chọn trên bản đồ</div>
                </li>
              )}
              {options.map((o) => (
                <li
                  key={o.key}
                  className="loc-option"
                  onMouseDown={() => {
                    onChange(o.value);
                    setText('');
                    setOpen(false);
                  }}
                >
                  <span>{o.icon}</span>
                  <div>
                    <div>{o.label}</div>
                    <div className="muted small">{o.sub}</div>
                  </div>
                </li>
              ))}
              {options.length === 0 && <li className="loc-option muted">Không có gợi ý phù hợp</li>}
            </ul>
          )}
        </div>
      )}
      {picking && <div className="hint">👆 Bấm lên bản đồ để chọn {label.toLowerCase()}</div>}
    </div>
  );
}
