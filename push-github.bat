@echo off
cd /d "%~dp0"
set "REPO=https://github.com/hmduc2604/public-transport-app.git"
echo Dang day project len %REPO% ...
(
if not exist .git git init -b main
git add -A
git -c core.autocrlf=true commit -m "Initial commit: HanoiGo - he thong tim lo trinh giao thong cong cong da phuong thuc" -m "Database (SQL Server), Backend (Express + TS), Frontend (React + Leaflet), scripts chay nhanh." -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGJ7xvGnQ4NAPuHrPau"
git remote remove origin
git remote add origin %REPO%
git push -u origin main
echo EXIT=%errorlevel%
git ls-files | find /c /v ""
) > git.log 2>&1
type git.log
pause
