/** Chi tiet tung buoc cua lo trinh (timeline) */
import { RouteResult } from '../types';
import { formatDistance, formatMoney } from '../utils/format';
import { MODE_META } from '../utils/modes';

export function RouteSteps({ route, originName, destinationName }: { route: RouteResult; originName: string; destinationName: string }) {
  return (
    <ol className="timeline">
      <li className="tl-point">
        <span className="loc-marker loc-marker-A">A</span>
        <strong>{originName}</strong>
      </li>
      {route.steps.map((s, i) => {
        const m = MODE_META[s.mode];
        return (
          <li key={i} className="tl-step" style={{ ['--c' as any]: m.color }}>
            <div className="tl-line" data-walk={s.mode === 'WALK'} />
            <div className="tl-body">
              <div className="tl-title">
                <span className="tl-icon" style={{ background: m.color }}>
                  {m.icon}
                </span>
                <span>{s.instruction}</span>
              </div>
              <div className="tl-meta muted small">
                <span>{s.duration} phút</span>
                <span>{formatDistance(s.distance)}</span>
                {s.waitTime ? <span>chờ ~{s.waitTime} phút</span> : null}
                {s.mode !== 'WALK' && (
                  <span>{s.coveredByPass ? '🎫 Vé tháng' : formatMoney(s.fare)}</span>
                )}
              </div>
              {s.nextDepartures && s.nextDepartures.length > 0 && (
                <div className="tl-departures small">
                  Chuyến tới tại {s.from.name}:{' '}
                  {s.nextDepartures.map((t) => (
                    <span key={t} className="time-chip">
                      {t}
                    </span>
                  ))}
                </div>
              )}
              {s.stops && s.stops.length > 2 && (
                <details className="tl-stops small">
                  <summary>{s.stops.length - 2} trạm dừng giữa</summary>
                  <ul>
                    {s.stops.slice(1, -1).map((p, j) => (
                      <li key={j}>{p.name}</li>
                    ))}
                  </ul>
                </details>
              )}
            </div>
          </li>
        );
      })}
      <li className="tl-point">
        <span className="loc-marker loc-marker-B">B</span>
        <strong>{destinationName}</strong>
      </li>
    </ol>
  );
}
