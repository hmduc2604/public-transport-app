/** Repository: Trips + StopTimes (lich trinh) */
import { getPool, sql } from '../config/database';
import { withTransaction } from '../utils/sqlHelpers';

const SELECT_TRIP = `
  SELECT tr.TripId AS tripId, tr.RouteId AS routeId, r.RouteCode AS routeCode, r.RouteName AS routeName,
         tr.VehicleId AS vehicleId, v.VehicleCode AS vehicleCode, tr.TripCode AS tripCode,
         CONVERT(VARCHAR(5), tr.DepartureTime, 108) AS departureTime,
         CONVERT(VARCHAR(5), tr.ArrivalTime, 108) AS arrivalTime,
         tr.Status AS status, r.TransportTypeId AS transportTypeId
  FROM Trips tr
  JOIN Routes r ON tr.RouteId = r.RouteId
  JOIN Vehicles v ON tr.VehicleId = v.VehicleId`;

export interface TripInput {
  routeId: number;
  vehicleId: number;
  tripCode: string;
  departureTime: string; // HH:mm
  arrivalTime: string;
  status?: string;
}

export const tripRepository = {
  async list(opts: { routeId?: number; status?: string; limit?: number } = {}) {
    const pool = await getPool();
    const req = pool.request().input('limit', sql.Int, opts.limit ?? 1000);
    const where = ['1 = 1'];
    if (opts.routeId) {
      where.push('tr.RouteId = @routeId');
      req.input('routeId', sql.Int, opts.routeId);
    }
    if (opts.status) {
      where.push('tr.Status = @status');
      req.input('status', sql.VarChar(20), opts.status);
    }
    const r = await req.query(
      `SELECT TOP (@limit) * FROM (${SELECT_TRIP} WHERE ${where.join(' AND ')}) x ORDER BY x.routeCode, x.departureTime`,
    );
    return r.recordset;
  },

  async getById(id: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, id).query(`${SELECT_TRIP} WHERE tr.TripId = @id`);
    return r.recordset[0] ?? null;
  },

  async stopTimes(tripId: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, tripId).query(`
      SELECT st.StopTimeId AS stopTimeId, st.StopOrder AS stopOrder, st.StationId AS stationId,
             s.StationName AS stationName,
             CONVERT(VARCHAR(5), st.ArrivalTime, 108) AS arrivalTime,
             CONVERT(VARCHAR(5), st.DepartureTime, 108) AS departureTime
      FROM StopTimes st JOIN Stations s ON st.StationId = s.StationId
      WHERE st.TripId = @id
      ORDER BY st.StopOrder`);
    return r.recordset;
  },

  /**
   * Tao chuyen + tu sinh StopTimes: noi suy tuyen tinh theo DistanceFromStart
   * giua gio xuat phat va gio den (neu thieu khoang cach thi chia deu).
   */
  create(data: TripInput) {
    return withTransaction(async (tx) => {
      const r = await new sql.Request(tx)
        .input('routeId', sql.Int, data.routeId)
        .input('vehicleId', sql.Int, data.vehicleId)
        .input('tripCode', sql.VarChar(50), data.tripCode)
        .input('dep', sql.VarChar(8), data.departureTime)
        .input('arr', sql.VarChar(8), data.arrivalTime)
        .input('status', sql.VarChar(20), data.status ?? 'SCHEDULED')
        .query(`INSERT INTO Trips (RouteId, VehicleId, TripCode, DepartureTime, ArrivalTime, Status)
                OUTPUT INSERTED.TripId AS id
                VALUES (@routeId, @vehicleId, @tripCode, CAST(@dep AS TIME), CAST(@arr AS TIME), @status)`);
      const tripId: number = r.recordset[0].id;
      await regenerateStopTimes(tx, tripId);
      return tripId;
    });
  },

  update(id: number, data: Partial<TripInput>) {
    return withTransaction(async (tx) => {
      const req = new sql.Request(tx).input('id', sql.Int, id);
      const sets: string[] = [];
      const add = (setClause: string, param: string, type: any, value: unknown) => {
        if (value === undefined) return;
        sets.push(setClause);
        req.input(param, type, value);
      };
      add('RouteId = @routeId', 'routeId', sql.Int, data.routeId);
      add('VehicleId = @vehicleId', 'vehicleId', sql.Int, data.vehicleId);
      add('TripCode = @tripCode', 'tripCode', sql.VarChar(50), data.tripCode);
      add('DepartureTime = CAST(@dep AS TIME)', 'dep', sql.VarChar(8), data.departureTime);
      add('ArrivalTime = CAST(@arr AS TIME)', 'arr', sql.VarChar(8), data.arrivalTime);
      add('Status = @status', 'status', sql.VarChar(20), data.status);
      if (sets.length === 0) return true;
      const r = await req.query(`UPDATE Trips SET ${sets.join(', ')} WHERE TripId = @id`);
      if (r.rowsAffected[0] === 0) return false;
      if (data.routeId !== undefined || data.departureTime !== undefined || data.arrivalTime !== undefined) {
        await regenerateStopTimes(tx, id);
      }
      return true;
    });
  },

  delete(id: number) {
    return withTransaction(async (tx) => {
      await new sql.Request(tx).input('id', sql.Int, id).query('DELETE FROM StopTimes WHERE TripId = @id');
      const r = await new sql.Request(tx).input('id', sql.Int, id).query('DELETE FROM Trips WHERE TripId = @id');
      return r.rowsAffected[0] > 0;
    });
  },
};

async function regenerateStopTimes(tx: sql.Transaction, tripId: number) {
  await new sql.Request(tx).input('id', sql.Int, tripId).query('DELETE FROM StopTimes WHERE TripId = @id');
  await new sql.Request(tx).input('id', sql.Int, tripId).query(`
    ;WITH stops AS (
      SELECT rs.StationId, rs.StopOrder,
             ISNULL(rs.DistanceFromStart, 0) AS Dist,
             MAX(ISNULL(rs.DistanceFromStart, 0)) OVER () AS MaxDist,
             COUNT(*) OVER () AS Cnt
      FROM Trips t JOIN RouteStations rs ON rs.RouteId = t.RouteId
      WHERE t.TripId = @id
    ),
    trip AS (
      SELECT DepartureTime,
             DATEDIFF(MINUTE, DepartureTime, ArrivalTime)
             + CASE WHEN ArrivalTime < DepartureTime THEN 1440 ELSE 0 END AS TotalMin
      FROM Trips WHERE TripId = @id
    )
    INSERT INTO StopTimes (TripId, StationId, ArrivalTime, DepartureTime, StopOrder)
    SELECT @id, s.StationId,
           DATEADD(MINUTE, o.MinOffset, t.DepartureTime),
           DATEADD(MINUTE, o.MinOffset + CASE WHEN s.StopOrder = 1 OR s.StopOrder = s.Cnt THEN 0 ELSE 1 END, t.DepartureTime),
           s.StopOrder
    FROM stops s
    CROSS JOIN trip t
    CROSS APPLY (
      SELECT CAST(ROUND(
        CASE WHEN s.MaxDist > 0 THEN t.TotalMin * s.Dist / s.MaxDist
             WHEN s.Cnt > 1 THEN t.TotalMin * (s.StopOrder - 1) * 1.0 / (s.Cnt - 1)
             ELSE 0 END, 0) AS INT) AS MinOffset
    ) o;`);
}
