/** Repository: bang VerificationCodes (ma xac nhan dang ky gui qua Email / SMS) */
import { getPool, sql } from '../config/database';

export interface VerificationRow {
  verificationId: string;
  purpose: string;
  channel: 'EMAIL' | 'SMS';
  destination: string;
  codeHash: string;
  payload: string;
  attempts: number;
  sendCount: number;
  expiresAt: Date;
  lastSentAt: Date;
  verifiedAt: Date | null;
  /** So giay ke tu lan gui gan nhat (tinh bang dong ho DB) */
  secondsSinceSent: number;
  isExpired: boolean;
}

const FIELDS = `
  VerificationId AS verificationId, Purpose AS purpose, Channel AS channel, Destination AS destination,
  CodeHash AS codeHash, Payload AS payload, Attempts AS attempts, SendCount AS sendCount,
  ExpiresAt AS expiresAt, LastSentAt AS lastSentAt, VerifiedAt AS verifiedAt,
  DATEDIFF(SECOND, LastSentAt, SYSDATETIME()) AS secondsSinceSent,
  CAST(CASE WHEN ExpiresAt < SYSDATETIME() THEN 1 ELSE 0 END AS BIT) AS isExpired`;

export const verificationRepository = {
  async create(v: { verificationId: string; purpose: string; channel: string; destination: string; codeHash: string; payload: string; ttlMinutes: number }) {
    const pool = await getPool();
    await pool
      .request()
      .input('id', sql.VarChar(36), v.verificationId)
      .input('purpose', sql.VarChar(30), v.purpose)
      .input('channel', sql.VarChar(10), v.channel)
      .input('dest', sql.VarChar(150), v.destination)
      .input('hash', sql.VarChar(64), v.codeHash)
      .input('payload', sql.NVarChar(sql.MAX), v.payload)
      .input('ttl', sql.Int, v.ttlMinutes).query(`
        INSERT INTO VerificationCodes (VerificationId, Purpose, Channel, Destination, CodeHash, Payload, ExpiresAt)
        VALUES (@id, @purpose, @channel, @dest, @hash, @payload, DATEADD(MINUTE, @ttl, SYSDATETIME()))`);
  },

  async get(id: string): Promise<VerificationRow | null> {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.VarChar(36), id).query(`SELECT ${FIELDS} FROM VerificationCodes WHERE VerificationId = @id`);
    return r.recordset[0] ?? null;
  },

  /** So lan da gui toi destination trong 60 phut qua (chong spam) */
  async sendsLastHour(destination: string): Promise<number> {
    const pool = await getPool();
    const r = await pool.request().input('dest', sql.VarChar(150), destination).query(`
      SELECT ISNULL(SUM(SendCount), 0) AS total FROM VerificationCodes
      WHERE Destination = @dest AND LastSentAt > DATEADD(HOUR, -1, SYSDATETIME())`);
    return r.recordset[0].total;
  },

  async incrementAttempts(id: string) {
    const pool = await getPool();
    await pool.request().input('id', sql.VarChar(36), id).query('UPDATE VerificationCodes SET Attempts = Attempts + 1 WHERE VerificationId = @id');
  },

  /** Gui lai ma moi: doi hash, gia han, tang SendCount, reset so lan nhap sai */
  async renew(id: string, codeHash: string, ttlMinutes: number) {
    const pool = await getPool();
    await pool.request().input('id', sql.VarChar(36), id).input('hash', sql.VarChar(64), codeHash).input('ttl', sql.Int, ttlMinutes).query(`
      UPDATE VerificationCodes
      SET CodeHash = @hash, Attempts = 0, SendCount = SendCount + 1, LastSentAt = SYSDATETIME(),
          ExpiresAt = DATEADD(MINUTE, @ttl, SYSDATETIME())
      WHERE VerificationId = @id`);
  },

  async markVerified(id: string) {
    const pool = await getPool();
    await pool.request().input('id', sql.VarChar(36), id).query('UPDATE VerificationCodes SET VerifiedAt = SYSDATETIME() WHERE VerificationId = @id');
  },

  async remove(id: string) {
    const pool = await getPool();
    await pool.request().input('id', sql.VarChar(36), id).query('DELETE FROM VerificationCodes WHERE VerificationId = @id');
  },

  /** Don dep ma het han qua 1 ngay */
  async cleanup() {
    const pool = await getPool();
    await pool.request().query(`DELETE FROM VerificationCodes WHERE ExpiresAt < DATEADD(DAY, -1, SYSDATETIME())`);
  },
};
