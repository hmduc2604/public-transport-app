@echo off
cd /d "%~dp0backend"
echo [%time%] npm install backend > "%~dp0install-deps.log"
call npm install --no-audit --no-fund >> "%~dp0install-deps.log" 2>&1
echo EXIT=%errorlevel% >> "%~dp0install-deps.log"
