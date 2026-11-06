/** Trang chu = Kham pha Ha Noi: tim kiem, loc theo loai, goi y noi bat */
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { attractionApi } from '../services/attractionApi';
import { Attraction } from '../types';
import { AttractionCard, categoryIcon } from '../components/AttractionCard';
import { Empty, ErrorBox, Loading } from '../components/Feedback';
import { useAsync } from '../utils/useAsync';
import { useAuth } from '../context/AuthContext';

export default function HomePage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [debounced, setDebounced] = useState('');
  const [category, setCategory] = useState('');
  const [sort, setSort] = useState('popular');
  const [picked, setPicked] = useState<string[]>([]);
  const [recommend, setRecommend] = useState<Attraction[] | null>(null);
  const [locating, setLocating] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => setDebounced(search), 300);
    return () => clearTimeout(t);
  }, [search]);

  const categories = useAsync(() => attractionApi.categories(), []);
  const featured = useAsync(() => attractionApi.featured(4), []);
  const list = useAsync(() => attractionApi.list({ search: debounced, category, sort }), [debounced, category, sort]);

  const runRecommend = (withLocation: boolean) => {
    const go = (lat?: number, lng?: number) =>
      attractionApi
        .recommend({ categories: picked.join(','), lat, lng, limit: 4 })
        .then(setRecommend)
        .finally(() => setLocating(false));
    if (withLocation && navigator.geolocation) {
      setLocating(true);
      navigator.geolocation.getCurrentPosition(
        (p) => go(p.coords.latitude, p.coords.longitude),
        () => go(),
        { timeout: 6000 },
      );
    } else go();
  };

  return (
    <div className="page">
      <section className="hero">
        <div className="hero-text">
          <div className="kicker">Xin chào{user ? `, ${user.fullName.split(' ').slice(-1)[0]}` : ''} 👋</div>
          <h1>Bạn muốn đi đâu hôm nay?</h1>
          <p>Khám phá 20 điểm đến nổi bật của Hà Nội và tìm lộ trình kết hợp Bus, Metro, xe đạp, xe điện.</p>
          <div className="hero-actions">
            <button className="btn btn-accent" onClick={() => navigate('/map')}>
              🗺️ Mở bản đồ tìm đường
            </button>
            <a href="#explore" className="btn btn-ghost-light">
              Khám phá địa điểm ↓
            </a>
          </div>
        </div>
        <div className="hero-modes">
          {['🚌 Bus', '🚇 Metro', '🚲 Xe đạp', '🛺 Xe điện'].map((m) => (
            <span key={m} className="hero-mode">
              {m}
            </span>
          ))}
        </div>
      </section>

      <section className="section">
        <div className="section-head">
          <h2>Nổi bật nhất</h2>
        </div>
        {featured.loading ? (
          <Loading />
        ) : featured.error ? (
          <ErrorBox message={featured.error} onRetry={featured.reload} />
        ) : (
          <div className="grid-cards">{featured.data?.map((a) => <AttractionCard key={a.attractionId} a={a} />)}</div>
        )}
      </section>

      <section className="section card recommend">
        <div className="section-head">
          <div>
            <h2>Gợi ý cho bạn</h2>
            <p className="muted small">Điểm = 0.5 × độ nổi bật + 0.3 × sở thích + 0.2 × khoảng cách</p>
          </div>
        </div>
        <div className="chips">
          {categories.data?.map((c) => (
            <button
              key={c.category}
              className={`chip chip-btn${picked.includes(c.category) ? ' active' : ''}`}
              onClick={() => setPicked((p) => (p.includes(c.category) ? p.filter((x) => x !== c.category) : [...p, c.category]))}
            >
              {categoryIcon(c.category)} {c.category}
            </button>
          ))}
        </div>
        <div className="row gap">
          <button className="btn btn-primary" onClick={() => runRecommend(false)}>
            Gợi ý theo sở thích
          </button>
          <button className="btn btn-ghost" onClick={() => runRecommend(true)} disabled={locating}>
            {locating ? 'Đang định vị...' : '📡 Gợi ý gần tôi'}
          </button>
        </div>
        {recommend && (
          <div className="grid-cards mt">
            {recommend.map((a) => (
              <AttractionCard key={a.attractionId} a={a} />
            ))}
          </div>
        )}
      </section>

      <section className="section" id="explore">
        <div className="section-head">
          <h2>Khám phá Hà Nội</h2>
          <div className="row gap">
            <input className="input" placeholder="🔎 Tìm địa điểm..." value={search} onChange={(e) => setSearch(e.target.value)} />
            <select className="input" value={sort} onChange={(e) => setSort(e.target.value)}>
              <option value="popular">Nổi bật</option>
              <option value="name">Tên A-Z</option>
            </select>
          </div>
        </div>
        <div className="chips">
          <button className={`chip chip-btn${category === '' ? ' active' : ''}`} onClick={() => setCategory('')}>
            Tất cả
          </button>
          {categories.data?.map((c) => (
            <button
              key={c.category}
              className={`chip chip-btn${category === c.category ? ' active' : ''}`}
              onClick={() => setCategory(c.category)}
            >
              {categoryIcon(c.category)} {c.category} <span className="muted">({c.total})</span>
            </button>
          ))}
        </div>
        {list.loading ? (
          <Loading />
        ) : list.error ? (
          <ErrorBox message={list.error} onRetry={list.reload} />
        ) : list.data && list.data.length > 0 ? (
          <div className="grid-cards">{list.data.map((a) => <AttractionCard key={a.attractionId} a={a} />)}</div>
        ) : (
          <Empty icon="🔍" title="Không tìm thấy địa điểm phù hợp" />
        )}
      </section>
    </div>
  );
}
