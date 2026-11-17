/* =====================================================================
   11_ai_features.sql - Bang cho 2 chuc nang AI (Gemini)
   Chay tren database DA CO du lieu (an toan khi chay lai).
   - AttractionEmbeddings: vector ngu nghia cua tung dia diem (backend tu tinh lan dau dung goi y)
   - AttractionViews     : lich su quan tam (xem chi tiet / tim duong toi / hoi tro ly)
     -> ca nhan hoa goi y "Danh cho ban"; them du lieu mau cho 2 tai khoan demo
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
USE PublicTransportDBV2;
GO
IF OBJECT_ID('AttractionEmbeddings', 'U') IS NULL
CREATE TABLE AttractionEmbeddings (
    AttractionId  INT            NOT NULL PRIMARY KEY,
    Model         VARCHAR(100)   NOT NULL,
    ContentHash   CHAR(64)       NOT NULL,
    Dimensions    INT            NOT NULL,
    Vector        NVARCHAR(MAX)  NOT NULL,
    UpdatedAt     DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_AttractionEmbeddings_Attractions FOREIGN KEY (AttractionId)
        REFERENCES TouristAttractions(AttractionId)
);
GO
IF OBJECT_ID('AttractionViews', 'U') IS NULL
CREATE TABLE AttractionViews (
    ViewId        BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserId        INT           NOT NULL,
    AttractionId  INT           NOT NULL,
    Source        VARCHAR(20)   NOT NULL DEFAULT 'VIEW',
    ViewedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_AttractionViews_Users       FOREIGN KEY (UserId)       REFERENCES Users(UserId),
    CONSTRAINT FK_AttractionViews_Attractions FOREIGN KEY (AttractionId) REFERENCES TouristAttractions(AttractionId),
    CONSTRAINT CK_AttractionViews_Source CHECK (Source IN ('VIEW', 'ROUTE', 'ASSISTANT'))
);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AttractionViews_User')
    CREATE INDEX IX_AttractionViews_User ON AttractionViews(UserId, ViewedAt DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AttractionViews_Attraction')
    CREATE INDEX IX_AttractionViews_Attraction ON AttractionViews(AttractionId);
GO
/* ---------------------------------------------------------------------
   18. AttractionViews - lich su quan tam mau de demo goi y "Danh cho ban" (AI)
       an@example.com  : hay xem di tich, bao tang (lich su)
       binh@example.com: hay xem ho, pho, cho (thu gian, am thuc)
   --------------------------------------------------------------------- */
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
JOIN TouristAttractions a ON a.Name = v.Name
WHERE NOT EXISTS (SELECT 1 FROM AttractionViews x WHERE x.UserId = u.UserId);
GO

SELECT (SELECT COUNT(*) FROM AttractionViews) AS AttractionViews,
       (SELECT COUNT(*) FROM AttractionEmbeddings) AS AttractionEmbeddings;
GO
