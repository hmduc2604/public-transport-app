@echo off
setlocal EnableExtensions
cd /d "%~dp0"
rem Cap nhat database dang chay (khong xoa du lieu): anh, thong tin dia diem, xac nhan dang ky, thanh toan the + chuyen khoan QR
set "LOG=%~dp0upgrade-db.log"
set "SA_PASSWORD=Pta@Strong2026"
set "CONTAINER=pta-sql"
set "SQLCMD=/opt/mssql-tools18/bin/sqlcmd"
echo [%time%] START > "%LOG%"
rem Chay lan luot cac script nang cap (an toan khi chay lai nhieu lan)
set "OK=1"
for %%F in (05_attraction_images 06_attraction_details 07_auth_verification 08_payment_methods 09_data_fixes) do (
  docker cp "%~dp0database\%%F.sql" %CONTAINER%:/tmp/%%F.sql >> "%LOG%" 2>&1
  docker exec %CONTAINER% %SQLCMD% -S localhost -U sa -P "%SA_PASSWORD%" -C -f 65001 -b -i /tmp/%%F.sql >> "%LOG%" 2>&1
  if errorlevel 1 set "OK=0"
)
if "%OK%"=="0" (echo [%time%] UPGRADE FAIL >> "%LOG%") else (echo [%time%] UPGRADE OK >> "%LOG%")
