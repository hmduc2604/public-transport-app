/**
 * Chuyen khoan bang ma VietQR (Napas 247)
 *   1. Tao giao dich PENDING: so tien + noi dung chuyen khoan rieng cho don
 *   2. Khach quet QR bang app ngan hang (tu dien so TK, so tien, noi dung)
 *   3. Bam "Toi da chuyen khoan" -> VAN cho xac nhan
 *   4. Ve chi phat hanh khi tien da ve tai khoan (admin xac nhan / webhook ngan hang)
 *      -> trang tu hoi trang thai moi vai giay
 */
import { useCallback, useEffect, useRef, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { paymentApi } from '../services/paymentApi';
import { ticketApi } from '../services/ticketApi';
import { ApiError, errorMessage } from '../services/api';
import { useAsync } from '../utils/useAsync';
import { ErrorBox, Loading } from '../components/Feedback';
import { OrderSummary } from '../components/payment/OrderSummary';
import { PaymentSuccess } from '../components/payment/PaymentSuccess';
import { formatDateTime, formatMoney } from '../utils/format';
import { PaymentView } from '../types';

const POLL_MS = 4000;

function CopyRow({ label, value, display, strong }: { label: string; value: string; display?: string; strong?: boolean }) {
  const [copied, setCopied] = useState(false);
  const copy = async () => {
    try {
      await navigator.clipboard.writeText(value);
      setCopied(true);
      setTimeout(() => setCopied(false), 1500);
    } catch {
      /* trinh duyet chan clipboard */
    }
  };
  return (
    <div className="copy-row">
      <dt>{label}</dt>
      <dd>
        <span className={`${strong ? 'copy-strong ' : ''}mono`}>{display ?? value}</span>
        <button type="button" className="btn btn-xs btn-ghost" onClick={copy} aria-label={`Sao chép ${label}`}>
          {copied ? '✓ Đã chép' : 'Sao chép'}
        </button>
      </dd>
    </div>
  );
}

const pad = (n: number) => String(n).padStart(2, '0');

export default function TransferPaymentPage() {
  const { orderId } = useParams();
  const { data: order, reload: reloadOrder } = useAsync(() => ticketApi.order(Number(orderId)), [orderId]);
  const [view, setView] = useState<PaymentView | null>(null);
  const [error, setError] = useState<{ message: string; code?: string } | null>(null);
  const [busy, setBusy] = useState(false);
  const [deadline, setDeadline] = useState<number | null>(null);
  const [now, setNow] = useState(Date.now());
  const viewRef = useRef<PaymentView | undefined>(undefined);

  const apply = useCallback(
    (v: PaymentView) => {
      const changed = viewRef.current?.status !== v.status;
      viewRef.current = v;
      setView(v);
      setDeadline(v.secondsLeft !== null ? Date.now() + v.secondsLeft * 1000 : null);
      if (changed && v.status !== 'PENDING') reloadOrder(); // don co the da bi huy / da thanh toan
    },
    [reloadOrder],
  );

  const create = useCallback(async () => {
    setBusy(true);
    setError(null);
    try {
      apply(await paymentApi.createTransfer(Number(orderId)));
    } catch (e) {
      setError({ message: errorMessage(e), code: e instanceof ApiError ? e.errorCode : undefined });
      reloadOrder();
    } finally {
      setBusy(false);
    }
  }, [orderId, apply, reloadOrder]);

  useEffect(() => {
    create();
  }, [create]);

  // Hoi trang thai dinh ky khi dang cho tien ve
  useEffect(() => {
    if (!view || view.status !== 'PENDING') return;
    const poll = async () => {
      const cur = viewRef.current;
      if (!cur || document.visibilityState === 'hidden') return;
      try {
        const v = await paymentApi.get(cur.paymentId);
        if (v.status !== cur.status || v.customerNotifiedAt !== cur.customerNotifiedAt) apply(v);
      } catch {
        /* mat mang tam thoi - thu lai lan sau */
      }
    };
    const t = setInterval(poll, POLL_MS);
    document.addEventListener('visibilitychange', poll);
    return () => {
      clearInterval(t);
      document.removeEventListener('visibilitychange', poll);
    };
  }, [view?.paymentId, view?.status, apply]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    const t = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(t);
  }, []);

  const notify = async () => {
    if (!view) return;
    setBusy(true);
    try {
      apply(await paymentApi.notifyTransferred(view.paymentId));
    } catch (e) {
      setError({ message: errorMessage(e) });
      try {
        apply(await paymentApi.get(view.paymentId));
      } catch {
        /* ignore */
      }
    } finally {
      setBusy(false);
    }
  };

  if (!view && !error) return <Loading text="Đang tạo mã QR chuyển khoản..." />;

  if (view?.status === 'SUCCESS' || order?.status === 'PAID') {
    return (
      <PaymentSuccess
        orderId={Number(orderId)}
        amount={view?.amount ?? order?.totalAmount ?? 0}
        ticketIds={view?.ticketIds?.length ? view.ticketIds : order?.tickets?.map((t) => t.ticketId) ?? []}
        detail={view?.status === 'SUCCESS' ? `Đã nhận chuyển khoản lúc ${formatDateTime(view.paidAt)} · nội dung ${view.transferContent}` : undefined}
      />
    );
  }

  const header = (
    <>
      <Link to={`/payment/${orderId}`} className="small">
        ← Đổi phương thức thanh toán
      </Link>
      <h1>Chuyển khoản qua mã QR</h1>
    </>
  );

  if (!view) {
    return (
      <div className="page narrow">
        {header}
        <ErrorBox message={error!.message} />
        <div className="row gap wrap">
          {error!.code === 'TRANSFER_NOT_CONFIGURED' || error!.code === 'ORDER_CANCELLED' ? null : (
            <button className="btn btn-primary" onClick={create} disabled={busy}>
              Thử lại
            </button>
          )}
          <Link to={`/payment/${orderId}/card`} className="btn btn-ghost">
            Thanh toán bằng thẻ
          </Link>
        </div>
      </div>
    );
  }

  const left = deadline !== null ? Math.max(0, Math.round((deadline - now) / 1000)) : null;
  const notified = Boolean(view.customerNotifiedAt);
  const pending = view.status === 'PENDING';
  const timeUp = left === 0;

  return (
    <div className="page">
      {header}
      <div className="pay-layout">
        <div className="card transfer-card">
          {pending && view.bank ? (
            <>
              <div className="transfer-steps small">
                <span className={!notified ? 'on' : 'done'}>1. Quét mã & chuyển khoản</span>
                <span className={notified ? 'on' : ''}>2. Chờ xác nhận tiền về</span>
                <span>3. Nhận vé</span>
              </div>
              <div className="transfer-grid">
                <div className="qr-box">
                  <div className="qr-frame">
                    {view.qrImage && <img src={view.qrImage} alt={`Mã VietQR chuyển ${formatMoney(view.amount)} tới ${view.bank.name}`} width={260} height={260} />}
                    {timeUp && !notified && <div className="qr-expired">Hết hạn</div>}
                  </div>
                  <div className="qr-logos small">
                    <b>VietQR</b> · Napas 247
                  </div>
                  {left !== null && !notified && (
                    <div className={`countdown${left < 120 ? ' urgent' : ''}`} aria-live="polite">
                      Mã hết hạn sau <b className="mono">{pad(Math.floor(left / 60))}:{pad(left % 60)}</b>
                    </div>
                  )}
                  {view.qrImage && (
                    <a className="btn btn-ghost btn-sm" href={view.qrImage} download={`VietQR-${view.transferContent}.png`}>
                      Lưu ảnh QR
                    </a>
                  )}
                </div>
                <div>
                  <p className="small muted">
                    Mở app ngân hàng bất kỳ → <b>Quét QR</b>. Số tài khoản, số tiền và nội dung được điền sẵn. Nếu chuyển thủ công, nhập{' '}
                    <b>chính xác</b> nội dung bên dưới.
                  </p>
                  <dl className="copy-list">
                    <div className="copy-row">
                      <dt>Ngân hàng</dt>
                      <dd>{view.bank.name}</dd>
                    </div>
                    <CopyRow label="Số tài khoản" value={view.bank.accountNo} />
                    <div className="copy-row">
                      <dt>Chủ tài khoản</dt>
                      <dd>{view.bank.accountName}</dd>
                    </div>
                    <CopyRow label="Số tiền" value={String(Math.round(view.amount))} display={formatMoney(view.amount)} strong />
                    <CopyRow label="Nội dung" value={view.transferContent ?? ''} strong />
                  </dl>
                  <div className="alert alert-warn small">
                    <span>
                      Chuyển <b>đúng số tiền</b> và <b>giữ nguyên nội dung</b> để hệ thống nhận ra đơn của bạn.
                    </span>
                  </div>
                </div>
              </div>

              {notified ? (
                <div className="waiting-box" role="status">
                  <span className="spinner" aria-hidden />
                  <div>
                    <b>Đang chờ xác nhận tiền về tài khoản</b>
                    <div className="small muted">
                      Bạn báo đã chuyển lúc {formatDateTime(view.customerNotifiedAt)}. Vé sẽ được phát hành tự động ngay khi hệ thống xác nhận đã nhận đủ{' '}
                      {formatMoney(view.amount)} với nội dung <span className="mono">{view.transferContent}</span>. Bạn có thể rời trang này, vé sẽ xuất
                      hiện trong mục <Link to="/tickets">Vé của tôi</Link>.
                    </div>
                  </div>
                </div>
              ) : (
                <button className="btn btn-primary btn-block btn-lg" onClick={notify} disabled={busy || timeUp}>
                  {busy ? 'Đang gửi...' : 'Tôi đã chuyển khoản'}
                </button>
              )}
              {timeUp && !notified && (
                <button className="btn btn-ghost btn-block" onClick={create} disabled={busy}>
                  Tạo mã QR mới
                </button>
              )}
              {error && <ErrorBox message={error.message} />}
            </>
          ) : (
            <div className="transfer-ended">
              {view.status === 'EXPIRED' && (
                <>
                  <div className="ended-icon">⌛</div>
                  <h3>Mã chuyển khoản đã hết hạn</h3>
                  <p className="muted small">
                    Nếu bạn <b>đã chuyển tiền</b> với nội dung <span className="mono">{view.transferContent}</span>, đừng chuyển lại, hãy liên hệ hỗ trợ để
                    được đối soát. Nếu chưa, tạo mã mới để tiếp tục.
                  </p>
                </>
              )}
              {view.status === 'FAILED' && (
                <>
                  <div className="ended-icon">✕</div>
                  <h3>Chưa xác nhận được giao dịch</h3>
                  <p className="muted small">{view.note ?? 'Không tìm thấy khoản tiền chuyển đến.'}</p>
                </>
              )}
              {view.status === 'CANCELLED' && (
                <>
                  <div className="ended-icon">✕</div>
                  <h3>Giao dịch chuyển khoản đã hủy</h3>
                  <p className="muted small">{view.note}</p>
                </>
              )}
              {!view.bank && view.status === 'PENDING' && <ErrorBox message="Tài khoản nhận tiền đang được cập nhật. Vui lòng thử lại sau." />}
              <div className="row gap center-row wrap">
                {order?.status === 'PENDING' && (
                  <button className="btn btn-primary" onClick={create} disabled={busy}>
                    Tạo mã QR mới
                  </button>
                )}
                <Link to={`/payment/${orderId}`} className="btn btn-ghost">
                  Về đơn hàng
                </Link>
              </div>
              {error && <ErrorBox message={error.message} />}
            </div>
          )}
        </div>
        <aside>{order && <OrderSummary order={order} compact />}</aside>
      </div>
    </div>
  );
}
