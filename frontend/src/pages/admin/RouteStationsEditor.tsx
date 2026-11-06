/** Sap xep thu tu tram cua 1 tuyen (PUT /admin/routes/:id/stations) */
import { useEffect, useState } from 'react';
import { adminApi } from '../../services/adminApi';
import { errorMessage } from '../../services/api';
import { ErrorBox, Loading } from '../../components/Feedback';
import { Station } from '../../types';

interface Stop {
  stationId: number;
  stationName: string;
  latitude: number;
  longitude: number;
  distanceFromStart: number | null;
}

const haversine = (a: Stop, b: Stop) => {
  const R = 6371000;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(b.latitude - a.latitude);
  const dLng = toRad(b.longitude - a.longitude);
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(a.latitude)) * Math.cos(toRad(b.latitude)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
};

export function RouteStationsEditor({ routeId, onSaved }: { routeId: number; onSaved: () => void }) {
  const [stops, setStops] = useState<Stop[]>([]);
  const [allStations, setAllStations] = useState<Station[]>([]);
  const [toAdd, setToAdd] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    Promise.all([adminApi.routeStations(routeId), adminApi.stations.list()])
      .then(([rs, all]) => {
        setStops(
          rs.map((s: any) => ({
            stationId: s.stationId,
            stationName: s.stationName,
            latitude: s.latitude,
            longitude: s.longitude,
            distanceFromStart: s.distanceFromStart,
          })),
        );
        setAllStations((all as Station[]).filter((s) => s.status === 'ACTIVE'));
      })
      .catch((e) => setError(errorMessage(e)))
      .finally(() => setLoading(false));
  }, [routeId]);

  const move = (i: number, d: -1 | 1) =>
    setStops((s) => {
      const j = i + d;
      if (j < 0 || j >= s.length) return s;
      const next = [...s];
      [next[i], next[j]] = [next[j], next[i]];
      return next;
    });

  const add = () => {
    const st = allStations.find((s) => s.stationId === Number(toAdd));
    if (!st) return;
    setStops((s) => [
      ...s,
      { stationId: st.stationId, stationName: st.stationName, latitude: st.latitude, longitude: st.longitude, distanceFromStart: null },
    ]);
    setToAdd('');
  };

  /** Uoc luong khoang cach = duong chim bay x 1.3 (he so duong vong) */
  const autoDistance = () =>
    setStops((s) => {
      let acc = 0;
      return s.map((st, i) => {
        if (i > 0) acc += haversine(s[i - 1], st) * 1.3;
        return { ...st, distanceFromStart: Math.round(acc / 10) * 10 };
      });
    });

  const save = async () => {
    setSaving(true);
    setError(null);
    try {
      await adminApi.replaceRouteStations(
        routeId,
        stops.map((s) => ({ stationId: s.stationId, distanceFromStart: s.distanceFromStart })),
      );
      onSaved();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <Loading />;

  return (
    <div className="stops-editor">
      <ol className="stops-list">
        {stops.map((s, i) => (
          <li key={`${s.stationId}-${i}`}>
            <span className="stop-order">{i + 1}</span>
            <span className="grow">{s.stationName}</span>
            <input
              className="input input-sm"
              type="number"
              placeholder="m từ đầu tuyến"
              value={s.distanceFromStart ?? ''}
              onChange={(e) =>
                setStops((all) =>
                  all.map((x, j) => (j === i ? { ...x, distanceFromStart: e.target.value === '' ? null : Number(e.target.value) } : x)),
                )
              }
            />
            <button className="icon-btn" onClick={() => move(i, -1)} aria-label="Lên">↑</button>
            <button className="icon-btn" onClick={() => move(i, 1)} aria-label="Xuống">↓</button>
            <button className="icon-btn danger" onClick={() => setStops((all) => all.filter((_, j) => j !== i))} aria-label="Bỏ">
              ✕
            </button>
          </li>
        ))}
      </ol>
      <div className="row gap">
        <select className="input grow" value={toAdd} onChange={(e) => setToAdd(e.target.value)}>
          <option value="">+ Thêm trạm...</option>
          {allStations.map((s) => (
            <option key={s.stationId} value={s.stationId}>
              {s.stationName} ({s.stationCode})
            </option>
          ))}
        </select>
        <button className="btn btn-ghost" onClick={add} disabled={!toAdd}>
          Thêm
        </button>
        <button className="btn btn-ghost" onClick={autoDistance}>
          Tự tính khoảng cách
        </button>
      </div>
      {error && <ErrorBox message={error} />}
      <div className="row gap end">
        <button className="btn btn-primary" onClick={save} disabled={saving || stops.length < 2}>
          {saving ? 'Đang lưu...' : 'Lưu thứ tự trạm'}
        </button>
      </div>
    </div>
  );
}
