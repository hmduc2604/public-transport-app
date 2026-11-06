/** Repository: TicketTypes + Tickets */
import { getPool, sql } from '../config/database';
import { ColumnMap, insertRow, updateRow } from '../utils/sqlHelpers';

const TYPE_FIELDS = `
  tt.TicketTypeId AS ticketTypeId, tt.Name AS name, tt.TransportTypeId AS transportTypeId,
  t.Name AS transportTypeName, tt.Type AS type, CAST(tt.Price AS FLOAT) AS price,
  tt.DurationMinutes AS durationMinutes, tt.Description AS description, tt.Status AS status`;

const TYPE_COLUMNS: ColumnMap = {
  name: { column: 'Name', type: sql.NVarChar(100) },
  transportTypeId: { column: 'TransportTypeId', type: sql.Int },
  type: { column: 'Type', type: sql.VarChar(20) },
  price: { column: 'Price', type: sql.Decimal(12, 2) },
  durationMinutes: { column: 'DurationMinutes', type: sql.Int },
  description: { column: 'Description', type: sql.NVarChar(500) },
  status: { column: 'Status', type: sql.VarChar(20) },
};

const TICKET_FIELDS = `
  tk.TicketId AS ticketId, tk.OrderId AS orderId, tk.TicketCode AS ticketCode, tk.QRCode AS qrCode,
  tk.ValidFrom AS validFrom, tk.ValidTo AS validTo, tk.Status AS status,
  tk.TicketTypeId AS ticketTypeId, tt.Name AS ticketTypeName, tt.Type AS type,
  CAST(tt.Price AS FLOAT) AS price, tt.TransportTypeId AS transportTypeId, t.Name AS transportTypeName,
  o.UserId AS userId, u.FullName AS userName, u.Email AS userEmail,
  -- Tinh trong SQL (dung dong ho cua DB) -> khong phu thuoc mui gio giua DB va Node
  CAST(CASE WHEN tk.Status = 'ACTIVE' AND SYSDATETIME() BETWEEN tk.ValidFrom AND tk.ValidTo THEN 1 ELSE 0 END AS BIT) AS isValidNow,
  CASE WHEN tk.Status = 'ACTIVE' AND tk.ValidTo > SYSDATETIME() THEN DATEDIFF(MINUTE, SYSDATETIME(), tk.ValidTo) ELSE 0 END AS remainingMinutes`;

const TICKET_FROM = `
  FROM Tickets tk
  JOIN TicketTypes tt ON tk.TicketTypeId = tt.TicketTypeId
  JOIN TransportTypes t ON tt.TransportTypeId = t.TransportTypeId
  JOIN Orders o ON tk.OrderId = o.OrderId
  JOIN Users u ON o.UserId = u.UserId`;

export const ticketRepository = {
  /* ---------------- TicketTypes ---------------- */
  async listTypes(opts: { type?: string; transportTypeId?: number; includeInactive?: boolean } = {}) {
    const pool = await getPool();
    const req = pool.request();
    const where = ['1 = 1'];
    if (!opts.includeInactive) where.push("tt.Status = 'ACTIVE'");
    if (opts.type) {
      where.push('tt.Type = @type');
      req.input('type', sql.VarChar(20), opts.type);
    }
    if (opts.transportTypeId) {
      where.push('tt.TransportTypeId = @typeId');
      req.input('typeId', sql.Int, opts.transportTypeId);
    }
    const r = await req.query(`
      SELECT ${TYPE_FIELDS} FROM TicketTypes tt
      JOIN TransportTypes t ON tt.TransportTypeId = t.TransportTypeId
      WHERE ${where.join(' AND ')}
      ORDER BY tt.Type DESC, tt.TransportTypeId, tt.Price`);
    return r.recordset;
  },

  async getType(id: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, id).query(`
      SELECT ${TYPE_FIELDS} FROM TicketTypes tt
      JOIN TransportTypes t ON tt.TransportTypeId = t.TransportTypeId
      WHERE tt.TicketTypeId = @id`);
    return r.recordset[0] ?? null;
  },

  createType: (data: Record<string, any>) => insertRow('TicketTypes', 'TicketTypeId', TYPE_COLUMNS, data),
  updateType: (id: number, data: Record<string, any>) =>
    updateRow('TicketTypes', 'TicketTypeId', id, TYPE_COLUMNS, data),

  /* ---------------- Tickets ---------------- */

  /** Ve ACTIVE da qua han -> EXPIRED (goi truoc khi doc danh sach ve) */
  async expireOverdue() {
    const pool = await getPool();
    await pool.request().query(`UPDATE Tickets SET Status = 'EXPIRED' WHERE Status = 'ACTIVE' AND ValidTo < SYSDATETIME()`);
  },

  async listByUser(userId: number, status?: string) {
    const pool = await getPool();
    const req = pool.request().input('userId', sql.Int, userId);
    let filter = '';
    if (status) {
      filter = 'AND tk.Status = @status';
      req.input('status', sql.VarChar(20), status);
    }
    const r = await req.query(`
      SELECT ${TICKET_FIELDS} ${TICKET_FROM}
      WHERE o.UserId = @userId ${filter}
      ORDER BY CASE tk.Status WHEN 'ACTIVE' THEN 0 ELSE 1 END, tk.ValidFrom DESC`);
    return r.recordset;
  },

  async getById(ticketId: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, ticketId).query(`SELECT ${TICKET_FIELDS} ${TICKET_FROM} WHERE tk.TicketId = @id`);
    return r.recordset[0] ?? null;
  },

  async getByCode(code: string) {
    const pool = await getPool();
    const r = await pool.request().input('code', sql.VarChar(100), code).query(`SELECT ${TICKET_FIELDS} ${TICKET_FROM} WHERE tk.TicketCode = @code`);
    return r.recordset[0] ?? null;
  },

  /** Ve thang con han cua user -> danh sach TransportTypeId (dung cho routing) */
  async activePassTransportTypes(userId: number): Promise<number[]> {
    const pool = await getPool();
    const r = await pool.request().input('userId', sql.Int, userId).query(`
      SELECT DISTINCT tt.TransportTypeId AS transportTypeId ${TICKET_FROM}
      WHERE o.UserId = @userId AND tt.Type = 'MONTHLY' AND tk.Status = 'ACTIVE'
        AND SYSDATETIME() BETWEEN tk.ValidFrom AND tk.ValidTo`);
    return r.recordset.map((x: any) => x.transportTypeId);
  },

  async updateStatus(ticketId: number, status: string) {
    const pool = await getPool();
    const r = await pool
      .request()
      .input('id', sql.Int, ticketId)
      .input('status', sql.VarChar(20), status)
      .query('UPDATE Tickets SET Status = @status WHERE TicketId = @id');
    return r.rowsAffected[0] > 0;
  },

  /** Admin: danh sach ve co loc + phan trang */
  async listAll(opts: { search?: string; status?: string; type?: string; offset: number; pageSize: number }) {
    const pool = await getPool();
    const req = pool.request().input('offset', sql.Int, opts.offset).input('pageSize', sql.Int, opts.pageSize);
    const where = ['1 = 1'];
    if (opts.search) {
      where.push('(tk.TicketCode LIKE @search OR u.Email LIKE @search OR u.FullName LIKE @search)');
      req.input('search', sql.NVarChar(150), `%${opts.search}%`);
    }
    if (opts.status) {
      where.push('tk.Status = @status');
      req.input('status', sql.VarChar(20), opts.status);
    }
    if (opts.type) {
      where.push('tt.Type = @type');
      req.input('type', sql.VarChar(20), opts.type);
    }
    const w = where.join(' AND ');
    const r = await req.query(`
      SELECT COUNT(*) AS total ${TICKET_FROM} WHERE ${w};
      SELECT ${TICKET_FIELDS} ${TICKET_FROM} WHERE ${w}
      ORDER BY tk.TicketId DESC OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;`);
    const sets = r.recordsets as any[];
    return { total: sets[0][0].total as number, items: sets[1] as any[] };
  },
};
