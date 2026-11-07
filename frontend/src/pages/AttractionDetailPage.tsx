import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { attractionApi } from '../services/attractionApi';
import { useAsync } from '../utils/useAsync';
import { ErrorBox, Loading } from '../components/Feedback';
import { AttractionCover, categoryIcon } from '../components/AttractionCard';
import { MapView } from '../components/MapView';
import { ModeBadge } from '../components/ModeBadge';
import { formatDistance } from '../utils/format';
import { AttractionDetail } from '../types';

interface Photo {
  url: string;
  caption: string;
  credit: string | null;
  sourceUrl: string | null;
}

/** Anh dai dien + bo suu tap -> 1 danh sach anh */
function photosOf(a: AttractionDetail): Photo[] {
  const list: Photo[] = [];
  if (a.imageUrl) {
    list.push({
      url: a.imageUrl,
      caption: a.name,
      credit: a.imageCredit?.replace(/^Ảnh:\s*/, '').replace(/\s*\/\s*Wikimedia Commons$/, '') ?? null,
      sourceUrl: a.imageSourceUrl ?? null,
    });
  }
  for (const img of a.images ?? []) {
    list.push({ url: img.imageUrl, caption: img.caption ?? a.name, credit: img.credit, sourceUrl: img.sourceUrl });
  }
  return list;
}

/** Xem anh phong to: mui ten trai/phai, Esc de dong */
function Lightbox({ photos, index, onClose, onMove }: { photos: Photo[]; index: number; onClose: () => void; onMove: (i: number) => void }) {
  const p = photos[index];
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
      if (e.key === 'ArrowRight') onMove((index + 1) % photos.length);
      if (e.key === 'ArrowLeft') onMove((index - 1 + photos.length) % photos.length);
    };
    window.addEventListener('keydown', onKey);
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      window.removeEventListener('keydown', onKey);
      document.body.style.overflow = prev;
    };
  }, [index, photos.length, onClose, onMove]);

  return (
    <div className="lightbox" role="dialog" aria-modal="true" onClick={onClose}>
      <button className="lightbox-close" aria-label="Đóng" onClick={onClose}>✕</button>
      {photos.length > 1 && (
        <button
          className="lightbox-nav prev"
          aria-label="Ảnh trước"
          onClick={(e) => {
            e.stopPropagation();
            onMove((index - 1 + photos.length) % photos.length);
          }}
        >
          ‹
        </button>
      )}
      <figure onClick={(e) => e.stopPropagation()}>
        <img src={p.url} alt={p.caption} />
        <figcaption>
          {p.caption} <span className="muted">· {index + 1}/{photos.length}</span>
        </figcaption>
      </figure>
      {photos.length > 1 && (
        <button
          className="lightbox-nav next"
          aria-label="Ảnh sau"
          onClick={(e) => {
            e.stopPropagation();
            onMove((index + 1) % photos.length);
          }}
        >
          ›
        </button>
      )}
    </div>
  );
}

export default function AttractionDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { data: a, loading, error, reload } = useAsync(() => attractionApi.detail(Number(id)), [id]);
  const [viewer, setViewer] = useState<number | null>(null);

  if (loading) return <Loading />;
  if (error || !a) return <div className="page"><ErrorBox message={error ?? 'Không tìm thấy'} onRetry={reload} /></div>;

  const photos = photosOf(a);
  const offset = a.imageUrl ? 1 : 0;
  const extra = photos.slice(offset);
  const facts = [
    { icon: '🕐', label: 'Giờ mở cửa', value: a.hoursSummary ?? a.openingHours },
    { icon: '🎟', label: 'Giá vé', value: a.priceFrom ?? a.ticketPrice },
    { icon: '⏱', label: 'Thời gian tham quan', value: a.visitDuration },
    { icon: '🌤', label: 'Nên đến', value: a.bestTime },
  ].filter((f) => f.value);

  return (
    <div className="detail-page">
      {/* Anh dau trang: phu kin chieu ngang */}
      <header className="detail-banner">
        <AttractionCover a={a} />
        <div className="detail-banner-shade" />
        <div className="detail-banner-inner">
          <Link to="/" className="banner-back">← Khám phá</Link>
          <span className="chip chip-glass">{categoryIcon(a.category)} {a.category}</span>
          <h1>{a.name}</h1>
          <p>📍 {a.address}</p>
          <div className="row gap wrap">
            <button className="btn btn-accent" onClick={() => navigate(`/map?to=attraction:${a.attractionId}`)}>
              🧭 Tìm đường đến đây
            </button>
            <button className="btn btn-glass" onClick={() => navigate(`/map?focus=attraction:${a.attractionId}`)}>
              Xem trên bản đồ
            </button>
            {photos.length > 1 && (
              <button className="btn btn-glass" onClick={() => setViewer(0)}>
                📷 Xem {photos.length} ảnh
              </button>
            )}
          </div>
        </div>
      </header>

      <div className="page detail-body">
        {facts.length > 0 && (
          <div className="quick-facts">
            {facts.map((f) => (
              <div key={f.label} className="quick-fact">
                <span className="quick-fact-icon">{f.icon}</span>
                <div>
                  <div className="quick-fact-label">{f.label}</div>
                  <div className="quick-fact-value">{f.value}</div>
                </div>
              </div>
            ))}
          </div>
        )}

        <div className="detail-grid">
          <div className="detail-main">
            <section className="card">
              <h2>Giới thiệu chung</h2>
              <p>{a.description}</p>
            </section>
            {a.history && (
              <section className="card">
                <h2>Lịch sử</h2>
                <p>{a.history}</p>
              </section>
            )}
            {a.highlights.length > 0 && (
              <section className="card">
                <h2>Điểm nổi bật</h2>
                <ul className="highlights">
                  {a.highlights.map((h) => (
                    <li key={h}>{h}</li>
                  ))}
                </ul>
              </section>
            )}
            {(a.tips?.length ?? 0) > 0 && (
              <section className="card card-tips">
                <h2>Lưu ý khi tham quan</h2>
                <ul className="tips">
                  {a.tips!.map((t) => (
                    <li key={t}>{t}</li>
                  ))}
                </ul>
              </section>
            )}
          </div>
          <aside className="detail-side">
            <section className="card">
              <h3>Thông tin tham quan</h3>
              <dl className="info-list">
                <dt>Giờ hoạt động</dt>
                <dd>{a.openingHours ?? 'Đang cập nhật'}</dd>
                <dt>Giá vé tham khảo</dt>
                <dd>{a.ticketPrice ?? 'Đang cập nhật'}</dd>
                {a.visitDuration && (
                  <>
                    <dt>Thời gian tham quan gợi ý</dt>
                    <dd>{a.visitDuration}</dd>
                  </>
                )}
                {a.bestTime && (
                  <>
                    <dt>Thời điểm đẹp nhất</dt>
                    <dd>{a.bestTime}</dd>
                  </>
                )}
              </dl>
              <p className="muted small">Giờ mở cửa và giá vé có thể thay đổi, vui lòng kiểm tra nguồn chính thức trước khi đi.</p>
            </section>
            <section className="card">
              <h3>Trạm gần đây</h3>
              <ul className="station-list">
                {a.nearbyStations.map((s) => (
                  <li key={s.stationId}>
                    <ModeBadge mode={s.mode} small />
                    <span className="grow">{s.stationName}</span>
                    <span className="muted small">
                      {formatDistance(s.walkingDistance)} · {s.walkingDuration}'
                    </span>
                  </li>
                ))}
                {a.nearbyStations.length === 0 && <li className="muted">Chưa có dữ liệu trạm gần</li>}
              </ul>
            </section>
            <div className="mini-map">
              <MapView
                stations={a.nearbyStations}
                attractions={[a]}
                destination={{ name: a.name, latitude: a.latitude, longitude: a.longitude }}
                focus={[a.latitude, a.longitude]}
                className="map map-mini"
              />
            </div>
          </aside>
        </div>

        {extra.length > 0 && (
          <section className="gallery-section">
            <h2>Hình ảnh {a.name}</h2>
            {/* Anh dai dien da o dau trang -> luoi chi gom anh bo sung (vi tri trong lightbox lech 1 neu co anh dai dien) */}
            <div className={`gallery gallery-n${Math.min(extra.length, 5)}`}>
              {extra.map((p, i) => (
                <button key={p.url} className="gallery-item" onClick={() => setViewer(i + offset)}>
                  <img src={p.url} alt={p.caption} loading="lazy" />
                  <span className="gallery-caption">{p.caption}</span>
                </button>
              ))}
            </div>
            {/* Ghi nguon theo yeu cau giay phep CC BY / CC BY-SA - thu gon, khong hien tren anh */}
            <details className="photo-credits">
              <summary>Nguồn ảnh</summary>
              <ul>
                {photos.map((p) => (
                  <li key={p.url}>
                    {p.caption}: {p.credit ?? 'Wikimedia Commons'}
                    {p.sourceUrl && (
                      <>
                        {' '}·{' '}
                        <a href={p.sourceUrl} target="_blank" rel="noreferrer">
                          Wikimedia Commons
                        </a>
                      </>
                    )}
                  </li>
                ))}
              </ul>
            </details>
          </section>
        )}
      </div>

      {viewer !== null && <Lightbox photos={photos} index={viewer} onClose={() => setViewer(null)} onMove={setViewer} />}
    </div>
  );
}
