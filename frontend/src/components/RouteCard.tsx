/** The tom tat 1 phuong an lo trinh: thoi gian, gia, di bo, chuyen tuyen + chuoi phuong tien */
import { RouteResult } from '../types';
import { formatDistance, formatMinutes, formatMoney } from '../utils/format';
import { MODE_META, PREFERENCE_META } from '../utils/modes';

export function RouteCard({ route, selected, onSelect }: { route: RouteResult; selected: boolean; onSelect: () => void }) {
  return (
    <button className={`route-card${selected ? ' selected' : ''}`} onClick={onSelect}>
      <div className="route-card-top">
        <div className="route-time">{formatMinutes(route.totalDuration)}</div>
        <div className="route-price">
          {route.fareToPay < route.totalFare ? (
            <>
              <s className="muted">{formatMoney(route.totalFare)}</s> {formatMoney(route.fareToPay)}
            </>
          ) : (
            formatMoney(route.totalFare)
          )}
        </div>
      </div>
      <div className="route-chain">
        {route.steps.map((s, i) => (
          <span key={i} className="route-chain-item">
            {i > 0 && <span className="chev">›</span>}
            <span className="chain-pill" style={{ borderColor: MODE_META[s.mode].color, color: MODE_META[s.mode].color }}>
              {MODE_META[s.mode].icon} {s.mode === 'WALK' ? `${s.duration}'` : s.routeCode}
            </span>
          </span>
        ))}
      </div>
      <div className="route-facts muted small">
        <span>🚶 {formatDistance(route.walkingDistance)}</span>
        <span>🔁 {route.transfers} lần chuyển</span>
        {route.waitingTime > 0 && <span>⏱ chờ ~{route.waitingTime}'</span>}
      </div>
      {route.labels.length > 0 && (
        <div className="route-labels">
          {route.labels.map((l) => (
            <span key={l} className="label-tag">
              {PREFERENCE_META[l].icon} {PREFERENCE_META[l].label}
            </span>
          ))}
        </div>
      )}
    </button>
  );
}
