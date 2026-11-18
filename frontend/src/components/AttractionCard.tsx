import { Link } from 'react-router-dom';
import { Attraction } from '../types';
import { formatDistance } from '../utils/format';
import { Icon } from './Icon';

const CATEGORY_ICON: Record<string, string> = {
  'Danh thắng': '🏞️',
  'Di tích': '🏛️',
  'Di sản': '🏯', // hoang thanh co lau tren cong thanh
  'Bảo tàng': '🏺',
  'Tôn giáo': '☸️', // banh xe Phap - chua Phat giao
  'Khu phố': '🏮',
  'Chợ': '🧺',
  'Kiến trúc': '📐',
  'Quảng trường': '🚩',
  'Văn hóa': '📚',
  'Nghệ thuật': '🎭',
  'Công viên': '🌳',
  'Vui chơi': '🎢',
  'Mua sắm': '🛍️',
};

/** Icon theo loai dia diem; nha tho (Cong giao) dung icon rieng thay cho banh xe Phap cua chua */
export const categoryIcon = (c?: string | null, name?: string | null) =>
  (name && /^nhà thờ/i.test(name) ? '⛪' : null) || (c && CATEGORY_ICON[c]) || '📍';

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
      <span>{categoryIcon(a.category, a.name)}</span>
    </div>
  );
}

export function AttractionCard({ a }: { a: Attraction }) {
  const photos = a.imageCount ? a.imageCount + (a.imageUrl ? 1 : 0) : 0;
  return (
    <Link to={`/attractions/${a.attractionId}`} className="attraction-card">
      <div className="attraction-media">
        <AttractionCover a={a} />
        <span className="media-chip">
          {categoryIcon(a.category, a.name)} {a.category ?? 'Địa điểm'}
        </span>
        {photos > 0 && (
          <span className="media-count" title={`${photos} ảnh`}>
            <Icon name="images" size={14} /> {photos}
          </span>
        )}
      </div>
      <div className="attraction-card-body">
        {(a.distanceMeters !== undefined || a.score !== undefined) && (
          <div className="attraction-meta">
            {a.distanceMeters !== undefined && <span className="muted">{formatDistance(a.distanceMeters)}</span>}
            {a.score !== undefined && <span className="muted">★ {a.score}</span>}
          </div>
        )}
        <h3>{a.name}</h3>
        <p className="muted clamp-2">{a.description}</p>
        <ul className="card-facts">
          {a.address && (
            <li title="Địa chỉ">
              <Icon name="pin" size={15} /> <span className="clamp-1">{a.address}</span>
            </li>
          )}
          {a.hoursSummary && (
            <li title="Giờ mở cửa">
              <Icon name="clock" size={15} /> <span className="clamp-1">{a.hoursSummary}</span>
            </li>
          )}
          {a.visitDuration && (
            <li title="Thời gian tham quan gợi ý">
              <Icon name="hourglass" size={15} /> <span className="clamp-1">{a.visitDuration}</span>
            </li>
          )}
        </ul>
        {a.priceFrom && (
          <div className="card-foot">
            <span className={`price-tag${a.priceFrom === 'Miễn phí' ? ' free' : ''}`}>
              <Icon name="ticket" size={14} /> {a.priceFrom}
            </span>
          </div>
        )}
      </div>
    </Link>
  );
}
