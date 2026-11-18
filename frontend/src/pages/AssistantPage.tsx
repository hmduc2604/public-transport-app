/**
 * TRO LY AI LAP LO TRINH (Google Gemini)
 *
 *   Nguoi dung hoi bang tieng Viet  ->  POST /assistant/chat
 *   -> AI goi bo tim duong / du lieu dia diem / gia ve THAT cua he thong
 *   -> cau tra loi + the lo trinh (mo tren ban do) + the dia diem
 *
 * Hoi thoai luu trong sessionStorage (dong tab la xoa). Ho tro noi bang giong (Chrome / Edge)
 * va gui vi tri hien tai (chi khi nguoi dung bat).
 */
import { FormEvent, KeyboardEvent, useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { aiApi } from '../services/aiApi';
import { ApiError, errorMessage } from '../services/api';
import { AssistantHistoryItem, AssistantPlaceCard, AssistantRouteSet, TicketAdvice } from '../types';
import { RichText } from '../components/RichText';
import { TicketAdviceView } from '../components/TicketAdvisor';
import { Icon, IconName } from '../components/Icon';
import { categoryIcon } from '../components/AttractionCard';
import { MODE_META, PREFERENCE_META } from '../utils/modes';
import { formatDistance, formatMinutes, formatMoney } from '../utils/format';
import { useAuth } from '../context/AuthContext';

interface Msg {
  id: string;
  role: 'user' | 'assistant';
  text: string;
  routes?: AssistantRouteSet[];
  places?: AssistantPlaceCard[];
  ticketAdvice?: TicketAdvice | null;
  tools?: { name: string; ok: boolean }[];
  meta?: string;
  /** Loi -> hien nut Thu lai voi cau hoi nay */
  retry?: string;
}

const STORE_KEY = 'hng_ai_chat_v1';
const uid = () => Math.random().toString(36).slice(2, 10);

const EXAMPLES: { icon: IconName; text: string }[] = [
  { icon: 'route', text: 'Từ Hồ Gươm đến Văn Miếu, đi bộ ít thôi' },
  { icon: 'map', text: 'Lên lịch nửa ngày: Văn Miếu → Hoàng thành Thăng Long → Hồ Tây ngắm hoàng hôn' },
  { icon: 'sparkles', text: 'Mình thích lịch sử và chụp ảnh, nên đi đâu?' },
  { icon: 'ticket', text: 'Mình đi xe buýt 2 lượt mỗi ngày, thứ 2 – thứ 6. Có nên mua vé tháng không?' },
];

const TOOL_LABEL: Record<string, string> = {
  find_places: 'Tìm địa điểm',
  plan_route: 'Tìm lộ trình',
  plan_itinerary: 'Lập lịch trình',
  suggest_places: 'Gợi ý địa điểm',
  get_place_info: 'Tra thông tin địa điểm',
  get_ticket_prices: 'Tra giá vé',
  recommend_ticket: 'Tư vấn chọn vé',
};

function loadChat(): Msg[] {
  try {
    const raw = sessionStorage.getItem(STORE_KEY);
    return raw ? (JSON.parse(raw) as Msg[]) : [];
  } catch {
    return [];
  }
}
function saveChat(ms: Msg[]) {
  try {
    sessionStorage.setItem(STORE_KEY, JSON.stringify(ms.slice(-30)));
  } catch {
    /* het dung luong / trinh duyet chan -> bo qua */
  }
}

/* ---------------- The lo trinh ---------------- */
function mapHref(set: AssistantRouteSet) {
  const p = new URLSearchParams({ from: set.fromRef, to: set.toRef, pref: set.preference, time: set.departureTime, auto: '1' });
  if (set.fromRef.startsWith('geo:')) p.set('fromName', set.from);
  if (set.toRef.startsWith('geo:')) p.set('toName', set.to);
  return `/map?${p.toString()}`;
}

function AiRouteCard({ set }: { set: AssistantRouteSet }) {
  const [sel, setSel] = useState(0);
  const options = set.routes.slice(0, 3);
  const r = options[sel] ?? options[0];
  if (!r) return null;
  return (
    <div className="ai-route">
      <div className="ai-route-head">
        <div className="ai-route-ends">
          <span className="ai-end">
            <span className="ai-pin">A</span>
            {set.from}
          </span>
          <Icon name="chevronRight" size={16} className="muted" />
          <span className="ai-end">
            <span className="ai-pin ai-pin-b">B</span>
            {set.to}
          </span>
        </div>
        <div className="muted small">
          {PREFERENCE_META[set.preference]?.label ?? set.preference} · khởi hành {set.departureTime}
        </div>
      </div>

      <div className="ai-opts" role="tablist" aria-label="Các phương án">
        {options.map((rt, i) => (
          <button key={rt.id} role="tab" aria-selected={i === sel} className={`ai-opt${i === sel ? ' active' : ''}`} onClick={() => setSel(i)}>
            <div className="ai-opt-top">
              <b>{formatMinutes(rt.totalDuration)}</b>
              <span>{formatMoney(rt.fareToPay)}</span>
            </div>
            <div className="route-chain">
              {rt.steps.map((s, j) => (
                <span key={j} className="route-chain-item">
                  {j > 0 && <span className="chev">›</span>}
                  <span className="chain-pill" style={{ borderColor: MODE_META[s.mode].color, color: MODE_META[s.mode].color }}>
                    {MODE_META[s.mode].icon} {s.mode === 'WALK' ? `${s.duration}'` : s.routeCode}
                  </span>
                </span>
              ))}
            </div>
            <div className="muted small">
              Đi bộ {formatDistance(rt.walkingDistance)} · {rt.transfers} lần chuyển
            </div>
            {rt.labels.length > 0 && (
              <div className="ai-opt-labels">
                {rt.labels.map((l) => (
                  <span key={l} className="label-tag">
                    {PREFERENCE_META[l].label}
                  </span>
                ))}
              </div>
            )}
          </button>
        ))}
      </div>

      <ol className="ai-steps">
        {r.steps.map((st, i) => (
          <li key={i}>
            <span className="ai-step-icon" style={{ background: MODE_META[st.mode].color }} aria-hidden>
              {MODE_META[st.mode].icon}
            </span>
            <div>
              <div>{st.instruction}</div>
              <div className="muted small">
                {st.duration} phút
                {st.fare > 0 && ` · ${formatMoney(st.fare)}`}
                {st.nextDepartures?.length ? ` · chuyến kế tiếp ${st.nextDepartures.slice(0, 3).join(', ')}` : ''}
              </div>
            </div>
          </li>
        ))}
      </ol>

      <div className="ai-route-foot">
        <Link className="btn btn-primary btn-sm" to={mapHref(set)}>
          <Icon name="map" size={16} /> Xem trên bản đồ
        </Link>
      </div>
    </div>
  );
}

/* ---------------- The dia diem ---------------- */
function AiPlaces({ places }: { places: AssistantPlaceCard[] }) {
  return (
    <div className="ai-places">
      {places.map((p) => (
        <div key={p.attractionId} className="ai-place">
          <Link to={`/attractions/${p.attractionId}`} className="ai-place-img" aria-label={p.name}>
            {p.imageUrl ? <img src={p.imageUrl} alt="" loading="lazy" /> : <span>{categoryIcon(p.category, p.name)}</span>}
          </Link>
          <div className="ai-place-body">
            <div className="muted small">
              {categoryIcon(p.category, p.name)} {p.category ?? 'Địa điểm'}
            </div>
            <Link to={`/attractions/${p.attractionId}`} className="ai-place-name clamp-1">
              {p.name}
            </Link>
            {p.reason && <p className="small clamp-2">{p.reason}</p>}
            {(p.hoursSummary || p.priceFrom) && <div className="muted small clamp-1">{[p.hoursSummary, p.priceFrom].filter(Boolean).join(' · ')}</div>}
            <div className="ai-place-actions">
              <Link to={`/attractions/${p.attractionId}`}>Chi tiết</Link>
              <Link to={`/map?to=attraction:${p.attractionId}`}>Chỉ đường</Link>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

function toolSummary(tools: { name: string; ok: boolean }[]) {
  const count = new Map<string, number>();
  for (const t of tools) count.set(t.name, (count.get(t.name) ?? 0) + 1);
  return [...count.entries()].map(([n, c]) => `${TOOL_LABEL[n] ?? n}${c > 1 ? ` ×${c}` : ''}`).join(' · ');
}

/* ============================== Trang ============================== */
export default function AssistantPage() {
  const { user } = useAuth();
  const [messages, setMessages] = useState<Msg[]>(loadChat);
  const [input, setInput] = useState('');
  const [busy, setBusy] = useState(false);
  const [loc, setLoc] = useState<{ latitude: number; longitude: number } | null>(null);
  const [locState, setLocState] = useState<'off' | 'locating' | 'on' | 'error'>('off');
  const [listening, setListening] = useState(false);
  const [configured, setConfigured] = useState(true);
  const recRef = useRef<any>(null);
  const endRef = useRef<HTMLDivElement>(null);
  const taRef = useRef<HTMLTextAreaElement>(null);

  const SpeechRec = typeof window !== 'undefined' ? (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition : null;

  useEffect(() => {
    aiApi
      .status()
      .then((s) => setConfigured(s.configured))
      .catch(() => undefined);
  }, []);
  useEffect(() => saveChat(messages), [messages]);
  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: 'smooth', block: 'end' });
  }, [messages, busy]);
  useEffect(() => () => recRef.current?.abort?.(), []);

  // Textarea tu cao theo noi dung (toi da ~5 dong)
  useEffect(() => {
    const ta = taRef.current;
    if (!ta) return;
    ta.style.height = 'auto';
    ta.style.height = `${Math.min(ta.scrollHeight, 140)}px`;
  }, [input]);

  async function send(text: string, base: Msg[] = messages) {
    const q = text.trim();
    if (!q || busy) return;
    const history: AssistantHistoryItem[] = base
      .filter((m) => !m.retry)
      .slice(-12)
      .map((m) => ({
        role: m.role,
        text: m.text,
        routes: m.routes?.map((r) => ({ from: r.from, to: r.to, fromRef: r.fromRef, toRef: r.toRef, preference: r.preference })),
      }));
    setMessages([...base, { id: uid(), role: 'user', text: q }]);
    setInput('');
    setBusy(true);
    try {
      const r = await aiApi.chat(q, history, loc);
      setMessages((ms) => [
        ...ms,
        {
          id: uid(),
          role: 'assistant',
          text: r.reply,
          routes: r.routes,
          places: r.places,
          ticketAdvice: r.ticketAdvice,
          tools: r.toolCalls,
          meta: `${(r.elapsedMs / 1000).toFixed(1).replace('.', ',')} giây${r.model ? ` · ${r.model}` : ''}`,
        },
      ]);
    } catch (e) {
      if (e instanceof ApiError && e.errorCode === 'AI_NOT_CONFIGURED') setConfigured(false);
      setMessages((ms) => [...ms, { id: uid(), role: 'assistant', text: errorMessage(e), retry: q }]);
    } finally {
      setBusy(false);
      taRef.current?.focus();
    }
  }

  const retry = (m: Msg) => {
    // Bo cau hoi loi + thong bao loi roi hoi lai
    const idx = messages.findIndex((x) => x.id === m.id);
    const base = messages.slice(0, Math.max(0, idx - 1));
    send(m.retry!, base);
  };

  const onSubmit = (e: FormEvent) => {
    e.preventDefault();
    send(input);
  };
  const onKeyDown = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey && !e.nativeEvent.isComposing) {
      e.preventDefault();
      send(input);
    }
  };

  const toggleLocation = () => {
    if (locState === 'on') {
      setLoc(null);
      setLocState('off');
      return;
    }
    if (!navigator.geolocation) return setLocState('error');
    setLocState('locating');
    navigator.geolocation.getCurrentPosition(
      (p) => {
        setLoc({ latitude: p.coords.latitude, longitude: p.coords.longitude });
        setLocState('on');
      },
      () => setLocState('error'),
      { timeout: 8000, enableHighAccuracy: true },
    );
  };

  const toggleMic = () => {
    if (!SpeechRec) return;
    if (listening) {
      recRef.current?.stop();
      return;
    }
    const rec = new SpeechRec();
    rec.lang = 'vi-VN';
    rec.interimResults = true;
    rec.continuous = false;
    const prefix = input.trim() ? `${input.trim()} ` : '';
    rec.onresult = (ev: any) => {
      let t = '';
      for (let i = 0; i < ev.results.length; i++) t += ev.results[i][0].transcript;
      setInput(prefix + t);
    };
    rec.onend = () => setListening(false);
    rec.onerror = () => setListening(false);
    recRef.current = rec;
    setListening(true);
    rec.start();
  };

  const reset = () => {
    setMessages([]);
    setInput('');
  };

  const locLabel =
    locState === 'on' ? 'Đang dùng vị trí của bạn' : locState === 'locating' ? 'Đang định vị…' : locState === 'error' ? 'Không lấy được vị trí' : 'Dùng vị trí của tôi';
  const firstName = user?.fullName.split(' ').slice(-1)[0];

  return (
    <div className="page ai-page">
      <div className="ai-shell">
        <header className="ai-head">
          <div className="ai-head-icon" aria-hidden>
            <Icon name="sparkles" size={22} />
          </div>
          <div className="ai-head-text">
            <h1>Trợ lý HanoiGo</h1>
            <p className="muted small">Hỏi đường bằng tiếng Việt. Lộ trình, giờ xe và giá vé lấy từ dữ liệu thật của hệ thống.</p>
          </div>
          {messages.length > 0 && (
            <button className="btn btn-ghost btn-sm" onClick={reset} disabled={busy}>
              <Icon name="plus" size={16} /> Cuộc trò chuyện mới
            </button>
          )}
        </header>

        {!configured && (
          <div className="alert alert-warn">
            Trợ lý AI chưa được bật trên máy chủ: thêm <code>GEMINI_API_KEY</code> vào <code>backend/.env.local</code> rồi khởi động lại backend.
          </div>
        )}

        <div className="ai-thread" aria-live="polite">
          {messages.length === 0 ? (
            <div className="ai-welcome">
              <div className="ai-welcome-badge" aria-hidden>
                <Icon name="sparkles" size={28} />
              </div>
              <h2>Xin chào{firstName ? `, ${firstName}` : ''}! Hôm nay bạn muốn đi đâu?</h2>
              <p className="muted">
                Mình tìm lộ trình xe buýt, Metro, xe đạp và xe điện công cộng, lên lịch tham quan nhiều điểm, gợi ý địa điểm theo sở thích và tra giá vé.
              </p>
              <div className="ai-examples">
                {EXAMPLES.map((ex) => (
                  <button key={ex.text} className="ai-example" onClick={() => send(ex.text)} disabled={busy}>
                    <Icon name={ex.icon} size={18} />
                    <span>{ex.text}</span>
                  </button>
                ))}
              </div>
            </div>
          ) : (
            messages.map((m) =>
              m.role === 'user' ? (
                <div key={m.id} className="ai-msg ai-msg-user">
                  <div className="ai-bubble">{m.text}</div>
                </div>
              ) : (
                <div key={m.id} className="ai-msg ai-msg-bot">
                  <div className="ai-avatar" aria-hidden>
                    <Icon name="sparkles" size={16} />
                  </div>
                  <div className="ai-bot-col">
                    <div className={`ai-bubble${m.retry ? ' ai-bubble-error' : ''}`}>
                      <RichText text={m.text} />
                      {m.retry && (
                        <button className="btn btn-ghost btn-sm" onClick={() => retry(m)} disabled={busy}>
                          Thử lại
                        </button>
                      )}
                    </div>
                    {m.routes?.map((set) => <AiRouteCard key={set.id} set={set} />)}
                    {m.places && m.places.length > 0 && <AiPlaces places={m.places} />}
                    {m.ticketAdvice && m.ticketAdvice.items.length > 0 && <TicketAdviceView a={m.ticketAdvice} compact />}
                    {(m.tools?.length || m.meta) && (
                      <div className="ai-meta">
                        {m.tools && m.tools.length > 0 && <span>Đã tra: {toolSummary(m.tools)}</span>}
                        {m.meta && <span>{m.meta}</span>}
                      </div>
                    )}
                  </div>
                </div>
              ),
            )
          )}
          {busy && (
            <div className="ai-msg ai-msg-bot">
              <div className="ai-avatar" aria-hidden>
                <Icon name="sparkles" size={16} />
              </div>
              <div className="ai-bubble ai-typing">
                <span className="ai-dots" aria-hidden>
                  <i />
                  <i />
                  <i />
                </span>
                <span className="muted small">Đang tra dữ liệu và tìm lộ trình…</span>
              </div>
            </div>
          )}
          <div ref={endRef} />
        </div>

        <form className="ai-composer" onSubmit={onSubmit}>
          <div className="ai-composer-tools">
            <button
              type="button"
              className={`ai-chip${locState === 'on' ? ' on' : ''}${locState === 'error' ? ' err' : ''}`}
              onClick={toggleLocation}
              disabled={locState === 'locating'}
              aria-pressed={locState === 'on'}
            >
              <Icon name="locate" size={15} /> {locLabel}
            </button>
          </div>
          <div className="ai-input-row">
            <textarea
              ref={taRef}
              rows={1}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={onKeyDown}
              maxLength={1000}
              placeholder={listening ? 'Đang nghe… hãy nói điểm đi và điểm đến' : 'Ví dụ: Từ ga Cát Linh đến Hồ Tây lúc 17:00, ít chuyển tuyến'}
              aria-label="Câu hỏi cho trợ lý"
            />
            {SpeechRec && (
              <button
                type="button"
                className={`ai-icon-btn${listening ? ' rec' : ''}`}
                onClick={toggleMic}
                aria-label={listening ? 'Dừng nghe' : 'Nói bằng giọng'}
                title={listening ? 'Dừng nghe' : 'Nói bằng giọng (tiếng Việt)'}
              >
                <Icon name={listening ? 'stop' : 'mic'} size={20} />
              </button>
            )}
            <button type="submit" className="ai-send" disabled={!input.trim() || busy} aria-label="Gửi">
              <Icon name="send" size={20} />
            </button>
          </div>
          <p className="ai-disclaimer">Trợ lý dùng Google Gemini để hiểu câu hỏi; lộ trình và giá vé do hệ thống HanoiGo tính. Giờ xe là giờ theo lịch.</p>
        </form>
      </div>
    </div>
  );
}
