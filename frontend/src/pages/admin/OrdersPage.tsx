/** Quan ly don hang + thanh toan */
import { useEffect, useState } from 'react';
import { adminApi } from '../../services/adminApi';
import { errorMessage } from '../../services/api';
import { ErrorBox, Loading, StatusBadge } from '../../components/Feedback';
import { Modal } from '../../components/Modal';
import { formatDateTime, formatMoney } from '../../utils/format';
import { STATUS_LABEL } from '../../utils/modes';
import { Order, Paginated } from '../../types';
import { Pager } from './Pager';

export default function OrdersPage() {
  const [q, setQ] = useState({ search: '', status: '', page: 1 });
  const [data, setData] = useState<Paginated<Order> | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [detail, setDetail] = useState<Order | null>(null);

  const load = () =>
    adminApi
      .orders({ ...q, pageSize: 15 })
      .then(setData)
      .catch((e) => setError(errorMessage(e)));

  useEffect(() => {
    const t = setTimeout(load, 250);
    return () => clearTimeout(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [q]);

  const open = async (id: number) => setDetail(await adminApi.order(id));
  const cancel = async (id: number) => {
    if (!confirm(`Hủy đơn #${id}?`)) return;
    try {
      await adminApi.cancelOrder(id);
      setDetail(null);
      load();
    } catch (e) {
      alert(errorMessage(e));
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-head">
        <h1>Đơn hàng</h1>
      </div>
      <div className="toolbar">
        <input className="input" placeholder="🔎 Mã đơn, email, tên..." value={q.search} onChange={(e) => setQ({ ...q, search: e.target.value, page: 1 })} />
        <select className="input" value={q.status} onChange={(e) => setQ({ ...q, status: e.target.value, page: 1 })}>
          <option value="">Trạng thái: tất cả</option>
          <option value="PENDING">Chờ thanh toán</option>
          <option value="PAID">Đã thanh toán</option>
          <option value="CANCELLED">Đã hủy</option>
        </select>
      </div>
      {error && <ErrorBox message={error} />}
      {!data ? (
        <Loading />
      ) : (
        <div className="table-wrap card">
          <table className="table">
            <thead>
              <tr>
                <th>Mã</th>
                <th>Khách hàng</th>
                <th>Nội dung</th>
                <th>Thời gian</th>
                <th className="right">Số tiền</th>
                <th>Thanh toán</th>
                <th>Trạng thái</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {data.items.map((o) => (
                <tr key={o.orderId}>
                  <td>#{o.orderId}</td>
                  <td>
                    {o.userName}
                    <div className="muted small">{o.userEmail}</div>
                  </td>
                  <td className="small">{o.itemsSummary}</td>
                  <td>{formatDateTime(o.createdAt)}</td>
                  <td className="right">{formatMoney(o.totalAmount)}</td>
                  <td>{o.paymentStatus ? <StatusBadge status={o.paymentStatus} label={STATUS_LABEL[o.paymentStatus]} /> : '—'}</td>
                  <td>
                    <StatusBadge status={o.status} label={STATUS_LABEL[o.status]} />
                  </td>
                  <td className="right">
                    <button className="btn btn-xs btn-ghost" onClick={() => open(o.orderId)}>
                      Chi tiết
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pager page={data.page} totalPages={data.totalPages} total={data.total} onChange={(page) => setQ({ ...q, page })} />
        </div>
      )}

      {detail && (
        <Modal title={`Đơn hàng #${detail.orderId}`} onClose={() => setDetail(null)} wide>
          <p>
            <strong>{detail.userName}</strong> · {detail.userEmail} · {formatDateTime(detail.createdAt)}
          </p>
          <table className="table">
            <thead>
              <tr>
                <th>Loại vé</th>
                <th className="right">SL</th>
                <th className="right">Đơn giá</th>
                <th className="right">Thành tiền</th>
              </tr>
            </thead>
            <tbody>
              {detail.items?.map((i) => (
                <tr key={i.orderDetailId}>
                  <td>{i.ticketTypeName}</td>
                  <td className="right">{i.quantity}</td>
                  <td className="right">{formatMoney(i.unitPrice)}</td>
                  <td className="right">{formatMoney(i.subtotal)}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <h4>Thanh toán</h4>
          <ul className="plain-list small">
            {detail.payments?.map((p) => (
              <li key={p.paymentId}>
                #{p.paymentId} · {p.paymentMethod === 'BANK_TRANSFER' ? `Chuyển khoản ${p.transferContent ?? ''}` : p.paymentMethod === 'CARD' ? `Thẻ ${p.cardBrand ?? ''} •••• ${p.cardLast4 ?? ''}` : p.paymentMethod} ·{' '}
                {formatMoney(p.amount)} · <StatusBadge status={p.status} label={STATUS_LABEL[p.status]} /> ·{' '}
                <span className="mono">{p.transactionCode ?? '—'}</span> · {formatDateTime(p.paidAt)}
              </li>
            ))}
            {detail.payments?.length === 0 && <li className="muted">Chưa có giao dịch</li>}
          </ul>
          <h4>Vé đã phát hành</h4>
          <ul className="plain-list small">
            {detail.tickets?.map((t) => (
              <li key={t.ticketId}>
                <span className="mono">{t.ticketCode}</span> · <StatusBadge status={t.status} label={STATUS_LABEL[t.status]} /> · đến{' '}
                {formatDateTime(t.validTo)}
              </li>
            ))}
            {detail.tickets?.length === 0 && <li className="muted">Chưa có vé</li>}
          </ul>
          {detail.status === 'PENDING' && (
            <button className="btn btn-ghost danger" onClick={() => cancel(detail.orderId)}>
              Hủy đơn
            </button>
          )}
        </Modal>
      )}
    </div>
  );
}
