import { useState } from 'react';
import { Link } from 'react-router-dom';
import { ticketApi } from '../services/ticketApi';
import { useAsync } from '../utils/useAsync';
import { Empty, ErrorBox, Loading } from '../components/Feedback';
import { TicketCard } from '../components/TicketCard';

const TABS = [
  { key: '', label: 'Tất cả' },
  { key: 'ACTIVE', label: 'Còn hiệu lực' },
  { key: 'USED', label: 'Đã dùng' },
  { key: 'EXPIRED', label: 'Hết hạn' },
];

export default function TicketsPage() {
  const [status, setStatus] = useState('');
  const { data, loading, error, reload } = useAsync(() => ticketApi.myTickets(status || undefined), [status]);

  return (
    <div className="page narrow">
      <div className="row space-between">
        <h1>Vé của tôi</h1>
        <Link to="/tickets/buy" className="btn btn-primary">
          + Mua vé
        </Link>
      </div>
      <div className="tabs">
        {TABS.map((t) => (
          <button key={t.key} className={`tab${status === t.key ? ' active' : ''}`} onClick={() => setStatus(t.key)}>
            {t.label}
          </button>
        ))}
      </div>
      {loading ? (
        <Loading />
      ) : error ? (
        <ErrorBox message={error} onRetry={reload} />
      ) : data && data.length > 0 ? (
        <div className="ticket-list">{data.map((t) => <TicketCard key={t.ticketId} t={t} />)}</div>
      ) : (
        <Empty icon="🎫" title="Chưa có vé nào">
          <Link to="/tickets/buy" className="btn btn-primary">
            Mua vé ngay
          </Link>
        </Empty>
      )}
    </div>
  );
}
