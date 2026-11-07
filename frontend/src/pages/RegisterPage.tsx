/**
 * Dang ky 2 buoc:
 *   1. Nhap thong tin + chon nhan ma qua Email hoac SMS -> backend GUI MA THAT
 *   2. Nhap ma 6 so -> backend tao tai khoan trong database va dang nhap
 */
import { ChangeEvent, FormEvent, useEffect, useRef, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { authApi } from '../services/authApi';
import { errorMessage } from '../services/api';
import { VerificationChannels, VerificationInfo, VerifyChannel } from '../types';

const PHONE_RE = /^(0|\+84|84)?[35789]\d{8}$/;

function useCountdown(seconds: number, key: unknown) {
  const [left, setLeft] = useState(seconds);
  useEffect(() => {
    setLeft(seconds);
    if (seconds <= 0) return;
    const t = setInterval(() => setLeft((s) => (s <= 1 ? (clearInterval(t), 0) : s - 1)), 1000);
    return () => clearInterval(t);
  }, [seconds, key]);
  return left;
}

const fmt = (s: number) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;

export default function RegisterPage() {
  const { register, verifyRegistration } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ fullName: '', email: '', phone: '', password: '', confirm: '' });
  const [channel, setChannel] = useState<VerifyChannel>('EMAIL');
  const [channels, setChannels] = useState<VerificationChannels | null>(null);
  const [info, setInfo] = useState<VerificationInfo | null>(null);
  const [code, setCode] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [sentAt, setSentAt] = useState(0);
  const codeRef = useRef<HTMLInputElement>(null);

  const resendLeft = useCountdown(info?.resendInSeconds ?? 0, sentAt);
  const expireLeft = useCountdown(info?.expiresInSeconds ?? 0, sentAt);

  useEffect(() => {
    authApi
      .channels()
      .then((c) => {
        setChannels(c);
        if (!c.email && c.sms) setChannel('SMS');
      })
      .catch(() => setChannels({ email: true, sms: true, ttlMinutes: 5, resendSeconds: 60 }));
  }, []);

  useEffect(() => {
    if (info) codeRef.current?.focus();
  }, [info]);

  const set = (k: keyof typeof form) => (e: ChangeEvent<HTMLInputElement>) => setForm({ ...form, [k]: e.target.value });

  /* Buoc 1: gui ma */
  const sendCode = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setNotice(null);
    if (form.password !== form.confirm) return setError('Mật khẩu nhập lại không khớp');
    if (!PHONE_RE.test(form.phone.replace(/[\s.\-()]/g, ''))) return setError('Số điện thoại không hợp lệ (vd: 0912345678)');
    setBusy(true);
    try {
      const r = await register({ fullName: form.fullName, email: form.email, phone: form.phone, password: form.password, channel });
      setInfo(r);
      setSentAt(Date.now());
      setCode('');
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  /* Buoc 2: xac nhan ma */
  const verify = async (e: FormEvent) => {
    e.preventDefault();
    if (!info) return;
    setBusy(true);
    setError(null);
    try {
      await verifyRegistration(info.verificationId, code);
      navigate('/', { replace: true });
    } catch (err) {
      setError(errorMessage(err));
      setCode('');
      codeRef.current?.focus();
    } finally {
      setBusy(false);
    }
  };

  const resend = async () => {
    if (!info) return;
    setBusy(true);
    setError(null);
    try {
      const r = await authApi.resendCode(info.verificationId);
      setInfo(r);
      setSentAt(Date.now());
      setCode('');
      setNotice(`Đã gửi lại mã mới tới ${r.destination}`);
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  /* ---------------- Buoc 2 ---------------- */
  if (info) {
    return (
      <div className="auth-page">
        <form className="card auth-card" onSubmit={verify}>
          <div className="steps">
            <span className="step done">1. Thông tin</span>
            <span className="step active">2. Xác nhận</span>
          </div>
          <h1>Nhập mã xác nhận</h1>
          <p className="muted">
            Mã gồm 6 chữ số đã được gửi tới {info.channel === 'EMAIL' ? 'email' : 'số điện thoại'} <strong>{info.destination}</strong>.
            {info.channel === 'EMAIL' && ' Nếu không thấy, hãy kiểm tra cả hộp thư Spam/Quảng cáo.'}
          </p>
          {error && <div className="alert alert-error">{error}</div>}
          {notice && !error && <div className="alert alert-success">{notice}</div>}
          <input
            ref={codeRef}
            className="input otp-input"
            inputMode="numeric"
            autoComplete="one-time-code"
            maxLength={6}
            placeholder="••••••"
            value={code}
            onChange={(e) => setCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
            aria-label="Mã xác nhận"
          />
          <p className="small muted center">
            {expireLeft > 0 ? `Mã hết hạn sau ${fmt(expireLeft)}` : 'Mã đã hết hạn, vui lòng gửi lại mã'}
          </p>
          <button className="btn btn-primary btn-block" disabled={busy || code.length !== 6}>
            {busy ? 'Đang xác nhận...' : 'Xác nhận và tạo tài khoản'}
          </button>
          <div className="row space-between small otp-actions">
            <button
              type="button"
              className="link-btn"
              onClick={() => {
                setInfo(null);
                setError(null);
                setNotice(null);
              }}
            >
              ← Sửa thông tin / đổi cách nhận mã
            </button>
            <button type="button" className="link-btn" onClick={resend} disabled={busy || resendLeft > 0}>
              {resendLeft > 0 ? `Gửi lại mã (${resendLeft}s)` : 'Gửi lại mã'}
            </button>
          </div>
        </form>
      </div>
    );
  }

  /* ---------------- Buoc 1 ---------------- */
  const opt = (c: VerifyChannel, icon: string, title: string, dest: string, enabled: boolean) => (
    <label className={`channel-option${channel === c ? ' active' : ''}${enabled ? '' : ' disabled'}`}>
      <input type="radio" name="channel" value={c} checked={channel === c} disabled={!enabled} onChange={() => setChannel(c)} />
      <span className="channel-icon">{icon}</span>
      <span className="channel-text">
        <strong>{title}</strong>
        <span className="muted small">{enabled ? dest || 'Nhập ở trên' : 'Chưa được cấu hình trên hệ thống'}</span>
      </span>
    </label>
  );

  return (
    <div className="auth-page">
      <form className="card auth-card" onSubmit={sendCode}>
        <div className="steps">
          <span className="step active">1. Thông tin</span>
          <span className="step">2. Xác nhận</span>
        </div>
        <h1>Tạo tài khoản</h1>
        {error && <div className="alert alert-error">{error}</div>}
        <label className="field">
          <span>Họ tên</span>
          <input className="input" value={form.fullName} onChange={set('fullName')} required minLength={2} autoComplete="name" />
        </label>
        <label className="field">
          <span>Email</span>
          <input className="input" type="email" value={form.email} onChange={set('email')} required autoComplete="email" />
        </label>
        <label className="field">
          <span>Số điện thoại</span>
          <input
            className="input"
            type="tel"
            value={form.phone}
            onChange={set('phone')}
            placeholder="vd: 0912345678"
            required
            autoComplete="tel"
          />
        </label>
        <div className="grid-2">
          <label className="field">
            <span>Mật khẩu</span>
            <input className="input" type="password" value={form.password} onChange={set('password')} required minLength={6} autoComplete="new-password" />
          </label>
          <label className="field">
            <span>Nhập lại</span>
            <input className="input" type="password" value={form.confirm} onChange={set('confirm')} required autoComplete="new-password" />
          </label>
        </div>
        <div className="field">
          <span>Nhận mã xác nhận qua</span>
          <div className="channel-options">
            {opt('EMAIL', '✉️', 'Email', form.email, channels?.email ?? true)}
            {opt('SMS', '💬', 'Tin nhắn SMS', form.phone, channels?.sms ?? true)}
          </div>
        </div>
        <button className="btn btn-primary btn-block" disabled={busy || (channels !== null && !channels.email && !channels.sms)}>
          {busy ? 'Đang gửi mã...' : 'Gửi mã xác nhận'}
        </button>
        {channels !== null && !channels.email && !channels.sms && (
          <p className="small muted center">Hệ thống chưa cấu hình gửi email/SMS, tạm thời chưa thể đăng ký.</p>
        )}
        <p className="small center">
          Đã có tài khoản? <Link to="/login">Đăng nhập</Link>
        </p>
      </form>
    </div>
  );
}
