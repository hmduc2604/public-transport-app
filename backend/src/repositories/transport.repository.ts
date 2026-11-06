/** Repository: TransportTypes + Vehicles */
import { getPool, sql } from '../config/database';
import { ColumnMap, deleteRow, insertRow, updateRow } from '../utils/sqlHelpers';

const TYPE_COLUMNS: ColumnMap = {
  name: { column: 'Name', type: sql.NVarChar(50) },
  description: { column: 'Description', type: sql.NVarChar(255) },
  status: { column: 'Status', type: sql.VarChar(20) },
};

const VEHICLE_COLUMNS: ColumnMap = {
  transportTypeId: { column: 'TransportTypeId', type: sql.Int },
  vehicleCode: { column: 'VehicleCode', type: sql.VarChar(50) },
  vehicleName: { column: 'VehicleName', type: sql.NVarChar(100) },
  capacity: { column: 'Capacity', type: sql.Int },
  status: { column: 'Status', type: sql.VarChar(20) },
};

export const transportRepository = {
  /* ---------------- TransportTypes ---------------- */
  async listTypes(includeInactive = false) {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT t.TransportTypeId AS transportTypeId, t.Name AS name, t.Description AS description, t.Status AS status,
             (SELECT COUNT(*) FROM Stations s WHERE s.TransportTypeId = t.TransportTypeId AND s.Status = 'ACTIVE') AS stationCount,
             (SELECT COUNT(*) FROM Routes r WHERE r.TransportTypeId = t.TransportTypeId AND r.Status = 'ACTIVE') AS routeCount,
             (SELECT COUNT(*) FROM Vehicles v WHERE v.TransportTypeId = t.TransportTypeId) AS vehicleCount
      FROM TransportTypes t
      ${includeInactive ? '' : "WHERE t.Status = 'ACTIVE'"}
      ORDER BY t.TransportTypeId`);
    return r.recordset;
  },

  async getType(id: number) {
    const pool = await getPool();
    const r = await pool
      .request()
      .input('id', sql.Int, id)
      .query(
        `SELECT TransportTypeId AS transportTypeId, Name AS name, Description AS description, Status AS status
         FROM TransportTypes WHERE TransportTypeId = @id`,
      );
    return r.recordset[0] ?? null;
  },

  createType: (data: Record<string, any>) => insertRow('TransportTypes', 'TransportTypeId', TYPE_COLUMNS, data),
  updateType: (id: number, data: Record<string, any>) =>
    updateRow('TransportTypes', 'TransportTypeId', id, TYPE_COLUMNS, data),

  /* ---------------- Vehicles ---------------- */
  async listVehicles(opts: { transportTypeId?: number; status?: string; search?: string } = {}) {
    const pool = await getPool();
    const req = pool.request();
    const where = ['1 = 1'];
    if (opts.transportTypeId) {
      where.push('v.TransportTypeId = @typeId');
      req.input('typeId', sql.Int, opts.transportTypeId);
    }
    if (opts.status) {
      where.push('v.Status = @status');
      req.input('status', sql.VarChar(20), opts.status);
    }
    if (opts.search) {
      where.push('(v.VehicleCode LIKE @search OR v.VehicleName LIKE @search)');
      req.input('search', sql.NVarChar(100), `%${opts.search}%`);
    }
    const r = await req.query(`
      SELECT v.VehicleId AS vehicleId, v.TransportTypeId AS transportTypeId, t.Name AS transportTypeName,
             v.VehicleCode AS vehicleCode, v.VehicleName AS vehicleName, v.Capacity AS capacity, v.Status AS status,
             (SELECT COUNT(*) FROM Trips tr WHERE tr.VehicleId = v.VehicleId) AS tripCount
      FROM Vehicles v
      JOIN TransportTypes t ON v.TransportTypeId = t.TransportTypeId
      WHERE ${where.join(' AND ')}
      ORDER BY v.VehicleId`);
    return r.recordset;
  },

  async getVehicle(id: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, id).query(`
      SELECT v.VehicleId AS vehicleId, v.TransportTypeId AS transportTypeId, t.Name AS transportTypeName,
             v.VehicleCode AS vehicleCode, v.VehicleName AS vehicleName, v.Capacity AS capacity, v.Status AS status
      FROM Vehicles v JOIN TransportTypes t ON v.TransportTypeId = t.TransportTypeId
      WHERE v.VehicleId = @id`);
    return r.recordset[0] ?? null;
  },

  createVehicle: (data: Record<string, any>) => insertRow('Vehicles', 'VehicleId', VEHICLE_COLUMNS, data),
  updateVehicle: (id: number, data: Record<string, any>) => updateRow('Vehicles', 'VehicleId', id, VEHICLE_COLUMNS, data),
  deleteVehicle: (id: number) => deleteRow('Vehicles', 'VehicleId', id),
};
