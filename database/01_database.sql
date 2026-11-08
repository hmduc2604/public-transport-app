/* =====================================================================
   PUBLIC TRANSPORT MULTI-MODAL - DATABASE SCHEMA (SQL Server)
   File   : 01_database.sql
   Muc dich: Tao database PublicTransportDBV2 + 20 bang + PK/FK/CHECK/INDEX
   Chay   : Mo SSMS -> New Query -> F5 (chay ca file)
   Luu y  : Script se XOA database cu (neu co) de tao lai tu dau.
            Neu khong muon mat du lieu, dung 04_upgrade_existing_db.sql
   ===================================================================== */
-- Bat buoc cho unique index co dieu kien (UX_Users_Phone); sqlcmd mac dinh tat QUOTED_IDENTIFIER
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO


USE master;
GO

IF DB_ID('PublicTransportDBV2') IS NOT NULL
BEGIN
    ALTER DATABASE PublicTransportDBV2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PublicTransportDBV2;
END
GO

CREATE DATABASE PublicTransportDBV2;
GO

USE PublicTransportDBV2;
GO

/* ---------------------------------------------------------------------
   1. Users
   --------------------------------------------------------------------- */
CREATE TABLE Users (
    UserId        INT IDENTITY(1,1) PRIMARY KEY,
    FullName      NVARCHAR(100) NOT NULL,
    Email         VARCHAR(150)  NOT NULL UNIQUE,
    PasswordHash  VARCHAR(255)  NOT NULL,
    Phone         VARCHAR(20),
    Role          VARCHAR(20)   NOT NULL DEFAULT 'USER',
    CreatedAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt     DATETIME2     NULL,
    Status        VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',
    EmailVerifiedAt DATETIME2   NULL,     -- thoi diem xac nhan email (qua ma gui ve email)
    PhoneVerifiedAt DATETIME2   NULL,     -- thoi diem xac nhan SĐT (qua ma SMS)
    CONSTRAINT CK_Users_Role   CHECK (Role IN ('USER', 'ADMIN')),
    CONSTRAINT CK_Users_Status CHECK (Status IN ('ACTIVE', 'LOCKED'))
);
GO
-- So dien thoai dung de dang nhap -> khong trung (cho phep NULL)
CREATE UNIQUE INDEX UX_Users_Phone ON Users(Phone) WHERE Phone IS NOT NULL;
GO

/* ---------------------------------------------------------------------
   1b. VerificationCodes  (ma xac nhan dang ky gui qua Email / SMS)
       - Luu thong tin dang ky tam trong Payload (JSON, mat khau da bam)
       - Chi luu HASH cua ma, khong luu ma goc
       - Nhap dung ma -> moi tao ban ghi trong Users
   --------------------------------------------------------------------- */
CREATE TABLE VerificationCodes (
    VerificationId VARCHAR(36)   NOT NULL PRIMARY KEY,
    Purpose        VARCHAR(30)   NOT NULL,          -- REGISTER
    Channel        VARCHAR(10)   NOT NULL,          -- EMAIL | SMS
    Destination    VARCHAR(150)  NOT NULL,          -- email hoac SĐT nhan ma
    CodeHash       VARCHAR(64)   NOT NULL,
    Payload        NVARCHAR(MAX) NULL,
    Attempts       INT           NOT NULL DEFAULT 0,
    SendCount      INT           NOT NULL DEFAULT 1,
    ExpiresAt      DATETIME2     NOT NULL,
    LastSentAt     DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    VerifiedAt     DATETIME2     NULL,
    CreatedAt      DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CK_VerificationCodes_Channel CHECK (Channel IN ('EMAIL', 'SMS'))
);
CREATE INDEX IX_VerificationCodes_Destination ON VerificationCodes(Destination, LastSentAt);
GO


/* ---------------------------------------------------------------------
   2. TransportTypes  (Bus, Metro, Bicycle, Electric Vehicle)
   --------------------------------------------------------------------- */
CREATE TABLE TransportTypes (
    TransportTypeId INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(50)  NOT NULL UNIQUE,
    Description     NVARCHAR(255),
    Status          VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT CK_TransportTypes_Status CHECK (Status IN ('ACTIVE', 'INACTIVE'))
);
GO

/* ---------------------------------------------------------------------
   3. Vehicles
   --------------------------------------------------------------------- */
CREATE TABLE Vehicles (
    VehicleId       INT IDENTITY(1,1) PRIMARY KEY,
    TransportTypeId INT          NOT NULL,
    VehicleCode     VARCHAR(50)  NOT NULL UNIQUE,
    VehicleName     NVARCHAR(100),
    Capacity        INT,
    Status          VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT FK_Vehicles_TransportTypes FOREIGN KEY (TransportTypeId)
        REFERENCES TransportTypes(TransportTypeId),
    CONSTRAINT CK_Vehicles_Status CHECK (Status IN ('ACTIVE', 'INACTIVE', 'MAINTENANCE'))
);
GO

/* ---------------------------------------------------------------------
   4. Stations
   --------------------------------------------------------------------- */
CREATE TABLE Stations (
    StationId       INT IDENTITY(1,1) PRIMARY KEY,
    StationCode     VARCHAR(50)   NOT NULL UNIQUE,
    StationName     NVARCHAR(150) NOT NULL,
    Latitude        DECIMAL(9,6)  NOT NULL,
    Longitude       DECIMAL(9,6)  NOT NULL,
    Address         NVARCHAR(255),
    TransportTypeId INT           NOT NULL,
    Status          VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT FK_Stations_TransportTypes FOREIGN KEY (TransportTypeId)
        REFERENCES TransportTypes(TransportTypeId),
    CONSTRAINT CK_Stations_Status CHECK (Status IN ('ACTIVE', 'INACTIVE'))
);
GO

/* ---------------------------------------------------------------------
   5. Routes
   --------------------------------------------------------------------- */
CREATE TABLE Routes (
    RouteId         INT IDENTITY(1,1) PRIMARY KEY,
    RouteCode       VARCHAR(50)   NOT NULL UNIQUE,
    RouteName       NVARCHAR(150) NOT NULL,
    TransportTypeId INT           NOT NULL,
    Description     NVARCHAR(500),
    StartStationId  INT NULL,
    EndStationId    INT NULL,
    Status          VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT FK_Routes_TransportTypes FOREIGN KEY (TransportTypeId)
        REFERENCES TransportTypes(TransportTypeId),
    CONSTRAINT FK_Routes_StartStation FOREIGN KEY (StartStationId)
        REFERENCES Stations(StationId),
    CONSTRAINT FK_Routes_EndStation FOREIGN KEY (EndStationId)
        REFERENCES Stations(StationId),
    CONSTRAINT CK_Routes_Status CHECK (Status IN ('ACTIVE', 'INACTIVE'))
);
GO

/* ---------------------------------------------------------------------
   6. RouteStations  (N:M Route <-> Station, co thu tu dung)
   --------------------------------------------------------------------- */
CREATE TABLE RouteStations (
    RouteStationId    INT IDENTITY(1,1) PRIMARY KEY,
    RouteId           INT NOT NULL,
    StationId         INT NOT NULL,
    StopOrder         INT NOT NULL,
    DistanceFromStart DECIMAL(10,2) NULL,   -- met, tinh tu tram dau tuyen
    CONSTRAINT FK_RouteStations_Routes   FOREIGN KEY (RouteId)   REFERENCES Routes(RouteId),
    CONSTRAINT FK_RouteStations_Stations FOREIGN KEY (StationId) REFERENCES Stations(StationId),
    CONSTRAINT UQ_RouteStations_Order UNIQUE (RouteId, StopOrder)
);
GO

/* ---------------------------------------------------------------------
   7. Trips  (chuyen xe chay theo tuyen)
   --------------------------------------------------------------------- */
CREATE TABLE Trips (
    TripId        INT IDENTITY(1,1) PRIMARY KEY,
    RouteId       INT         NOT NULL,
    VehicleId     INT         NOT NULL,
    TripCode      VARCHAR(50) NOT NULL UNIQUE,
    DepartureTime TIME        NOT NULL,
    ArrivalTime   TIME        NOT NULL,
    Status        VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',
    CONSTRAINT FK_Trips_Routes   FOREIGN KEY (RouteId)   REFERENCES Routes(RouteId),
    CONSTRAINT FK_Trips_Vehicles FOREIGN KEY (VehicleId) REFERENCES Vehicles(VehicleId),
    CONSTRAINT CK_Trips_Status CHECK (Status IN ('SCHEDULED', 'RUNNING', 'COMPLETED', 'CANCELLED'))
);
GO

/* ---------------------------------------------------------------------
   8. StopTimes  (gio den/di cua tung chuyen tai tung tram)
   --------------------------------------------------------------------- */
CREATE TABLE StopTimes (
    StopTimeId    INT IDENTITY(1,1) PRIMARY KEY,
    TripId        INT  NOT NULL,
    StationId     INT  NOT NULL,
    ArrivalTime   TIME NOT NULL,
    DepartureTime TIME NOT NULL,
    StopOrder     INT  NOT NULL,
    CONSTRAINT FK_StopTimes_Trips    FOREIGN KEY (TripId)    REFERENCES Trips(TripId),
    CONSTRAINT FK_StopTimes_Stations FOREIGN KEY (StationId) REFERENCES Stations(StationId),
    CONSTRAINT UQ_StopTimes_Order UNIQUE (TripId, StopOrder)
);
GO

/* ---------------------------------------------------------------------
   9. TouristAttractions  (da mo rong theo de xuat cua Nguoi 1:
      History, Highlights, TicketPrice, PopularityScore)
   --------------------------------------------------------------------- */
CREATE TABLE TouristAttractions (
    AttractionId    INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(200)  NOT NULL,
    Description     NVARCHAR(1000),
    History         NVARCHAR(MAX)  NULL,
    Highlights      NVARCHAR(MAX)  NULL,      -- cac y cach nhau boi dau '|'
    Address         NVARCHAR(255),
    Latitude        DECIMAL(9,6)   NOT NULL,
    Longitude       DECIMAL(9,6)   NOT NULL,
    Category        NVARCHAR(100),
    OpeningHours    NVARCHAR(500),
    TicketPrice     NVARCHAR(500)  NULL,
    ImageUrl        VARCHAR(500),
    ImageCredit     NVARCHAR(300)  NULL,      -- tac gia / giay phep anh
    ImageSourceUrl  VARCHAR(500)   NULL,      -- trang nguon cua anh (Wikimedia Commons)
    HoursSummary    NVARCHAR(100)  NULL,      -- gio mo cua rut gon (hien tren the dia diem)
    PriceFrom       NVARCHAR(50)   NULL,      -- gia ve tu ... (hien tren the dia diem)
    VisitDuration   NVARCHAR(100)  NULL,      -- thoi gian tham quan goi y
    BestTime        NVARCHAR(300)  NULL,      -- thoi diem dep nhat
    Tips            NVARCHAR(MAX)  NULL,      -- luu y, cac y cach nhau boi dau '|'
    PopularityScore INT            NOT NULL CONSTRAINT DF_TouristAttractions_Popularity DEFAULT 50,
    Status          VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE',
    CreatedAt       DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt       DATETIME2      NULL,
    CONSTRAINT CK_TouristAttractions_Status CHECK (Status IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT CK_TouristAttractions_Popularity CHECK (PopularityScore BETWEEN 0 AND 100)
);
GO

/* ---------------------------------------------------------------------
   10. AttractionStations  (tram gan diem tham quan)
   --------------------------------------------------------------------- */
CREATE TABLE AttractionStations (
    AttractionStationId INT IDENTITY(1,1) PRIMARY KEY,
    AttractionId        INT NOT NULL,
    StationId           INT NOT NULL,
    WalkingDistance     DECIMAL(10,2),   -- met
    WalkingDuration     INT,             -- phut
    CONSTRAINT FK_AttractionStations_Attractions FOREIGN KEY (AttractionId)
        REFERENCES TouristAttractions(AttractionId),
    CONSTRAINT FK_AttractionStations_Stations FOREIGN KEY (StationId)
        REFERENCES Stations(StationId),
    CONSTRAINT UQ_AttractionStations UNIQUE (AttractionId, StationId)
);
GO

/* ---------------------------------------------------------------------
   10b. AttractionImages  (bo suu tap anh cua diem tham quan)
   --------------------------------------------------------------------- */
CREATE TABLE AttractionImages (
    ImageId       INT IDENTITY(1,1) PRIMARY KEY,
    AttractionId  INT            NOT NULL,
    ImageUrl      VARCHAR(500)   NOT NULL,
    Caption       NVARCHAR(200)  NULL,
    Credit        NVARCHAR(300)  NULL,   -- tac gia / giay phep
    SourceUrl     VARCHAR(500)   NULL,   -- trang nguon (Wikimedia Commons)
    SortOrder     INT            NOT NULL DEFAULT 0,
    CONSTRAINT FK_AttractionImages_Attractions FOREIGN KEY (AttractionId)
        REFERENCES TouristAttractions(AttractionId)
);
CREATE INDEX IX_AttractionImages_Attraction ON AttractionImages(AttractionId, SortOrder);
GO

/* ---------------------------------------------------------------------
   11. TicketTypes  (SINGLE = ve luot, MONTHLY = ve thang)
   --------------------------------------------------------------------- */
CREATE TABLE TicketTypes (
    TicketTypeId    INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(100) NOT NULL,
    TransportTypeId INT           NOT NULL,
    Type            VARCHAR(20)   NOT NULL,
    Price           DECIMAL(12,2) NOT NULL,
    DurationMinutes INT NULL,
    Description     NVARCHAR(500),
    Status          VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT FK_TicketTypes_TransportTypes FOREIGN KEY (TransportTypeId)
        REFERENCES TransportTypes(TransportTypeId),
    CONSTRAINT CK_TicketTypes_Type   CHECK (Type IN ('SINGLE', 'MONTHLY')),
    CONSTRAINT CK_TicketTypes_Status CHECK (Status IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT CK_TicketTypes_Price  CHECK (Price >= 0)
);
GO

/* ---------------------------------------------------------------------
   12. FareRules  (gia ve theo cap tram cho tung loai phuong tien)
   --------------------------------------------------------------------- */
CREATE TABLE FareRules (
    FareRuleId      INT IDENTITY(1,1) PRIMARY KEY,
    TransportTypeId INT           NOT NULL,
    FromStationId   INT           NOT NULL,
    ToStationId     INT           NOT NULL,
    Price           DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_FareRules_TransportTypes FOREIGN KEY (TransportTypeId)
        REFERENCES TransportTypes(TransportTypeId),
    CONSTRAINT FK_FareRules_FromStation FOREIGN KEY (FromStationId) REFERENCES Stations(StationId),
    CONSTRAINT FK_FareRules_ToStation   FOREIGN KEY (ToStationId)   REFERENCES Stations(StationId),
    CONSTRAINT CK_FareRules_Price CHECK (Price >= 0)
);
GO

/* ---------------------------------------------------------------------
   13. Orders
   --------------------------------------------------------------------- */
CREATE TABLE Orders (
    OrderId     INT IDENTITY(1,1) PRIMARY KEY,
    UserId      INT           NOT NULL,
    TotalAmount DECIMAL(12,2) NOT NULL,
    Status      VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    CreatedAt   DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT CK_Orders_Status CHECK (Status IN ('PENDING', 'PAID', 'CANCELLED'))
);
GO

/* ---------------------------------------------------------------------
   14. OrderDetails
   --------------------------------------------------------------------- */
CREATE TABLE OrderDetails (
    OrderDetailId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId       INT           NOT NULL,
    TicketTypeId  INT           NOT NULL,
    Quantity      INT           NOT NULL,
    UnitPrice     DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_OrderDetails_Orders      FOREIGN KEY (OrderId)      REFERENCES Orders(OrderId),
    CONSTRAINT FK_OrderDetails_TicketTypes FOREIGN KEY (TicketTypeId) REFERENCES TicketTypes(TicketTypeId),
    CONSTRAINT CK_OrderDetails_Quantity CHECK (Quantity > 0)
);
GO

/* ---------------------------------------------------------------------
   15. Payments  (thanh toan mo phong - MOCK)
   --------------------------------------------------------------------- */
CREATE TABLE Payments (
    PaymentId       INT IDENTITY(1,1) PRIMARY KEY,
    OrderId         INT           NOT NULL,
    Amount          DECIMAL(12,2) NOT NULL,
    PaymentMethod   VARCHAR(30)   NOT NULL,          -- CARD | BANK_TRANSFER (MOCK: du lieu cu)
    Status          VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    TransactionCode VARCHAR(100),
    PaidAt          DATETIME2 NULL,
    -- The: chi luu hang the + 4 so cuoi (KHONG luu so the day du / CVV)
    CardBrand       VARCHAR(20)   NULL,
    CardLast4       CHAR(4)       NULL,
    -- Chuyen khoan QR: noi dung CK duy nhat, han thanh toan, xac nhan
    TransferContent    VARCHAR(50)   NULL,
    ExpiresAt          DATETIME2     NULL,
    CustomerNotifiedAt DATETIME2     NULL,     -- khach bam "Toi da chuyen khoan"
    ConfirmedBy        NVARCHAR(100) NULL,     -- 'ADMIN #4' | 'SEPAY'
    BankReference      VARCHAR(100)  NULL,     -- ma giao dich ngan hang
    Note               NVARCHAR(255) NULL,
    CreatedAt          DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    CONSTRAINT CK_Payments_Method CHECK (PaymentMethod IN ('CARD', 'BANK_TRANSFER', 'MOCK')),
    CONSTRAINT CK_Payments_Status CHECK (Status IN ('PENDING', 'SUCCESS', 'FAILED', 'EXPIRED', 'CANCELLED'))
);
CREATE UNIQUE INDEX UX_Payments_TransferContent ON Payments(TransferContent) WHERE TransferContent IS NOT NULL;
GO

/* ---------------------------------------------------------------------
   15b. PaymentSettings  (1 dong: tai khoan ngan hang NHAN tien chuyen khoan QR)
        Admin cap nhat tai trang Quan tri > Thanh toan
   --------------------------------------------------------------------- */
CREATE TABLE PaymentSettings (
    SettingId             INT           NOT NULL PRIMARY KEY DEFAULT 1,
    BankBin               VARCHAR(10)   NULL,
    BankName              NVARCHAR(100) NULL,
    AccountNo             VARCHAR(30)   NULL,
    AccountName           NVARCHAR(100) NULL,
    TransferExpiryMinutes INT           NOT NULL DEFAULT 30,
    UpdatedAt             DATETIME2     NULL,
    CONSTRAINT CK_PaymentSettings_Single CHECK (SettingId = 1)
);
GO

/* ---------------------------------------------------------------------
   16. Tickets  (ve dien tu + QR)
   --------------------------------------------------------------------- */
CREATE TABLE Tickets (
    TicketId     INT IDENTITY(1,1) PRIMARY KEY,
    OrderId      INT          NOT NULL,
    TicketTypeId INT          NOT NULL,
    TicketCode   VARCHAR(100) NOT NULL UNIQUE,
    QRCode       VARCHAR(500),
    ValidFrom    DATETIME2    NOT NULL,
    ValidTo      DATETIME2    NOT NULL,
    Status       VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT FK_Tickets_Orders      FOREIGN KEY (OrderId)      REFERENCES Orders(OrderId),
    CONSTRAINT FK_Tickets_TicketTypes FOREIGN KEY (TicketTypeId) REFERENCES TicketTypes(TicketTypeId),
    CONSTRAINT CK_Tickets_Status CHECK (Status IN ('ACTIVE', 'USED', 'EXPIRED', 'CANCELLED'))
);
GO

/* ---------------------------------------------------------------------
   17. TripHistories  (lich su chuyen di - RouteData luu JSON)
   --------------------------------------------------------------------- */
CREATE TABLE TripHistories (
    TripHistoryId INT IDENTITY(1,1) PRIMARY KEY,
    UserId        INT           NOT NULL,
    Origin        NVARCHAR(255) NOT NULL,
    Destination   NVARCHAR(255) NOT NULL,
    RouteData     NVARCHAR(MAX),
    StartedAt     DATETIME2 NULL,
    CompletedAt   DATETIME2 NULL,
    CONSTRAINT FK_TripHistories_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
GO

/* ---------------------------------------------------------------------
   INDEX - toi uu cac truy van hay dung
   --------------------------------------------------------------------- */
CREATE INDEX IX_Stations_TransportType       ON Stations(TransportTypeId);
CREATE INDEX IX_Routes_TransportType         ON Routes(TransportTypeId);
CREATE INDEX IX_RouteStations_Station        ON RouteStations(StationId);
CREATE INDEX IX_Trips_Route                  ON Trips(RouteId);
CREATE INDEX IX_StopTimes_Trip               ON StopTimes(TripId);
CREATE INDEX IX_StopTimes_Station            ON StopTimes(StationId, DepartureTime);
CREATE INDEX IX_AttractionStations_Station   ON AttractionStations(StationId);
CREATE INDEX IX_TouristAttractions_Category  ON TouristAttractions(Category);
CREATE INDEX IX_TouristAttractions_Popularity ON TouristAttractions(PopularityScore DESC);
CREATE INDEX IX_FareRules_Lookup             ON FareRules(TransportTypeId, FromStationId, ToStationId);
CREATE INDEX IX_Orders_User                  ON Orders(UserId, CreatedAt DESC);
CREATE INDEX IX_OrderDetails_Order           ON OrderDetails(OrderId);
CREATE INDEX IX_Payments_Order               ON Payments(OrderId);
CREATE INDEX IX_Tickets_Order                ON Tickets(OrderId);
CREATE INDEX IX_TripHistories_User           ON TripHistories(UserId, StartedAt DESC);
GO

/* Kiem tra: phai co 20 bang */
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO
