@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title HanoiGo - Setup and Run
set "ROOT=%~dp0"
set "LOG=%~dp0run-all.log"
set "SA_PASSWORD=Pta@Strong2026"
set "CONTAINER=pta-sql"
echo [%time%] START > "%LOG%"

call :log "1/7 Kiem tra Docker"
docker info >nul 2>&1
if not errorlevel 1 goto dockerok
call :log "Docker chua chay - dang mo Docker Desktop, vui long cho..."
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
set /a n=0
:waitdocker
timeout /t 5 /nobreak >nul
docker info >nul 2>&1
if not errorlevel 1 goto dockerok
set /a n+=1
if %n% GEQ 72 goto faildocker
goto waitdocker
:faildocker
call :log "LOI: Docker khong khoi dong duoc sau 6 phut"
goto fail
:dockerok
call :log "Docker OK"

call :log "2/7 SQL Server container"
docker inspect %CONTAINER% >nul 2>&1
if not errorlevel 1 goto containerexists
call :log "Dang tai image SQL Server 2022 va tao container - lan dau mat vai phut..."
docker run -d --name %CONTAINER% -e ACCEPT_EULA=Y -e TZ=Asia/Ho_Chi_Minh -e "MSSQL_SA_PASSWORD=%SA_PASSWORD%" -p 1433:1433 mcr.microsoft.com/mssql/server:2022-latest >> "%LOG%" 2>&1
if errorlevel 1 goto failrun
goto waitsqlstart
:failrun
call :log "LOI: docker run that bai"
goto fail
:containerexists
docker start %CONTAINER% >> "%LOG%" 2>&1

:waitsqlstart
set "SQLCMD=/opt/mssql-tools18/bin/sqlcmd"
set "CFLAG=-C"
docker exec %CONTAINER% test -f /opt/mssql-tools18/bin/sqlcmd >nul 2>&1
if errorlevel 1 set "SQLCMD=/opt/mssql-tools/bin/sqlcmd"
if errorlevel 1 set "CFLAG="
call :log "3/7 Cho SQL Server san sang"
set /a n=0
:waitsql
docker exec %CONTAINER% %SQLCMD% -S localhost -U sa -P "%SA_PASSWORD%" %CFLAG% -Q "SELECT 1" >nul 2>&1
if not errorlevel 1 goto sqlok
set /a n+=1
if %n% GEQ 60 goto failsql
timeout /t 3 /nobreak >nul
goto waitsql
:failsql
call :log "LOI: SQL Server khong san sang"
docker logs --tail 30 %CONTAINER% >> "%LOG%" 2>&1
goto fail
:sqlok
call :log "SQL Server OK"
docker start pta-osrm-foot pta-osrm-bicycle pta-osrm-car >nul 2>&1
if errorlevel 1 call :log "Chua co may chu chi duong tren may (chay osrm-setup.bat 1 lan) - tam dung may chu cong cong"

call :log "4/7 Tao database + seed"
docker exec %CONTAINER% %SQLCMD% -S localhost -U sa -P "%SA_PASSWORD%" %CFLAG% -h -1 -W -Q "SET NOCOUNT ON; SELECT CASE WHEN DB_ID('PublicTransportDBV2') IS NULL THEN 0 ELSE 1 END" > "%TEMP%\pta_db.txt" 2>&1
set /p DBEXISTS=<"%TEMP%\pta_db.txt"
if "%DBEXISTS%"=="1" if not "%~1"=="reset" goto dbdone
docker cp "%ROOT%database\01_database.sql" %CONTAINER%:/tmp/01.sql >> "%LOG%" 2>&1
docker cp "%ROOT%database\02_seed.sql" %CONTAINER%:/tmp/02.sql >> "%LOG%" 2>&1
docker exec %CONTAINER% %SQLCMD% -S localhost -U sa -P "%SA_PASSWORD%" %CFLAG% -f 65001 -b -i /tmp/01.sql >> "%LOG%" 2>&1
if errorlevel 1 goto failschema
docker exec %CONTAINER% %SQLCMD% -S localhost -U sa -P "%SA_PASSWORD%" %CFLAG% -f 65001 -b -i /tmp/02.sql >> "%LOG%" 2>&1
if errorlevel 1 goto failseed
call :log "Database da tao xong"
goto dbdone
:failschema
call :log "LOI khi chay 01_database.sql - xem run-all.log"
goto fail
:failseed
call :log "LOI khi chay 02_seed.sql - xem run-all.log"
goto fail
:dbdone
call :log "Database OK"

call :log "5/7 Ghi backend\.env"
> "%ROOT%backend\.env" echo PORT=5000
>> "%ROOT%backend\.env" echo NODE_ENV=development
>> "%ROOT%backend\.env" echo CORS_ORIGIN=http://localhost:5173
>> "%ROOT%backend\.env" echo DB_SERVER=localhost
>> "%ROOT%backend\.env" echo DB_PORT=1433
>> "%ROOT%backend\.env" echo DB_INSTANCE=
>> "%ROOT%backend\.env" echo DB_DATABASE=PublicTransportDBV2
>> "%ROOT%backend\.env" echo DB_USER=sa
>> "%ROOT%backend\.env" echo DB_PASSWORD=%SA_PASSWORD%
>> "%ROOT%backend\.env" echo DB_ENCRYPT=false
>> "%ROOT%backend\.env" echo DB_TRUST_SERVER_CERTIFICATE=true
rem Khoa ky JWT rieng cho may nay (ngau nhien, tao 1 lan, khong day len GitHub)
if not exist "%ROOT%backend\.jwt-secret" node -e "process.stdout.write(require('crypto').randomBytes(48).toString('hex'))" > "%ROOT%backend\.jwt-secret"
set "JWT_SECRET="
if exist "%ROOT%backend\.jwt-secret" set /p JWT_SECRET=<"%ROOT%backend\.jwt-secret"
if not defined JWT_SECRET set "JWT_SECRET=hanoigo_dev_jwt_secret_change_me_2026"
>> "%ROOT%backend\.env" echo JWT_SECRET=%JWT_SECRET%
>> "%ROOT%backend\.env" echo JWT_EXPIRES_IN=7d
>> "%ROOT%backend\.env" echo QR_SECRET=hanoigo_dev_qr_secret_2026

call :log "6/7 npm install"
if exist "%ROOT%backend\node_modules" goto feinstall
pushd "%ROOT%backend"
call npm install --no-audit --no-fund >> "%LOG%" 2>&1
set ERR=%errorlevel%
popd
if not "%ERR%"=="0" goto failnpm
:feinstall
if exist "%ROOT%frontend\node_modules" goto npmdone
pushd "%ROOT%frontend"
call npm install --no-audit --no-fund >> "%LOG%" 2>&1
set ERR=%errorlevel%
popd
if not "%ERR%"=="0" goto failnpm
goto npmdone
:failnpm
call :log "LOI: npm install that bai - xem run-all.log"
goto fail
:npmdone
call :log "npm install OK"

call :log "7/7 Khoi dong backend + frontend"
pushd "%ROOT%backend"
start "HanoiGo Backend" /min cmd /c "npm run dev > ..\backend.log 2>&1"
popd
pushd "%ROOT%frontend"
start "HanoiGo Frontend" /min cmd /c "npm run dev > ..\frontend.log 2>&1"
popd
set /a n=0
:waitapi
timeout /t 3 /nobreak >nul
curl -s -o nul -w "%%{http_code}" http://localhost:5000/api/v1/health > "%TEMP%\pta_h.txt" 2>nul
set /p HC=<"%TEMP%\pta_h.txt"
if "%HC%"=="200" goto apiok
set /a n+=1
if %n% GEQ 40 goto failapi
goto waitapi
:failapi
call :log "LOI: backend khong chay - xem backend.log"
goto fail
:apiok
call :log "Backend OK: http://localhost:5000/api/v1"
timeout /t 4 /nobreak >nul
start "" http://localhost:5173
call :log "XONG - mo http://localhost:5173  (tai khoan: an@example.com / admin@example.com, mat khau 123456)"
echo.
echo Giu 2 cua so "HanoiGo Backend" va "HanoiGo Frontend" dang chay. Dong cua so nay duoc.
timeout /t 30
exit /b 0

:fail
echo.
echo Co loi, xem file run-all.log
pause
exit /b 1

:log
echo [%time%] %~1
>> "%LOG%" echo [%time%] %~1
exit /b
