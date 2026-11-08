/**
 * Thanh toan bang THE NGAN HANG
 *  - The quoc te: so the, ten chu the, ngay het han, CVV
 *  - The ATM noi dia (NAPAS): ngan hang phat hanh, so the, ten chu the, ngay phat hanh
 * He thong KHONG luu so the / CVV - chi luu hang the + 4 so cuoi.
 */
import { FormEvent, useMemo, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { ticketApi } from '../services/ticketApi';
import { paymentApi } from '../services/paymentApi';
import { ApiError, errorMessage } from '../services/api';
import { useAsync } from '../utils/useAsync';
import { ErrorBox, Loading } from '../components/Feedback';
import { OrderSummary } from '../components/payment/OrderSummary';
import { PaymentSuccess } from '../components/payment/PaymentSuccess';
import { formatMoney } from '../utils/format';
import {
  BRAND_LABEL,
  CardForm,
  detectBrand,
  digitsOnly,
  formatCardNumber,
  formatMonthYear,
  maxDigits,
  toCardHolder,
  validateCardForm,
} from '../utils/card';
import { CardKind, CardPaymentResult } from '../types';

const EMPTY: CardForm = { cardKind: 'INTERNATIONAL', cardNumber: '', cardHolder: '', expiry: '', cvv: '', bankBin: '' };

const TEST_CARDS = [
  { kind: 'INTERNATIONAL' as CardKind, number: '4242424242424242', label: 'Visa - thành công' },
  { kind: 'INTERNATIONAL' as CardKind, number: '5555555555554444', label: 'Mastercard - thành công' },
  { kind: 'INTERNATIONAL' as CardKind, number: '4000000000000002', label: 'Visa - bị từ chối' },
  { kind: 'INTERNATIONAL' as CardKind, number: '4000000000009995', label: 'Visa - không đủ số dư' },
  { kind: 'DOMESTIC' as CardKind, number: '9704000000000018', label: 'ATM nội địa - thành công' },
];

export default function CardPaymentPage() {
  const { orderId } = useParams();
  const navigate = useNavigate();
  const { data: order, loading, error } = useAsync(() => ticketApi.order(Number(orderId)), [orderId]);
  const { data: methods } = useAsync(() => paymentApi.methods(), []);
  const [f, setF] = useState<CardForm>(EMPTY);
  const [touched, setTouched] = useState<Record<string, boolean>>({});
  const [serverErrors, setServerErrors] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const [declined, setDeclined] = useState<string | null>(null);
  const [payError, setPayError] = useState<string | null>(null);
  const [result, setResult] = useState<CardPaymentResult | null>(null);
  const [flipped, setFlipped] = useState(false);

  const brand = detectBrand(f.cardNumber);
  const errors = useMemo(() => validateCardForm(f), [f]);
  const domestic = f.cardKind === 'DOMESTIC';
  const bank = methods?.banks.find((b) => b.bin === f.bankBin);
  const err = (k: keyof CardForm) => (touched[k] ? errors[k] : undefined) ?? serverErrors[k];

  const set = (k: keyof CardForm, v: string) => {
    setF((prev) => ({ ...prev, [k]: v }));
    setServerErrors((prev) => ({ ...prev, [k]: '' }));
  };
  const blur = (k: keyof CardForm) => () => setTouched((t) => ({ ...t, [k]: true }));
  const switchKind = (k: CardKind) => {
    setF({ ...EMPTY, cardKind: k, cardHolder: f.cardHolder });
    setTouched({});
    setServerErrors({});
    setDeclined(null);
  };
  const fillTest = (t: (typeof TEST_CARDS)[number]) => {
    const now = new Date();
    const yy = String((now.getFullYear() + (t.kind === 'DOMESTIC' ? -2 : 3)) % 100).padStart(2, '0');
    setF({
      cardKind: t.kind,
      cardNumber: t.number,
      cardHolder: 'NGUYEN VAN A',
      expiry: `${String(now.getMonth() + 1).padStart(2, '0')}/${yy}`,
      cvv: t.kind === 'DOMESTIC' ? '' : '123',
      bankBin: t.kind === 'DOMESTIC' ? '970436' : '',
    });
    setTouched({});
    setServerErrors({});
    setDeclined(null);
  };

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setTouched({ cardNumber: true, cardHolder: true, expiry: true, cvv: true, bankBin: true });
    if (Object.keys(errors).length) return;
    setBusy(true);
    setDeclined(null);
    setPayError(null);
    try {
      const r = await paymentApi.payByCard({
        orderId: Number(orderId),
        cardKind: f.cardKind,
        cardNumber: f.cardNumber,
        cardHolder: f.cardHolder.trim(),
        expiry: f.expiry,
        cvv: domestic ? undefined : f.cvv,
        bankBin: domestic ? f.bankBin : undefined,
      });
      if (r.status === 'SUCCESS') setResult(r);
      else setDeclined(r.message ?? 'Giao dịch bị từ chối');
    } catch (ex) {
      if (ex instanceof ApiError && ex.details) setServerErrors(ex.details);
      setPayError(ex instanceof ApiError && ex.details ? ex.message : errorMessage(ex));
    } finally {
      setBusy(false);
    }
  };

  if (loading) return <Loading />;
  if (error || !order) return <div className="page"><ErrorBox message={error ?? 'Không tìm thấy đơn'} /></div>;
  if (result) {
    return (
      <PaymentSuccess
        orderId={order.orderId}
        amount={result.amount}
        ticketIds={result.ticketIds}
        detail={`Đã thanh toán bằng thẻ ${BRAND_LABEL[result.cardBrand as keyof typeof BRAND_LABEL] || ''} •••• ${result.cardLast4}`}
      />
    );
  }
  if (order.status !== 'PENDING') {
    return (
      <div className="page narrow">
        <div className="alert alert-info">
          <span>
            Đơn #{order.orderId} không còn chờ thanh toán. <Link to={`/payment/${order.orderId}`}>Xem đơn</Link>
          </span>
        </div>
      </div>
    );
  }

  const shownNumber = formatCardNumber(f.cardNumber) || (domestic ? '9704 •••• •••• ••••' : '•••• •••• •••• ••••');

  return (
    <div className="page">
      <Link to={`/payment/${order.orderId}`} className="small">
        ← Đổi phương thức thanh toán
      </Link>
      <h1>Thanh toán bằng thẻ</h1>
      <div className="pay-layout">
        <form className="card card-form" onSubmit={submit} noValidate>
          <div className="seg" role="tablist" aria-label="Loại thẻ">
            <button type="button" role="tab" aria-selected={!domestic} className={`seg-btn${!domestic ? ' active' : ''}`} onClick={() => switchKind('INTERNATIONAL')}>
              Thẻ quốc tế
              <span className="small">Visa · Mastercard · JCB · AMEX</span>
            </button>
            <button type="button" role="tab" aria-selected={domestic} className={`seg-btn${domestic ? ' active' : ''}`} onClick={() => switchKind('DOMESTIC')}>
              Thẻ ATM nội địa
              <span className="small">NAPAS · Internet Banking</span>
            </button>
          </div>

          <div className={`card-visual${domestic ? ' domestic' : ''}${flipped ? ' flipped' : ''}`} aria-hidden>
            <div className="card-face card-front">
              <div className="row space-between">
                <span className="card-bank">{domestic ? bank?.code ?? 'NGÂN HÀNG' : 'HanoiGo Pay'}</span>
                <span className="card-brand">{BRAND_LABEL[brand] || (domestic ? 'NAPAS' : '')}</span>
              </div>
              <div className="card-chip" />
              <div className="card-number mono">{shownNumber}</div>
              <div className="row space-between card-bottom">
                <div>
                  <div className="card-label">Chủ thẻ</div>
                  <div className="card-holder">{f.cardHolder || 'TEN CHU THE'}</div>
                </div>
                <div>
                  <div className="card-label">{domestic ? 'Phát hành' : 'Hết hạn'}</div>
                  <div className="mono">{f.expiry || 'MM/YY'}</div>
                </div>
              </div>
            </div>
            <div className="card-face card-back">
              <div className="card-stripe" />
              <div className="card-cvv">
                <span className="card-label">CVV</span>
                <span className="mono">{f.cvv ? '•'.repeat(f.cvv.length) : '•••'}</span>
              </div>
            </div>
          </div>

          {domestic && (
            <label className="field">
              <span>Ngân hàng phát hành</span>
              <select className={`input${err('bankBin') ? ' invalid' : ''}`} value={f.bankBin} onChange={(e) => set('bankBin', e.target.value)} onBlur={blur('bankBin')}>
                <option value="">— Chọn ngân hàng —</option>
                {methods?.banks.map((b) => (
                  <option key={b.bin} value={b.bin}>
                    {b.code} - {b.name}
                  </option>
                ))}
              </select>
              {err('bankBin') && <small className="field-error">{err('bankBin')}</small>}
            </label>
          )}

          <label className="field">
            <span>Số thẻ</span>
            <div className="input-icon">
              <input
                className={`input mono${err('cardNumber') ? ' invalid' : ''}`}
                inputMode="numeric"
                autoComplete="cc-number"
                placeholder={domestic ? '9704 0000 0000 0000' : '4242 4242 4242 4242'}
                value={formatCardNumber(f.cardNumber)}
                onChange={(e) => set('cardNumber', digitsOnly(e.target.value).slice(0, maxDigits(detectBrand(digitsOnly(e.target.value)))))}
                onBlur={blur('cardNumber')}
              />
              {BRAND_LABEL[brand] && <span className="input-badge">{BRAND_LABEL[brand]}</span>}
            </div>
            {err('cardNumber') && <small className="field-error">{err('cardNumber')}</small>}
          </label>

          <label className="field">
            <span>Tên chủ thẻ (in trên thẻ)</span>
            <input
              className={`input${err('cardHolder') ? ' invalid' : ''}`}
              autoComplete="cc-name"
              placeholder="NGUYEN VAN A"
              value={f.cardHolder}
              onChange={(e) => set('cardHolder', toCardHolder(e.target.value))}
              onBlur={blur('cardHolder')}
            />
            {err('cardHolder') && <small className="field-error">{err('cardHolder')}</small>}
          </label>

          <div className="grid-2">
            <label className="field">
              <span>{domestic ? 'Ngày phát hành' : 'Ngày hết hạn'}</span>
              <input
                className={`input mono${err('expiry') ? ' invalid' : ''}`}
                inputMode="numeric"
                autoComplete={domestic ? 'off' : 'cc-exp'}
                placeholder="MM/YY"
                value={f.expiry}
                onChange={(e) => set('expiry', formatMonthYear(e.target.value))}
                onBlur={blur('expiry')}
              />
              {err('expiry') && <small className="field-error">{err('expiry')}</small>}
            </label>
            {!domestic && (
              <label className="field">
                <span>Mã bảo mật CVV</span>
                <input
                  className={`input mono${err('cvv') ? ' invalid' : ''}`}
                  inputMode="numeric"
                  autoComplete="cc-csc"
                  type="password"
                  placeholder={brand === 'AMEX' ? '4 số' : '3 số'}
                  value={f.cvv}
                  onFocus={() => setFlipped(true)}
                  onChange={(e) => set('cvv', digitsOnly(e.target.value).slice(0, brand === 'AMEX' ? 4 : 3))}
                  onBlur={() => {
                    setFlipped(false);
                    blur('cvv')();
                  }}
                />
                {err('cvv') && <small className="field-error">{err('cvv')}</small>}
              </label>
            )}
          </div>

          {declined && (
            <div className="alert alert-error" role="alert">
              <span>
                <b>Giao dịch bị từ chối.</b> {declined}
              </span>
            </div>
          )}
          {payError && <ErrorBox message={payError} />}

          <button className="btn btn-primary btn-block btn-lg" disabled={busy}>
            {busy ? 'Đang xử lý giao dịch...' : `Thanh toán ${formatMoney(order.totalAmount)}`}
          </button>
          <p className="secure-note small muted">
            🔒 Số thẻ và CVV chỉ dùng để xử lý giao dịch, hệ thống không lưu lại (chỉ lưu 4 số cuối).
          </p>
          <button type="button" className="btn btn-ghost btn-sm" onClick={() => navigate(`/payment/${order.orderId}/transfer`)}>
            Chuyển khoản QR thay vì dùng thẻ
          </button>
        </form>

        <aside>
          <OrderSummary order={order} compact />
          <details className="card test-cards">
            <summary>
              <b>Thẻ thử nghiệm</b> <span className="small muted">(cổng thẻ đang ở chế độ thử nghiệm, không trừ tiền thật)</span>
            </summary>
            <ul className="plain-list">
              {TEST_CARDS.map((t) => (
                <li key={t.number}>
                  <button type="button" className="link-btn mono" onClick={() => fillTest(t)}>
                    {formatCardNumber(t.number)}
                  </button>
                  <span className="small muted"> {t.label}</span>
                </li>
              ))}
            </ul>
            <p className="small muted">Bấm vào số thẻ để điền nhanh. Ngày hết hạn bất kỳ trong tương lai, CVV 3 số bất kỳ.</p>
          </details>
        </aside>
      </div>
    </div>
  );
}
