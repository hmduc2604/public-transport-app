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
│   ├── 01_database.sql          Tạo DB PublicTransportDBV2 + 22 bảng + index
│   ├── 02_seed.sql              Dữ liệu mẫu: 571 trạm vị trí thật, 22 tuyến (20 bus + Metro 2A, 3.1), 34 điểm tham quan...
│   ├── 03_test_queries.sql      Truy vấn kiểm thử (nearby, join, thống kê)
│   ├── 04_upgrade_existing_db.sql  Dùng khi ĐÃ CÓ DB cũ, không muốn xóa dữ liệu
│   ├── 05 … 12_*.sql            Nâng cấp DB đang chạy (ảnh, chi tiết địa điểm, xác nhận đăng ký, thanh toán, sửa dữ liệu, AI, 14 địa điểm mới) – chạy bằng upgrade-db.bat
│   └── 99_cleanup_test_data.sql Dọn trạm / tuyến do api-test tạo
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
| `api-test.bat` | Chạy 109 test API toàn luồng (gồm các trường hợp lỗi / bảo mật và chức năng AI), kết quả ở `api-test.log` |
| `stability-test.bat` | Kiểm tra độ ổn định: chịu tải đồng thời (≈ 3.000 request), thanh toán trùng cùng lúc, và **tắt SQL Server 10 giây** rồi bật lại để xem backend có tự phục hồi không. Chỉ chạy trên máy thử nghiệm; kết quả ở `stability-test.log` |
| `upgrade-db.bat` | Cập nhật database đang chạy lên bản mới nhất (chạy lần lượt `05` → `12`, không xóa dữ liệu, chạy lại nhiều lần vẫn an toàn) |
| `install-deps.bat` | Cài / cập nhật thư viện cho backend + frontend, xong tự khởi động lại 2 cửa sổ |
| `restart-app.bat` | Khởi động lại backend + frontend (khi backend bị treo hoặc vừa đổi thư viện) |

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
npm run db:check            # kiểm tra kết nối + đếm bản ghi 22 bảng
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
1. Đăng nhập `an@example.com` → Trang chủ "Bạn muốn đi đâu hôm nay?": gõ điểm đến vào ô tìm kiếm (gõ không dấu cũng được, ví dụ "ho tay") → mở thẳng bản đồ tìm đường tới nơi đó. Nút mặt trời / mặt trăng góc phải để đổi giao diện sáng / tối.
2. Khám phá → chọn **Văn Miếu - Quốc Tử Giám** → xem chi tiết → **Tìm đường đến đây**.
3. Chọn điểm đi (gõ "Hỏa Lò", hoặc "Dùng vị trí hiện tại", hoặc chọn trên bản đồ) → **Tìm đường**.
4. Hệ thống trả **Top 3** phương án, gắn nhãn Nhanh nhất / Rẻ nhất / Ít đi bộ / Ít chuyển tuyến; đổi tab tiêu chí để so sánh.
5. Chọn 1 phương án → bản đồ vẽ tuyến (mỗi phương tiện 1 màu, đi bộ nét đứt) + chi tiết từng bước + giờ chuyến kế tiếp.
6. **Mua vé cho lộ trình** → vé lượt được chọn sẵn → **Thanh toán** bằng thẻ (thẻ thử nghiệm `4242 4242 4242 4242`) hoặc **chuyển khoản QR** → **QR e-ticket**.
7. Đăng nhập `admin@example.com` → Dashboard thống kê → Vé & Soát vé: dán nội dung QR → vé lượt chuyển **Đã dùng**.
8. Admin thêm trạm/tuyến mới → graph tìm đường tự xây lại → tìm đường thấy tuyến mới.
9. **Trợ lý AI** (menu Trợ lý AI): gõ "Lên lịch nửa ngày: Văn Miếu → Hoàng thành Thăng Long → Hồ Tây ngắm hoàng hôn" → trợ lý trả lịch trình có giờ đến / giờ rời từng nơi, mỗi chặng 1 thẻ lộ trình → bấm **Xem trên bản đồ**. Hỏi tiếp "đi chậm thôi, ít đi bộ" để trợ lý tìm lại theo tiêu chí khác.
10. Trang chủ → **Gợi ý cho bạn**: gõ sở thích ("kiến trúc Pháp, chụp ảnh buổi tối") → 4 địa điểm hợp nhất kèm lý do; đăng nhập `an@example.com` thì có thêm dòng "Dành cho bạn, dựa trên: …" (lịch sử đã xem / đã tìm đường).
11. Vé → **Mua vé** → khung **Tư vấn chọn vé**: gõ "đi làm từ Cầu Giấy đến Hồ Gươm, thứ 2 – thứ 6" (hoặc bấm **Dựa trên vé tôi đã mua**) → hệ thống so tiền vé lượt cả tháng với vé tháng, ghi rõ tiết kiệm bao nhiêu → bấm **Chọn Vé tháng Bus** để thêm vào đơn.
12. Mở trang **Văn Miếu - Quốc Tử Giám** → mục **Hỏi đáp**: hỏi "Giá vé bao nhiêu?", rồi hỏi tiếp "Còn trẻ em thì sao?", "Giờ này còn mở cửa không?" → AI trả lời chỉ dựa trên dữ liệu của địa điểm (giờ mở cửa theo mùa, giá vé, trạm gần).

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

- **Thông tin chi tiết** cho 34 địa điểm: giới thiệu, lịch sử, điểm nổi bật, giờ mở cửa, giá vé (tra cứu 11/2026 – có thể thay đổi), thời gian tham quan gợi ý, thời điểm đẹp nhất, lưu ý khi tham quan, **thông tin nhanh** (năm xây dựng, xếp hạng di tích...) và **mốc lịch sử** (cả 34 địa điểm, mỗi nơi ít nhất 4 thông tin nhanh và 2 mốc). Thẻ ở mục **Khám phá** hiện nhanh địa chỉ, giờ mở cửa, thời gian tham quan, giá vé và số ảnh.
- **Trang chi tiết** (`pages/AttractionDetailPage.tsx`): ảnh phủ kín đầu trang + 3 ảnh xem trước, dải thông tin (giờ mở cửa, giá vé, thời gian tham quan, trạm gần nhất), cột phải "Đến bằng phương tiện công cộng" (mỗi trạm kèm số tuyến dừng tại đó và số phút đi bộ, bản đồ nhỏ, nút tìm lộ trình), trục mốc lịch sử, kinh nghiệm tham quan, bộ sưu tập ảnh và mục **Đi tiếp gần đây** (4 địa điểm trong bán kính 3 km). Thanh **mục lục** dính dưới menu (Tổng quan · Đi lại · Nổi bật · Lịch sử · Kinh nghiệm · Hình ảnh · Gần đây) tự sáng mục đang đọc, kèm nút Tìm đường; nút **Chia sẻ** mở bảng chia sẻ của điện thoại hoặc chép liên kết. Icon nét SVG (`components/Icon.tsx`) thay cho emoji để hiển thị giống nhau trên mọi máy.
- **Ảnh**: 1 ảnh đại diện (phủ kín đầu trang chi tiết) + 3–5 ảnh bộ sưu tập mỗi địa điểm, xem phóng to bằng lightbox. Ảnh lấy từ [Wikimedia Commons](https://commons.wikimedia.org) (giấy phép tự do CC0 / Public domain / CC BY / CC BY-SA), lưu sẵn trong `frontend/public/images/attractions/` và `.../gallery/`.
- **Ghi nguồn ảnh** (bắt buộc với CC BY / CC BY-SA): mục "Nguồn ảnh" thu gọn cuối trang chi tiết, cột `ImageCredit` / bảng `AttractionImages`, và file `frontend/public/images/attractions/CREDITS.md`.
- Bảng mới `AttractionImages`; cột mới `HoursSummary`, `PriceFrom`, `VisitDuration`, `BestTime`, `Tips`, `Facts`, `Timeline` trong `TouristAttractions`. Admin sửa được tất cả, kể cả bộ sưu tập ảnh (mỗi dòng: `URL | chú thích | tác giả / giấy phép | link nguồn`), thông tin nhanh (`Nhãn | Giá trị`) và mốc lịch sử (`Năm | Sự kiện`).
- Database đã có dữ liệu: chạy `upgrade-db.bat` (chạy `05_attraction_images.sql`, `06_attraction_details.sql`, `10_attraction_guide.sql`, không xóa dữ liệu khác).
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

## Chức năng AI: trợ lý lập lộ trình, gợi ý theo sở thích, tư vấn chọn vé, hỏi đáp địa điểm

Dùng Google **Gemini API**. Khóa đặt trong `backend/.env.local` (file này **không** được đưa lên GitHub):

```
GEMINI_API_KEY=...khóa lấy ở https://aistudio.google.com/apikey...
```

Sau đó chạy `upgrade-db.bat` (có `11_ai_features.sql`: bảng `AttractionEmbeddings`, `AttractionViews`) và `restart-app.bat`.

| Chức năng | Ở đâu | Cách hoạt động |
|---|---|---|
| **Trợ lý lập lộ trình bằng tiếng Việt** | Menu **Trợ lý AI** (`/assistant`, cần đăng nhập) | Gõ hoặc nói (nút micro) câu tự nhiên: "Từ Hồ Gươm đến Văn Miếu, đi bộ ít thôi", "Sáng mai 8h đi Hỏa Lò rồi Văn Miếu", "mình đang ở đây, muốn đi Lăng Bác" (bật **Dùng vị trí của tôi**). Gemini hiểu câu hỏi rồi gọi bộ tìm đường, dữ liệu địa điểm, bảng giá vé của hệ thống; trả lời tiếng Việt kèm **thẻ lộ trình** (3 phương án, mở trên bản đồ) và **thẻ địa điểm**. Lịch trình nhiều điểm được tính nối tiếp từng chặng, có cảnh báo nơi đã đóng cửa và giờ mặt trời lặn. Nhớ ngữ cảnh trong cuộc trò chuyện ("còn cách nào rẻ hơn không?"). |
| **Gợi ý địa điểm theo sở thích** | Trang chủ → **Gợi ý cho bạn** | Gõ sở thích bất kỳ hoặc chọn nhanh (Lịch sử, Kiến trúc Pháp, Chụp ảnh, Ẩm thực…), có thể bấm **📍 Gần tôi**. Hệ thống so khớp **ngữ nghĩa** (vector Gemini) giữa sở thích và mô tả các địa điểm, cộng thêm lịch sử các nơi bạn đã xem / tìm đường tới, khoảng cách và độ phổ biến; mỗi gợi ý có lý do cụ thể. Không có khóa hoặc mất mạng → tự chuyển sang khớp từ khóa. |
| **Tư vấn chọn vé** | **Vé → Mua vé** (khung trên cùng, `/tickets/buy#tu-van`), banner ở **Vé của tôi**, và trong **Trợ lý AI** ("đi buýt 2 lượt mỗi ngày, có nên mua vé tháng?") | Mô tả thói quen bằng lời ("metro 2 lượt mỗi ngày, 5 ngày/tuần", "đi làm từ Cầu Giấy đến Hồ Gươm") hoặc bấm **Dựa trên vé tôi đã mua** (vé lượt 30 ngày qua). Gemini chỉ tách thói quen thành số liệu; số lượt / tháng, tiền vé lượt, vé tháng, điểm hòa vốn, tiết kiệm đều do backend tính từ bảng giá. Với quãng đi làm, hệ thống tìm đường thật (Nhanh nhất + Rẻ nhất), chọn phương án rẻ nhất mỗi tháng mà chậm hơn không quá 20 phút. Đã có vé tháng còn hạn → báo "chưa cần mua". Bấm **Chọn** để thêm vé vào đơn. Mô tả chưa rõ → hỏi lại, không đoán. |
| **Hỏi đáp trên trang địa điểm** | Trang chi tiết mỗi địa điểm → mục **Hỏi đáp** (cần đăng nhập) | Hỏi tự do: giá vé, giờ mở cửa, "giờ này còn mở không?", trẻ em, đi bằng xe buýt nào, gần đó có gì… AI chỉ trả lời từ dữ liệu của địa điểm trong database (giới thiệu, lịch sử, giờ mở cửa, giá vé, kinh nghiệm, trạm và địa điểm lân cận); không có thông tin thì nói không có. Giờ mở cửa tính **theo mùa** (giờ mùa đông tháng 11 – 3), ngày nghỉ trong tuần và giờ cuối tuần. Nhớ 3 câu hỏi trước để hỏi tiếp; gợi ý câu hỏi tiếp theo. Không có khóa / Gemini bận → trả lời theo từ khóa. |

Chi tiết kỹ thuật: `backend/README.md` (mục 5), API: `docs/API.md` (mục 7). Khóa đã từng gửi qua chat / email nên **tạo khóa mới sau khi bảo vệ** và thay vào `.env.local`.

## Yêu cầu đăng nhập khi xem chi tiết

- Khách chưa đăng nhập vẫn xem được trang chủ và danh sách **Khám phá**.
- Bấm vào một địa điểm (`/attractions/:id`) hoặc mở **Tìm đường** (`/map`) khi chưa đăng nhập → hiện thông báo kèm nút **Đăng nhập** / **Đăng ký tài khoản mới** (`components/LoginRequired.tsx`).
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

## Kiểm tra tổng thể và các lỗi đã sửa (11/2026)

Đã kiểm tra: type-check TypeScript (backend + frontend), build production, 13 test tìm đường, 78 test API, `npm audit`, toàn vẹn dữ liệu database (28 nhóm truy vấn), giao diện mọi trang người dùng + quản trị ở máy tính và điện thoại.

| Phần | Lỗi | Đã sửa |
|---|---|---|
| Backend | `?sort=constructor` / id quá lớn / họ tên rỗng / QR có ký tự lạ → lỗi 500 | Trả 400 hoặc giá trị mặc định |
| Backend | Tìm đường từ toạ độ ngoài Hà Nội (vd. TP HCM) ra "đi bộ 236 giờ"; giờ khởi hành `25:99` vẫn nhận | Báo `OUT_OF_SERVICE_AREA` / `INVALID_TIME` |
| Backend | Tạo chuyến có giờ đến trước giờ đi (thành chuyến 23 giờ); 1 xe được gán 2 chuyến cùng giờ | Kiểm tra thời gian (≤ 6 giờ) và trùng lịch xe |
| Bảo mật | Tài khoản bị khóa / bị hạ quyền vẫn dùng token cũ tới 7 ngày | Mỗi request đối chiếu lại trạng thái trong DB (cache 15 giây) |
| Bảo mật | Không giới hạn số lần đăng nhập sai / gửi mã xác nhận | Giới hạn theo IP, trả 429 |
| Bảo mật | Khóa ký JWT là chuỗi cố định công khai trong `run-all.bat` | Mỗi máy tự sinh khóa ngẫu nhiên vào `backend/.jwt-secret` (không đẩy lên GitHub); chạy production với khóa mặc định sẽ bị chặn. Lần chạy `run-all.bat` đầu tiên sau bản này cần đăng nhập lại |
| Thư viện | `nodemailer` 6 (lỗ hổng mức cao), `react-router-dom` 6 (mức trung bình) | Lên `nodemailer` 10, `react-router-dom` 7 → `npm audit`: 0 lỗ hổng |
| Database | 7 xe buýt xoay vòng cho 20 tuyến → 1 xe chạy nhiều chuyến **cùng lúc**; 9 cột khóa ngoại chưa có index | `09_data_fixes.sql`: mỗi tuyến có đội xe riêng (đủ xe theo giãn cách và thời gian chuyến), 0 chuyến trùng; thêm index |
| Frontend | Backend khởi động lại đúng lúc mở trang → bị đăng xuất; vào `/login` khi đã đăng nhập vẫn hiện form | Chỉ đăng xuất khi token thật sự sai (401); đã đăng nhập thì tự chuyển trang |
| Quản trị | Trang Lịch trình chỉ hiện 500/1184 chuyến | Hiện đủ |

## Kiểm tra lần 2 (13/11/2026): ảnh, icon, trang chi tiết, độ ổn định

**Ảnh**: đối chiếu từng ảnh (120 ảnh) với địa điểm và chú thích.

| Lỗi | Đã sửa |
|---|---|
| Ảnh đại diện Phố cổ, Quảng trường Ba Đình, Chùa Một Cột, Văn Miếu, Bảo tàng Lịch sử: ảnh dọc bị cắt mất chủ thể, độ phân giải thấp hoặc trùng với ảnh trong bộ sưu tập | Thay ảnh ngang 1600px rõ chủ thể (Khuê Văn Các, Chùa Một Cột, phố cổ, mặt tiền bảo tàng...) |
| Hỏa Lò chỉ có 3 ảnh (có ảnh chụp lại ảnh tư liệu), Ba Đình 4 ảnh | Bổ sung đủ 5 ảnh chụp tại chỗ cho mỗi địa điểm |
| Bộ sưu tập Phố sách in dấu ngày giờ / watermark của điện thoại | Thay ảnh khác và cắt bỏ dải dấu ngày giờ (ghi chú trong nguồn ảnh) |
| Một số ảnh Phố cổ, Ba Đình, Chùa Một Cột, Văn Miếu chung chung, trùng ảnh đại diện mới hoặc không đúng chủ thể trong chú thích | Thay ảnh đúng chủ thể: Ô Quan Chưởng, chùa Diên Hựu, nhà bia tiến sĩ trên lưng rùa... |
| 11 chú thích không khớp ảnh: 5 ảnh phố Tạ Hiện (ảnh đêm ghi "ban ngày" và ngược lại), tranh vẽ ghi "mô hình thuyền chiến", ảnh khu vườn ghi "hiện vật trưng bày", ảnh hồ về đêm không thấy Tháp Rùa vẫn ghi "Tháp Rùa"... | Viết lại chú thích theo đúng nội dung ảnh |

Danh sách tác giả / giấy phép sinh lại từ database: `frontend/public/images/attractions/CREDITS.md`. Thay đổi DB nằm trong `database/10_attraction_guide.sql` (đã gộp vào `01_database.sql` + `02_seed.sql` cho lần cài mới).

**Icon**: loại địa điểm dùng icon đúng nghĩa hơn (Di tích 🏛️, Di sản 🏯, Bảo tàng 🏺, Tôn giáo ☸️, Kiến trúc 📐); xe điện 🛵 thay 🛺 (xe lam/tuk-tuk). Trang chi tiết dùng bộ icon nét SVG.

**Độ ổn định** (`stability-test.bat`, `api-test.bat`, kiểm tra toàn vẹn DB 29 nhóm truy vấn):

| Kiểm tra | Kết quả |
|---|---|
| 2.000 request đọc dữ liệu, 50 request song song | 100% thành công, 160–200 request/giây, 95% dưới 0,7 giây |
| 200–300 lần tìm lộ trình, 20 song song | 100% thành công, 95% dưới 1,5 giây |
| 5 lần thanh toán **cùng lúc** cho 1 đơn | Chỉ 1 lần thành công, 4 lần bị chặn `ORDER_ALREADY_PAID`, sinh đúng 1 vé |
| Tạo / hủy 20 đơn cùng lúc | Đủ 20 đơn, mã không trùng |
| 4 vòng tải liên tiếp (≈ 9.200 request) | RAM backend ổn định ~350 MB, không tăng dần (không rò rỉ bộ nhớ) |
| Tắt SQL Server 10 giây | Backend không sập, trả 503 `DB_UNAVAILABLE`; bật lại DB thì tự kết nối lại sau ~14 giây (thời gian SQL Server khởi động) |
| Type-check, build, `npm audit`, 13 test tìm đường, 85 test API, toàn vẹn dữ liệu | Đạt hết, 0 lỗ hổng |

Gia cố thêm: bắt sự kiện lỗi của connection pool (`config/database.ts`) và ghi log Promise bị từ chối không ai bắt (`server.ts`) để một lỗi kết nối bất ngờ không làm dừng cả backend.

## Kiểm tra lần 3 (13/11/2026)

**Ảnh**: xem lại cả 120 ảnh (ảnh đại diện + bộ sưu tập) theo từng địa điểm: tất cả đúng chỗ, không còn ảnh sai chủ thể. Viết lại 3 chú thích còn chung chung ở Hồ Tây ("Hồ Tây", "Bờ Hồ Tây", "Chiều Hồ Tây" → hoa giấy bên hồ, hàng cọ ven hồ, chùa Trấn Quốc lúc chiều tà).

**Nội dung**: bổ sung mốc lịch sử cho 4 địa điểm còn thiếu (Hồ Tây, Bảo tàng Dân tộc học, phố Tạ Hiện, Phố sách) và thêm mốc cho 4 nơi còn ít (Quảng trường Ba Đình, Bảo tàng Lịch sử Quốc gia, Bảo tàng Mỹ thuật, Nhà hát Múa rối Thăng Long); mỗi địa điểm đủ 4 thông tin nhanh. Bỏ chi tiết "phố Tạ Hiện tên cũ là Hàng Guột" vì không tìm được nguồn xác nhận, thay bằng tên thời Pháp (Rue Géraud) và năm đổi tên 1945. Dữ liệu nằm trong `database/10_attraction_guide.sql` (đã gộp vào `02_seed.sql`, `06_attraction_details.sql`).

**Trang chi tiết**: thêm thanh mục lục dính + nút Chia sẻ; trên điện thoại tăng lớp tối sau tên địa điểm (ảnh sáng như Bảo tàng Dân tộc học trước đây làm chữ khó đọc). **Icon**: "Ít đi bộ" đổi 🦶 → 🚶.

**Database / backend**:

| Kiểm tra | Kết quả |
|---|---|
| Cài database mới từ đầu (`01` + `02` trên DB tạm) | 20 bảng, đủ dữ liệu, 0 xe trùng lịch |
| Nâng cấp DB đang chạy (`10_attraction_guide.sql`) | Đạt, chạy lại nhiều lần vẫn an toàn |
| Toàn vẹn dữ liệu (29 nhóm truy vấn) | Không có vi phạm |
| Test API (`api-test.bat`) | 86/86, thêm kiểm tra cả 20 địa điểm đủ thông tin nhanh, mốc lịch sử, 5 ảnh |
| Test tìm đường, type-check, build, `npm audit` | 13/13, 0 lỗi, 0 lỗ hổng |
| Tải đồng thời (`stability-test.bat`) | 2.000 request đọc p95 277 ms; 200 lần tìm đường p95 889 ms; 5 lần thanh toán cùng lúc chỉ 1 lần trừ tiền |
| Tắt SQL Server 10 giây | Backend không sập, trả 503; tự kết nối lại sau 11,5 giây |

`api-test.bat` nay tự dọn trạm / tuyến thử (mã `BUS-TEST…`, `BUSTEST…`) bằng `database/99_cleanup_test_data.sql` sau khi chạy, để trang quản trị không còn dữ liệu rác. Từ lần 4, file này còn đưa **lịch sử quan tâm** của `an@` / `binh@` về dữ liệu mẫu (các lần thử trợ lý AI, tìm đường làm mục "Dành cho bạn" lệch) – nên chạy `api-test.bat` một lần trước buổi bảo vệ.

## Kiểm tra lần 4 (17/11/2026): chức năng AI

| Kiểm tra | Kết quả |
|---|---|
| Trợ lý: hỏi đường 1 chặng, nhiều điểm, theo tiêu chí, hỏi tiếp theo ngữ cảnh, giá vé, gợi ý, câu ngoài phạm vi | Đúng công cụ, giờ / giá khớp thẻ lộ trình, từ chối câu ngoài phạm vi |
| Lịch trình nhiều điểm | Thêm công cụ `plan_itinerary`: các chặng tính nối tiếp, cảnh báo nơi đã đóng cửa, có giờ mặt trời lặn; thẻ lộ trình đúng thứ tự chặng |
| Gemini quá tải / hết lượt miễn phí | Tự chuyển model (`gemini-3-flash-preview` → `gemini-3.6-flash` → `gemini-3.5-flash-lite`…), không lỗi với người dùng |
| `api-test.bat` | 98/98 (thêm 12 test cho AI và tìm đường tới Hồ Tây) |
| Type-check backend + frontend | 0 lỗi |

**Lỗi dữ liệu đã sửa**: tọa độ **Hồ Tây** nằm giữa lòng hồ nên tìm đường tới Hồ Tây phải đi bộ vòng hồ ~8,3 km (133 phút). Nay đặt ở bờ hồ trên đường Thanh Niên (điểm ngắm hoàng hôn): Hoàng thành → Hồ Tây còn 20 phút. Database đang chạy: `upgrade-db.bat` (có trong `09_data_fixes.sql`).

**Backend**: ghi log lỗi không bắt được (`uncaughtException`) và từng lượt gọi công cụ của trợ lý (`[AI] round …` trong `backend.log`) để dễ tìm nguyên nhân khi có sự cố.

## Tư vấn chọn vé và hỏi đáp địa điểm (18/11/2026)

| Kiểm tra | Kết quả |
|---|---|
| "Metro 2 lượt mỗi ngày, 5 ngày/tuần" | 43 lượt/tháng: vé lượt 645.000đ, vé tháng Metro 300.000đ → nên mua vé tháng, tiết kiệm 345.000đ |
| "Đi làm từ Cầu Giấy đến Hồ Gươm, thứ 2 – thứ 6" | Tìm đường thật: xe buýt 34 (52 phút), 43 lượt/tháng → nên mua vé tháng Bus 200.000đ, tiết kiệm 101.000đ; ghi kèm phương án nhanh nhất để so sánh (xe điện 40 phút nhưng 430.000đ/tháng) |
| Dựa trên vé đã mua (`an@example.com`) | Tính theo vé lượt 30 ngày qua của từng phương tiện; phương tiện không có vé tháng (xe đạp, xe điện) ghi "chỉ có vé lượt" |
| Trợ lý AI: "đi buýt 2 lượt mỗi ngày, có nên mua vé tháng?" | Gọi công cụ `recommend_ticket`, trả thẻ tư vấn ngay trong cuộc trò chuyện |
| Hỏi đáp Văn Miếu: giá vé → "còn trẻ em thì sao?" | Đúng giá trong DB (30.000đ / 15.000đ), hiểu câu hỏi nối tiếp (trẻ em dưới 15 tuổi miễn phí) |
| "Giờ này còn mở cửa không?" lúc 17:29 tháng 11 | Trả lời đã đóng cửa lúc 17:00 (giờ mùa đông). Lỗi cũ: dùng giờ mùa hè. Trợ lý lập lịch trình cũng dùng giờ theo mùa |
| `api-test.bat` | 109/109 (thêm 11 test: tư vấn vé, hỏi đáp, trợ lý gọi `recommend_ticket`; tự chờ rồi thử lại khi Gemini báo hết lượt / phút) |
| Type-check backend + frontend | 0 lỗi |

## Giao diện mới và chế độ tối (18/11/2026)

| Phần | Thay đổi |
|---|---|
| Chế độ Sáng / Tối | Nút mặt trời / mặt trăng trên thanh menu (và trong thanh bên trang quản trị, mục **Giao diện** ở trang Tài khoản): **Sáng**, **Tối**, **Theo thiết bị** (tự đổi theo cài đặt máy). Lựa chọn được nhớ trên trình duyệt; trang mở ra đúng chế độ ngay, không bị nháy trắng. Chế độ tối dùng nền xanh mực đậm, màu vàng hoàng thành sáng hơn; bản đồ OpenStreetMap được đổi sang tông tối, mã QR vé và chuyển khoản luôn nền trắng để quét được. |
| Hệ màu | Toàn bộ màu nằm ở biến CSS (`--bg`, `--surface`, `--heading`, `--primary`, `--success-bg`…) đầu `frontend/src/index.css`; `[data-theme='dark']` đổi bộ biến. Thêm màu mới thì dùng biến, không đặt mã màu cứng trong component. |
| Trang chủ | Ô tìm điểm đến ngay đầu trang (gợi ý theo tên, tìm không dấu, phím mũi tên + Enter) → mở bản đồ tìm đường; nút đi nhanh tới các điểm phổ biến. Hình nền là 4 tuyến Bus / Metro / xe đạp / xe điện theo đúng màu trên bản đồ, vẽ ra một lần khi mở trang (tắt nếu máy bật giảm chuyển động). |
| Thanh menu | Icon cho từng mục, menu tài khoản (Tài khoản, Vé của tôi, Lịch sử, Quản trị, Đăng xuất), trên điện thoại gọn trong nút ☰. Có liên kết "Bỏ qua thanh điều hướng" cho người dùng bàn phím. |
| Thẻ địa điểm | Loại địa điểm và số ảnh đặt trên ảnh; địa chỉ, giờ mở cửa, thời gian tham quan, giá vé dùng icon nét thay cho emoji. |
| Đăng nhập / Đăng ký | Khung 2 cột: bên trái giới thiệu ngắn trên nền 4 tuyến, bên phải là form (điện thoại chỉ hiện form). |
| Khác | Nút, ô nhập, thẻ, tab tiêu chí tìm đường kiểu mới; popup và nút zoom bản đồ theo giao diện; bảng quản trị không còn tiêu đề in hoa. |

File mới: `context/ThemeContext.tsx`, `components/HeaderMenus.tsx` (menu giao diện + tài khoản), `components/TransitLines.tsx`, `components/AuthShell.tsx`.

## Bổ sung 14 địa điểm (17/11/2026)

Tham khảo bài [Hà Nội đi đâu chơi? TOP 30++ địa điểm](https://www.vietnamairlines.com/th/vi/plan-book/travel/travel-guide/ha-noi-di-dau-choi) của Vietnam Airlines; chỉ lấy các điểm trong nội thành có trạm xe buýt / Metro / xe đạp công cộng gần (bỏ quán cà phê, karaoke, photobooth và các điểm ngoại thành không có tuyến của hệ thống).

| Nhóm | Địa điểm |
|---|---|
| Tham quan | Nhà thờ Lớn Hà Nội, Bảo tàng Hồ Chí Minh, Khu di tích Phủ Chủ tịch, Phố sách Đinh Lễ, Hồ Trúc Bạch, Công viên Thống Nhất, Công viên Thủ Lệ (Vườn thú Hà Nội), Bảo tàng Thiên nhiên Việt Nam |
| Vui chơi gia đình | Công viên nước Hồ Tây, Thủy cung Times City, Landmark 72 – Đài quan sát Sky72, Lotte Mall Tây Hồ, Vincom Center Bà Triệu, Vincom Mega Mall Royal City |

- Mỗi nơi đủ giới thiệu, lịch sử, điểm nổi bật, giờ mở cửa, giá vé (tra cứu 11/2026 – có thể thay đổi), thời gian tham quan, kinh nghiệm, ≥ 4 thông tin nhanh, ≥ 2 mốc lịch sử.
- Tọa độ đặt ở lối vào / bờ hồ (không đặt giữa hồ), trạm gần nhất tính bằng **quãng đường đi bộ thật** (OSRM) – 3 trạm xe buýt, ga Metro nếu ≤ 1,2 km, trạm xe đạp / xe điện.
- Ảnh: 9 địa điểm có ảnh đại diện + 5 ảnh bộ sưu tập từ Wikimedia Commons (ghi nguồn đầy đủ); Công viên nước Hồ Tây có 1 ảnh. **Phố sách Đinh Lễ, Bảo tàng Thiên nhiên, Thủy cung Times City, Lotte Mall Tây Hồ chưa có ảnh giấy phép tự do** nên hiển thị nền màu theo loại địa điểm – có thể bổ sung ảnh tự chụp trong trang quản trị (Địa điểm → Sửa → Bộ sưu tập).
- Loại địa điểm mới: Công viên 🌳, Vui chơi 🎢, Mua sắm 🛍️; nhà thờ dùng icon ⛪. Trợ lý AI hiểu cả tên gọi quen thuộc ("vườn thú", "nhà sàn Bác", "Keangnam", "Lotte Tây Hồ"...).
- Database đang chạy: `upgrade-db.bat` (có `12_more_attractions.sql`); cài mới: đã gộp vào `02_seed.sql` (mục 10b).

