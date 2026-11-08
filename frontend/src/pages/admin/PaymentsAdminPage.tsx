/**
 * Quan tri > Thanh toan
 *  - Tai khoan ngan hang NHAN tien chuyen khoan (dung de tao ma VietQR)
 *  - Danh sach giao dich: doi soat chuyen khoan -> Xac nhan da nhan tien (phat hanh ve) / Tu choi
 */
import { FormEvent, useEffect, useState } from 'react';
import { adminApi } from '../../services/adminApi';
import { errorMessage } from '../../services/api';
import { ErrorBox, Loading, StatusBadge } from '../../components/Feedback';
import { Modal } from '../../components/Modal';
import { formatDateTime, formatMoney } from '../../utils/format';
import { AdminPayment, Paginated, PaymentSettings } from '../../types';
import { Pager } from './Pager';

const PAY_STATUS: Record<string, string> = {
  PENDING: 'Chờ xác nhận',
  SUCCESS: 'Thành công',
  FAILED: 'Thất bại',
  EXPIRED: 'Hết hạn',
  CANCELLED: 'Đã hủy',
};
const METHOD_LABEL: Record<string, string> = { CARD: '💳 Thẻ', BANK_TRANSFER: '🏦 Chuyển khoản', MOCK: 'Mô phỏng (cũ)' };

function SettingsCard() {
  const [s, setS] = useState<PaymentSettings | null>(null);
  const [form, setForm] = useState({ bankBin: '', accountNo: '', accountName: '', transferExpiryMinutes: 30 });
  const [msg, setMsg] = useState<{ ok: boolean; text: string } | null>(null);
  const [busy, setBusy] = useState(false);
  const [editing, setEditing] = useState(false);
  const [confirmOff, setConfirmOff] = useState(false);

  const turnOff = async () => {
    setBusy(true);
    try {
      const r = await adminApi.clearPaymentSettings();
      setS((prev) => ({ ...r, banks: prev?.banks ?? [] }));
      setForm({ bankBin: '', accountNo: '', accountName: '', transferExpiryMinutes: r.transferExpiryMinutes });
      setEditing(true);
      setMsg({ ok: true, text: 'Đã tắt thanh toán chuyển khoản QR.' });
    } catch (ex) {
      setMsg({ ok: false, text: errorMessage(ex) });
    } finally {
      setBusy(false);
      setConfirmOff(false);
    }
  };

  useEffect(() => {
    adminApi
      .paymentSettings()
      .then((r) => {
        setS(r);
        setForm({ bankBin: r.bankBin ?? '', accountNo: r.accountNo ?? '', accountName: r.accountName ?? '', transferExpiryMinutes: r.transferExpiryMinutes });
        setEditing(!r.accountNo);
      })
      .catch((e) => setMsg({ ok: false, text: errorMessage(e) }));
  }, []);

  const save = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setMsg(null);
    try {
      const r = await adminApi.updatePaymentSettings(form);
      setS((prev) => ({ ...r, banks: prev?.banks ?? [] }));
      setForm({ ...form, accountName: r.accountName ?? '', accountNo: r.accountNo ?? '' });
      setEditing(false);
      setMsg({ ok: true, text: 'Đã lưu. Khách hàng có thể thanh toán chuyển khoản QR.' });
    } catch (ex) {
      setMsg({ ok: false, text: errorMessage(ex) });
    } finally {
      setBusy(false);
    }
  };

  if (!s) return msg ? <ErrorBox message={msg.text} /> : <Loading />;
  const configured = Boolean(s.accountNo);

  return (
    <div className="card">
      <div className="row space-between wrap gap">
        <h3>Tài khoản nhận chuyển khoản</h3>
        {configured ? <span className="badge badge-success">Đang nhận chuyển khoản</span> : <span className="badge badge-pending">Chưa cài đặt</span>}
      </div>
      {!configured && (
        <div className="alert alert-warn small">
          Chưa có tài khoản nhận tiền nên khách chưa thể thanh toán bằng chuyển khoản QR. Nhập tài khoản ngân hàng của bạn bên dưới.
        </div>
      )}
      {msg && <div className={`alert ${msg.ok ? 'alert-success' : 'alert-error'}`}>{msg.text}</div>}
      {!editing && configured ? (
        <div className="row space-between wrap gap">
          <div>
            <div>
              <b>{s.bankName}</b> · <span className="mono">{s.accountNo}</span>
            </div>
            <div className="small muted">
              {s.accountName} · mã QR hết hạn sau {s.transferExpiryMinutes} phút · cập nhật {formatDateTime(s.updatedAt)}
            </div>
          </div>
          <div className="row gap">
            <button className="btn btn-ghost btn-sm" onClick={() => setEditing(true)}>
              Sửa
            </button>
            <button className="btn btn-ghost btn-sm danger" onClick={() => setConfirmOff(true)}>
              Tắt chuyển khoản
            </button>
          </div>
        </div>
      ) : (
        <form onSubmit={save} className="form-grid">
          <label className="field">
            <span>Ngân hàng</span>
            <select className="input" value={form.bankBin} onChange={(e) => setForm({ ...form, bankBin: e.target.value })} required>
              <option value="">— Chọn ngân hàng —</option>
              {s.banks.map((b) => (
                <option key={b.bin} value={b.bin}>
                  {b.code} - {b.name}
                </option>
              ))}
            </select>
          </label>
          <label className="field">
            <span>Số tài khoản</span>
            <input className="input mono" inputMode="numeric" value={form.accountNo} onChange={(e) => setForm({ ...form, accountNo: e.target.value.replace(/\s/g, '') })} required />
          </label>
          <label className="field">
            <span>Tên chủ tài khoản</span>
            <input className="input" value={form.accountName} onChange={(e) => setForm({ ...form, accountName: e.target.value })} placeholder="NGUYEN VAN A" required />
          </label>
          <label className="field">
            <span>Mã QR hết hạn sau (phút)</span>
            <input
              className="input"
              type="number"
              min={5}
              max={1440}
              value={form.transferExpiryMinutes}
              onChange={(e) => setForm({ ...form, transferExpiryMinutes: Number(e.target.value) })}
            />
          </label>
          <div className="full row gap">
            <button className="btn btn-primary" disabled={busy}>
              {busy ? 'Đang lưu...' : 'Lưu tài khoản'}
            </button>
            {configured && (
              <button type="button" className="btn btn-ghost" onClick={() => setEditing(false)}>
                Hủy
              </button>
            )}
          </div>
        </form>
      )}
      {confirmOff && (
        <Modal title="Tắt thanh toán chuyển khoản?" onClose={() => setConfirmOff(false)}>
          <p className="small">Khách sẽ chỉ còn thanh toán được bằng thẻ. Các mã QR đang chờ vẫn được giữ để bạn đối soát.</p>
          <div className="row gap end">
            <button className="btn btn-ghost" onClick={() => setConfirmOff(false)}>
              Đóng
            </button>
            <button className="btn btn-ghost danger" onClick={turnOff} disabled={busy}>
              Tắt chuyển khoản
            </button>
          </div>
        </Modal>
      )}
    </div>
  );
}

export default function PaymentsAdminPage() {
  const [q, setQ] = useState({ search: '', status: 'PENDING', method: 'BANK_TRANSFER', page: 1 });
  const [data, setData] = useState<Paginated<AdminPayment> | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [action, setAction] = useState<{ kind: 'confirm' | 'reject'; p: AdminPayment } | null>(null);
  const [text, setText] = useState('');
  const [busy, setBusy] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);

  const load = () =>
    adminApi
      .payments({ ...q, pageSize: 15 })
      .then((r) => {
        setData(r);
        setError(null);
      })
      .catch((e) => setError(errorMessage(e)));

  useEffect(() => {
    const t = setTimeout(load, 250);
    const auto = setInterval(load, 15000); // tu cap nhat giao dich moi
    return () => {
      clearTimeout(t);
      clearInterval(auto);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [q]);

  const openAction = (kind: 'confirm' | 'reject', p: AdminPayment) => {
    setAction({ kind, p });
    setText('');
    setActionError(null);
  };

  const run = async () => {
    if (!action) return;
    setBusy(true);
    setActionError(null);
    try {
      if (action.kind === 'confirm') await adminApi.confirmPayment(action.p.paymentId, text.trim() || undefined);
      else await adminApi.rejectPayment(action.p.paymentId, text.trim() || undefined);
      setAction(null);
      load();
    } catch (e) {
      setActionError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-head">
        <h1>Thanh toán</h1>
      </div>
      <SettingsCard />

      <h3>Giao dịch</h3>
      <div className="toolbar">
        <input className="input" placeholder="🔎 Mã đơn, nội dung CK, email..." value={q.search} onChange={(e) => setQ({ ...q, search: e.target.value, page: 1 })} />
        <select className="input" value={q.method} onChange={(e) => setQ({ ...q, method: e.target.value, page: 1 })}>
          <option value="">Phương thức: tất cả</option>
          <option value="BANK_TRANSFER">Chuyển khoản QR</option>
          <option value="CARD">Thẻ ngân hàng</option>
        </select>
        <select className="input" value={q.status} onChange={(e) => setQ({ ...q, status: e.target.value, page: 1 })}>
          <option value="">Trạng thái: tất cả</option>
          {Object.entries(PAY_STATUS).map(([k, v]) => (
            <option key={k} value={k}>
              {v}
            </option>
          ))}
        </select>
      </div>
      {q.method === 'BANK_TRANSFER' && q.status === 'PENDING' && (
        <p className="small muted">
          Đối chiếu với sao kê / thông báo biến động số dư: chỉ bấm <b>Xác nhận đã nhận tiền</b> khi tài khoản đã nhận <b>đủ số tiền</b> với <b>đúng nội dung</b>.
          Vé sẽ được phát hành ngay sau khi xác nhận.
        </p>
      )}
      {error && <ErrorBox message={error} />}
      {!data ? (
        <Loading />
      ) : (
        <div className="table-wrap card">
          <table className="table">
            <thead>
              <tr>
                <th>Mã</th>
                <th>Đơn / Khách</th>
                <th>Phương thức</th>
                <th>Nội dung / Thẻ</th>
                <th>Thời gian</th>
                <th className="right">Số tiền</th>
                <th>Trạng thái</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {data.items.map((p) => (
                <tr key={p.paymentId}>
                  <td>#{p.paymentId}</td>
                  <td>
                    Đơn #{p.orderId} · {p.userName}
                    <div className="muted small">{p.userEmail}</div>
                  </td>
                  <td className="nowrap">{METHOD_LABEL[p.paymentMethod] ?? p.paymentMethod}</td>
                  <td>
                    {p.paymentMethod === 'BANK_TRANSFER' ? (
                      <b className="mono">{p.transferContent}</b>
                    ) : p.cardLast4 ? (
                      <span className="mono">
                        {p.cardBrand} •••• {p.cardLast4}
                      </span>
                    ) : (
                      '—'
                    )}
                    {p.customerNotifiedAt && p.status === 'PENDING' && <div className="small notified">Khách báo đã chuyển {formatDateTime(p.customerNotifiedAt)}</div>}
                    {p.note && <div className="small muted">{p.note}</div>}
                    {p.confirmedBy && p.status === 'SUCCESS' && p.paymentMethod === 'BANK_TRANSFER' && (
                      <div className="small muted">
                        Xác nhận: {p.confirmedBy}
                        {p.bankReference ? ` · ${p.bankReference}` : ''}
                      </div>
                    )}
                  </td>
                  <td className="small">
                    {formatDateTime(p.paidAt ?? p.createdAt)}
                    {p.status === 'PENDING' && p.expiresAt && <div className="muted">hạn {formatDateTime(p.expiresAt)}</div>}
                  </td>
                  <td className="right nowrap">
                    <b>{formatMoney(p.amount)}</b>
                  </td>
                  <td>
                    <StatusBadge status={p.status} label={PAY_STATUS[p.status]} />
                  </td>
                  <td className="right nowrap">
                    {p.paymentMethod === 'BANK_TRANSFER' && ['PENDING', 'EXPIRED'].includes(p.status) && p.orderStatus === 'PENDING' && (
                      <>
                        <button className="btn btn-xs btn-primary" onClick={() => openAction('confirm', p)}>
                          Xác nhận đã nhận tiền
                        </button>
                        <button className="btn btn-xs btn-ghost danger" onClick={() => openAction('reject', p)}>
                          Từ chối
                        </button>
                      </>
                    )}
                  </td>
                </tr>
              ))}
              {data.items.length === 0 && (
                <tr>
                  <td colSpan={8} className="center muted">
                    Không có giao dịch
                  </td>
                </tr>
              )}
            </tbody>
          </table>
          <Pager page={data.page} totalPages={data.totalPages} total={data.total} onChange={(page) => setQ({ ...q, page })} />
        </div>
      )}

      {action && (
        <Modal title={action.kind === 'confirm' ? 'Xác nhận đã nhận tiền' : 'Từ chối giao dịch'} onClose={() => setAction(null)}>
          <dl className="copy-list">
            <div className="copy-row">
              <dt>Đơn hàng</dt>
              <dd>
                #{action.p.orderId} · {action.p.userName}
              </dd>
            </div>
            <div className="copy-row">
              <dt>Số tiền</dt>
              <dd>
                <b>{formatMoney(action.p.amount)}</b>
              </dd>
            </div>
            <div className="copy-row">
              <dt>Nội dung CK</dt>
              <dd className="mono">{action.p.transferContent}</dd>
            </div>
          </dl>
          {action.kind === 'confirm' ? (
            <p className="small">Chỉ xác nhận khi tài khoản đã nhận đủ số tiền với đúng nội dung trên. Vé sẽ được phát hành cho khách ngay lập tức.</p>
          ) : (
            <p className="small">Khách sẽ thấy giao dịch không được xác nhận và có thể tạo mã chuyển khoản mới.</p>
          )}
          <label className="field">
            <span>{action.kind === 'confirm' ? 'Mã giao dịch ngân hàng (không bắt buộc)' : 'Lý do (không bắt buộc)'}</span>
            <input
              className="input"
              value={text}
              onChange={(e) => setText(e.target.value)}
              placeholder={action.kind === 'confirm' ? 'vd: FT26312XXXXX' : 'Không nhận được tiền / chuyển thiếu'}
            />
          </label>
          {actionError && <ErrorBox message={actionError} />}
          <div className="row gap end">
            <button className="btn btn-ghost" onClick={() => setAction(null)}>
              Đóng
            </button>
            <button className={`btn ${action.kind === 'confirm' ? 'btn-primary' : 'btn-ghost danger'}`} onClick={run} disabled={busy}>
              {busy ? 'Đang xử lý...' : action.kind === 'confirm' ? 'Xác nhận & phát hành vé' : 'Từ chối giao dịch'}
            </button>
          </div>
        </Modal>
      )}
    </div>
  );
}
