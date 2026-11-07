@echo off
setlocal EnableExtensions
cd /d "%~dp0"
rem Tai anh dia diem tham quan tu Wikimedia Commons (anh dai dien + bo suu tap)
rem Chi tai file chua co. Anh: frontend\public\images\attractions (dai dien) va ...\gallery (bo suu tap)
set "DIR=%~dp0frontend\public\images\attractions"
set "GDIR=%DIR%\gallery"
set "LOG=%~dp0download-images.log"
if not exist "%DIR%" mkdir "%DIR%"
if not exist "%GDIR%" mkdir "%GDIR%"
echo [%time%] START > "%LOG%"
set /a FAIL=0
if not exist "%DIR%\01-ho-hoan-kiem.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\01-ho-hoan-kiem.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Hoan_Kiem_10082026.jpg/1280px-Hoan_Kiem_10082026.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 01-ho-hoan-kiem.jpg >> "%LOG%") else (echo OK 01-ho-hoan-kiem.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\02-den-ngoc-son.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\02-den-ngoc-son.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/C%%E1%%BB%%95ng_%%C4%%91%%E1%%BB%%81n_Ng%%E1%%BB%%8Dc_S%%C6%%A1n.jpg/1280px-C%%E1%%BB%%95ng_%%C4%%91%%E1%%BB%%81n_Ng%%E1%%BB%%8Dc_S%%C6%%A1n.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 02-den-ngoc-son.jpg >> "%LOG%") else (echo OK 02-den-ngoc-son.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\03-pho-co-ha-noi.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\03-pho-co-ha-noi.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Hanoi_shophouse_2.jpg/1280px-Hanoi_shophouse_2.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 03-pho-co-ha-noi.jpg >> "%LOG%") else (echo OK 03-pho-co-ha-noi.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\04-cho-dong-xuan.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\04-cho-dong-xuan.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Ch%%E1%%BB%%A3_%%C4%%90%%E1%%BB%%93ng_Xu%%C3%%A2n_-_NKS.jpg/1280px-Ch%%E1%%BB%%A3_%%C4%%90%%E1%%BB%%93ng_Xu%%C3%%A2n_-_NKS.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 04-cho-dong-xuan.jpg >> "%LOG%") else (echo OK 04-cho-dong-xuan.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\05-nha-hat-lon.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\05-nha-hat-lon.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Hanoi_Opera_House_1.jpg/1280px-Hanoi_Opera_House_1.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 05-nha-hat-lon.jpg >> "%LOG%") else (echo OK 05-nha-hat-lon.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\06-nha-tu-hoa-lo.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\06-nha-tu-hoa-lo.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Ho%%E1%%BA%%A3_L%%C3%%B2.jpg/1280px-Ho%%E1%%BA%%A3_L%%C3%%B2.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 06-nha-tu-hoa-lo.jpg >> "%LOG%") else (echo OK 06-nha-tu-hoa-lo.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\07-hoang-thanh-thang-long.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\07-hoang-thanh-thang-long.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Doan_Mon_Gate_1.jpg/1280px-Doan_Mon_Gate_1.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 07-hoang-thanh-thang-long.jpg >> "%LOG%") else (echo OK 07-hoang-thanh-thang-long.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\08-lang-chu-tich-ho-chi-minh.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\08-lang-chu-tich-ho-chi-minh.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/L%%C4%%83ng_B%%C3%%A1c_-_NKS.jpg/1280px-L%%C4%%83ng_B%%C3%%A1c_-_NKS.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 08-lang-chu-tich-ho-chi-minh.jpg >> "%LOG%") else (echo OK 08-lang-chu-tich-ho-chi-minh.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\09-quang-truong-ba-dinh.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\09-quang-truong-ba-dinh.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Hanoi%%2C_Vietnam%%2C_Ba_Dinh_Square.jpg/1280px-Hanoi%%2C_Vietnam%%2C_Ba_Dinh_Square.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 09-quang-truong-ba-dinh.jpg >> "%LOG%") else (echo OK 09-quang-truong-ba-dinh.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\10-chua-mot-cot.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\10-chua-mot-cot.jpg" "https://upload.wikimedia.org/wikipedia/commons/9/90/One_Pillar_Pagoda_Hanoi.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 10-chua-mot-cot.jpg >> "%LOG%") else (echo OK 10-chua-mot-cot.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\11-van-mieu-quoc-tu-giam.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\11-van-mieu-quoc-tu-giam.jpg" "https://upload.wikimedia.org/wikipedia/commons/a/a6/Khue_Van_Cac_2024.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 11-van-mieu-quoc-tu-giam.jpg >> "%LOG%") else (echo OK 11-van-mieu-quoc-tu-giam.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\12-bao-tang-my-thuat.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\12-bao-tang-my-thuat.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Vietnam_National_Museum_of_Fine_Arts_01.JPG/1280px-Vietnam_National_Museum_of_Fine_Arts_01.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 12-bao-tang-my-thuat.jpg >> "%LOG%") else (echo OK 12-bao-tang-my-thuat.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\13-bao-tang-lich-su-quoc-gia.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\13-bao-tang-lich-su-quoc-gia.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/4G4A7248A_HDR.jpg/1280px-4G4A7248A_HDR.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 13-bao-tang-lich-su-quoc-gia.jpg >> "%LOG%") else (echo OK 13-bao-tang-lich-su-quoc-gia.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\14-bao-tang-dan-toc-hoc.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\14-bao-tang-dan-toc-hoc.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Dan_toc_hoc_1.jpg/1280px-Dan_toc_hoc_1.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 14-bao-tang-dan-toc-hoc.jpg >> "%LOG%") else (echo OK 14-bao-tang-dan-toc-hoc.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\15-ho-tay.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\15-ho-tay.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/H%%E1%%BB%%93_T%%C3%%A2y_ho%%C3%%A0ng_h%%C3%%B4n_-_NKS.jpg/1280px-H%%E1%%BB%%93_T%%C3%%A2y_ho%%C3%%A0ng_h%%C3%%B4n_-_NKS.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 15-ho-tay.jpg >> "%LOG%") else (echo OK 15-ho-tay.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\16-chua-tran-quoc.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\16-chua-tran-quoc.jpg" "https://upload.wikimedia.org/wikipedia/commons/e/e5/Ch%%C3%%B9a_Tr%%E1%%BA%%A5n_Qu%%E1%%BB%%91c%%2C_H%%C3%%A0_N%%E1%%BB%%99i.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 16-chua-tran-quoc.jpg >> "%LOG%") else (echo OK 16-chua-tran-quoc.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\17-pho-ta-hien.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\17-pho-ta-hien.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/T%%E1%%BA%%A1_Hi%%E1%%BB%%87n_Street%%2C_Hanoi.jpg/1280px-T%%E1%%BA%%A1_Hi%%E1%%BB%%87n_Street%%2C_Hanoi.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 17-pho-ta-hien.jpg >> "%LOG%") else (echo OK 17-pho-ta-hien.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\18-pho-sach-ha-noi.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\18-pho-sach-ha-noi.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Newone_-_ph%%E1%%BB%%91_s%%C3%%A1ch_19_th%%C3%%A1ng_12.jpg/1280px-Newone_-_ph%%E1%%BB%%91_s%%C3%%A1ch_19_th%%C3%%A1ng_12.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 18-pho-sach-ha-noi.jpg >> "%LOG%") else (echo OK 18-pho-sach-ha-noi.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\19-cau-long-bien.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\19-cau-long-bien.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Long_bien_bridge.jpg/1280px-Long_bien_bridge.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 19-cau-long-bien.jpg >> "%LOG%") else (echo OK 19-cau-long-bien.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%DIR%\20-nha-hat-mua-roi-thang-long.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%DIR%\20-nha-hat-mua-roi-thang-long.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Hanoi_Vietnam_Thang-Long-Water-Puppet-Theatre-01.jpg/1280px-Hanoi_Vietnam_Thang-Long-Water-Puppet-Theatre-01.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 20-nha-hat-mua-roi-thang-long.jpg >> "%LOG%") else (echo OK 20-nha-hat-mua-roi-thang-long.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\01-ho-hoan-kiem-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\01-ho-hoan-kiem-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Hoan_Kiem%%2C_Hanoi_%%2844478561440%%29.jpg/960px-Hoan_Kiem%%2C_Hanoi_%%2844478561440%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 01-ho-hoan-kiem-1.jpg >> "%LOG%") else (echo OK 01-ho-hoan-kiem-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\01-ho-hoan-kiem-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\01-ho-hoan-kiem-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Ho_Hoan_Kiem_%%2813574475044%%29.jpg/960px-Ho_Hoan_Kiem_%%2813574475044%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 01-ho-hoan-kiem-2.jpg >> "%LOG%") else (echo OK 01-ho-hoan-kiem-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\01-ho-hoan-kiem-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\01-ho-hoan-kiem-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Angler_at_Hoan_Kiem_Lake.jpg/960px-Angler_at_Hoan_Kiem_Lake.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 01-ho-hoan-kiem-3.jpg >> "%LOG%") else (echo OK 01-ho-hoan-kiem-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\01-ho-hoan-kiem-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\01-ho-hoan-kiem-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Ho_Hoan_Kiem_%%2812313745773%%29.jpg/960px-Ho_Hoan_Kiem_%%2812313745773%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 01-ho-hoan-kiem-4.jpg >> "%LOG%") else (echo OK 01-ho-hoan-kiem-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\01-ho-hoan-kiem-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\01-ho-hoan-kiem-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/20190923_164624lake_park_in_h%%C3%%A0_n%%E1%%BB%%99i.jpg/960px-20190923_164624lake_park_in_h%%C3%%A0_n%%E1%%BB%%99i.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 01-ho-hoan-kiem-5.jpg >> "%LOG%") else (echo OK 01-ho-hoan-kiem-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\02-den-ngoc-son-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\02-den-ngoc-son-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Hanoi_-_Ngoc_Son_Temple.jpg/960px-Hanoi_-_Ngoc_Son_Temple.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 02-den-ngoc-son-1.jpg >> "%LOG%") else (echo OK 02-den-ngoc-son-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\02-den-ngoc-son-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\02-den-ngoc-son-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Hanoi%%2C_Vietnam_%%2812042291376%%29.jpg/960px-Hanoi%%2C_Vietnam_%%2812042291376%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 02-den-ngoc-son-2.jpg >> "%LOG%") else (echo OK 02-den-ngoc-son-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\02-den-ngoc-son-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\02-den-ngoc-son-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Den_Ngoc_Son_shrine_%%2838457884970%%29.jpg/960px-Den_Ngoc_Son_shrine_%%2838457884970%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 02-den-ngoc-son-3.jpg >> "%LOG%") else (echo OK 02-den-ngoc-son-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\02-den-ngoc-son-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\02-den-ngoc-son-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/019Jadebergtempel_innen.jpg/960px-019Jadebergtempel_innen.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 02-den-ngoc-son-4.jpg >> "%LOG%") else (echo OK 02-den-ngoc-son-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\02-den-ngoc-son-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\02-den-ngoc-son-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/ICHanoiNgocSon1.jpg/960px-ICHanoiNgocSon1.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 02-den-ngoc-son-5.jpg >> "%LOG%") else (echo OK 02-den-ngoc-son-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\03-pho-co-ha-noi-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\03-pho-co-ha-noi-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Old_Quarter%%2C_Hanoi%%2C_Vietnam_%%285246284208%%29.jpg/960px-Old_Quarter%%2C_Hanoi%%2C_Vietnam_%%285246284208%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 03-pho-co-ha-noi-1.jpg >> "%LOG%") else (echo OK 03-pho-co-ha-noi-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\03-pho-co-ha-noi-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\03-pho-co-ha-noi-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Old_Quarter%%2C_Hanoi_-_panoramio.jpg/960px-Old_Quarter%%2C_Hanoi_-_panoramio.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 03-pho-co-ha-noi-2.jpg >> "%LOG%") else (echo OK 03-pho-co-ha-noi-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\03-pho-co-ha-noi-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\03-pho-co-ha-noi-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Old_Quarter_street_scene%%2C_Hanoi_%%282%%29_%%2838496798321%%29.jpg/960px-Old_Quarter_street_scene%%2C_Hanoi_%%282%%29_%%2838496798321%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 03-pho-co-ha-noi-3.jpg >> "%LOG%") else (echo OK 03-pho-co-ha-noi-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\03-pho-co-ha-noi-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\03-pho-co-ha-noi-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Old_Quarter_street_scene%%2C_Hanoi_%%283%%29_%%2838464656402%%29.jpg/960px-Old_Quarter_street_scene%%2C_Hanoi_%%283%%29_%%2838464656402%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 03-pho-co-ha-noi-4.jpg >> "%LOG%") else (echo OK 03-pho-co-ha-noi-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\03-pho-co-ha-noi-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\03-pho-co-ha-noi-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Old_Quarter%%2C_Hanoi%%2C_Vietnam_%%285246306092%%29.jpg/960px-Old_Quarter%%2C_Hanoi%%2C_Vietnam_%%285246306092%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 03-pho-co-ha-noi-5.jpg >> "%LOG%") else (echo OK 03-pho-co-ha-noi-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\04-cho-dong-xuan-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\04-cho-dong-xuan-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Dong_Xuan_Market_market_in_the_Hanoi_old_quarter_%%2830645886763%%29.jpg/960px-Dong_Xuan_Market_market_in_the_Hanoi_old_quarter_%%2830645886763%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 04-cho-dong-xuan-1.jpg >> "%LOG%") else (echo OK 04-cho-dong-xuan-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\04-cho-dong-xuan-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\04-cho-dong-xuan-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Hanoi_Night_Market_3.jpg/960px-Hanoi_Night_Market_3.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 04-cho-dong-xuan-2.jpg >> "%LOG%") else (echo OK 04-cho-dong-xuan-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\04-cho-dong-xuan-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\04-cho-dong-xuan-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/%%C4%%90%%E1%%BB%%93ng_Xu%%C3%%A2n_Market_6.jpg/960px-%%C4%%90%%E1%%BB%%93ng_Xu%%C3%%A2n_Market_6.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 04-cho-dong-xuan-3.jpg >> "%LOG%") else (echo OK 04-cho-dong-xuan-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\04-cho-dong-xuan-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\04-cho-dong-xuan-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/%%C4%%90%%E1%%BB%%93ng_Xu%%C3%%A2n_Market_2.jpg/960px-%%C4%%90%%E1%%BB%%93ng_Xu%%C3%%A2n_Market_2.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 04-cho-dong-xuan-4.jpg >> "%LOG%") else (echo OK 04-cho-dong-xuan-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\04-cho-dong-xuan-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\04-cho-dong-xuan-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Dong_Xuan_Market_%%2823144327176%%29.jpg/960px-Dong_Xuan_Market_%%2823144327176%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 04-cho-dong-xuan-5.jpg >> "%LOG%") else (echo OK 04-cho-dong-xuan-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\05-nha-hat-lon-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\05-nha-hat-lon-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Hanoi_Opera_House%%2C_1901-11_%%283%%29_%%2837779750014%%29.jpg/960px-Hanoi_Opera_House%%2C_1901-11_%%283%%29_%%2837779750014%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 05-nha-hat-lon-1.jpg >> "%LOG%") else (echo OK 05-nha-hat-lon-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\05-nha-hat-lon-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\05-nha-hat-lon-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Nha_hat_lon_%%2812358211094%%29.jpg/960px-Nha_hat_lon_%%2812358211094%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 05-nha-hat-lon-2.jpg >> "%LOG%") else (echo OK 05-nha-hat-lon-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\05-nha-hat-lon-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\05-nha-hat-lon-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Opera_House%%2C_Hanoi%%2C_Vietnam_%%2836761966601%%29.jpg/960px-Opera_House%%2C_Hanoi%%2C_Vietnam_%%2836761966601%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 05-nha-hat-lon-3.jpg >> "%LOG%") else (echo OK 05-nha-hat-lon-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\05-nha-hat-lon-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\05-nha-hat-lon-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Hanoi_Opera_House_2018.jpg/960px-Hanoi_Opera_House_2018.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 05-nha-hat-lon-4.jpg >> "%LOG%") else (echo OK 05-nha-hat-lon-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\05-nha-hat-lon-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\05-nha-hat-lon-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Nh%%C3%%A0_h%%C3%%A1t_L%%E1%%BB%%9Bn_H%%C3%%A0_N%%E1%%BB%%99i_-_2022-09-02_03.jpg/960px-Nh%%C3%%A0_h%%C3%%A1t_L%%E1%%BB%%9Bn_H%%C3%%A0_N%%E1%%BB%%99i_-_2022-09-02_03.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 05-nha-hat-lon-5.jpg >> "%LOG%") else (echo OK 05-nha-hat-lon-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\06-nha-tu-hoa-lo-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\06-nha-tu-hoa-lo-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Communist_Prisoners_of_the_French%%2C_Hoa_Lo_Prison_%%289754076916%%29.jpg/960px-Communist_Prisoners_of_the_French%%2C_Hoa_Lo_Prison_%%289754076916%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 06-nha-tu-hoa-lo-1.jpg >> "%LOG%") else (echo OK 06-nha-tu-hoa-lo-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\06-nha-tu-hoa-lo-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\06-nha-tu-hoa-lo-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Bunk_Bed_for_American_Prisoners%%2C_Hoa_Lo_Prison_%%289754110835%%29.jpg/960px-Bunk_Bed_for_American_Prisoners%%2C_Hoa_Lo_Prison_%%289754110835%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 06-nha-tu-hoa-lo-2.jpg >> "%LOG%") else (echo OK 06-nha-tu-hoa-lo-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\06-nha-tu-hoa-lo-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\06-nha-tu-hoa-lo-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/American_Prisoners_Leaving_Hoa_Lo_Prison%%2C_1973_%%289754154193%%29.jpg/960px-American_Prisoners_Leaving_Hoa_Lo_Prison%%2C_1973_%%289754154193%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 06-nha-tu-hoa-lo-3.jpg >> "%LOG%") else (echo OK 06-nha-tu-hoa-lo-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\07-hoang-thanh-thang-long-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\07-hoang-thanh-thang-long-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Central_Sector_of_the_Imperial_Citadel_of_Thang_Long_-_Hanoi_%%2826246667851%%29.jpg/960px-Central_Sector_of_the_Imperial_Citadel_of_Thang_Long_-_Hanoi_%%2826246667851%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 07-hoang-thanh-thang-long-1.jpg >> "%LOG%") else (echo OK 07-hoang-thanh-thang-long-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\07-hoang-thanh-thang-long-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\07-hoang-thanh-thang-long-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Central_Sector_of_the_Imperial_Citadel_of_Thang_Long_-_Hanoi.jpg/960px-Central_Sector_of_the_Imperial_Citadel_of_Thang_Long_-_Hanoi.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 07-hoang-thanh-thang-long-2.jpg >> "%LOG%") else (echo OK 07-hoang-thanh-thang-long-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\07-hoang-thanh-thang-long-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\07-hoang-thanh-thang-long-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Citadelle_de_Hano%%C3%%AF_%%281%%29.jpg/960px-Citadelle_de_Hano%%C3%%AF_%%281%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 07-hoang-thanh-thang-long-3.jpg >> "%LOG%") else (echo OK 07-hoang-thanh-thang-long-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\07-hoang-thanh-thang-long-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\07-hoang-thanh-thang-long-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Citadelle_de_Hano%%C3%%AF_%%284%%29.jpg/960px-Citadelle_de_Hano%%C3%%AF_%%284%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 07-hoang-thanh-thang-long-4.jpg >> "%LOG%") else (echo OK 07-hoang-thanh-thang-long-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\07-hoang-thanh-thang-long-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\07-hoang-thanh-thang-long-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/C%%E1%%BB%%95ng_tr%%C3%%A1i_%%C4%%90oan_M%%C3%%B4n%%2C_Ho%%C3%%A0ng_th%%C3%%A0nh_Th%%C4%%83ng_Long%%2C_H%%C3%%A0_N%%E1%%BB%%99i_001.JPG/960px-C%%E1%%BB%%95ng_tr%%C3%%A1i_%%C4%%90oan_M%%C3%%B4n%%2C_Ho%%C3%%A0ng_th%%C3%%A0nh_Th%%C4%%83ng_Long%%2C_H%%C3%%A0_N%%E1%%BB%%99i_001.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 07-hoang-thanh-thang-long-5.jpg >> "%LOG%") else (echo OK 07-hoang-thanh-thang-long-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\08-lang-chu-tich-ho-chi-minh-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\08-lang-chu-tich-ho-chi-minh-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/HCM_Mausoleum-_closed_as_his_preserved_body_wan%%27t_it_%%2831454165115%%29.jpg/960px-HCM_Mausoleum-_closed_as_his_preserved_body_wan%%27t_it_%%2831454165115%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 08-lang-chu-tich-ho-chi-minh-1.jpg >> "%LOG%") else (echo OK 08-lang-chu-tich-ho-chi-minh-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\08-lang-chu-tich-ho-chi-minh-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\08-lang-chu-tich-ho-chi-minh-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/Guards_of_the_Ho_Chi_Minh_Mausoleum.jpg/960px-Guards_of_the_Ho_Chi_Minh_Mausoleum.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 08-lang-chu-tich-ho-chi-minh-2.jpg >> "%LOG%") else (echo OK 08-lang-chu-tich-ho-chi-minh-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\08-lang-chu-tich-ho-chi-minh-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\08-lang-chu-tich-ho-chi-minh-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Hanoi_day_2_%%2842633365842%%29.jpg/960px-Hanoi_day_2_%%2842633365842%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 08-lang-chu-tich-ho-chi-minh-3.jpg >> "%LOG%") else (echo OK 08-lang-chu-tich-ho-chi-minh-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\08-lang-chu-tich-ho-chi-minh-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\08-lang-chu-tich-ho-chi-minh-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Hanoi%%2C_Vietnam_%%2849538245913%%29.jpg/960px-Hanoi%%2C_Vietnam_%%2849538245913%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 08-lang-chu-tich-ho-chi-minh-4.jpg >> "%LOG%") else (echo OK 08-lang-chu-tich-ho-chi-minh-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\08-lang-chu-tich-ho-chi-minh-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\08-lang-chu-tich-ho-chi-minh-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Gardeners_in_the_Ho_Chi_Minh_Mausoleum_-_Vietnam_%%2815860257192%%29.jpg/960px-Gardeners_in_the_Ho_Chi_Minh_Mausoleum_-_Vietnam_%%2815860257192%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 08-lang-chu-tich-ho-chi-minh-5.jpg >> "%LOG%") else (echo OK 08-lang-chu-tich-ho-chi-minh-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\09-quang-truong-ba-dinh-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\09-quang-truong-ba-dinh-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Hanoi%%2C_Vietnam%%2C_Ho_Chi_Minh_Mausoleum_on_Ba_Dinh_Square.jpg/960px-Hanoi%%2C_Vietnam%%2C_Ho_Chi_Minh_Mausoleum_on_Ba_Dinh_Square.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 09-quang-truong-ba-dinh-1.jpg >> "%LOG%") else (echo OK 09-quang-truong-ba-dinh-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\09-quang-truong-ba-dinh-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\09-quang-truong-ba-dinh-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Qu%%E1%%BA%%A3ng_tr%%C6%%B0%%E1%%BB%%9Dng_Ba_%%C4%%90%%C3%%ACnh_v%%E1%%BB%%81_%%C4%%91%%C3%%AAm.JPG/960px-Qu%%E1%%BA%%A3ng_tr%%C6%%B0%%E1%%BB%%9Dng_Ba_%%C4%%90%%C3%%ACnh_v%%E1%%BB%%81_%%C4%%91%%C3%%AAm.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 09-quang-truong-ba-dinh-2.jpg >> "%LOG%") else (echo OK 09-quang-truong-ba-dinh-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\09-quang-truong-ba-dinh-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\09-quang-truong-ba-dinh-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Ba_Dinh_Square%%2C_Hanoi_%%2837609038445%%29.jpg/960px-Ba_Dinh_Square%%2C_Hanoi_%%2837609038445%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 09-quang-truong-ba-dinh-3.jpg >> "%LOG%") else (echo OK 09-quang-truong-ba-dinh-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\09-quang-truong-ba-dinh-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\09-quang-truong-ba-dinh-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Mausoleo_de_Ho_Chi_Minh.JPG/960px-Mausoleo_de_Ho_Chi_Minh.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 09-quang-truong-ba-dinh-4.jpg >> "%LOG%") else (echo OK 09-quang-truong-ba-dinh-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\10-chua-mot-cot-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\10-chua-mot-cot-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Eins%%C3%%A4ulenpagode_Ngoc_Son_Hanoi_%%2839513844382%%29.jpg/960px-Eins%%C3%%A4ulenpagode_Ngoc_Son_Hanoi_%%2839513844382%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 10-chua-mot-cot-1.jpg >> "%LOG%") else (echo OK 10-chua-mot-cot-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\10-chua-mot-cot-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\10-chua-mot-cot-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/Hanoi_-_Hanoi1638.jpg/960px-Hanoi_-_Hanoi1638.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 10-chua-mot-cot-2.jpg >> "%LOG%") else (echo OK 10-chua-mot-cot-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\10-chua-mot-cot-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\10-chua-mot-cot-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/Ch%%C3%%B9a_M%%E1%%BB%%99t_C%%E1%%BB%%99t_5.JPG/960px-Ch%%C3%%B9a_M%%E1%%BB%%99t_C%%E1%%BB%%99t_5.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 10-chua-mot-cot-3.jpg >> "%LOG%") else (echo OK 10-chua-mot-cot-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\10-chua-mot-cot-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\10-chua-mot-cot-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Ch%%C3%%B9a_M%%E1%%BB%%99t_C%%E1%%BB%%99t_4.JPG/960px-Ch%%C3%%B9a_M%%E1%%BB%%99t_C%%E1%%BB%%99t_4.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 10-chua-mot-cot-4.jpg >> "%LOG%") else (echo OK 10-chua-mot-cot-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\10-chua-mot-cot-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\10-chua-mot-cot-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Hanoi%%2C_Vietnam_%%2812041825854%%29.jpg/960px-Hanoi%%2C_Vietnam_%%2812041825854%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 10-chua-mot-cot-5.jpg >> "%LOG%") else (echo OK 10-chua-mot-cot-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\11-van-mieu-quoc-tu-giam-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\11-van-mieu-quoc-tu-giam-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/20220605_Temple_of_Literature%%2C_Hanoi_14.jpg/960px-20220605_Temple_of_Literature%%2C_Hanoi_14.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 11-van-mieu-quoc-tu-giam-1.jpg >> "%LOG%") else (echo OK 11-van-mieu-quoc-tu-giam-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\11-van-mieu-quoc-tu-giam-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\11-van-mieu-quoc-tu-giam-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/20220605_Temple_of_Literature%%2C_Hanoi_16.jpg/960px-20220605_Temple_of_Literature%%2C_Hanoi_16.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 11-van-mieu-quoc-tu-giam-2.jpg >> "%LOG%") else (echo OK 11-van-mieu-quoc-tu-giam-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\11-van-mieu-quoc-tu-giam-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\11-van-mieu-quoc-tu-giam-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/20220605_Temple_of_Literature%%2C_Hanoi_04.jpg/960px-20220605_Temple_of_Literature%%2C_Hanoi_04.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 11-van-mieu-quoc-tu-giam-3.jpg >> "%LOG%") else (echo OK 11-van-mieu-quoc-tu-giam-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\11-van-mieu-quoc-tu-giam-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\11-van-mieu-quoc-tu-giam-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/20220605_Temple_of_Literature%%2C_Hanoi_28.jpg/960px-20220605_Temple_of_Literature%%2C_Hanoi_28.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 11-van-mieu-quoc-tu-giam-4.jpg >> "%LOG%") else (echo OK 11-van-mieu-quoc-tu-giam-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\11-van-mieu-quoc-tu-giam-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\11-van-mieu-quoc-tu-giam-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/20220605_Temple_of_Literature%%2C_Hanoi_24.jpg/960px-20220605_Temple_of_Literature%%2C_Hanoi_24.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 11-van-mieu-quoc-tu-giam-5.jpg >> "%LOG%") else (echo OK 11-van-mieu-quoc-tu-giam-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\12-bao-tang-my-thuat-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\12-bao-tang-my-thuat-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Doors_carved_with_dragon_motifs%%2C_1262%%2C_Museum_of_Fine_Arts%%2C_Hanoi_%%281%%29_%%2824628505508%%29.jpg/960px-Doors_carved_with_dragon_motifs%%2C_1262%%2C_Museum_of_Fine_Arts%%2C_Hanoi_%%281%%29_%%2824628505508%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 12-bao-tang-my-thuat-1.jpg >> "%LOG%") else (echo OK 12-bao-tang-my-thuat-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\12-bao-tang-my-thuat-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\12-bao-tang-my-thuat-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Statue_of_a_duchess%%2C_1632%%2C_Museum_of_Fine_Arts%%2C_Hanoi_%%281%%29_%%2824628273508%%29.jpg/960px-Statue_of_a_duchess%%2C_1632%%2C_Museum_of_Fine_Arts%%2C_Hanoi_%%281%%29_%%2824628273508%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 12-bao-tang-my-thuat-2.jpg >> "%LOG%") else (echo OK 12-bao-tang-my-thuat-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\12-bao-tang-my-thuat-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\12-bao-tang-my-thuat-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Nandi_bull%%2C_8th-9th_cents.%%2C_Museum_of_Fine_Arts%%2C_Hanoi_%%2837785222234%%29.jpg/960px-Nandi_bull%%2C_8th-9th_cents.%%2C_Museum_of_Fine_Arts%%2C_Hanoi_%%2837785222234%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 12-bao-tang-my-thuat-3.jpg >> "%LOG%") else (echo OK 12-bao-tang-my-thuat-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\12-bao-tang-my-thuat-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\12-bao-tang-my-thuat-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Mythological_lion%%2C_early_17th_century%%2C_Museum_of_Fine_Arts%%2C_Hanoi_%%282%%29_%%2838468435862%%29.jpg/960px-Mythological_lion%%2C_early_17th_century%%2C_Museum_of_Fine_Arts%%2C_Hanoi_%%282%%29_%%2838468435862%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 12-bao-tang-my-thuat-4.jpg >> "%LOG%") else (echo OK 12-bao-tang-my-thuat-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\12-bao-tang-my-thuat-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\12-bao-tang-my-thuat-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Kinnari_drumming%%2C_1087%%2C_Museum_of_Fine_Arts%%2C_Hanoi_%%2837613891045%%29.jpg/960px-Kinnari_drumming%%2C_1087%%2C_Museum_of_Fine_Arts%%2C_Hanoi_%%2837613891045%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 12-bao-tang-my-thuat-5.jpg >> "%LOG%") else (echo OK 12-bao-tang-my-thuat-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\13-bao-tang-lich-su-quoc-gia-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\13-bao-tang-lich-su-quoc-gia-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Vietnam_History_Museum_%%289753022072%%29.jpg/960px-Vietnam_History_Museum_%%289753022072%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 13-bao-tang-lich-su-quoc-gia-1.jpg >> "%LOG%") else (echo OK 13-bao-tang-lich-su-quoc-gia-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\13-bao-tang-lich-su-quoc-gia-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\13-bao-tang-lich-su-quoc-gia-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Vietnam_History_Museum_%%289753023741%%29.jpg/960px-Vietnam_History_Museum_%%289753023741%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 13-bao-tang-lich-su-quoc-gia-2.jpg >> "%LOG%") else (echo OK 13-bao-tang-lich-su-quoc-gia-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\13-bao-tang-lich-su-quoc-gia-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\13-bao-tang-lich-su-quoc-gia-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/B%%E1%%BA%%A3o_t%%C3%%A0ng_LSVN.jpg/960px-B%%E1%%BA%%A3o_t%%C3%%A0ng_LSVN.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 13-bao-tang-lich-su-quoc-gia-3.jpg >> "%LOG%") else (echo OK 13-bao-tang-lich-su-quoc-gia-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\13-bao-tang-lich-su-quoc-gia-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\13-bao-tang-lich-su-quoc-gia-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/ThuyenchienDaiViet1.JPG/960px-ThuyenchienDaiViet1.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 13-bao-tang-lich-su-quoc-gia-4.jpg >> "%LOG%") else (echo OK 13-bao-tang-lich-su-quoc-gia-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\13-bao-tang-lich-su-quoc-gia-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\13-bao-tang-lich-su-quoc-gia-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Vietnam_History_Museum_%%289753230575%%29.jpg/960px-Vietnam_History_Museum_%%289753230575%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 13-bao-tang-lich-su-quoc-gia-5.jpg >> "%LOG%") else (echo OK 13-bao-tang-lich-su-quoc-gia-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\14-bao-tang-dan-toc-hoc-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\14-bao-tang-dan-toc-hoc-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Ede_longhouse%%2C_Museum_of_Ethnology%%2C_Hanoi_%%2837608576475%%29.jpg/960px-Ede_longhouse%%2C_Museum_of_Ethnology%%2C_Hanoi_%%2837608576475%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 14-bao-tang-dan-toc-hoc-1.jpg >> "%LOG%") else (echo OK 14-bao-tang-dan-toc-hoc-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\14-bao-tang-dan-toc-hoc-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\14-bao-tang-dan-toc-hoc-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Giarai_tomb%%2C_Museum_of_Ethnology%%2C_Hanoi_%%282%%29_%%2838439476326%%29.jpg/960px-Giarai_tomb%%2C_Museum_of_Ethnology%%2C_Hanoi_%%282%%29_%%2838439476326%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 14-bao-tang-dan-toc-hoc-2.jpg >> "%LOG%") else (echo OK 14-bao-tang-dan-toc-hoc-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\14-bao-tang-dan-toc-hoc-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\14-bao-tang-dan-toc-hoc-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Traditional_Hanoi_dwelling%%2C_Museum_of_Ethnology%%2C_Hanoi_%%281%%29_%%2838497797791%%29.jpg/960px-Traditional_Hanoi_dwelling%%2C_Museum_of_Ethnology%%2C_Hanoi_%%281%%29_%%2838497797791%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 14-bao-tang-dan-toc-hoc-3.jpg >> "%LOG%") else (echo OK 14-bao-tang-dan-toc-hoc-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\14-bao-tang-dan-toc-hoc-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\14-bao-tang-dan-toc-hoc-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Cotu_tomb%%2C_Museum_of_Ethnology%%2C_Hanoi_%%282%%29_%%2838495337181%%29.jpg/960px-Cotu_tomb%%2C_Museum_of_Ethnology%%2C_Hanoi_%%282%%29_%%2838495337181%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 14-bao-tang-dan-toc-hoc-4.jpg >> "%LOG%") else (echo OK 14-bao-tang-dan-toc-hoc-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\14-bao-tang-dan-toc-hoc-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\14-bao-tang-dan-toc-hoc-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Traditional_Hanoi_dwelling%%2C_Museum_of_Ethnology%%2C_Hanoi_%%287%%29_%%2826722014039%%29.jpg/960px-Traditional_Hanoi_dwelling%%2C_Museum_of_Ethnology%%2C_Hanoi_%%287%%29_%%2826722014039%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 14-bao-tang-dan-toc-hoc-5.jpg >> "%LOG%") else (echo OK 14-bao-tang-dan-toc-hoc-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\15-ho-tay-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\15-ho-tay-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Ho%%C3%%A0ng_h%%C3%%B4n_h%%E1%%BB%%93_T%%C3%%A2y_-_NKS.jpg/960px-Ho%%C3%%A0ng_h%%C3%%B4n_h%%E1%%BB%%93_T%%C3%%A2y_-_NKS.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 15-ho-tay-1.jpg >> "%LOG%") else (echo OK 15-ho-tay-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\15-ho-tay-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\15-ho-tay-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/Hanoi%%2C_10_March_2019.jpg/960px-Hanoi%%2C_10_March_2019.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 15-ho-tay-2.jpg >> "%LOG%") else (echo OK 15-ho-tay-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\15-ho-tay-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\15-ho-tay-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Lac-ouest-hanoi-4.jpg/960px-Lac-ouest-hanoi-4.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 15-ho-tay-3.jpg >> "%LOG%") else (echo OK 15-ho-tay-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\15-ho-tay-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\15-ho-tay-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Chi%%E1%%BB%%81u_h%%E1%%BB%%93_T%%C3%%A2y_-_NKS.jpg/960px-Chi%%E1%%BB%%81u_h%%E1%%BB%%93_T%%C3%%A2y_-_NKS.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 15-ho-tay-4.jpg >> "%LOG%") else (echo OK 15-ho-tay-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\15-ho-tay-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\15-ho-tay-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Night_in_Hanoi_%%2830053395432%%29.jpg/960px-Night_in_Hanoi_%%2830053395432%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 15-ho-tay-5.jpg >> "%LOG%") else (echo OK 15-ho-tay-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\16-chua-tran-quoc-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\16-chua-tran-quoc-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Hanoi%%2C_Vietnam_%%2826246682151%%29.jpg/960px-Hanoi%%2C_Vietnam_%%2826246682151%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 16-chua-tran-quoc-1.jpg >> "%LOG%") else (echo OK 16-chua-tran-quoc-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\16-chua-tran-quoc-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\16-chua-tran-quoc-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Ch%%C3%%B9a_Tr%%E1%%BA%%A5n_Qu%%E1%%BB%%91c_%%28H%%C3%%A0_N%%E1%%BB%%99i%%29.jpg/960px-Ch%%C3%%B9a_Tr%%E1%%BA%%A5n_Qu%%E1%%BB%%91c_%%28H%%C3%%A0_N%%E1%%BB%%99i%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 16-chua-tran-quoc-2.jpg >> "%LOG%") else (echo OK 16-chua-tran-quoc-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\16-chua-tran-quoc-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\16-chua-tran-quoc-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/An_impressive_arch_leads_up_to_the_temple_%%2831417104356%%29.jpg/960px-An_impressive_arch_leads_up_to_the_temple_%%2831417104356%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 16-chua-tran-quoc-3.jpg >> "%LOG%") else (echo OK 16-chua-tran-quoc-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\16-chua-tran-quoc-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\16-chua-tran-quoc-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/Area_with_shrines_for_the_ashes_of_departed_monks_%%2831454177605%%29.jpg/960px-Area_with_shrines_for_the_ashes_of_departed_monks_%%2831454177605%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 16-chua-tran-quoc-4.jpg >> "%LOG%") else (echo OK 16-chua-tran-quoc-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\16-chua-tran-quoc-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\16-chua-tran-quoc-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ee/C%%C3%%A2y_b%%E1%%BB%%93_%%C4%%91%%E1%%BB%%81_ch%%C3%%B9a_Tr%%E1%%BA%%A5n_Qu%%E1%%BB%%91c.jpg/960px-C%%C3%%A2y_b%%E1%%BB%%93_%%C4%%91%%E1%%BB%%81_ch%%C3%%B9a_Tr%%E1%%BA%%A5n_Qu%%E1%%BB%%91c.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 16-chua-tran-quoc-5.jpg >> "%LOG%") else (echo OK 16-chua-tran-quoc-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\17-pho-ta-hien-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\17-pho-ta-hien-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Ph%%E1%%BB%%91_T%%E1%%BA%%A1_Hi%%E1%%BB%%87n_-_NKS.jpg/960px-Ph%%E1%%BB%%91_T%%E1%%BA%%A1_Hi%%E1%%BB%%87n_-_NKS.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 17-pho-ta-hien-1.jpg >> "%LOG%") else (echo OK 17-pho-ta-hien-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\17-pho-ta-hien-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\17-pho-ta-hien-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/T%%E1%%BA%%A1_Hi%%E1%%BB%%87n_Street.jpg/960px-T%%E1%%BA%%A1_Hi%%E1%%BB%%87n_Street.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 17-pho-ta-hien-2.jpg >> "%LOG%") else (echo OK 17-pho-ta-hien-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\17-pho-ta-hien-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\17-pho-ta-hien-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Ta-hien-street-3559133.jpg/960px-Ta-hien-street-3559133.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 17-pho-ta-hien-3.jpg >> "%LOG%") else (echo OK 17-pho-ta-hien-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\17-pho-ta-hien-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\17-pho-ta-hien-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/T%%E1%%BA%%A1_Hi%%E1%%BB%%87n_Street%%2C_Hanoi%%2C_Vietnam_13.jpg/960px-T%%E1%%BA%%A1_Hi%%E1%%BB%%87n_Street%%2C_Hanoi%%2C_Vietnam_13.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 17-pho-ta-hien-4.jpg >> "%LOG%") else (echo OK 17-pho-ta-hien-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\17-pho-ta-hien-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\17-pho-ta-hien-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/20190923_170333ph%%E1%%BB%%91_t%%E1%%BA%%A1_hi%%E1%%BB%%87n_h%%C3%%A0_n%%E1%%BB%%99i.jpg/960px-20190923_170333ph%%E1%%BB%%91_t%%E1%%BA%%A1_hi%%E1%%BB%%87n_h%%C3%%A0_n%%E1%%BB%%99i.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 17-pho-ta-hien-5.jpg >> "%LOG%") else (echo OK 17-pho-ta-hien-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\18-pho-sach-ha-noi-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\18-pho-sach-ha-noi-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/NewOne_-_Ph%%E1%%BB%%91_S%%C3%%A1ch_H%%C3%%A0_N%%E1%%BB%%99i_ng%%C3%%A0y_h%%E1%%BB%%99i_khuy%%E1%%BA%%BFn_%%C4%%91%%E1%%BB%%8Dc_06.jpg/960px-NewOne_-_Ph%%E1%%BB%%91_S%%C3%%A1ch_H%%C3%%A0_N%%E1%%BB%%99i_ng%%C3%%A0y_h%%E1%%BB%%99i_khuy%%E1%%BA%%BFn_%%C4%%91%%E1%%BB%%8Dc_06.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 18-pho-sach-ha-noi-1.jpg >> "%LOG%") else (echo OK 18-pho-sach-ha-noi-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\18-pho-sach-ha-noi-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\18-pho-sach-ha-noi-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/NewOne_-_Ph%%E1%%BB%%91_S%%C3%%A1ch_H%%C3%%A0_N%%E1%%BB%%99i_ng%%C3%%A0y_h%%E1%%BB%%99i_khuy%%E1%%BA%%BFn_%%C4%%91%%E1%%BB%%8Dc_16.jpg/960px-NewOne_-_Ph%%E1%%BB%%91_S%%C3%%A1ch_H%%C3%%A0_N%%E1%%BB%%99i_ng%%C3%%A0y_h%%E1%%BB%%99i_khuy%%E1%%BA%%BFn_%%C4%%91%%E1%%BB%%8Dc_16.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 18-pho-sach-ha-noi-2.jpg >> "%LOG%") else (echo OK 18-pho-sach-ha-noi-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\18-pho-sach-ha-noi-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\18-pho-sach-ha-noi-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/NewOne_-_Ph%%E1%%BB%%91_S%%C3%%A1ch_H%%C3%%A0_N%%E1%%BB%%99i_ng%%C3%%A0y_h%%E1%%BB%%99i_khuy%%E1%%BA%%BFn_%%C4%%91%%E1%%BB%%8Dc_17.jpg/960px-NewOne_-_Ph%%E1%%BB%%91_S%%C3%%A1ch_H%%C3%%A0_N%%E1%%BB%%99i_ng%%C3%%A0y_h%%E1%%BB%%99i_khuy%%E1%%BA%%BFn_%%C4%%91%%E1%%BB%%8Dc_17.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 18-pho-sach-ha-noi-3.jpg >> "%LOG%") else (echo OK 18-pho-sach-ha-noi-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\18-pho-sach-ha-noi-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\18-pho-sach-ha-noi-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/NewOne_-_Ph%%E1%%BB%%91_S%%C3%%A1ch_H%%C3%%A0_N%%E1%%BB%%99i_ng%%C3%%A0y_h%%E1%%BB%%99i_khuy%%E1%%BA%%BFn_%%C4%%91%%E1%%BB%%8Dc_03.jpg/960px-NewOne_-_Ph%%E1%%BB%%91_S%%C3%%A1ch_H%%C3%%A0_N%%E1%%BB%%99i_ng%%C3%%A0y_h%%E1%%BB%%99i_khuy%%E1%%BA%%BFn_%%C4%%91%%E1%%BB%%8Dc_03.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 18-pho-sach-ha-noi-4.jpg >> "%LOG%") else (echo OK 18-pho-sach-ha-noi-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\18-pho-sach-ha-noi-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\18-pho-sach-ha-noi-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/NewOne_-_Ph%%E1%%BB%%91_S%%C3%%A1ch_H%%C3%%A0_N%%E1%%BB%%99i_ng%%C3%%A0y_h%%E1%%BB%%99i_khuy%%E1%%BA%%BFn_%%C4%%91%%E1%%BB%%8Dc_05.jpg/960px-NewOne_-_Ph%%E1%%BB%%91_S%%C3%%A1ch_H%%C3%%A0_N%%E1%%BB%%99i_ng%%C3%%A0y_h%%E1%%BB%%99i_khuy%%E1%%BA%%BFn_%%C4%%91%%E1%%BB%%8Dc_05.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 18-pho-sach-ha-noi-5.jpg >> "%LOG%") else (echo OK 18-pho-sach-ha-noi-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\19-cau-long-bien-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\19-cau-long-bien-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Farm_%%26_bridge_%%2827730838553%%29.jpg/960px-Farm_%%26_bridge_%%2827730838553%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 19-cau-long-bien-1.jpg >> "%LOG%") else (echo OK 19-cau-long-bien-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\19-cau-long-bien-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\19-cau-long-bien-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/C%%E1%%BA%%A7u_Long_Bi%%C3%%AAn_v%%C3%%A0o_%%C4%%91%%C3%%AAm.jpg/960px-C%%E1%%BA%%A7u_Long_Bi%%C3%%AAn_v%%C3%%A0o_%%C4%%91%%C3%%AAm.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 19-cau-long-bien-2.jpg >> "%LOG%") else (echo OK 19-cau-long-bien-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\19-cau-long-bien-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\19-cau-long-bien-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/C%%E1%%BA%%A7u_Long_Bi%%C3%%AAn_28-2-2016.JPG/960px-C%%E1%%BA%%A7u_Long_Bi%%C3%%AAn_28-2-2016.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 19-cau-long-bien-3.jpg >> "%LOG%") else (echo OK 19-cau-long-bien-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\19-cau-long-bien-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\19-cau-long-bien-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Hanoi_pont_long_Bien.jpg/960px-Hanoi_pont_long_Bien.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 19-cau-long-bien-4.jpg >> "%LOG%") else (echo OK 19-cau-long-bien-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\19-cau-long-bien-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\19-cau-long-bien-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/28-2-2016_IMG_1667.JPG/960px-28-2-2016_IMG_1667.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 19-cau-long-bien-5.jpg >> "%LOG%") else (echo OK 19-cau-long-bien-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\20-nha-hat-mua-roi-thang-long-1.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\20-nha-hat-mua-roi-thang-long-1.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Thang_Long_Water_Puppet_Theatre1.JPG/960px-Thang_Long_Water_Puppet_Theatre1.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 20-nha-hat-mua-roi-thang-long-1.jpg >> "%LOG%") else (echo OK 20-nha-hat-mua-roi-thang-long-1.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\20-nha-hat-mua-roi-thang-long-2.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\20-nha-hat-mua-roi-thang-long-2.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Thang_Long_Water_Puppet_Theatre3.JPG/960px-Thang_Long_Water_Puppet_Theatre3.JPG" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 20-nha-hat-mua-roi-thang-long-2.jpg >> "%LOG%") else (echo OK 20-nha-hat-mua-roi-thang-long-2.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\20-nha-hat-mua-roi-thang-long-3.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\20-nha-hat-mua-roi-thang-long-3.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/ICHanoi21.jpg/960px-ICHanoi21.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 20-nha-hat-mua-roi-thang-long-3.jpg >> "%LOG%") else (echo OK 20-nha-hat-mua-roi-thang-long-3.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\20-nha-hat-mua-roi-thang-long-4.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\20-nha-hat-mua-roi-thang-long-4.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Water_Puppet_Theater%%2C_Hanoi_%%281344448995%%29.jpg/960px-Water_Puppet_Theater%%2C_Hanoi_%%281344448995%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 20-nha-hat-mua-roi-thang-long-4.jpg >> "%LOG%") else (echo OK 20-nha-hat-mua-roi-thang-long-4.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
if not exist "%GDIR%\20-nha-hat-mua-roi-thang-long-5.jpg" (
  curl -sS -L --fail --retry 5 --retry-delay 5 -A "HanoiGo-student-project/1.0 (educational; Wikimedia thumbnails)" -o "%GDIR%\20-nha-hat-mua-roi-thang-long-5.jpg" "https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/04391-Hanoi_%%2832139687983%%29.jpg/960px-04391-Hanoi_%%2832139687983%%29.jpg" >> "%LOG%" 2>&1
  if errorlevel 1 (set /a FAIL+=1 & echo LOI 20-nha-hat-mua-roi-thang-long-5.jpg >> "%LOG%") else (echo OK 20-nha-hat-mua-roi-thang-long-5.jpg >> "%LOG%")
  timeout /t 2 /nobreak >nul
)
echo [%time%] XONG - loi: %FAIL% >> "%LOG%"
exit /b %FAIL%
