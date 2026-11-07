@echo off
setlocal EnableExtensions
cd /d "%~dp0"
rem Tai anh 20 diem tham quan tu Wikimedia Commons vao frontend\public\images\attractions
set "DIR=%~dp0frontend\public\images\attractions"
set "LOG=%~dp0download-images.log"
if not exist "%DIR%" mkdir "%DIR%"
echo [%time%] START > "%LOG%"
set /a FAIL=0
if not exist "%DIR%\01-ho-hoan-kiem.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\01-ho-hoan-kiem.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Hoan_Kiem_10082026.jpg/1280px-Hoan_Kiem_10082026.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 01-ho-hoan-kiem.jpg >> "%LOG%") else (echo OK 01-ho-hoan-kiem.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\02-den-ngoc-son.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\02-den-ngoc-son.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/C%%E1%%BB%%95ng_%%C4%%91%%E1%%BB%%81n_Ng%%E1%%BB%%8Dc_S%%C6%%A1n.jpg/1280px-C%%E1%%BB%%95ng_%%C4%%91%%E1%%BB%%81n_Ng%%E1%%BB%%8Dc_S%%C6%%A1n.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 02-den-ngoc-son.jpg >> "%LOG%") else (echo OK 02-den-ngoc-son.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\03-pho-co-ha-noi.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\03-pho-co-ha-noi.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Hanoi_shophouse_2.jpg/1280px-Hanoi_shophouse_2.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 03-pho-co-ha-noi.jpg >> "%LOG%") else (echo OK 03-pho-co-ha-noi.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\04-cho-dong-xuan.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\04-cho-dong-xuan.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Ch%%E1%%BB%%A3_%%C4%%90%%E1%%BB%%93ng_Xu%%C3%%A2n_-_NKS.jpg/1280px-Ch%%E1%%BB%%A3_%%C4%%90%%E1%%BB%%93ng_Xu%%C3%%A2n_-_NKS.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 04-cho-dong-xuan.jpg >> "%LOG%") else (echo OK 04-cho-dong-xuan.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\05-nha-hat-lon.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\05-nha-hat-lon.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Hanoi_Opera_House_1.jpg/1280px-Hanoi_Opera_House_1.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 05-nha-hat-lon.jpg >> "%LOG%") else (echo OK 05-nha-hat-lon.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\06-nha-tu-hoa-lo.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\06-nha-tu-hoa-lo.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Ho%%E1%%BA%%A3_L%%C3%%B2.jpg/1280px-Ho%%E1%%BA%%A3_L%%C3%%B2.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 06-nha-tu-hoa-lo.jpg >> "%LOG%") else (echo OK 06-nha-tu-hoa-lo.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\07-hoang-thanh-thang-long.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\07-hoang-thanh-thang-long.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Doan_Mon_Gate_1.jpg/1280px-Doan_Mon_Gate_1.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 07-hoang-thanh-thang-long.jpg >> "%LOG%") else (echo OK 07-hoang-thanh-thang-long.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\08-lang-chu-tich-ho-chi-minh.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\08-lang-chu-tich-ho-chi-minh.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/L%%C4%%83ng_B%%C3%%A1c_-_NKS.jpg/1280px-L%%C4%%83ng_B%%C3%%A1c_-_NKS.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 08-lang-chu-tich-ho-chi-minh.jpg >> "%LOG%") else (echo OK 08-lang-chu-tich-ho-chi-minh.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\09-quang-truong-ba-dinh.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\09-quang-truong-ba-dinh.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Hanoi%%2C_Vietnam%%2C_Ba_Dinh_Square.jpg/1280px-Hanoi%%2C_Vietnam%%2C_Ba_Dinh_Square.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 09-quang-truong-ba-dinh.jpg >> "%LOG%") else (echo OK 09-quang-truong-ba-dinh.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\10-chua-mot-cot.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\10-chua-mot-cot.jpg" "https://upload.wikimedia.org/wikipedia/commons/9/90/One_Pillar_Pagoda_Hanoi.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 10-chua-mot-cot.jpg >> "%LOG%") else (echo OK 10-chua-mot-cot.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\11-van-mieu-quoc-tu-giam.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\11-van-mieu-quoc-tu-giam.jpg" "https://upload.wikimedia.org/wikipedia/commons/a/a6/Khue_Van_Cac_2024.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 11-van-mieu-quoc-tu-giam.jpg >> "%LOG%") else (echo OK 11-van-mieu-quoc-tu-giam.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\12-bao-tang-my-thuat.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\12-bao-tang-my-thuat.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Vietnam_National_Museum_of_Fine_Arts_01.JPG/1280px-Vietnam_National_Museum_of_Fine_Arts_01.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 12-bao-tang-my-thuat.jpg >> "%LOG%") else (echo OK 12-bao-tang-my-thuat.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\13-bao-tang-lich-su-quoc-gia.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\13-bao-tang-lich-su-quoc-gia.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/4G4A7248A_HDR.jpg/1280px-4G4A7248A_HDR.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 13-bao-tang-lich-su-quoc-gia.jpg >> "%LOG%") else (echo OK 13-bao-tang-lich-su-quoc-gia.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\14-bao-tang-dan-toc-hoc.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\14-bao-tang-dan-toc-hoc.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Dan_toc_hoc_1.jpg/1280px-Dan_toc_hoc_1.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 14-bao-tang-dan-toc-hoc.jpg >> "%LOG%") else (echo OK 14-bao-tang-dan-toc-hoc.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\15-ho-tay.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\15-ho-tay.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/H%%E1%%BB%%93_T%%C3%%A2y_ho%%C3%%A0ng_h%%C3%%B4n_-_NKS.jpg/1280px-H%%E1%%BB%%93_T%%C3%%A2y_ho%%C3%%A0ng_h%%C3%%B4n_-_NKS.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 15-ho-tay.jpg >> "%LOG%") else (echo OK 15-ho-tay.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\16-chua-tran-quoc.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\16-chua-tran-quoc.jpg" "https://upload.wikimedia.org/wikipedia/commons/e/e5/Ch%%C3%%B9a_Tr%%E1%%BA%%A5n_Qu%%E1%%BB%%91c%%2C_H%%C3%%A0_N%%E1%%BB%%99i.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 16-chua-tran-quoc.jpg >> "%LOG%") else (echo OK 16-chua-tran-quoc.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\17-pho-ta-hien.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\17-pho-ta-hien.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/T%%E1%%BA%%A1_Hi%%E1%%BB%%87n_Street%%2C_Hanoi.jpg/1280px-T%%E1%%BA%%A1_Hi%%E1%%BB%%87n_Street%%2C_Hanoi.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 17-pho-ta-hien.jpg >> "%LOG%") else (echo OK 17-pho-ta-hien.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\18-pho-sach-ha-noi.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\18-pho-sach-ha-noi.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Newone_-_ph%%E1%%BB%%91_s%%C3%%A1ch_19_th%%C3%%A1ng_12.jpg/1280px-Newone_-_ph%%E1%%BB%%91_s%%C3%%A1ch_19_th%%C3%%A1ng_12.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 18-pho-sach-ha-noi.jpg >> "%LOG%") else (echo OK 18-pho-sach-ha-noi.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\19-cau-long-bien.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\19-cau-long-bien.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Long_bien_bridge.jpg/1280px-Long_bien_bridge.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 19-cau-long-bien.jpg >> "%LOG%") else (echo OK 19-cau-long-bien.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
if not exist "%DIR%\20-nha-hat-mua-roi-thang-long.jpg" (
  curl -sS -L --fail --retry 3 --retry-delay 2 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\20-nha-hat-mua-roi-thang-long.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Hanoi_Vietnam_Thang-Long-Water-Puppet-Theatre-01.jpg/1280px-Hanoi_Vietnam_Thang-Long-Water-Puppet-Theatre-01.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 20-nha-hat-mua-roi-thang-long.jpg >> "%LOG%") else (echo OK 20-nha-hat-mua-roi-thang-long.jpg >> "%LOG%")
  timeout /t 1 /nobreak >nul
)
echo [%time%] XONG - loi: %FAIL% >> "%LOG%"
type "%LOG%"
timeout /t 5
exit /b %FAIL%
