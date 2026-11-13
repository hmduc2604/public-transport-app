@echo off
cd /d "%~dp0"
(
git add -A
git commit -m "Trang chi tiet dia diem day du hon, sua anh va kiem tra do on dinh" -m "- Anh: thay 5 anh dai dien va cac anh bo suu tap sai chu the / mo / trung, them anh cho Hoa Lo va Ba Dinh, sua 14 chu thich; CREDITS.md sinh lai tu database" -m "- Trang chi tiet: thong tin nhanh va moc lich su cho ca 20 dia diem, tram gan kem cac tuyen dung, dia diem lan can, thanh muc luc dinh, nut chia se, icon SVG (database/10_attraction_guide.sql)" -m "- Sua giao dien chi tiet lo trinh bi vo (trung ten class timeline voi trang dia diem)" -m "- Icon: loai dia diem, xe dien, tieu chi it di bo" -m "- Backend: bat loi connection pool va Promise bi tu choi de backend khong dung; stability-test.bat (tai dong thoi, tat SQL Server 10 giay)" -m "- Test: 86 test API; api-test.bat tu don tram / tuyen thu (database/99_cleanup_test_data.sql)" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGKpE8JTKrR2HbKYqSL"
git push origin main
echo EXIT=%errorlevel%
git log --oneline -2
git status -sb
) > git.log 2>&1
