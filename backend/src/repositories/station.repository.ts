/** Repository: bang Stations */
import { getPool, sql } from '../config/database';
import { ColumnMap, haversineSql, insertRow, updateRow } from '../utils/sqlHelpers';

const SELECT_STATION = `
  SELECT s.StationId AS stationId, s.StationCode AS stationCode, s.StationName AS stationName,
         CAST(s.Latitude AS FLOAT) AS latitude, CAST(s.Longitude AS FLOAT) AS longitude,
         s.Address AS address, s.TransportTypeId AS transportTypeId, t.Name AS transportTypeName,
         s.Status AS status
  FROM Stations s
  JOIN TransportTypes t ON s.TransportTypeId = t.TransportTypeId`;

const COLUMNS: ColumnMap = {
  stationCode: { column: 'StationCode', type: sql.VarChar(50) },
  stationName: { column: 'StationName', type: sql.NVarChar(150) },
  latitude: { column: 'Latitude', type: sql.Decimal(9, 6) },
  longitude: { column: 'Longitude', type: sql.Decimal(9, 6) },
  address: { column: 'Address', type: sql.NVarChar(255) },
  transportTypeId: { column: 'TransportTypeId', type: sql.Int },
  status: { column: 'Status', type: sql.VarChar(20) },
};

export const stationRepository = {
  async list(opts: { transportTypeId?: number; search?: string; includeInactive?: boolean } = {}) {
    const pool = await getPool();
    const req = pool.request();
    const where = ['1 = 1'];
    if (!opts.includeInactive) where.push("s.Status = 'ACTIVE'");
    if (opts.transportTypeId) {
      where.push('s.TransportTypeId = @typeId');
      req.input('typeId', sql.Int, opts.transportTypeId);
    }
    if (opts.search) {
      where.push('(s.StationName LIKE @search OR s.StationCode LIKE @search OR s.Address LIKE @search)');
      req.input('search', sql.NVarChar(150), `%${opts.search}%`);
    }
    const r = await req.query(`${SELECT_STATION} WHERE ${where.join(' AND ')} ORDER BY s.TransportTypeId, s.StationName`);
    return r.recordset;
  },

  async getById(id: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, id).query(`${SELECT_STATION} WHERE s.StationId = @id`);
    return r.recordset[0] ?? null;
  },

  /** Tram gan toa do (truy van so 3 - Haversine) */
  async nearby(lat: number, lng: number, radiusKm: number, limit: number, transportTypeId?: number) {
    const pool = await getPool();
    const req = pool
      .request()
      .input('lat', sql.Float, lat)
      .input('lng', sql.Float, lng)
      .input('radius', sql.Float, radiusKm)
      .input('limit', sql.Int, limit);
    let typeFilter = '';
    if (transportTypeId) {
      typeFilter = 'AND s.TransportTypeId = @typeId';
      req.input('typeId', sql.Int, transportTypeId);
    }
    const r = await req.query(`
      SELECT TOP (@limit) * FROM (
        SELECT s.StationId AS stationId, s.StationCode AS stationCode, s.StationName AS stationName,
               CAST(s.Latitude AS FLOAT) AS latitude, CAST(s.Longitude AS FLOAT) AS longitude,
               s.Address AS address, s.TransportTypeId AS transportTypeId, t.Name AS transportTypeName,
               ${haversineSql('s.Latitude', 's.Longitude')} AS distanceKm
        FROM Stations s JOIN TransportTypes t ON s.TransportTypeId = t.TransportTypeId
        WHERE s.Status = 'ACTIVE' ${typeFilter}
      ) x
      WHERE x.distanceKm <= @radius
      ORDER BY x.distanceKm`);
    return r.recordset;
  },

  /** Cac tuyen di qua 1 tram */
  async routesOfStation(stationId: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, stationId).query(`
      SELECT r.RouteId AS routeId, r.RouteCode AS routeCode, r.RouteName AS routeName,
             r.TransportTypeId AS transportTypeId, t.Name AS transportTypeName, rs.StopOrder AS stopOrder
      FROM RouteStations rs
      JOIN Routes r ON rs.RouteId = r.RouteId
      JOIN TransportTypes t ON r.TransportTypeId = t.TransportTypeId
      WHERE rs.StationId = @id AND r.Status = 'ACTIVE'
      ORDER BY r.RouteCode`);
    return r.recordset;
  },

  /** Diem tham quan gan tram */
  async attractionsOfStation(stationId: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, stationId).query(`
      SELECT a.AttractionId AS attractionId, a.Name AS name, a.Category AS category,
             ats.WalkingDistance AS walkingDistance, ats.WalkingDuration AS walkingDuration
      FROM AttractionStations ats
      JOIN TouristAttractions a ON a.AttractionId = ats.AttractionId
      WHERE ats.StationId = @id AND a.Status = 'ACTIVE'
      ORDER BY ats.WalkingDistance`);
    return r.recordset;
  },

  create: (data: Record<string, any>) => insertRow('Stations', 'StationId', COLUMNS, data),
  update: (id: number, data: Record<string, any>) => updateRow('Stations', 'StationId', id, COLUMNS, data),
};
