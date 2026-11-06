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
}

main();
