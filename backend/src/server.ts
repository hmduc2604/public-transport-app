/** Diem khoi dong backend: npm run dev */
import { createApp } from './app';
import { env } from './config/env';
import { closePool, getPool } from './config/database';
import { hashSeedPasswords } from './config/bootstrap';

async function main() {
  const app = createApp();

  // Thu ket noi DB ngay khi khoi dong de bao loi som (server van chay neu loi)
  getPool()
    .then(() => hashSeedPasswords())
    .catch(() => {
      console.error('[DB] Kiểm tra lại cấu hình DB_* trong file .env (xem README).');
    });

  const server = app.listen(env.port, () => {
    console.log(`🚍 API running at http://localhost:${env.port}/api/v1`);
  });

  const shutdown = async () => {
    console.log('\nShutting down...');
    server.close();
    await closePool().catch(() => undefined);
    process.exit(0);
  };
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
  // Promise bi tu choi ma khong ai bat (vd. gui email nen that bai) -> ghi log, khong lam sap server
  process.on('unhandledRejection', (reason) => console.error('[UNHANDLED REJECTION]', reason));
  // Loi khong ai bat (vd. trong callback/timer) -> ghi log day du truoc khi tien trinh dung
  process.on('uncaughtException', (err) => {
    console.error('[UNCAUGHT EXCEPTION]', err);
  });
  process.on('exit', (code) => {
    if (code !== 0) console.error(`[EXIT] Backend dung voi ma ${code}`);
  });
}

main();
