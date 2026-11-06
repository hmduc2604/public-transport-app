/**
 * Repository: xu ly thanh toan trong 1 TRANSACTION
 *
 *   Payment SUCCESS -> Order PAID -> Create Tickets (+ QR)
 *
 * Neu bat ky buoc nao loi -> rollback toan bo (khong co chuyen tru tien ma khong co ve).
 */
import { sql } from '../config/database';
import { withTransaction } from '../utils/sqlHelpers';
import { AppError } from '../utils/AppError';

export interface TicketToIssue {
  ticketTypeId: number;
  ticketCode: string;
  qrCode: string;
  durationMinutes: number;
}

export const paymentRepository = {
  processMockPayment(params: {
    orderId: number;
    userId: number;
    success: boolean;
    transactionCode: string;
    buildTickets: (details: { ticketTypeId: number; quantity: number; durationMinutes: number }[]) => TicketToIssue[];
  }) {
    return withTransaction(async (tx) => {
      // 1. Khoa dong Order (UPDLOCK) de chong thanh toan 2 lan cung luc
      const o = await new sql.Request(tx).input('id', sql.Int, params.orderId).query(`
        SELECT OrderId AS orderId, UserId AS userId, CAST(TotalAmount AS FLOAT) AS totalAmount, Status AS status
        FROM Orders WITH (UPDLOCK, ROWLOCK) WHERE OrderId = @id`);
      const order = o.recordset[0];
      if (!order) throw AppError.notFound('Không tìm thấy đơn hàng', 'ORDER_NOT_FOUND');
      if (order.userId !== params.userId) throw AppError.forbidden('Đơn hàng không thuộc về bạn', 'ORDER_FORBIDDEN');
      if (order.status === 'PAID') throw AppError.conflict('Đơn hàng đã được thanh toán', 'ORDER_ALREADY_PAID');
      if (order.status === 'CANCELLED') throw AppError.conflict('Đơn hàng đã bị hủy', 'ORDER_CANCELLED');

      // 2. Ghi nhan payment
      const p = await new sql.Request(tx)
        .input('orderId', sql.Int, params.orderId)
        .input('amount', sql.Decimal(12, 2), order.totalAmount)
        .input('status', sql.VarChar(20), params.success ? 'SUCCESS' : 'FAILED')
        .input('code', sql.VarChar(100), params.transactionCode).query(`
          INSERT INTO Payments (OrderId, Amount, PaymentMethod, Status, TransactionCode, PaidAt)
          OUTPUT INSERTED.PaymentId AS id
          VALUES (@orderId, @amount, 'MOCK', @status, @code, CASE WHEN @status = 'SUCCESS' THEN SYSDATETIME() ELSE NULL END)`);
      const paymentId: number = p.recordset[0].id;

      if (!params.success) {
        return { paymentId, orderId: params.orderId, amount: order.totalAmount, status: 'FAILED' as const, ticketIds: [] };
      }

      // 3. Order -> PAID
      await new sql.Request(tx)
        .input('id', sql.Int, params.orderId)
        .query(`UPDATE Orders SET Status = 'PAID' WHERE OrderId = @id`);

      // 4. Sinh ve theo OrderDetails (Quantity = so ve)
      const d = await new sql.Request(tx).input('id', sql.Int, params.orderId).query(`
        SELECT d.TicketTypeId AS ticketTypeId, d.Quantity AS quantity, ISNULL(tt.DurationMinutes, 120) AS durationMinutes
        FROM OrderDetails d JOIN TicketTypes tt ON d.TicketTypeId = tt.TicketTypeId
        WHERE d.OrderId = @id`);
      const tickets = params.buildTickets(d.recordset);

      const ticketIds: number[] = [];
      for (const t of tickets) {
        const r = await new sql.Request(tx)
          .input('orderId', sql.Int, params.orderId)
          .input('typeId', sql.Int, t.ticketTypeId)
          .input('code', sql.VarChar(100), t.ticketCode)
          .input('qr', sql.VarChar(500), t.qrCode)
          .input('duration', sql.Int, t.durationMinutes).query(`
            INSERT INTO Tickets (OrderId, TicketTypeId, TicketCode, QRCode, ValidFrom, ValidTo, Status)
            OUTPUT INSERTED.TicketId AS id
            VALUES (@orderId, @typeId, @code, @qr, SYSDATETIME(), DATEADD(MINUTE, @duration, SYSDATETIME()), 'ACTIVE')`);
        ticketIds.push(r.recordset[0].id);
      }

      return { paymentId, orderId: params.orderId, amount: order.totalAmount, status: 'SUCCESS' as const, ticketIds };
    });
  },
};
