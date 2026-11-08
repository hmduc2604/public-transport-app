@echo off
cd /d "%~dp0"
(
git add -A
git commit -m "Kiem tra tong the: sua loi backend, bao mat, du lieu va cap nhat thu vien" -m "- Backend: sort/id/ho ten rong/QR la khong con loi 500; toa do ngoai Ha Noi va gio sai bi tu choi; chuyen phai hop ly va xe khong trung lich" -m "- Bao mat: token cua tai khoan bi khoa mat hieu luc ngay; gioi han dang nhap sai / gui ma (429); khoa JWT ngau nhien moi may" -m "- Database: 09_data_fixes.sql - doi xe theo tuyen (0 chuyen trung gio), index cho khoa ngoai" -m "- Thu vien: nodemailer 10, react-router-dom 7 (npm audit 0 lo hong); frontend khong dang xuat khi mat ket noi; 78 test API" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGJ7xvGnQ4NAPuHrPau"
git push origin main
echo EXIT=%errorlevel%
git log --oneline -2
git status -sb
) > git.log 2>&1
