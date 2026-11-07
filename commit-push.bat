@echo off
cd /d "%~dp0"
(
git add -A
git commit -m "Chi duong theo duong pho that (OSRM) + xep hang theo tieu chi" -m "- Quang duong di bo thuc te (OSRM table) dua vao Dijkstra; ve lai tung buoc theo duong pho: di bo, xe dap/xe dien, xe buyt qua cac tram" -m "- Tinh lai thoi gian / di bo roi xep hang lai theo tieu chi Nhanh nhat / Re nhat / It di bo / It chuyen tuyen; uu tien phuong an khac han nhau" -m "- osrm-setup.bat: may chu OSRM tren may (Docker, ban do Ha Noi) cho di bo :5001, xe dap :5002, o to :5003; du phong routing.openstreetmap.de" -m "- Giao dien bao ro khi phai ve duong thang; api-test dung ma test khong trung" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGJ7xvGnQ4NAPuHrPau"
git push origin main
echo EXIT=%errorlevel%
git log --oneline -2
git status -sb
) > git.log 2>&1
