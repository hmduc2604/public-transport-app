/**
 * TU VAN CHON VE (AI)
 *   - TicketAdvisor: khung nhap thoi quen di lai tren trang Mua ve -> POST /tickets/advice
 *   - TicketAdviceView: hien ket qua (dung chung cho trang Mua ve va the trong Tro ly AI)
 * So luot, gia, tien tiet kiem do he thong tinh tu bang gia + bo tim duong; AI tach thoi quen va viet giai thich.
 */
import { FormEvent, useState } from 'react';
import { Link } from 'react-router-dom';
import { aiApi } from '../services/aiApi';
import { errorMessage } from '../services/api';
import { useAuth } from '../context/AuthContext';
import { ErrorBox } from './Feedback';
import { Icon } from './Icon';
import { ModeBadge } from './ModeBadge';
import { RichText } from './RichText';
import { formatMoney } from '../utils/format';
import { TicketAdvice, TicketAdviceItem } from '../types';

const EXAMPLES = [
  'Đi làm bằng Metro, thứ 2 – thứ 6, đi về trong ngày',
  'Đi làm từ Cầu Giấy đến Hồ Hoàn Kiếm, 5 ngày/tuần',
  'Chỉ cuối tuần mới đi xe buýt vài lượt',
];

const VERDICT: Record<TicketAdviceItem['verdict'], string> = {
  BUY_PASS: 'Nên mua vé tháng',
  KEEP_SINGLE: 'Nên mua vé lượt',
  HAS_PASS: 'Đang có vé tháng',
  SINGLE_ONLY: 'Chỉ có vé lượt',
};

function AdviceItem({ it, onPick }: { it: TicketAdviceItem; onPick?: (ticketTypeId: number) => void }) {
  const passCheaper = it.pass !== null && it.saving !== null && it.saving > 0;
  return (
    <li className={`advice-item v-${it.verdict}`}>
      <div className="advice-item-head">
        <ModeBadge mode={it.mode} small />
        <strong>{it.label}</strong>
        <span className="muted small">~{it.ridesPerMonth} lượt/tháng</span>
      </div>
      <div className="advice-compare">
        <div className={!passCheaper && it.pass ? 'best' : undefined}>
          <span className="muted small">Mua vé lượt</span>
          <strong>{formatMoney(it.singleCost)}</strong>
        </div>
        <div className={passCheaper ? 'best' : undefined}>
          <span className="muted small">{it.pass ? it.pass.name : 'Vé tháng'}</span>
          <strong>{it.pass ? formatMoney(it.pass.price) : 'Chưa có'}</strong>
        </div>
      </div>
      <div className="advice-verdict">
        {VERDICT[it.verdict]}
        {it.verdict === 'BUY_PASS' && it.saving !== null && <> · tiết kiệm {formatMoney(it.saving)}</>}
        {it.verdict === 'HAS_PASS' && it.activePass && <> · còn {it.activePass.daysLeft} ngày</>}
      </div>
      {it.breakEvenRides !== null && it.verdict !== 'HAS_PASS' && (
        <span className="muted small">Vé tháng có lợi từ {it.breakEvenRides} lượt/tháng</span>
      )}
      {it.verdict === 'BUY_PASS' &&
        it.pass &&
        (onPick ? (
          <button className="btn btn-accent btn-sm" onClick={() => onPick(it.pass!.ticketTypeId)}>
            <Icon name="ticket" size={16} /> Chọn {it.pass.name}
          </button>
        ) : (
          <Link className="btn btn-accent btn-sm" to={`/tickets/buy?select=${it.pass.ticketTypeId}`}>
            <Icon name="ticket" size={16} /> Mua {it.pass.name}
          </Link>
        ))}
    </li>
  );
}

export function TicketAdviceView({ a, onPick, compact }: { a: TicketAdvice; onPick?: (ticketTypeId: number) => void; compact?: boolean }) {
  const c = a.commute;
  return (
    <div className={`advice${compact ? ' compact' : ''}`}>
      {compact && (
        <div className="advice-title">
          <Icon name="ticket" size={18} /> Tư vấn chọn vé
        </div>
      )}
      {!compact && (
        <div className="advice-summary">
          <Icon name="sparkles" size={18} />
          <RichText text={a.explanation} />
        </div>
      )}
      {a.understood.length > 0 && (
        <div className="advice-understood">
          <span className="muted small">Hệ thống hiểu:</span>
          {a.understood.map((u) => (
            <span key={u} className="chip">
              {u}
            </span>
          ))}
        </div>
      )}
      {c && !c.error && c.summary && (
        <p className="advice-commute small">
          <Icon name="route" size={16} /> Lộ trình dùng để tính: {c.summary} · {c.minutes} phút · {formatMoney(c.farePerTrip)}/chuyến · ~{c.tripsPerMonth} chuyến/tháng
          {c.fastest && (
            <>
              <br />
              Lộ trình nhanh nhất ({c.fastest.summary}, {c.fastest.minutes} phút) tốn khoảng {formatMoney(c.fastest.monthlyCost)}/tháng.
            </>
          )}
        </p>
      )}
      {a.items.length > 0 && (
        <ul className="advice-items">
          {a.items.map((it) => (
            <AdviceItem key={it.mode} it={it} onPick={onPick} />
          ))}
        </ul>
      )}
      {a.items.length > 1 && a.totals.saving > 0 && (
        <p className="advice-total">
          Tổng mỗi tháng: <strong>{formatMoney(a.totals.best)}</strong> thay vì {formatMoney(a.totals.singleOnly)} nếu chỉ mua vé lượt.
        </p>
      )}
      {a.basis === 'history' && (
        <p className="muted small">
          Dựa trên {a.history.singleTickets} vé lượt bạn đã mua trong {a.history.days} ngày qua ({formatMoney(a.history.spent)}).
        </p>
      )}
    </div>
  );
}

export function TicketAdvisor({ onPick }: { onPick?: (ticketTypeId: number) => void }) {
  const { user } = useAuth();
  const [text, setText] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<TicketAdvice | null>(null);

  const run = async (habit: string) => {
    if (busy) return;
    setBusy(true);
    setError(null);
    try {
      setResult(await aiApi.ticketAdvice(habit.trim() || undefined));
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  };
  const onSubmit = (e: FormEvent) => {
    e.preventDefault();
    if (text.trim()) run(text);
  };

  return (
    <section className="card advisor" id="tu-van" aria-labelledby="h-advisor">
      <div className="advisor-head">
        <span className="ai-head-icon" aria-hidden>
          <Icon name="sparkles" size={20} />
        </span>
        <div>
          <h2 id="h-advisor">
            Tư vấn chọn vé <span className="ai-badge">AI</span>
          </h2>
          <p className="muted small">Kể thói quen đi lại của bạn, hệ thống so vé lượt với vé tháng theo bảng giá và lộ trình thật.</p>
        </div>
      </div>

      {!user ? (
        <p className="small">
          <Link to="/login" state={{ from: '/tickets/buy#tu-van' }}>
            Đăng nhập
          </Link>{' '}
          để được tư vấn theo vé bạn đã mua và thói quen đi lại.
        </p>
      ) : (
        <>
          <form className="advisor-form" onSubmit={onSubmit}>
            <textarea
              className="input"
              rows={2}
              maxLength={500}
              placeholder="Ví dụ: Mình đi làm từ Cầu Giấy đến Hồ Gươm, thứ 2 – thứ 6, đi về trong ngày"
              value={text}
              onChange={(e) => setText(e.target.value)}
              disabled={busy}
            />
            <div className="advisor-actions">
              <button className="btn btn-primary" disabled={busy || !text.trim()}>
                <Icon name="sparkles" size={16} /> Tư vấn
              </button>
              <button type="button" className="btn btn-ghost" onClick={() => run('')} disabled={busy}>
                Dựa trên vé tôi đã mua
              </button>
            </div>
          </form>
          <div className="advisor-examples">
            {EXAMPLES.map((ex) => (
              <button
                key={ex}
                className="chip chip-btn"
                disabled={busy}
                onClick={() => {
                  setText(ex);
                  run(ex);
                }}
              >
                {ex}
              </button>
            ))}
          </div>
          {busy && (
            <div className="advisor-loading" role="status">
              <span className="spinner" aria-hidden /> Đang tính chi phí theo bảng giá và lộ trình…
            </div>
          )}
          {error && <ErrorBox message={error} />}
          {result && !busy && (
            <>
              {result.question && <div className="alert alert-info small">{result.question}</div>}
              {result.notice && <div className="alert alert-warn small">{result.notice}</div>}
              {(result.items.length > 0 || !result.question) && <TicketAdviceView a={result} onPick={onPick} />}
            </>
          )}
        </>
      )}
    </section>
  );
}
