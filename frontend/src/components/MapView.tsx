/**
 * Ban do Leaflet + OpenStreetMap
 *  - Marker tram theo loai phuong tien (Bus / Metro / Xe dap / Xe dien)
 *  - Tram xe dap + xe dien CUNG VI TRI -> gop thanh 1 marker (popup liet ke ca 2)
 *  - Marker diem tham quan
 *  - Ve lo trinh (polyline) theo tung buoc, moi phuong tien 1 mau, di bo net dut
 */
import { ReactNode, useEffect, useMemo } from 'react';
import { MapContainer, Marker, Polyline, Popup, TileLayer, useMap, useMapEvents } from 'react-leaflet';
import L from 'leaflet';
import { Attraction, Place, RouteResult, Station, TransportMode } from '../types';
import { MODE_META } from '../utils/modes';
import { categoryIcon } from './AttractionCard';

export const HANOI_CENTER: [number, number] = [21.0315, 105.8455];

const iconCache = new Map<string, L.DivIcon>();
function pinIcon(key: string, emoji: string, color: string, size = 30, extraClass = '') {
  const k = `${key}-${size}-${extraClass}`;
  if (!iconCache.has(k)) {
    iconCache.set(
      k,
      L.divIcon({
        className: 'pin-wrap',
        html: `<div class="pin ${extraClass}" style="background:${color};width:${size}px;height:${size}px;font-size:${Math.round(size * 0.52)}px">${emoji}</div>`,
        iconSize: [size, size],
        iconAnchor: [size / 2, size / 2],
        popupAnchor: [0, -size / 2],
      }),
    );
  }
  return iconCache.get(k)!;
}

/** Marker gop nhieu phuong tien tai cung 1 diem (vd. tram xe dap + xe dien) */
function comboIcon(modes: TransportMode[], size = 30) {
  const key = `combo-${modes.join('+')}-${size}`;
  if (!iconCache.has(key)) {
    const colors = modes.map((m) => MODE_META[m].color);
    const step = 100 / colors.length;
    const bg = `linear-gradient(135deg, ${colors.map((c, i) => `${c} ${i * step}% ${(i + 1) * step}%`).join(', ')})`;
    const icons = modes.map((m) => MODE_META[m].icon).join('');
    iconCache.set(
      key,
      L.divIcon({
        className: 'pin-wrap',
        html: `<div class="pin pin-combo" style="background:${bg};width:${size}px;height:${size}px;font-size:${Math.round(size * 0.36)}px">${icons}</div>`,
        iconSize: [size, size],
        iconAnchor: [size / 2, size / 2],
        popupAnchor: [0, -size / 2],
      }),
    );
  }
  return iconCache.get(key)!;
}

/** Kich thuoc marker: diem dung bus rat day -> nho hon */
const PIN_SIZE: Record<TransportMode, number> = { WALK: 20, BUS: 20, METRO: 28, BICYCLE: 26, ELECTRIC_VEHICLE: 26 };

/** Gom cac tram trung toa do (lam tron ~1m) thanh 1 nhom */
function groupByPosition(stations: Station[]) {
  const groups = new Map<string, Station[]>();
  for (const s of stations) {
    const k = `${s.latitude.toFixed(5)},${s.longitude.toFixed(5)}`;
    if (!groups.has(k)) groups.set(k, []);
    groups.get(k)!.push(s);
  }
  return [...groups.values()];
}

const originIcon = () => pinIcon('origin', 'A', '#13294B', 36, 'pin-endpoint');
const destIcon = () => pinIcon('dest', 'B', '#E0A526', 36, 'pin-endpoint');

function ClickHandler({ onClick }: { onClick: (lat: number, lng: number) => void }) {
  useMapEvents({ click: (e) => onClick(e.latlng.lat, e.latlng.lng) });
  return null;
}

function FitTo({ points, focus }: { points: [number, number][]; focus?: [number, number] | null }) {
  const map = useMap();
  useEffect(() => {
    if (points.length >= 2) map.fitBounds(L.latLngBounds(points), { padding: [48, 48], maxZoom: 16 });
  }, [map, points]);
  useEffect(() => {
    if (focus) map.flyTo(focus, Math.max(map.getZoom(), 16), { duration: 0.6 });
  }, [map, focus]);
  return null;
}

export interface MapViewProps {
  stations?: Station[];
  attractions?: Attraction[];
  visibleModes?: Set<TransportMode>;
  showAttractions?: boolean;
  route?: RouteResult | null;
  origin?: Place | null;
  destination?: Place | null;
  focus?: [number, number] | null;
  onMapClick?: (lat: number, lng: number) => void;
  stationPopup?: (s: Station) => ReactNode;
  attractionPopup?: (a: Attraction) => ReactNode;
  className?: string;
}

export function MapView({
  stations = [],
  attractions = [],
  visibleModes,
  showAttractions = true,
  route,
  origin,
  destination,
  focus,
  onMapClick,
  stationPopup,
  attractionPopup,
  className,
}: MapViewProps) {
  const routePoints = useMemo<[number, number][]>(() => {
    if (!route) {
      const pts: [number, number][] = [];
      if (origin) pts.push([origin.latitude, origin.longitude]);
      if (destination) pts.push([destination.latitude, destination.longitude]);
      return pts;
    }
    return route.steps.flatMap((s) => s.path);
  }, [route, origin, destination]);

  const stationGroups = useMemo(
    () => groupByPosition(visibleModes ? stations.filter((s) => visibleModes.has(s.mode)) : stations),
    [stations, visibleModes],
  );

  return (
    <MapContainer center={HANOI_CENTER} zoom={14} className={className ?? 'map'} scrollWheelZoom>
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      {onMapClick && <ClickHandler onClick={onMapClick} />}
      <FitTo points={routePoints} focus={focus} />

      {stationGroups.map((group) => {
        const first = group[0];
        if (group.length === 1) {
          const m = MODE_META[first.mode];
          return (
            <Marker
              key={`s-${first.stationId}`}
              position={[first.latitude, first.longitude]}
              icon={pinIcon(first.mode, m.icon, m.color, PIN_SIZE[first.mode])}
            >
              <Popup>
                <div className="popup">
                  <div className="popup-kicker" style={{ color: m.color }}>
                    {m.icon} {m.label} · {first.stationCode}
                  </div>
                  <strong>{first.stationName}</strong>
                  {first.address && <div className="muted">{first.address}</div>}
                  {stationPopup?.(first)}
                </div>
              </Popup>
            </Marker>
          );
        }
        // Nhieu phuong tien chung 1 vi tri (tram xe dap + xe dien)
        const modes = [...new Set(group.map((x) => x.mode))];
        return (
          <Marker
            key={`g-${group.map((x) => x.stationId).join('-')}`}
            position={[first.latitude, first.longitude]}
            icon={comboIcon(modes)}
          >
            <Popup>
              <div className="popup">
                <div className="popup-kicker">{modes.map((m) => MODE_META[m].label).join(' + ')} · cùng vị trí</div>
                {first.address && <div className="muted">{first.address}</div>}
                {group.map((x) => (
                  <div key={x.stationId} className="popup-sub">
                    <div className="popup-kicker" style={{ color: MODE_META[x.mode].color }}>
                      {MODE_META[x.mode].icon} {MODE_META[x.mode].label} · {x.stationCode}
                    </div>
                    <strong>{x.stationName}</strong>
                    {stationPopup?.(x)}
                  </div>
                ))}
              </div>
            </Popup>
          </Marker>
        );
      })}

      {showAttractions &&
        attractions.map((a) => (
          <Marker
            key={`a-${a.attractionId}`}
            position={[a.latitude, a.longitude]}
            icon={pinIcon(`attr-${a.category}`, categoryIcon(a.category), '#ffffff', 30, 'pin-attraction')}
          >
            <Popup>
              <div className="popup">
                <div className="popup-kicker">📍 {a.category}</div>
                <strong>{a.name}</strong>
                {a.description && <div className="muted clamp-2">{a.description}</div>}
                {attractionPopup?.(a)}
              </div>
            </Popup>
          </Marker>
        ))}

      {route?.steps.map((step, i) => (
        <Polyline
          key={`${route.id}-${i}`}
          positions={step.path}
          pathOptions={{
            color: MODE_META[step.mode].color,
            weight: step.mode === 'WALK' ? 4 : 7,
            opacity: 0.9,
            dashArray: step.mode === 'WALK' ? '2 10' : undefined,
            lineCap: 'round',
          }}
        />
      ))}

      {route?.steps
        .filter((s) => s.mode !== 'WALK')
        .flatMap((s) => (s.stops ?? []).map((p, j) => ({ p, s, j })))
        .map(({ p, s, j }) => (
          <Marker
            key={`stop-${s.routeCode}-${p.stationId}-${j}`}
            position={[p.latitude, p.longitude]}
            icon={pinIcon(`stop-${s.mode}`, '', MODE_META[s.mode].color, 14, 'pin-stop')}
          >
            <Popup>
              <strong>{p.name}</strong>
              <div className="muted">
                {MODE_META[s.mode].icon} {s.routeCode}
              </div>
            </Popup>
          </Marker>
        ))}

      {origin && (
        <Marker position={[origin.latitude, origin.longitude]} icon={originIcon()} zIndexOffset={1000}>
          <Popup>
            <strong>Điểm đi:</strong> {origin.name}
          </Popup>
        </Marker>
      )}
      {destination && (
        <Marker position={[destination.latitude, destination.longitude]} icon={destIcon()} zIndexOffset={1000}>
          <Popup>
            <strong>Điểm đến:</strong> {destination.name}
          </Popup>
        </Marker>
      )}
    </MapContainer>
  );
}
