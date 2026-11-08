@echo off
cd /d "%~dp0"
(
git add -A
git commit -m "Yeu cau dang nhap khi xem chi tiet dia diem va chi duong" -m "- Component LoginRequired: chua dang nhap -> thong bao kem nut Dang nhap / Dang ky; dang nhap xong quay lai dung trang" -m "- Ap dung cho /attractions/:id va /map; trang chu, danh sach Kham pha van xem duoc khi chua dang nhap" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGJ7xvGnQ4NAPuHrPau"
git push origin main
echo EXIT=%errorlevel%
git log --oneline -2
git status -sb
) > git.log 2>&1
