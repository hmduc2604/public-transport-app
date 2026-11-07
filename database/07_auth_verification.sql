/* =====================================================================
   07_auth_verification.sql - Dang ky co xac nhan qua Email / SMS
   Chay tren database DA CO du lieu (an toan khi chay lai nhieu lan).
   - Users: them EmailVerifiedAt, PhoneVerifiedAt; SĐT khong duoc trung (dang nhap bang SĐT)
   - Bang VerificationCodes: luu ma xac nhan (dang hash) + thong tin dang ky tam
   ===================================================================== */
-- Bat buoc cho unique index co dieu kien (UX_Users_Phone); sqlcmd mac dinh tat QUOTED_IDENTIFIER
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE PublicTransportDBV2;
GO
IF COL_LENGTH('Users', 'EmailVerifiedAt') IS NULL ALTER TABLE Users ADD EmailVerifiedAt DATETIME2 NULL;
IF COL_LENGTH('Users', 'PhoneVerifiedAt') IS NULL ALTER TABLE Users ADD PhoneVerifiedAt DATETIME2 NULL;
GO
-- Tai khoan da ton tai truoc khi co tinh nang xac nhan: coi nhu da xac nhan
UPDATE Users SET EmailVerifiedAt = ISNULL(EmailVerifiedAt, CreatedAt) WHERE EmailVerifiedAt IS NULL;
GO
-- SĐT trung nhau (neu co) -> giu tai khoan cu nhat, xoa SĐT o tai khoan con lai
;WITH d AS (
    SELECT UserId, ROW_NUMBER() OVER (PARTITION BY Phone ORDER BY UserId) AS rn
    FROM Users WHERE Phone IS NOT NULL
)
UPDATE Users SET Phone = NULL WHERE UserId IN (SELECT UserId FROM d WHERE rn > 1);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Users_Phone')
    CREATE UNIQUE INDEX UX_Users_Phone ON Users(Phone) WHERE Phone IS NOT NULL;
GO
IF OBJECT_ID('VerificationCodes', 'U') IS NULL
BEGIN
    CREATE TABLE VerificationCodes (
        VerificationId VARCHAR(36)   NOT NULL PRIMARY KEY,
        Purpose        VARCHAR(30)   NOT NULL,
        Channel        VARCHAR(10)   NOT NULL,
        Destination    VARCHAR(150)  NOT NULL,
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
END
GO
SELECT UserId, Email, Phone, EmailVerifiedAt, PhoneVerifiedAt FROM Users ORDER BY UserId;
GO
