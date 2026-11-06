/** Ve dien tu + QR (UC: Show QR Ticket) */
import { Link, useParams } from 'react-router-dom';
import { ticketApi } from '../services/ticketApi';
import { useAsync } from '../utils/useAsync';
import { ErrorBox, Loading, StatusBadge } from '../components/Feedback';
import { formatDateTime, formatMinutes, formatMoney } from '../utils/format';
import { MODE_META, STATUS_LABEL } from '../utils/modes';

export default function TicketDetailPage() {
  const { id } = useParams();
  const ticket = useAsync(() => ticketApi.ticket(Number(id)), [id]);
  const qr = useAsync(() => ticketApi.qr(Number(id)), [id]);

  if (ticket.loading) return <Loading />;
  if (ticket.error || !ticket.data) return <div className="page"><ErrorBox message={ticket.error ?? 'Không tìm thấy vé'} /></div>;
  const t = ticket.data;
  const m = MODE_META[t.mode];

  return (
    <div className="page narrow">
      <Link to="/tickets" className="back-link">← Vé của tôi</Link>
      <div className={`eticket eticket-${t.status.toLowerCase()}`}>
        <div className="eticket-head" style={{ background: m.color }}>
          <div>
            <div className="eticket-kicker">E-TICKET · {t.type === 'MONTHLY' ? 'VÉ THÁNG' : 'VÉ LƯỢT'}</div>
            <div className="eticket-title">
              {m.icon} {t.ticketTypeName}
            </div>
          </div>
          <StatusBadge status={t.status} label={STATUS_LABEL[t.status]} />
        </div>
        <div className="eticket-qr">
          {qr.loading ? (
            <Loading text="Đang tạo QR..." />
          ) : qr.data ? (
            <img src={qr.data.image} alt={`QR ${t.ticketCode}`} width={260} height={260} />
          ) : (
            <ErrorBox message={qr.error ?? 'Không tạo được QR'} />
          )}
          <div className="mono">{t.ticketCode}</div>
          {qr.data && (
            <details className="small qr-raw">
              <summary>Nội dung QR (dùng để demo soát vé)</summary>
              <code>{qr.data.payload}</code>
              <button className="btn btn-xs btn-ghost" onClick={() => navigator.clipboard?.writeText(qr.data!.payload)}>
                Sao chép
              </button>
            </details>
          )}
          {t.status !== 'ACTIVE' && <div className="eticket-void">{STATUS_LABEL[t.status]}</div>}
        </div>
        <div className="eticket-perf" />
        <dl className="eticket-info">
          <div>
            <dt>Phương tiện</dt>
            <dd>{m.label}</dd>
          </div>
          <div>
            <dt>Giá vé</dt>
            <dd>{formatMoney(t.price)}</dd>
          </div>
          <div>
            <dt>Hiệu lực từ</dt>
            <dd>{formatDateTime(t.validFrom)}</dd>
          </div>
          <div>
            <dt>Đến</dt>
            <dd>{formatDateTime(t.validTo)}</dd>
          </div>
        </dl>
        {t.isValidNow && <div className="eticket-foot">Còn hiệu lực {formatMinutes(t.remainingMinutes)} · Đưa mã QR cho nhân viên soát vé</div>}
      </div>
    </div>
  );
}
