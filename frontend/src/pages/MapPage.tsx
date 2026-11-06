/**
 * BAN DO + TIM DUONG (UC02 View Transport Map + UC03 Find Route)
 *
 *   Chon diem di (A) + diem den (B)  ->  chon tieu chi  ->  POST /routing/search
 *   ->  hien Top 3 phuong an  ->  chon 1 phuong an  ->  ve tren ban do + chi tiet tung buoc
 *   ->  Luu lich su / Mua ve
 */
import { useCallback, useEffect, useMemo, useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { MapView } from '../components/MapView';
import { LocationPicker, PickedLocation } from '../components/LocationPicker';
import { RouteCard } from '../components/RouteCard';
import { RouteSteps } from '../components/RouteSteps';
import { ErrorBox } from '../components/Feedback';
import { transportApi } from '../services/transportApi';
import { attractionApi } from '../services/attractionApi';
import { routeApi } from '../services/routeApi';
import { ticketApi } from '../services/ticketApi';
import { errorMessage } from '../services/api';
import { useAuth } from '../context/AuthContext';
import { Attraction, RoutePreference, RoutingSearchResult, Station, TransportMode } from '../types';
import { MODE_META, PREFERENCE_META } from '../utils/modes';
import { formatDistance, formatMinutes, formatMoney, nowHHmm } from '../utils/format';

const MODES: TransportMode[] = ['BUS', 'METRO', 'BICYCLE', 'ELECTRIC_VEHICLE'];
const PREFS: RoutePreference[] = ['FASTEST', 'CHEAPEST', 'LEAST_WALKING', 'FEWEST_TRANSFERS'];

const fromStation = (s: Station): PickedLocation => ({
  input: { stationId: s.stationId, name: s.stationName },
  place: { name: s.stationName, latitude: s.latitude, longitude: s.longitude, stationId: s.stationId },
});
const fromAttraction = (a: Attraction): PickedLocation => ({
  input: { attractionId: a.attractionId, name: a.name },
  place: { name: a.name, latitude: a.latitude, longitude: a.longitude },
});

export default function MapPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [params] = useSearchParams();

  const [stations, setStations] = useState<Station[]>([]);
  const [attractions, setAttractions] = useState<Attraction[]>([]);
  const [visibleModes, setVisibleModes] = useState<Set<TransportMode>>(new Set(MODES));
  const [showAttractions, setShowAttractions] = useState(true);

  const [origin, setOrigin] = useState<PickedLocation | null>(null);
  const [destination, setDestination] = useState<PickedLocation | null>(null);
  const [picking, setPicking] = useState<'origin' | 'destination' | null>(null);
  const [preference, setPreference] = useState<RoutePreference>('FASTEST');
  const [departure, setDeparture] = useState(nowHHmm());

  const [result, setResult] = useState<RoutingSearchResult | null>(null);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [searching, setSearching] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [focus, setFocus] = useState<[number, number] | null>(null);
  const [savedMsg, setSavedMsg] = useState<string | null>(null);

  // 1. Tai du lieu ban do
  useEffect(() => {
    Promise.all([transportApi.stations(), attractionApi.list()])
      .then(([s, a]) => {
        setStations(s);
        setAttractions(a);
      })
      .catch((e) => setError(errorMessage(e)));
  }, []);

  // 2. Doc tham so URL: ?to=attraction:11  ?from=station:1  ?focus=attraction:3
  useEffect(() => {
    if (stations.length === 0 && attractions.length === 0) return;
    const resolve = (v: string | null): PickedLocation | null => {
      if (!v) return null;
      const [kind, idStr] = v.split(':');
      const id = Number(idStr);
      if (kind === 'attraction') {
        const a = attractions.find((x) => x.attractionId === id);
        return a ? fromAttraction(a) : null;
      }
      if (kind === 'station') {
        const s = stations.find((x) => x.stationId === id);
        return s ? fromStation(s) : null;
      }
      return null;
    };
    const to = resolve(params.get('to'));
    const from = resolve(params.get('from'));
    const f = resolve(params.get('focus'));
    if (to) setDestination(to);
    if (from) setOrigin(from);
    if (f) setFocus([f.place.latitude, f.place.longitude]);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [stations, attractions]);

  const selected = useMemo(
    () => result?.routes.find((r) => r.id === selectedId) ?? result?.routes[0] ?? null,
    [result, selectedId],
  );

  // 3. Tim duong
  const search = useCallback(
    async (pref: RoutePreference = preference) => {
      if (!origin || !destination) return setError('Hãy chọn điểm đi và điểm đến');
      setSearching(true);
      setError(null);
      setSavedMsg(null);
      try {
        const r = await routeApi.search(origin.input, destination.input, pref, departure);
        setResult(r);
        setSelectedId(r.routes[0]?.id ?? null);
      } catch (e) {
        setResult(null);
        setError(errorMessage(e));
      } finally {
        setSearching(false);
      }
    },
    [origin, destination, preference, departure],
  );

  // Tu dong tim lai khi doi tieu chi (neu da co ket qua)
  const changePreference = (p: RoutePreference) => {
    setPreference(p);
    if (result) search(p);
  };

  const onMapClick = (lat: number, lng: number) => {
    if (!picking) return;
    const v: PickedLocation = {
      input: { latitude: lat, longitude: lng, name: 'Điểm đã chọn' },
      place: { name: `Điểm đã chọn (${lat.toFixed(4)}, ${lng.toFixed(4)})`, latitude: lat, longitude: lng },
    };
    if (picking === 'origin') setOrigin(v);
    else setDestination(v);
    setPicking(null);
  };

  const swap = () => {
    setOrigin(destination);
    setDestination(origin);
    setResult(null);
  };

  const saveTrip = async () => {
    if (!user) return navigate('/login', { state: { from: '/map' } });
    if (!selected || !result) return;
    try {
      await ticketApi.saveTrip({
        origin: result.origin.name,
        destination: result.destination.name,
        routeData: {
          preference: selected.preference,
          route: selected.summary,
          transfers: selected.transfers,
          duration: selected.totalDuration,
          fare: selected.totalFare,
          modes: selected.modes,
        },
      });
      setSavedMsg('Đã lưu vào lịch sử chuyến đi');
    } catch (e) {
      setSavedMsg(errorMessage(e));
    }
  };

  const buyTickets = () => {
    if (!selected) return;
    const modes = selected.modes.filter((m) => m !== 'WALK').join(',');
    navigate(`/tickets/buy?modes=${modes}`);
  };

  const toggleMode = (m: TransportMode) =>
    setVisibleModes((prev) => {
      const next = new Set(prev);
      next.has(m) ? next.delete(m) : next.add(m);
      return next;
    });

  return (
    <div className="map-page">
      <aside className="planner">
        <div className="planner-card">
          <h2 className="planner-title">Tìm lộ trình</h2>
          <LocationPicker
            label="Điểm đi"
            marker="A"
            value={origin}
            onChange={(v) => {
              setOrigin(v);
              setResult(null);
            }}
            stations={stations}
            attractions={attractions}
            onPickOnMap={() => setPicking('origin')}
            picking={picking === 'origin'}
          />
          <button className="swap-btn" onClick={swap} title="Đổi chiều" aria-label="Đổi chiều">
            ⇅
          </button>
          <LocationPicker
            label="Điểm đến"
            marker="B"
            value={destination}
            onChange={(v) => {
              setDestination(v);
              setResult(null);
            }}
            stations={stations}
            attractions={attractions}
            onPickOnMap={() => setPicking('destination')}
            picking={picking === 'destination'}
          />

          <div className="pref-tabs" role="tablist">
            {PREFS.map((p) => (
              <button
                key={p}
                role="tab"
                className={`pref-tab${preference === p ? ' active' : ''}`}
                onClick={() => changePreference(p)}
                title={PREFERENCE_META[p].hint}
              >
                <span>{PREFERENCE_META[p].icon}</span> {PREFERENCE_META[p].label}
              </button>
            ))}
          </div>

          <div className="row gap align-end">
            <label className="field grow">
              <span>Giờ xuất phát</span>
              <input className="input" type="time" value={departure} onChange={(e) => setDeparture(e.target.value)} />
            </label>
            <button className="btn btn-primary" onClick={() => search()} disabled={searching || !origin || !destination}>
              {searching ? 'Đang tìm...' : 'Tìm đường'}
            </button>
          </div>
          {error && <ErrorBox message={error} />}
        </div>

        {result && (
          <div className="planner-results">
            <div className="results-head small muted">
              {result.routes.length} phương án · tính trong {result.stats.computeTimeMs} ms trên graph {result.stats.graphNodes} node
            </div>
            {result.routes.map((r) => (
              <RouteCard key={r.id} route={r} selected={selected?.id === r.id} onSelect={() => setSelectedId(r.id)} />
            ))}
          </div>
        )}

        {selected && result && (
          <div className="planner-card">
            <div className="row space-between">
              <h3>Chi tiết lộ trình</h3>
              <span className="muted small">Khởi hành {result.departureTime}</span>
            </div>
            <div className="summary-grid">
              <div>
                <div className="muted small">Thời gian</div>
                <strong>{formatMinutes(selected.totalDuration)}</strong>
              </div>
              <div>
                <div className="muted small">Chi phí</div>
                <strong>{formatMoney(selected.fareToPay)}</strong>
              </div>
              <div>
                <div className="muted small">Đi bộ</div>
                <strong>{formatDistance(selected.walkingDistance)}</strong>
              </div>
              <div>
                <div className="muted small">Chuyển tuyến</div>
                <strong>{selected.transfers}</strong>
              </div>
            </div>
            <RouteSteps route={selected} originName={result.origin.name} destinationName={result.destination.name} />
            <div className="row gap wrap">
              {selected.modes.some((m) => m !== 'WALK') && (
                <button className="btn btn-accent" onClick={buyTickets}>
                  🎫 Mua vé cho lộ trình
                </button>
              )}
              <button className="btn btn-ghost" onClick={saveTrip}>
                💾 Lưu chuyến đi
              </button>
            </div>
            {savedMsg && (
              <div className="alert alert-info small">
                {savedMsg} {user && <Link to="/history">Xem lịch sử</Link>}
              </div>
            )}
          </div>
        )}
      </aside>

      <section className="map-area">
        <div className="map-legend">
          {MODES.map((m) => (
            <button
              key={m}
              className={`legend-btn${visibleModes.has(m) ? ' on' : ''}`}
              style={{ ['--c' as any]: MODE_META[m].color }}
              onClick={() => toggleMode(m)}
            >
              {MODE_META[m].icon} {MODE_META[m].short}
            </button>
          ))}
          <button className={`legend-btn${showAttractions ? ' on' : ''}`} onClick={() => setShowAttractions((v) => !v)}>
            📍 Địa điểm
          </button>
        </div>
        {picking && <div className="map-picking-banner">Bấm lên bản đồ để chọn {picking === 'origin' ? 'điểm đi' : 'điểm đến'} · <button className="link-btn" onClick={() => setPicking(null)}>Hủy</button></div>}
        <MapView
          className={`map map-full${picking ? ' map-picking' : ''}`}
          stations={stations}
          attractions={attractions}
          visibleModes={visibleModes}
          showAttractions={showAttractions}
          route={selected}
          origin={origin?.place}
          destination={destination?.place}
          focus={focus}
          onMapClick={onMapClick}
          stationPopup={(s) => (
            <div className="popup-actions">
              <button className="btn btn-xs" onClick={() => setOrigin(fromStation(s))}>Đi từ đây</button>
              <button className="btn btn-xs btn-primary" onClick={() => setDestination(fromStation(s))}>Đến đây</button>
            </div>
          )}
          attractionPopup={(a) => (
            <div className="popup-actions">
              <button className="btn btn-xs" onClick={() => setOrigin(fromAttraction(a))}>Đi từ đây</button>
              <button className="btn btn-xs btn-primary" onClick={() => setDestination(fromAttraction(a))}>Đến đây</button>
              <Link to={`/attractions/${a.attractionId}`} className="btn btn-xs btn-ghost">Chi tiết</Link>
            </div>
          )}
        />
      </section>
    </div>
  );
}
