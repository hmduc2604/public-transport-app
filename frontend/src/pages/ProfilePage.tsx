import { FormEvent, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { authApi } from '../services/authApi';
import { errorMessage } from '../services/api';
import { formatDate } from '../utils/format';

export default function ProfilePage() {
  const { user, setUser } = useAuth();
  const [fullName, setFullName] = useState(user?.fullName ?? '');
  const [phone, setPhone] = useState(user?.phone ?? '');
  const [msg, setMsg] = useState<{ ok: boolean; text: string } | null>(null);
  const [pw, setPw] = useState({ current: '', next: '' });
  const [pwMsg, setPwMsg] = useState<{ ok: boolean; text: string } | null>(null);

  if (!user) return null;

  const save = async (e: FormEvent) => {
    e.preventDefault();
    try {
      setUser(await authApi.updateMe({ fullName, phone: phone || undefined }));
      setMsg({ ok: true, text: 'Đã lưu thay đổi' });
    } catch (err) {
      setMsg({ ok: false, text: errorMessage(err) });
    }
  };

  const changePw = async (e: FormEvent) => {
    e.preventDefault();
    try {
      await authApi.changePassword(pw.current, pw.next);
      setPw({ current: '', next: '' });
      setPwMsg({ ok: true, text: 'Đổi mật khẩu thành công' });
    } catch (err) {
      setPwMsg({ ok: false, text: errorMessage(err) });
    }
  };

  return (
    <div className="page narrow">
      <h1>Hồ sơ</h1>
      <form className="card" onSubmit={save}>
        <div className="profile-head">
          <div className="avatar">{user.fullName.charAt(0)}</div>
          <div>
            <strong>{user.fullName}</strong>
            <div className="muted small">
              {user.email} · {user.role === 'ADMIN' ? 'Quản trị viên' : 'Khách hàng'} · tham gia {formatDate(user.createdAt)}
            </div>
          </div>
        </div>
        {msg && <div className={`alert ${msg.ok ? 'alert-success' : 'alert-error'}`}>{msg.text}</div>}
        <label className="field">
          <span>Họ tên</span>
          <input className="input" value={fullName} onChange={(e) => setFullName(e.target.value)} required />
        </label>
        <label className="field">
          <span>Số điện thoại</span>
          <input className="input" value={phone} onChange={(e) => setPhone(e.target.value)} />
        </label>
        <button className="btn btn-primary">Lưu</button>
      </form>

      <form className="card" onSubmit={changePw}>
        <h3>Đổi mật khẩu</h3>
        {pwMsg && <div className={`alert ${pwMsg.ok ? 'alert-success' : 'alert-error'}`}>{pwMsg.text}</div>}
        <div className="grid-2">
          <label className="field">
            <span>Mật khẩu hiện tại</span>
            <input className="input" type="password" value={pw.current} onChange={(e) => setPw({ ...pw, current: e.target.value })} required />
          </label>
          <label className="field">
            <span>Mật khẩu mới</span>
            <input className="input" type="password" value={pw.next} onChange={(e) => setPw({ ...pw, next: e.target.value })} required minLength={6} />
          </label>
        </div>
        <button className="btn btn-ghost">Đổi mật khẩu</button>
      </form>
    </div>
  );
}
