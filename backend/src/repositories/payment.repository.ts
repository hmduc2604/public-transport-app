/**
 * Repository: Thanh toan
 *
 *  - THE NGAN HANG : cong thanh toan duyet ngay -> Payment SUCCESS -> Order PAID -> sinh ve (1 transaction)
 *  - CHUYEN KHOAN QR: tao Payment PENDING (noi dung CK duy nhat + han thanh toan).
 *                     Ve CHI duoc sinh khi tien da ve tai khoan: admin xac nhan hoac webhook ngan hang (SePay).
 *
 * Moi buoc doi trang thai deu khoa dong Order (UPDLOCK) -> khong the thanh toan 2 lan / sinh ve 2 lan.
 */
import { getPool, sql } from '../config/database';
import { withTransaction } from '../utils/sqlHelpers';
import { AppError } from '../utils/AppError';

export interface TicketToIssue {
  ticketTypeId: number;
  ticketCode: string;
  qrCode: string;
  durationMinutes: number;
}

export type TicketBuilder = (details: { ticketTypeId: number; quantity: number; durationMinutes: number }[]) => TicketToIssue[];

export interface PaymentSettings {
  bankBin: string | null;
  bankName: string | null;
  accountNo: string | null;
  accountName: string | null;
  transferExpiryMinutes: number;
  updatedAt: string | null;
}

const PAYMENT_FIELDS = `
  p.PaymentId AS paymentId, p.OrderId AS orderId, o.UserId AS userId, CAST(p.Amount AS FLOAT) AS amount,
  p.PaymentMethod AS paymentMethod, p.Status AS status, p.TransactionCode AS transactionCode, p.PaidAt AS paidAt,
  p.CardBrand AS cardBrand, p.CardLast4 AS cardLast4, p.TransferContent AS transferContent,
  p.ExpiresAt AS expiresAt, p.CustomerNotifiedAt AS customerNotifiedAt, p.ConfirmedBy AS confirmedBy,
  p.BankReference AS bankReference, p.Note AS note, p.CreatedAt AS createdAt, o.Status AS orderStatus,
  CASE WHEN p.ExpiresAt IS NULL THEN NULL ELSE DATEDIFF(SECOND, SYSDATETIME(), p.ExpiresAt) END AS secondsLeft`;

type Tx = sql.Transaction;

/** Khoa dong Order va kiem tra con cho thanh toan */
async function lockPendingOrder(tx: Tx, orderId: number, userId?: number) {
  const r = await new sql.Request(tx).input('id', sql.Int, orderId).query(`
    SELECT OrderId AS orderId, UserId AS userId, CAST(TotalAmount AS FLOAT) AS totalAmount, Status AS status
    FROM Orders WITH (UPDLOCK, ROWLOCK) WHERE OrderId = @id`);
  const order = r.recordset[0];
  if (!order) throw AppError.notFound('Không tìm thấy đơn hàng', 'ORDER_NOT_FOUND');
  if (userId !== undefined && order.userId !== userId) throw AppError.forbidden('Đơn hàng không thuộc về bạn', 'ORDER_FORBIDDEN');
  if (order.status === 'PAID') throw AppError.conflict('Đơn hàng đã được thanh toán', 'ORDER_ALREADY_PAID');
  if (order.status === 'CANCELLED') throw AppError.conflict('Đơn hàng đã bị hủy', 'ORDER_CANCELLED');
  return order as { orderId: number; userId: number; totalAmount: number; status: string };
}

/** Order -> PAID + sinh ve theo OrderDetails (Quantity = so ve). Goi ben trong transaction. */
async function markPaidAndIssueTickets(tx: Tx, orderId: number, buildTickets: TicketBuilder) {
  await new sql.Request(tx).input('id', sql.Int, orderId).query(`UPDATE Orders SET Status = 'PAID' WHERE OrderId = @id`);
  const d = await new sql.Request(tx).input('id', sql.Int, orderId).query(`
    SELECT d.TicketTypeId AS ticketTypeId, d.Quantity AS quantity, ISNULL(tt.DurationMinutes, 120) AS durationMinutes
    FROM OrderDetails d JOIN TicketTypes tt ON d.TicketTypeId = tt.TicketTypeId
    WHERE d.OrderId = @id`);
  const ticketIds: number[] = [];
  for (const t of buildTickets(d.recordset)) {
    const r = await new sql.Request(tx)
      .input('orderId', sql.Int, orderId)
      .input('typeId', sql.Int, t.ticketTypeId)
      .input('code', sql.VarChar(100), t.ticketCode)
      .input('qr', sql.VarChar(500), t.qrCode)
      .input('duration', sql.Int, t.durationMinutes).query(`
        INSERT INTO Tickets (OrderId, TicketTypeId, TicketCode, QRCode, ValidFrom, ValidTo, Status)
        OUTPUT INSERTED.TicketId AS id
        VALUES (@orderId, @typeId, @code, @qr, SYSDATETIME(), DATEADD(MINUTE, @duration, SYSDATETIME()), 'ACTIVE')`);
    ticketIds.push(r.recordset[0].id);
  }
  return ticketIds;
}

/** Huy cac giao dich chuyen khoan dang cho cua don (vd. khach doi sang tra bang the) */
async function cancelPendingTransfers(tx: Tx | null, orderId: number, note: string) {
  const req = tx ? new sql.Request(tx) : (await getPool()).request();
  await req.input('orderId', sql.Int, orderId).input('note', sql.NVarChar(255), note).query(`
    UPDATE Payments SET Status = 'CANCELLED', Note = @note
    WHERE OrderId = @orderId AND PaymentMethod = 'BANK_TRANSFER' AND Status = 'PENDING'`);
}

export const paymentRepository = {
  /* ============================== THE NGAN HANG ============================== */
  payByCard(p: {
    orderId: number;
    userId: number;
    approved: boolean;
    failReason?: string;
    cardBrand: string;
    cardLast4: string;
    transactionCode: string;
    buildTickets: TicketBuilder;
  }) {
    return withTransaction(async (tx) => {
      const order = await lockPendingOrder(tx, p.orderId, p.userId);
      const ins = await new sql.Request(tx)
        .input('orderId', sql.Int, p.orderId)
        .input('amount', sql.Decimal(12, 2), order.totalAmount)
        .input('status', sql.VarChar(20), p.approved ? 'SUCCESS' : 'FAILED')
        .input('code', sql.VarChar(100), p.transactionCode)
        .input('brand', sql.VarChar(20), p.cardBrand)
        .input('last4', sql.VarChar(4), p.cardLast4)
        .input('note', sql.NVarChar(255), p.failReason ?? null).query(`
          INSERT INTO Payments (OrderId, Amount, PaymentMethod, Status, TransactionCode, PaidAt, CardBrand, CardLast4, Note)
          OUTPUT INSERTED.PaymentId AS id
          VALUES (@orderId, @amount, 'CARD', @status, @code,
                  CASE WHEN @status = 'SUCCESS' THEN SYSDATETIME() ELSE NULL END, @brand, @last4, @note)`);
      const paymentId: number = ins.recordset[0].id;
      if (!p.approved) return { paymentId, amount: order.totalAmount, status: 'FAILED' as const, ticketIds: [] as number[] };

      await cancelPendingTransfers(tx, p.orderId, 'Khách đã thanh toán bằng thẻ');
      const ticketIds = await markPaidAndIssueTickets(tx, p.orderId, p.buildTickets);
      return { paymentId, amount: order.totalAmount, status: 'SUCCESS' as const, ticketIds };
    });
  },

  /* ============================== CHUYEN KHOAN QR ============================== */
  /**
   * Tao (hoac dung lai) giao dich chuyen khoan dang cho cua don hang.
   * makeContent() sinh noi dung CK ngau nhien; trung (rat hiem) -> thu lai.
   */
  createOrReuseTransfer(p: { orderId: number; userId: number; expiryMinutes: number; makeContent: () => string }) {
    return withTransaction(async (tx) => {
      const order = await lockPendingOrder(tx, p.orderId, p.userId);
      await paymentRepository.expireOverdue(tx);
      const cur = await new sql.Request(tx).input('orderId', sql.Int, p.orderId).query(`
        SELECT TOP 1 PaymentId AS id FROM Payments
        WHERE OrderId = @orderId AND PaymentMethod = 'BANK_TRANSFER' AND Status = 'PENDING'
        ORDER BY PaymentId DESC`);
      if (cur.recordset[0]) return { paymentId: cur.recordset[0].id as number, reused: true };

      for (let attempt = 0; ; attempt++) {
        try {
          const ins = await new sql.Request(tx)
            .input('orderId', sql.Int, p.orderId)
            .input('amount', sql.Decimal(12, 2), order.totalAmount)
            .input('content', sql.VarChar(50), p.makeContent())
            .input('minutes', sql.Int, p.expiryMinutes).query(`
              INSERT INTO Payments (OrderId, Amount, PaymentMethod, Status, TransferContent, ExpiresAt)
              OUTPUT INSERTED.PaymentId AS id
              VALUES (@orderId, @amount, 'BANK_TRANSFER', 'PENDING', @content, DATEADD(MINUTE, @minutes, SYSDATETIME()))`);
          return { paymentId: ins.recordset[0].id as number, reused: false };
        } catch (err: any) {
          if (attempt < 3 && (err?.number === 2601 || err?.number === 2627)) continue; // trung noi dung CK
          throw err;
        }
      }
    });
  },

  /**
   * Giao dich CK qua han -> EXPIRED.
   * Neu khach DA bam "Toi da chuyen khoan" thi giu PENDING de admin doi soat (tien co the da ve).
   */
  async expireOverdue(tx?: Tx) {
    const req = tx ? new sql.Request(tx) : (await getPool()).request();
    await req.query(`
      UPDATE Payments SET Status = 'EXPIRED'
      WHERE PaymentMethod = 'BANK_TRANSFER' AND Status = 'PENDING'
        AND ExpiresAt < SYSDATETIME() AND CustomerNotifiedAt IS NULL`);
  },

  async getById(paymentId: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, paymentId).query(`
      SELECT ${PAYMENT_FIELDS}, u.FullName AS userName, u.Email AS userEmail
      FROM Payments p JOIN Orders o ON p.OrderId = o.OrderId JOIN Users u ON o.UserId = u.UserId
      WHERE p.PaymentId = @id`);
    return r.recordset[0] ?? null;
  },

  async findByTransferContent(content: string) {
    const pool = await getPool();
    const r = await pool.request().input('c', sql.VarChar(50), content).query(`
      SELECT ${PAYMENT_FIELDS} FROM Payments p JOIN Orders o ON p.OrderId = o.OrderId WHERE p.TransferContent = @c`);
    return r.recordset[0] ?? null;
  },

  async findByBankReference(ref: string) {
    const pool = await getPool();
    const r = await pool.request().input('ref', sql.VarChar(100), ref).query(`
      SELECT TOP 1 PaymentId AS paymentId FROM Payments WHERE BankReference = @ref`);
    return r.recordset[0] ?? null;
  },

  /** Khach bam "Toi da chuyen khoan": ghi nhan thoi diem, van PENDING cho doi soat */
  async markCustomerNotified(paymentId: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, paymentId).query(`
      UPDATE Payments SET CustomerNotifiedAt = ISNULL(CustomerNotifiedAt, SYSDATETIME())
      WHERE PaymentId = @id AND PaymentMethod = 'BANK_TRANSFER' AND Status = 'PENDING'`);
    return r.rowsAffected[0] > 0;
  },

  /**
   * Xac nhan DA NHAN TIEN (admin doi soat sao ke / webhook ngan hang)
   * -> Payment SUCCESS -> Order PAID -> sinh ve. Chap nhan ca giao dich da EXPIRED neu don van cho thanh toan
   * (tien ve tre hon han).
   */
  confirmTransfer(p: { paymentId: number; confirmedBy: string; bankReference?: string | null; transactionCode: string; buildTickets: TicketBuilder }) {
    return withTransaction(async (tx) => {
      const r = await new sql.Request(tx).input('id', sql.Int, p.paymentId).query(`
        SELECT PaymentId AS paymentId, OrderId AS orderId, PaymentMethod AS method, Status AS status
        FROM Payments WITH (UPDLOCK, ROWLOCK) WHERE PaymentId = @id`);
      const pay = r.recordset[0];
      if (!pay) throw AppError.notFound('Không tìm thấy giao dịch', 'PAYMENT_NOT_FOUND');
      if (pay.method !== 'BANK_TRANSFER') throw AppError.badRequest('Chỉ xác nhận được giao dịch chuyển khoản', 'PAYMENT_NOT_TRANSFER');
      if (pay.status === 'SUCCESS') throw AppError.conflict('Giao dịch đã được xác nhận trước đó', 'PAYMENT_ALREADY_CONFIRMED');
      if (!['PENDING', 'EXPIRED'].includes(pay.status)) {
        throw AppError.conflict('Giao dịch đã bị hủy / từ chối, không thể xác nhận', 'PAYMENT_NOT_PENDING');
      }
      await lockPendingOrder(tx, pay.orderId);

      await new sql.Request(tx)
        .input('id', sql.Int, p.paymentId)
        .input('by', sql.NVarChar(100), p.confirmedBy)
        .input('ref', sql.VarChar(100), p.bankReference ?? null)
        .input('code', sql.VarChar(100), p.transactionCode).query(`
          UPDATE Payments SET Status = 'SUCCESS', PaidAt = SYSDATETIME(), ConfirmedBy = @by,
                 BankReference = @ref, TransactionCode = @code
          WHERE PaymentId = @id`);
      // Cac giao dich CK khac cua cung don (neu co) -> huy
      await new sql.Request(tx).input('orderId', sql.Int, pay.orderId).input('id', sql.Int, p.paymentId).query(`
        UPDATE Payments SET Status = 'CANCELLED', Note = N'Đơn đã được thanh toán bằng giao dịch khác'
        WHERE OrderId = @orderId AND PaymentId <> @id AND PaymentMethod = 'BANK_TRANSFER' AND Status = 'PENDING'`);
      const ticketIds = await markPaidAndIssueTickets(tx, pay.orderId, p.buildTickets);
      return { paymentId: p.paymentId, orderId: pay.orderId as number, ticketIds };
    });
  },

  /** Admin tu choi: khong thay tien ve / sai so tien */
  async rejectTransfer(paymentId: number, by: string, note: string) {
    const pool = await getPool();
    const r = await pool
      .request()
      .input('id', sql.Int, paymentId)
      .input('by', sql.NVarChar(100), by)
      .input('note', sql.NVarChar(255), note).query(`
        UPDATE Payments SET Status = 'FAILED', ConfirmedBy = @by, Note = @note
        WHERE PaymentId = @id AND PaymentMethod = 'BANK_TRANSFER' AND Status IN ('PENDING', 'EXPIRED')`);
    return r.rowsAffected[0] > 0;
  },

  cancelPendingForOrder: (orderId: number, note: string) => cancelPendingTransfers(null, orderId, note),

  /* ============================== CAU HINH TAI KHOAN NHAN ============================== */
  async getSettings(): Promise<PaymentSettings> {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT BankBin AS bankBin, BankName AS bankName, AccountNo AS accountNo, AccountName AS accountName,
             TransferExpiryMinutes AS transferExpiryMinutes, UpdatedAt AS updatedAt
      FROM PaymentSettings WHERE SettingId = 1`);
    return (
      r.recordset[0] ?? { bankBin: null, bankName: null, accountNo: null, accountName: null, transferExpiryMinutes: 30, updatedAt: null }
    );
  },

  async updateSettings(s: { bankBin: string; bankName: string; accountNo: string; accountName: string; transferExpiryMinutes: number }) {
    const pool = await getPool();
    await pool
      .request()
      .input('bin', sql.VarChar(10), s.bankBin)
      .input('bank', sql.NVarChar(100), s.bankName)
      .input('acc', sql.VarChar(30), s.accountNo)
      .input('name', sql.NVarChar(100), s.accountName)
      .input('min', sql.Int, s.transferExpiryMinutes).query(`
        MERGE PaymentSettings AS t USING (SELECT 1 AS SettingId) AS s ON t.SettingId = s.SettingId
        WHEN MATCHED THEN UPDATE SET BankBin = @bin, BankName = @bank, AccountNo = @acc, AccountName = @name,
             TransferExpiryMinutes = @min, UpdatedAt = SYSDATETIME()
        WHEN NOT MATCHED THEN INSERT (SettingId, BankBin, BankName, AccountNo, AccountName, TransferExpiryMinutes, UpdatedAt)
             VALUES (1, @bin, @bank, @acc, @name, @min, SYSDATETIME());`);
    return paymentRepository.getSettings();
  },

  /** Tat chuyen khoan QR: xoa tai khoan nhan */
  async clearSettings() {
    const pool = await getPool();
    await pool.request().query(`
      UPDATE PaymentSettings SET BankBin = NULL, BankName = NULL, AccountNo = NULL, AccountName = NULL, UpdatedAt = SYSDATETIME()
      WHERE SettingId = 1`);
    return paymentRepository.getSettings();
  },

  /* ============================== ADMIN ============================== */
  async listAll(opts: { status?: string; method?: string; search?: string; offset: number; pageSize: number }) {
    const pool = await getPool();
    const req = pool.request().input('offset', sql.Int, opts.offset).input('pageSize', sql.Int, opts.pageSize);
    const where = ['1 = 1'];
    if (opts.status) {
      where.push('p.Status = @status');
      req.input('status', sql.VarChar(20), opts.status);
    }
    if (opts.method) {
      where.push('p.PaymentMethod = @method');
      req.input('method', sql.VarChar(30), opts.method);
    }
    if (opts.search) {
      where.push(`(u.Email LIKE @search OR u.FullName LIKE @search OR p.TransferContent LIKE @search
                   OR CAST(p.OrderId AS VARCHAR(20)) = @exact)`);
      req.input('search', sql.NVarChar(150), `%${opts.search}%`).input('exact', sql.VarChar(20), opts.search);
    }
    const w = where.join(' AND ');
    const r = await req.query(`
      SELECT COUNT(*) AS total
      FROM Payments p JOIN Orders o ON p.OrderId = o.OrderId JOIN Users u ON o.UserId = u.UserId WHERE ${w};
      SELECT ${PAYMENT_FIELDS}, u.FullName AS userName, u.Email AS userEmail
      FROM Payments p JOIN Orders o ON p.OrderId = o.OrderId JOIN Users u ON o.UserId = u.UserId
      WHERE ${w}
      ORDER BY CASE WHEN p.Status = 'PENDING' THEN 0 ELSE 1 END, p.PaymentId DESC
      OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;`);
    const sets = r.recordsets as any[];
    return { total: sets[0][0].total as number, items: sets[1] as any[] };
  },
};
