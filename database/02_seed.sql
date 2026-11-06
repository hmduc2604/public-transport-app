/* =====================================================================
   PUBLIC TRANSPORT MULTI-MODAL - SEED DATA
   File   : 02_seed.sql   (chay SAU 01_database.sql)
   Khu vuc: Trung tam Ha Noi (Hoan Kiem, Ba Dinh, Dong Da, Tay Ho, Long Bien)

   Tai khoan demo (mat khau tat ca: 123456)
     - an@example.com     (USER)
     - binh@example.com   (USER)
     - cuong@example.com  (USER)
     - admin@example.com  (ADMIN)

   Thay doi so voi ban seed cu cua nhom:
     - PasswordHash dang 'SEED:<mat khau>' -> backend tu bam bcrypt khi
       khoi dong lan dau (src/config/bootstrap.ts), sau do dang nhap duoc.
     - TicketTypes duoc insert TRUOC OrderDetails/Tickets (ban cu bi loi FK).
     - Trips dung dung loai xe (ban cu BUS01 dung xe METRO-01).
     - Them 7 tram + 6 tuyen (Ga Ha Noi, Hoa Lo, Tran Quoc...) de routing
       co nhieu phuong an hon. ID 1..20 cua tram cu GIU NGUYEN.
     - Trips sinh tu dong theo tan suat (headway) + StopTimes theo toc do.
     - Them du lieu chi tiet cho 20 diem tham quan.
   ===================================================================== */

USE PublicTransportDBV2;
GO

SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------------
   1. Users  (mat khau: 123456 - backend se bam bcrypt luc khoi dong)
   --------------------------------------------------------------------- */
INSERT INTO Users (FullName, Email, PasswordHash, Phone, Role, Status) VALUES
(N'Nguyễn Văn An',  'an@example.com',    'SEED:123456', '0901000001', 'USER',  'ACTIVE'),
(N'Trần Thị Bình',  'binh@example.com',  'SEED:123456', '0901000002', 'USER',  'ACTIVE'),
(N'Lê Minh Cường',  'cuong@example.com', 'SEED:123456', '0901000003', 'USER',  'ACTIVE'),
(N'Admin System',   'admin@example.com', 'SEED:123456', '0901000000', 'ADMIN', 'ACTIVE');
GO

/* ---------------------------------------------------------------------
   2. TransportTypes  (ID 1..4 duoc dung trong toan bo seed)
   --------------------------------------------------------------------- */
INSERT INTO TransportTypes (Name, Description) VALUES
(N'Bus',              N'Xe buýt'),
(N'Metro',            N'Tàu điện đô thị'),
(N'Bicycle',          N'Xe đạp công cộng'),
(N'Electric Vehicle', N'Xe điện công cộng');
GO

/* ---------------------------------------------------------------------
   3. Vehicles
   --------------------------------------------------------------------- */
INSERT INTO Vehicles (TransportTypeId, VehicleCode, VehicleName, Capacity) VALUES
(1, 'BUS-01',   N'Xe buýt mẫu 01', 60),
(1, 'BUS-02',   N'Xe buýt mẫu 02', 60),
(1, 'BUS-03',   N'Xe buýt mẫu 03', 60),
(1, 'BUS-04',   N'Xe buýt mẫu 04', 60),
(1, 'BUS-05',   N'Xe buýt mẫu 05', 60),
(2, 'METRO-01', N'Tàu Metro 01', 900),
(2, 'METRO-02', N'Tàu Metro 02', 900),
(3, 'BIKE-01',  N'Xe đạp công cộng 01', 1),
(3, 'BIKE-02',  N'Xe đạp công cộng 02', 1),
(3, 'BIKE-03',  N'Xe đạp công cộng 03', 1),
(4, 'EV-01',    N'Xe điện công cộng 01', 6),
(4, 'EV-02',    N'Xe điện công cộng 02', 6),
(4, 'EV-03',    N'Xe điện công cộng 03', 6),
(1, 'BUS-06',   N'Xe buýt mẫu 06', 60),
(1, 'BUS-07',   N'Xe buýt mẫu 07', 60),
(1, 'BUS-08',   N'Xe buýt mẫu 08', 60);
UPDATE Vehicles SET Status = 'MAINTENANCE' WHERE VehicleCode = 'BUS-05';
GO

/* ---------------------------------------------------------------------
   4. Stations  (1..20 giu nguyen nhu ban cu, 21..27 la tram moi)
   --------------------------------------------------------------------- */
INSERT INTO Stations (StationCode, StationName, Latitude, Longitude, Address, TransportTypeId) VALUES
-- BUS (1..8)
('BUS-ST01',  N'Bờ Hồ Hoàn Kiếm',            21.028511, 105.854444, N'Hoàn Kiếm, Hà Nội', 1),
('BUS-ST02',  N'Nhà hát Lớn',                21.024206, 105.857265, N'Hoàn Kiếm, Hà Nội', 1),
('BUS-ST03',  N'Chợ Đồng Xuân',              21.038100, 105.849700, N'Hoàn Kiếm, Hà Nội', 1),
('BUS-ST04',  N'Văn Miếu',                   21.027039, 105.835650, N'Đống Đa, Hà Nội',   1),
('BUS-ST05',  N'Lăng Chủ tịch Hồ Chí Minh',  21.036800, 105.834900, N'Ba Đình, Hà Nội',   1),
('BUS-ST06',  N'Hoàng thành Thăng Long',     21.035600, 105.841700, N'Ba Đình, Hà Nội',   1),
('BUS-ST07',  N'Hồ Tây',                     21.055300, 105.818900, N'Tây Hồ, Hà Nội',    1),
('BUS-ST08',  N'Cầu Long Biên',              21.043700, 105.850200, N'Long Biên, Hà Nội', 1),
-- METRO (9..12)
('METRO-ST01', N'Cát Linh',                  21.027600, 105.841200, N'Đống Đa, Hà Nội',   2),
('METRO-ST02', N'La Thành',                  21.021500, 105.814000, N'Đống Đa, Hà Nội',   2),
('METRO-ST03', N'Thái Hà',                   21.013700, 105.821600, N'Đống Đa, Hà Nội',   2),
('METRO-ST04', N'Láng',                      21.008600, 105.801900, N'Đống Đa, Hà Nội',   2),
-- BICYCLE (13..16)
('BIKE-ST01', N'Điểm xe đạp Hoàn Kiếm',      21.028900, 105.852000, N'Hoàn Kiếm, Hà Nội', 3),
('BIKE-ST02', N'Điểm xe đạp Nhà hát Lớn',    21.023900, 105.858000, N'Hoàn Kiếm, Hà Nội', 3),
('BIKE-ST03', N'Điểm xe đạp Văn Miếu',       21.027200, 105.834800, N'Đống Đa, Hà Nội',   3),
('BIKE-ST04', N'Điểm xe đạp Ba Đình',        21.034900, 105.837500, N'Ba Đình, Hà Nội',   3),
-- ELECTRIC VEHICLE (17..20)
('EV-ST01',   N'Điểm xe điện Hoàn Kiếm',     21.030000, 105.854500, N'Hoàn Kiếm, Hà Nội', 4),
('EV-ST02',   N'Điểm xe điện Phố cổ',        21.034500, 105.850500, N'Hoàn Kiếm, Hà Nội', 4),
('EV-ST03',   N'Điểm xe điện Ba Đình',       21.035800, 105.839000, N'Ba Đình, Hà Nội',   4),
('EV-ST04',   N'Điểm xe điện Hồ Tây',        21.053500, 105.817500, N'Tây Hồ, Hà Nội',    4),
-- TRAM MOI (21..27)
('BUS-ST09',  N'Ga Hà Nội',                  21.024400, 105.841100, N'Lê Duẩn, Đống Đa, Hà Nội',    1),
('BUS-ST10',  N'Nhà tù Hỏa Lò',              21.025500, 105.846300, N'Hỏa Lò, Hoàn Kiếm, Hà Nội',   1),
('BUS-ST11',  N'Bảo tàng Dân tộc học',       21.040500, 105.799000, N'Nguyễn Văn Huyên, Cầu Giấy',  1),
('BUS-ST12',  N'Chùa Trấn Quốc',             21.047800, 105.836700, N'Thanh Niên, Tây Hồ, Hà Nội',  1),
('BIKE-ST05', N'Điểm xe đạp Hồ Tây',         21.048500, 105.835500, N'Thanh Niên, Tây Hồ, Hà Nội',  3),
('BIKE-ST06', N'Điểm xe đạp Phố cổ',         21.034200, 105.851500, N'Tạ Hiện, Hoàn Kiếm, Hà Nội',  3),
('EV-ST05',   N'Điểm xe điện Nhà hát Lớn',   21.024600, 105.856600, N'Tràng Tiền, Hoàn Kiếm',       4);
GO

/* ---------------------------------------------------------------------
   5. Routes  (1..11 nhu ban cu, 12..17 moi)
   --------------------------------------------------------------------- */
INSERT INTO Routes (RouteCode, RouteName, TransportTypeId, Description) VALUES
('BUS01',   N'Hoàn Kiếm - Văn Miếu',                 1, N'Tuyến bus mô phỏng'),
('BUS02',   N'Hoàn Kiếm - Ba Đình',                  1, N'Tuyến bus mô phỏng'),
('BUS03',   N'Hoàn Kiếm - Hồ Tây',                   1, N'Tuyến bus mô phỏng'),
('BUS04',   N'Nhà hát Lớn - Chợ Đồng Xuân',          1, N'Tuyến bus mô phỏng'),
('BUS05',   N'Văn Miếu - Hoàng thành',               1, N'Tuyến bus mô phỏng'),
('BUS06',   N'Ba Đình - Hồ Tây',                     1, N'Tuyến bus mô phỏng'),
('BUS07',   N'Hoàn Kiếm - Cầu Long Biên',            1, N'Tuyến bus mô phỏng'),
('BUS08',   N'Cầu Long Biên - Hồ Tây',               1, N'Tuyến bus mô phỏng'),
('METRO2A', N'Cát Linh - Hà Đông',                   2, N'Tuyến Metro 2A (đoạn mô phỏng trong khu vực trung tâm)'),
('BIKE01',  N'Xe đạp khu vực Hoàn Kiếm',             3, N'Tuyến xe đạp mô phỏng'),
('EV01',    N'Xe điện khu vực Hoàn Kiếm - Ba Đình',  4, N'Tuyến xe điện mô phỏng'),
('BUS09',   N'Ga Hà Nội - Nhà hát Lớn',              1, N'Tuyến bus mô phỏng qua Hỏa Lò, Bờ Hồ'),
('BUS10',   N'Cầu Giấy - Hồ Tây - Ba Đình',          1, N'Tuyến bus mô phỏng qua Chùa Trấn Quốc'),
('BUS11',   N'Ga Hà Nội - Lăng Bác',                 1, N'Tuyến bus mô phỏng qua Văn Miếu, Hoàng thành'),
('BIKE02',  N'Xe đạp Hồ Tây - Văn Miếu',             3, N'Tuyến xe đạp mô phỏng'),
('BIKE03',  N'Xe đạp Phố cổ - Nhà hát Lớn',          3, N'Tuyến xe đạp mô phỏng'),
('EV02',    N'Xe điện Nhà hát Lớn - Hồ Tây',         4, N'Tuyến xe điện mô phỏng ven sông');
GO

/* ---------------------------------------------------------------------
   6. RouteStations  (DistanceFromStart: met)
   --------------------------------------------------------------------- */
INSERT INTO RouteStations (RouteId, StationId, StopOrder, DistanceFromStart) VALUES
-- BUS01
(1, 1, 1, 0), (1, 4, 2, 2200), (1, 9, 3, 3000),
-- BUS02
(2, 1, 1, 0), (2, 6, 2, 2500), (2, 5, 3, 3500),
-- BUS03
(3, 1, 1, 0), (3, 3, 2, 1800), (3, 7, 3, 4500),
-- BUS04
(4, 2, 1, 0), (4, 3, 2, 2500), (4, 8, 3, 4000),
-- BUS05
(5, 4, 1, 0), (5, 6, 2, 1800), (5, 5, 3, 3000),
-- BUS06
(6, 5, 1, 0), (6, 6, 2, 1000), (6, 7, 3, 3500),
-- BUS07
(7, 1, 1, 0), (7, 3, 2, 1800), (7, 8, 3, 3000),
-- BUS08
(8, 8, 1, 0), (8, 3, 2, 3000), (8, 7, 3, 6000),
-- METRO2A
(9, 9, 1, 0), (9, 10, 2, 1800), (9, 11, 3, 3200), (9, 12, 4, 5000),
-- BIKE01
(10, 13, 1, 0), (10, 14, 2, 1500), (10, 15, 3, 3500),
-- EV01
(11, 17, 1, 0), (11, 18, 2, 1200), (11, 19, 3, 2500),
-- BUS09: Ga Ha Noi -> Hoa Lo -> Bo Ho -> Nha hat Lon
(12, 21, 1, 0), (12, 22, 2, 720), (12, 1, 3, 1900), (12, 2, 4, 2630),
-- BUS10: Bao tang Dan toc hoc -> Ho Tay -> Tran Quoc -> Lang Bac
(13, 23, 1, 0), (13, 7, 2, 3430), (13, 24, 3, 6070), (13, 5, 4, 7680),
-- BUS11: Ga Ha Noi -> Van Mieu -> Hoang thanh -> Lang Bac
(14, 21, 1, 0), (14, 4, 2, 830), (14, 6, 3, 2310), (14, 5, 4, 3240),
-- BIKE02: Ho Tay -> Ba Dinh -> Van Mieu
(15, 25, 1, 0), (15, 16, 2, 1980), (15, 15, 3, 3160),
-- BIKE03: Pho co -> Hoan Kiem -> Nha hat Lon
(16, 26, 1, 0), (16, 13, 2, 770), (16, 14, 3, 1850),
-- EV02: Nha hat Lon -> Hoan Kiem -> Pho co -> Ho Tay
(17, 27, 1, 0), (17, 17, 2, 830), (17, 18, 3, 1680), (17, 20, 4, 6910);
GO

/* Cap nhat tram dau / tram cuoi cho moi tuyen */
UPDATE r
SET StartStationId = (SELECT TOP 1 StationId FROM RouteStations WHERE RouteId = r.RouteId ORDER BY StopOrder ASC),
    EndStationId   = (SELECT TOP 1 StationId FROM RouteStations WHERE RouteId = r.RouteId ORDER BY StopOrder DESC)
FROM Routes r;
GO

/* ---------------------------------------------------------------------
   7 + 8. Trips + StopTimes (sinh tu dong)
   - Chuyen dau 05:30, chuyen cuoi <= 22:00
   - Tan suat (headway): Bus 20', Metro 10', Xe dap 30', Xe dien 30'
   - Toc do (m/phut) dung chung voi backend (src/config/routing.config.ts):
       Bus 333 (~20km/h), Metro 583 (~35km/h), Xe dap 200 (~12km/h), Xe dien 300 (~18km/h)
   - Moi tram dung 1 phut
   --------------------------------------------------------------------- */
DECLARE @Mode TABLE (TransportTypeId INT PRIMARY KEY, Headway INT, SpeedMPerMin DECIMAL(10,2));
INSERT INTO @Mode VALUES (1, 20, 333), (2, 10, 583), (3, 30, 200), (4, 30, 300);

;WITH Nums AS (
    SELECT TOP (200) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects
)
INSERT INTO Trips (RouteId, VehicleId, TripCode, DepartureTime, ArrivalTime, Status)
SELECT
    r.RouteId,
    v.VehicleId,
    CONCAT(r.RouteCode, '-T', RIGHT('000' + CAST(n.n + 1 AS VARCHAR(4)), 3)),
    DATEADD(MINUTE, n.n * m.Headway, CAST('05:30' AS TIME)),
    DATEADD(MINUTE, n.n * m.Headway
                    + CAST(CEILING(d.MaxDistance / m.SpeedMPerMin) AS INT)
                    + (d.StopCount - 1),
            CAST('05:30' AS TIME)),
    'SCHEDULED'
FROM Routes r
JOIN @Mode m ON m.TransportTypeId = r.TransportTypeId
CROSS APPLY (
    SELECT MAX(ISNULL(DistanceFromStart, 0)) AS MaxDistance, COUNT(*) AS StopCount
    FROM RouteStations WHERE RouteId = r.RouteId
) d
CROSS APPLY (
    SELECT COUNT(*) AS Cnt FROM Vehicles
    WHERE TransportTypeId = r.TransportTypeId AND Status = 'ACTIVE'
) vc
CROSS JOIN Nums n
CROSS APPLY (
    -- Xoay vong xe cung loai cho cac chuyen (xe thu k = (n + RouteId) mod so xe)
    SELECT x.VehicleId FROM (
        SELECT VehicleId, ROW_NUMBER() OVER (ORDER BY VehicleId) - 1 AS rn
        FROM Vehicles
        WHERE TransportTypeId = r.TransportTypeId AND Status = 'ACTIVE'
    ) x
    WHERE x.rn = (n.n + r.RouteId) % vc.Cnt
) v
WHERE n.n * m.Headway <= 990;   -- 05:30 + 990 phut = 22:00

INSERT INTO StopTimes (TripId, StationId, ArrivalTime, DepartureTime, StopOrder)
SELECT
    t.TripId,
    rs.StationId,
    DATEADD(MINUTE,
            CAST(CEILING(ISNULL(rs.DistanceFromStart, 0) / m.SpeedMPerMin) AS INT) + (rs.StopOrder - 1),
            t.DepartureTime),
    DATEADD(MINUTE,
            CAST(CEILING(ISNULL(rs.DistanceFromStart, 0) / m.SpeedMPerMin) AS INT) + (rs.StopOrder - 1)
            + CASE WHEN rs.StopOrder = 1 THEN 0 ELSE 1 END,
            t.DepartureTime),
    rs.StopOrder
FROM Trips t
JOIN Routes r         ON r.RouteId = t.RouteId
JOIN @Mode m          ON m.TransportTypeId = r.TransportTypeId
JOIN RouteStations rs ON rs.RouteId = t.RouteId;
GO

/* ---------------------------------------------------------------------
   9. TouristAttractions (20 diem) - noi dung mo ta tong quan.
   Gio mo cua / gia ve chi mang tinh tham khao, can kiem chung lai
   tu nguon chinh thuc truoc khi dua vao bao cao.
   --------------------------------------------------------------------- */
INSERT INTO TouristAttractions
(Name, Description, History, Highlights, Address, Latitude, Longitude, Category, OpeningHours, TicketPrice, PopularityScore)
VALUES
(N'Hồ Hoàn Kiếm',
 N'Hồ nước nằm giữa trung tâm Hà Nội, được xem là trái tim của thủ đô.',
 N'Gắn với truyền thuyết vua Lê Lợi trả gươm thần cho Rùa Vàng sau khi đánh thắng quân Minh ở thế kỷ XV, từ đó hồ mang tên Hoàn Kiếm (trả gươm).',
 N'Tháp Rùa giữa hồ|Cầu Thê Húc và Đền Ngọc Sơn|Không gian phố đi bộ vào cuối tuần',
 N'Hoàn Kiếm, Hà Nội', 21.028511, 105.854444, N'Danh thắng',
 N'Khu vực công cộng, tham quan cả ngày', N'Miễn phí (khu vực quanh hồ)', 98),

(N'Đền Ngọc Sơn',
 N'Ngôi đền trên đảo Ngọc ở phía bắc hồ Hoàn Kiếm, nối với bờ bằng cầu Thê Húc sơn đỏ.',
 N'Đền thờ Đức Thánh Trần Hưng Đạo và Văn Xương Đế Quân. Cụm kiến trúc được nhà nho Nguyễn Văn Siêu tu sửa vào giữa thế kỷ XIX, xây thêm Tháp Bút, Đài Nghiên.',
 N'Cầu Thê Húc|Tháp Bút - Đài Nghiên|Tiêu bản rùa hồ Gươm',
 N'Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội', 21.030035, 105.852640, N'Di tích',
 N'Mở cửa ban ngày (tham khảo, cần kiểm tra lại)', N'Có thu phí vào cửa - xem giá niêm yết tại điểm tham quan', 88),

(N'Phố cổ Hà Nội',
 N'Khu phố lịch sử với những con phố mang tên nghề truyền thống như Hàng Bạc, Hàng Đường, Hàng Mã.',
 N'Hình thành từ các phường nghề buôn bán ven thành Thăng Long, thường được gọi là "36 phố phường".',
 N'Nhà ống kiến trúc cổ|Ẩm thực đường phố|Chợ đêm cuối tuần',
 N'Hoàn Kiếm, Hà Nội', 21.034000, 105.850000, N'Khu phố',
 N'Khu vực công cộng, tham quan cả ngày', N'Miễn phí', 95),

(N'Chợ Đồng Xuân',
 N'Khu chợ lớn và lâu đời nhất trong khu phố cổ.',
 N'Chợ được người Pháp xây dựng vào cuối thế kỷ XIX (năm 1889); sau trận hỏa hoạn năm 1994 chợ được xây dựng lại, giữ mặt tiền kiến trúc cũ.',
 N'Kiến trúc mặt tiền thời Pháp|Hàng vải, đồ khô, đặc sản|Chợ đêm khu Hàng Đào - Đồng Xuân',
 N'Đồng Xuân, Hoàn Kiếm, Hà Nội', 21.038100, 105.849700, N'Chợ',
 N'Thường mở từ sáng đến chiều tối (tham khảo)', N'Miễn phí vào chợ', 80),

(N'Nhà hát Lớn Hà Nội',
 N'Công trình kiến trúc Pháp nổi bật, nơi tổ chức các chương trình nghệ thuật lớn.',
 N'Xây dựng trong giai đoạn 1901 - 1911, lấy cảm hứng từ Nhà hát Opera Garnier ở Paris.',
 N'Kiến trúc tân cổ điển|Quảng trường Cách mạng Tháng Tám|Các buổi biểu diễn nghệ thuật',
 N'Số 1 Tràng Tiền, Hoàn Kiếm, Hà Nội', 21.024206, 105.857265, N'Kiến trúc',
 N'Theo lịch biểu diễn và lịch tham quan của nhà hát', N'Theo từng chương trình', 85),

(N'Nhà tù Hỏa Lò',
 N'Di tích lịch sử ghi dấu thời kỳ đấu tranh của các chiến sĩ cách mạng Việt Nam.',
 N'Do thực dân Pháp xây dựng năm 1896 với tên Maison Centrale; sau này từng giam giữ phi công Mỹ trong chiến tranh.',
 N'Khu trưng bày lịch sử|Tour đêm "Đường vào cõi bất tử"|Phần kiến trúc cổng nhà tù',
 N'Số 1 Hỏa Lò, Hoàn Kiếm, Hà Nội', 21.025700, 105.846800, N'Di tích',
 N'Mở cửa ban ngày (tham khảo, cần kiểm tra lại)', N'Có thu phí vào cửa - xem giá niêm yết tại điểm tham quan', 84),

(N'Hoàng thành Thăng Long',
 N'Quần thể di tích kinh thành qua nhiều triều đại phong kiến Việt Nam.',
 N'Được UNESCO công nhận là Di sản Văn hóa Thế giới năm 2010.',
 N'Đoan Môn|Điện Kính Thiên|Khu khảo cổ 18 Hoàng Diệu|Cột cờ Hà Nội',
 N'19C Hoàng Diệu, Ba Đình, Hà Nội', 21.035600, 105.841700, N'Di sản',
 N'Mở cửa ban ngày (tham khảo, cần kiểm tra lại)', N'Có thu phí vào cửa - xem giá niêm yết tại điểm tham quan', 86),

(N'Lăng Chủ tịch Hồ Chí Minh',
 N'Nơi lưu giữ thi hài Chủ tịch Hồ Chí Minh, nằm tại Quảng trường Ba Đình.',
 N'Công trình được khánh thành năm 1975.',
 N'Lễ thượng cờ, hạ cờ|Khu di tích Phủ Chủ tịch|Nhà sàn Bác Hồ',
 N'Số 2 Hùng Vương, Ba Đình, Hà Nội', 21.036800, 105.834900, N'Di tích',
 N'Mở cửa buổi sáng theo lịch, có đợt đóng cửa định kỳ - cần kiểm tra lịch chính thức', N'Miễn phí (yêu cầu trang phục lịch sự)', 92),

(N'Quảng trường Ba Đình',
 N'Quảng trường lớn và giàu ý nghĩa lịch sử bậc nhất Việt Nam.',
 N'Nơi Chủ tịch Hồ Chí Minh đọc Tuyên ngôn Độc lập ngày 2/9/1945.',
 N'Không gian quảng trường rộng|Lễ thượng cờ buổi sáng|Gần Lăng Bác và Chùa Một Cột',
 N'Ba Đình, Hà Nội', 21.036700, 105.835000, N'Quảng trường',
 N'Khu vực công cộng', N'Miễn phí', 82),

(N'Chùa Một Cột',
 N'Ngôi chùa có kiến trúc độc đáo dựng trên một cột đá giữa hồ.',
 N'Được xây dựng năm 1049 dưới thời vua Lý Thái Tông. Chùa bị phá năm 1954 và được dựng lại năm 1955.',
 N'Kiến trúc hình hoa sen|Hồ Linh Chiểu|Chùa Diên Hựu bên cạnh',
 N'Chùa Một Cột, Ba Đình, Hà Nội', 21.035800, 105.833800, N'Tôn giáo',
 N'Mở cửa ban ngày', N'Miễn phí', 85),

(N'Văn Miếu - Quốc Tử Giám',
 N'Quần thể di tích thờ Khổng Tử và là trường đại học đầu tiên của Việt Nam.',
 N'Văn Miếu được xây dựng năm 1070 thời vua Lý Thánh Tông; năm 1076 Quốc Tử Giám được lập. 82 bia Tiến sĩ được UNESCO ghi danh là Di sản tư liệu thế giới.',
 N'Khuê Văn Các|82 bia Tiến sĩ|Giếng Thiên Quang|Khu Thái Học',
 N'58 Quốc Tử Giám, Đống Đa, Hà Nội', 21.027039, 105.835650, N'Di tích',
 N'Mở cửa ban ngày (tham khảo, cần kiểm tra lại)', N'Có thu phí vào cửa - xem giá niêm yết tại điểm tham quan', 94),

(N'Bảo tàng Mỹ thuật Việt Nam',
 N'Bảo tàng lưu giữ các tác phẩm mỹ thuật tiêu biểu của Việt Nam qua nhiều thời kỳ.',
 N'Bảo tàng mở cửa năm 1966 trong một tòa nhà kiến trúc Pháp.',
 N'Tranh sơn mài, lụa, sơn dầu|Điêu khắc cổ|Mỹ thuật dân gian',
 N'66 Nguyễn Thái Học, Ba Đình, Hà Nội', 21.029500, 105.833500, N'Bảo tàng',
 N'Mở cửa ban ngày (tham khảo, cần kiểm tra lại)', N'Có thu phí vào cửa - xem giá niêm yết tại điểm tham quan', 72),

(N'Bảo tàng Lịch sử Quốc gia',
 N'Bảo tàng trưng bày tiến trình lịch sử Việt Nam từ thời tiền sử đến hiện đại.',
 N'Thành lập năm 2011 trên cơ sở hợp nhất Bảo tàng Lịch sử Việt Nam và Bảo tàng Cách mạng Việt Nam.',
 N'Hiện vật thời Đông Sơn|Kiến trúc Đông Dương|Trưng bày cổ vật',
 N'1 Tràng Tiền, Hoàn Kiếm, Hà Nội', 21.025300, 105.858000, N'Bảo tàng',
 N'Mở cửa ban ngày (tham khảo, cần kiểm tra lại)', N'Có thu phí vào cửa - xem giá niêm yết tại điểm tham quan', 75),

(N'Bảo tàng Dân tộc học Việt Nam',
 N'Bảo tàng giới thiệu văn hóa của 54 dân tộc Việt Nam.',
 N'Bảo tàng mở cửa đón khách năm 1997.',
 N'Vườn kiến trúc nhà truyền thống ngoài trời|Trang phục, nhạc cụ các dân tộc|Múa rối nước',
 N'Nguyễn Văn Huyên, Cầu Giấy, Hà Nội', 21.040700, 105.798300, N'Bảo tàng',
 N'Mở cửa ban ngày, có ngày nghỉ trong tuần - cần kiểm tra lại', N'Có thu phí vào cửa - xem giá niêm yết tại điểm tham quan', 80),

(N'Hồ Tây',
 N'Hồ nước tự nhiên lớn nhất nội thành Hà Nội.',
 N'Hồ gắn với nhiều truyền thuyết và là không gian văn hóa, tâm linh của Thăng Long xưa.',
 N'Ngắm hoàng hôn|Đường đạp xe quanh hồ|Phủ Tây Hồ, Chùa Trấn Quốc',
 N'Tây Hồ, Hà Nội', 21.055300, 105.818900, N'Danh thắng',
 N'Khu vực công cộng, tham quan cả ngày', N'Miễn phí', 90),

(N'Chùa Trấn Quốc',
 N'Ngôi chùa cổ nằm trên bán đảo nhỏ phía đông Hồ Tây.',
 N'Được coi là ngôi chùa cổ nhất Hà Nội, khởi dựng từ thế kỷ VI thời Lý Nam Đế bên bờ sông Hồng, sau được dời về vị trí hiện nay.',
 N'Bảo tháp nhiều tầng|Cây bồ đề|Khung cảnh Hồ Tây',
 N'Thanh Niên, Tây Hồ, Hà Nội', 21.048000, 105.836000, N'Tôn giáo',
 N'Mở cửa ban ngày', N'Miễn phí', 87),

(N'Phố Tạ Hiện',
 N'Con phố nhỏ sôi động về đêm trong khu phố cổ.',
 N'Nổi tiếng với các quán bia vỉa hè và là điểm gặp gỡ của du khách trong và ngoài nước.',
 N'Không khí về đêm|Ẩm thực, bia hơi|Gần phố đi bộ',
 N'Tạ Hiện, Hoàn Kiếm, Hà Nội', 21.034900, 105.851000, N'Khu phố',
 N'Sôi động nhất vào buổi tối', N'Miễn phí', 78),

(N'Phố sách Hà Nội',
 N'Không gian văn hóa đọc giữa lòng thủ đô.',
 N'Phố sách 19/12 được khai trương năm 2017, tập trung nhiều đơn vị xuất bản và phát hành sách.',
 N'Gian hàng sách|Không gian giao lưu, ra mắt sách|Quán cà phê sách',
 N'Phố 19 Tháng 12, Hoàn Kiếm, Hà Nội', 21.027500, 105.849000, N'Văn hóa',
 N'Mở cửa ban ngày đến tối', N'Miễn phí', 65),

(N'Cầu Long Biên',
 N'Cây cầu thép lịch sử bắc qua sông Hồng.',
 N'Được người Pháp xây dựng trong giai đoạn 1898 - 1902, ban đầu mang tên cầu Paul Doumer; chứng kiến nhiều biến cố của lịch sử Hà Nội.',
 N'Kết cấu thép cổ|Ngắm sông Hồng|Bãi giữa sông Hồng',
 N'Long Biên, Hà Nội', 21.043700, 105.850200, N'Kiến trúc',
 N'Khu vực công cộng', N'Miễn phí', 83),

(N'Nhà hát Múa rối Thăng Long',
 N'Nhà hát biểu diễn múa rối nước - loại hình nghệ thuật truyền thống của Việt Nam.',
 N'Nhà hát được thành lập năm 1969 và là địa chỉ quen thuộc của du khách quốc tế.',
 N'Múa rối nước|Nhạc cụ dân tộc|Gần hồ Hoàn Kiếm',
 N'57B Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội', 21.031700, 105.852700, N'Nghệ thuật',
 N'Theo lịch suất diễn trong ngày', N'Theo suất diễn - xem giá tại quầy vé', 86);
GO

/* ---------------------------------------------------------------------
   10. AttractionStations
   --------------------------------------------------------------------- */
INSERT INTO AttractionStations (AttractionId, StationId, WalkingDistance, WalkingDuration) VALUES
(1, 1, 200, 3),  (1, 13, 250, 3), (1, 17, 200, 3),
(2, 1, 350, 5),  (2, 17, 150, 2),
(3, 1, 500, 7),  (3, 3, 400, 5),  (3, 18, 100, 2), (3, 26, 100, 2),
(4, 3, 200, 3),
(5, 2, 200, 3),  (5, 14, 100, 2), (5, 27, 100, 2),
(6, 1, 900, 12), (6, 4, 1200, 15), (6, 22, 100, 2),
(7, 6, 300, 4),  (7, 9, 900, 12), (7, 19, 300, 4),
(8, 5, 200, 3),  (8, 6, 700, 9),
(9, 5, 150, 2),
(10, 5, 500, 7),
(11, 4, 250, 3), (11, 9, 500, 6), (11, 15, 150, 2),
(12, 5, 400, 5), (12, 15, 250, 3),
(13, 2, 300, 4), (13, 27, 200, 3),
(14, 7, 1500, 20), (14, 23, 250, 3),
(15, 7, 300, 4), (15, 20, 200, 3),
(16, 7, 1200, 15), (16, 24, 100, 2), (16, 25, 150, 2),
(17, 3, 500, 7), (17, 26, 100, 2),
(18, 1, 600, 8), (18, 22, 350, 5),
(19, 8, 400, 5),
(20, 1, 350, 5), (20, 17, 200, 3);
GO

/* ---------------------------------------------------------------------
   11. TicketTypes  (PHAI insert truoc OrderDetails / Tickets)
   --------------------------------------------------------------------- */
INSERT INTO TicketTypes (Name, TransportTypeId, Type, Price, DurationMinutes, Description) VALUES
(N'Vé lượt Bus',        1, 'SINGLE',  10000, 120,   N'Vé mô phỏng cho một lượt sử dụng xe buýt'),
(N'Vé lượt Metro',      2, 'SINGLE',  15000, 120,   N'Vé mô phỏng cho một lượt Metro'),
(N'Vé tháng Bus',       1, 'MONTHLY', 200000, 43200, N'Vé tháng mô phỏng - đi không giới hạn 30 ngày'),
(N'Vé tháng Metro',     2, 'MONTHLY', 300000, 43200, N'Vé tháng mô phỏng - đi không giới hạn 30 ngày'),
(N'Vé lượt Xe đạp',     3, 'SINGLE',  5000,  60,    N'Thuê xe đạp công cộng tối đa 60 phút'),
(N'Vé lượt Xe điện',    4, 'SINGLE',  10000, 60,    N'Một lượt xe điện công cộng trong 60 phút');
GO

/* ---------------------------------------------------------------------
   12. FareRules
   --------------------------------------------------------------------- */
INSERT INTO FareRules (TransportTypeId, FromStationId, ToStationId, Price) VALUES
-- Bus
(1, 1, 4, 10000), (1, 1, 5, 10000), (1, 1, 7, 15000), (1, 2, 3, 10000),
(1, 23, 5, 15000), (1, 8, 7, 15000),
-- Metro
(2, 9, 10, 10000), (2, 9, 11, 12000), (2, 9, 12, 15000),
(2, 10, 11, 8000), (2, 10, 12, 10000), (2, 11, 12, 8000),
-- Bicycle
(3, 13, 14, 5000), (3, 14, 15, 5000),
-- Electric Vehicle
(4, 17, 18, 10000), (4, 18, 19, 10000), (4, 27, 20, 20000);
GO

/* ---------------------------------------------------------------------
   13..16. Orders, OrderDetails, Payments, Tickets
   --------------------------------------------------------------------- */
-- 3 don hang mau cua nhom (giu nguyen y nghia)
INSERT INTO Orders (UserId, TotalAmount, Status) VALUES
(1, 10000,  'PAID'),
(2, 300000, 'PAID'),
(3, 15000,  'PENDING');

INSERT INTO OrderDetails (OrderId, TicketTypeId, Quantity, UnitPrice) VALUES
(1, 1, 1, 10000),
(2, 4, 1, 300000),
(3, 2, 1, 15000);

INSERT INTO Payments (OrderId, Amount, PaymentMethod, Status, TransactionCode, PaidAt) VALUES
(1, 10000,  'MOCK', 'SUCCESS', 'MOCK-TXN-000001', SYSDATETIME()),
(2, 300000, 'MOCK', 'SUCCESS', 'MOCK-TXN-000002', SYSDATETIME()),
(3, 15000,  'MOCK', 'PENDING', NULL, NULL);

INSERT INTO Tickets (OrderId, TicketTypeId, TicketCode, QRCode, ValidFrom, ValidTo, Status) VALUES
(1, 1, 'TICKET-000001', NULL, SYSDATETIME(), DATEADD(HOUR, 2, SYSDATETIME()), 'ACTIVE'),
(2, 4, 'TICKET-000002', NULL, SYSDATETIME(), DATEADD(DAY, 30, SYSDATETIME()), 'ACTIVE');
GO

-- Sinh them ~24 don hang da thanh toan trong 14 ngay qua (phuc vu bieu do thong ke)
DECLARE @i INT = 1;
WHILE @i <= 24
BEGIN
    DECLARE @UserId INT       = ((@i - 1) % 3) + 1;
    DECLARE @TypeId INT       = CASE (@i % 6) WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 1 WHEN 3 THEN 5 WHEN 4 THEN 6 ELSE 3 END;
    DECLARE @Qty INT          = CASE WHEN @TypeId IN (3, 4) THEN 1 ELSE ((@i % 3) + 1) END;
    DECLARE @Price DECIMAL(12,2), @Duration INT;
    SELECT @Price = Price, @Duration = DurationMinutes FROM TicketTypes WHERE TicketTypeId = @TypeId;

    DECLARE @CreatedAt DATETIME2 = DATEADD(HOUR, -((@i * 13) % 24), DATEADD(DAY, -((@i * 5) % 14) - 1, SYSDATETIME()));
    DECLARE @OrderId INT;

    INSERT INTO Orders (UserId, TotalAmount, Status, CreatedAt)
    VALUES (@UserId, @Price * @Qty, 'PAID', @CreatedAt);
    SET @OrderId = SCOPE_IDENTITY();

    INSERT INTO OrderDetails (OrderId, TicketTypeId, Quantity, UnitPrice)
    VALUES (@OrderId, @TypeId, @Qty, @Price);

    INSERT INTO Payments (OrderId, Amount, PaymentMethod, Status, TransactionCode, PaidAt)
    VALUES (@OrderId, @Price * @Qty, 'MOCK', 'SUCCESS',
            CONCAT('MOCK-TXN-', RIGHT('000000' + CAST(@OrderId AS VARCHAR(10)), 6)), @CreatedAt);

    DECLARE @k INT = 1;
    WHILE @k <= @Qty
    BEGIN
        DECLARE @ValidTo DATETIME2 = DATEADD(MINUTE, @Duration, @CreatedAt);
        INSERT INTO Tickets (OrderId, TicketTypeId, TicketCode, QRCode, ValidFrom, ValidTo, Status)
        VALUES (@OrderId, @TypeId,
                CONCAT('TICKET-S', RIGHT('0000' + CAST(@OrderId AS VARCHAR(10)), 4), '-', @k),
                NULL, @CreatedAt, @ValidTo,
                CASE WHEN @ValidTo < SYSDATETIME() THEN (CASE WHEN @k = 1 THEN 'USED' ELSE 'EXPIRED' END)
                     ELSE 'ACTIVE' END);
        SET @k += 1;
    END

    SET @i += 1;
END
GO

/* ---------------------------------------------------------------------
   17. TripHistories
   --------------------------------------------------------------------- */
INSERT INTO TripHistories (UserId, Origin, Destination, RouteData, StartedAt, CompletedAt) VALUES
(1, N'Hồ Hoàn Kiếm', N'Văn Miếu - Quốc Tử Giám',
 N'{"preference":"FASTEST","route":"BUS01","transfers":0,"duration":20}',
 DATEADD(DAY, -2, SYSDATETIME()), DATEADD(MINUTE, 20, DATEADD(DAY, -2, SYSDATETIME()))),
(2, N'Hồ Hoàn Kiếm', N'Hoàng thành Thăng Long',
 N'{"preference":"FEWEST_TRANSFERS","route":"BUS02","transfers":0,"duration":25}',
 DATEADD(DAY, -1, SYSDATETIME()), DATEADD(MINUTE, 25, DATEADD(DAY, -1, SYSDATETIME()))),
(1, N'Ga Hà Nội', N'Chùa Trấn Quốc',
 N'{"preference":"CHEAPEST","route":"BUS11>BUS10","transfers":1,"duration":34}',
 DATEADD(DAY, -3, SYSDATETIME()), DATEADD(MINUTE, 34, DATEADD(DAY, -3, SYSDATETIME())));
GO

/* Kiem tra nhanh so luong ban ghi */
SELECT 'Users' AS TableName, COUNT(*) AS Total FROM Users
UNION ALL SELECT 'TransportTypes', COUNT(*) FROM TransportTypes
UNION ALL SELECT 'Vehicles', COUNT(*) FROM Vehicles
UNION ALL SELECT 'Stations', COUNT(*) FROM Stations
UNION ALL SELECT 'Routes', COUNT(*) FROM Routes
UNION ALL SELECT 'RouteStations', COUNT(*) FROM RouteStations
UNION ALL SELECT 'Trips', COUNT(*) FROM Trips
UNION ALL SELECT 'StopTimes', COUNT(*) FROM StopTimes
UNION ALL SELECT 'TouristAttractions', COUNT(*) FROM TouristAttractions
UNION ALL SELECT 'AttractionStations', COUNT(*) FROM AttractionStations
UNION ALL SELECT 'TicketTypes', COUNT(*) FROM TicketTypes
UNION ALL SELECT 'FareRules', COUNT(*) FROM FareRules
UNION ALL SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL SELECT 'OrderDetails', COUNT(*) FROM OrderDetails
UNION ALL SELECT 'Payments', COUNT(*) FROM Payments
UNION ALL SELECT 'Tickets', COUNT(*) FROM Tickets
UNION ALL SELECT 'TripHistories', COUNT(*) FROM TripHistories;
GO
