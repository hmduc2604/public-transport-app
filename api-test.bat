@echo off
setlocal EnableExtensions
cd /d "%~dp0"
rem Chay bo test API (can backend dang chay). Ket qua o api-test.log
node api-test.js > api-test.log 2>&1
set "TEST_EXIT=%errorlevel%"
rem Don tram / tuyen thu (BUS-TEST, BUSTEST) do test tao ra - chi khi dung SQL Server trong Docker (pta-sql)
set "HAS_SQL="
for /f %%i in ('docker ps -q -f name^=pta-sql 2^>nul') do set "HAS_SQL=1"
if defined HAS_SQL (
  docker cp "%~dp0database\99_cleanup_test_data.sql" pta-sql:/tmp/99_cleanup_test_data.sql >nul 2>&1
  docker exec pta-sql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Pta@Strong2026" -C -f 65001 -b -i /tmp/99_cleanup_test_data.sql >> api-test.log 2>&1
)
exit /b %TEST_EXIT%
