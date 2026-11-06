/** Repository: Routes + RouteStations */
import { getPool, sql } from '../config/database';
import { ColumnMap, insertRow, updateRow, withTransaction } from '../utils/sqlHelpers';

const SELECT_ROUTE = `
  SELECT r.RouteId AS routeId, r.RouteCode AS routeCode, r.RouteName AS routeName,
         r.TransportTypeId AS transportTypeId, t.Name AS transportTypeName,
         r.Description AS description, r.StartStationId AS startStationId, ss.StationName AS startStationName,
         r.EndStationId AS endStationId, es.StationName AS endStationName, r.Status AS status,
         (SELECT COUNT(*) FROM RouteStations x WHERE x.RouteId = r.RouteId) AS stopCount,
         (SELECT COUNT(*) FROM Trips tr WHERE tr.RouteId = r.RouteId) AS tripCount
  FROM Routes r
  JOIN TransportTypes t ON r.TransportTypeId = t.TransportTypeId
  LEFT JOIN Stations ss ON r.StartStationId = ss.StationId
  LEFT JOIN Stations es ON r.EndStationId = es.StationId`;

const COLUMNS: ColumnMap = {
  routeCode: { column: 'RouteCode', type: sql.VarChar(50) },
  routeName: { column: 'RouteName', type: sql.NVarChar(150) },
  transportTypeId: { column: 'TransportTypeId', type: sql.Int },
  description: { column: 'Description', type: sql.NVarChar(500) },
  status: { column: 'Status', type: sql.VarChar(20) },
};

export interface RouteStopInput {
  stationId: number;
  distanceFromStart?: number | null;
}

export const routeRepository = {
  async list(opts: { transportTypeId?: number; search?: string; includeInactive?: boolean } = {}) {
    const pool = await getPool();
    const req = pool.request();
    const where = ['1 = 1'];
    if (!opts.includeInactive) where.push("r.Status = 'ACTIVE'");
    if (opts.transportTypeId) {
      where.push('r.TransportTypeId = @typeId');
      req.input('typeId', sql.Int, opts.transportTypeId);
    }
    if (opts.search) {
      where.push('(r.RouteCode LIKE @search OR r.RouteName LIKE @search)');
      req.input('search', sql.NVarChar(150), `%${opts.search}%`);
    }
    const r = await req.query(`${SELECT_ROUTE} WHERE ${where.join(' AND ')} ORDER BY r.RouteCode`);
    return r.recordset;
  },

  async getById(id: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, id).query(`${SELECT_ROUTE} WHERE r.RouteId = @id`);
    return r.recordset[0] ?? null;
  },

  /** Cac tram cua 1 tuyen theo thu tu (truy van so 7) */
  async stations(routeId: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, routeId).query(`
      SELECT rs.RouteStationId AS routeStationId, rs.StopOrder AS stopOrder,
             CAST(rs.DistanceFromStart AS FLOAT) AS distanceFromStart,
             s.StationId AS stationId, s.StationCode AS stationCode, s.StationName AS stationName,
             CAST(s.Latitude AS FLOAT) AS latitude, CAST(s.Longitude AS FLOAT) AS longitude,
             s.TransportTypeId AS transportTypeId, s.Status AS status
      FROM RouteStations rs
      JOIN Stations s ON rs.StationId = s.StationId
      WHERE rs.RouteId = @id
      ORDER BY rs.StopOrder`);
    return r.recordset;
  },

  create: (data: Record<string, any>) => insertRow('Routes', 'RouteId', COLUMNS, data),
  update: (id: number, data: Record<string, any>) => updateRow('Routes', 'RouteId', id, COLUMNS, data),

  /**
   * Thay toan bo danh sach tram cua tuyen (Admin keo-tha thu tu tram).
   * Chay trong transaction: xoa cu -> them moi -> cap nhat tram dau/cuoi.
   * Neu tuyen da co StopTimes cho tram bi bo -> SQL bao loi FK 547 -> 409.
   */
  replaceStations(routeId: number, stops: RouteStopInput[]) {
    return withTransaction(async (tx) => {
      await new sql.Request(tx).input('id', sql.Int, routeId).query('DELETE FROM RouteStations WHERE RouteId = @id');
      for (let i = 0; i < stops.length; i++) {
        await new sql.Request(tx)
          .input('routeId', sql.Int, routeId)
          .input('stationId', sql.Int, stops[i].stationId)
          .input('stopOrder', sql.Int, i + 1)
          .input('distance', sql.Decimal(10, 2), stops[i].distanceFromStart ?? null)
          .query(
            `INSERT INTO RouteStations (RouteId, StationId, StopOrder, DistanceFromStart)
             VALUES (@routeId, @stationId, @stopOrder, @distance)`,
          );
      }
      await new sql.Request(tx)
        .input('id', sql.Int, routeId)
        .input('start', sql.Int, stops[0]?.stationId ?? null)
        .input('end', sql.Int, stops[stops.length - 1]?.stationId ?? null)
        .query('UPDATE Routes SET StartStationId = @start, EndStationId = @end WHERE RouteId = @id');
    });
  },
};
