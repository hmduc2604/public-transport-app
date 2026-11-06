/** Quan ly ve + Soat ve bang noi dung QR */
import { FormEvent, useEffect, useState } from 'react';
import { adminApi } from '../../services/adminApi';
import { errorMessage } from '../../services/api';
import { ErrorBox, Loading, StatusBadge } from '../../components/Feedback';
import { formatDateTime } from '../../utils/format';
import { STATUS_LABEL } from '../../utils/modes';
import { Paginated, Ticket } from '../../types';
import { Pager } from './Pager';

export default function TicketsAdminPage() {
  const [q, setQ] = useState({ search: '', status: '', type: '', page: 1 });
  const [data, setData] = useState<Paginated<Ticket> | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [qrData, setQrData] = useState('');
  const [verify, setVerify] = useState<{ valid: boolean; reason: string; ticket: Ticket | null } | null>(null);

  const load = () =>
    adminApi
      .tickets({ ...q, pageSize: 15 })
      .then(setData)
      .catch((e) => setError(errorMessage(e)));

  useEffect(() => {
    const t = setTimeout(load, 250);
    return () => clearTimeout(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [q]);

  const doVerify = async (e: FormEvent) => {
    e.preventDefault();
    try {
      setVerify(await adminApi.verifyTicket(qrData.trim()));
      load();
    } catch (err) {
      setVerify({ valid: false, reason: errorMessage(err), ticket: null });
    }
  };

  const setStatus = async (t: Ticket, status: string) => {
    try {
      await adminApi.updateTicketStatus(t.ticketId, status);
      load();
    } catch (e) {
      alert(errorMessage(e));
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-head">
        <h1>Vé & Soát vé</h1>
      </div>

      <form className="card verify-box" onSubmit={doVerify}>
        <h3>Soát vé</h3>
        <p className="muted small">Dán nội dung QR (dạng PTA|TK-...|XXXXXXXX) hoặc mã vé. Vé lượt hợp lệ sẽ được đánh dấu ĐÃ DÙNG.</p>
        <div className="row gap">
          <input className="input grow mono" value={qrData} onChange={(e) => setQrData(e.target.value)} placeholder="PTA|TK-261106-ABC123|1A2B3C4D" required />
          <button className="btn btn-primary">Kiểm tra</button>
        </div>
        {verify && (
          <div className={`alert ${verify.valid ? 'alert-success' : 'alert-error'}`}>
            <strong>{verify.valid ? '✓ HỢP LỆ' : '✕ KHÔNG HỢP LỆ'}</strong> — {verify.reason}
            {verify.ticket && (
              <div className="small">
                {verify.ticket.ticketTypeName} · {verify.ticket.userName} · hiệu lực đến {formatDateTime(verify.ticket.validTo)}
              </div>
            )}
          </div>
        )}
      </form>

      <div className="toolbar">
        <input className="input" placeholder="🔎 Mã vé, email..." value={q.search} onChange={(e) => setQ({ ...q, search: e.target.value, page: 1 })} />
        <select className="input" value={q.status} onChange={(e) => setQ({ ...q, status: e.target.value, page: 1 })}>
          <option value="">Trạng thái: tất cả</option>
          {['ACTIVE', 'USED', 'EXPIRED', 'CANCELLED'].map((s) => (
            <option key={s} value={s}>
              {STATUS_LABEL[s]}
            </option>
          ))}
        </select>
        <select className="input" value={q.type} onChange={(e) => setQ({ ...q, type: e.target.value, page: 1 })}>
          <option value="">Kiểu: tất cả</option>
          <option value="SINGLE">Vé lượt</option>
          <option value="MONTHLY">Vé tháng</option>
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
                <th>Mã vé</th>
                <th>Loại</th>
                <th>Khách hàng</th>
                <th>Hiệu lực</th>
                <th>Trạng thái</th>
                <th className="right">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {data.items.map((t) => (
                <tr key={t.ticketId}>
                  <td className="mono small">{t.ticketCode}</td>
                  <td>{t.ticketTypeName}</td>
                  <td>
                    {t.userName}
                    <div className="muted small">{t.userEmail}</div>
                  </td>
                  <td className="small">
                    {formatDateTime(t.validFrom)} → {formatDateTime(t.validTo)}
                  </td>
                  <td>
                    <StatusBadge status={t.status} label={STATUS_LABEL[t.status]} />
                  </td>
                  <td className="right">
                    {t.status === 'ACTIVE' && (
                      <button className="btn btn-xs btn-ghost danger" onClick={() => setStatus(t, 'CANCELLED')}>
                        Hủy vé
                      </button>
                    )}
                    {t.status === 'CANCELLED' && (
                      <button className="btn btn-xs btn-ghost" onClick={() => setStatus(t, 'ACTIVE')}>
                        Khôi phục
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pager page={data.page} totalPages={data.totalPages} total={data.total} onChange={(page) => setQ({ ...q, page })} />
        </div>
      )}
    </div>
  );
}
