@echo off
cd /d "%~dp0"
echo Dang push len https://github.com/hmduc2604/public-transport-app
echo Neu hien cua so dang nhap GitHub, hay dang nhap bang tai khoan hmduc2604.
(
git remote remove origin
git remote add origin https://hmduc2604@github.com/hmduc2604/public-transport-app.git
git push -u origin main
echo EXIT=%errorlevel%
git status -sb
) > git.log 2>&1
type git.log
timeout /t 15
