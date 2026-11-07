@echo off
cd /d "%~dp0"
(
git add -A
git commit -m "Cap nhat vi tri tram that: bus (Vinpearl + OSM), Metro 2A/3.1 (metrohanoi.vn), xe dap/xe dien TNGo" -m "- 453 diem dung cua 20 tuyen buyt, thu tu va khoang cach doc duong tu OpenStreetMap; gia ve bus 7.000d" -m "- 20 ga Metro 2A va 3.1 theo toa do chinh thuc; gia theo quang duong 8.000-15.000d (mo phong)" -m "- 49 tram xe dap TNGo theo bai dantocphattrien.vietnamnet.vn, 49 tram xe dien cung vi tri; bo tuyen co dinh xe dap/xe dien" -m "- Routing: moi loai phuong tien luon co tram gan nhat lam ung vien; ban do gop marker xe dap + xe dien" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGJ7xvGnQ4NAPuHrPau"
git push origin main
echo EXIT=%errorlevel%
git log --oneline -2
git status -sb
) > git.log 2>&1
