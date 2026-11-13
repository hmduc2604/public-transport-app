/**
 * Trang chi tiet dia diem tham quan
 *  - Anh dau trang phu kin + ten dia diem + 3 anh xem truoc
 *  - Dai thong tin: gio mo cua, gia ve, thoi gian tham quan, tram gan nhat
 *  - Gioi thieu, du kien nhanh, diem noi bat, lich su (moc thoi gian), kinh nghiem tham quan
 *  - Cot phai: den bang phuong tien cong cong (tram + tuyen), ban do nho, gio mo cua & gia ve day du
 *  - Bo suu tap anh (lightbox) va dia diem lan can
 */
import { MouseEvent, useEffect, useRef, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { attractionApi } from '../services/attractionApi';
import { useAsync } from '../utils/useAsync';
import { ErrorBox, Loading } from '../components/Feedback';
import { categoryIcon } from '../components/AttractionCard';
import { MapView } from '../components/MapView';
import { ModeBadge } from '../components/ModeBadge';
import { Icon, IconName } from '../components/Icon';
import { formatDistance } from '../utils/format';
import { MODE_META } from '../utils/modes';
import { AttractionDetail, NearbyAttraction } from '../types';

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

  const go = (d: number) => (e: MouseEvent) => {
    e.stopPropagation();
    onMove((index + d + photos.length) % photos.length);
  };

  return (
    <div className="lightbox" role="dialog" aria-modal="true" aria-label={`Ảnh ${index + 1} trên ${photos.length}`} onClick={onClose}>
      <button className="lightbox-close" aria-label="Đóng" onClick={onClose}>
        <Icon name="close" />
      </button>
      {photos.length > 1 && (
        <button className="lightbox-nav prev" aria-label="Ảnh trước" onClick={go(-1)}>
          <Icon name="chevronLeft" size={26} />
        </button>
      )}
      <figure onClick={(e) => e.stopPropagation()}>
        <img src={p.url} alt={p.caption} />
        <figcaption>
          <span>{p.caption}</span>
          <span className="lightbox-count">
            {index + 1}/{photos.length}
          </span>
        </figcaption>
      </figure>
      {photos.length > 1 && (
        <button className="lightbox-nav next" aria-label="Ảnh sau" onClick={go(1)}>
          <Icon name="chevronRight" size={26} />
        </button>
      )}
    </div>
  );
}

function Fact({ icon, label, value, sub }: { icon: IconName; label: string; value: string; sub?: string }) {
  return (
    <div className="place-fact">
      <span className="place-fact-icon">
        <Icon name={icon} />
      </span>
      <div className="place-fact-text">
        <span className="place-fact-label">{label}</span>
        <strong className="place-fact-value">{value}</strong>
        {sub && <span className="place-fact-sub">{sub}</span>}
      </div>
    </div>
  );
}

interface NavItem {
  id: string;
  label: string;
  /** Chi hien khi cot phai xep xuong duoi (man hinh hep): tren may tinh cot "Den bang PTCC" luon nam ben canh */
  stackedOnly?: boolean;
}

/**
 * Thanh muc luc dinh duoi thanh menu: bam de cuon toi muc, tu danh dau muc dang doc.
 * Muc dang doc = muc cuoi cung co mep tren da vuot qua thanh muc luc.
 */
function SectionNav({ items, onRoute }: { items: NavItem[]; onRoute: () => void }) {
  const [active, setActive] = useState(items[0]?.id);
  const navRef = useRef<HTMLDivElement>(null);
  const itemsKey = items.map((it) => it.id).join(',');

  useEffect(() => {
    let frame = 0;
    const compute = () => {
      frame = 0;
      const bar = navRef.current?.closest('.place-tabs') as HTMLElement | null;
      const line = (bar?.getBoundingClientRect().bottom ?? 120) + 40; // > scroll-margin-top (18px) -> bam muc nao thi muc do sang
      let current = items[0]?.id;
      let best = -Infinity;
      items.forEach((it, i) => {
        const link = navRef.current?.querySelector<HTMLElement>(`[data-target="${it.id}"]`);
        const el = document.getElementById(it.id);
        if (!el || !link || link.offsetParent === null) return; // muc bi an tren man hinh nay
        const top = el.getBoundingClientRect().top;
        // cung vi tri (vd. cot phai ngang hang phan mo dau) -> uu tien muc dung truoc
        const key = top - i * 0.001;
        if (top <= line && key > best) {
          best = key;
          current = it.id;
        }
      });
      // Cuon toi day trang -> muc cuoi
      if (window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 4) current = items[items.length - 1]?.id;
      setActive(current);
    };
    const onScroll = () => {
      if (!frame) frame = requestAnimationFrame(compute);
    };
    compute();
    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', onScroll);
    return () => {
      window.removeEventListener('scroll', onScroll);
      window.removeEventListener('resize', onScroll);
      if (frame) cancelAnimationFrame(frame);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [itemsKey]);

  // Tren dien thoai thanh muc luc cuon ngang: giu muc dang doc trong tam nhin
  useEffect(() => {
    const nav = navRef.current;
    const link = nav?.querySelector<HTMLElement>(`[data-target="${active}"]`);
    if (!nav || !link || nav.scrollWidth <= nav.clientWidth) return;
    nav.scrollTo({ left: link.offsetLeft - 16, behavior: 'smooth' });
  }, [active]);

  const go = (id: string) => (e: MouseEvent) => {
    e.preventDefault();
    const el = document.getElementById(id);
    if (!el) return;
    const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    el.scrollIntoView({ behavior: reduce ? 'auto' : 'smooth', block: 'start' });
    setActive(id);
  };

  return (
    <nav className="place-tabs" aria-label="Mục lục trang">
      <div className="place-tabs-inner">
        <div className="place-tabs-links" ref={navRef}>
          {items.map((it) => (
            <a
              key={it.id}
              href={`#${it.id}`}
              data-target={it.id}
              className={`place-tab${active === it.id ? ' active' : ''}${it.stackedOnly ? ' stacked-only' : ''}`}
              aria-current={active === it.id ? 'location' : undefined}
              onClick={go(it.id)}
            >
              {it.label}
            </a>
          ))}
        </div>
        <button className="btn btn-accent btn-sm place-tabs-cta" onClick={onRoute} aria-label="Tìm đường đến đây">
          <Icon name="navigation" size={16} />
          <span className="place-tabs-cta-label">Tìm đường</span>
        </button>
      </div>
    </nav>
  );
}

/** Chia se: dung bang chia se cua he dieu hanh neu co, khong thi chep lien ket */
function ShareButton({ title }: { title: string }) {
  const [copied, setCopied] = useState(false);
  useEffect(() => {
    if (!copied) return;
    const t = setTimeout(() => setCopied(false), 2200);
    return () => clearTimeout(t);
  }, [copied]);

  const share = async () => {
    const url = window.location.href.split('#')[0];
    try {
      if (typeof navigator.share === 'function') {
        await navigator.share({ title: `${title} – HanoiGo`, url });
        return;
      }
      await navigator.clipboard.writeText(url);
      setCopied(true);
    } catch {
      /* nguoi dung dong bang chia se / trinh duyet chan clipboard: khong lam gi */
    }
  };

  return (
    <button className="btn btn-glass place-share" onClick={share} aria-label={copied ? 'Đã sao chép liên kết' : 'Chia sẻ địa điểm'}>
      <Icon name={copied ? 'check' : 'share'} size={18} />
      <span className="place-share-label">{copied ? 'Đã sao chép liên kết' : 'Chia sẻ'}</span>
    </button>
  );
}

function NearbyCard({ n }: { n: NearbyAttraction }) {
  return (
    <Link to={`/attractions/${n.attractionId}`} className="nearby-card">
      <div className="nearby-media">
        {n.imageUrl ? <img src={n.imageUrl} alt="" loading="lazy" /> : <span className="nearby-ph">{categoryIcon(n.category)}</span>}
      </div>
      <div className="nearby-body">
        <span className="nearby-cat">{n.category}</span>
        <strong className="nearby-name">{n.name}</strong>
        <span className="nearby-dist">
          <Icon name="walk" size={16} />
          {formatDistance(n.distanceMeters)}, khoảng {n.walkingMinutes} phút đi bộ
        </span>
      </div>
    </Link>
  );
}

export default function AttractionDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { data: a, loading, error, reload } = useAsync(() => attractionApi.detail(Number(id)), [id]);
  const [viewer, setViewer] = useState<number | null>(null);

  // Sang dia diem khac (muc "Di tiep gan day") -> len dau trang, dong lightbox
  useEffect(() => {
    window.scrollTo(0, 0);
    setViewer(null);
  }, [id]);

  useEffect(() => {
    if (!a) return;
    const prev = document.title;
    document.title = `${a.name} – HanoiGo`;
    return () => {
      document.title = prev;
    };
  }, [a]);

  if (loading) return <Loading />;
  if (error || !a) return <div className="page"><ErrorBox message={error ?? 'Không tìm thấy địa điểm'} onRetry={reload} /></div>;

  const photos = photosOf(a);
  const offset = a.imageUrl ? 1 : 0;
  const extra = photos.slice(offset);
  const nearest = a.nearbyStations[0];
  const facts = a.facts ?? [];
  const timeline = a.timeline ?? [];
  const goRoute = () => navigate(`/map?to=attraction:${a.attractionId}`);
  const tips = a.tips ?? [];
  const nearbyPlaces = a.nearbyAttractions ?? [];
  const navItems: NavItem[] = [
    { id: 'tong-quan', label: 'Tổng quan' },
    { id: 'di-lai', label: 'Đi lại', stackedOnly: true },
    ...(a.highlights.length > 0 ? [{ id: 'noi-bat', label: 'Nổi bật' }] : []),
    ...(a.history || timeline.length > 0 ? [{ id: 'lich-su', label: 'Lịch sử' }] : []),
    ...(tips.length > 0 ? [{ id: 'kinh-nghiem', label: 'Kinh nghiệm' }] : []),
    ...(extra.length > 0 ? [{ id: 'hinh-anh', label: 'Hình ảnh' }] : []),
    ...(nearbyPlaces.length > 0 ? [{ id: 'gan-day', label: 'Gần đây' }] : []),
  ];

  return (
    <article className="place">
      {/* ---------- Anh dau trang ---------- */}
      <header className="place-hero">
        {a.imageUrl ? <img className="place-hero-img" src={a.imageUrl} alt={a.name} /> : <div className="place-hero-img place-hero-ph" />}
        <div className="place-hero-shade" />
        <div className="place-hero-inner">
          <Link to="/" className="place-back">
            <Icon name="arrowLeft" size={18} /> Khám phá
          </Link>
          <div className="place-hero-bottom">
            <div className="place-hero-text">
              {a.category && <span className="place-cat">{a.category}</span>}
              <h1>{a.name}</h1>
              {a.address && (
                <p className="place-addr">
                  <Icon name="pin" size={18} /> {a.address}
                </p>
              )}
              <div className="place-actions">
                <button className="btn btn-accent" onClick={goRoute}>
                  <Icon name="navigation" size={18} /> Tìm đường đến đây
                </button>
                <button className="btn btn-glass" onClick={() => navigate(`/map?focus=attraction:${a.attractionId}`)}>
                  <Icon name="map" size={18} /> Xem trên bản đồ
                </button>
                {photos.length > 1 && (
                  <button className="btn btn-glass place-photos-btn" onClick={() => setViewer(0)}>
                    <Icon name="images" size={18} /> {photos.length} ảnh
                  </button>
                )}
                <ShareButton title={a.name} />
              </div>
            </div>
            {extra.length > 0 && (
              <button className="place-peek" onClick={() => setViewer(offset)} aria-label={`Xem ${photos.length} ảnh của ${a.name}`}>
                {extra.slice(0, 3).map((p, i) => (
                  <span key={p.url} className="place-peek-item">
                    <img src={p.url} alt="" loading="lazy" />
                    {i === 2 && extra.length > 3 && <span className="place-peek-more">+{photos.length - 3}</span>}
                  </span>
                ))}
              </button>
            )}
          </div>
        </div>
      </header>

      {/* ---------- Dai thong tin nhanh ---------- */}
      <div className="place-wrap">
        <div className="place-facts">
          <Fact icon="clock" label="Giờ mở cửa" value={a.hoursSummary ?? a.openingHours ?? 'Đang cập nhật'} />
          <Fact icon="ticket" label="Giá vé" value={a.priceFrom ?? 'Đang cập nhật'} />
          <Fact icon="hourglass" label="Thời gian tham quan" value={a.visitDuration ?? 'Tùy lịch trình'} />
          {nearest ? (
            <Fact
              icon="walk"
              label="Trạm gần nhất"
              value={nearest.stationName}
              sub={`${MODE_META[nearest.mode].label}, ${nearest.walkingDuration} phút đi bộ`}
            />
          ) : (
            <Fact icon="walk" label="Trạm gần nhất" value="Chưa có dữ liệu" />
          )}
        </div>

        <SectionNav items={navItems} onRoute={goRoute} />

        <div className="place-body">
          {/* Gioi thieu + du kien */}
          <div className="place-lead-area" id="tong-quan" data-spy>
            {a.description && <p className="place-lead">{a.description}</p>}
            {facts.length > 0 && (
              <section className="place-section" aria-labelledby="h-facts">
                <h2 id="h-facts">Thông tin nhanh</h2>
                <dl className="place-factlist">
                  {facts.map((f) => (
                    <div key={f.label}>
                      <dt>{f.label}</dt>
                      <dd>{f.value}</dd>
                    </div>
                  ))}
                </dl>
              </section>
            )}
          </div>

          {/* Cot phai: cach di chuyen + thong tin tham quan */}
          <aside className="place-side">
            <section className="place-panel" id="di-lai" data-spy aria-labelledby="h-transit">
              <h2 id="h-transit">Đến bằng phương tiện công cộng</h2>
              {a.nearbyStations.length > 0 ? (
                <ul className="transit-list">
                  {a.nearbyStations.map((s) => (
                    <li key={s.stationId}>
                      <ModeBadge mode={s.mode} small />
                      <div className="transit-main">
                        <span className="transit-name">{s.stationName}</span>
                        {s.routes.length > 0 && (
                          <span className="transit-lines" aria-label="Các tuyến dừng tại trạm">
                            {s.routes.slice(0, 6).map((r) => (
                              <span
                                key={r.routeId}
                                className="line-chip"
                                style={{ borderColor: MODE_META[s.mode].color, color: MODE_META[s.mode].color }}
                                title={r.routeName}
                              >
                                {r.routeCode}
                              </span>
                            ))}
                            {s.routes.length > 6 && <span className="line-chip line-chip-more">+{s.routes.length - 6}</span>}
                          </span>
                        )}
                      </div>
                      <span className="transit-walk">
                        <strong>{s.walkingDuration} phút</strong>
                        <span>{formatDistance(s.walkingDistance)}</span>
                      </span>
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="muted">Chưa có dữ liệu trạm gần địa điểm này.</p>
              )}
              <button className="btn btn-primary btn-block" onClick={goRoute}>
                <Icon name="route" size={18} /> Tìm lộ trình từ vị trí của bạn
              </button>
              <div className="place-map">
                <MapView
                  stations={a.nearbyStations}
                  attractions={[a]}
                  destination={{ name: a.name, latitude: a.latitude, longitude: a.longitude }}
                  focus={[a.latitude, a.longitude]}
                  className="map map-mini"
                />
              </div>
            </section>

            <section className="place-panel" aria-labelledby="h-visit">
              <h2 id="h-visit">Giờ mở cửa và giá vé</h2>
              <dl className="visit-list">
                <dt>
                  <Icon name="clock" size={18} /> Giờ hoạt động
                </dt>
                <dd>{a.openingHours ?? 'Đang cập nhật'}</dd>
                <dt>
                  <Icon name="ticket" size={18} /> Giá vé
                </dt>
                <dd>{a.ticketPrice ?? 'Đang cập nhật'}</dd>
                {a.bestTime && (
                  <>
                    <dt>
                      <Icon name="sun" size={18} /> Thời điểm đẹp nhất
                    </dt>
                    <dd>{a.bestTime}</dd>
                  </>
                )}
              </dl>
              <p className="place-note">
                <Icon name="info" size={16} /> Giờ mở cửa và giá vé có thể thay đổi theo mùa và dịp lễ. Nên kiểm tra lại trước khi đi.
              </p>
            </section>
          </aside>

          {/* Noi dung chinh */}
          <div className="place-main">
            {a.highlights.length > 0 && (
              <section className="place-section" id="noi-bat" data-spy aria-labelledby="h-hl">
                <h2 id="h-hl">Điểm nổi bật</h2>
                <ul className="place-highlights">
                  {a.highlights.map((h) => (
                    <li key={h}>{h}</li>
                  ))}
                </ul>
              </section>
            )}

            {(a.history || timeline.length > 0) && (
              <section className="place-section" id="lich-su" data-spy aria-labelledby="h-history">
                <h2 id="h-history">Lịch sử</h2>
                {a.history && <p className="place-prose">{a.history}</p>}
                {timeline.length > 1 && (
                  <ol className="place-timeline" aria-label="Các mốc lịch sử">
                    {timeline.map((t) => (
                      <li key={t.year + t.event}>
                        <span className="place-timeline-year">{t.year}</span>
                        <span className="place-timeline-event">{t.event}</span>
                      </li>
                    ))}
                  </ol>
                )}
              </section>
            )}

            {tips.length > 0 && (
              <section className="place-section place-tips" id="kinh-nghiem" data-spy aria-labelledby="h-tips">
                <h2 id="h-tips">
                  <Icon name="bulb" size={22} /> Kinh nghiệm tham quan
                </h2>
                <ul>
                  {tips.map((t) => (
                    <li key={t}>{t}</li>
                  ))}
                </ul>
              </section>
            )}
          </div>
        </div>

        {/* ---------- Bo suu tap ---------- */}
        {extra.length > 0 && (
          <section className="place-gallery" id="hinh-anh" data-spy aria-labelledby="h-gallery">
            <div className="place-gallery-head">
              <h2 id="h-gallery">Hình ảnh</h2>
              <button className="btn btn-ghost btn-sm" onClick={() => setViewer(0)}>
                <Icon name="images" size={18} /> Xem tất cả {photos.length} ảnh
              </button>
            </div>
            <div className={`gallery gallery-n${Math.min(extra.length, 5)}`}>
              {extra.slice(0, 5).map((p, i) => (
                <button key={p.url} className="gallery-item" onClick={() => setViewer(i + offset)}>
                  <img src={p.url} alt={p.caption} loading="lazy" />
                  <span className="gallery-caption">{p.caption}</span>
                </button>
              ))}
            </div>
            {/* Ghi nguon theo yeu cau giay phep CC BY / CC BY-SA - thu gon */}
            <details className="photo-credits">
              <summary>Nguồn ảnh</summary>
              <ul>
                {photos.map((p) => (
                  <li key={p.url}>
                    {p.caption}: {p.credit ?? 'Wikimedia Commons'}
                    {p.sourceUrl && (
                      <>
                        {', '}
                        <a href={p.sourceUrl} target="_blank" rel="noreferrer">
                          Wikimedia Commons <Icon name="external" size={13} />
                        </a>
                      </>
                    )}
                  </li>
                ))}
              </ul>
            </details>
          </section>
        )}

        {/* ---------- Dia diem lan can ---------- */}
        {nearbyPlaces.length > 0 && (
          <section className="place-nearby" id="gan-day" data-spy aria-labelledby="h-nearby">
            <h2 id="h-nearby">Đi tiếp gần đây</h2>
            <div className="nearby-grid">
              {nearbyPlaces.map((n) => (
                <NearbyCard key={n.attractionId} n={n} />
              ))}
            </div>
          </section>
        )}
      </div>

      {viewer !== null && <Lightbox photos={photos} index={viewer} onClose={() => setViewer(null)} onMove={setViewer} />}
    </article>
  );
}
