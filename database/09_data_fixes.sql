/* =====================================================================
   09_data_fixes.sql - Sua du lieu / hieu nang (chay tren database DA CO du lieu, an toan khi chay lai)
   1. Them index cho cac cot khoa ngoai chua co index
   2. Doi xe theo tuyen: truoc day 7 xe buyt xoay vong cho 20 tuyen -> 1 xe chay nhieu chuyen
      CUNG LUC. Nay moi tuyen co doi xe rieng, khong xe nao trung gio.
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
USE PublicTransportDBV2;
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Vehicles_TransportType') CREATE INDEX IX_Vehicles_TransportType       ON Vehicles(TransportTypeId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Trips_Vehicle') CREATE INDEX IX_Trips_Vehicle                ON Trips(VehicleId, DepartureTime);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TicketTypes_TransportType') CREATE INDEX IX_TicketTypes_TransportType    ON TicketTypes(TransportTypeId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderDetails_TicketType') CREATE INDEX IX_OrderDetails_TicketType      ON OrderDetails(TicketTypeId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Tickets_TicketType') CREATE INDEX IX_Tickets_TicketType           ON Tickets(TicketTypeId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Routes_StartStation') CREATE INDEX IX_Routes_StartStation          ON Routes(StartStationId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Routes_EndStation') CREATE INDEX IX_Routes_EndStation            ON Routes(EndStationId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FareRules_From') CREATE INDEX IX_FareRules_From               ON FareRules(FromStationId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FareRules_To') CREATE INDEX IX_FareRules_To                 ON FareRules(ToStationId);
GO
/* ---------------------------------------------------------------------
   Doi xe theo tuyen: moi chuyen co 1 xe rieng, KHONG xe nao chay 2 chuyen cung luc.
     So xe can cho 1 tuyen = CEILING((thoi gian 1 chuyen + 10 phut quay dau) / gian cach)
     Chuyen thu n cua tuyen -> xe so (n mod so_xe) + 1
   Chi gan lai cac chuyen mau (ma <RouteCode>-Txxx); chuyen admin tu tao giu nguyen.
   --------------------------------------------------------------------- */
DECLARE @Fleet TABLE (RouteId INT PRIMARY KEY, RouteCode VARCHAR(50), TransportTypeId INT, Need INT);
;WITH seedTrips AS (
    SELECT t.TripId, t.RouteId, r.RouteCode, r.TransportTypeId,
           DATEDIFF(MINUTE, t.DepartureTime, t.ArrivalTime) AS Dur,
           DATEDIFF(MINUTE, LAG(t.DepartureTime) OVER (PARTITION BY t.RouteId ORDER BY t.DepartureTime), t.DepartureTime) AS Gap
    FROM Trips t JOIN Routes r ON r.RouteId = t.RouteId
    WHERE t.TripCode LIKE r.RouteCode + '-T[0-9][0-9][0-9]'
)
INSERT INTO @Fleet (RouteId, RouteCode, TransportTypeId, Need)
SELECT RouteId, RouteCode, TransportTypeId,
       CASE WHEN MIN(Gap) IS NULL OR MIN(Gap) <= 0 THEN COUNT(*)
            ELSE CEILING((MAX(Dur) + 10.0) / MIN(Gap)) END
FROM seedTrips GROUP BY RouteId, RouteCode, TransportTypeId;

;WITH Nums AS (SELECT TOP (100) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS k FROM sys.all_objects)
INSERT INTO Vehicles (TransportTypeId, VehicleCode, VehicleName, Capacity, Status)
SELECT f.TransportTypeId,
       CONCAT(CASE f.TransportTypeId WHEN 2 THEN 'TAU-' ELSE 'BUS-' END, f.RouteCode, '-', RIGHT('0' + CAST(n.k AS VARCHAR(3)), 2)),
       CASE f.TransportTypeId
            WHEN 2 THEN CONCAT(N'Tàu ', REPLACE(f.RouteCode, 'METRO', N'Metro '), N' - đoàn ', RIGHT('0' + CAST(n.k AS VARCHAR(3)), 2))
            ELSE CONCAT(N'Xe buýt tuyến ', f.RouteCode, N' - xe ', RIGHT('0' + CAST(n.k AS VARCHAR(3)), 2)) END,
       CASE f.TransportTypeId WHEN 2 THEN 900 ELSE 60 END,
       'ACTIVE'
FROM @Fleet f JOIN Nums n ON n.k <= f.Need
WHERE NOT EXISTS (
    SELECT 1 FROM Vehicles v
    WHERE v.VehicleCode = CONCAT(CASE f.TransportTypeId WHEN 2 THEN 'TAU-' ELSE 'BUS-' END, f.RouteCode, '-', RIGHT('0' + CAST(n.k AS VARCHAR(3)), 2)));

;WITH ordered AS (
    SELECT t.TripId, f.RouteCode, f.TransportTypeId, f.Need,
           ROW_NUMBER() OVER (PARTITION BY t.RouteId ORDER BY t.DepartureTime, t.TripId) - 1 AS n
    FROM Trips t JOIN @Fleet f ON f.RouteId = t.RouteId
    WHERE t.TripCode LIKE f.RouteCode + '-T[0-9][0-9][0-9]'
)
UPDATE t SET VehicleId = v.VehicleId
FROM Trips t
JOIN ordered o ON o.TripId = t.TripId
JOIN Vehicles v ON v.VehicleCode = CONCAT(CASE o.TransportTypeId WHEN 2 THEN 'TAU-' ELSE 'BUS-' END, o.RouteCode, '-',
                                          RIGHT('0' + CAST(o.n % o.Need + 1 AS VARCHAR(3)), 2));
GO
-- Kiem tra: so cap chuyen trung gio cung 1 xe (phai = 0)
SELECT COUNT(*) AS VehicleConflicts
FROM Trips a JOIN Trips b ON a.VehicleId = b.VehicleId AND a.TripId < b.TripId
WHERE a.Status <> 'CANCELLED' AND b.Status <> 'CANCELLED'
  AND a.DepartureTime < b.ArrivalTime AND b.DepartureTime < a.ArrivalTime;
SELECT t.Name AS Loai, COUNT(*) AS SoXe FROM Vehicles v JOIN TransportTypes t ON t.TransportTypeId = v.TransportTypeId GROUP BY t.Name;
GO
