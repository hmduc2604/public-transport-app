/** Thanh toan mo phong: Payment SUCCESS -> sinh ve + QR */
import { useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { ticketApi } from '../services/ticketApi';
import { paymentApi } from '../services/paymentApi';
import { errorMessage } from '../services/api';
import { useAsync } from '../utils/useAsync';
import { ErrorBox, Loading, StatusBadge } from '../components/Feedback';
import { formatDateTime, formatMoney } from '../utils/format';
import { STATUS_LABEL } from '../utils/modes';
import { PaymentResult } from '../types';

const METHODS = [
  { id: 'wallet', label: 'Ví điện tử (mô phỏng)', icon: '📱' },
  { id: 'card', label: 'Thẻ ngân hàng (mô phỏng)', icon: '💳' },
  { id: 'qr', label: 'Chuyển khoản QR (mô phỏng)', icon: '🏦' },
];

export default function PaymentPage() {
  const { orderId } = useParams();
  const navigate = useNavigate();
  const { data: order, loading, error, reload } = useAsync(() => ticketApi.order(Number(orderId)), [orderId]);
  const [method, setMethod] = useState(METHODS[0].id);
  const [busy, setBusy] = useState(false);
  const [result, setResult] = useState<PaymentResult | null>(null);
  const [payError, setPayError] = useState<string | null>(null);

  const pay = async (simulate: 'SUCCESS' | 'FAILED') => {
    setBusy(true);
    setPayError(null);
    try {
      // Gia lap do tre cua cong thanh toan
      await new Promise((r) => setTimeout(r, 900));
      const r = await paymentApi.pay(Number(orderId), simulate);
      setResult(r);
      if (r.status === 'SUCCESS') reload();
    } catch (e) {
      setPayError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  };

  const cancel = async () => {
    await ticketApi.cancelOrder(Number(orderId)).catch(() => undefined);
    navigate('/tickets/buy');
  };

  if (loading) return <Loading />;
  if (error || !order) return <div className="page"><ErrorBox message={error ?? 'Không tìm thấy đơn'} /></div>;

  if (result?.status === 'SUCCESS' || order.status === 'PAID') {
    const ticketIds = result?.ticketIds ?? order.tickets?.map((t) => t.ticketId) ?? [];
    return (
      <div className="page narrow">
        <div className="card success-card">
          <div className="success-icon">✓</div>
          <h1>Thanh toán thành công</h1>
          <p className="muted">
            Đơn #{order.orderId} · {formatMoney(order.totalAmount)} · {ticketIds.length} vé đã được phát hành
          </p>
          <div className="row gap center-row">
            {ticketIds.length === 1 ? (
              <button className="btn btn-primary" onClick={() => navigate(`/tickets/${ticketIds[0]}`)}>
                Xem vé QR
              </button>
            ) : (
              <button className="btn btn-primary" onClick={() => navigate('/tickets')}>
                Xem vé của tôi
              </button>
            )}
            <Link to="/map" className="btn btn-ghost">
              Tiếp tục tìm đường
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="page narrow">
      <h1>Thanh toán</h1>
      <div className="card">
        <div className="row space-between">
          <strong>Đơn hàng #{order.orderId}</strong>
          <StatusBadge status={order.status} label={STATUS_LABEL[order.status]} />
        </div>
        <div className="muted small">Tạo lúc {formatDateTime(order.createdAt)}</div>
        <ul className="order-lines">
          {order.items?.map((it) => (
            <li key={it.orderDetailId}>
              <span>
                {it.ticketTypeName} × {it.quantity}
              </span>
              <span>{formatMoney(it.subtotal)}</span>
            </li>
          ))}
        </ul>
        <div className="order-total">
          <span>Tổng thanh toán</span>
          <strong>{formatMoney(order.totalAmount)}</strong>
        </div>
      </div>

      {order.status === 'CANCELLED' ? (
        <div className="alert alert-error">Đơn hàng đã bị hủy.</div>
      ) : (
        <div className="card">
          <h3>Phương thức thanh toán</h3>
          <div className="methods">
            {METHODS.map((m) => (
              <label key={m.id} className={`method${method === m.id ? ' active' : ''}`}>
                <input type="radio" name="method" checked={method === m.id} onChange={() => setMethod(m.id)} />
                <span className="method-icon">{m.icon}</span> {m.label}
              </label>
            ))}
          </div>
          <p className="muted small">Đây là thanh toán mô phỏng (MOCK) phục vụ đồ án, không trừ tiền thật.</p>
          {result?.status === 'FAILED' && <div className="alert alert-error">Giao dịch thất bại (mô phỏng). Bạn có thể thử lại.</div>}
          {payError && <ErrorBox message={payError} />}
          <div className="row gap wrap">
            <button className="btn btn-primary" disabled={busy} onClick={() => pay('SUCCESS')}>
              {busy ? 'Đang xử lý...' : `Thanh toán ${formatMoney(order.totalAmount)}`}
            </button>
            <button className="btn btn-ghost" disabled={busy} onClick={() => pay('FAILED')} title="Dùng khi demo trường hợp lỗi">
              Mô phỏng thất bại
            </button>
            <button className="btn btn-ghost danger" disabled={busy} onClick={cancel}>
              Hủy đơn
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
