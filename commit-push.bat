@echo off
cd /d "%~dp0"
(
git add -A
git commit -m "Thanh toan: the ngan hang va chuyen khoan QR (bo vi dien tu)" -m "- Trang thanh toan the: the quoc te (so the Luhn, ten, han, CVV) va ATM noi dia NAPAS (ngan hang, so the, ngay phat hanh); chi luu hang the + 4 so cuoi" -m "- Chuyen khoan: tao ma VietQR (Napas 247) co so tien + noi dung rieng tung don; giao dich PENDING, ve chi phat hanh khi admin xac nhan da nhan tien hoac webhook SePay" -m "- Admin > Thanh toan: tai khoan nhan tien, doi soat xac nhan / tu choi; 08_payment_methods.sql" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGJ7xvGnQ4NAPuHrPau"
git push origin main
echo EXIT=%errorlevel%
git log --oneline -2
git status -sb
) > git.log 2>&1
