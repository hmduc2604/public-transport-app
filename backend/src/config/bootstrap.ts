/**
 * Chay 1 lan khi backend khoi dong.
 *
 * File seed (02_seed.sql) khong the tao san bcrypt hash bang T-SQL, nen
 * mat khau mau duoc luu dang 'SEED:<mat khau>'. Ham nay tim cac dong do
 * va thay bang bcrypt hash that -> sau lan khoi dong dau, dang nhap binh thuong.
 */
import bcrypt from 'bcryptjs';
import { getPool, sql } from './database';

export async function hashSeedPasswords(): Promise<void> {
  const pool = await getPool();
  const r = await pool
    .request()
    .query("SELECT UserId AS userId, PasswordHash AS passwordHash FROM Users WHERE PasswordHash LIKE 'SEED:%'");
  for (const row of r.recordset as { userId: number; passwordHash: string }[]) {
    const plain = row.passwordHash.slice('SEED:'.length);
    const hash = await bcrypt.hash(plain, 10);
    await pool
      .request()
      .input('id', sql.Int, row.userId)
      .input('hash', sql.VarChar(255), hash)
      .query('UPDATE Users SET PasswordHash = @hash WHERE UserId = @id');
  }
  if (r.recordset.length > 0) {
    console.log(`[Bootstrap] Đã băm bcrypt mật khẩu cho ${r.recordset.length} tài khoản seed.`);
  }
}
