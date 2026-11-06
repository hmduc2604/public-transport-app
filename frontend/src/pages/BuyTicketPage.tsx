/** Chon loai ve (ve luot / ve thang) -> tao Order -> chuyen sang trang thanh toan */
import { useEffect, useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { ticketApi } from '../services/ticketApi';
import { errorMessage } from '../services/api';
import { useAsync } from '../utils/useAsync';
import { useAuth } from '../context/AuthContext';
import { ErrorBox, Loading } from '../components/Feedback';
import { ModeBadge } from '../components/ModeBadge';
import { TicketType, TransportMode } from '../types';
import { durationLabel, formatMoney } from '../utils/format';
import { MODE_META } from '../utils/modes';

export default function BuyTicketPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const routeModes = useMemo(
    () => new Set((params.get('modes') ?? '').split(',').filter(Boolean) as TransportMode[]),
    [params],
  );

  const { data: types, loading, error, reload } = useAsync(() => ticketApi.ticketTypes(), []);
  const [qty, setQty] = useState<Record<number, number>>({});
  const [initialized, setInitialized] = useState(false);
  const [busy, setBusy] = useState(false);
  const [submitError, setSubmitError] = useState<string | null>(null);

  // Den tu trang tim duong: tu chon san 1 ve luot cho moi phuong tien trong lo trinh
  useEffect(() => {
    if (!types || initialized) return;
    const init: Record<number, number> = {};
    for (const m of routeModes) {
      const t = types.find((x) => x.mode === m && x.type === 'SINGLE');
      if (t) init[t.ticketTypeId] = 1;
    }
    setQty(init);
    setInitialized(true);
  }, [types, initialized, routeModes]);

  const items = Object.entries(qty)
    .filter(([, q]) => q > 0)
    .map(([id, q]) => ({ ticketTypeId: Number(id), quantity: q }));
  const total = items.reduce((s, it) => s + (types?.find((t) => t.ticketTypeId === it.ticketTypeId)?.price ?? 0) * it.quantity, 0);

  const change = (t: TicketType, delta: number) =>
    setQty((q) => {
      const max = t.type === 'MONTHLY' ? 1 : 10;
      return { ...q, [t.ticketTypeId]: Math.max(0, Math.min(max, (q[t.ticketTypeId] ?? 0) + delta)) };
    });

  const checkout = async () => {
    if (!user) return navigate('/login', { state: { from: `/tickets/buy?${params.toString()}` } });
    setBusy(true);
    setSubmitError(null);
    try {
      const order = await ticketApi.createOrder(items);
      navigate(`/payment/${order.orderId}`);
    } catch (e) {
      setSubmitError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  };

  if (loading) return <Loading />;
  if (error) return <div className="page"><ErrorBox message={error} onRetry={reload} /></div>;

  const groups: { title: string; type: 'SINGLE' | 'MONTHLY'; desc: string }[] = [
    { title: 'Vé lượt', type: 'SINGLE', desc: 'Dùng cho một chuyến đi, hiệu lực trong thời gian quy định' },
    { title: 'Vé tháng', type: 'MONTHLY', desc: 'Đi không giới hạn 30 ngày · tự động miễn phí khi tìm đường' },
  ];

  return (
    <div className="page buy-page">
      <h1>Mua vé</h1>
      {routeModes.size > 0 && (
        <div className="alert alert-info">
          Đã chọn sẵn vé lượt cho lộ trình của bạn:{' '}
          {[...routeModes].map((m) => (
            <ModeBadge key={m} mode={m} small />
          ))}
        </div>
      )}
      <div className="buy-grid">
        <div>
          {groups.map((g) => (
            <section key={g.type} className="section">
              <h2>{g.title}</h2>
              <p className="muted small">{g.desc}</p>
              <div className="ticket-type-grid">
                {types
                  ?.filter((t) => t.type === g.type)
                  .map((t) => (
                    <div key={t.ticketTypeId} className={`ticket-type${(qty[t.ticketTypeId] ?? 0) > 0 ? ' chosen' : ''}`}>
                      <div className="ticket-type-head" style={{ background: MODE_META[t.mode].color }}>
                        <span>{MODE_META[t.mode].icon}</span>
                        <span>{durationLabel(t.durationMinutes)}</span>
                      </div>
                      <div className="ticket-type-body">
                        <strong>{t.name}</strong>
                        <div className="muted small">{t.description}</div>
                        <div className="ticket-type-foot">
                          <span className="price">{formatMoney(t.price)}</span>
                          <div className="qty">
                            <button onClick={() => change(t, -1)} aria-label="Bớt">−</button>
                            <span>{qty[t.ticketTypeId] ?? 0}</span>
                            <button onClick={() => change(t, 1)} aria-label="Thêm">+</button>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
              </div>
            </section>
          ))}
        </div>
        <aside className="card checkout">
          <h3>Đơn hàng</h3>
          {items.length === 0 ? (
            <p className="muted">Chưa chọn vé nào</p>
          ) : (
            <ul className="order-lines">
              {items.map((it) => {
                const t = types!.find((x) => x.ticketTypeId === it.ticketTypeId)!;
                return (
                  <li key={it.ticketTypeId}>
                    <span>
                      {t.name} × {it.quantity}
                    </span>
                    <span>{formatMoney(t.price * it.quantity)}</span>
                  </li>
                );
              })}
            </ul>
          )}
          <div className="order-total">
            <span>Tổng cộng</span>
            <strong>{formatMoney(total)}</strong>
          </div>
          {submitError && <ErrorBox message={submitError} />}
          <button className="btn btn-primary btn-block" disabled={items.length === 0 || busy} onClick={checkout}>
            {busy ? 'Đang tạo đơn...' : user ? 'Tiếp tục thanh toán' : 'Đăng nhập để mua'}
          </button>
        </aside>
      </div>
    </div>
  );
}
