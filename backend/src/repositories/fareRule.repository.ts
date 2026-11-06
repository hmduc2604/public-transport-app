/** Repository: FareRules (gia ve theo cap tram) */
import { getPool, sql } from '../config/database';
import { ColumnMap, deleteRow, insertRow, updateRow } from '../utils/sqlHelpers';

const COLUMNS: ColumnMap = {
  transportTypeId: { column: 'TransportTypeId', type: sql.Int },
  fromStationId: { column: 'FromStationId', type: sql.Int },
  toStationId: { column: 'ToStationId', type: sql.Int },
  price: { column: 'Price', type: sql.Decimal(12, 2) },
};

export const fareRuleRepository = {
  async list(transportTypeId?: number) {
    const pool = await getPool();
    const req = pool.request();
    let w = '1 = 1';
    if (transportTypeId) {
      w = 'f.TransportTypeId = @typeId';
      req.input('typeId', sql.Int, transportTypeId);
    }
    const r = await req.query(`
      SELECT f.FareRuleId AS fareRuleId, f.TransportTypeId AS transportTypeId, t.Name AS transportTypeName,
             f.FromStationId AS fromStationId, fs.StationName AS fromStationName,
             f.ToStationId AS toStationId, ts.StationName AS toStationName, CAST(f.Price AS FLOAT) AS price
      FROM FareRules f
      JOIN TransportTypes t ON f.TransportTypeId = t.TransportTypeId
      JOIN Stations fs ON f.FromStationId = fs.StationId
      JOIN Stations ts ON f.ToStationId = ts.StationId
      WHERE ${w}
      ORDER BY f.TransportTypeId, fs.StationName`);
    return r.recordset;
  },

  async getById(id: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, id).query(`
      SELECT FareRuleId AS fareRuleId, TransportTypeId AS transportTypeId, FromStationId AS fromStationId,
             ToStationId AS toStationId, CAST(Price AS FLOAT) AS price
      FROM FareRules WHERE FareRuleId = @id`);
    return r.recordset[0] ?? null;
  },

  create: (data: Record<string, any>) => insertRow('FareRules', 'FareRuleId', COLUMNS, data),
  update: (id: number, data: Record<string, any>) => updateRow('FareRules', 'FareRuleId', id, COLUMNS, data),
  delete: (id: number) => deleteRow('FareRules', 'FareRuleId', id),
};
