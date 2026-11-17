/* =====================================================================
   99_cleanup_test_data.sql - Don du lieu thu do api-test.js tao ra
   - Tram ma 'BUS-TEST%', tuyen ma 'BUSTEST%' va moi thu gan voi chung
     (chuyen, gio chay, tram cua tuyen, luat gia, tram gan diem tham quan)
   - KHONG dong toi du lieu that: chi xoa theo tien to ma thu nghiem
   - Dua lich su quan tam (AttractionViews) cua 2 tai khoan demo an@ / binh@ ve du lieu mau
     (cac lan test / dien tap goi tro ly AI, tim duong se lam hong goi y "Danh cho ban")
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

-- Lich su quan tam cua 2 tai khoan demo -> ve du lieu mau (giong 02_seed.sql / 11_ai_features.sql)
IF OBJECT_ID('AttractionViews', 'U') IS NOT NULL
BEGIN
    DELETE v FROM AttractionViews v JOIN Users u ON u.UserId = v.UserId
    WHERE u.Email IN ('an@example.com', 'binh@example.com');

    INSERT INTO AttractionViews (UserId, AttractionId, Source, ViewedAt)
    SELECT u.UserId, a.AttractionId, v.Source, DATEADD(DAY, -v.DaysAgo, SYSDATETIME())
    FROM (VALUES
        ('an@example.com',   N'Văn Miếu - Quốc Tử Giám',  'VIEW',   2),
        ('an@example.com',   N'Hoàng thành Thăng Long',    'ROUTE',  5),
        ('an@example.com',   N'Bảo tàng Lịch sử Quốc gia', 'VIEW',  10),
        ('an@example.com',   N'Nhà tù Hỏa Lò',             'VIEW',  12),
        ('binh@example.com', N'Hồ Tây',                    'VIEW',   1),
        ('binh@example.com', N'Phố Tạ Hiện',               'ROUTE',  3),
        ('binh@example.com', N'Cầu Long Biên',             'VIEW',   6),
        ('binh@example.com', N'Chợ Đồng Xuân',             'VIEW',   8)
    ) v(Email, Name, Source, DaysAgo)
    JOIN Users u ON u.Email = v.Email
    JOIN TouristAttractions a ON a.Name = v.Name;

    SELECT COUNT(*) AS demoInterestRows FROM AttractionViews v JOIN Users u ON u.UserId = v.UserId
    WHERE u.Email IN ('an@example.com', 'binh@example.com');
END
GO
