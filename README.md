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
│   ├── 02_seed.sql              Dữ liệu mẫu (27 trạm, 17 tuyến, ~700 chuyến, 20 điểm tham quan...)
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
6. **Mua vé cho lộ trình** → vé lượt được chọn sẵn → **Thanh toán (mô phỏng)** → **QR e-ticket**.
7. Đăng nhập `admin@example.com` → Dashboard thống kê → Vé & Soát vé: dán nội dung QR → vé lượt chuyển **Đã dùng**.
8. Admin thêm trạm/tuyến mới → graph tìm đường tự xây lại → tìm đường thấy tuyến mới.
