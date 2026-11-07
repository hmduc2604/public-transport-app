import { Link } from 'react-router-dom';
import { Attraction } from '../types';
import { formatDistance } from '../utils/format';

const CATEGORY_ICON: Record<string, string> = {
  'Danh thắng': '🏞️',
  'Di tích': '🏯',
  'Di sản': '🏛️',
  'Bảo tàng': '🖼️',
  'Tôn giáo': '🛕',
  'Khu phố': '🏮',
  'Chợ': '🧺',
  'Kiến trúc': '🌉',
  'Quảng trường': '🚩',
  'Văn hóa': '📚',
  'Nghệ thuật': '🎭',
};

export const categoryIcon = (c?: string | null) => (c && CATEGORY_ICON[c]) || '📍';

/** Anh dai dien: neu chua co ImageUrl thi ve nen mau theo loai dia diem */
export function AttractionCover({ a, tall }: { a: Attraction; tall?: boolean }) {
  if (a.imageUrl) {
    return <img className={`cover${tall ? ' cover-tall' : ''}`} src={a.imageUrl} alt={a.name} loading="lazy" />;
  }
  const hue = [...(a.category ?? a.name)].reduce((h, ch) => (h * 31 + ch.charCodeAt(0)) % 360, 7);
  return (
    <div
      className={`cover cover-placeholder${tall ? ' cover-tall' : ''}`}
      style={{ background: `linear-gradient(135deg, hsl(${hue} 32% 30%), hsl(${(hue + 35) % 360} 38% 44%))` }}
    >
      <span>{categoryIcon(a.category)}</span>
    </div>
  );
}

export function AttractionCard({ a }: { a: Attraction }) {
  return (
    <Link to={`/attractions/${a.attractionId}`} className="attraction-card">
      <AttractionCover a={a} />
      <div className="attraction-card-body">
        <div className="attraction-meta">
          <span className="chip">{categoryIcon(a.category)} {a.category ?? 'Địa điểm'}</span>
          {a.distanceMeters !== undefined && <span className="muted">{formatDistance(a.distanceMeters)}</span>}
          {a.score !== undefined && <span className="muted">★ {a.score}</span>}
        </div>
        <h3>{a.name}</h3>
        <p className="muted clamp-2">{a.description}</p>
        <ul className="card-facts">
          {a.address && <li title="Địa chỉ">📍 <span className="clamp-1">{a.address}</span></li>}
          {a.hoursSummary && <li title="Giờ mở cửa">🕐 <span className="clamp-1">{a.hoursSummary}</span></li>}
          {a.visitDuration && <li title="Thời gian tham quan gợi ý">⏱ <span className="clamp-1">{a.visitDuration}</span></li>}
        </ul>
        <div className="card-foot">
          {a.priceFrom && <span className={`price-tag${a.priceFrom === 'Miễn phí' ? ' free' : ''}`}>🎟 {a.priceFrom}</span>}
          {a.imageCount ? <span className="muted small">📷 {a.imageCount + (a.imageUrl ? 1 : 0)} ảnh</span> : null}
        </div>
      </div>
    </Link>
  );
}
