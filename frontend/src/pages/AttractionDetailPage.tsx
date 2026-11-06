import { Link, useNavigate, useParams } from 'react-router-dom';
import { attractionApi } from '../services/attractionApi';
import { useAsync } from '../utils/useAsync';
import { ErrorBox, Loading } from '../components/Feedback';
import { AttractionCover, categoryIcon } from '../components/AttractionCard';
import { MapView } from '../components/MapView';
import { ModeBadge } from '../components/ModeBadge';
import { formatDistance } from '../utils/format';

export default function AttractionDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { data: a, loading, error, reload } = useAsync(() => attractionApi.detail(Number(id)), [id]);

  if (loading) return <Loading />;
  if (error || !a) return <div className="page"><ErrorBox message={error ?? 'Không tìm thấy'} onRetry={reload} /></div>;

  return (
    <div className="page">
      <Link to="/" className="back-link">← Khám phá</Link>
      <div className="detail-hero">
        <AttractionCover a={a} tall />
        <div className="detail-hero-text">
          <span className="chip">{categoryIcon(a.category)} {a.category}</span>
          <h1>{a.name}</h1>
          <p className="muted">📍 {a.address}</p>
          <div className="row gap">
            <button className="btn btn-accent" onClick={() => navigate(`/map?to=attraction:${a.attractionId}`)}>
              🧭 Tìm đường đến đây
            </button>
            <button className="btn btn-ghost" onClick={() => navigate(`/map?focus=attraction:${a.attractionId}`)}>
              Xem trên bản đồ
            </button>
          </div>
        </div>
      </div>

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
        </div>
        <aside className="detail-side">
          <section className="card">
            <h3>Thông tin tham quan</h3>
            <dl className="info-list">
              <dt>Giờ hoạt động</dt>
              <dd>{a.openingHours ?? 'Đang cập nhật'}</dd>
              <dt>Giá vé tham khảo</dt>
              <dd>{a.ticketPrice ?? 'Đang cập nhật'}</dd>
            </dl>
            <p className="muted small">Thông tin mang tính tham khảo, vui lòng kiểm tra nguồn chính thức trước khi đi.</p>
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
    </div>
  );
}
