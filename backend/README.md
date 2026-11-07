# Backend – public-transport-api

Node.js + Express + TypeScript + SQL Server (`mssql`) + JWT. Đây là phần **Người 3** phụ trách (kiến trúc, DB, JWT/RBAC, Admin, thống kê), đồng thời chứa API cho Người 1 (Map/Routing) và Người 2 (User/Ticket/Payment).

## Chạy

```bash
npm install
copy .env.example .env     # sửa DB_USER, DB_PASSWORD (xem README gốc, mục "Kết nối SQL Server")
npm run db:check           # kiểm tra kết nối + 17 bảng
npm run dev                # http://localhost:5000/api/v1
```

| Lệnh | Tác dụng |
|---|---|
| `npm run dev` | Chạy dev, tự reload khi sửa code |
| `npm run build` / `npm start` | Biên dịch ra `dist/` và chạy bản build |
| `npm run typecheck` | Kiểm tra kiểu TypeScript |
| `npm run test:routing` | Test Dijkstra + multi-modal trên dữ liệu seed (không cần DB) |
| `npm run db:check` | Test kết nối SQL Server, đếm bản ghi |
| `npm run db:reset-passwords` | Đặt lại mật khẩu `123456` cho tài khoản có hash cũ không hợp lệ |

## Kiến trúc phân lớp

```
Request
  │
  ▼
routes/        Khai báo URL + middleware (authenticate, requireAdmin)
  │
  ▼
controllers/   Nhận request → validate → gọi service → trả { success, data, message }
  │            (KHÔNG chứa nghiệp vụ, KHÔNG chứa SQL, KHÔNG chứa Dijkstra)
  ▼
services/      Nghiệp vụ: kiểm tra quyền sở hữu, giá lấy từ DB, cache graph, invalidate...
  │
  ├──► algorithms/   Graph + Dijkstra + Multi-modal planner (thuần TypeScript, test độc lập)
  ▼
repositories/  Câu SQL (tham số hóa @param), map cột PascalCase → camelCase
  │
  ▼
SQL Server (PublicTransportDBV2)
```

```
src/
├── app.ts / server.ts            Khởi tạo Express, CORS, morgan, error handler
├── config/
│   ├── env.ts                    Đọc .env
│   ├── database.ts               Connection pool mssql (dùng chung)
│   ├── bootstrap.ts              Băm bcrypt mật khẩu seed 'SEED:...' khi khởi động
│   └── routing.config.ts         Tham số thuật toán: tốc độ, thời gian chờ, giá mặc định, bán kính...
├── middleware/
│   ├── auth.middleware.ts        JWT: authenticate / optionalAuth / signToken
│   ├── admin.middleware.ts       RBAC: requireRole('ADMIN')
│   └── error.middleware.ts       Lỗi → JSON chuẩn; map lỗi SQL 2627/547 → 409
├── utils/                        AppError, apiResponse, asyncHandler, validators, geo, qr, sqlHelpers, time
├── validations/schemas.ts        Schema validate input từng API
├── types/                        Kiểu dữ liệu dùng chung
├── algorithms/
│   ├── graph.ts                  Đồ thị trạng thái (W:station, R:line:station)
│   ├── dijkstra.ts               Dijkstra + MinHeap
│   └── routing.ts                Pipeline: nearest stations → weight theo tiêu chí → Dijkstra → Top 3
├── repositories/                 user, transport, station, route, trip, attraction, ticket, order,
│                                 payment, fareRule, tripHistory, transitNetwork, statistics
├── services/                     auth, transport, attraction, routing, ticket, order, tripHistory, admin
├── controllers/                  auth, transport, attraction, routing, ticket, admin
└── routes/                       *.routes.ts + index.ts (gắn vào /api/v1)
```

## Những điểm kỹ thuật nên trình bày khi bảo vệ

**1. API contract thống nhất** – mọi response đều `{ success, data, message }`; lỗi là `{ success: false, message, errorCode }` với HTTP status 400/401/403/404/409/500 (xem `docs/API.md`).

**2. Bảo mật**
- Mật khẩu băm **bcrypt** (10 rounds); JWT ký bằng `JWT_SECRET`, hết hạn theo `JWT_EXPIRES_IN`.
- RBAC: toàn bộ `/api/v1/admin/*` qua `authenticate + requireAdmin`.
- Mọi câu SQL dùng tham số `@param` → chống SQL injection.
- `validate()` chỉ giữ các field có trong schema → client không tự gửi `role: 'ADMIN'` khi đăng ký được.
- Giá vé luôn lấy từ DB khi tạo đơn, không tin giá từ client.
- QR vé có chữ ký **HMAC-SHA256** (`PTA|<mã vé>|<chữ ký>`) → không làm giả QR được.

**3. Toàn vẹn dữ liệu**
- Thanh toán chạy trong **1 transaction** + khóa dòng `UPDLOCK`: Payment SUCCESS → Order PAID → sinh Tickets. Lỗi giữa chừng → rollback, không bao giờ "trừ tiền mà không có vé", không thanh toán 2 lần.
- Xóa mềm (`Status = 'INACTIVE'`) cho Trạm, Tuyến, Loại vé, Loại phương tiện, Điểm tham quan → không làm vỡ lịch sử đơn hàng/vé.
- Xóa cứng Phương tiện/Chuyến/Bảng giá; nếu đang được tham chiếu SQL báo lỗi 547 → API trả 409 `CONSTRAINT_VIOLATION`.

**4. Routing (phối hợp với Người 1)**
- Graph xây 1 lần từ DB rồi **cache trong RAM** (10 phút); Admin sửa trạm/tuyến/giá → `routingService.invalidate()` → lần tìm sau xây lại.
- Đồ thị trạng thái: mỗi trạm tách thành node "đứng ở trạm" và "đang ngồi trên tuyến X" → đếm đúng số lần chuyển tuyến, cộng giá vé & thời gian chờ đúng lúc lên xe.
- 4 tiêu chí = 4 hàm trọng số cho cùng 1 Dijkstra:

| Tiêu chí | Trọng số mỗi cạnh |
|---|---|
| FASTEST | thời gian (phút) |
| CHEAPEST | giá vé + 30đ/phút + 5đ/m đi bộ |
| LEAST_WALKING | mét đi bộ + 3 × phút |
| FEWEST_TRANSFERS | thời gian + 20 phút phạt mỗi lần lên xe |

- Sinh ứng viên: chạy 4 tiêu chí + "né tuyến đã dùng" để có phương án thay thế → loại trùng → xếp hạng → **Top 3**, gắn nhãn.
- Đăng nhập + có vé tháng còn hạn → chặng đó tính 0đ (`fareToPay`).
- Xe đạp/xe điện: không có tuyến cố định — lấy xe ở trạm này, trả ở trạm cùng loại bất kỳ trong 4 km (trạm xe đạp và xe điện dùng chung vị trí).
- Mỗi loại phương tiện luôn có tối đa 2 trạm gần nhất được xét làm điểm lên/xuống (`perModeAccessStations`), để điểm dừng bus dày đặc không che mất ga Metro / trạm xe đạp.
- **Chỉ đường theo đường phố thật** (`services/roadGeometry.service.ts`, máy chủ OSRM chạy trên máy bằng Docker — `osrm-setup.bat`; dự phòng `routing.openstreetmap.de`):
  1. Trước Dijkstra: 1 request ma trận (`/table`, profile đi bộ) lấy quãng đường đi bộ thực tế từ điểm đi/đến tới các trạm ứng viên.
  2. Sau Dijkstra: vẽ lại từng bước theo đường phố — đi bộ (`routed-foot`), xe đạp/xe điện (`routed-bike`), xe buýt (`routed-car` đi qua lần lượt các trạm); Metro nối thẳng giữa các ga (tuyến trên cao).
  3. Tính lại tổng thời gian / quãng đường đi bộ rồi **xếp hạng lại theo tiêu chí** người dùng chọn (Nhanh nhất / Rẻ nhất / Ít đi bộ / Ít chuyển tuyến).
  - Có cache, gộp request trùng, giới hạn 6 request đồng thời; máy chủ lỗi → bỏ qua 60 giây và thử máy chủ tiếp theo; tất cả lỗi → ước lượng đường chim bay (`stats.roadGeometry = false`).
  - Bỏ phương án "chỉ đi bộ" dài hơn 1,5 km khi đã có phương án đi xe. Tắt hẳn bằng `ROAD_ROUTING=false`; đổi máy chủ bằng `OSRM_FOOT_URL`, `OSRM_BIKE_URL`, `OSRM_CAR_URL`.
- Graph seed: 571 trạm → ~1.300 node, ~9.500 cạnh; mỗi lần tìm ~5–35 ms.

## Thêm 1 API mới (quy trình chuẩn)
1. `repositories/x.repository.ts` – viết SQL.
2. `services/x.service.ts` – nghiệp vụ, `throw AppError.notFound(...)` khi cần.
3. `controllers/x.controller.ts` – `validate(req.body, schema)` → gọi service → `ok(res, data)`.
4. `routes/x.routes.ts` – khai báo URL, bọc `asyncHandler`, thêm `authenticate`/`requireAdmin` nếu cần.
5. Gắn router vào `routes/index.ts`, ghi vào `docs/API.md`.
