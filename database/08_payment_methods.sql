/* =====================================================================
   08_payment_methods.sql - Thanh toan bang THE ngan hang va CHUYEN KHOAN QR (VietQR)
   Chay tren database DA CO du lieu (an toan khi chay lai).
   - Bo vi dien tu; Payments them cot cho the (hang + 4 so cuoi) va chuyen khoan
   - Bang PaymentSettings: tai khoan ngan hang nhan tien (admin cap nhat)
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
USE PublicTransportDBV2;
GO
IF COL_LENGTH('Payments', 'CardBrand') IS NULL ALTER TABLE Payments ADD CardBrand VARCHAR(20) NULL;
IF COL_LENGTH('Payments', 'CardLast4') IS NULL ALTER TABLE Payments ADD CardLast4 CHAR(4) NULL;
IF COL_LENGTH('Payments', 'TransferContent') IS NULL ALTER TABLE Payments ADD TransferContent VARCHAR(50) NULL;
IF COL_LENGTH('Payments', 'ExpiresAt') IS NULL ALTER TABLE Payments ADD ExpiresAt DATETIME2 NULL;
IF COL_LENGTH('Payments', 'CustomerNotifiedAt') IS NULL ALTER TABLE Payments ADD CustomerNotifiedAt DATETIME2 NULL;
IF COL_LENGTH('Payments', 'ConfirmedBy') IS NULL ALTER TABLE Payments ADD ConfirmedBy NVARCHAR(100) NULL;
IF COL_LENGTH('Payments', 'BankReference') IS NULL ALTER TABLE Payments ADD BankReference VARCHAR(100) NULL;
IF COL_LENGTH('Payments', 'Note') IS NULL ALTER TABLE Payments ADD Note NVARCHAR(255) NULL;
IF COL_LENGTH('Payments', 'CreatedAt') IS NULL ALTER TABLE Payments ADD CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Payments_CreatedAt DEFAULT SYSDATETIME();
GO
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Payments_Method') ALTER TABLE Payments DROP CONSTRAINT CK_Payments_Method;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Payments_Status') ALTER TABLE Payments DROP CONSTRAINT CK_Payments_Status;
GO
ALTER TABLE Payments ADD CONSTRAINT CK_Payments_Method CHECK (PaymentMethod IN ('CARD', 'BANK_TRANSFER', 'MOCK'));
ALTER TABLE Payments ADD CONSTRAINT CK_Payments_Status CHECK (Status IN ('PENDING', 'SUCCESS', 'FAILED', 'EXPIRED', 'CANCELLED'));
GO
-- Giao dich MOCK dang cho (tu luong cu) -> het han, khach thanh toan lai bang the / chuyen khoan
UPDATE Payments SET Status = 'EXPIRED' WHERE PaymentMethod = 'MOCK' AND Status = 'PENDING';
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Payments_TransferContent')
    CREATE UNIQUE INDEX UX_Payments_TransferContent ON Payments(TransferContent) WHERE TransferContent IS NOT NULL;
GO
IF OBJECT_ID('PaymentSettings', 'U') IS NULL
BEGIN
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
END
IF NOT EXISTS (SELECT 1 FROM PaymentSettings) INSERT INTO PaymentSettings (SettingId, TransferExpiryMinutes) VALUES (1, 30);
GO
SELECT PaymentMethod, Status, COUNT(*) AS Total FROM Payments GROUP BY PaymentMethod, Status ORDER BY PaymentMethod, Status;
SELECT * FROM PaymentSettings;
GO
