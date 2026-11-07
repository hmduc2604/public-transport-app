@echo off
setlocal EnableExtensions
cd /d "%~dp0"
rem Cap nhat database dang chay (khong xoa du lieu): them anh cho diem tham quan
set "LOG=%~dp0upgrade-db.log"
set "SA_PASSWORD=Pta@Strong2026"
set "CONTAINER=pta-sql"
set "SQLCMD=/opt/mssql-tools18/bin/sqlcmd"
echo [%time%] START > "%LOG%"
docker cp "%~dp0database\05_attraction_images.sql" %CONTAINER%:/tmp/05.sql >> "%LOG%" 2>&1
docker exec %CONTAINER% %SQLCMD% -S localhost -U sa -P "%SA_PASSWORD%" -C -f 65001 -b -i /tmp/05.sql >> "%LOG%" 2>&1
if errorlevel 1 (echo [%time%] UPGRADE FAIL >> "%LOG%") else (echo [%time%] UPGRADE OK >> "%LOG%")
