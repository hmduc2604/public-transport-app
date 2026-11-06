/** Repository: TripHistories (lich su chuyen di) */
import { getPool, sql } from '../config/database';

export const tripHistoryRepository = {
  async listByUser(userId: number, limit = 50) {
    const pool = await getPool();
    const r = await pool.request().input('userId', sql.Int, userId).input('limit', sql.Int, limit).query(`
      SELECT TOP (@limit) TripHistoryId AS tripHistoryId, UserId AS userId, Origin AS origin,
             Destination AS destination, RouteData AS routeData, StartedAt AS startedAt, CompletedAt AS completedAt
      FROM TripHistories WHERE UserId = @userId
      ORDER BY ISNULL(StartedAt, CompletedAt) DESC, TripHistoryId DESC`);
    return r.recordset.map((row: any) => ({ ...row, routeData: safeJson(row.routeData) }));
  },

  async create(data: {
    userId: number;
    origin: string;
    destination: string;
    routeData: unknown;
    startedAt?: Date | null;
    completedAt?: Date | null;
  }) {
    const pool = await getPool();
    const r = await pool
      .request()
      .input('userId', sql.Int, data.userId)
      .input('origin', sql.NVarChar(255), data.origin)
      .input('destination', sql.NVarChar(255), data.destination)
      .input('routeData', sql.NVarChar(sql.MAX), data.routeData ? JSON.stringify(data.routeData) : null)
      .input('startedAt', sql.DateTime2, data.startedAt ?? new Date())
      .input('completedAt', sql.DateTime2, data.completedAt ?? null).query(`
        INSERT INTO TripHistories (UserId, Origin, Destination, RouteData, StartedAt, CompletedAt)
        OUTPUT INSERTED.TripHistoryId AS id
        VALUES (@userId, @origin, @destination, @routeData, @startedAt, @completedAt)`);
    return r.recordset[0].id as number;
  },

  async complete(id: number, userId: number) {
    const pool = await getPool();
    const r = await pool
      .request()
      .input('id', sql.Int, id)
      .input('userId', sql.Int, userId)
      .query('UPDATE TripHistories SET CompletedAt = SYSDATETIME() WHERE TripHistoryId = @id AND UserId = @userId');
    return r.rowsAffected[0] > 0;
  },

  async delete(id: number, userId: number) {
    const pool = await getPool();
    const r = await pool
      .request()
      .input('id', sql.Int, id)
      .input('userId', sql.Int, userId)
      .query('DELETE FROM TripHistories WHERE TripHistoryId = @id AND UserId = @userId');
    return r.rowsAffected[0] > 0;
  },
};

function safeJson(s: string | null) {
  if (!s) return null;
  try {
    return JSON.parse(s);
  } catch {
    return s;
  }
}
