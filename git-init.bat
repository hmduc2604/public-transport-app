@echo off
cd /d "%~dp0"
(
if not exist .git git init -b main
git add -A
git -c core.autocrlf=true commit -m "Initial commit: HanoiGo - he thong tim lo trinh giao thong cong cong da phuong thuc" -m "Database (SQL Server), Backend (Express + TS), Frontend (React + Leaflet), scripts chay nhanh." -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGJ7xvGnQ4NAPuHrPau"
git log --oneline -1
git ls-files | find /c /v ""
git ls-files | findstr /I "env node_modules .log"
echo === DONE
) > git.log 2>&1
