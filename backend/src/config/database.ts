/**
 * Ket noi SQL Server bang thu vien `mssql` (driver tedious).
 * Dung 1 connection pool dung chung cho toan bo ung dung.
 *
 * Cach dung trong repository:
 *   const pool = await getPool();
 *   const result = await pool.request()
 *       .input('id', sql.Int, id)
 *       .query('SELECT * FROM Stations WHERE StationId = @id');
 */
import sql from 'mssql';
import { env } from './env';

const config: sql.config = {
  server: env.db.server,
  database: env.db.database,
  user: env.db.user,
  password: env.db.password,
  port: env.db.instanceName ? undefined : env.db.port ?? 1433,
  options: {
    encrypt: env.db.encrypt,
    trustServerCertificate: env.db.trustServerCertificate,
    instanceName: env.db.instanceName,
    enableArithAbort: true,
    // Tra ve DATETIME2 theo gio local cua server (khong doi sang UTC)
    useUTC: false,
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

let poolPromise: Promise<sql.ConnectionPool> | null = null;

export function getPool(): Promise<sql.ConnectionPool> {
  if (!poolPromise) {
    poolPromise = new sql.ConnectionPool(config)
      .connect()
      .then((pool) => {
        // Loi phat sinh SAU khi da ket noi (SQL Server khoi dong lai, rot mang...): chi ghi log.
        // Pool tu bo ket noi hong va tao ket noi moi o request sau. Neu khong co listener,
        // EventEmitter se nem loi 'error' ra ngoai va lam dung ca backend.
        pool.on('error', (err: Error) => console.error('[DB] Pool error:', err?.message ?? err));
        console.log(`[DB] Connected to SQL Server: ${env.db.server}/${env.db.database}`);
        return pool;
      })
      .catch((err) => {
        poolPromise = null; // cho phep thu ket noi lai o request sau
        console.error('[DB] Connection failed:', err.message);
        throw err;
      });
  }
  return poolPromise as Promise<sql.ConnectionPool>;
}

export async function closePool(): Promise<void> {
  if (poolPromise) {
    const pool = await poolPromise;
    await pool.close();
    poolPromise = null;
  }
}

export { sql };
