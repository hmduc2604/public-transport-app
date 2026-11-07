@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title HanoiGo - Cai dat may chu chi duong OSRM
rem ====================================================================
rem  May chu chi duong OSRM chay tren may (Docker) - ban do duong Ha Noi
rem   - di bo   (foot)    : http://localhost:5001
rem   - xe dap  (bicycle) : http://localhost:5002
rem   - o to/bus (car)    : http://localhost:5003
rem  Chi can chay 1 lan (khoang 10-20 phut). Cac container tu khoi dong
rem  lai cung Docker (--restart unless-stopped).
rem  Nguon ban do: OpenStreetMap - Geofabrik (vietnam-latest.osm.pbf),
rem  cat vung Ha Noi bang osmium.
rem ====================================================================
set "LOG=%~dp0osrm-setup.log"
set "DATA=%~dp0osrm-data"
set "IMG=ghcr.io/project-osrm/osrm-backend:v5.27.1"
set "BBOX=105.70,20.92,105.92,21.11"
echo [%time%] START > "%LOG%"

docker info >nul 2>&1
if errorlevel 1 (
  call :log "LOI: Docker chua chay - hay mo Docker Desktop roi chay lai"
  goto fail
)
if not exist "%DATA%" mkdir "%DATA%"

if exist "%DATA%\hanoi.osm.pbf" goto havemap
if exist "%DATA%\vietnam-latest.osm.pbf" goto clip
call :log "1/4 Tai ban do Viet Nam tu Geofabrik (vai tram MB)..."
curl -sS -L --fail --retry 3 -A "HanoiGo-student-project/1.0" -o "%DATA%\vietnam.part" https://download.geofabrik.de/asia/vietnam-latest.osm.pbf >> "%LOG%" 2>&1
if errorlevel 1 goto failmap
move /y "%DATA%\vietnam.part" "%DATA%\vietnam-latest.osm.pbf" >nul
for %%F in ("%DATA%\vietnam-latest.osm.pbf") do call :log "Da tai: %%~zF bytes"

:clip
call :log "2/4 Cat vung Ha Noi (%BBOX%) bang osmium"
docker run --rm -v "%DATA%:/data" debian:bookworm-slim bash -c "apt-get update -qq && apt-get install -y -qq osmium-tool >/dev/null && osmium extract --overwrite -b %BBOX% /data/vietnam-latest.osm.pbf -o /data/hanoi.osm.pbf" >> "%LOG%" 2>&1
if errorlevel 1 goto failclip
for %%F in ("%DATA%\hanoi.osm.pbf") do call :log "Ban do Ha Noi: %%~zF bytes"
:havemap

call :log "3/4 Tai image OSRM"
docker pull %IMG% >> "%LOG%" 2>&1
if errorlevel 1 (
  call :log "LOI: khong tai duoc image %IMG%"
  goto fail
)

call :log "4/4 Xay du lieu chi duong + khoi dong may chu"
call :build foot 5001
if errorlevel 1 goto fail
call :build bicycle 5002
if errorlevel 1 goto fail
call :build car 5003
if errorlevel 1 goto fail

call :log "XONG - OSRM: di bo :5001, xe dap :5002, o to :5003"
timeout /t 10
exit /b 0

:build
set "P=%~1"
set "PORT=%~2"
set "DIR=%DATA%\%P%"
if exist "%DIR%\hanoi.osrm.cell_metrics" goto run
call :log "  - %P%: extract / partition / customize"
if not exist "%DIR%" mkdir "%DIR%"
copy /y "%DATA%\hanoi.osm.pbf" "%DIR%\hanoi.osm.pbf" >nul
docker run --rm -v "%DIR%:/data" %IMG% osrm-extract -p /opt/%P%.lua /data/hanoi.osm.pbf >> "%LOG%" 2>&1
if errorlevel 1 goto buildfail
docker run --rm -v "%DIR%:/data" %IMG% osrm-partition /data/hanoi.osrm >> "%LOG%" 2>&1
if errorlevel 1 goto buildfail
docker run --rm -v "%DIR%:/data" %IMG% osrm-customize /data/hanoi.osrm >> "%LOG%" 2>&1
if errorlevel 1 goto buildfail
:run
docker rm -f pta-osrm-%P% >nul 2>&1
docker run -d --name pta-osrm-%P% --restart unless-stopped -p %PORT%:5000 -v "%DIR%:/data" %IMG% osrm-routed --algorithm mld /data/hanoi.osrm >> "%LOG%" 2>&1
if errorlevel 1 goto buildfail
call :log "  - %P%: chay tai http://localhost:%PORT%"
exit /b 0
:buildfail
call :log "LOI khi xay du lieu %P% - xem osrm-setup.log"
exit /b 1

:failmap
call :log "LOI: khong tai duoc ban do tu Geofabrik - kiem tra mang roi chay lai"
goto fail
:failclip
call :log "LOI: khong cat duoc vung Ha Noi - xem osrm-setup.log"
goto fail

:fail
echo.
echo Co loi, xem file osrm-setup.log
pause
exit /b 1

:log
echo [%time%] %~1
>> "%LOG%" echo [%time%] %~1
exit /b
