export function Pager({ page, totalPages, total, onChange }: { page: number; totalPages: number; total: number; onChange: (p: number) => void }) {
  return (
    <div className="pager">
      <span className="muted small">{total} bản ghi</span>
      <button className="btn btn-xs btn-ghost" disabled={page <= 1} onClick={() => onChange(page - 1)}>
        ‹ Trước
      </button>
      <span className="small">
        Trang {page}/{totalPages}
      </span>
      <button className="btn btn-xs btn-ghost" disabled={page >= totalPages} onClick={() => onChange(page + 1)}>
        Sau ›
      </button>
    </div>
  );
}
