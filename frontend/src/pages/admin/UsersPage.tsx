/** Quan ly nguoi dung: tim kiem, phan quyen, khoa / mo khoa */
import { useEffect, useState } from 'react';
import { adminApi } from '../../services/adminApi';
import { errorMessage } from '../../services/api';
import { useAuth } from '../../context/AuthContext';
import { ErrorBox, Loading, StatusBadge } from '../../components/Feedback';
import { formatDate } from '../../utils/format';
import { STATUS_LABEL } from '../../utils/modes';
import { Paginated, User } from '../../types';
import { Pager } from './Pager';

export default function UsersPage() {
  const { user: me } = useAuth();
  const [q, setQ] = useState({ search: '', role: '', status: '', page: 1 });
  const [data, setData] = useState<Paginated<User & { paidOrders: number }> | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = () =>
    adminApi
      .users({ ...q, pageSize: 15 })
      .then(setData)
      .catch((e) => setError(errorMessage(e)));

  useEffect(() => {
    const t = setTimeout(load, 250);
    return () => clearTimeout(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [q]);

  const update = async (u: User, patch: { role?: string; status?: string }) => {
    try {
      await adminApi.updateUser(u.userId, patch);
      load();
    } catch (e) {
      alert(errorMessage(e));
    }
  };

  return (
    <div className="admin-page">
      <div className="admin-head">
        <h1>Người dùng</h1>
      </div>
      <div className="toolbar">
        <input className="input" placeholder="🔎 Tên, email, SĐT..." value={q.search} onChange={(e) => setQ({ ...q, search: e.target.value, page: 1 })} />
        <select className="input" value={q.role} onChange={(e) => setQ({ ...q, role: e.target.value, page: 1 })}>
          <option value="">Vai trò: tất cả</option>
          <option value="USER">USER</option>
          <option value="ADMIN">ADMIN</option>
        </select>
        <select className="input" value={q.status} onChange={(e) => setQ({ ...q, status: e.target.value, page: 1 })}>
          <option value="">Trạng thái: tất cả</option>
          <option value="ACTIVE">Hoạt động</option>
          <option value="LOCKED">Đã khóa</option>
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
                <th>ID</th>
                <th>Họ tên</th>
                <th>Email</th>
                <th>SĐT</th>
                <th>Vai trò</th>
                <th className="right">Đơn đã TT</th>
                <th>Ngày tạo</th>
                <th>Trạng thái</th>
                <th className="right">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {data.items.map((u) => (
                <tr key={u.userId}>
                  <td>{u.userId}</td>
                  <td>{u.fullName}</td>
                  <td>{u.email}</td>
                  <td>{u.phone ?? '—'}</td>
                  <td>
                    <select
                      className="input input-sm"
                      value={u.role}
                      disabled={u.userId === me?.userId}
                      onChange={(e) => update(u, { role: e.target.value })}
                    >
                      <option value="USER">USER</option>
                      <option value="ADMIN">ADMIN</option>
                    </select>
                  </td>
                  <td className="right">{u.paidOrders}</td>
                  <td>{formatDate(u.createdAt)}</td>
                  <td>
                    <StatusBadge status={u.status} label={STATUS_LABEL[u.status]} />
                  </td>
                  <td className="right">
                    {u.userId !== me?.userId &&
                      (u.status === 'ACTIVE' ? (
                        <button className="btn btn-xs btn-ghost danger" onClick={() => update(u, { status: 'LOCKED' })}>
                          Khóa
                        </button>
                      ) : (
                        <button className="btn btn-xs btn-ghost" onClick={() => update(u, { status: 'ACTIVE' })}>
                          Mở khóa
                        </button>
                      ))}
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
