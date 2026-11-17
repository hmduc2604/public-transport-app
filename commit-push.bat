@echo off
cd /d "%~dp0"
(
git add -A
git commit -m "Them chuc nang AI (Gemini): tro ly lap lo trinh tieng Viet va goi y dia diem theo so thich" -m "- Tro ly AI (/assistant): Gemini function calling goi bo tim duong, du lieu dia diem, bang gia ve cua he thong; the lo trinh mo tren ban do, the dia diem, nhap bang giong noi, nho ngu canh" -m "- plan_itinerary: lich trinh nhieu diem tinh noi tiep tung chang, canh bao noi da dong cua, gio mat troi moc / lan (utils/sun.ts)" -m "- Goi y theo so thich (GET /attractions/suggestions): vector gemini-embedding-001 + lich su quan tam (AttractionEmbeddings, AttractionViews - database/11_ai_features.sql)" -m "- Tu chuyen model khi Gemini qua tai / het luot mien phi; khoa API chi nam trong backend/.env.local (khong dua len git)" -m "- Sua toa do Ho Tay (giua long ho -> bo ho duong Thanh Nien): tim duong toi Ho Tay tu 133 phut con 20 phut" -m "- Backend ghi log uncaughtException va tung luot goi cong cu AI; api-test.bat 98 test, dua lich su quan tam tai khoan demo ve mau" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01TWMGGKpE8JTKrR2HbKYqSL"
git push origin main
echo EXIT=%errorlevel%
git log --oneline -2
git status -sb
) > git.log 2>&1
