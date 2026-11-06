import { ReactNode } from 'react';

export function Loading({ text = 'Đang tải...' }: { text?: string }) {
  return (
    <div className="feedback">
      <span className="spinner" aria-hidden /> {text}
    </div>
  );
}

export function ErrorBox({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <div className="alert alert-error" role="alert">
      <span>{message}</span>
      {onRetry && (
        <button className="btn btn-sm btn-ghost" onClick={onRetry}>
          Thử lại
        </button>
      )}
    </div>
  );
}

export function Empty({ icon = '🗂️', title, children }: { icon?: string; title: string; children?: ReactNode }) {
  return (
    <div className="empty">
      <div className="empty-icon">{icon}</div>
      <div className="empty-title">{title}</div>
      {children}
    </div>
  );
}

export function StatusBadge({ status, label }: { status: string; label?: string }) {
  return <span className={`badge badge-${status.toLowerCase()}`}>{label ?? status}</span>;
}
