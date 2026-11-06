/**
 * Trang CRUD dung chung cho Admin (cau hinh bang props):
 *   bang du lieu + tim kiem + loc + form them/sua trong modal + xoa.
 * Dung cho: Loai phuong tien, Phuong tien, Tram, Tuyen, Lich trinh, Loai ve, Bang gia, Diem tham quan.
 */
import { FormEvent, ReactNode, useEffect, useMemo, useState } from 'react';
import { crudApi } from '../../services/adminApi';
import { errorMessage } from '../../services/api';
import { Empty, ErrorBox, Loading } from '../../components/Feedback';
import { Modal } from '../../components/Modal';

export type Option = { value: string | number; label: string };

export interface FieldDef {
  name: string;
  label: string;
  type?: 'text' | 'number' | 'select' | 'textarea' | 'time';
  required?: boolean;
  options?: Option[];
  optionsLoader?: () => Promise<Option[]>;
  placeholder?: string;
  step?: string;
  /** chi hien khi tao moi / chi hien khi sua */
  only?: 'create' | 'edit';
  full?: boolean;
  defaultValue?: string | number;
}

export interface ColumnDef<T> {
  key: string;
  label: string;
  render?: (row: T) => ReactNode;
  className?: string;
}

export interface FilterDef {
  name: string;
  label: string;
  options?: Option[];
  optionsLoader?: () => Promise<Option[]>;
}

export interface CrudPageProps<T> {
  title: string;
  subtitle?: string;
  idKey: string;
  api: ReturnType<typeof crudApi<T>>;
  columns: ColumnDef<T>[];
  fields: FieldDef[];
  filters?: FilterDef[];
  searchable?: boolean;
  deleteLabel?: string;
  deleteConfirm?: string;
  rowActions?: (row: T, reload: () => void) => ReactNode;
  toPayload?: (form: Record<string, any>, editing: T | null) => Record<string, any>;
}

export function CrudPage<T extends Record<string, any>>(props: CrudPageProps<T>) {
  const { title, subtitle, idKey, api, columns, fields, filters = [], searchable = true } = props;
  const [rows, setRows] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [filterValues, setFilterValues] = useState<Record<string, string>>({});
  const [options, setOptions] = useState<Record<string, Option[]>>({});
  const [editing, setEditing] = useState<T | null>(null);
  const [creating, setCreating] = useState(false);
  const [form, setForm] = useState<Record<string, any>>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      setRows(await api.list({ search: search || undefined, ...filterValues }));
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const t = setTimeout(load, 250);
    return () => clearTimeout(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [search, filterValues]);

  // Tai danh sach lua chon cho select (vd: loai phuong tien, tuyen, tram)
  useEffect(() => {
    const loaders = [...fields, ...filters].filter((f) => f.optionsLoader);
    Promise.all(loaders.map((f) => f.optionsLoader!().then((o) => [f.name, o] as const))).then((pairs) =>
      setOptions(Object.fromEntries(pairs)),
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const optionsOf = (f: { name: string; options?: Option[] }) => f.options ?? options[f.name] ?? [];

  const openCreate = () => {
    const init: Record<string, any> = {};
    fields.forEach((f) => {
      if (f.defaultValue !== undefined) init[f.name] = f.defaultValue;
    });
    setForm(init);
    setFormError(null);
    setEditing(null);
    setCreating(true);
  };

  const openEdit = (row: T) => {
    const init: Record<string, any> = {};
    fields.forEach((f) => {
      const v = row[f.name];
      init[f.name] = Array.isArray(v) ? v.join(' | ') : v ?? '';
    });
    setForm(init);
    setFormError(null);
    setEditing(row);
    setCreating(true);
  };

  const close = () => {
    setCreating(false);
    setEditing(null);
  };

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    setSaving(true);
    setFormError(null);
    try {
      const data: Record<string, any> = {};
      for (const f of fields) {
        if (f.only === 'create' && editing) continue;
        if (f.only === 'edit' && !editing) continue;
        let v = form[f.name];
        if (v === undefined) continue;
        if (f.type === 'number' || (f.type === 'select' && typeof optionsOf(f)[0]?.value === 'number')) {
          v = v === '' || v === null ? null : Number(v);
        }
        data[f.name] = v;
      }
      const payload = props.toPayload ? props.toPayload(data, editing) : data;
      if (editing) await api.update(editing[idKey], payload as Partial<T>);
      else await api.create(payload as Partial<T>);
      close();
      load();
    } catch (err) {
      setFormError(errorMessage(err));
    } finally {
      setSaving(false);
    }
  };

  const remove = async (row: T) => {
    if (!confirm(props.deleteConfirm ?? `Xóa / ngừng hoạt động bản ghi #${row[idKey]}?`)) return;
    try {
      await api.remove(row[idKey]);
      load();
    } catch (err) {
      alert(errorMessage(err));
    }
  };

  const visibleFields = useMemo(
    () => fields.filter((f) => !(f.only === 'create' && editing) && !(f.only === 'edit' && !editing)),
    [fields, editing],
  );

  return (
    <div className="admin-page">
      <div className="admin-head">
        <div>
          <h1>{title}</h1>
          {subtitle && <p className="muted">{subtitle}</p>}
        </div>
        <button className="btn btn-primary" onClick={openCreate}>
          + Thêm mới
        </button>
      </div>

      <div className="toolbar">
        {searchable && <input className="input" placeholder="🔎 Tìm kiếm..." value={search} onChange={(e) => setSearch(e.target.value)} />}
        {filters.map((f) => (
          <select
            key={f.name}
            className="input"
            value={filterValues[f.name] ?? ''}
            onChange={(e) => setFilterValues((v) => ({ ...v, [f.name]: e.target.value }))}
          >
            <option value="">{f.label}: tất cả</option>
            {optionsOf(f).map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
              </option>
            ))}
          </select>
        ))}
        <span className="muted small">{rows.length} bản ghi</span>
      </div>

      {error && <ErrorBox message={error} onRetry={load} />}
      {loading ? (
        <Loading />
      ) : rows.length === 0 ? (
        <Empty title="Chưa có dữ liệu" />
      ) : (
        <div className="table-wrap card">
          <table className="table">
            <thead>
              <tr>
                {columns.map((c) => (
                  <th key={c.key} className={c.className}>
                    {c.label}
                  </th>
                ))}
                <th className="right">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => (
                <tr key={row[idKey]}>
                  {columns.map((c) => (
                    <td key={c.key} className={c.className}>
                      {c.render ? c.render(row) : String(row[c.key] ?? '—')}
                    </td>
                  ))}
                  <td className="right nowrap">
                    {props.rowActions?.(row, load)}
                    <button className="btn btn-xs btn-ghost" onClick={() => openEdit(row)}>
                      Sửa
                    </button>
                    <button className="btn btn-xs btn-ghost danger" onClick={() => remove(row)}>
                      {props.deleteLabel ?? 'Xóa'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {creating && (
        <Modal title={editing ? `Sửa ${title.toLowerCase()} #${editing[idKey]}` : `Thêm ${title.toLowerCase()}`} onClose={close} wide>
          <form onSubmit={submit} className="form-grid">
            {visibleFields.map((f) => (
              <label key={f.name} className={`field${f.full || f.type === 'textarea' ? ' full' : ''}`}>
                <span>
                  {f.label}
                  {f.required && <b className="req"> *</b>}
                </span>
                {f.type === 'select' ? (
                  <select
                    className="input"
                    value={form[f.name] ?? ''}
                    required={f.required}
                    onChange={(e) => setForm({ ...form, [f.name]: e.target.value })}
                  >
                    <option value="">-- Chọn --</option>
                    {optionsOf(f).map((o) => (
                      <option key={o.value} value={o.value}>
                        {o.label}
                      </option>
                    ))}
                  </select>
                ) : f.type === 'textarea' ? (
                  <textarea
                    className="input"
                    rows={3}
                    value={form[f.name] ?? ''}
                    placeholder={f.placeholder}
                    required={f.required}
                    onChange={(e) => setForm({ ...form, [f.name]: e.target.value })}
                  />
                ) : (
                  <input
                    className="input"
                    type={f.type === 'number' ? 'number' : f.type === 'time' ? 'time' : 'text'}
                    step={f.step ?? (f.type === 'number' ? 'any' : undefined)}
                    value={form[f.name] ?? ''}
                    placeholder={f.placeholder}
                    required={f.required}
                    onChange={(e) => setForm({ ...form, [f.name]: e.target.value })}
                  />
                )}
              </label>
            ))}
            {formError && (
              <div className="full">
                <ErrorBox message={formError} />
              </div>
            )}
            <div className="full row gap end">
              <button type="button" className="btn btn-ghost" onClick={close}>
                Hủy
              </button>
              <button className="btn btn-primary" disabled={saving}>
                {saving ? 'Đang lưu...' : 'Lưu'}
              </button>
            </div>
          </form>
        </Modal>
      )}
    </div>
  );
}
