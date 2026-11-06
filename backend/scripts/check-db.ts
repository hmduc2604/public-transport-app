/**
 * Kiem tra ket noi SQL Server + dem so ban ghi 17 bang.
 * Chay: npm run db:check
 */
import { getPool, closePool } from '../src/config/database';

const TABLES = [
  'Users', 'TransportTypes', 'Vehicles', 'Stations', 'Routes', 'RouteStations', 'Trips', 'StopTimes',
  'TouristAttractions', 'AttractionStations', 'TicketTypes', 'FareRules', 'Orders', 'OrderDetails',
  'Payments', 'Tickets', 'TripHistories',
];

(async () => {
  try {
    const pool = await getPool();
    const v = await pool.request().query('SELECT @@VERSION AS version');
    console.log(v.recordset[0].version.split('\n')[0]);
    for (const t of TABLES) {
      try {
        const r = await pool.request().query(`SELECT COUNT(*) AS n FROM ${t}`);
        console.log(`  ✔ ${t.padEnd(20)} ${r.recordset[0].n}`);
      } catch (e: any) {
        console.log(`  ✘ ${t.padEnd(20)} ${e.message}`);
      }
    }
    const cols = await pool.request().query(
      "SELECT COUNT(*) AS n FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TouristAttractions' AND COLUMN_NAME IN ('History','Highlights','TicketPrice','PopularityScore')",
    );
    if (cols.recordset[0].n < 4) console.log('\n⚠ TouristAttractions thiếu cột mở rộng -> chạy database/04_upgrade_existing_db.sql');
  } catch (e: any) {
    console.error('Không kết nối được SQL Server:', e.message);
    process.exitCode = 1;
  } finally {
    await closePool();
  }
})();
