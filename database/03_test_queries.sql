/* =====================================================================
   03_test_queries.sql - Cac truy van kiem thu (SELECT / JOIN / Nearby / Statistics)
   Backend dung lai logic cua cac truy van nay trong thu muc
   backend/src/repositories/*.repository.ts
   ===================================================================== */
USE PublicTransportDBV2;
GO

-- 1. Toan bo phuong tien
SELECT v.VehicleId, v.VehicleCode, v.VehicleName, t.Name AS TransportType, v.Capacity, v.Status
FROM Vehicles v
JOIN TransportTypes t ON v.TransportTypeId = t.TransportTypeId;

-- 2. Toan bo tram dang hoat dong
SELECT s.StationId, s.StationCode, s.StationName, s.Latitude, s.Longitude, s.Address, t.Name AS TransportType
FROM Stations s
JOIN TransportTypes t ON s.TransportTypeId = t.TransportTypeId
WHERE s.Status = 'ACTIVE'
ORDER BY s.StationName;

-- 3. Tram gan 1 toa do (Haversine) -> GET /api/v1/stations/nearby
DECLARE @Latitude DECIMAL(9,6) = 21.028500;
DECLARE @Longitude DECIMAL(9,6) = 105.854200;
SELECT TOP 5 s.StationId, s.StationName, s.Latitude, s.Longitude,
       6371 * 2 * ASIN(SQRT(
           POWER(SIN(RADIANS(s.Latitude - @Latitude) / 2), 2)
         + COS(RADIANS(@Latitude)) * COS(RADIANS(s.Latitude))
         * POWER(SIN(RADIANS(s.Longitude - @Longitude) / 2), 2)
       )) AS DistanceKm
FROM Stations s
WHERE s.Status = 'ACTIVE'
ORDER BY DistanceKm;
GO

-- 4. Diem du lich gan nguoi dung -> GET /api/v1/attractions/nearby
DECLARE @Latitude DECIMAL(9,6) = 21.028500;
DECLARE @Longitude DECIMAL(9,6) = 105.854200;
SELECT TOP 10 a.AttractionId, a.Name, a.Address, a.Latitude, a.Longitude,
       6371 * 2 * ASIN(SQRT(
           POWER(SIN(RADIANS(a.Latitude - @Latitude) / 2), 2)
         + COS(RADIANS(@Latitude)) * COS(RADIANS(a.Latitude))
         * POWER(SIN(RADIANS(a.Longitude - @Longitude) / 2), 2)
       )) AS DistanceKm
FROM TouristAttractions a
WHERE a.Status = 'ACTIVE'
ORDER BY DistanceKm;
GO

-- 5. Tram gan diem du lich -> GET /api/v1/attractions/:id/nearby-stations
SELECT a.Name AS Attraction, s.StationName, s.Latitude, s.Longitude, ats.WalkingDistance, ats.WalkingDuration
FROM AttractionStations ats
JOIN TouristAttractions a ON ats.AttractionId = a.AttractionId
JOIN Stations s ON ats.StationId = s.StationId
WHERE a.AttractionId = 1
ORDER BY ats.WalkingDistance;

-- 6. Cac tuyen
SELECT r.RouteId, r.RouteCode, r.RouteName, t.Name AS TransportType, r.Description
FROM Routes r
JOIN TransportTypes t ON r.TransportTypeId = t.TransportTypeId
WHERE r.Status = 'ACTIVE'
ORDER BY r.RouteCode;

-- 7. Cac tram cua 1 tuyen -> GET /api/v1/routes/:id/stations
SELECT r.RouteCode, r.RouteName, rs.StopOrder, s.StationCode, s.StationName, rs.DistanceFromStart
FROM RouteStations rs
JOIN Routes r ON rs.RouteId = r.RouteId
JOIN Stations s ON rs.StationId = s.StationId
WHERE r.RouteCode = 'BUS01'
ORDER BY rs.StopOrder;

-- 8. Lich trinh cac chuyen cua 1 tuyen -> GET /api/v1/routes/:id/trips
SELECT r.RouteCode, r.RouteName, tr.TripCode, v.VehicleCode, tr.DepartureTime, tr.ArrivalTime, tr.Status
FROM Trips tr
JOIN Routes r ON tr.RouteId = r.RouteId
JOIN Vehicles v ON tr.VehicleId = v.VehicleId
WHERE r.RouteCode = 'BUS01'
ORDER BY tr.DepartureTime;

-- 9. Gio xe toi tram tiep theo (dung cho nextDepartures trong routing)
SELECT TOP 3 r.RouteCode, s.StationName, st.DepartureTime
FROM StopTimes st
JOIN Trips t ON st.TripId = t.TripId
JOIN Routes r ON t.RouteId = r.RouteId
JOIN Stations s ON st.StationId = s.StationId
WHERE r.RouteCode = 'BUS01' AND st.StationId = 1
  AND st.DepartureTime >= CAST(SYSDATETIME() AS TIME)
ORDER BY st.DepartureTime;

-- 10. Tuyen di thang giua 2 tram
SELECT DISTINCT r.RouteId, r.RouteCode, r.RouteName
FROM Routes r
JOIN RouteStations rs1 ON r.RouteId = rs1.RouteId
JOIN RouteStations rs2 ON r.RouteId = rs2.RouteId
WHERE rs1.StationId = 1 AND rs2.StationId = 4 AND rs1.StopOrder < rs2.StopOrder;

-- 11. Du lieu xay graph cho routing (backend: transitNetwork.repository.ts)
SELECT r.RouteId, r.RouteCode, r.RouteName, t.Name AS TransportType,
       rs.StopOrder, s.StationId, s.StationName, s.Latitude, s.Longitude, rs.DistanceFromStart
FROM RouteStations rs
JOIN Routes r ON rs.RouteId = r.RouteId
JOIN Stations s ON rs.StationId = s.StationId
JOIN TransportTypes t ON r.TransportTypeId = t.TransportTypeId
WHERE r.Status = 'ACTIVE' AND s.Status = 'ACTIVE'
ORDER BY r.RouteId, rs.StopOrder;

-- 12. Ve cua 1 nguoi dung -> GET /api/v1/tickets/me
SELECT tk.TicketId, tk.TicketCode, tt.Name AS TicketType, tt.Type, tk.ValidFrom, tk.ValidTo, tk.Status
FROM Tickets tk
JOIN Orders o ON tk.OrderId = o.OrderId
JOIN TicketTypes tt ON tk.TicketTypeId = tt.TicketTypeId
WHERE o.UserId = 1
ORDER BY tk.ValidFrom DESC;

-- 13. THONG KE: doanh thu theo ngay (30 ngay) -> GET /api/v1/admin/statistics
SELECT CAST(p.PaidAt AS DATE) AS [Date], SUM(p.Amount) AS Revenue, COUNT(*) AS Payments
FROM Payments p
WHERE p.Status = 'SUCCESS' AND p.PaidAt >= DATEADD(DAY, -30, SYSDATETIME())
GROUP BY CAST(p.PaidAt AS DATE)
ORDER BY [Date];

-- 14. THONG KE: so ve ban theo loai ve
SELECT tt.Name, tt.Type, COUNT(tk.TicketId) AS TicketsSold, SUM(tt.Price) AS Revenue
FROM TicketTypes tt
LEFT JOIN Tickets tk ON tk.TicketTypeId = tt.TicketTypeId
GROUP BY tt.TicketTypeId, tt.Name, tt.Type
ORDER BY TicketsSold DESC;

-- 15. THONG KE: so tram / tuyen theo loai phuong tien
SELECT t.Name,
       (SELECT COUNT(*) FROM Stations s WHERE s.TransportTypeId = t.TransportTypeId) AS Stations,
       (SELECT COUNT(*) FROM Routes r WHERE r.TransportTypeId = t.TransportTypeId) AS Routes,
       (SELECT COUNT(*) FROM Vehicles v WHERE v.TransportTypeId = t.TransportTypeId) AS Vehicles
FROM TransportTypes t;

-- 16. THONG KE: diem den duoc tim nhieu nhat
SELECT TOP 5 Destination, COUNT(*) AS Trips
FROM TripHistories
GROUP BY Destination
ORDER BY Trips DESC;
GO
