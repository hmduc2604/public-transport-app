/** The dia diem duoc AI goi y: anh, loai, ten, LY DO goi y, gio mo cua / gia ve / khoang cach */
import { Link } from 'react-router-dom';
import { Suggestion } from '../types';
import { categoryIcon } from './AttractionCard';
import { Icon } from './Icon';
import { formatDistance } from '../utils/format';

export function SuggestionCard({ s }: { s: Suggestion }) {
  return (
    <Link to={`/attractions/${s.attractionId}`} className="attraction-card suggestion-card">
      {s.imageUrl ? (
        <img className="cover" src={s.imageUrl} alt={s.name} loading="lazy" />
      ) : (
        <div className="cover cover-placeholder">
          <span>{categoryIcon(s.category, s.name)}</span>
        </div>
      )}
      <div className="attraction-card-body">
        <div className="attraction-meta">
          <span className="chip">
            {categoryIcon(s.category, s.name)} {s.category ?? 'Địa điểm'}
          </span>
          {s.distanceMeters !== undefined && <span className="muted small">{formatDistance(s.distanceMeters)}</span>}
          {s.seen && <span className="muted small">Đã xem</span>}
        </div>
        <h3>{s.name}</h3>
        <p className="suggestion-reason">
          <Icon name="sparkles" size={15} />
          <span className="clamp-3">{s.reason}</span>
        </p>
        <div className="card-foot">
          {s.priceFrom && <span className={`price-tag${s.priceFrom === 'Miễn phí' ? ' free' : ''}`}>🎟 {s.priceFrom}</span>}
          {s.hoursSummary && <span className="muted small clamp-1">🕐 {s.hoursSummary}</span>}
        </div>
      </div>
    </Link>
  );
}
