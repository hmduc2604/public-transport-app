# API Contract – `/api/v1`

Base URL: `http://localhost:5000/api/v1`
Xác thực: header `Authorization: Bearer <token>` (🔒 = cần đăng nhập, 👑 = cần ADMIN)

**Thành công**
```json
{ "success": true, "data": {}, "message": "Success" }
```
**Lỗi**
```json
{ "success": false, "message": "Route not found", "errorCode": "ROUTE_NOT_FOUND" }
```
Lỗi validate có thêm `details`: `{ "email": "Email không hợp lệ" }`.

| HTTP | Khi nào |
|---|---|
| 200 / 201 | Thành công / Tạo mới |
| 400 | `VALIDATION_ERROR`, `INVALID_ID`, `INVALID_LOCATION`, `OUT_OF_SERVICE_AREA` (toạ độ ngoài Hà Nội), `INVALID_TIME` (giờ không phải HH:mm), `INVALID_TRIP_TIME`, `CARD_INVALID`... |
| 401 | `UNAUTHORIZED`, `INVALID_TOKEN`, `TOKEN_EXPIRED`, `INVALID_CREDENTIALS`, `ACCOUNT_INACTIVE` (tài khoản vừa bị khóa – token cũ mất hiệu lực ngay) |
| 403 | `FORBIDDEN`, `ACCOUNT_LOCKED`, `TICKET_FORBIDDEN`, `ORDER_FORBIDDEN` |
| 404 | `*_NOT_FOUND`, `NO_ROUTE_FOUND`, `API_NOT_FOUND` |
| 409 | `EMAIL_EXISTS`, `DUPLICATE_VALUE`, `CONSTRAINT_VIOLATION`, `ORDER_ALREADY_PAID`, `VEHICLE_SCHEDULE_CONFLICT` (xe đã có chuyến trùng giờ) |
| 429 | `TOO_MANY_LOGIN_ATTEMPTS` (sai mật khẩu 10 lần / 15 phút / IP), `TOO_MANY_CODE_REQUESTS` (gửi mã quá 10 lần / giờ / IP), `TOO_MANY_REQUESTS` (trợ lý AI quá 40 câu / 10 phút / tài khoản), `AI_RATE_LIMITED` (hết lượt gọi Gemini); header `Retry-After` |
| 502 / 503 / 504 | `AI_ERROR` / `AI_NOT_CONFIGURED`, `AI_KEY_INVALID`, `AI_UNAVAILABLE` / `AI_TIMEOUT` – chỉ ở các API trợ lý AI |
| 500 / 503 | `INTERNAL_ERROR` / `DB_UNAVAILABLE` (mất kết nối database; backend tự kết nối lại khi database chạy lại) |

---

## 1. Auth & User (Người 2)

| Method | URL | Body / Query | Ghi chú |
|---|---|---|---|
| POST | `/auth/register` | `{ fullName, email, password, phone? }` | → `{ token, user }` |
| POST | `/auth/login` | `{ email, password }` | → `{ token, user }` |
| POST | `/auth/logout` | | JWT stateless, client xóa token |
| GET 🔒 | `/users/me` | | Hồ sơ |
| PUT 🔒 | `/users/me` | `{ fullName?, phone? }` | |
| PUT 🔒 | `/users/me/password` | `{ currentPassword, newPassword }` | |

`user` = `{ id, userId, name, fullName, email, phone, role: "USER"|"ADMIN", status, createdAt }`

## 2. Transport (Người 1 – Map)

| Method | URL | Query | Ghi chú |
|---|---|---|---|
| GET | `/transport-types` | | kèm `mode`: BUS / METRO / BICYCLE / ELECTRIC_VEHICLE |
| GET | `/stations` | `transportTypeId?`, `search?` | |
| GET | `/stations/nearby` | `lat`, `lng`, `radius`(km, mặc định 1), `limit`, `transportTypeId?` | kèm `distanceMeters` |
| GET | `/stations/:id` | | kèm `routes[]`, `attractions[]` |
| GET | `/search/stations` | `keyword` | |
| GET | `/routes` | `transportTypeId?`, `search?` | |
| GET | `/routes/:id` | | kèm `stations[]` theo thứ tự |
| GET | `/routes/:id/stations` | | |
| GET | `/routes/:id/trips` | `upcoming=true?` | lịch chạy |
| GET | `/trips/:id` | | kèm `stopTimes[]` |

## 3. Attractions (Người 1 – Khám phá)

| Method | URL | Query |
|---|---|---|
| GET | `/attractions` | `category?`, `search?`, `sort=popular|name|newest` (kết hợp được) |
| GET | `/attractions/featured` | `limit` |
| GET | `/attractions/categories` | |
| GET | `/attractions/recommend` | `categories=Di tích,Bảo tàng`, `lat?`, `lng?`, `limit` → điểm `S = 0.5P + 0.3C + 0.2D` (công thức cũ, vẫn giữ) |
| GET | `/attractions/suggestions` | **Gợi ý theo sở thích (AI)** – xem mục 7. Không bắt buộc đăng nhập; có token thì cá nhân hóa |
| GET | `/attractions/nearby` | `lat`, `lng`, `radius`, `limit` |
| GET | `/attractions/:id` | kèm `nearbyStations[]`; `highlights` là mảng |
| GET | `/attractions/:id/nearby-stations` | |

`GET /attractions/:id` trả thêm cho trang chi tiết:

| Trường | Kiểu | Ý nghĩa |
|---|---|---|
| `highlights`, `tips` | `string[]` | Điểm nổi bật, kinh nghiệm tham quan |
| `facts` | `{ label, value }[]` | Thông tin nhanh (năm xây dựng, xếp hạng...) – cột `Facts`, mỗi dòng `nhãn \| giá trị` |
| `timeline` | `{ year, event }[]` | Mốc lịch sử theo thứ tự – cột `Timeline`, mỗi dòng `năm \| sự kiện`; chưa có thì `[]` |
| `nearbyStations[].routes` | `{ routeId, routeCode, routeName }[]` | Các tuyến đang chạy dừng tại trạm (trạm xe đạp / xe điện: `[]`) |
| `nearbyAttractions` | `{ attractionId, name, category, imageUrl, hoursSummary, priceFrom, imageCount, distanceMeters, walkingMinutes }[]` | Tối đa 4 địa điểm khác trong bán kính 3 km, gần nhất trước |
| `images` | `{ imageUrl, caption, credit, sourceUrl }[]` | Bộ sưu tập ảnh (kèm tác giả / giấy phép) |

## 4. Routing – API quan trọng nhất

`POST /routing/search` (đăng nhập không bắt buộc; nếu có token + vé tháng thì chặng đó được tính 0đ)

```json
{
  "origin":      { "latitude": 21.0255, "longitude": 105.8463 },
  "destination": { "attractionId": 16 },
  "preference":  "FASTEST",
  "departureTime": "08:00"
}
```
Mỗi điểm truyền **1 trong 3**: `{latitude, longitude}` | `{stationId}` | `{attractionId}` (+ `name` tùy chọn).
`preference`: `FASTEST` | `CHEAPEST` | `LEAST_WALKING` | `FEWEST_TRANSFERS`.

Response `data`:
```json
{
  "origin": { "name": "...", "latitude": 21.0255, "longitude": 105.8463 },
  "destination": { "name": "Chùa Trấn Quốc", "latitude": 21.048, "longitude": 105.836, "attractionId": 16 },
  "preference": "FASTEST",
  "departureTime": "08:00",
  "routes": [
    {
      "id": "R1X2Y3",
      "preference": "FASTEST",
      "labels": ["FASTEST", "FEWEST_TRANSFERS"],
      "totalDuration": 32, "totalDistance": 4300, "totalFare": 5000, "fareToPay": 5000,
      "walkingDistance": 958, "walkingDuration": 12, "waitingTime": 2, "transfers": 0,
      "modes": ["WALK", "BICYCLE"],
      "summary": "Đi bộ → BIKE-SHARE → Đi bộ",
      "steps": [
        {
          "mode": "BUS", "routeId": 1, "routeCode": "BUS01", "routeName": "Hoàn Kiếm - Văn Miếu",
          "from": { "name": "Bờ Hồ Hoàn Kiếm", "latitude": 21.0285, "longitude": 105.8544, "stationId": 1 },
          "to":   { "name": "Văn Miếu", "latitude": 21.027, "longitude": 105.8357, "stationId": 4 },
          "stops": [ ... ], "numStops": 1,
          "duration": 8, "waitTime": 8, "distance": 2200, "fare": 10000, "coveredByPass": false,
          "nextDepartures": ["08:10", "08:30", "08:50"],
          "path": [[21.0285, 105.8544], [21.027, 105.8357]],
          "instruction": "Đi Xe buýt BUS01 từ Bờ Hồ Hoàn Kiếm đến Văn Miếu (1 trạm)"
        }
      ]
    }
  ],
  "stats": { "graphNodes": 94, "graphEdges": 292, "computeTimeMs": 4 }
}
```
- `path` = mảng `[lat, lng]` để frontend vẽ `Polyline`.
- Tối đa 3 phương án; phương án đầu luôn tối ưu theo `preference` đã chọn.
- Không có đường → 404 `NO_ROUTE_FOUND`.
- Alias cũ: `POST /routing/find`. Thông tin graph: `GET /routing/network`.

## 5. Ticket, Order, Payment, History (Người 2)

| Method | URL | Body / Query | Ghi chú |
|---|---|---|---|
| GET | `/ticket-types` | `type=SINGLE|MONTHLY?`, `transportTypeId?` | |
| POST 🔒 | `/orders` | `{ items: [{ ticketTypeId, quantity }] }` | Tạo đơn PENDING, giá lấy từ DB. Vé tháng tối đa 1/đơn, vé lượt tối đa 10 |
| POST 🔒 | `/tickets` | `{ ticketTypeId, quantity? }` | Mua nhanh 1 loại vé (tạo order) |
| GET 🔒 | `/orders/me` | | kèm `itemsSummary` |
| GET 🔒 | `/orders/:id` | | kèm `items[]`, `payments[]`, `tickets[]` |
| POST 🔒 | `/orders/:id/cancel` | | chỉ đơn PENDING |
| GET | `/payments/methods` | | `{ card, bankTransfer: { enabled, bankName, expiryMinutes, autoConfirm }, banks[] }` |
| POST 🔒 | `/payments/card` | `{ orderId, cardKind: "INTERNATIONAL"|"DOMESTIC", cardNumber, cardHolder, expiry: "MM/YY", cvv? (quốc tế), bankBin? (nội địa) }` | 201 SUCCESS → Order PAID + sinh vé (1 transaction) · 200 FAILED (thẻ bị từ chối) · 400 `CARD_INVALID` + `details` theo từng trường |
| POST 🔒 | `/payments/bank-transfer` | `{ orderId }` | Tạo / dùng lại giao dịch **PENDING**: `qrImage`, `qrPayload` (VietQR), `bank`, `amount`, `transferContent`, `expiresAt`, `secondsLeft`. 503 `TRANSFER_NOT_CONFIGURED` nếu admin chưa nhập tài khoản |
| GET 🔒 | `/payments/:id` | | Trạng thái giao dịch (frontend hỏi định kỳ); SUCCESS kèm `ticketIds` |
| POST 🔒 | `/payments/:id/transferred` | | Khách báo đã chuyển → vẫn PENDING (ghi `customerNotifiedAt`) |
| POST | `/payments/webhooks/sepay` | JSON của SePay, header `Authorization: Apikey <SEPAY_API_KEY>` | Tiền vào đúng nội dung + đủ tiền → SUCCESS + sinh vé. Luôn trả `{ success: true }` |
| GET 🔒 | `/tickets/me` | `status?` (alias `/tickets/my`) | Tự chuyển vé quá hạn → EXPIRED |
| GET 🔒 | `/tickets/:id` | | `qrPayload`, `isValidNow`, `remainingMinutes` |
| GET 🔒 | `/tickets/:id/qr` | | `{ payload, image: "data:image/png;base64,..." }` |
| GET 🔒 | `/trip-histories` | | `routeData` đã parse JSON |
| POST 🔒 | `/trip-histories` | `{ origin, destination, routeData?, startedAt?, completedAt? }` | |
| PATCH 🔒 | `/trip-histories/:id/complete` | | |
| DELETE 🔒 | `/trip-histories/:id` | | |

Thanh toán thẻ trả: `{ paymentId, orderId, amount, status: "SUCCESS"|"FAILED", message, cardBrand, cardLast4, ticketIds, order }`.
Trạng thái giao dịch: `PENDING` → `SUCCESS` | `FAILED` (bị từ chối) | `EXPIRED` (quá hạn, chưa báo chuyển) | `CANCELLED` (hủy đơn / đã trả bằng cách khác).

## 6. Admin 👑 (Người 3) – `/admin/*`

CRUD chuẩn: `GET /x` · `GET /x/:id` · `POST /x` · `PUT /x/:id` (gửi field nào cập nhật field đó) · `DELETE /x/:id`

| Resource | Lọc (query) | DELETE |
|---|---|---|
| `/admin/transport-types` | | xóa mềm (INACTIVE) |
| `/admin/vehicles` | `transportTypeId`, `status`, `search` | xóa thật (409 nếu đã có chuyến) |
| `/admin/stations` | `transportTypeId`, `search` | xóa mềm |
| `/admin/routes` | `transportTypeId`, `search` | xóa mềm |
| `/admin/trips` (alias `/admin/schedules`) | `routeId`, `status` | xóa thật (kèm StopTimes) |
| `/admin/ticket-types` | | xóa mềm (ngừng bán) |
| `/admin/fare-rules` (alias `/admin/fares`) | `transportTypeId` | xóa thật |
| `/admin/attractions` | `category`, `search` | xóa mềm (ẩn) |

Bổ sung:

| Method | URL | Body / Query |
|---|---|---|
| GET | `/admin/routes/:id/stations` | |
| PUT | `/admin/routes/:id/stations` | `{ stations: [{ stationId, distanceFromStart? }] }` (≥ 2 trạm, theo thứ tự) |
| POST | `/admin/routes` | có thể kèm `stations: [...]` |
| POST | `/admin/trips` | `{ routeId, vehicleId, tripCode, departureTime:"HH:mm", arrivalTime:"HH:mm" }` → tự sinh StopTimes |
| POST/PUT | `/admin/attractions` | có thể kèm `stations: [{ stationId, walkingDistance, walkingDuration }]`; `highlights` cách nhau bởi `\|`; `facts` (≤ 4000 ký tự) / `timeline` (≤ 8000): mỗi dòng `nhãn \| giá trị`, gửi `null` để xóa |
| GET | `/admin/users` | `search`, `role`, `status`, `page`, `pageSize` → phân trang |
| GET / PUT | `/admin/users/:id` | `{ fullName?, phone?, role?, status: "ACTIVE"|"LOCKED" }` (không tự khóa/hạ quyền chính mình) |
| GET | `/admin/orders` | `search`, `status`, `page`, `pageSize` |
| GET | `/admin/orders/:id` · POST `/admin/orders/:id/cancel` | |
| GET | `/admin/tickets` | `search`, `status`, `type`, `page`, `pageSize` |
| PATCH | `/admin/tickets/:id/status` | `{ status }` |
| POST | `/admin/tickets/verify` | `{ qrData, markUsed? }` → `{ valid, reason, ticket }` (vé lượt hợp lệ → USED) |
| GET | `/admin/payments` | `method` (CARD/BANK_TRANSFER), `status`, `search` (mã đơn, nội dung CK, email), `page`, `pageSize` |
| POST | `/admin/payments/:id/confirm` | `{ bankReference? }` → xác nhận đã nhận tiền chuyển khoản, phát hành vé |
| POST | `/admin/payments/:id/reject` | `{ note? }` → FAILED |
| GET / PUT / DELETE | `/admin/payment-settings` | PUT `{ bankBin, accountNo, accountName, transferExpiryMinutes? }` – tài khoản nhận chuyển khoản; DELETE = tắt chuyển khoản |
| GET | `/admin/statistics` | `days` (mặc định 30) → `overview`, `revenueByDay`, `ticketsByType`, `ticketsByStatus`, `transportSummary`, `topDestinations`, `recentOrders` |
| POST | `/admin/routing/rebuild` | Xây lại graph tìm đường ngay |

Danh sách phân trang trả về: `{ items, total, page, pageSize, totalPages }`.

## 7. Trợ lý AI và gợi ý theo sở thích (Gemini)

Cần `GEMINI_API_KEY` trong `backend/.env.local`. Không có khóa: gợi ý vẫn chạy bằng từ khóa (`mode: "basic"`), trợ lý trả `503 AI_NOT_CONFIGURED`.

| Method | URL | Body / Query | Ghi chú |
|---|---|---|---|
| GET | `/attractions/suggestions` | `q?` (sở thích, ≤ 300 ký tự), `categories?`, `lat?`, `lng?`, `limit?` (≤ 12) | Đăng nhập tùy chọn; giới hạn 60 lần / 10 phút |
| GET 🔒 | `/assistant/status` | | `{ configured, model, embeddingModel, availableModels }` |
| POST 🔒 | `/assistant/chat` | `{ message, history?, location? }` | Giới hạn 40 câu / 10 phút / tài khoản |

**`GET /attractions/suggestions`** – điểm mỗi địa điểm:

`S = 0.5·Q + 0.25·H + 0.15·C + 0.15·D + 0.1·P` (thiếu thành phần nào thì chia lại theo tổng trọng số còn lại)

| Ký hiệu | Ý nghĩa |
|---|---|
| Q | Độ giống (cosine) giữa vector sở thích `q` và vector mô tả địa điểm (`gemini-embedding-001`, 768 chiều, lưu ở bảng `AttractionEmbeddings`) |
| H | Độ giống với "hồ sơ sở thích" = trung bình có trọng số vector các nơi người dùng đã quan tâm (bảng `AttractionViews`: tìm đường tới ×2, hỏi trợ lý ×1,5, xem chi tiết ×1; giảm một nửa sau mỗi 30 ngày) |
| C, D, P | Đúng loại đã chọn; gần vị trí (0 điểm khi ≥ 5 km); độ phổ biến |

```json
{ "mode": "ai", "query": "kiến trúc Pháp", "basedOn": ["Văn Miếu - Quốc Tử Giám"],
  "items": [{ "attractionId": 5, "name": "Nhà hát Lớn Hà Nội", "score": 0.82, "reason": "…", "reasons": ["…"], "seen": false, "distanceMeters": null, "...": "…" }] }
```

**`POST /assistant/chat`**

```json
// Request
{ "message": "Lên lịch nửa ngày: Văn Miếu → Hoàng thành → Hồ Tây ngắm hoàng hôn",
  "history": [{ "role": "user", "text": "…" }, { "role": "assistant", "text": "…", "routes": [{ "from": "…", "to": "…", "fromRef": "attraction:11", "toRef": "attraction:7" }] }],
  "location": { "latitude": 21.0285, "longitude": 105.8542 } }
// Response data
{ "reply": "…tiếng Việt…", "routes": [{ "id": 1, "fromRef": "attraction:11", "toRef": "attraction:7", "from": "…", "to": "…", "preference": "FASTEST", "departureTime": "14:00", "routes": [/* tối đa 3 phương án như /routing/search, bỏ path */] }],
  "places": [{ "attractionId": 7, "name": "…", "imageUrl": "…", "hoursSummary": "…", "priceFrom": "…", "reason": "…" }],
  "toolCalls": [{ "name": "plan_itinerary", "ok": true }], "model": "gemini-3.6-flash", "elapsedMs": 6400 }
```

Công cụ Gemini được gọi (function calling): `find_places`, `plan_route`, `plan_itinerary` (lịch trình nhiều điểm, các chặng tính nối tiếp), `suggest_places`, `get_place_info`, `get_ticket_prices`. Mọi lộ trình, giờ, giá đều do backend tính – AI chỉ hiểu câu hỏi và diễn giải kết quả. Ref địa điểm: `attraction:ID`, `station:ID`, `geo:lat,lng`, `me`.

## Ghi chú cho cả nhóm
- JSON dùng **camelCase** (`stationId`, `stationName`...), repository đã alias từ cột PascalCase của SQL Server. Code cũ đọc `StationId` cần đổi sang `stationId`.
- Ngày giờ trả về dạng ISO; giờ trong lịch trình (`departureTime`) dạng `"HH:mm"`.
