/* =====================================================================
   99_cleanup_test_data.sql - Don du lieu thu do api-test.js tao ra
   - Tram ma 'BUS-TEST%', tuyen ma 'BUSTEST%' va moi thu gan voi chung
     (chuyen, gio chay, tram cua tuyen, luat gia, tram gan diem tham quan)
   - KHONG dong toi du lieu that: chi xoa theo tien to ma thu nghiem
   api-test.bat tu chay file nay sau khi test (khi dung SQL Server trong Docker).
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
GO
USE PublicTransportDBV2;
GO
BEGIN TRANSACTION;

DECLARE @r TABLE (RouteId INT PRIMARY KEY);
INSERT @r SELECT RouteId FROM Routes WHERE RouteCode LIKE 'BUSTEST%';

DECLARE @s TABLE (StationId INT PRIMARY KEY);
INSERT @s SELECT StationId FROM Stations WHERE StationCode LIKE 'BUS-TEST%';

DECLARE @t TABLE (TripId INT PRIMARY KEY);
INSERT @t SELECT TripId FROM Trips WHERE TripCode LIKE 'BUSTEST%' OR RouteId IN (SELECT RouteId FROM @r);

DELETE FROM StopTimes WHERE TripId IN (SELECT TripId FROM @t) OR StationId IN (SELECT StationId FROM @s);
DELETE FROM Trips WHERE TripId IN (SELECT TripId FROM @t);
DELETE FROM RouteStations WHERE RouteId IN (SELECT RouteId FROM @r) OR StationId IN (SELECT StationId FROM @s);
DELETE FROM FareRules WHERE FromStationId IN (SELECT StationId FROM @s) OR ToStationId IN (SELECT StationId FROM @s);
DELETE FROM AttractionStations WHERE StationId IN (SELECT StationId FROM @s);
DELETE FROM Routes WHERE RouteId IN (SELECT RouteId FROM @r);
-- Tram thu con duoc tuyen THAT dung lam diem dau/cuoi -> giu lai (khong xay ra voi api-test)
DELETE FROM Stations
WHERE StationId IN (SELECT StationId FROM @s)
  AND NOT EXISTS (SELECT 1 FROM Routes x WHERE x.StartStationId = Stations.StationId OR x.EndStationId = Stations.StationId);

COMMIT;

SELECT (SELECT COUNT(*) FROM @r) AS testRoutesRemoved,
       (SELECT COUNT(*) FROM @s) AS testStationsRemoved,
       (SELECT COUNT(*) FROM @t) AS testTripsRemoved;
GO
