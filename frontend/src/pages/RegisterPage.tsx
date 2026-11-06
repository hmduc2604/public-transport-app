import { ChangeEvent, FormEvent, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { errorMessage } from '../services/api';

export default function RegisterPage() {
  const { register } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ fullName: '', email: '', phone: '', password: '', confirm: '' });
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const set = (k: keyof typeof form) => (e: ChangeEvent<HTMLInputElement>) => setForm({ ...form, [k]: e.target.value });

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    if (form.password !== form.confirm) return setError('Mật khẩu nhập lại không khớp');
    setBusy(true);
    setError(null);
    try {
      await register({ fullName: form.fullName, email: form.email, password: form.password, phone: form.phone || undefined });
      navigate('/', { replace: true });
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="auth-page">
      <form className="card auth-card" onSubmit={submit}>
        <h1>Tạo tài khoản</h1>
        {error && <div className="alert alert-error">{error}</div>}
        <label className="field">
          <span>Họ tên</span>
          <input className="input" value={form.fullName} onChange={set('fullName')} required minLength={2} />
        </label>
        <label className="field">
          <span>Email</span>
          <input className="input" type="email" value={form.email} onChange={set('email')} required />
        </label>
        <label className="field">
          <span>Số điện thoại (không bắt buộc)</span>
          <input className="input" value={form.phone} onChange={set('phone')} />
        </label>
        <div className="grid-2">
          <label className="field">
            <span>Mật khẩu</span>
            <input className="input" type="password" value={form.password} onChange={set('password')} required minLength={6} />
          </label>
          <label className="field">
            <span>Nhập lại</span>
            <input className="input" type="password" value={form.confirm} onChange={set('confirm')} required />
          </label>
        </div>
        <button className="btn btn-primary btn-block" disabled={busy}>
          {busy ? 'Đang tạo...' : 'Đăng ký'}
        </button>
        <p className="small center">
          Đã có tài khoản? <Link to="/login">Đăng nhập</Link>
        </p>
      </form>
    </div>
  );
}
