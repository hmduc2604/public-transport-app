/**
 * Chon phuong thuc thanh toan cho don hang:
 *   - The ngan hang  -> /payment/:orderId/card
 *   - Chuyen khoan QR -> /payment/:orderId/transfer
 */
import { Link, useNavigate, useParams } from 'react-router-dom';
import { ticketApi } from '../services/ticketApi';
import { paymentApi } from '../services/paymentApi';
import { useAsync } from '../utils/useAsync';
import { ErrorBox, Loading } from '../components/Feedback';
import { OrderSummary } from '../components/payment/OrderSummary';
import { PaymentSuccess } from '../components/payment/PaymentSuccess';
import { formatDateTime } from '../utils/format';

export default function PaymentPage() {
  const { orderId } = useParams();
  const navigate = useNavigate();
  const { data: order, loading, error } = useAsync(() => ticketApi.order(Number(orderId)), [orderId]);
  const { data: methods } = useAsync(() => paymentApi.methods(), []);

  const cancel = async () => {
    await ticketApi.cancelOrder(Number(orderId)).catch(() => undefined);
    navigate('/tickets/buy');
  };

  if (loading) return <Loading />;
  if (error || !order) return <div className="page"><ErrorBox message={error ?? 'Không tìm thấy đơn'} /></div>;

  if (order.status === 'PAID') {
    return <PaymentSuccess orderId={order.orderId} amount={order.totalAmount} ticketIds={order.tickets?.map((t) => t.ticketId) ?? []} />;
  }

  const pendingTransfer = order.payments?.find((p) => p.paymentMethod === 'BANK_TRANSFER' && p.status === 'PENDING');
  const lastFailedCard = order.payments?.[0]?.paymentMethod === 'CARD' && order.payments[0].status === 'FAILED' ? order.payments[0] : null;
  const transferOn = methods?.bankTransfer.enabled ?? true;

  return (
    <div className="page narrow">
      <h1>Thanh toán</h1>
      <OrderSummary order={order} />

      {order.status === 'CANCELLED' ? (
        <div className="alert alert-error">
          <span>
            Đơn hàng đã bị hủy. <Link to="/tickets/buy">Mua vé mới</Link>
          </span>
        </div>
      ) : (
        <div className="card">
          <h3>Chọn phương thức thanh toán</h3>
          {pendingTransfer && (
            <div className="alert alert-warn">
              <span>
                Bạn có mã chuyển khoản <b className="mono">{pendingTransfer.transferContent}</b> đang chờ (hạn {formatDateTime(pendingTransfer.expiresAt)}).
              </span>
              <Link className="btn btn-sm btn-ghost" to={`/payment/${order.orderId}/transfer`}>
                Tiếp tục chuyển khoản
              </Link>
            </div>
          )}
          {lastFailedCard && (
            <div className="alert alert-error">
              Giao dịch thẻ •••• {lastFailedCard.cardLast4} bị từ chối{lastFailedCard.note ? `: ${lastFailedCard.note}` : ''}. Vui lòng thử lại.
            </div>
          )}
          <div className="pay-options">
            <Link to={`/payment/${order.orderId}/card`} className="pay-option">
              <span className="pay-option-icon" aria-hidden>
                💳
              </span>
              <span className="pay-option-text">
                <strong>Thẻ ngân hàng</strong>
                <span className="small muted">Visa, Mastercard, JCB, AMEX hoặc thẻ ATM nội địa (NAPAS)</span>
                <span className="pay-option-tags">
                  <span className="tag">Vé phát hành ngay</span>
                </span>
              </span>
              <span className="pay-option-go" aria-hidden>
                ›
              </span>
            </Link>
            {transferOn ? (
              <Link to={`/payment/${order.orderId}/transfer`} className="pay-option">
                <span className="pay-option-icon" aria-hidden>
                  🏦
                </span>
                <span className="pay-option-text">
                  <strong>Chuyển khoản QR</strong>
                  <span className="small muted">
                    Quét mã VietQR bằng app ngân hàng bất kỳ{methods?.bankTransfer.bankName ? ` · nhận tiền tại ${methods.bankTransfer.bankName}` : ''}
                  </span>
                  <span className="pay-option-tags">
                    <span className="tag">Vé phát hành khi tiền về tài khoản</span>
                  </span>
                </span>
                <span className="pay-option-go" aria-hidden>
                  ›
                </span>
              </Link>
            ) : (
              <div className="pay-option disabled" aria-disabled>
                <span className="pay-option-icon" aria-hidden>
                  🏦
                </span>
                <span className="pay-option-text">
                  <strong>Chuyển khoản QR</strong>
                  <span className="small muted">Tạm chưa mở: quản trị viên chưa cài đặt tài khoản nhận tiền.</span>
                </span>
              </div>
            )}
          </div>
          <div className="row end">
            <button className="btn btn-ghost danger btn-sm" onClick={cancel}>
              Hủy đơn
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
