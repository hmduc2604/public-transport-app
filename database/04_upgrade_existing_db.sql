/* =====================================================================
   04_upgrade_existing_db.sql
   DUNG KHI: nhom da co san database PublicTransportDBV2 (tao tu file
   "Truy van db" cu) va KHONG muon xoa du lieu.
   Script nay chi BO SUNG nhung gi backend can, chay nhieu lan khong loi.
   Neu tao moi tu dau thi chi can chay 01_database.sql + 02_seed.sql.
   ===================================================================== */
USE PublicTransportDBV2;
GO

-- 1. Mo rong bang TouristAttractions (de xuat cua Nguoi 1)
IF COL_LENGTH('TouristAttractions', 'History') IS NULL
    ALTER TABLE TouristAttractions ADD History NVARCHAR(MAX) NULL;
IF COL_LENGTH('TouristAttractions', 'Highlights') IS NULL
    ALTER TABLE TouristAttractions ADD Highlights NVARCHAR(MAX) NULL;
IF COL_LENGTH('TouristAttractions', 'TicketPrice') IS NULL
    ALTER TABLE TouristAttractions ADD TicketPrice NVARCHAR(500) NULL;
IF COL_LENGTH('TouristAttractions', 'PopularityScore') IS NULL
    ALTER TABLE TouristAttractions ADD PopularityScore INT NOT NULL
        CONSTRAINT DF_TouristAttractions_Popularity DEFAULT 50;
GO

-- 2. Index cho cac truy van hay dung
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TouristAttractions_Category')
    CREATE INDEX IX_TouristAttractions_Category ON TouristAttractions(Category);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TouristAttractions_Popularity')
    CREATE INDEX IX_TouristAttractions_Popularity ON TouristAttractions(PopularityScore DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RouteStations_Station')
    CREATE INDEX IX_RouteStations_Station ON RouteStations(StationId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_StopTimes_Station')
    CREATE INDEX IX_StopTimes_Station ON StopTimes(StationId, DepartureTime);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_User')
    CREATE INDEX IX_Orders_User ON Orders(UserId, CreatedAt DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Tickets_Order')
    CREATE INDEX IX_Tickets_Order ON Tickets(OrderId);
GO

-- 3. Mat khau seed cu la chuoi 'HASH_PASSWORD_001'... khong dang nhap duoc.
--    Dat lai mat khau = 123456 cho cac tai khoan seed (backend tu bam bcrypt khi khoi dong):
UPDATE Users
SET PasswordHash = 'SEED:123456'
WHERE PasswordHash NOT LIKE '$2%' AND PasswordHash NOT LIKE 'SEED:%';
GO

-- 4. Diem noi bat mac dinh cho 20 diem tham quan (phuc vu /attractions/featured)
UPDATE TouristAttractions SET PopularityScore = CASE Name
    WHEN N'Hồ Hoàn Kiếm' THEN 98 WHEN N'Phố cổ Hà Nội' THEN 95
    WHEN N'Văn Miếu - Quốc Tử Giám' THEN 94 WHEN N'Lăng Chủ tịch Hồ Chí Minh' THEN 92
    WHEN N'Hồ Tây' THEN 90 WHEN N'Đền Ngọc Sơn' THEN 88 WHEN N'Chùa Trấn Quốc' THEN 87
    WHEN N'Hoàng thành Thăng Long' THEN 86 WHEN N'Nhà hát Múa rối Thăng Long' THEN 86
    WHEN N'Nhà hát Lớn Hà Nội' THEN 85 WHEN N'Chùa Một Cột' THEN 85
    WHEN N'Nhà tù Hỏa Lò' THEN 84 WHEN N'Cầu Long Biên' THEN 83
    WHEN N'Quảng trường Ba Đình' THEN 82 WHEN N'Chợ Đồng Xuân' THEN 80
    WHEN N'Bảo tàng Dân tộc học Việt Nam' THEN 80 WHEN N'Phố Tạ Hiện' THEN 78
    WHEN N'Bảo tàng Lịch sử Quốc gia' THEN 75 WHEN N'Bảo tàng Mỹ thuật Việt Nam' THEN 72
    ELSE PopularityScore END;
GO

PRINT N'Upgrade xong. Backend co the chay voi database hien tai.';
