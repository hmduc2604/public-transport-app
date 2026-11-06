/** Lich su chuyen di + lich su mua ve */
import { useState } from 'react';
import { Link } from 'react-router-dom';
import { ticketApi } from '../services/ticketApi';
import { useAsync } from '../utils/useAsync';
import { Empty, ErrorBox, Loading, StatusBadge } from '../components/Feedback';
import { formatDateTime, formatMinutes, formatMoney } from '../utils/format';
import { STATUS_LABEL } from '../utils/modes';

export default function HistoryPage() {
  const [tab, setTab] = useState<'trips' | 'orders'>('trips');
  const trips = useAsync(() => ticketApi.tripHistories(), []);
  const orders = useAsync(() => ticketApi.myOrders(), []);

  const remove = async (id: number) => {
    await ticketApi.deleteTrip(id);
    trips.reload();
  };

  return (
    <div className="page narrow">
      <h1>Lịch sử</h1>
      <div className="tabs">
        <button className={`tab${tab === 'trips' ? ' active' : ''}`} onClick={() => setTab('trips')}>
          Chuyến đi
        </button>
        <button className={`tab${tab === 'orders' ? ' active' : ''}`} onClick={() => setTab('orders')}>
          Mua vé
        </button>
      </div>

      {tab === 'trips' &&
        (trips.loading ? (
          <Loading />
        ) : trips.error ? (
          <ErrorBox message={trips.error} onRetry={trips.reload} />
        ) : trips.data && trips.data.length > 0 ? (
          <ul className="history-list">
            {trips.data.map((t) => (
              <li key={t.tripHistoryId} className="card history-item">
                <div className="history-route">
                  <span className="loc-marker loc-marker-A">A</span> {t.origin}
                  <span className="chev">→</span>
                  <span className="loc-marker loc-marker-B">B</span> {t.destination}
                </div>
                <div className="muted small">
                  {formatDateTime(t.startedAt)}
                  {t.routeData?.route && <> · {t.routeData.route}</>}
                  {t.routeData?.duration && <> · {formatMinutes(t.routeData.duration)}</>}
                  {t.routeData?.transfers !== undefined && <> · {t.routeData.transfers} lần chuyển</>}
                </div>
                <button className="icon-btn" onClick={() => remove(t.tripHistoryId)} aria-label="Xóa">
                  🗑
                </button>
              </li>
            ))}
          </ul>
        ) : (
          <Empty icon="🧭" title="Chưa có chuyến đi nào">
            <Link to="/map" className="btn btn-primary">
              Tìm đường
            </Link>
          </Empty>
        ))}

      {tab === 'orders' &&
        (orders.loading ? (
          <Loading />
        ) : orders.error ? (
          <ErrorBox message={orders.error} onRetry={orders.reload} />
        ) : orders.data && orders.data.length > 0 ? (
          <div className="table-wrap card">
            <table className="table">
              <thead>
                <tr>
                  <th>Mã đơn</th>
                  <th>Thời gian</th>
                  <th>Nội dung</th>
                  <th className="right">Số tiền</th>
                  <th>Trạng thái</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {orders.data.map((o) => (
                  <tr key={o.orderId}>
                    <td>#{o.orderId}</td>
                    <td>{formatDateTime(o.createdAt)}</td>
                    <td className="small">{o.itemsSummary}</td>
                    <td className="right">{formatMoney(o.totalAmount)}</td>
                    <td>
                      <StatusBadge status={o.status} label={STATUS_LABEL[o.status]} />
                    </td>
                    <td>
                      {o.status === 'PENDING' && (
                        <Link to={`/payment/${o.orderId}`} className="btn btn-xs btn-primary">
                          Thanh toán
                        </Link>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <Empty icon="🧾" title="Chưa có đơn hàng" />
        ))}
    </div>
  );
}
