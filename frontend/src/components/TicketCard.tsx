import { Link } from 'react-router-dom';
import { Ticket } from '../types';
import { formatDateTime, formatMinutes } from '../utils/format';
import { MODE_META, STATUS_LABEL } from '../utils/modes';
import { StatusBadge } from './Feedback';

export function TicketCard({ t }: { t: Ticket }) {
  const m = MODE_META[t.mode];
  return (
    <Link to={`/tickets/${t.ticketId}`} className={`ticket-card ticket-${t.status.toLowerCase()}`}>
      <div className="ticket-stub" style={{ background: m.color }}>
        <span className="ticket-stub-icon">{m.icon}</span>
        <span className="ticket-stub-type">{t.type === 'MONTHLY' ? 'VÉ THÁNG' : 'VÉ LƯỢT'}</span>
      </div>
      <div className="ticket-main">
        <div className="ticket-row">
          <strong>{t.ticketTypeName}</strong>
          <StatusBadge status={t.status} label={STATUS_LABEL[t.status]} />
        </div>
        <div className="mono muted small">{t.ticketCode}</div>
        <div className="small">
          Hiệu lực đến <strong>{formatDateTime(t.validTo)}</strong>
          {t.isValidNow && <span className="muted"> · còn {formatMinutes(t.remainingMinutes)}</span>}
        </div>
      </div>
      <div className="ticket-qr-hint" aria-hidden>
        ▦
      </div>
    </Link>
  );
}
