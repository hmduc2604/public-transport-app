@echo off
cd /d "%~dp0"
node api-test.js > api-test.log 2>&1
