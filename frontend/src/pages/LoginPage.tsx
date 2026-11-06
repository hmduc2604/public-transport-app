import { FormEvent, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { errorMessage } from '../services/api';

export default function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const from = (location.state as { from?: string } | null)?.from;
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const u = await login(email, password);
      navigate(from || (u.role === 'ADMIN' ? '/admin' : '/'), { replace: true });
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="auth-page">
      <form className="card auth-card" onSubmit={submit}>
        <h1>Đăng nhập</h1>
        <p className="muted">Khám phá Hà Nội bằng giao thông công cộng</p>
        {error && <div className="alert alert-error">{error}</div>}
        <label className="field">
          <span>Email</span>
          <input className="input" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoFocus />
        </label>
        <label className="field">
          <span>Mật khẩu</span>
          <input className="input" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
        </label>
        <button className="btn btn-primary btn-block" disabled={busy}>
          {busy ? 'Đang đăng nhập...' : 'Đăng nhập'}
        </button>
        <p className="small center">
          Chưa có tài khoản? <Link to="/register">Đăng ký</Link>
        </p>
        <div className="demo-accounts small">
          <div className="muted">Tài khoản demo (mật khẩu 123456):</div>
          {['an@example.com', 'admin@example.com'].map((em) => (
            <button
              type="button"
              key={em}
              className="chip chip-btn"
              onClick={() => {
                setEmail(em);
                setPassword('123456');
              }}
            >
              {em}
            </button>
          ))}
        </div>
      </form>
    </div>
  );
}
