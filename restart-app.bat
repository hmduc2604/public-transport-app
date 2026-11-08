@echo off
rem Khoi dong lai backend + frontend (dung khi doi thu vien hoac backend bi treo)
set "LOG=%~dp0restart-app.log"
echo [%time%] Dung cac tien trinh node cua do an >> "%LOG%"
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='node.exe'\" | Where-Object { $_.CommandLine -like '*public-transport-app*' } | ForEach-Object { Write-Output ('stop ' + $_.ProcessId); Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }" >> "%LOG%" 2>&1
timeout /t 3 /nobreak >nul
cd /d "%~dp0backend"
start "HanoiGo Backend" /min cmd /c "npm run dev > ..\backend.log 2>&1"
cd /d "%~dp0frontend"
start "HanoiGo Frontend" /min cmd /c "npm run dev -- --force > ..\frontend.log 2>&1"
echo [%time%] Da khoi dong lai >> "%LOG%"
