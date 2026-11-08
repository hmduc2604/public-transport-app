import { Link, useNavigate } from 'react-router-dom';
import { formatMoney } from '../../utils/format';

export function PaymentSuccess({
  orderId,
  amount,
  ticketIds,
  detail,
}: {
  orderId: number;
  amount: number;
  ticketIds: number[];
  detail?: string;
}) {
  const navigate = useNavigate();
  return (
    <div className="page narrow">
      <div className="card success-card">
        <div className="success-icon">✓</div>
        <h1>Thanh toán thành công</h1>
        <p className="muted">
          Đơn #{orderId} · {formatMoney(amount)} · {ticketIds.length} vé đã được phát hành
        </p>
        {detail && <p className="small muted">{detail}</p>}
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
