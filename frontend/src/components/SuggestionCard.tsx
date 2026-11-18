/** The dia diem duoc AI goi y: anh, loai, ten, LY DO goi y, gio mo cua / gia ve / khoang cach */
import { Link } from 'react-router-dom';
import { Suggestion } from '../types';
import { categoryIcon } from './AttractionCard';
import { Icon } from './Icon';
import { formatDistance } from '../utils/format';

export function SuggestionCard({ s }: { s: Suggestion }) {
  return (
    <Link to={`/attractions/${s.attractionId}`} className="attraction-card suggestion-card">
      <div className="attraction-media">
        {s.imageUrl ? (
          <img className="cover" src={s.imageUrl} alt={s.name} loading="lazy" />
        ) : (
          <div className="cover cover-placeholder">
            <span>{categoryIcon(s.category, s.name)}</span>
          </div>
        )}
        <span className="media-chip">
          {categoryIcon(s.category, s.name)} {s.category ?? 'Địa điểm'}
        </span>
      </div>
      <div className="attraction-card-body">
        {(s.distanceMeters !== undefined || s.seen) && (
          <div className="attraction-meta">
            {s.distanceMeters !== undefined && <span className="muted small">{formatDistance(s.distanceMeters)}</span>}
            {s.seen && <span className="muted small">Đã xem</span>}
          </div>
        )}
        <h3>{s.name}</h3>
        <p className="suggestion-reason">
          <Icon name="sparkles" size={15} />
          <span className="clamp-3">{s.reason}</span>
        </p>
        <div className="card-foot">
          {s.priceFrom && (
            <span className={`price-tag${s.priceFrom === 'Miễn phí' ? ' free' : ''}`}>
              <Icon name="ticket" size={14} /> {s.priceFrom}
            </span>
          )}
          {s.hoursSummary && (
            <span className="muted small clamp-1 card-hours">
              <Icon name="clock" size={14} /> {s.hoursSummary}
            </span>
          )}
        </div>
      </div>
    </Link>
  );
}
