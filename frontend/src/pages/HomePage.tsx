/** Trang chu = Kham pha Ha Noi: tim kiem, loc theo loai, goi y theo so thich (AI) */
import { FormEvent, KeyboardEvent, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { attractionApi } from '../services/attractionApi';
import { aiApi } from '../services/aiApi';
import { errorMessage } from '../services/api';
import { Attraction, SuggestionResult } from '../types';
import { AttractionCard, categoryIcon } from '../components/AttractionCard';
import { SuggestionCard } from '../components/SuggestionCard';
import { Icon } from '../components/Icon';
import { Empty, ErrorBox, Loading } from '../components/Feedback';
import { useAsync } from '../utils/useAsync';
import { useAuth } from '../context/AuthContext';
import { MODE_META } from '../utils/modes';
import { TransitLines } from '../components/TransitLines';

/** Bo dau tieng Viet de tim khong dau ("van mieu" -> Van Mieu) */
const fold = (s: string) => s.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd');

/** Chon nhanh so thich (bam de them vao o so thich) */
const INTERESTS = ['Lịch sử', 'Kiến trúc Pháp', 'Chụp ảnh', 'Ẩm thực đường phố', 'Tâm linh, chùa chiền', 'Hồ nước, cây xanh', 'Về đêm', 'Đi cùng trẻ em', 'Nghệ thuật'];

export default function HomePage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [debounced, setDebounced] = useState('');
  const [category, setCategory] = useState('');
  const [sort, setSort] = useState('popular');
  const [interest, setInterest] = useState('');
  const [suggest, setSuggest] = useState<SuggestionResult | null>(null);
  const [suggesting, setSuggesting] = useState(false);
  const [suggestError, setSuggestError] = useState<string | null>(null);
  const [locating, setLocating] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => setDebounced(search), 300);
    return () => clearTimeout(t);
  }, [search]);

  const categories = useAsync(() => attractionApi.categories(), []);
  // O tim diem den o dau trang: chon dia diem -> mo ban do tim duong toi do
  const allPlaces = useAsync(() => attractionApi.list({ sort: 'popular' }), []);
  const [dest, setDest] = useState('');
  const [destOpen, setDestOpen] = useState(false);
  const [destActive, setDestActive] = useState(0);
  const destMatches = useMemo<Attraction[]>(() => {
    const q = fold(dest.trim());
    if (!q) return [];
    return (allPlaces.data ?? []).filter((a) => fold(`${a.name} ${a.category ?? ''} ${a.address ?? ''}`).includes(q)).slice(0, 6);
  }, [dest, allPlaces.data]);
  const goTo = (a: Attraction) => navigate(`/map?to=attraction:${a.attractionId}`);
  const onDestSubmit = (e: FormEvent) => {
    e.preventDefault();
    const pick = destMatches[destActive] ?? destMatches[0];
    if (pick) return goTo(pick);
    if (!dest.trim()) return navigate('/map');
    // Khong khop dia diem nao -> loc danh sach Kham pha theo chu da go
    setSearch(dest.trim());
    document.getElementById('explore')?.scrollIntoView({ behavior: 'smooth' });
  };
  const onDestKey = (e: KeyboardEvent<HTMLInputElement>) => {
    if (!destMatches.length) return;
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      setDestOpen(true);
      setDestActive((i) => (i + 1) % destMatches.length);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setDestActive((i) => (i - 1 + destMatches.length) % destMatches.length);
    } else if (e.key === 'Escape') {
      setDestOpen(false);
    }
  };
  const featured = useAsync(() => attractionApi.featured(4), []);
  const list = useAsync(() => attractionApi.list({ search: debounced, category, sort }), [debounced, category, sort]);

  // Goi y theo so thich (AI): dang nhap -> ket hop nhung noi da xem / da tim duong
  const runSuggest = (q: string, lat?: number, lng?: number) => {
    setSuggesting(true);
    setSuggestError(null);
    aiApi
      .suggestions({ q: q.trim() || undefined, lat, lng, limit: 4 })
      .then(setSuggest)
      .catch((e) => setSuggestError(errorMessage(e)))
      .finally(() => {
        setSuggesting(false);
        setLocating(false);
      });
  };
  // Mo trang: goi y "danh cho ban" theo lich su (khach: theo do noi bat)
  useEffect(() => {
    runSuggest('');
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user?.id]);

  const onSuggest = (e: FormEvent) => {
    e.preventDefault();
    runSuggest(interest);
  };
  const suggestNearMe = () => {
    if (!navigator.geolocation) return runSuggest(interest);
    setLocating(true);
    navigator.geolocation.getCurrentPosition(
      (p) => runSuggest(interest, p.coords.latitude, p.coords.longitude),
      () => runSuggest(interest),
      { timeout: 6000 },
    );
  };
  const toggleInterest = (tag: string) => {
    const parts = interest.split(',').map((x) => x.trim()).filter(Boolean);
    const has = parts.some((x) => x.toLowerCase() === tag.toLowerCase());
    setInterest((has ? parts.filter((x) => x.toLowerCase() !== tag.toLowerCase()) : [...parts, tag]).join(', '));
  };
  const interestOn = (tag: string) => interest.toLowerCase().split(',').map((x) => x.trim()).includes(tag.toLowerCase());

  return (
    <div className="page">
      <section className="home-hero">
        <TransitLines />
        <div className="hero-content">
          <p className="hero-greet">Xin chào{user ? `, ${user.fullName.split(' ').slice(-1)[0]}` : ''}</p>
          <h1>Bạn muốn đi đâu hôm nay?</h1>
          <p className="hero-sub">Chọn điểm đến, HanoiGo tìm lộ trình kết hợp xe buýt, Metro, xe đạp và xe điện công cộng.</p>
          <form className="hero-search" role="search" onSubmit={onDestSubmit}>
            <Icon name="search" size={20} />
            <input
              value={dest}
              onChange={(e) => {
                setDest(e.target.value);
                setDestActive(0);
                setDestOpen(true);
              }}
              onFocus={() => setDestOpen(true)}
              onBlur={() => window.setTimeout(() => setDestOpen(false), 150)}
              onKeyDown={onDestKey}
              placeholder="Nhập điểm đến: Văn Miếu, Hồ Tây, Lotte Mall…"
              aria-label="Điểm đến"
              role="combobox"
              aria-expanded={destOpen && destMatches.length > 0}
              aria-controls="hero-results"
              aria-autocomplete="list"
              autoComplete="off"
            />
            <button className="btn btn-accent" type="submit">
              <Icon name="route" size={18} />
              <span className="btn-label">Tìm đường</span>
            </button>
            {destOpen && destMatches.length > 0 && (
              <ul className="hero-results" id="hero-results" role="listbox">
                {destMatches.map((a, i) => (
                  <li
                    key={a.attractionId}
                    role="option"
                    aria-selected={i === destActive}
                    className={`hero-result${i === destActive ? ' on' : ''}`}
                    onMouseEnter={() => setDestActive(i)}
                    onMouseDown={(e) => {
                      e.preventDefault();
                      goTo(a);
                    }}
                  >
                    <span className="hero-result-icon">{a.imageUrl ? <img src={a.imageUrl} alt="" /> : categoryIcon(a.category, a.name)}</span>
                    <span className="hero-result-text">
                      <strong>{a.name}</strong>
                      <span>{[a.category, a.address].filter(Boolean).join(', ')}</span>
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </form>
          {featured.data && featured.data.length > 0 && (
            <div className="hero-quick">
              <span>Phổ biến:</span>
              {featured.data.map((a) => (
                <button key={a.attractionId} type="button" onClick={() => goTo(a)}>
                  {a.name.replace(/^Lăng Chủ tịch Hồ Chí Minh$/, 'Lăng Bác').replace(/ - .*$/, '')}
                </button>
              ))}
            </div>
          )}
        </div>
        <div className="hero-foot">
          <ul className="hero-legend" aria-label="Phương tiện trong hệ thống">
            {(['BUS', 'METRO', 'BICYCLE', 'ELECTRIC_VEHICLE'] as const).map((m) => (
              <li key={m}>
                <i style={{ ['--c' as any]: MODE_META[m].color }} />
                {MODE_META[m].label}
              </li>
            ))}
          </ul>
          <div className="hero-links">
            <button className="btn btn-sm btn-ghost-light" onClick={() => navigate('/assistant')}>
              <Icon name="sparkles" size={16} /> Hỏi trợ lý AI
            </button>
            <a href="#explore" className="btn btn-sm btn-ghost-light">
              Xem 50 địa điểm
            </a>
          </div>
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
            <h2>
              Gợi ý cho bạn <span className="ai-badge">AI</span>
            </h2>
            <p className="muted small">
              Nhập điều bạn thích, AI chọn địa điểm hợp nhất{user ? ' và kết hợp những nơi bạn đã xem, đã tìm đường' : ''}.
            </p>
          </div>
          <button className="btn btn-ghost btn-sm" onClick={() => navigate('/assistant')}>
            <Icon name="sparkles" size={16} /> Hỏi trợ lý AI
          </button>
        </div>
        <form className="suggest-form" onSubmit={onSuggest}>
          <input
            className="input"
            value={interest}
            onChange={(e) => setInterest(e.target.value)}
            maxLength={300}
            placeholder="Bạn thích gì? Ví dụ: lịch sử, kiến trúc Pháp, chụp ảnh hoàng hôn"
            aria-label="Sở thích của bạn"
          />
          <button className="btn btn-primary" type="submit" disabled={suggesting}>
            {suggesting && !locating ? 'Đang gợi ý…' : 'Gợi ý'}
          </button>
          <button className="btn btn-ghost" type="button" onClick={suggestNearMe} disabled={suggesting}>
            <Icon name="locate" size={17} />
            {locating ? 'Đang định vị…' : 'Gần tôi'}
          </button>
        </form>
        <div className="chips">
          {INTERESTS.map((tag) => (
            <button key={tag} type="button" className={`chip chip-btn${interestOn(tag) ? ' active' : ''}`} onClick={() => toggleInterest(tag)}>
              {tag}
            </button>
          ))}
        </div>
        {suggest && !suggest.query && suggest.basedOn.length > 0 && (
          <p className="muted small suggest-basis">
            <Icon name="sparkles" size={14} /> Dành cho bạn, dựa trên: {suggest.basedOn.join(', ')}
          </p>
        )}
        {suggestError ? (
          <ErrorBox message={suggestError} onRetry={() => runSuggest(interest)} />
        ) : suggest ? (
          <div className={`grid-cards${suggesting ? ' is-loading' : ''}`}>
            {suggest.items.map((it) => (
              <SuggestionCard key={it.attractionId} s={it} />
            ))}
          </div>
        ) : (
          <Loading />
        )}
        {suggest?.notice && <p className="muted small mt">{suggest.notice}</p>}
      </section>

      <section className="section" id="explore">
        <div className="section-head">
          <h2>Khám phá Hà Nội</h2>
          <div className="row gap">
            <input className="input" placeholder="Tìm theo tên địa điểm" aria-label="Tìm địa điểm" value={search} onChange={(e) => setSearch(e.target.value)} />
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
