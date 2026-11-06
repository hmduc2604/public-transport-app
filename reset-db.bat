@echo off
setlocal EnableExtensions
cd /d "%~dp0"
set "ROOT=%~dp0"
set "LOG=%~dp0reset-db.log"
set "SA_PASSWORD=Pta@Strong2026"
set "CONTAINER=pta-sql"
echo [%time%] Tao lai container SQL Server (mui gio Viet Nam) + seed lai du lieu > "%LOG%"
docker rm -f %CONTAINER% >> "%LOG%" 2>&1
docker run -d --name %CONTAINER% -e ACCEPT_EULA=Y -e TZ=Asia/Ho_Chi_Minh -e "MSSQL_SA_PASSWORD=%SA_PASSWORD%" -p 1433:1433 mcr.microsoft.com/mssql/server:2022-latest >> "%LOG%" 2>&1
set "SQLCMD=/opt/mssql-tools18/bin/sqlcmd"
set /a n=0
:waitsql
timeout /t 3 /nobreak >nul
docker exec %CONTAINER% %SQLCMD% -S localhost -U sa -P "%SA_PASSWORD%" -C -Q "SELECT 1" >nul 2>&1
if not errorlevel 1 goto sqlok
set /a n+=1
if %n% GEQ 60 goto fail
goto waitsql
:sqlok
docker exec %CONTAINER% %SQLCMD% -S localhost -U sa -P "%SA_PASSWORD%" -C -Q "SELECT SYSDATETIME() AS DbNow" >> "%LOG%" 2>&1
docker cp "%ROOT%database\01_database.sql" %CONTAINER%:/tmp/01.sql >> "%LOG%" 2>&1
docker cp "%ROOT%database\02_seed.sql" %CONTAINER%:/tmp/02.sql >> "%LOG%" 2>&1
docker exec %CONTAINER% %SQLCMD% -S localhost -U sa -P "%SA_PASSWORD%" -C -f 65001 -b -i /tmp/01.sql >> "%LOG%" 2>&1
if errorlevel 1 goto fail
docker exec %CONTAINER% %SQLCMD% -S localhost -U sa -P "%SA_PASSWORD%" -C -f 65001 -b -i /tmp/02.sql >> "%LOG%" 2>&1
if errorlevel 1 goto fail
echo [%time%] RESET OK >> "%LOG%"
exit /b 0
:fail
echo [%time%] RESET FAIL >> "%LOG%"
pause
exit /b 1
