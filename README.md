# HanoiGo – Hệ thống hỗ trợ tra cứu và lập lộ trình giao thông công cộng đa phương thức

Đồ án: Bus · Metro · Xe đạp công cộng · Xe điện công cộng – khu vực trung tâm Hà Nội.

```
React + TypeScript + Leaflet  ──REST /api/v1 + JWT──>  Node.js + Express + TypeScript  ──>  SQL Server
        (frontend/)                                          (backend/)                       (database/)
```

## Cấu trúc thư mục

```
public-transport-app/
├── database/            ← Script SQL Server
│   ├── 01_database.sql          Tạo DB PublicTransportDBV2 + 17 bảng + index
│   ├── 02_seed.sql              Dữ liệu mẫu: 571 trạm vị trí thật, 22 tuyến (20 bus + Metro 2A, 3.1), 20 điểm tham quan...
│   ├── 03_test_queries.sql      Truy vấn kiểm thử (nearby, join, thống kê)
│   └── 04_upgrade_existing_db.sql  Dùng khi ĐÃ CÓ DB cũ, không muốn xóa dữ liệu
├── backend/             ← API (tách riêng, xem backend/README.md)
├── frontend/            ← Giao diện React
└── docs/API.md          ← API contract đầy đủ cho cả nhóm
```

## Phân công theo code

| Người | Module | Backend (backend/src) | Frontend (frontend/src) |
|---|---|---|---|
| Người 1 – Map + Routing | Transport, Attractions, Routing | `algorithms/*`, `services/routing, transport, attraction.service.ts` | `pages/MapPage`, `HomePage`, `AttractionDetailPage`, `components/MapView` |
| Người 2 – User + Ticket + Payment | Auth, Ticket, Order, Payment, History | `services/auth, ticket, order, tripHistory.service.ts` | `pages/LoginPage, BuyTicketPage, PaymentPage, TicketDetailPage...` |
| Người 3 – Backend + Admin | Kiến trúc, DB, JWT/RBAC, Admin CRUD, Thống kê | `config/*`, `middleware/*`, `utils/*`, `repositories/*`, `services/admin.service.ts` | `pages/admin/*`, `layouts/AdminLayout` |

## Chạy nhanh trên máy này (Docker + 1 cú nhấp)

Máy chưa cài SQL Server nên dùng SQL Server 2022 trong Docker (container `pta-sql`, giờ Việt Nam, user `sa` / `Pta@Strong2026`).

| File | Tác dụng |
|---|---|
| `run-all.bat` | Bật Docker → bật SQL Server → tạo DB lần đầu → ghi `backend/.env` → `npm install` → chạy backend (cửa sổ "HanoiGo Backend") + frontend ("HanoiGo Frontend") → mở http://localhost:5173 |
| `reset-db.bat` | Xóa container và tạo lại database + dữ liệu mẫu từ đầu (sau đó tắt/mở lại cửa sổ backend để băm lại mật khẩu seed) |
| `api-test.bat` | Chạy 42 test API toàn luồng, kết quả ở `api-test.log` |

Log: `run-all.log`, `backend.log`, `frontend.log`. Tắt project: đóng 2 cửa sổ HanoiGo; SQL Server tắt bằng `docker stop pta-sql`.
Kết nối SSMS vào DB này: Server `localhost,1433`, SQL Server Authentication, `sa` / `Pta@Strong2026`.

## Chạy project (Windows)

Yêu cầu: **Node.js 18+**, **SQL Server 2017+** (cần `STRING_AGG`), SSMS.

### 1. Database
1. Mở SSMS → mở `database/01_database.sql` → **Execute** (F5).
2. Mở `database/02_seed.sql` → **Execute**.
   - Nếu nhóm đã có DB cũ và không muốn xóa: chỉ chạy `04_upgrade_existing_db.sql`.

### 2. Kết nối SQL Server (làm 1 lần)
Thư viện `mssql` dùng **SQL Server Authentication** qua TCP:
1. SSMS → chuột phải server → *Properties* → *Security* → chọn **SQL Server and Windows Authentication mode**.
2. *Security → Logins → sa* → đặt mật khẩu, *Status* = **Enabled**.
3. *SQL Server Configuration Manager* → *SQL Server Network Configuration* → *Protocols* → **TCP/IP = Enabled** → *IP Addresses* → *IPAll* → `TCP Port = 1433`.
4. Restart dịch vụ SQL Server.
   - Dùng SQL Express (instance `SQLEXPRESS`) mà không đặt port: điền `DB_INSTANCE=SQLEXPRESS`, để trống `DB_PORT` và bật dịch vụ **SQL Server Browser**.

### 3. Backend
```bash
cd backend
npm install
copy .env.example .env      # sửa DB_USER / DB_PASSWORD
npm run db:check            # kiểm tra kết nối + đếm bản ghi 17 bảng
npm run test:routing        # test thuật toán tìm đường (không cần DB)
npm run dev                 # http://localhost:5000/api/v1
```
Mở http://localhost:5000/api/v1/stations → thấy JSON là backend ↔ SQL Server OK.

> Lần chạy đầu, backend tự băm bcrypt mật khẩu của các tài khoản seed (seed lưu dạng `SEED:123456`).

### 4. Frontend
```bash
cd frontend
npm install
npm run dev                 # http://localhost:5173
```
Vite đã cấu hình proxy `/api → http://localhost:5000`, nên không cần chỉnh CORS khi chạy local.

### Tài khoản demo (mật khẩu `123456`)
| Email | Vai trò |
|---|---|
| an@example.com | USER (đã có vé lượt Bus) |
| binh@example.com | USER (có vé tháng Metro → tìm đường được miễn phí Metro) |
| admin@example.com | ADMIN |

## Kịch bản demo khi bảo vệ
1. Đăng nhập `an@example.com` → Trang chủ "Bạn muốn đi đâu hôm nay?"
2. Khám phá → chọn **Văn Miếu - Quốc Tử Giám** → xem chi tiết → **Tìm đường đến đây**.
3. Chọn điểm đi (gõ "Hỏa Lò", hoặc "Dùng vị trí hiện tại", hoặc chọn trên bản đồ) → **Tìm đường**.
4. Hệ thống trả **Top 3** phương án, gắn nhãn Nhanh nhất / Rẻ nhất / Ít đi bộ / Ít chuyển tuyến; đổi tab tiêu chí để so sánh.
5. Chọn 1 phương án → bản đồ vẽ tuyến (mỗi phương tiện 1 màu, đi bộ nét đứt) + chi tiết từng bước + giờ chuyến kế tiếp.
6. **Mua vé cho lộ trình** → vé lượt được chọn sẵn → **Thanh toán** bằng thẻ (thẻ thử nghiệm `4242 4242 4242 4242`) hoặc **chuyển khoản QR** → **QR e-ticket**.
7. Đăng nhập `admin@example.com` → Dashboard thống kê → Vé & Soát vé: dán nội dung QR → vé lượt chuyển **Đã dùng**.
8. Admin thêm trạm/tuyến mới → graph tìm đường tự xây lại → tìm đường thấy tuyến mới.

## Nguồn dữ liệu vị trí trạm

| Loại | Số trạm | Nguồn |
|---|---|---|
| Xe buýt | 453 điểm dừng, 20 tuyến | Danh sách tuyến, giờ chạy, giá vé 7.000đ theo [Vinpearl – Bản đồ xe bus Hà Nội](https://vinpearl.com/vi/ban-do-xe-bus-ha-noi). Bài viết không có tọa độ nên vị trí và thứ tự điểm dừng lấy từ OpenStreetMap (route relation của từng tuyến), khoảng cách đo dọc theo đường. |
| Metro | 20 ga (2A: 12 ga, 3.1: 8 ga) | Tọa độ ga từ [metrohanoi.vn](https://metrohanoi.vn/line/map). Giá vé theo quãng đường 8.000–15.000đ là mô phỏng. |
| Xe đạp | 49 trạm TNGo | Danh sách + địa chỉ theo [bài viết trên dantocphattrien.vietnamnet.vn](https://dantocphattrien.vietnamnet.vn/danh-sach-cac-tram-xe-dap-cong-cong-cho-thue-o-ha-noi-46898.html), tọa độ từ OpenStreetMap. |
| Xe điện | 49 trạm | **Cùng vị trí** với trạm xe đạp (`BIKE-xxx` ↔ `EV-xxx`); trên bản đồ hiển thị chung 1 marker. |

Xe đạp / xe điện không có tuyến cố định: lấy xe ở trạm bất kỳ, trả ở trạm cùng loại trong bán kính 4 km.
Sau khi đổi dữ liệu cần chạy lại `reset-db.bat` (hoặc chạy lại `01_database.sql` + `02_seed.sql`).

## Chỉ đường theo đường phố thật (OSRM)

Lộ trình trên bản đồ được vẽ theo đường phố thật (đi bộ, xe đạp/xe điện, xe buýt), không còn là đường chim bay. Quãng đường đi bộ thực tế cũng được dùng khi tính 4 tiêu chí **Nhanh nhất / Rẻ nhất / Ít đi bộ / Ít chuyển tuyến**.

| Bước | Cách làm |
|---|---|
| Cài 1 lần | Chạy `osrm-setup.bat` (cần Docker, ~10 phút): tải bản đồ Việt Nam từ Geofabrik, cắt vùng Hà Nội bằng osmium, dựng 3 máy chủ OSRM trong Docker: đi bộ `:5001`, xe đạp `:5002`, ô tô/xe buýt `:5003`. |
| Các lần sau | Các container tự chạy cùng Docker; `run-all.bat` cũng tự khởi động chúng. |
| Dự phòng | Nếu máy chủ trên máy không chạy, backend dùng máy chủ công cộng `routing.openstreetmap.de` (có giới hạn tần suất); nếu cũng lỗi thì vẽ đường thẳng và giao diện báo rõ. |

Metro đi trên cao nên vẫn nối thẳng giữa các ga. Cấu hình trong `backend/src/config/routing.config.ts` (`roadRouting`), tắt bằng `ROAD_ROUTING=false` trong `backend/.env`.


## Địa điểm tham quan: thông tin và ảnh

- **Thông tin chi tiết** cho 20 địa điểm: giới thiệu, lịch sử, điểm nổi bật, giờ mở cửa, giá vé (tra cứu 11/2026 – có thể thay đổi), thời gian tham quan gợi ý, thời điểm đẹp nhất, lưu ý khi tham quan. Thẻ ở mục **Khám phá** hiện nhanh địa chỉ, giờ mở cửa, thời gian tham quan, giá vé và số ảnh.
- **Ảnh**: 1 ảnh đại diện (phủ kín đầu trang chi tiết) + 3–5 ảnh bộ sưu tập mỗi địa điểm, xem phóng to bằng lightbox. Ảnh lấy từ [Wikimedia Commons](https://commons.wikimedia.org) (giấy phép tự do CC0 / Public domain / CC BY / CC BY-SA), lưu sẵn trong `frontend/public/images/attractions/` và `.../gallery/`.
- **Ghi nguồn ảnh** (bắt buộc với CC BY / CC BY-SA): mục "Nguồn ảnh" thu gọn cuối trang chi tiết, cột `ImageCredit` / bảng `AttractionImages`, và file `frontend/public/images/attractions/CREDITS.md`.
- Bảng mới `AttractionImages`; cột mới `HoursSummary`, `PriceFrom`, `VisitDuration`, `BestTime`, `Tips` trong `TouristAttractions`. Admin sửa được tất cả, kể cả bộ sưu tập ảnh (mỗi dòng: `URL | chú thích | tác giả / giấy phép | link nguồn`).
- Database đã có dữ liệu: chạy `upgrade-db.bat` (chạy `05_attraction_images.sql` + `06_attraction_details.sql`, không xóa dữ liệu khác).
- Tải lại ảnh nếu thiếu: `download-images.bat` (chỉ tải file chưa có; Wikimedia giới hạn tốc độ nên mất khoảng 20–30 phút cho lần đầu).

## Đăng ký có xác nhận qua Email / SMS

- **Đăng ký 2 bước**: nhập họ tên, email, số điện thoại, mật khẩu → chọn nhận **mã 6 số** qua **Email** hoặc **SMS** → nhập mã → tài khoản mới được tạo trong bảng `Users` (kèm `EmailVerifiedAt` / `PhoneVerifiedAt`). Trước khi nhập đúng mã, thông tin chỉ nằm tạm trong bảng `VerificationCodes` (mật khẩu đã băm, mã chỉ lưu dạng hash).
- Mã hết hạn sau 5 phút, sai tối đa 5 lần, gửi lại sau 60 giây, tối đa 5 mã/giờ cho mỗi email/SĐT.
- **Đăng nhập** bằng email **hoặc** số điện thoại (0912345678, +84 912 345 678…). Số điện thoại không được trùng giữa các tài khoản.
- Chưa cấu hình gửi → API trả lỗi 503 `NOTIFY_NOT_CONFIGURED`, trang đăng ký báo rõ (không giả vờ gửi).
- Database đang chạy: chạy `upgrade-db.bat` (có `07_auth_verification.sql`). Cài thư viện gửi mail: `install-deps.bat` (nodemailer).

### Cấu hình gửi thật — tạo file `backend/.env.local`

File này chứa thông tin bí mật: **không** bị `run-all.bat` ghi đè và **không** được đẩy lên GitHub. Tạo file rồi điền giá trị của bạn, lưu lại là backend tự khởi động lại.

```ini
# ---- EMAIL qua Gmail ----
# Bật Xác minh 2 bước -> tạo Mật khẩu ứng dụng (App Password 16 ký tự) tại
# https://myaccount.google.com/apppasswords  (KHÔNG dùng mật khẩu Gmail thường)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=465
SMTP_SECURE=true
SMTP_USER=ban@gmail.com
SMTP_PASS=xxxxxxxxxxxxxxxx
MAIL_FROM=ban@gmail.com

# ---- SMS: chọn 1 trong twilio | esms | speedsms ----
SMS_PROVIDER=twilio
# Twilio (https://console.twilio.com) - tài khoản dùng thử chỉ gửi tới số đã xác minh trong Twilio
TWILIO_ACCOUNT_SID=ACxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxx
TWILIO_FROM=+1xxxxxxxxxx
# eSMS.vn - cần Brandname + mẫu tin CSKH đã được duyệt
# SMS_PROVIDER=esms
# ESMS_API_KEY=...
# ESMS_SECRET_KEY=...
# ESMS_BRANDNAME=...
# SpeedSMS.vn - access token ở Settings > Profile; SPEEDSMS_TYPE=2 (CSKH) hoặc 3 (brandname riêng + SPEEDSMS_SENDER)
# SMS_PROVIDER=speedsms
# SPEEDSMS_TOKEN=...
# SPEEDSMS_TYPE=2
```

Kiểm tra: mở `http://localhost:5000/api/v1/auth/verification-channels` → `"email": true` / `"sms": true` là đã sẵn sàng.

## Yêu cầu đăng nhập khi xem chi tiết

- Khách chưa đăng nhập vẫn xem được trang chủ và danh sách **Khám phá**.
- Bấm vào một địa điểm (`/attractions/:id`) hoặc mở **Bản đồ & Tìm đường** (`/map`) khi chưa đăng nhập → hiện thông báo kèm nút **Đăng nhập** / **Đăng ký tài khoản mới** (`components/LoginRequired.tsx`).
- Đăng nhập hoặc đăng ký xong sẽ tự quay lại đúng trang đang định xem; đã đăng nhập thì xem bình thường.

## Thanh toán: thẻ ngân hàng và chuyển khoản QR

Chỉ còn 2 phương thức (đã bỏ ví điện tử): `/payment/:orderId` cho chọn **Thẻ ngân hàng** hoặc **Chuyển khoản QR**.

**Thẻ ngân hàng** (`/payment/:orderId/card`)
- Thẻ quốc tế (Visa, Mastercard, JCB, AMEX): số thẻ (kiểm tra Luhn, tự nhận hãng thẻ), tên in trên thẻ (chữ in hoa không dấu), ngày hết hạn MM/YY, CVV (AMEX 4 số).
- Thẻ ATM nội địa (NAPAS): ngân hàng phát hành, số thẻ 16/19 số bắt đầu `9704`, tên chủ thẻ, ngày phát hành MM/YY.
- Database chỉ lưu **hãng thẻ + 4 số cuối**, không lưu số thẻ đầy đủ hay CVV.
- Cổng thẻ ở chế độ **thử nghiệm** (chưa nối ngân hàng thật, cần hợp đồng với cổng thanh toán như VNPAY / OnePay / Stripe). Thẻ thử: `4242 4242 4242 4242` thành công, `4000 0000 0000 0002` bị từ chối, `4000 0000 0000 9995` không đủ số dư, `9704 0000 0000 0018` ATM nội địa thành công.

**Chuyển khoản QR** (`/payment/:orderId/transfer`)
- Tạo mã **VietQR** (chuẩn Napas 247, quét được bằng mọi app ngân hàng) chứa sẵn số tài khoản, **số tiền** và **nội dung riêng cho từng đơn** (vd. `HNG2008ZXAB`). Mã hết hạn sau 30 phút (chỉnh được).
- Thanh toán **không thành công ngay**: giao dịch ở trạng thái `PENDING`. Khách bấm "Tôi đã chuyển khoản" vẫn chỉ là chờ xác nhận; trang tự kiểm tra trạng thái mỗi 4 giây.
- Vé chỉ được phát hành khi tiền đã về tài khoản:
  - **Admin xác nhận**: Quản trị → **Thanh toán** → đối chiếu sao kê → "Xác nhận đã nhận tiền" (hoặc "Từ chối").
  - **Tự động (tùy chọn)**: webhook [SePay](https://sepay.vn) `POST /api/v1/payments/webhooks/sepay`, khớp nội dung + đủ số tiền. Cần backend có địa chỉ public và thêm `SEPAY_API_KEY=...` vào `backend/.env.local` (SePay gửi header `Authorization: Apikey <key>`).
- **Bước bắt buộc**: đăng nhập admin → **Thanh toán** → nhập **ngân hàng, số tài khoản, tên chủ tài khoản** nhận tiền. Chưa nhập thì lựa chọn chuyển khoản bị tắt.

**Database**: bảng `Payments` thêm cột `CardBrand`, `CardLast4`, `TransferContent`, `ExpiresAt`, `CustomerNotifiedAt`, `ConfirmedBy`, `BankReference`, `Note`, `CreatedAt` và trạng thái `EXPIRED` / `CANCELLED`; bảng mới `PaymentSettings`. Database đang chạy: chạy `upgrade-db.bat` (có `08_payment_methods.sql`).
