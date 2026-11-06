/**
 * Repository: doc TOAN BO du lieu can thiet de xay graph routing (truy van so 11).
 * Chi goi khi khoi tao / khi Admin thay doi du lieu (service co cache).
 */
import { getPool } from '../config/database';
import { TransitNetworkData } from '../algorithms/routing';
import { toTransportMode, DepartureIndex } from '../types/transport.types';

export const transitNetworkRepository = {
  async load(): Promise<TransitNetworkData> {
    const pool = await getPool();
    const r = await pool.request().query(`
      -- 1. Stations
      SELECT s.StationId AS stationId, s.StationCode AS stationCode, s.StationName AS stationName,
             CAST(s.Latitude AS FLOAT) AS latitude, CAST(s.Longitude AS FLOAT) AS longitude,
             s.Address AS address, s.TransportTypeId AS transportTypeId, t.Name AS transportTypeName, s.Status AS status
      FROM Stations s JOIN TransportTypes t ON s.TransportTypeId = t.TransportTypeId
      WHERE s.Status = 'ACTIVE' AND t.Status = 'ACTIVE';

      -- 2. Routes
      SELECT r.RouteId AS routeId, r.RouteCode AS routeCode, r.RouteName AS routeName,
             r.TransportTypeId AS transportTypeId, t.Name AS transportTypeName, r.Status AS status
      FROM Routes r JOIN TransportTypes t ON r.TransportTypeId = t.TransportTypeId
      WHERE r.Status = 'ACTIVE' AND t.Status = 'ACTIVE';

      -- 3. RouteStations
      SELECT RouteId AS routeId, StationId AS stationId, StopOrder AS stopOrder,
             CAST(DistanceFromStart AS FLOAT) AS distanceFromStart
      FROM RouteStations;

      -- 4. FareRules
      SELECT TransportTypeId AS transportTypeId, FromStationId AS fromStationId,
             ToStationId AS toStationId, CAST(Price AS FLOAT) AS price
      FROM FareRules;

      -- 5. AttractionStations
      SELECT AttractionId AS attractionId, StationId AS stationId,
             CAST(WalkingDistance AS FLOAT) AS walkingDistance, WalkingDuration AS walkingDuration
      FROM AttractionStations;

      -- 6. Gio xe chay tai tung tram (de hien thi "chuyen tiep theo")
      SELECT t.RouteId AS routeId, st.StationId AS stationId,
             CONVERT(VARCHAR(5), st.DepartureTime, 108) AS departureTime
      FROM StopTimes st JOIN Trips t ON st.TripId = t.TripId
      WHERE t.Status IN ('SCHEDULED', 'RUNNING')
      ORDER BY t.RouteId, st.StationId, st.DepartureTime;`);

    const [stations, routes, routeStops, fareRules, attractionAccess, stopTimes] = r.recordsets as any[];

    const departures: DepartureIndex = {};
    for (const row of stopTimes as { routeId: number; stationId: number; departureTime: string }[]) {
      const key = `${row.routeId}:${row.stationId}`;
      (departures[key] ||= []).push(row.departureTime);
    }

    return {
      stations,
      routes: routes.map((x: any) => ({ ...x, mode: toTransportMode(x.transportTypeName) })),
      routeStops,
      fareRules,
      attractionAccess,
      departures,
    };
  },
};
