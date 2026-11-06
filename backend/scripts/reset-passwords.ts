/**
 * Dat lai mat khau = 123456 cho moi tai khoan co PasswordHash chua phai bcrypt
 * (vd: seed cu 'HASH_PASSWORD_001'). Chay: npm run db:reset-passwords
 * Them --all de dat lai TAT CA tai khoan.
 */
import bcrypt from 'bcryptjs';
import { getPool, closePool, sql } from '../src/config/database';

(async () => {
  try {
    const all = process.argv.includes('--all');
    const hash = await bcrypt.hash('123456', 10);
    const pool = await getPool();
    const r = await pool
      .request()
      .input('hash', sql.VarChar(255), hash)
      .query(`UPDATE Users SET PasswordHash = @hash ${all ? '' : "WHERE PasswordHash NOT LIKE '$2%'"}`);
    console.log(`Đã đặt lại mật khẩu (123456) cho ${r.rowsAffected[0]} tài khoản.`);
  } catch (e: any) {
    console.error(e.message);
    process.exitCode = 1;
  } finally {
    await closePool();
  }
})();
