@echo off
cd /d "%~dp0"
(
git add -A
git commit -m "Them anh that cho 20 dia diem tham quan (Wikimedia Commons)" -m "- 20 anh giay phep tu do (CC0 / Public domain / CC BY / CC BY-SA), luu tai frontend/public/images/attractions, kem CREDITS.md" -m "- Cot moi ImageCredit, ImageSourceUrl (01_database, 02_seed, 05_attraction_images.sql cho DB dang chay); trang chi tiet hien tac gia / giay phep duoi anh" -m "- download-images.bat, upgrade-db.bat; admin sua duoc nguon anh" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGJ7xvGnQ4NAPuHrPau"
git push origin main
echo EXIT=%errorlevel%
git log --oneline -2
git status -sb
) > git.log 2>&1
