@echo off
cd /d "%~dp0"
(
git add -A
git commit -m "Dia diem: thong tin chi tiet, anh dau trang phu kin, bo suu tap anh" -m "- 20 dia diem: gioi thieu, lich su, diem noi bat, gio mo cua, gia ve (tra cuu 11/2026), thoi gian tham quan, thoi diem dep, luu y" -m "- The Kham pha hien dia chi, gio mo cua, thoi gian tham quan, gia ve, so anh" -m "- Trang chi tiet: anh phu kin dau trang, bo chu thich duoi anh, thong tin nhanh, bo suu tap 97 anh Wikimedia Commons + lightbox; nguon anh thu gon cuoi trang" -m "- Bang AttractionImages, cot moi HoursSummary/PriceFrom/VisitDuration/BestTime/Tips; 06_attraction_details.sql; admin sua duoc bo suu tap" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGJ7xvGnQ4NAPuHrPau"
git push origin main
echo EXIT=%errorlevel%
git log --oneline -2
git status -sb
) > git.log 2>&1
