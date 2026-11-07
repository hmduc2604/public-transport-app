@echo off
cd /d "%~dp0"
(
git reset --soft origin/main
git add -A
git commit -m "Dang ky co ma xac nhan that qua Email hoac SMS, dang nhap bang email/SDT" -m "- Dang ky 2 buoc: chon nhan ma 6 so qua Email (SMTP/nodemailer) hoac SMS (Twilio / eSMS / SpeedSMS); nhap dung ma moi tao tai khoan trong Users" -m "- Bang VerificationCodes (chi luu hash ma), cot EmailVerifiedAt/PhoneVerifiedAt, unique index SDT; 07_auth_verification.sql" -m "- Het han 5 phut, sai toi da 5 lan, gui lai sau 60s, toi da 5 ma/gio; chua cau hinh -> bao loi 503 ro rang" -m "- Dang nhap bang email hoac so dien thoai; cau hinh bi mat trong backend/.env.local (khong day len GitHub)" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGJ7xvGnQ4NAPuHrPau"
git push origin main
echo EXIT=%errorlevel%
git log --oneline -2
git status -sb
) > git.log 2>&1
