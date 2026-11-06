/**
 * Ban do Leaflet + OpenStreetMap
 *  - Marker tram theo loai phuong tien (Bus / Metro / Xe dap / Xe dien)
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

  const shownStations = visibleModes ? stations.filter((s) => visibleModes.has(s.mode)) : stations;

  return (
    <MapContainer center={HANOI_CENTER} zoom={14} className={className ?? 'map'} scrollWheelZoom>
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      {onMapClick && <ClickHandler onClick={onMapClick} />}
      <FitTo points={routePoints} focus={focus} />

      {shownStations.map((s) => {
        const m = MODE_META[s.mode];
        return (
          <Marker key={`s-${s.stationId}`} position={[s.latitude, s.longitude]} icon={pinIcon(s.mode, m.icon, m.color, 26)}>
            <Popup>
              <div className="popup">
                <div className="popup-kicker" style={{ color: m.color }}>
                  {m.icon} {m.label} · {s.stationCode}
                </div>
                <strong>{s.stationName}</strong>
                {s.address && <div className="muted">{s.address}</div>}
                {stationPopup?.(s)}
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
