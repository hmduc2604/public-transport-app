@echo off
rem Cai / cap nhat thu vien cho backend + frontend roi khoi dong lai 2 cua so dang chay
set "LOG=%~dp0install-deps.log"
echo [%time%] node: > "%LOG%"
node -v >> "%LOG%" 2>&1
cd /d "%~dp0backend"
echo [%time%] npm install backend >> "%LOG%"
call npm install --no-audit --no-fund >> "%LOG%" 2>&1
echo BACKEND_EXIT=%errorlevel% >> "%LOG%"
cd /d "%~dp0frontend"
echo [%time%] npm install frontend >> "%LOG%"
call npm install --no-audit --no-fund >> "%LOG%" 2>&1
echo FRONTEND_EXIT=%errorlevel% >> "%LOG%"
echo [%time%] Khoi dong lai backend + frontend >> "%LOG%"
call "%~dp0restart-app.bat"
echo [%time%] DONE >> "%LOG%"
