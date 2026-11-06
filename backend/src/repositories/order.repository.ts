/** Repository: Orders + OrderDetails + Payments */
import { getPool, sql } from '../config/database';
import { withTransaction } from '../utils/sqlHelpers';

const ORDER_FIELDS = `
  o.OrderId AS orderId, o.UserId AS userId, u.FullName AS userName, u.Email AS userEmail,
  CAST(o.TotalAmount AS FLOAT) AS totalAmount, o.Status AS status, o.CreatedAt AS createdAt,
  (SELECT TOP 1 p.Status FROM Payments p WHERE p.OrderId = o.OrderId ORDER BY p.PaymentId DESC) AS paymentStatus,
  (SELECT COUNT(*) FROM Tickets tk WHERE tk.OrderId = o.OrderId) AS ticketCount`;

export interface OrderItemInput {
  ticketTypeId: number;
  quantity: number;
  unitPrice: number;
}

export const orderRepository = {
  /** Tao don + chi tiet trong 1 transaction */
  create(userId: number, items: OrderItemInput[]) {
    const total = items.reduce((s, i) => s + i.unitPrice * i.quantity, 0);
    return withTransaction(async (tx) => {
      const r = await new sql.Request(tx)
        .input('userId', sql.Int, userId)
        .input('total', sql.Decimal(12, 2), total)
        .query(`INSERT INTO Orders (UserId, TotalAmount, Status) OUTPUT INSERTED.OrderId AS id VALUES (@userId, @total, 'PENDING')`);
      const orderId: number = r.recordset[0].id;
      for (const it of items) {
        await new sql.Request(tx)
          .input('orderId', sql.Int, orderId)
          .input('typeId', sql.Int, it.ticketTypeId)
          .input('qty', sql.Int, it.quantity)
          .input('price', sql.Decimal(12, 2), it.unitPrice)
          .query(
            `INSERT INTO OrderDetails (OrderId, TicketTypeId, Quantity, UnitPrice) VALUES (@orderId, @typeId, @qty, @price)`,
          );
      }
      return orderId;
    });
  },

  async getById(orderId: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, orderId).query(`
      SELECT ${ORDER_FIELDS} FROM Orders o JOIN Users u ON o.UserId = u.UserId WHERE o.OrderId = @id;
      SELECT d.OrderDetailId AS orderDetailId, d.TicketTypeId AS ticketTypeId, tt.Name AS ticketTypeName,
             tt.Type AS type, tt.DurationMinutes AS durationMinutes, tt.TransportTypeId AS transportTypeId,
             t.Name AS transportTypeName, d.Quantity AS quantity, CAST(d.UnitPrice AS FLOAT) AS unitPrice,
             CAST(d.Quantity * d.UnitPrice AS FLOAT) AS subtotal
      FROM OrderDetails d
      JOIN TicketTypes tt ON d.TicketTypeId = tt.TicketTypeId
      JOIN TransportTypes t ON tt.TransportTypeId = t.TransportTypeId
      WHERE d.OrderId = @id;
      SELECT PaymentId AS paymentId, CAST(Amount AS FLOAT) AS amount, PaymentMethod AS paymentMethod,
             Status AS status, TransactionCode AS transactionCode, PaidAt AS paidAt
      FROM Payments WHERE OrderId = @id ORDER BY PaymentId DESC;
      SELECT TicketId AS ticketId, TicketCode AS ticketCode, Status AS status, ValidFrom AS validFrom, ValidTo AS validTo
      FROM Tickets WHERE OrderId = @id ORDER BY TicketId;`);
    const sets = r.recordsets as any[];
    if (!sets[0][0]) return null;
    return { ...sets[0][0], items: sets[1], payments: sets[2], tickets: sets[3] };
  },

  async listByUser(userId: number) {
    const pool = await getPool();
    const r = await pool.request().input('userId', sql.Int, userId).query(`
      SELECT ${ORDER_FIELDS},
             (SELECT STRING_AGG(CONCAT(tt.Name, ' x', d.Quantity), ', ')
              FROM OrderDetails d JOIN TicketTypes tt ON d.TicketTypeId = tt.TicketTypeId
              WHERE d.OrderId = o.OrderId) AS itemsSummary
      FROM Orders o JOIN Users u ON o.UserId = u.UserId
      WHERE o.UserId = @userId
      ORDER BY o.CreatedAt DESC`);
    return r.recordset;
  },

  async listAll(opts: { search?: string; status?: string; offset: number; pageSize: number }) {
    const pool = await getPool();
    const req = pool.request().input('offset', sql.Int, opts.offset).input('pageSize', sql.Int, opts.pageSize);
    const where = ['1 = 1'];
    if (opts.search) {
      where.push('(u.Email LIKE @search OR u.FullName LIKE @search OR CAST(o.OrderId AS VARCHAR(20)) = @exact)');
      req.input('search', sql.NVarChar(150), `%${opts.search}%`).input('exact', sql.VarChar(20), opts.search);
    }
    if (opts.status) {
      where.push('o.Status = @status');
      req.input('status', sql.VarChar(20), opts.status);
    }
    const w = where.join(' AND ');
    const r = await req.query(`
      SELECT COUNT(*) AS total FROM Orders o JOIN Users u ON o.UserId = u.UserId WHERE ${w};
      SELECT ${ORDER_FIELDS},
             (SELECT STRING_AGG(CONCAT(tt.Name, ' x', d.Quantity), ', ')
              FROM OrderDetails d JOIN TicketTypes tt ON d.TicketTypeId = tt.TicketTypeId
              WHERE d.OrderId = o.OrderId) AS itemsSummary
      FROM Orders o JOIN Users u ON o.UserId = u.UserId WHERE ${w}
      ORDER BY o.OrderId DESC OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;`);
    const sets = r.recordsets as any[];
    return { total: sets[0][0].total as number, items: sets[1] as any[] };
  },

  async updateStatus(orderId: number, status: 'PENDING' | 'PAID' | 'CANCELLED') {
    const pool = await getPool();
    const r = await pool
      .request()
      .input('id', sql.Int, orderId)
      .input('status', sql.VarChar(20), status)
      .query('UPDATE Orders SET Status = @status WHERE OrderId = @id');
    return r.rowsAffected[0] > 0;
  },

  /* ---------------- Payments ---------------- */
  async listPayments(opts: { status?: string; offset: number; pageSize: number }) {
    const pool = await getPool();
    const req = pool.request().input('offset', sql.Int, opts.offset).input('pageSize', sql.Int, opts.pageSize);
    let w = '1 = 1';
    if (opts.status) {
      w = 'p.Status = @status';
      req.input('status', sql.VarChar(20), opts.status);
    }
    const r = await req.query(`
      SELECT COUNT(*) AS total FROM Payments p WHERE ${w};
      SELECT p.PaymentId AS paymentId, p.OrderId AS orderId, CAST(p.Amount AS FLOAT) AS amount,
             p.PaymentMethod AS paymentMethod, p.Status AS status, p.TransactionCode AS transactionCode,
             p.PaidAt AS paidAt, u.FullName AS userName, u.Email AS userEmail
      FROM Payments p JOIN Orders o ON p.OrderId = o.OrderId JOIN Users u ON o.UserId = u.UserId
      WHERE ${w}
      ORDER BY p.PaymentId DESC OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;`);
    const sets = r.recordsets as any[];
    return { total: sets[0][0].total as number, items: sets[1] as any[] };
  },
};
