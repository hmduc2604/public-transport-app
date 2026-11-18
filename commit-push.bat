@echo off
cd /d "%~dp0"
(
git add -A -- . ":(exclude)git-status.bat"
git commit -m "Bo sung 30 dia diem (tong 50) va anh cho tat ca dia diem" -m "- 30 dia diem moi (database/12_more_attractions.sql, 13_more_attractions_2.sql): toa do OpenStreetMap, tram gan tinh bang duong di bo OSRM, thong tin nhanh, moc lich su, kinh nghiem tham quan, anh Wikimedia Commons" -m "- Anh cho cac dia diem con thieu / it anh (14_more_photos.sql); Lotte Mall Tay Ho va Bao tang Thien nhien Viet Nam dung anh nhom suu tam (15, 16, 17_*.sql); nguon tung anh ghi trong CREDITS.md" -m "- Trang chi tiet: ghi nguon anh dai dien ca khi chua co bo suu tap, nen icon loai dia diem khi chua co anh; icon cho loai Cong vien, Vui choi, Mua sam va icon rieng cho nha tho" -m "- Tro ly AI hieu ten goi quen thuoc cua dia diem moi (Cot co, Ky dai, ho B52, 87 Ma May...); Gemini tu thu lai mot lan khi may chu qua tai (503)" -m "- upgrade-db.bat chay them 12 -> 17; 02_seed.sql gop du lieu moi (muc 10b - 10g); api-test.bat 98 test" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGKpE8JTKrR2HbKYqSL"
git push origin main
echo EXIT=%errorlevel%
git log --oneline -2
git status -sb
) > git.log 2>&1
