/** Dashboard thong ke (UC: View Statistics) */
import { useState } from 'react';
import { adminApi } from '../../services/adminApi';
import { errorMessage } from '../../services/api';
import { useAsync } from '../../utils/useAsync';
import { ErrorBox, Loading, StatusBadge } from '../../components/Feedback';
import { formatDateTime, formatMoney } from '../../utils/format';
import { STATUS_LABEL } from '../../utils/modes';

export default function DashboardPage() {
  const [days, setDays] = useState(14);
  const { data, loading, error, reload } = useAsync(() => adminApi.statistics(days), [days]);
  const [graphMsg, setGraphMsg] = useState<string | null>(null);

  const rebuild = async () => {
    try {
      const r = await adminApi.rebuildGraph();
      setGraphMsg(`Graph: ${r.stations} trạm · ${r.lines} tuyến · ${r.nodes} node · ${r.edges} cạnh`);
    } catch (e) {
      setGraphMsg(errorMessage(e));
    }
  };

  if (loading && !data) return <Loading />;
  if (error) return <ErrorBox message={error} onRetry={reload} />;
  if (!data) return null;
  const o = data.overview;

  // Lap day cac ngay khong co doanh thu de bieu do lien tuc
  const series: { date: string; revenue: number }[] = [];
  for (let i = days - 1; i >= 0; i--) {
    const d = new Date();
    d.setDate(d.getDate() - i);
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    series.push({ date: key, revenue: data.revenueByDay.find((x) => x.date === key)?.revenue ?? 0 });
  }
  const maxRev = Math.max(1, ...series.map((s) => s.revenue));

  const tiles = [
    { label: 'Doanh thu kỳ này', value: formatMoney(o.periodRevenue), sub: `Tổng: ${formatMoney(o.totalRevenue)}` },
    { label: 'Vé đã bán', value: o.ticketsSold, sub: `${o.activeTickets} vé đang hiệu lực` },
    { label: 'Đơn hàng', value: o.totalOrders, sub: `${o.paidOrders} đã thanh toán · ${o.pendingOrders} chờ` },
    { label: 'Người dùng', value: o.totalUsers, sub: `+${o.newUsers} trong kỳ` },
    { label: 'Trạm / Tuyến', value: `${o.totalStations} / ${o.totalRoutes}`, sub: `${o.totalTrips} chuyến theo lịch` },
    { label: 'Phương tiện', value: o.totalVehicles, sub: `${o.activeVehicles} đang hoạt động` },
  ];

  return (
    <div className="admin-page">
      <div className="admin-head">
        <div>
          <h1>Dashboard</h1>
          <p className="muted">Tổng quan hệ thống giao thông đa phương thức</p>
        </div>
        <div className="row gap">
          <select className="input" value={days} onChange={(e) => setDays(Number(e.target.value))}>
            <option value={7}>7 ngày</option>
            <option value={14}>14 ngày</option>
            <option value={30}>30 ngày</option>
          </select>
          <button className="btn btn-ghost" onClick={rebuild}>
            ↻ Xây lại graph
          </button>
        </div>
      </div>
      {graphMsg && <div className="alert alert-info small">{graphMsg}</div>}

      <div className="stat-grid">
        {tiles.map((t) => (
          <div key={t.label} className="stat card">
            <div className="stat-label">{t.label}</div>
            <div className="stat-value">{t.value}</div>
            <div className="stat-sub muted small">{t.sub}</div>
          </div>
        ))}
      </div>

      <div className="card">
        <h3>Doanh thu theo ngày</h3>
        <div className="bars" role="img" aria-label="Biểu đồ doanh thu theo ngày">
          {series.map((s) => (
            <div key={s.date} className="bar-col" title={`${s.date}: ${formatMoney(s.revenue)}`}>
              <div className="bar" style={{ height: `${(s.revenue / maxRev) * 100}%` }} />
              <div className="bar-label">{s.date.slice(8)}/{s.date.slice(5, 7)}</div>
            </div>
          ))}
        </div>
      </div>

      <div className="grid-2">
        <div className="card">
          <h3>Vé bán theo loại</h3>
          <table className="table">
            <thead>
              <tr>
                <th>Loại vé</th>
                <th className="right">Số vé</th>
                <th className="right">Doanh thu</th>
              </tr>
            </thead>
            <tbody>
              {data.ticketsByType.map((t) => (
                <tr key={t.ticketTypeId}>
                  <td>{t.name}</td>
                  <td className="right">{t.ticketsSold}</td>
                  <td className="right">{formatMoney(t.revenue)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="card">
          <h3>Hạ tầng theo phương tiện</h3>
          <table className="table">
            <thead>
              <tr>
                <th>Loại</th>
                <th className="right">Trạm</th>
                <th className="right">Tuyến</th>
                <th className="right">Xe</th>
              </tr>
            </thead>
            <tbody>
              {data.transportSummary.map((t) => (
                <tr key={t.transportTypeId}>
                  <td>{t.name}</td>
                  <td className="right">{t.stations}</td>
                  <td className="right">{t.routes}</td>
                  <td className="right">{t.vehicles}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <h3 className="mt">Điểm đến được tìm nhiều</h3>
          <ol className="top-list">
            {data.topDestinations.map((d) => (
              <li key={d.destination}>
                <span>{d.destination}</span>
                <span className="muted">{d.total} lượt</span>
              </li>
            ))}
          </ol>
        </div>
      </div>

      <div className="card">
        <h3>Đơn hàng gần đây</h3>
        <table className="table">
          <tbody>
            {data.recentOrders.map((r) => (
              <tr key={r.orderId}>
                <td>#{r.orderId}</td>
                <td>{r.userName}</td>
                <td>{formatDateTime(r.createdAt)}</td>
                <td className="right">{formatMoney(r.totalAmount)}</td>
                <td>
                  <StatusBadge status={r.status} label={STATUS_LABEL[r.status]} />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
