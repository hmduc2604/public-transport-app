@echo off
setlocal
cd /d "%~dp0"
rem Kiem tra do on dinh backend: chiu tai dong thoi + mat ket noi database (tam dung SQL Server 10 giay).
rem Can backend dang chay (run-all.bat). Ket qua o stability-test.log
set "LOG=%~dp0stability-test.log"
echo [%date% %time%] START > "%LOG%"
node stability-test.js >> "%LOG%" 2>&1
echo [%date% %time%] DONE >> "%LOG%"
