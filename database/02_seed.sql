/* =====================================================================
   PUBLIC TRANSPORT MULTI-MODAL - SEED DATA
   File   : 02_seed.sql   (chay SAU 01_database.sql)
   Khu vuc: Ha Noi (noi thanh + Ha Dong, Cau Giay, Bac Tu Liem, Long Bien...)

   Tai khoan demo (mat khau tat ca: 123456)
     - an@example.com     (USER)
     - binh@example.com   (USER)
     - cuong@example.com  (USER)
     - admin@example.com  (ADMIN)

   Nguon vi tri tram (cap nhat):
     - Xe buyt : cac tuyen trong https://vinpearl.com/vi/ban-do-xe-bus-ha-noi
                 (so hieu tuyen, gio chay, gia ve 7.000d). Vi tri diem dung va
                 thu tu dung lay tu OpenStreetMap (route relation tung tuyen)
                 vi bai Vinpearl khong co toa do.
     - Metro   : toa do ga tuyen 2A, 3.1 tu https://metrohanoi.vn/line/map
     - Xe dap  : 49 tram TNGo trong bai dantocphattrien.vietnamnet.vn
                 (toa do tu OpenStreetMap - amenity=bicycle_rental)
     - Xe dien : dung CHUNG vi tri voi tram xe dap (BIKE-xxx <-> EV-xxx)

   Ghi chu:
     - PasswordHash dang 'SEED:<mat khau>' -> backend tu bam bcrypt khi
       khoi dong (src/config/bootstrap.ts), sau do dang nhap duoc.
     - TicketTypes duoc insert TRUOC OrderDetails/Tickets.
     - Trips sinh tu dong theo tan suat (headway) + StopTimes theo toc do.
   ===================================================================== */
-- Bat buoc cho unique index co dieu kien (UX_Users_Phone); sqlcmd mac dinh tat QUOTED_IDENTIFIER
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO


USE PublicTransportDBV2;
GO

SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------------
   1. Users  (mat khau: 123456 - backend se bam bcrypt luc khoi dong)
   --------------------------------------------------------------------- */
INSERT INTO Users (FullName, Email, PasswordHash, Phone, Role, Status) VALUES
(N'Nguyễn Văn An',  'an@example.com',    'SEED:123456', '0901000001', 'USER',  'ACTIVE'),
(N'Trần Thị Bình',  'binh@example.com',  'SEED:123456', '0901000002', 'USER',  'ACTIVE'),
(N'Lê Minh Cường',  'cuong@example.com', 'SEED:123456', '0901000003', 'USER',  'ACTIVE'),
(N'Admin System',   'admin@example.com', 'SEED:123456', '0901000000', 'ADMIN', 'ACTIVE');
-- Tai khoan demo coi nhu da xac nhan email + SĐT
UPDATE Users SET EmailVerifiedAt = SYSDATETIME(), PhoneVerifiedAt = SYSDATETIME();
GO

/* ---------------------------------------------------------------------
   2. TransportTypes  (ID 1..4 duoc dung trong toan bo seed)
   --------------------------------------------------------------------- */
INSERT INTO TransportTypes (Name, Description) VALUES
(N'Bus',              N'Xe buýt'),
(N'Metro',            N'Tàu điện đô thị'),
(N'Bicycle',          N'Xe đạp công cộng'),
(N'Electric Vehicle', N'Xe điện công cộng');
GO

/* ---------------------------------------------------------------------
   3. Vehicles
   --------------------------------------------------------------------- */
INSERT INTO Vehicles (TransportTypeId, VehicleCode, VehicleName, Capacity) VALUES
(1, 'BUS-01',   N'Xe buýt mẫu 01', 60),
(1, 'BUS-02',   N'Xe buýt mẫu 02', 60),
(1, 'BUS-03',   N'Xe buýt mẫu 03', 60),
(1, 'BUS-04',   N'Xe buýt mẫu 04', 60),
(1, 'BUS-05',   N'Xe buýt mẫu 05', 60),
(2, 'METRO-01', N'Tàu Metro 01', 900),
(2, 'METRO-02', N'Tàu Metro 02', 900),
(3, 'BIKE-01',  N'Xe đạp công cộng 01', 1),
(3, 'BIKE-02',  N'Xe đạp công cộng 02', 1),
(3, 'BIKE-03',  N'Xe đạp công cộng 03', 1),
(4, 'EV-01',    N'Xe điện công cộng 01', 6),
(4, 'EV-02',    N'Xe điện công cộng 02', 6),
(4, 'EV-03',    N'Xe điện công cộng 03', 6),
(1, 'BUS-06',   N'Xe buýt mẫu 06', 60),
(1, 'BUS-07',   N'Xe buýt mẫu 07', 60),
(1, 'BUS-08',   N'Xe buýt mẫu 08', 60);
UPDATE Vehicles SET Status = 'MAINTENANCE' WHERE VehicleCode = 'BUS-05';
GO

/* ---------------------------------------------------------------------
   4. Stations (571 tram) - VI TRI THAT
     - 1..453     : diem dung xe buyt (453 diem) cua 20 tuyen trong bai
                     https://vinpearl.com/vi/ban-do-xe-bus-ha-noi ; toa do + thu tu
                     diem dung lay tu OpenStreetMap (route relation cua tung tuyen)
     - 454..473   : 20 ga Metro tuyen 2A va 3.1 (toa do tu https://metrohanoi.vn/line/map)
     - 474..522   : 49 tram xe dap TNGo theo bai
                     https://dantocphattrien.vietnamnet.vn/danh-sach-cac-tram-xe-dap-cong-cong-cho-thue-o-ha-noi-46898.html
     - 523..571   : 49 tram xe dien - CUNG VI TRI voi tram xe dap tuong ung
                     (EV-xxx va BIKE-xxx cung ma so, cung toa do)
   --------------------------------------------------------------------- */
INSERT INTO Stations (StationCode, StationName, Latitude, Longitude, Address, TransportTypeId) VALUES
('BUS-0001', N'Đối diện Trụ sở HĐND huyện Thanh Trì - Ngọc Hồi', 20.946601, 105.844216, N'Điểm dừng xe buýt - tuyến 08A - Hà Nội', 1),
('BUS-0002', N'Tòa nhà King Palace - 108 Nguyễn Trãi', 20.999853, 105.815113, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0003', N'Học viện công nghệ bưu chính viễn thông - Trần Phú (Hà Đông)', 20.980523, 105.788002, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0004', N'Số 10 Trần Phú - Siêu thị Việt Long', 20.983357, 105.791540, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0005', N'216 Nguyễn Trãi - Nhà Văn hóa tổ dân phố số 8 & 9 Phường Trung Văn', 20.987886, 105.797790, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0006', N'Bách hóa Thanh Xuân - đường Nguyễn Trãi', 20.990520, 105.801519, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0007', N'386 Nguyễn Trãi - Cục Sở hữu Trí tuệ', 20.993488, 105.805671, N'Điểm dừng xe buýt - tuyến 01, 02, 60A - Hà Nội', 1),
('BUS-0008', N'322 Nguyễn Trãi', 20.995901, 105.809151, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0009', N'398 Xã Đàn', 21.015117, 105.833549, N'Điểm dừng xe buýt - tuyến 25 - Hà Nội', 1),
('BUS-0010', N'215 Bạch Mai', 21.004656, 105.851185, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0011', N'Chợ Mơ - 459D Bạch Mai', 20.996787, 105.850104, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0012', N'327 Bạch Mai', 21.001060, 105.850701, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0013', N'549 Nguyễn Văn Cừ (cột trước)', 21.049762, 105.883565, N'Điểm dừng xe buýt - tuyến 01 - Hà Nội', 1),
('BUS-0014', N'426 Đê La Thành', 21.022803, 105.822226, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0015', N'196 Giải Phóng - Ngân hàng Nông nghiệp & PTNT Chi nhánh Nam Hà Nội', 20.993159, 105.841037, N'Điểm dừng xe buýt - tuyến 41, 08A - Hà Nội', 1),
('BUS-0016', N'Trước nút giao Hàng Than 70m', 21.043873, 105.847112, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0017', N'Đối diện Bến xe Nước ngầm Hà Nội - Ngọc Hồi (cột trước)', 20.964293, 105.841821, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0018', N'Đối diện 394 Lê Duẩn', 21.009523, 105.841443, N'Điểm dừng xe buýt - tuyến 32, 03A - Hà Nội', 1),
('BUS-0019', N'Ga Giáp Bát - Đối diện 1035 Giải Phóng', 20.976318, 105.840770, N'Điểm dừng xe buýt - tuyến 36, 08A - Hà Nội', 1),
('BUS-0020', N'274-276 Khâm Thiên', 21.019330, 105.834296, N'Điểm dừng xe buýt - tuyến 01, 49 - Hà Nội', 1),
('BUS-0021', N'325 Âu Cơ', 21.073472, 105.824870, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0022', N'Trung tâm kiểm định xe máy quân sự (Cầu Diễn)', 21.042487, 105.759638, N'Điểm dừng xe buýt - tuyến 32 - Hà Nội', 1),
('BUS-0023', N'286 Âu Cơ', 21.073608, 105.825080, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0024', N'Đối diện UBND phường Nhật Tân', 21.076249, 105.821571, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0025', N'60 Lê Thanh Nghị', 21.003419, 105.848464, N'Điểm dừng xe buýt - tuyến 08A - Hà Nội', 1),
('BUS-0026', N'Tòa nhà Indochina Tower - Đối diện ĐHQG Hà Nội', 21.036548, 105.782044, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0027', N'66 Đại La', 20.996359, 105.848178, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0028', N'Gò Đống Đa - Tây Sơn', 21.011212, 105.825379, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0029', N'Số 3 Hàng Muối', 21.034354, 105.854709, N'Điểm dừng xe buýt - tuyến 31, 34 - Hà Nội', 1),
('BUS-0030', N'Công viên Thống Nhất - Đối diện 326 Lê Duẩn', 21.014125, 105.841470, N'Điểm dừng xe buýt - tuyến 32, 03A - Hà Nội', 1),
('BUS-0031', N'Điểm trung chuyển Cầu Giấy - GTVT 02', 21.028583, 105.803835, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0032', N'Bộ Y tế - 138A Giảng Võ', 21.028434, 105.825401, N'Điểm dừng xe buýt - tuyến 25, 38, 49 - Hà Nội', 1),
('BUS-0033', N'221A-221B Khâm Thiên (Đối diện 302)', 21.019252, 105.833521, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0034', N'175-177 Giải Phóng (Ngã 3 Lê Thanh Nghị)', 21.001173, 105.841486, N'Điểm dừng xe buýt - tuyến 25, 32, 03A - Hà Nội', 1),
('BUS-0035', N'Trụ sở Quận uỷ Tây Hồ - 657 Lạc Long Quân', 21.068583, 105.811219, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0036', N'Cạnh ngõ 18 Nguyễn Khoái (Đối diện Vân Đồn Hotel)', 21.009705, 105.864842, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0037', N'Chợ Thượng Đình - 224 Nguyễn Trãi', 20.997752, 105.811959, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0038', N'211 Kim Mã', 21.031378, 105.823250, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0039', N'170-172 Lê Thanh Nghị', 21.001859, 105.843929, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0040', N'18-20 Tuệ Tĩnh', 21.015213, 105.850738, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0041', N'10-12 Quán Thánh', 21.040371, 105.846814, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0042', N'468 Âu Cơ', 21.080459, 105.818708, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0043', N'Đối diện 220 Trần Duy Hưng', 21.006845, 105.795000, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0044', N'59 Hoàng Cầu', 21.017624, 105.824268, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0045', N'Đài tưởng niệm Khâm Thiên - 45 Khâm Thiên', 21.018912, 105.838543, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0046', N'B13 Ký túc xá Bách Khoa', 21.006193, 105.847306, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0047', N'Bệnh viện Xanh Pôn - 12 Chu Văn An', 21.031058, 105.836118, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0048', N'212 Hoàng Quốc Việt - đối diện Học viện Chính trị Quốc gia Hồ Chí Minh', 21.046348, 105.787532, N'Điểm dừng xe buýt - tuyến 33, 38, 09A - Hà Nội', 1),
('BUS-0049', N'CN4 Xuân Phương', 21.042205, 105.737924, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0050', N'26 Trần Nhật Duật', 21.038850, 105.851604, N'Điểm dừng xe buýt - tuyến 23, 34, 03A - Hà Nội', 1),
('BUS-0051', N'90 Hoàng Quốc Việt', 21.046399, 105.796577, N'Điểm dừng xe buýt - tuyến 33, 38, 09A - Hà Nội', 1),
('BUS-0052', N'Qua ngã ba Nguyễn Khánh Toàn - Dương Quảng Hàm', 21.037373, 105.801608, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0053', N'251-253 Tam Trinh', 20.988894, 105.863371, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0054', N'579 Lạc Long Quân', 21.066020, 105.810320, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0055', N'658 Trương Định', 20.981255, 105.845255, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0056', N'216-218 Bạch Mai', 21.004035, 105.850973, N'Điểm dừng xe buýt - tuyến 36, 08A - Hà Nội', 1),
('BUS-0057', N'Hè trước số nhà 202 - 204 Nguyễn Khoái', 21.006354, 105.868041, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0058', N'512-514 Bạch Mai', 20.996803, 105.849984, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0059', N'Qua ngã 3 Xuân La 70m - Lạc Long Quân (Hồ Tây)', 21.058889, 105.808734, N'Điểm dừng xe buýt - tuyến 13, 33 - Hà Nội', 1),
('BUS-0060', N'116 A5 Tập thể Giảng Võ - Kim Mã', 21.030661, 105.818837, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0061', N'215 Âu Cơ', 21.065998, 105.828093, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0062', N'276 Tôn Đức Thắng', 21.019988, 105.830444, N'Điểm dừng xe buýt - tuyến 02, 41 - Hà Nội', 1),
('BUS-0063', N'Đối diện 105 Đặng Tiến Đông', 21.012061, 105.823925, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0064', N'Tổng công ty Đường sắt Việt Nam - 116 Lê Duẩn', 21.025734, 105.841468, N'Điểm dừng xe buýt - tuyến 01 - Hà Nội', 1),
('BUS-0065', N'Bệnh viện Bạch Mai (cột sau)', 21.001038, 105.841122, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0066', N'10 Hoa Lư', 21.009515, 105.847714, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0067', N'Chợ Mơ - 5 Minh Khai', 20.996163, 105.850605, N'Điểm dừng xe buýt - tuyến 24, 38 - Hà Nội', 1),
('BUS-0068', N'Đối diện 16 Hai Bà Trưng (Ngã 4 Hai Bà Trưng- Ngô Quyền)', 21.023850, 105.853996, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0069', N'18 Lý Thường Kiệt', 21.021995, 105.855276, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0070', N'177 Giảng Võ', 21.028126, 105.825588, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0071', N'23 Hàng Tre', 21.032024, 105.855697, N'Điểm dừng xe buýt - tuyến 31, 34 - Hà Nội', 1),
('BUS-0072', N'Platform dành riêng cho xe buýt trước nhà 80 Đường Láng', 21.003955, 105.818678, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0073', N'115 Phùng Hưng', 21.035189, 105.845857, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0074', N'Đối diện đài tưởng niệm chủ tịch HCM - đường Nguyễn Hữu Thọ', 20.969607, 105.830975, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0075', N'36 Lý Thái Tổ - Cung thiếu nhi Hà Nội', 21.028192, 105.855631, N'Điểm dừng xe buýt - tuyến 23, 08A - Hà Nội', 1),
('BUS-0076', N'89 Tam Trinh', 20.993896, 105.862806, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0077', N'Bệnh viện Hữu Nghị Việt Xô - 1 Trần Khánh Dư', 21.015380, 105.862485, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0078', N'Nhà NƠ. 7B KĐT Linh Đàm', 20.963547, 105.830495, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0079', N'22B Hai Bà Trưng - Cạnh Tràng Tiền Plaza', 21.024085, 105.853636, N'Điểm dừng xe buýt - tuyến 02, 09A - Hà Nội', 1),
('BUS-0080', N'Điểm xén hè (Cửa hàng xăng dầu số 75) - Số 6 Cầu Dậu', 20.970057, 105.826089, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0081', N'666-668 Đê La Thành', 21.023881, 105.816826, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0082', N'220 Trần Duy Hưng', 21.007272, 105.794800, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0083', N'Qua viện tin học Pháp ngữ 20m - Lê Thanh Nghị', 21.002872, 105.847499, N'Điểm dừng xe buýt - tuyến 23, 08A - Hà Nội', 1),
('BUS-0084', N'Nhà sách Trí Tuệ - 187G Giảng Võ', 21.025674, 105.822776, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0085', N'Trường Mạc Đĩnh Chi', 21.048940, 105.841423, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0086', N'Trước phố Chương Dương Độ (đối diện 198 Trần Quang Khải)', 21.028194, 105.858372, N'Điểm dừng xe buýt - tuyến 03A - Hà Nội', 1),
('BUS-0087', N'Chợ hoa Quảng An', 21.066166, 105.828162, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0088', N'37 Hai Bà Trưng - Bệnh viện Việt Nam Cu Ba', 21.024976, 105.850138, N'Điểm dừng xe buýt - tuyến 34, 36 - Hà Nội', 1),
('BUS-0089', N'Đối diện Công viên Thủ Lệ - Đường Bưởi dưới', 21.031306, 105.802546, N'Điểm dừng xe buýt - tuyến 32 - Hà Nội', 1),
('BUS-0090', N'Đối diện Bảo tàng phòng không không quân - Trường Chinh', 21.000225, 105.831159, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0091', N'85 Nguyễn Thái Học - Trường Tiểu học Lý Thường Kiệt', 21.029530, 105.838949, N'Điểm dừng xe buýt - tuyến 23, 34 - Hà Nội', 1),
('BUS-0092', N'Đối diện Đình Nhật Tân', 21.075992, 105.822120, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0093', N'58B Bà Triệu', 21.021962, 105.850346, N'Điểm dừng xe buýt - tuyến 36, 08A - Hà Nội', 1),
('BUS-0094', N'Đối diện Bệnh Viện Trung ương Quân đội 108 - Trần Hưng Đạo', 21.018528, 105.860709, N'Điểm dừng xe buýt - tuyến 02, 49, 09A - Hà Nội', 1),
('BUS-0095', N'Đối diện Đại học Dược Hà Nội - 15 Lê Thánh Tông', 21.021503, 105.857838, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0096', N'22 Liễu Giai', 21.035879, 105.814377, N'Điểm dừng xe buýt - tuyến 09A - Hà Nội', 1),
('BUS-0097', N'44-46 Khâm Thiên', 21.019018, 105.838866, N'Điểm dừng xe buýt - tuyến 01, 49 - Hà Nội', 1),
('BUS-0098', N'545 Lạc Long Quân', 21.063785, 105.809453, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0099', N'1014 Đường Láng', 21.023409, 105.799316, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0100', N'12A Điện Biên Phủ', 21.029502, 105.842345, N'Điểm dừng xe buýt - tuyến 02, 32, 09A - Hà Nội', 1),
('BUS-0101', N'31 Trần Hưng Đạo', 21.020283, 105.854407, N'Điểm dừng xe buýt - tuyến 03A - Hà Nội', 1),
('BUS-0102', N'Hè trước giữa số nhà 26 - 28 Nguyễn Khánh Toàn', 21.035583, 105.803868, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0103', N'Đối diện Bộ Khoa học & Công nghệ - 146 Trần Duy Hưng', 21.010110, 105.798760, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0104', N'180-182 Bà Triệu', 21.015878, 105.849126, N'Điểm dừng xe buýt - tuyến 36, 08A - Hà Nội', 1),
('BUS-0105', N'55 Quang Trung - Đối diện hồ Thiền Quang', 21.018161, 105.847419, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0106', N'79 Xuân Thủy (Đối diện Học viện Báo chí và Tuyên truyền)', 21.036341, 105.787786, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0107', N'Ngã ba Hoàng Diệu - Hoàng Văn Thụ', 21.039006, 105.839656, N'Điểm dừng xe buýt - tuyến 41, 50 - Hà Nội', 1),
('BUS-0108', N'145 Nguyễn Thái Học', 21.031054, 105.833767, N'Điểm dừng xe buýt - tuyến 23, 34 - Hà Nội', 1),
('BUS-0109', N'290 Tây Sơn', 21.007414, 105.823330, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0110', N'Hè trước tòa nhà PTA - Số 1 Kim Mã', 21.032242, 105.829364, N'Điểm dừng xe buýt - tuyến 23, 34 - Hà Nội', 1),
('BUS-0111', N'Bảo tàng dân tộc học Việt Nam - Nguyễn Văn Huyên', 21.040840, 105.797799, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0112', N'65 Quán Sứ (Đối diện 80 Quán Sứ)', 21.023794, 105.844845, N'Điểm dừng xe buýt - tuyến 32 - Hà Nội', 1),
('BUS-0113', N'Siêu thị Metro Thăng Long', 21.054720, 105.781714, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0114', N'54 Lý Thường Kiệt', 21.024841, 105.845568, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0115', N'Đối diện Trường Đại học Lao động & Xã Hội - 48 Trần Duy Hưng', 21.012475, 105.801378, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0116', N'Số nhà 2/2C khu Ngoại Giao Đoàn, phố Kim Mã đường dưới', 21.030860, 105.816663, N'Điểm dừng xe buýt - tuyến 25, 32 - Hà Nội', 1),
('BUS-0117', N'527 Phạm Văn Đồng', 21.057657, 105.783002, N'Điểm dừng xe buýt - tuyến 38, 09A - Hà Nội', 1),
('BUS-0118', N'7 Nguyễn Thái Học - Cửa Nam', 21.028343, 105.843007, N'Điểm dừng xe buýt - tuyến 23, 34 - Hà Nội', 1),
('BUS-0119', N'Công viên Lê nin - Đối diện 35 Trần Phú', 21.031061, 105.839366, N'Điểm dừng xe buýt - tuyến 02, 32 - Hà Nội', 1),
('BUS-0120', N'Trạm biến áp Đội Cấn 2 - Số nhà 47 phố Đội Cấn', 21.034504, 105.830521, N'Điểm dừng xe buýt - tuyến 09A - Hà Nội', 1),
('BUS-0121', N'593-595 Kim Mã', 21.029397, 105.808861, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0122', N'Chợ Láng Hạ A - 572 đường Láng', 21.013139, 105.808048, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0123', N'Đối diện TCT cơ điện nông nghiệp & Thủy lợi (Văn Điển) - 264 Ngọc Hồi', 20.952095, 105.843848, N'Điểm dừng xe buýt - tuyến 08A - Hà Nội', 1),
('BUS-0124', N'Qua đường vào Bệnh viện đa khoa Thăng Long 60m - Đối diện 171 Ngọc Hồi', 20.954963, 105.843247, N'Điểm dừng xe buýt - tuyến 08A - Hà Nội', 1),
('BUS-0125', N'149 Phố Huế', 21.014307, 105.851777, N'Điểm dừng xe buýt - tuyến 31, 38 - Hà Nội', 1),
('BUS-0126', N'92-94 Bà Triệu', 21.019170, 105.849429, N'Điểm dừng xe buýt - tuyến 36, 08A - Hà Nội', 1),
('BUS-0127', N'Qua ngã 3 Ngọc Hồi - Phan Trọng Tuệ 100m - Ngọc Hồi', 20.942234, 105.843920, N'Điểm dừng xe buýt - tuyến 08A - Hà Nội', 1),
('BUS-0128', N'Đối diện 39 Lý Thường Kiệt', 21.023037, 105.851743, N'Điểm dừng xe buýt - tuyến 49, 08A - Hà Nội', 1),
('BUS-0129', N'49 Hai Bà Trưng - Tháp Hà Nội', 21.026036, 105.846557, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0130', N'28 Đường Thành', 21.031078, 105.847091, N'Điểm dừng xe buýt - tuyến 01 - Hà Nội', 1),
('BUS-0131', N'Trước 100m ngõ 218 Phạm Văn Đồng', 21.062171, 105.783600, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0132', N'6-8 Tràng Thi (Qua ngã 4 Tràng Thi - Lý Quốc Sư)', 21.026545, 105.849684, N'Điểm dừng xe buýt - tuyến 02, 09A - Hà Nội', 1),
('BUS-0133', N'Bệnh viện Việt Đức - 40 Tràng Thi', 21.027390, 105.846674, N'Điểm dừng xe buýt - tuyến 02, 09A - Hà Nội', 1),
('BUS-0134', N'Điểm đỗ xe buýt 32 Nguyễn Công Trứ', 21.013770, 105.853037, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0135', N'Đối diện Vincom Tower - Bà Triệu', 21.011365, 105.849028, N'Điểm dừng xe buýt - tuyến 23, 36, 08A - Hà Nội', 1),
('BUS-0136', N'Đối diện B13 Ký Túc Xá Bách Khoa', 21.006465, 105.847234, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0137', N'114-115 E8 Phương Mai', 21.004197, 105.839100, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0138', N'116-C2 Lương Định Của', 21.004476, 105.835803, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0139', N'Trạm xử lý nước thải Kim Liên', 21.005934, 105.833228, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0140', N'10 Chùa Bộc - Học viện Ngân Hàng', 21.007452, 105.828796, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0141', N'Đại học Công Đoàn - 169 Tây Sơn', 21.010376, 105.825126, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0142', N'63 Trần Quang Diệu', 21.014959, 105.824244, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0143', N'21 Hoàng Cầu', 21.019443, 105.825181, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0144', N'167 Phùng Hưng', 21.030643, 105.844946, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0145', N'Đối diện 16 Phùng Hưng (đường trong)', 21.038326, 105.846531, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0146', N'54 Nguyễn Hữu Huân', 21.033313, 105.854407, N'Điểm dừng xe buýt - tuyến 23, 08A - Hà Nội', 1),
('BUS-0147', N'16 Trần Hưng Đạo', 21.019505, 105.857438, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0148', N'29 Hàn Thuyên', 21.018510, 105.855484, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0149', N'52 Ngô Thì Nhậm', 21.017458, 105.852862, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0150', N'94 Ngô Thì Nhậm', 21.014198, 105.853359, N'Điểm dừng xe buýt - tuyến 23 - Hà Nội', 1),
('BUS-0151', N'Bến xe Kim Mã', 21.031969, 105.829358, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0152', N'Nhà chờ Núi Trúc', 21.028844, 105.826306, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0153', N'Nhà chờ Giảng Võ', 21.024577, 105.821045, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0154', N'Nhà chờ Thành Công', 21.018132, 105.815990, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0155', N'Nhà chờ Vũ Ngọc Phan', 21.013418, 105.812926, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0156', N'Nhà chờ Hoàng Đạo Thúy', 21.005990, 105.805677, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0157', N'Nhà chờ Nguyễn Tuân', 21.002575, 105.800807, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0158', N'Nhà chờ Khuất Duy Tiến', 20.997771, 105.794523, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0159', N'Nhà chờ Lương Thế Vinh', 20.995336, 105.790943, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0160', N'Nhà chờ Trung Văn', 20.990918, 105.783679, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0161', N'Nhà chờ Mỗ Lao', 20.987907, 105.779352, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0162', N'Nhà chờ Vạn Phúc 2', 20.984819, 105.774834, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0163', N'Nhà chờ Vạn Phúc 1', 20.982277, 105.769790, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0164', N'Nhà chờ Dương Nội', 20.979449, 105.765881, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0165', N'Nhà chờ Văn Khê', 20.976580, 105.762231, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0166', N'Nhà chờ An Hưng', 20.973232, 105.757915, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0167', N'Nhà chờ Cầu La Khê', 20.970260, 105.754685, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0168', N'Nhà chờ KĐT Park City', 20.967681, 105.755459, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0169', N'Nhà chờ La Khê', 20.965408, 105.759546, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0170', N'Nhà chờ Văn Phú', 20.962830, 105.764074, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0171', N'Nhà chờ Văn La', 20.960041, 105.761960, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0172', N'Nhà chờ Ba La', 20.956874, 105.757852, N'Điểm dừng xe buýt - tuyến BRT01 - Hà Nội', 1),
('BUS-0173', N'Bến xe Yên Nghĩa', 20.949605, 105.747615, N'Điểm dừng xe buýt - tuyến 01, 02, BRT01 - Hà Nội', 1),
('BUS-0174', N'Trạm trung chuyển xe buýt Trần Khánh Dư (Khu đón khách)', 21.022188, 105.861202, N'Điểm dừng xe buýt - tuyến 02, 24, 49, 09A - Hà Nội', 1),
('BUS-0175', N'Đại học Khoa học tự nhiên - 19 Lê Thánh Tông', 21.020498, 105.858321, N'Điểm dừng xe buýt - tuyến 02, 49, 09A - Hà Nội', 1),
('BUS-0176', N'Hè cạnh vườn hoa 19-8, đường Hai Bà Trưng', 21.023115, 105.857025, N'Điểm dừng xe buýt - tuyến 02, 09A - Hà Nội', 1),
('BUS-0177', N'48 Hai Bà Trưng - Viện Kiểm Nghiệm thuốc Trung ương', 21.024911, 105.850819, N'Điểm dừng xe buýt - tuyến 02, 09A - Hà Nội', 1),
('BUS-0178', N'Cột cờ Hà Nội - Điện Biên Phủ', 21.032160, 105.839720, N'Điểm dừng xe buýt - tuyến 09A - Hà Nội', 1),
('BUS-0179', N'18A Lê Hồng Phong - Ngã tư Lê Hồng Phong - Ông Ích Khiêm', 21.034234, 105.833855, N'Điểm dừng xe buýt - tuyến 09A - Hà Nội', 1),
('BUS-0180', N'195B Đội Cấn', 21.035107, 105.823394, N'Điểm dừng xe buýt - tuyến 09A - Hà Nội', 1),
('BUS-0181', N'285 Đội Cấn - Công ty Dệt Kim Hà Nội', 21.035449, 105.818867, N'Điểm dừng xe buýt - tuyến 09A - Hà Nội', 1),
('BUS-0182', N'10 Đào Tấn - Viện Vật lý', 21.032256, 105.810277, N'Điểm dừng xe buýt - tuyến 25, 32, 38, 09A - Hà Nội', 1),
('BUS-0183', N'Dốc tập lái - 202 đường Bưởi trên', 21.035369, 105.806016, N'Điểm dừng xe buýt - tuyến 25, 09A - Hà Nội', 1),
('BUS-0184', N'Gần ngõ 378 đường Bưởi tránh (bên giao Đội Cấn)', 21.040852, 105.806946, N'Điểm dừng xe buýt - tuyến 25, 09A - Hà Nội', 1),
('BUS-0185', N'Số 610 Đường Bưởi (gần vòng xuyến Hoàng Quốc Việt)', 21.045518, 105.806310, N'Điểm dừng xe buýt - tuyến 25, 09A - Hà Nội', 1),
('BUS-0186', N'Trung tâm KHTN Công nghệ Quốc Gia - 18 Hoàng Quốc Việt', 21.046416, 105.801728, N'Điểm dừng xe buýt - tuyến 13, 33, 09A - Hà Nội', 1),
('BUS-0187', N'122-124 Hoàng Quốc Việt', 21.046379, 105.792082, N'Điểm dừng xe buýt - tuyến 33, 38, 09A - Hà Nội', 1),
('BUS-0188', N'Trạm trung chuyển xe buýt Hoàng Quốc Việt (cột trước) - chiều đi Phạm Văn Đồng', 21.046170, 105.784841, N'Điểm dừng xe buýt - tuyến 33, 38, 09A - Hà Nội', 1),
('BUS-0189', N'655 Phạm Văn Đồng', 21.048154, 105.781697, N'Điểm dừng xe buýt - tuyến 38, 09A - Hà Nội', 1),
('BUS-0190', N'36A Phạm Văn Đồng', 21.051300, 105.781953, N'Điểm dừng xe buýt - tuyến 38, 09A - Hà Nội', 1),
('BUS-0191', N'UBND phường Cổ Nhuế 1 - 601 Phạm Văn Đồng', 21.054403, 105.782264, N'Điểm dừng xe buýt - tuyến 38, 09A - Hà Nội', 1),
('BUS-0192', N'Qua 70m đường vào Công viên Hòa Bình', 21.062248, 105.784213, N'Điểm dừng xe buýt - tuyến 38, 09A - Hà Nội', 1),
('BUS-0193', N'373 Phạm Văn Đồng', 21.070524, 105.785661, N'Điểm dừng xe buýt - tuyến 38, 09A - Hà Nội', 1),
('BUS-0194', N'189 Phạm Văn Đồng', 21.074987, 105.786010, N'Điểm dừng xe buýt - tuyến 38, 09A - Hà Nội', 1),
('BUS-0195', N'68A Tân Xuân', 21.081895, 105.785368, N'Điểm dừng xe buýt - tuyến 38, 09A - Hà Nội', 1),
('BUS-0196', N'Đối diện số nhà 69 Hoàng Tăng Bí', 21.082275, 105.783455, N'Điểm dừng xe buýt - tuyến 09A - Hà Nội', 1),
('BUS-0197', N'Trường Đại học Y tế Cộng đồng', 21.082629, 105.778164, N'Điểm dừng xe buýt - tuyến 31, 09A - Hà Nội', 1),
('BUS-0198', N'Công an phường Đức Thắng', 21.078658, 105.777669, N'Điểm dừng xe buýt - tuyến 31, 09A - Hà Nội', 1),
('BUS-0199', N'Trường Cao đẳng Tài nguyên & Môi trường Hà Nội', 21.073993, 105.777211, N'Điểm dừng xe buýt - tuyến 31, 09A - Hà Nội', 1),
('BUS-0200', N'Đối diện Bệnh viện đa khoa Phương Đông', 21.071675, 105.775348, N'Điểm dừng xe buýt - tuyến 09A - Hà Nội', 1),
('BUS-0201', N'Đại học Mỏ - Tuyến 09A, 144', 21.071450, 105.770036, N'Điểm dừng xe buýt - tuyến 09A - Hà Nội', 1),
('BUS-0202', N'Đại học Bách Khoa', 21.006728, 105.845035, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0203', N'Sân vận động Bách Khoa - Lê Thanh Nghị', 21.002835, 105.847614, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0204', N'319 Phố Huế', 21.010086, 105.851620, N'Điểm dừng xe buýt - tuyến 31, 38 - Hà Nội', 1),
('BUS-0205', N'25A-25B Phố Huế', 21.018869, 105.851787, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0206', N'25 Lý Thường Kiệt', 21.021945, 105.854785, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0207', N'Đối diện 6C Phan Chu Trinh', 21.023599, 105.856873, N'Điểm dừng xe buýt - tuyến 31, 34 - Hà Nội', 1),
('BUS-0208', N'51 Lý Thái Tổ - Ngân hàng Nhà nước Việt Nam', 21.026705, 105.856277, N'Điểm dừng xe buýt - tuyến 31, 34 - Hà Nội', 1),
('BUS-0209', N'E1.3 Điểm trung chuyển Long Biên', 21.041376, 105.849624, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0210', N'Qua nút giao Hàng Than 50m', 21.044038, 105.847111, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0211', N'Trước nút giao Cửa Bắc 30m', 21.046410, 105.844156, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0212', N'Trước đường vào bãi An Dương', 21.050229, 105.840688, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0213', N'152-154 Nghi Tàm', 21.054166, 105.837376, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0214', N'Trước ngõ 34 Âu Cơ 20m', 21.059800, 105.833930, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0215', N'106 Âu Cơ', 21.062453, 105.832334, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0216', N'242 Âu Cơ (Ngã 3 Xuân Diệu - Quảng Bá)', 21.069804, 105.826228, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0217', N'8 An Dương Vương', 21.084201, 105.816841, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0218', N'Trạm Thú y Tây Hồ 197 An Dương Vương', 21.090073, 105.811598, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0219', N'Đối diện UBND Phường Phú Thượng', 21.089878, 105.807867, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0220', N'Đối diện 327 An Dương Vương', 21.089748, 105.802813, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0221', N'Làng Thượng Thụy', 21.089449, 105.797044, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0222', N'Đình Nhật Tảo', 21.090788, 105.789050, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0223', N'Đại học Mỏ', 21.071513, 105.776882, N'Điểm dừng xe buýt - tuyến 31 - Hà Nội', 1),
('BUS-0224', N'Bến xe Gia Lâm', 21.048230, 105.878443, N'Điểm dừng xe buýt - tuyến 01, 34, 03A - Hà Nội', 1),
('BUS-0225', N'Cty Cầu 5 Thăng Long - 307 Nguyễn Văn Cừ', 21.045604, 105.875409, N'Điểm dừng xe buýt - tuyến 01 - Hà Nội', 1),
('BUS-0226', N'135 Nguyễn Văn Cừ', 21.042391, 105.870482, N'Điểm dừng xe buýt - tuyến 01 - Hà Nội', 1),
('BUS-0227', N'E3.1 Điểm trung chuyển Long Biên', 21.041137, 105.849589, N'Điểm dừng xe buýt - tuyến 01, 41 - Hà Nội', 1),
('BUS-0228', N'50 Hàng Cót', 21.037297, 105.847089, N'Điểm dừng xe buýt - tuyến 01 - Hà Nội', 1),
('BUS-0229', N'Bệnh viện Phụ sản Trung ương - Đối diện số 4 Triệu Quốc Đạt', 21.026650, 105.847622, N'Điểm dừng xe buýt - tuyến 01, 36 - Hà Nội', 1),
('BUS-0230', N'Đối diện tháp Hà Nội - Hai Bà Trưng (cạnh 56 Hai Bà Trưng)', 21.026141, 105.846653, N'Điểm dừng xe buýt - tuyến 01, 38 - Hà Nội', 1),
('BUS-0231', N'Ga Hà Nội - 120 Lê Duẩn', 21.023367, 105.841406, N'Điểm dừng xe buýt - tuyến 01, 49 - Hà Nội', 1),
('BUS-0232', N'142-144 Nguyễn Lương Bằng', 21.015944, 105.828287, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0233', N'Công ty CP Công trình GT 873 - Nguyễn Trãi', 20.985863, 105.794904, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0234', N'Ga Văn Quán', 20.977670, 105.784442, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0235', N'Khách sạn Sông Nhuệ (148 Trần Phú- Hà Đông)', 20.975472, 105.781537, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0236', N'8 Quang Trung - Hà Đông', 20.972484, 105.777489, N'Điểm dừng xe buýt - tuyến 01, 02, 33 - Hà Nội', 1),
('BUS-0237', N'80 Quang Trung - Hà Đông', 20.970084, 105.774535, N'Điểm dừng xe buýt - tuyến 01, 02, 33 - Hà Nội', 1),
('BUS-0238', N'Nhà thi đấu Hà Đông - 182 Quang Trung (Hà Đông)', 20.967582, 105.771339, N'Điểm dừng xe buýt - tuyến 01, 02, 33 - Hà Nội', 1),
('BUS-0239', N'350-352 Quang Trung - Ga La Khê', 20.963770, 105.766484, N'Điểm dừng xe buýt - tuyến 01, 02, 33 - Hà Nội', 1),
('BUS-0240', N'Giữa số 428 - 430 Quang Trung (Hà Đông)', 20.962100, 105.764371, N'Điểm dừng xe buýt - tuyến 01, 02, 33 - Hà Nội', 1),
('BUS-0241', N'530-532 Quang Trung - Hà Đông', 20.959962, 105.761603, N'Điểm dừng xe buýt - tuyến 01, 02, 33 - Hà Nội', 1),
('BUS-0242', N'678 - 680 Quang Trung (Hà Đông)', 20.958115, 105.759239, N'Điểm dừng xe buýt - tuyến 01, 02, 33 - Hà Nội', 1),
('BUS-0243', N'870 Quang Trung - Ga Văn Khê', 20.955579, 105.755825, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0244', N'Nissan Hà Đông', 20.954091, 105.753850, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0245', N'Đối diện Trường Tiểu học Kinh tế Hà Tây - Quốc lộ 6', 20.952036, 105.751169, N'Điểm dừng xe buýt - tuyến 01, 02 - Hà Nội', 1),
('BUS-0246', N'E3.2 Điểm trung chuyển Long Biên', 21.041259, 105.849453, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0247', N'162 Trần Quang Khải - Viện Quy hoạch Thủy Lợi', 21.031945, 105.856185, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0248', N'Vườn hoa Trần Quang Khải (Đối diện BQL Xây dựng công trình Công ích)', 21.025281, 105.859646, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0249', N'Trung tâm kỹ thuật cao Viện 108 (Qua ngã 3 Trần Khánh Dư - Trần Hưng Đạo 50m)', 21.018123, 105.861818, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0250', N'539-541 Minh Khai', 21.000797, 105.870575, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0251', N'Tòa nhà Imperia Garden 2 - 423 Minh Khai (cột sau)', 20.997998, 105.866418, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0252', N'259 Minh Khai', 20.997098, 105.863895, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0253', N'199 Minh Khai', 20.995874, 105.860262, N'Điểm dừng xe buýt - tuyến 24, 38 - Hà Nội', 1),
('BUS-0254', N'161 Minh Khai', 20.995580, 105.855116, N'Điểm dừng xe buýt - tuyến 24, 38 - Hà Nội', 1),
('BUS-0255', N'Tập thể A10 - 128C Đại La', 20.997411, 105.843861, N'Điểm dừng xe buýt - tuyến 24, 08A - Hà Nội', 1),
('BUS-0256', N'86 Trường Chinh', 20.998732, 105.838486, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0257', N'Platform dành riêng cho xe buýt trước nhà 604 Trường Chinh', 21.002899, 105.821704, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0258', N'220 Đường Láng - Trường Đảng Lê Hồng Phong', 21.005965, 105.816685, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0259', N'470 Đường Láng', 21.009864, 105.812859, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0260', N'794 Đường Láng', 21.018160, 105.803024, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0261', N'1178 Đường Láng', 21.027244, 105.799495, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0262', N'Dải giữa điểm trung chuyển Cầu Giấy - Nhà ga S8-01', 21.029170, 105.803143, N'Điểm dừng xe buýt - tuyến 24 - Hà Nội', 1),
('BUS-0263', N'Đối diện Bệnh viện Xanh pôn - 60 Trần Phú (Bộ Tư pháp)', 21.031718, 105.835941, N'Điểm dừng xe buýt - tuyến 02, 32, 50 - Hà Nội', 1),
('BUS-0264', N'92-94 Tôn Đức Thắng', 21.027343, 105.833864, N'Điểm dừng xe buýt - tuyến 02, 41 - Hà Nội', 1),
('BUS-0265', N'160 Tôn Đức Thắng', 21.024859, 105.832736, N'Điểm dừng xe buýt - tuyến 02, 41 - Hà Nội', 1),
('BUS-0266', N'Công viên nước Hồ Tây', 21.075940, 105.815908, N'Điểm dừng xe buýt - tuyến 13, 60A - Hà Nội', 1),
('BUS-0267', N'Qua 50m ngõ 677 Lạc Long Quân (Đối diện trường Trung học cơ sở Nhật Tân - 474 Lạc Long Quân)', 21.071529, 105.812111, N'Điểm dừng xe buýt - tuyến 13, 60A - Hà Nội', 1),
('BUS-0268', N'Đối diện UBND Quận Tây Hồ - Nguyễn Hoàng Tôn', 21.070191, 105.810016, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0269', N'Cổng vào KĐT Ciputra (Đối diện 83 Nguyễn Hoàng Tôn)', 21.070839, 105.808101, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0270', N'333-335 Nguyễn Hoàng Tôn', 21.073505, 105.800979, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0271', N'Đối diện tập thể Pháo Binh (đối diện 547 Nguyễn Hoàng Tôn)', 21.075806, 105.794884, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0272', N'721 Nguyễn Hoàng Tôn', 21.077537, 105.790539, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0273', N'138 Phạm Văn Đồng - Cầu vượt bộ hành', 21.074511, 105.785454, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0274', N'542 Phạm Văn Đồng', 21.071268, 105.785271, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0275', N'370 Phạm Văn Đồng', 21.058045, 105.782548, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0276', N'Chung cư GreenStars', 21.051554, 105.781373, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0277', N'126 Phạm Văn Đồng', 21.043780, 105.780817, N'Điểm dừng xe buýt - tuyến 33, 60A - Hà Nội', 1),
('BUS-0278', N'9 Phạm Văn Đồng', 21.039462, 105.780592, N'Điểm dừng xe buýt - tuyến 13, 33, 60A - Hà Nội', 1),
('BUS-0279', N'Bệnh viện Đa khoa Y học cổ truyền - 6 Phạm Hùng', 21.034464, 105.779948, N'Điểm dừng xe buýt - tuyến 33, 60A - Hà Nội', 1),
('BUS-0280', N'Đối diện Bưu cục Thăng Long', 21.031213, 105.779410, N'Điểm dừng xe buýt - tuyến 33, 60A - Hà Nội', 1),
('BUS-0281', N'Gần ngã tư Phạm Hùng - Đình Thôn (cột sau)', 21.022964, 105.778517, N'Điểm dừng xe buýt - tuyến 33, 60A - Hà Nội', 1),
('BUS-0282', N'Nhà CT5 KĐT Sông Đà Mỹ Đình - Phạm Hùng', 21.018515, 105.781161, N'Điểm dừng xe buýt - tuyến 33, 60A - Hà Nội', 1),
('BUS-0283', N'Nhà CT5-D KĐT Mỹ Đình - Phạm Hùng', 21.014706, 105.784227, N'Điểm dừng xe buýt - tuyến 33, 60A - Hà Nội', 1),
('BUS-0284', N'Bảo tàng Hà Nội - Phạm Hùng', 21.011267, 105.787037, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0285', N'Ngã 4 Phạm Hùng - Khuất Duy Tiến (Trung tâm Hội nghị Quốc gia)', 21.006781, 105.790656, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0286', N'Đối diện Trường Trung học phổ thông chuyên Hà Nội - Amsterdam', 21.006381, 105.796751, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0287', N'Đối diện nhà N2A Khu đô thị Trung Hòa Nhân Chính', 21.003142, 105.799510, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0288', N'Qua cổng chính nghĩa trang Quán Dền - Nguyễn Tuân', 21.001492, 105.800801, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0289', N'Viện Khoa học Hình sự - 99 Nguyễn Tuân', 20.996416, 105.804809, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0290', N'100 Nguyễn Xiển', 20.989465, 105.804468, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0291', N'Công ty Cổ phần Thiên Phú', 20.985645, 105.807237, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0292', N'Hầm đường bộ số 3 - Nghiêm Xuân Yêm', 20.979441, 105.811792, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0293', N'Trường Đại học Thăng Long', 20.975741, 105.814555, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0294', N'Trung tâm Huấn luyện và Thi đấu Thể thao Công an nhân dân', 20.971654, 105.821057, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0295', N'Bãi đỗ xe Khu đô thị Linh Đàm', 20.967432, 105.826590, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0296', N'Nhà HH2A Khu đô thị Linh Đàm', 20.965005, 105.827328, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0297', N'Qua chợ Xanh Linh Đàm 50m', 20.965990, 105.835938, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0298', N'Đối diện qua Tượng đài liệt sĩ phường Hoàng Liệt 30m', 20.965626, 105.839601, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0299', N'Trường PTTH Việt Nam Balan (Đối diện Khách sạn Nam Thành) - Ngọc Hồi', 20.960484, 105.841997, N'Điểm dừng xe buýt - tuyến 08A, 60A - Hà Nội', 1),
('BUS-0300', N'Trạm biến áp Pháp Vân 6', 20.957687, 105.844940, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0301', N'Nhà No9 KĐT Pháp Vân', 20.955285, 105.846908, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0302', N'No 23 KĐT Pháp Vân Tứ Hiệp (Điểm đỗ cuối tuyến 60)', 20.953469, 105.849909, N'Điểm dừng xe buýt - tuyến 60A - Hà Nội', 1),
('BUS-0303', N'Bến xe Giáp Bát', 20.980333, 105.841547, N'Điểm dừng xe buýt - tuyến 03A - Hà Nội', 1),
('BUS-0304', N'Toyota Giải Phóng - 807 Giải Phóng', 20.984782, 105.841227, N'Điểm dừng xe buýt - tuyến 25, 32, 03A - Hà Nội', 1),
('BUS-0305', N'649 Giải Phóng', 20.989328, 105.841267, N'Điểm dừng xe buýt - tuyến 25, 32, 03A - Hà Nội', 1),
('BUS-0306', N'487 Giải Phóng', 20.993419, 105.841346, N'Điểm dừng xe buýt - tuyến 25, 32, 03A - Hà Nội', 1),
('BUS-0307', N'Gần cổng Parabol ĐH Bách Khoa - 17 Giải Phóng (cột sau)', 21.004950, 105.841572, N'Điểm dừng xe buýt - tuyến 25, 32, 03A - Hà Nội', 1),
('BUS-0308', N'Đối Diện 28 Trần Bình Trọng - Hồ Thiền Quang', 21.018445, 105.843959, N'Điểm dừng xe buýt - tuyến 32, 03A - Hà Nội', 1),
('BUS-0309', N'Bảo tàng Công an Nhân dân - Trần Bình Trọng', 21.022367, 105.845284, N'Điểm dừng xe buýt - tuyến 32, 03A - Hà Nội', 1),
('BUS-0310', N'67 Trần Hưng Đạo', 21.021885, 105.848946, N'Điểm dừng xe buýt - tuyến 03A - Hà Nội', 1),
('BUS-0311', N'13A Trần Hưng Đạo', 21.019396, 105.857414, N'Điểm dừng xe buýt - tuyến 03A - Hà Nội', 1),
('BUS-0312', N'162 Nguyễn Văn Cừ (cột sau)', 21.042634, 105.871098, N'Điểm dừng xe buýt - tuyến 34, 03A - Hà Nội', 1),
('BUS-0313', N'358-360 Nguyễn Văn Cừ', 21.045619, 105.875946, N'Điểm dừng xe buýt - tuyến 34, 03A - Hà Nội', 1),
('BUS-0314', N'Đối diện 447 Ngọc Lâm - Vườn hoa Gia Lâm', 21.049030, 105.875875, N'Điểm dừng xe buýt - tuyến 34, 03A - Hà Nội', 1),
('BUS-0315', N'Bến xe Giáp Bát', 20.980380, 105.841425, N'Điểm dừng xe buýt - tuyến 25 - Hà Nội', 1),
('BUS-0316', N'242 Xã Đàn', 21.012263, 105.836218, N'Điểm dừng xe buýt - tuyến 25 - Hà Nội', 1),
('BUS-0317', N'490 Xã Đàn', 21.017065, 105.831426, N'Điểm dừng xe buýt - tuyến 25 - Hà Nội', 1),
('BUS-0318', N'94 Ô Chợ Dừa', 21.020298, 105.826919, N'Điểm dừng xe buýt - tuyến 25, 49 - Hà Nội', 1),
('BUS-0319', N'Đối diện Học viện Âm nhạc Quốc gia Việt Nam', 21.022944, 105.826844, N'Điểm dừng xe buýt - tuyến 25 - Hà Nội', 1),
('BUS-0320', N'188 Hào Nam', 21.027492, 105.827694, N'Điểm dừng xe buýt - tuyến 25, 49 - Hà Nội', 1),
('BUS-0321', N'50-52 Lạc Long Quân', 21.049757, 105.807273, N'Điểm dừng xe buýt - tuyến 25 - Hà Nội', 1),
('BUS-0322', N'196 Lạc Long Quân - Trường mầm non Hoa Hồng', 21.052695, 105.809202, N'Điểm dừng xe buýt - tuyến 25 - Hà Nội', 1),
('BUS-0323', N'Gần ngã 3 Xuân La 40m - Lạc Long Quân (Hồ Tây)', 21.059325, 105.808971, N'Điểm dừng xe buýt - tuyến 25 - Hà Nội', 1),
('BUS-0324', N'312 Lạc Long Quân - Chùa Thiên Niên (Chùa Sài)', 21.062172, 105.809308, N'Điểm dừng xe buýt - tuyến 25 - Hà Nội', 1),
('BUS-0325', N'360 Lạc Long Quân', 21.065793, 105.810526, N'Điểm dừng xe buýt - tuyến 25 - Hà Nội', 1),
('BUS-0326', N'Đối diện Quận uỷ Tây Hồ - Lạc Long Quân', 21.068679, 105.811492, N'Điểm dừng xe buýt - tuyến 25 - Hà Nội', 1),
('BUS-0327', N'Đối diện Phòng Cảnh sát Phòng cháy chữa cháy', 21.071614, 105.809793, N'Điểm dừng xe buýt - tuyến 25, 41 - Hà Nội', 1),
('BUS-0328', N'Đối diện Khu đô thị Nam Thăng Long', 21.074557, 105.811063, N'Điểm dừng xe buýt - tuyến 25, 41 - Hà Nội', 1),
('BUS-0329', N'44 Lý Thường Kiệt', 21.023853, 105.848879, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0330', N'Đối diện 251 Giảng Võ', 21.024785, 105.821042, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0331', N'148-150 Cầu Giấy', 21.033009, 105.798461, N'Điểm dừng xe buýt - tuyến 32, 49 - Hà Nội', 1),
('BUS-0332', N'Ga Chùa Hà', 21.035021, 105.794591, N'Điểm dừng xe buýt - tuyến 32, 49 - Hà Nội', 1),
('BUS-0333', N'370 Cầu Giấy', 21.035899, 105.791805, N'Điểm dừng xe buýt - tuyến 32, 49 - Hà Nội', 1),
('BUS-0334', N'Học viện Báo chí và Tuyên truyền - 36 Xuân Thủy', 21.036550, 105.788475, N'Điểm dừng xe buýt - tuyến 32, 49 - Hà Nội', 1),
('BUS-0335', N'Chợ Xanh', 21.036703, 105.786123, N'Điểm dừng xe buýt - tuyến 32, 49 - Hà Nội', 1),
('BUS-0336', N'144 Xuân Thủy', 21.036810, 105.782860, N'Điểm dừng xe buýt - tuyến 32, 49 - Hà Nội', 1),
('BUS-0337', N'32 Hồ Tùng Mậu', 21.036779, 105.778757, N'Điểm dừng xe buýt - tuyến 13, 32, 49 - Hà Nội', 1),
('BUS-0338', N'Đối diện Đại học Thương mại - 6 Hồ Tùng Mậu (cột sau)', 21.037837, 105.774438, N'Điểm dừng xe buýt - tuyến 13, 49 - Hà Nội', 1),
('BUS-0339', N'Khoảng Xén Hè Chung Cư A1- Ngân hàng Vietcombank - Nguyễn Cơ Thạch', 21.036254, 105.766376, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0340', N'Khu đô thị Mỹ Đình II', 21.032883, 105.765213, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0341', N'Nhà C6 Khu đô thị Mỹ Đình I', 21.029957, 105.762329, N'Điểm dừng xe buýt - tuyến 49, 50 - Hà Nội', 1),
('BUS-0342', N'Qua nhà CT2A, KĐT Xuân Phương 30m', 21.031803, 105.756508, N'Điểm dừng xe buýt - tuyến 49, 50 - Hà Nội', 1),
('BUS-0343', N'Qua cầu vượt Xuân Phương 100m', 21.037030, 105.749095, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0344', N'Nhà máy Bia Sài Gòn - Hà Nội', 21.039626, 105.742397, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0345', N'Đối diện tòa chung cư Hateco Group', 21.047159, 105.736047, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0346', N'Điểm trung chuyển Nhổn', 21.051258, 105.736952, N'Điểm dừng xe buýt - tuyến 49 - Hà Nội', 1),
('BUS-0347', N'E3.4 Điểm trung chuyển Long Biên', 21.041492, 105.849198, N'Điểm dừng xe buýt - tuyến 36, 08A - Hà Nội', 1),
('BUS-0348', N'40 Ngô Quyền - TT Giao Dịch Công Nghệ', 21.022864, 105.854444, N'Điểm dừng xe buýt - tuyến 08A - Hà Nội', 1),
('BUS-0349', N'Ký túc xá Đại học Xây dựng', 20.999692, 105.845320, N'Điểm dừng xe buýt - tuyến 08A - Hà Nội', 1),
('BUS-0350', N'106 Trần Đại Nghĩa', 20.997569, 105.845828, N'Điểm dừng xe buýt - tuyến 08A - Hà Nội', 1),
('BUS-0351', N'352 Giải Phóng', 20.987629, 105.840974, N'Điểm dừng xe buýt - tuyến 41, 08A - Hà Nội', 1),
('BUS-0352', N'Đối diện 807 Giải Phóng', 20.984342, 105.840899, N'Điểm dừng xe buýt - tuyến 41, 08A - Hà Nội', 1),
('BUS-0353', N'Đối diện Bến xe Giáp Bát - Giải Phóng (cột sau)', 20.979403, 105.840823, N'Điểm dừng xe buýt - tuyến 08A - Hà Nội', 1),
('BUS-0354', N'Đối diện 1251 Giải Phóng', 20.971809, 105.840795, N'Điểm dừng xe buýt - tuyến 36, 08A - Hà Nội', 1),
('BUS-0355', N'Đối diện Bến xe Nước ngầm Hà Nội - Ngọc Hồi (cột sau)', 20.964007, 105.841800, N'Điểm dừng xe buýt - tuyến 08A - Hà Nội', 1),
('BUS-0356', N'Đối diện 634 - 636 Lạc Long Quân (Lotte Lạc Long Quân)', 21.076199, 105.814222, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0357', N'Gần ngã 3 Võng Thị - 313 Lạc Long Quân', 21.053044, 105.808930, N'Điểm dừng xe buýt - tuyến 13, 33 - Hà Nội', 1),
('BUS-0358', N'105 - 111 Lạc Long Quân (Gần đối diện ngã 3 Thụy Khuê)', 21.049057, 105.806560, N'Điểm dừng xe buýt - tuyến 13, 33 - Hà Nội', 1),
('BUS-0359', N'Trường Trung học cơ sở Nghĩa Tân - Đối diện 179 Tô Hiệu', 21.041708, 105.794002, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0360', N'Trường Trung cấp Tư thục Kinh tế Công nghệ Nguyễn Bình Khiêm - Số 6 Trần Quốc Hoàn', 21.041724, 105.787901, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0361', N'Câu lạc bộ rèn luyện sức khỏe Công đoàn Bộ ngoại Giao - Đối diện 77 Trần Quốc Hoàn', 21.041818, 105.783732, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0362', N'Đối diện UBND phường Từ Liêm', 21.040153, 105.766473, N'Điểm dừng xe buýt - tuyến 13, 32 - Hà Nội', 1),
('BUS-0363', N'Ga Cầu Diễn', 21.041468, 105.762764, N'Điểm dừng xe buýt - tuyến 13, 32 - Hà Nội', 1),
('BUS-0364', N'Giữa nhà 56-58 Tổ 9 Đường K3 Cầu Diễn', 21.043331, 105.765434, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0365', N'Giữa nhà 316-318 Tổ 8 Đường K3 Cầu Diễn', 21.050717, 105.770724, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0366', N'Đối diện Doanh trại Quân đội nhân dân Việt Nam (Cách cột điện CN9/4A 7m) Đường K3 Cầu Diễn', 21.060083, 105.773283, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0367', N'Giữa nhà 54-56 Đường Tập thể Học viện Cảnh sát', 21.063613, 105.764945, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0368', N'Qua ngã 3 vào Thôn Trù 2 - Phường Cổ Nhuế 2', 21.064769, 105.761847, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0369', N'Cổ Nhuế - HV Cảnh sát', 21.065576, 105.759341, N'Điểm dừng xe buýt - tuyến 13 - Hà Nội', 1),
('BUS-0370', N'Nam Thăng Long', 21.065894, 105.788700, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0371', N'Trung tâm Samsung R&D', 21.062347, 105.791897, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0372', N'Đối diện tòa N03T7 Ngoại Giao Đoàn', 21.065165, 105.800775, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0373', N'Chung cư Kosmo Xuân La', 21.067705, 105.801243, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0374', N'Đối diện Trường Đại học Nội vụ Hà Nội', 21.068298, 105.803011, N'Điểm dừng xe buýt - tuyến 33, 41 - Hà Nội', 1),
('BUS-0375', N'Đến Sóc - Xuân La', 21.065993, 105.804801, N'Điểm dừng xe buýt - tuyến 33, 41 - Hà Nội', 1),
('BUS-0376', N'Khu liên cơ quan sở ngành - 258 Võ Chí Công', 21.068314, 105.808242, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0377', N'Trước 50m ngõ 689 Lạc Long Quân', 21.078659, 105.813240, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0378', N'111 Âu Cơ', 21.062990, 105.831977, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0379', N'27-29 Âu Cơ', 21.060259, 105.833237, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0380', N'Qua nút giao Cửa Bắc 120m', 21.046221, 105.844166, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0381', N'86 Quán Thánh - Bộ chỉ huy Quân sự Quận Ba Đình', 21.041743, 105.844255, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0382', N'34-36 Hoàng Diệu', 21.034220, 105.839017, N'Điểm dừng xe buýt - tuyến 41, 50 - Hà Nội', 1),
('BUS-0383', N'254-256 Lê Duẩn', 21.015701, 105.841357, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0384', N'358-360 Lê Duẩn', 21.009827, 105.841281, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0385', N'Đối diện cổng Parabol ĐH Bách Khoa (cột sau)', 21.004979, 105.841196, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0386', N'Bến xe Giáp Bát', 20.980426, 105.841426, N'Điểm dừng xe buýt - tuyến 41 - Hà Nội', 1),
('BUS-0387', N'Bến xe Giáp Bát', 20.980475, 105.841556, N'Điểm dừng xe buýt - tuyến 32 - Hà Nội', 1),
('BUS-0388', N'140 Sơn Tây', 21.032705, 105.829568, N'Điểm dừng xe buýt - tuyến 32, 50 - Hà Nội', 1),
('BUS-0389', N'240 Kim Mã', 21.031755, 105.824055, N'Điểm dừng xe buýt - tuyến 32, 50 - Hà Nội', 1),
('BUS-0390', N'Ga Lê Đức Thọ', 21.038201, 105.773012, N'Điểm dừng xe buýt - tuyến 32 - Hà Nội', 1),
('BUS-0391', N'Ga Phú Diễn', 21.044125, 105.755216, N'Điểm dừng xe buýt - tuyến 32 - Hà Nội', 1),
('BUS-0392', N'135 Tổ 3 - Đường 32', 21.045992, 105.750452, N'Điểm dừng xe buýt - tuyến 32 - Hà Nội', 1),
('BUS-0393', N'Ga Minh Khai', 21.048139, 105.744878, N'Điểm dừng xe buýt - tuyến 32 - Hà Nội', 1),
('BUS-0394', N'Điểm trung chuyển Nhổn', 21.051558, 105.737079, N'Điểm dừng xe buýt - tuyến 32 - Hà Nội', 1),
('BUS-0395', N'Điểm trung chuyển Nhổn', 21.051581, 105.736452, N'Điểm dừng xe buýt - tuyến 32 - Hà Nội', 1),
('BUS-0396', N'368-370 Bạch Mai', 21.000201, 105.850439, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0397', N'64 Trương Định', 20.994194, 105.849657, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0398', N'194-196 Trương Định', 20.990568, 105.847842, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0399', N'468 Trương Định', 20.985411, 105.846337, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0400', N'Gần đường vào KĐT Đại Kim - 45 Nguyễn Hữu Thọ', 20.970970, 105.836222, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1);
INSERT INTO Stations (StationCode, StationName, Latitude, Longitude, Address, TransportTypeId) VALUES
('BUS-0401', N'704 Kim Giang', 20.965476, 105.820149, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0402', N'Nhà văn hóa xã Thanh Liệt', 20.963218, 105.817364, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0403', N'81 Thanh Liệt', 20.961937, 105.811827, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0404', N'Trường THCS Chu Văn An', 20.966093, 105.815645, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0405', N'29 Manor 2 Sunrise - KĐT Manor Central Park', 20.970827, 105.811330, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0406', N'Yên Xá', 20.969532, 105.798196, N'Điểm dừng xe buýt - tuyến 36 - Hà Nội', 1),
('BUS-0407', N'39-41 Xuân La', 21.061954, 105.808065, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0408', N'Bến xe Mỹ Đình', 21.028023, 105.778479, N'Điểm dừng xe buýt - tuyến 33, 34 - Hà Nội', 1),
('BUS-0409', N'Nhà số 3 lô A đường Đỗ Đức Dục', 21.009168, 105.783126, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0410', N'38 Miếu Đầm - Đền Thánh Mẫu', 21.006841, 105.781874, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0411', N'105 Cương Kiên', 20.998832, 105.780531, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0412', N'Đối diện tòa nhà 17T1 đường Cương Kiên', 20.995288, 105.778495, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0413', N'Trước nhà chờ Mỗ Lao 30m', 20.988288, 105.779622, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0414', N'Qua nhà chờ BRT Vạn Phúc 2 30m (chiều về)', 20.984674, 105.774305, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0415', N'Số 51 Vạn Phúc (Hà Đông) - Tòa nhà Landmark', 20.981772, 105.770840, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0416', N'Số 63 Vạn Phúc (Hà Đông) - Siêu thị Vinmart Vạn Phúc', 20.978355, 105.774031, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0417', N'Chung cư Goldsilk Complex Hà Đông - đường Vạn Phúc', 20.976821, 105.775869, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0418', N'Nhà văn hóa Công đoàn Hà Nội', 20.973828, 105.778252, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0419', N'46 Ba La - Trung cấp Y Hà Nội', 20.954395, 105.757218, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0420', N'Trung cấp Kỹ thuật Y dược Hà Nội', 20.947420, 105.756823, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0421', N'124 Phố Xốm', 20.943512, 105.756649, N'Điểm dừng xe buýt - tuyến 33 - Hà Nội', 1),
('BUS-0422', N'Đối diện Bến xe khách Mỹ Đình - Phạm Hùng (cột trước)', 21.027022, 105.779269, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0423', N'Đối diện Bệnh viện đa khoa y học cổ truyền - Phạm Hùng', 21.034366, 105.780539, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0424', N'Siêu thị điện máy PiCo - 173 Xuân Thủy', 21.036482, 105.785234, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0425', N'331 Cầu Giấy', 21.035700, 105.791762, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0426', N'Đối diện tòa nhà Discovery Complex', 21.034777, 105.794418, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0427', N'165 Cầu Giấy - Bưu điện Cầu Giấy', 21.032625, 105.798518, N'Điểm dừng xe buýt - tuyến 34 - Hà Nội', 1),
('BUS-0428', N'Điểm đỗ xe buýt Mai Động', 20.980686, 105.863852, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0429', N'441 Tam Trinh', 20.984835, 105.863775, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0430', N'37 Quang Trung', 21.020761, 105.848292, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0431', N'104 Nguyễn Khuyến', 21.028337, 105.838720, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0432', N'Văn Miếu - Quốc Tử Giám', 21.027436, 105.835172, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0433', N'Chùa An Quốc', 21.028483, 105.832638, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0434', N'Kim Mã (nhà chờ BRT Kim Mã) - Biển trước', 21.032089, 105.829172, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0435', N'Ngã ba Kim Mã - Vạn Bảo', 21.030818, 105.817878, N'Điểm dừng xe buýt - tuyến 38, 50 - Hà Nội', 1),
('BUS-0436', N'Tân Xuân', 21.087109, 105.785319, N'Điểm dừng xe buýt - tuyến 38 - Hà Nội', 1),
('BUS-0437', N'E3.3 Điểm trung chuyển Long Biên', 21.041373, 105.849326, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0438', N'Hồ Ngọc Khánh - Đối diện 37 Nguyễn Chí Thanh', 21.026979, 105.811918, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0439', N'Đối diện Đại học Luật Hà Nội - Nguyễn Chí Thanh', 21.022244, 105.809398, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0440', N'Trung tâm y tế dự phòng HN - 70 Nguyễn Chí Thanh', 21.018236, 105.807015, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0441', N'Ngã 4 Phạm Hùng - Khuất Duy Tiến (Đối diện Trung tâm Hội nghị Quốc gia)', 21.006909, 105.791250, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0442', N'Qua 130m Doanh trại Bộ chỉ huy quân sự HN - 99A Phạm Hùng', 21.012814, 105.786475, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0443', N'Tòa nhà Landmark 72 - đường Phạm Hùng', 21.015541, 105.784270, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0444', N'Nhà hàng Hàn Quốc, nhà CT4 ĐN KĐT Mỹ Đình', 21.016654, 105.780491, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0445', N'Tường rào Trạm y tế Mễ Trì', 21.012478, 105.774606, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0446', N'Đối diện Trường Trung học cơ sở Phú Đô', 21.012981, 105.770783, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0447', N'Bãi đỗ xe Sân vận động Mỹ Đình', 21.019516, 105.767390, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0448', N'Đường vào Trường Cao đẳng nghề Trần Hưng Đạo', 21.025156, 105.767714, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0449', N'Nhà CT5-ĐN1 Khu đô thị Mỹ Đình 1', 21.028857, 105.765928, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0450', N'Đối diện Bưu điện Vân Canh', 21.035664, 105.738214, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0451', N'320 Xuân Phương', 21.032140, 105.739026, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0452', N'Nhà văn hóa số 7 Xuân Phương - KĐT Vân Canh', 21.028046, 105.738906, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('BUS-0453', N'Khu đô thị An Lạc (Hoài Đức)', 21.025887, 105.733092, N'Điểm dừng xe buýt - tuyến 50 - Hà Nội', 1),
('METRO2A-01', N'Ga Cát Linh', 21.028377, 105.827275, N'Ga Cát Linh - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO2A-02', N'Ga La Thành', 21.020149, 105.825350, N'Ga La Thành - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO2A-03', N'Ga Thái Hà', 21.014556, 105.819471, N'Ga Thái Hà - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO2A-04', N'Ga Láng', 21.006369, 105.816070, N'Ga Láng - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO2A-05', N'Ga Thượng Đình', 20.997679, 105.812245, N'Ga Thượng Đình - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO2A-06', N'Ga Vành Đai 3', 20.992293, 105.804418, N'Ga Vành Đai 3 - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO2A-07', N'Ga Phùng Khoang', 20.984276, 105.793054, N'Ga Phùng Khoang - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO2A-08', N'Ga Văn Quán', 20.977722, 105.784795, N'Ga Văn Quán - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO2A-09', N'Ga Hà Đông', 20.970204, 105.774941, N'Ga Hà Đông - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO2A-10', N'Ga La Khê', 20.963837, 105.766803, N'Ga La Khê - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO2A-11', N'Ga Văn Khê', 20.955621, 105.756166, N'Ga Văn Khê - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO2A-12', N'Ga Yên Nghĩa', 20.949773, 105.748427, N'Ga Yên Nghĩa - tuyến Cát Linh - Hà Đông - Hà Nội', 2),
('METRO3-01', N'Ga Nhổn', 21.051932, 105.735426, N'Ga Nhổn - tuyến Nhổn - Cầu Giấy - Hà Nội', 2),
('METRO3-02', N'Ga Minh Khai', 21.047978, 105.744806, N'Ga Minh Khai - tuyến Nhổn - Cầu Giấy - Hà Nội', 2),
('METRO3-03', N'Ga Phú Diễn', 21.043915, 105.755272, N'Ga Phú Diễn - tuyến Nhổn - Cầu Giấy - Hà Nội', 2),
('METRO3-04', N'Ga Cầu Diễn', 21.041227, 105.762688, N'Ga Cầu Diễn - tuyến Nhổn - Cầu Giấy - Hà Nội', 2),
('METRO3-05', N'Ga Lê Đức Thọ', 21.038040, 105.772990, N'Ga Lê Đức Thọ - tuyến Nhổn - Cầu Giấy - Hà Nội', 2),
('METRO3-06', N'Ga Đại học Quốc gia Hà Nội', 21.036655, 105.782689, N'Ga Đại học Quốc gia Hà Nội - tuyến Nhổn - Cầu Giấy - Hà Nội', 2),
('METRO3-07', N'Ga Chùa Hà', 21.034923, 105.794376, N'Ga Chùa Hà - tuyến Nhổn - Cầu Giấy - Hà Nội', 2),
('METRO3-08', N'Ga Cầu Giấy', 21.029210, 105.803366, N'Ga Cầu Giấy - tuyến Nhổn - Cầu Giấy - Hà Nội', 2),
('BIKE-099', N'Trạm xe đạp Văn phòng TNGo Hà Nội', 21.037688, 105.809490, N'Số 446 Đội Cấn - Phường Cống Vị - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-002', N'Trạm xe đạp Số 01 Trần Huy Liệu', 21.028048, 105.821651, N'Số 01 Trần Huy Liệu - Phường Giảng Võ - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-003', N'Trạm xe đạp Nguyễn Văn Ngọc', 21.031808, 105.810671, N'Nút giao Nguyễn Văn Ngọc, Đào Tấn - Phường Ngọc Khánh - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-004', N'Trạm xe đạp Hồ Ngọc Khánh', 21.027112, 105.811943, N'Đối diện 43 Nguyễn Chí Thanh - Phường Ngọc Khánh - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-006', N'Trạm xe đạp Bảo tàng Chiến thắng B52', 21.034891, 105.825856, N'Số 157 Đội Cấn - Phường Đội Cấn - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-008', N'Trạm xe đạp Thành cổ Hà Nội', 21.040548, 105.841682, N'Đối diện số 38 Phan Đình Phùng - Phường Quán Thánh - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-011', N'Trạm xe đạp Vườn hoa Nguyễn Biểu', 21.043440, 105.840120, N'Đối diện số 1 Nguyễn Biểu - Phường Quán Thánh - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-014', N'Trạm xe đạp Số 30 Phan Đình Phùng', 21.040614, 105.842323, N'Số 30 Phan Đình Phùng - Phường Quán Thánh - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-015', N'Trạm xe đạp Số 34 Trần Phú', 21.030231, 105.843763, N'Số 34 Trần Phú - Phường Điện Biên - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-016', N'Trạm xe đạp Số 12 Đào Tấn', 21.032446, 105.809708, N'Số 12 Đào Tấn - Phường Cống Vị - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-017', N'Trạm xe đạp Sân bóng Vạn Phúc', 21.033024, 105.818058, N'Đối diện số 8 Vạn Phúc - Phường Kim Mã - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-018', N'Trạm xe đạp Nhà hát Chèo Việt Nam', 21.031983, 105.827263, N'Số 71 Kim Mã - Phường Kim Mã - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-019', N'Trạm xe đạp Bến xe Kim Mã', 21.032067, 105.829774, N'Nút giao Nguyễn Thái Học - Giảng Võ - Phường Kim Mã - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-021', N'Trạm xe đạp Bảo tàng Mỹ thuật', 21.030327, 105.836668, N'Số 66 Nguyễn Thái Học - Phường Điện Biên - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-022', N'Trạm xe đạp Vườn hoa Lê Nin', 21.031416, 105.840221, N'Gần nút giao Điện Biên Phủ - Nguyễn Tri Phương - Phường Điện Biên - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-023', N'Trạm xe đạp Vườn hoa Hàng Đậu 01', 21.039890, 105.846465, N'Đối diện số 1 Lý Nam Đế - Phường Quán Thánh - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-024', N'Trạm xe đạp Số 30 Văn Cao', 21.040317, 105.815754, N'Số 30 Văn Cao - Phường Liễu Giai - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-025', N'Trạm xe đạp Vườn hoa Hàng Đậu 02', 21.040206, 105.847041, N'Đối diện số 6 Quán Thánh - Phường Quán Thánh - Quận Ba Đình - TP Hà Nội', 3),
('BIKE-028', N'Trạm xe đạp Đền Thủy Trung Tiên', 21.049157, 105.838862, N'Bên phải cổng Đền Thủy Trung Tiên - Phường Yên Phụ - Quận Tây Hồ - TP Hà Nội', 3),
('BIKE-029', N'Trạm xe đạp Số 187 Trích Sài', 21.053233, 105.812490, N'Số 187 Trích Sài - Phường Bưởi - Quận Tây Hồ - TP Hà Nội', 3),
('BIKE-032', N'Trạm xe đạp Số 380 Lạc Long Quân', 21.067759, 105.811268, N'Số 380 Lạc Long Quân - Phường Xuân La - Quận Tây Hồ - TP Hà Nội', 3),
('BIKE-033', N'Trạm xe đạp Số 713 Lạc Long Quân', 21.080835, 105.817571, N'Số 713 Lạc Long Quân - Phường Xuân La - Quận Tây Hồ - TP Hà Nội', 3),
('BIKE-034', N'Trạm xe đạp Hồ Tây - Đường Lạc Long Quân', 21.059174, 105.808976, N'Số 292 Lạc Long Quân - Phường Xuân La - Quận Tây Hồ - TP Hà Nội', 3),
('BIKE-035', N'Trạm xe đạp Bờ hồ Trúc Bạch', 21.044671, 105.836507, N'Gần trạm xe buýt đường Thanh Niên - Phường Thụy Khuê - Quận Tây Hồ - TP Hà Nội', 3),
('BIKE-037', N'Trạm xe đạp Vườn hoa Lý Tự Trọng', 21.042768, 105.835205, N'Số 2 Thụy Khuê - Phường Thụy Khuê - Quận Tây Hồ - TP Hà Nội', 3),
('BIKE-041', N'Trạm xe đạp 187C Giảng Võ', 21.025967, 105.822461, N'Số 187C Giảng Võ - Phường Cát Linh - Quận Đống Đa - TP Hà Nội', 3),
('BIKE-047', N'Trạm xe đạp Số 70 Nguyễn Chí Thanh', 21.018366, 105.807098, N'Số 70 Nguyễn Chí Thanh - Phường Láng Thượng - Quận Đống Đa - TP Hà Nội', 3),
('BIKE-048', N'Trạm xe đạp Số 99 Nguyễn Chí Thanh', 21.018162, 105.807495, N'Số 99 Nguyễn Chí Thanh - Phường Láng Hạ - Quận Đống Đa - TP Hà Nội', 3),
('BIKE-050', N'Trạm xe đạp Số 58 Nguyễn Chí Thanh', 21.022168, 105.809322, N'Số 58 Nguyễn Chí Thanh - Phường Láng Hạ - Quận Đống Đa - TP Hà Nội', 3),
('BIKE-052', N'Trạm xe đạp Ga Metro Cát Linh', 21.026835, 105.827593, N'Vỉa hè hồ Hào Nam - Phường Láng Hạ - Quận Đống Đa - TP Hà Nội', 3),
('BIKE-053', N'Trạm xe đạp Học viện Ngoại giao', 21.023505, 105.806877, N'Ngõ 80 Chùa Láng - Phường Láng Thượng - Quận Đống Đa - TP Hà Nội', 3),
('BIKE-057', N'Trạm xe đạp Vincom Phạm Ngọc Thạch', 21.006635, 105.831993, N'Số 2 Phạm Ngọc Thạch - Phường Trung Tự - Quận Đống Đa - TP Hà Nội', 3),
('BIKE-059', N'Trạm xe đạp Số 56 Hai Bà Trưng', 21.026008, 105.846642, N'Số 56 Hai Bà Trưng - Phường Trần Hưng Đạo - Quận Hoàn Kiếm - TP Hà Nội', 3),
('BIKE-060', N'Trạm xe đạp Số 80 Trần Hưng Đạo', 21.022928, 105.846043, N'Số 80 Trần Hưng Đạo - Phường Trần Hưng Đạo - Quận Hoàn Kiếm - TP Hà Nội', 3),
('BIKE-062', N'Trạm xe đạp Số 32 Lý Thường Kiệt', 21.022935, 105.852150, N'Số 32 Lý Thường Kiệt - Phường Hàng Bài - Quận Hoàn Kiếm - TP Hà Nội', 3),
('BIKE-063', N'Trạm xe đạp Số 44B Lý Thường Kiệt', 21.024147, 105.848125, N'Số 44B Lý Thường Kiệt - Phường Trần Hưng Đạo - Quận Hoàn Kiếm - TP Hà Nội', 3),
('BIKE-064', N'Trạm xe đạp Số 19 Lý Thường Kiệt', 21.021621, 105.855893, N'Số 19 Lý Thường Kiệt - Phường Phan Chu Trinh - Quận Hoàn Kiếm - TP Hà Nội', 3),
('BIKE-065', N'Trạm xe đạp Vườn hoa 19/8', 21.023643, 105.856910, N'Đối diện số 6 Phan Chu Trinh - Phường Tràng Tiền - Quận Hoàn Kiếm - TP Hà Nội', 3),
('BIKE-066', N'Trạm xe đạp Vườn hoa Cổ Tân', 21.024963, 105.858133, N'Bên cạnh số 25 Tông Đản - Phường Tràng Tiền - Quận Hoàn Kiếm - TP Hà Nội', 3),
('BIKE-067', N'Trạm xe đạp Vườn hoa Hàng Vôi', 21.029127, 105.856786, N'Đối diện số 3 Trần Nguyên Hãn - Phường Lý Thái Tổ - Quận Hoàn Kiếm - TP Hà Nội', 3),
('BIKE-069', N'Trạm xe đạp Vườn hoa Lý Thái Tổ', 21.027235, 105.854595, N'Đối diện số 02 Lê Thạch - Phường Tràng Tiền - Quận Hoàn Kiếm - TP Hà Nội', 3),
('BIKE-070', N'Trạm xe đạp Vườn hoa Tây Sơn', 21.026745, 105.850275, N'Đối diện số 2D Quang Trung - Phường Hàng Trống - Quận Hoàn Kiếm - TP Hà Nội', 3),
('BIKE-081', N'Trạm xe đạp Số 47 Nguyễn Đình Chiểu', 21.013293, 105.846465, N'Đối diện số 47 Nguyễn Đình Chiểu - Phường Lê Đại Hành - Quận Hai Bà Trưng - TP Hà Nội', 3),
('BIKE-083', N'Trạm xe đạp Cổng Nguyễn Đình Chiểu', 21.008322, 105.845966, N'Đối diện số 120 Đại Cồ Việt - Phường Lê Đại Hành - Quận Hai Bà Trưng - TP Hà Nội', 3),
('BIKE-087', N'Trạm xe đạp Số 72 Trần Đại Nghĩa', 21.000783, 105.845230, N'Số 72 Trần Đại Nghĩa - Phường Đồng Tâm - Quận Hai Bà Trưng - TP Hà Nội', 3),
('BIKE-088', N'Trạm xe đạp Số 55 Giải Phóng', 21.003776, 105.841526, N'Số 55 Giải Phóng - Phường Đồng Tâm - Quận Hai Bà Trưng - TP Hà Nội', 3),
('BIKE-090', N'Trạm xe đạp Số 75 Trần Đại Nghĩa', 21.005359, 105.845714, N'Số 75 Trần Đại Nghĩa - Phường Bách Khoa - Quận Hai Bà Trưng - TP Hà Nội', 3),
('BIKE-093', N'Trạm xe đạp Số 48 Tăng Bạt Hổ', 21.014047, 105.859268, N'Đối diện số 48 Tăng Bạt Hổ - Phường Phạm Đình Hổ - Quận Hai Bà Trưng - TP Hà Nội', 3),
('BIKE-094', N'Trạm xe đạp Số 16 Tăng Bạt Hổ', 21.017851, 105.858298, N'Đối diện số 16 Tăng Bạt Hổ - Phường Phạm Đình Hổ - Quận Hai Bà Trưng - TP Hà Nội', 3),
('EV-099', N'Trạm xe điện Văn phòng TNGo Hà Nội', 21.037688, 105.809490, N'Số 446 Đội Cấn - Phường Cống Vị - Quận Ba Đình - TP Hà Nội', 4),
('EV-002', N'Trạm xe điện Số 01 Trần Huy Liệu', 21.028048, 105.821651, N'Số 01 Trần Huy Liệu - Phường Giảng Võ - Quận Ba Đình - TP Hà Nội', 4),
('EV-003', N'Trạm xe điện Nguyễn Văn Ngọc', 21.031808, 105.810671, N'Nút giao Nguyễn Văn Ngọc, Đào Tấn - Phường Ngọc Khánh - Quận Ba Đình - TP Hà Nội', 4),
('EV-004', N'Trạm xe điện Hồ Ngọc Khánh', 21.027112, 105.811943, N'Đối diện 43 Nguyễn Chí Thanh - Phường Ngọc Khánh - Quận Ba Đình - TP Hà Nội', 4),
('EV-006', N'Trạm xe điện Bảo tàng Chiến thắng B52', 21.034891, 105.825856, N'Số 157 Đội Cấn - Phường Đội Cấn - Quận Ba Đình - TP Hà Nội', 4),
('EV-008', N'Trạm xe điện Thành cổ Hà Nội', 21.040548, 105.841682, N'Đối diện số 38 Phan Đình Phùng - Phường Quán Thánh - Quận Ba Đình - TP Hà Nội', 4),
('EV-011', N'Trạm xe điện Vườn hoa Nguyễn Biểu', 21.043440, 105.840120, N'Đối diện số 1 Nguyễn Biểu - Phường Quán Thánh - Quận Ba Đình - TP Hà Nội', 4),
('EV-014', N'Trạm xe điện Số 30 Phan Đình Phùng', 21.040614, 105.842323, N'Số 30 Phan Đình Phùng - Phường Quán Thánh - Quận Ba Đình - TP Hà Nội', 4),
('EV-015', N'Trạm xe điện Số 34 Trần Phú', 21.030231, 105.843763, N'Số 34 Trần Phú - Phường Điện Biên - Quận Ba Đình - TP Hà Nội', 4),
('EV-016', N'Trạm xe điện Số 12 Đào Tấn', 21.032446, 105.809708, N'Số 12 Đào Tấn - Phường Cống Vị - Quận Ba Đình - TP Hà Nội', 4),
('EV-017', N'Trạm xe điện Sân bóng Vạn Phúc', 21.033024, 105.818058, N'Đối diện số 8 Vạn Phúc - Phường Kim Mã - Quận Ba Đình - TP Hà Nội', 4),
('EV-018', N'Trạm xe điện Nhà hát Chèo Việt Nam', 21.031983, 105.827263, N'Số 71 Kim Mã - Phường Kim Mã - Quận Ba Đình - TP Hà Nội', 4),
('EV-019', N'Trạm xe điện Bến xe Kim Mã', 21.032067, 105.829774, N'Nút giao Nguyễn Thái Học - Giảng Võ - Phường Kim Mã - Quận Ba Đình - TP Hà Nội', 4),
('EV-021', N'Trạm xe điện Bảo tàng Mỹ thuật', 21.030327, 105.836668, N'Số 66 Nguyễn Thái Học - Phường Điện Biên - Quận Ba Đình - TP Hà Nội', 4),
('EV-022', N'Trạm xe điện Vườn hoa Lê Nin', 21.031416, 105.840221, N'Gần nút giao Điện Biên Phủ - Nguyễn Tri Phương - Phường Điện Biên - Quận Ba Đình - TP Hà Nội', 4),
('EV-023', N'Trạm xe điện Vườn hoa Hàng Đậu 01', 21.039890, 105.846465, N'Đối diện số 1 Lý Nam Đế - Phường Quán Thánh - Quận Ba Đình - TP Hà Nội', 4),
('EV-024', N'Trạm xe điện Số 30 Văn Cao', 21.040317, 105.815754, N'Số 30 Văn Cao - Phường Liễu Giai - Quận Ba Đình - TP Hà Nội', 4),
('EV-025', N'Trạm xe điện Vườn hoa Hàng Đậu 02', 21.040206, 105.847041, N'Đối diện số 6 Quán Thánh - Phường Quán Thánh - Quận Ba Đình - TP Hà Nội', 4),
('EV-028', N'Trạm xe điện Đền Thủy Trung Tiên', 21.049157, 105.838862, N'Bên phải cổng Đền Thủy Trung Tiên - Phường Yên Phụ - Quận Tây Hồ - TP Hà Nội', 4),
('EV-029', N'Trạm xe điện Số 187 Trích Sài', 21.053233, 105.812490, N'Số 187 Trích Sài - Phường Bưởi - Quận Tây Hồ - TP Hà Nội', 4),
('EV-032', N'Trạm xe điện Số 380 Lạc Long Quân', 21.067759, 105.811268, N'Số 380 Lạc Long Quân - Phường Xuân La - Quận Tây Hồ - TP Hà Nội', 4),
('EV-033', N'Trạm xe điện Số 713 Lạc Long Quân', 21.080835, 105.817571, N'Số 713 Lạc Long Quân - Phường Xuân La - Quận Tây Hồ - TP Hà Nội', 4),
('EV-034', N'Trạm xe điện Hồ Tây - Đường Lạc Long Quân', 21.059174, 105.808976, N'Số 292 Lạc Long Quân - Phường Xuân La - Quận Tây Hồ - TP Hà Nội', 4),
('EV-035', N'Trạm xe điện Bờ hồ Trúc Bạch', 21.044671, 105.836507, N'Gần trạm xe buýt đường Thanh Niên - Phường Thụy Khuê - Quận Tây Hồ - TP Hà Nội', 4),
('EV-037', N'Trạm xe điện Vườn hoa Lý Tự Trọng', 21.042768, 105.835205, N'Số 2 Thụy Khuê - Phường Thụy Khuê - Quận Tây Hồ - TP Hà Nội', 4),
('EV-041', N'Trạm xe điện 187C Giảng Võ', 21.025967, 105.822461, N'Số 187C Giảng Võ - Phường Cát Linh - Quận Đống Đa - TP Hà Nội', 4),
('EV-047', N'Trạm xe điện Số 70 Nguyễn Chí Thanh', 21.018366, 105.807098, N'Số 70 Nguyễn Chí Thanh - Phường Láng Thượng - Quận Đống Đa - TP Hà Nội', 4),
('EV-048', N'Trạm xe điện Số 99 Nguyễn Chí Thanh', 21.018162, 105.807495, N'Số 99 Nguyễn Chí Thanh - Phường Láng Hạ - Quận Đống Đa - TP Hà Nội', 4),
('EV-050', N'Trạm xe điện Số 58 Nguyễn Chí Thanh', 21.022168, 105.809322, N'Số 58 Nguyễn Chí Thanh - Phường Láng Hạ - Quận Đống Đa - TP Hà Nội', 4),
('EV-052', N'Trạm xe điện Ga Metro Cát Linh', 21.026835, 105.827593, N'Vỉa hè hồ Hào Nam - Phường Láng Hạ - Quận Đống Đa - TP Hà Nội', 4),
('EV-053', N'Trạm xe điện Học viện Ngoại giao', 21.023505, 105.806877, N'Ngõ 80 Chùa Láng - Phường Láng Thượng - Quận Đống Đa - TP Hà Nội', 4),
('EV-057', N'Trạm xe điện Vincom Phạm Ngọc Thạch', 21.006635, 105.831993, N'Số 2 Phạm Ngọc Thạch - Phường Trung Tự - Quận Đống Đa - TP Hà Nội', 4),
('EV-059', N'Trạm xe điện Số 56 Hai Bà Trưng', 21.026008, 105.846642, N'Số 56 Hai Bà Trưng - Phường Trần Hưng Đạo - Quận Hoàn Kiếm - TP Hà Nội', 4),
('EV-060', N'Trạm xe điện Số 80 Trần Hưng Đạo', 21.022928, 105.846043, N'Số 80 Trần Hưng Đạo - Phường Trần Hưng Đạo - Quận Hoàn Kiếm - TP Hà Nội', 4),
('EV-062', N'Trạm xe điện Số 32 Lý Thường Kiệt', 21.022935, 105.852150, N'Số 32 Lý Thường Kiệt - Phường Hàng Bài - Quận Hoàn Kiếm - TP Hà Nội', 4),
('EV-063', N'Trạm xe điện Số 44B Lý Thường Kiệt', 21.024147, 105.848125, N'Số 44B Lý Thường Kiệt - Phường Trần Hưng Đạo - Quận Hoàn Kiếm - TP Hà Nội', 4),
('EV-064', N'Trạm xe điện Số 19 Lý Thường Kiệt', 21.021621, 105.855893, N'Số 19 Lý Thường Kiệt - Phường Phan Chu Trinh - Quận Hoàn Kiếm - TP Hà Nội', 4),
('EV-065', N'Trạm xe điện Vườn hoa 19/8', 21.023643, 105.856910, N'Đối diện số 6 Phan Chu Trinh - Phường Tràng Tiền - Quận Hoàn Kiếm - TP Hà Nội', 4),
('EV-066', N'Trạm xe điện Vườn hoa Cổ Tân', 21.024963, 105.858133, N'Bên cạnh số 25 Tông Đản - Phường Tràng Tiền - Quận Hoàn Kiếm - TP Hà Nội', 4),
('EV-067', N'Trạm xe điện Vườn hoa Hàng Vôi', 21.029127, 105.856786, N'Đối diện số 3 Trần Nguyên Hãn - Phường Lý Thái Tổ - Quận Hoàn Kiếm - TP Hà Nội', 4),
('EV-069', N'Trạm xe điện Vườn hoa Lý Thái Tổ', 21.027235, 105.854595, N'Đối diện số 02 Lê Thạch - Phường Tràng Tiền - Quận Hoàn Kiếm - TP Hà Nội', 4),
('EV-070', N'Trạm xe điện Vườn hoa Tây Sơn', 21.026745, 105.850275, N'Đối diện số 2D Quang Trung - Phường Hàng Trống - Quận Hoàn Kiếm - TP Hà Nội', 4),
('EV-081', N'Trạm xe điện Số 47 Nguyễn Đình Chiểu', 21.013293, 105.846465, N'Đối diện số 47 Nguyễn Đình Chiểu - Phường Lê Đại Hành - Quận Hai Bà Trưng - TP Hà Nội', 4),
('EV-083', N'Trạm xe điện Cổng Nguyễn Đình Chiểu', 21.008322, 105.845966, N'Đối diện số 120 Đại Cồ Việt - Phường Lê Đại Hành - Quận Hai Bà Trưng - TP Hà Nội', 4),
('EV-087', N'Trạm xe điện Số 72 Trần Đại Nghĩa', 21.000783, 105.845230, N'Số 72 Trần Đại Nghĩa - Phường Đồng Tâm - Quận Hai Bà Trưng - TP Hà Nội', 4),
('EV-088', N'Trạm xe điện Số 55 Giải Phóng', 21.003776, 105.841526, N'Số 55 Giải Phóng - Phường Đồng Tâm - Quận Hai Bà Trưng - TP Hà Nội', 4),
('EV-090', N'Trạm xe điện Số 75 Trần Đại Nghĩa', 21.005359, 105.845714, N'Số 75 Trần Đại Nghĩa - Phường Bách Khoa - Quận Hai Bà Trưng - TP Hà Nội', 4),
('EV-093', N'Trạm xe điện Số 48 Tăng Bạt Hổ', 21.014047, 105.859268, N'Đối diện số 48 Tăng Bạt Hổ - Phường Phạm Đình Hổ - Quận Hai Bà Trưng - TP Hà Nội', 4),
('EV-094', N'Trạm xe điện Số 16 Tăng Bạt Hổ', 21.017851, 105.858298, N'Đối diện số 16 Tăng Bạt Hổ - Phường Phạm Đình Hổ - Quận Hai Bà Trưng - TP Hà Nội', 4);
GO

/* ---------------------------------------------------------------------
   5. Routes - 1..20: tuyen buyt (so hieu that), 21..22: Metro 2A, 3.1
   Xe dap / xe dien KHONG co tuyen co dinh: lay xe o tram bat ky, tra o tram
   cung loai bat ky (backend tu noi cac tram, xem routing.config.ts)
   --------------------------------------------------------------------- */
INSERT INTO Routes (RouteCode, RouteName, TransportTypeId, Description) VALUES
('23', N'Nguyễn Công Trứ - Nguyễn Công Trứ', 1, N'Tuyến buýt 23 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('BRT01', N'Kim Mã - Bến xe Yên Nghĩa', 1, N'Tuyến buýt BRT01 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('09A', N'Trần Khánh Dư - Cầu Giấy - Đại học Mỏ', 1, N'Tuyến buýt 09A - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('31', N'Đại học Bách Khoa - Chèm (Đại học Mỏ)', 1, N'Tuyến buýt 31 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('01', N'Bến xe Gia Lâm - Bến xe Yên Nghĩa', 1, N'Tuyến buýt 01 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('24', N'Long Biên - Ngã Tư Sở - Cầu Giấy', 1, N'Tuyến buýt 24 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('02', N'Bác Cổ - Bến xe Yên Nghĩa', 1, N'Tuyến buýt 02 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('60A', N'Công Viên Nước Hồ Tây - KĐT Pháp Vân, Tứ Hiệp', 1, N'Tuyến buýt 60A - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('03A', N'Bến xe Giáp Bát - Bến xe Gia Lâm', 1, N'Tuyến buýt 03A - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('25', N'Bến xe Giáp Bát - Bệnh viện Nhiệt đới Trung ương cơ sở 2', 1, N'Tuyến buýt 25 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('49', N'Trần Khánh Dư - Nhổn', 1, N'Tuyến buýt 49 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('08A', N'Long Biên - Đông Mỹ', 1, N'Tuyến buýt 08A - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('13', N'Công viên Nước Hồ Tây - Cổ Nhuế (Học viện Cảnh sát)', 1, N'Tuyến buýt 13 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('41', N'Nam Thăng Long - Bến Xe Giáp Bát', 1, N'Tuyến buýt 41 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('32', N'Bến xe Giáp Bát - Nhổn', 1, N'Tuyến buýt 32 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('36', N'Long Biên - Yên Xá', 1, N'Tuyến buýt 36 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('33', N'Xuân Đỉnh - Cụm công nghiệp Thanh Oai', 1, N'Tuyến buýt 33 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('34', N'Bến xe Mỹ Đình - Bến xe Gia Lâm', 1, N'Tuyến buýt 34 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('38', N'Mai Động - Tân Xuân', 1, N'Tuyến buýt 38 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('50', N'Long Biên - Khu đô thị An Lạc (Hoài Đức)', 1, N'Tuyến buýt 50 - lộ trình theo OpenStreetMap, giờ chạy 05:00 - 21:00 (Vinpearl)'),
('METRO2A', N'Cát Linh - Hà Đông', 2, N'Tuyến đường sắt đô thị số 2A, 12 ga trên cao (nguồn: metrohanoi.vn). Giờ chạy 05:15 - 22:30.'),
('METRO3', N'Nhổn - Cầu Giấy', 2, N'Tuyến đường sắt đô thị số 3.1 Nhổn - Ga Hà Nội, đoạn trên cao Nhổn - Cầu Giấy (8 ga, nguồn: metrohanoi.vn). Giờ chạy 05:30 - 22:00.');
GO

/* ---------------------------------------------------------------------
   6. RouteStations  (DistanceFromStart: met, do doc theo duong that tren OSM;
      Metro: theo chieu dai tuyen chinh thuc 13.05 km / 8.5 km)
   --------------------------------------------------------------------- */
INSERT INTO RouteStations (RouteId, StationId, StopOrder, DistanceFromStart) VALUES
-- 23: Nguyễn Công Trứ - Nguyễn Công Trứ
(1, 134, 1, 0), (1, 40, 2, 407), (1, 135, 3, 994), (1, 66, 4, 1453), (1, 136, 5, 2110), (1, 83, 6, 2575), (1, 39, 7, 2990), (1, 137, 8, 3724), (1, 138, 9, 4173), (1, 139, 10, 4581), (1, 140, 11, 5089), (1, 141, 12, 5715), (1, 63, 13, 6105), (1, 142, 14, 6561), (1, 44, 15, 6966), (1, 143, 16, 7189), (1, 14, 17, 7827), (1, 84, 18, 8416), (1, 70, 19, 8816), (1, 110, 20, 9603), (1, 108, 21, 10079), (1, 91, 22, 10643), (1, 118, 23, 11086), (1, 144, 24, 11480), (1, 73, 25, 11994), (1, 145, 26, 12374), (1, 50, 27, 13153), (1, 146, 28, 13863), (1, 75, 29, 14450), (1, 95, 30, 15428), (1, 147, 31, 15858), (1, 148, 32, 16140), (1, 149, 33, 16495), (1, 150, 34, 16861),
-- BRT01: Kim Mã - Bến xe Yên Nghĩa
(2, 151, 1, 0), (2, 152, 2, 562), (2, 153, 3, 1287), (2, 154, 4, 2285), (2, 155, 5, 2900), (2, 156, 6, 4030), (2, 157, 7, 4663), (2, 158, 8, 5511), (2, 159, 9, 5971), (2, 160, 10, 6874), (2, 161, 11, 7434), (2, 162, 12, 8015), (2, 163, 13, 8611), (2, 164, 14, 9126), (2, 165, 15, 9622), (2, 166, 16, 10205), (2, 167, 17, 10681), (2, 168, 18, 11204), (2, 169, 19, 11698), (2, 170, 20, 12249), (2, 171, 21, 12725), (2, 172, 22, 13278), (2, 173, 23, 14645),
-- 09A: Trần Khánh Dư - Cầu Giấy - Đại học Mỏ
(3, 174, 1, 0), (3, 94, 2, 534), (3, 175, 3, 917), (3, 176, 4, 1248), (3, 79, 5, 1616), (3, 177, 6, 1922), (3, 132, 7, 2229), (3, 133, 8, 2556), (3, 100, 9, 3082), (3, 178, 10, 3486), (3, 179, 11, 4160), (3, 120, 12, 4516), (3, 180, 13, 5259), (3, 181, 14, 5731), (3, 96, 15, 6349), (3, 182, 16, 7157), (3, 183, 17, 7851), (3, 184, 18, 8490), (3, 185, 19, 9020), (3, 186, 20, 9632), (3, 51, 21, 10167), (3, 187, 22, 10633), (3, 48, 23, 11105), (3, 188, 24, 11387), (3, 189, 25, 11918), (3, 190, 26, 12270), (3, 191, 27, 12618), (3, 117, 28, 12988), (3, 192, 29, 13515), (3, 193, 30, 14449), (3, 194, 31, 14947), (3, 195, 32, 16137), (3, 196, 33, 16495), (3, 197, 34, 17222), (3, 198, 35, 17667), (3, 199, 36, 18189), (3, 200, 37, 18643), (3, 201, 38, 19195),
-- 31: Đại học Bách Khoa - Chèm (Đại học Mỏ)
(4, 202, 1, 0), (4, 203, 2, 926), (4, 46, 3, 1361), (4, 204, 4, 2168), (4, 125, 5, 2638), (4, 205, 6, 3153), (4, 206, 7, 3831), (4, 207, 8, 4199), (4, 208, 9, 4597), (4, 71, 10, 5229), (4, 29, 11, 5511), (4, 209, 12, 6490), (4, 210, 13, 6900), (4, 211, 14, 7305), (4, 212, 15, 7876), (4, 213, 16, 8439), (4, 214, 17, 9162), (4, 215, 18, 9505), (4, 87, 19, 10164), (4, 216, 20, 10633), (4, 23, 21, 11083), (4, 92, 22, 11489), (4, 42, 23, 12103), (4, 217, 24, 12565), (4, 218, 25, 13471), (4, 219, 26, 13860), (4, 220, 27, 14385), (4, 221, 28, 14987), (4, 222, 29, 15838), (4, 197, 30, 18211), (4, 198, 31, 18656), (4, 199, 32, 19177), (4, 223, 33, 19476),
-- 01: Bến xe Gia Lâm - Bến xe Yên Nghĩa
(5, 224, 1, 0), (5, 13, 2, 1154), (5, 225, 3, 2122), (5, 226, 4, 2749), (5, 227, 5, 5685), (5, 228, 6, 6401), (5, 130, 7, 7147), (5, 229, 8, 7660), (5, 230, 9, 7833), (5, 64, 10, 8599), (5, 231, 11, 8863), (5, 97, 12, 9629), (5, 20, 13, 10105), (5, 232, 14, 10944), (5, 28, 15, 11551), (5, 109, 16, 12025), (5, 2, 17, 13258), (5, 37, 18, 13661), (5, 8, 19, 14018), (5, 7, 20, 14468), (5, 6, 21, 15014), (5, 5, 22, 15499), (5, 233, 23, 15874), (5, 4, 24, 16321), (5, 3, 25, 16805), (5, 234, 26, 17292), (5, 235, 27, 17681), (5, 236, 28, 18217), (5, 237, 29, 18624), (5, 238, 30, 19057), (5, 239, 31, 19716), (5, 240, 32, 20003), (5, 241, 33, 20376), (5, 242, 34, 20697), (5, 243, 35, 21150), (5, 244, 36, 21414), (5, 245, 37, 21774), (5, 173, 38, 22263),
-- 24: Long Biên - Ngã Tư Sở - Cầu Giấy
(6, 246, 1, 0), (6, 247, 2, 1266), (6, 248, 3, 2091), (6, 174, 4, 2480), (6, 249, 5, 2938), (6, 77, 6, 3251), (6, 36, 7, 3928), (6, 57, 8, 4427), (6, 250, 9, 5115), (6, 251, 10, 5745), (6, 252, 11, 6025), (6, 253, 12, 6426), (6, 254, 13, 6972), (6, 67, 14, 7445), (6, 27, 15, 7698), (6, 255, 16, 8163), (6, 256, 17, 8741), (6, 90, 18, 9521), (6, 257, 19, 10548), (6, 72, 20, 10896), (6, 258, 21, 11206), (6, 259, 22, 11801), (6, 122, 23, 12420), (6, 260, 24, 13194), (6, 99, 25, 13899), (6, 261, 26, 14413), (6, 262, 27, 15526),
-- 02: Bác Cổ - Bến xe Yên Nghĩa
(7, 174, 1, 0), (7, 94, 2, 534), (7, 175, 3, 917), (7, 176, 4, 1248), (7, 79, 5, 1616), (7, 177, 6, 1922), (7, 132, 7, 2229), (7, 133, 8, 2556), (7, 100, 9, 3082), (7, 119, 10, 3451), (7, 263, 11, 3814), (7, 264, 12, 4592), (7, 265, 13, 4892), (7, 62, 14, 5484), (7, 232, 15, 5993), (7, 28, 16, 6600), (7, 109, 17, 7074), (7, 2, 18, 8308), (7, 37, 19, 8710), (7, 8, 20, 9067), (7, 7, 21, 9517), (7, 6, 22, 10062), (7, 5, 23, 10547), (7, 233, 24, 10922), (7, 4, 25, 11369), (7, 3, 26, 11853), (7, 234, 27, 12341), (7, 235, 28, 12730), (7, 236, 29, 13266), (7, 237, 30, 13673), (7, 238, 31, 14106), (7, 239, 32, 14764), (7, 240, 33, 15052), (7, 241, 34, 15425), (7, 242, 35, 15745), (7, 243, 36, 16198), (7, 244, 37, 16462), (7, 245, 38, 16822), (7, 173, 39, 17310),
-- 60A: Công Viên Nước Hồ Tây - KĐT Pháp Vân, Tứ Hiệp
(8, 266, 1, 0), (8, 267, 2, 789), (8, 268, 3, 1199), (8, 269, 4, 1411), (8, 270, 5, 2207), (8, 271, 6, 2890), (8, 272, 7, 3380), (8, 273, 8, 4884), (8, 274, 9, 5246), (8, 131, 10, 6276), (8, 275, 11, 6750), (8, 113, 12, 7129), (8, 276, 13, 7483), (8, 277, 14, 8351), (8, 278, 15, 8832), (8, 279, 16, 9393), (8, 280, 17, 9761), (8, 281, 18, 10684), (8, 282, 19, 11251), (8, 283, 20, 11781), (8, 284, 21, 12262), (8, 285, 22, 12887), (8, 43, 23, 13561), (8, 286, 24, 13847), (8, 287, 25, 14308), (8, 288, 26, 14537), (8, 289, 27, 15238), (8, 7, 28, 15692), (8, 290, 29, 16352), (8, 291, 30, 16865), (8, 292, 31, 17702), (8, 293, 32, 18204), (8, 294, 33, 19033), (8, 80, 34, 19585), (8, 295, 35, 20024), (8, 296, 36, 20500), (8, 78, 37, 21006), (8, 297, 38, 21798), (8, 298, 39, 22181), (8, 17, 40, 22557), (8, 299, 41, 22981), (8, 300, 42, 23578), (8, 301, 43, 24050), (8, 302, 44, 24644),
-- 03A: Bến xe Giáp Bát - Bến xe Gia Lâm
(9, 303, 1, 0), (9, 304, 2, 524), (9, 305, 3, 1030), (9, 306, 4, 1485), (9, 34, 5, 2348), (9, 307, 6, 2768), (9, 18, 7, 3280), (9, 30, 8, 3791), (9, 308, 9, 4526), (9, 309, 10, 4984), (9, 310, 11, 5439), (9, 101, 12, 6033), (9, 311, 13, 6361), (9, 86, 14, 8010), (9, 50, 15, 9681), (9, 312, 16, 12158), (9, 313, 17, 12768), (9, 314, 18, 13596), (9, 224, 19, 14118),
-- 25: Bến xe Giáp Bát - Bệnh viện Nhiệt đới Trung ương cơ sở 2
(10, 315, 1, 0), (10, 304, 2, 513), (10, 305, 3, 1019), (10, 306, 4, 1474), (10, 34, 5, 2337), (10, 307, 6, 2757), (10, 316, 7, 3836), (10, 9, 8, 4257), (10, 317, 9, 4566), (10, 318, 10, 5159), (10, 319, 11, 5546), (10, 320, 12, 6079), (10, 32, 13, 6555), (10, 116, 14, 7695), (10, 182, 15, 8387), (10, 183, 16, 9097), (10, 184, 17, 9736), (10, 185, 18, 10267), (10, 321, 19, 10773), (10, 322, 20, 11160), (10, 323, 21, 11899), (10, 324, 22, 12219), (10, 325, 23, 12645), (10, 326, 24, 12981), (10, 327, 25, 13479), (10, 328, 26, 13832),
-- 49: Trần Khánh Dư - Nhổn
(11, 174, 1, 0), (11, 94, 2, 534), (11, 175, 3, 917), (11, 69, 4, 1298), (11, 128, 5, 1683), (11, 329, 6, 1994), (11, 114, 7, 2355), (11, 231, 8, 3082), (11, 97, 9, 3848), (11, 20, 10, 4324), (11, 318, 11, 5152), (11, 320, 12, 6072), (11, 32, 13, 6548), (11, 330, 14, 7156), (11, 81, 15, 7663), (11, 331, 16, 10033), (11, 332, 17, 10500), (11, 333, 18, 10806), (11, 334, 19, 11160), (11, 335, 20, 11404), (11, 336, 21, 11743), (11, 337, 22, 12173), (11, 338, 23, 12641), (11, 339, 24, 13781), (11, 340, 25, 14175), (11, 341, 26, 14756), (11, 342, 27, 15395), (11, 343, 28, 16361), (11, 344, 29, 17114), (11, 49, 30, 17718), (11, 345, 31, 18304), (11, 346, 32, 18951),
-- 08A: Long Biên - Đông Mỹ
(12, 347, 1, 0), (12, 146, 2, 1100), (12, 75, 3, 1687), (12, 348, 4, 2310), (12, 128, 5, 2663), (12, 93, 6, 2909), (12, 126, 7, 3234), (12, 104, 8, 3602), (12, 135, 9, 4104), (12, 56, 10, 5036), (12, 25, 11, 5372), (12, 83, 12, 5494), (12, 349, 13, 6040), (12, 350, 14, 6288), (12, 255, 15, 6582), (12, 15, 16, 7405), (12, 351, 17, 8020), (12, 352, 18, 8386), (12, 353, 19, 8936), (12, 19, 20, 9279), (12, 354, 21, 9780), (12, 355, 22, 10660), (12, 299, 23, 11052), (12, 124, 24, 11680), (12, 123, 25, 12005), (12, 1, 26, 12619), (12, 127, 27, 13108),
-- 13: Công viên Nước Hồ Tây - Cổ Nhuế (Học viện Cảnh sát)
(13, 266, 1, 0), (13, 356, 2, 223), (13, 267, 3, 789), (13, 35, 4, 1138), (13, 54, 5, 1440), (13, 98, 6, 1704), (13, 59, 7, 2254), (13, 357, 8, 2905), (13, 358, 9, 3430), (13, 186, 10, 4147), (13, 359, 11, 5372), (13, 360, 12, 6005), (13, 361, 13, 6438), (13, 278, 14, 7298), (13, 337, 15, 7718), (13, 338, 16, 8186), (13, 362, 17, 9052), (13, 363, 18, 9464), (13, 364, 19, 9985), (13, 365, 20, 10978), (13, 366, 21, 12086), (13, 367, 22, 13148), (13, 368, 23, 13494), (13, 369, 24, 13770),
-- 41: Nam Thăng Long - Bến Xe Giáp Bát
(14, 370, 1, 0), (14, 371, 2, 670), (14, 372, 3, 1935), (14, 373, 4, 2308), (14, 374, 5, 2561), (14, 375, 6, 2972), (14, 376, 7, 3545), (14, 327, 8, 4066), (14, 328, 9, 4525), (14, 377, 10, 5186), (14, 24, 11, 6363), (14, 21, 12, 6962), (14, 61, 13, 8127), (14, 378, 14, 8808), (14, 379, 15, 9237), (14, 85, 16, 11211), (14, 380, 17, 11751), (14, 16, 18, 12274), (14, 227, 19, 12792), (14, 41, 20, 13182), (14, 381, 21, 13580), (14, 107, 22, 14316), (14, 382, 23, 15013), (14, 47, 24, 15615), (14, 264, 25, 16232), (14, 265, 26, 16622), (14, 62, 27, 17391), (14, 33, 28, 17820), (14, 45, 29, 18499), (14, 383, 30, 19099), (14, 384, 31, 19948), (14, 385, 32, 20649), (14, 65, 33, 21219), (14, 15, 34, 22358), (14, 351, 35, 23157), (14, 352, 36, 23632), (14, 386, 37, 24203),
-- 32: Bến xe Giáp Bát - Nhổn
(15, 387, 1, 0), (15, 304, 2, 502), (15, 305, 3, 1008), (15, 306, 4, 1463), (15, 34, 5, 2326), (15, 307, 6, 2746), (15, 18, 7, 3257), (15, 30, 8, 3769), (15, 308, 9, 4504), (15, 309, 10, 4962), (15, 112, 11, 5193), (15, 100, 12, 6000), (15, 119, 13, 6369), (15, 263, 14, 6732), (15, 388, 15, 7406), (15, 389, 16, 7989), (15, 116, 17, 8766), (15, 182, 18, 9458), (15, 89, 19, 10515), (15, 331, 20, 11133), (15, 332, 21, 11600), (15, 333, 22, 11905), (15, 334, 23, 12259), (15, 335, 24, 12504), (15, 336, 25, 12843), (15, 337, 26, 13274), (15, 390, 27, 13895), (15, 362, 28, 14608), (15, 363, 29, 15020), (15, 22, 30, 15365), (15, 391, 31, 15859), (15, 392, 32, 16396), (15, 393, 33, 17022), (15, 394, 34, 17920), (15, 395, 35, 18178),
-- 36: Long Biên - Yên Xá
(16, 347, 1, 0), (16, 229, 2, 2739), (16, 88, 3, 3060), (16, 93, 4, 3509), (16, 126, 5, 3833), (16, 104, 6, 4201), (16, 135, 7, 4703), (16, 56, 8, 5636), (16, 396, 9, 6067), (16, 58, 10, 6448), (16, 397, 11, 6740), (16, 398, 12, 7210), (16, 399, 13, 7808), (16, 55, 14, 8289), (16, 19, 15, 9059), (16, 354, 16, 9561), (16, 400, 17, 10293), (16, 74, 18, 10862), (16, 401, 19, 12395), (16, 402, 20, 12784), (16, 403, 21, 13663), (16, 404, 22, 14298), (16, 405, 23, 15365), (16, 406, 24, 17592),
-- 33: Xuân Đỉnh - Cụm công nghiệp Thanh Oai
(17, 374, 1, 0), (17, 375, 2, 317), (17, 407, 3, 881), (17, 59, 4, 1256), (17, 357, 5, 1906), (17, 358, 6, 2431), (17, 186, 7, 3148), (17, 51, 8, 3683), (17, 187, 9, 4149), (17, 48, 10, 4622), (17, 188, 11, 4903), (17, 277, 12, 5567), (17, 278, 13, 6048), (17, 279, 14, 6610), (17, 280, 15, 6976), (17, 408, 16, 7380), (17, 281, 17, 7976), (17, 282, 18, 8543), (17, 283, 19, 9073), (17, 409, 20, 9974), (17, 410, 21, 10345), (17, 411, 22, 11314), (17, 412, 23, 11768), (17, 413, 24, 13056), (17, 414, 25, 13740), (17, 415, 26, 14331), (17, 416, 27, 14844), (17, 417, 28, 15105), (17, 418, 29, 15520), (17, 236, 30, 15747), (17, 237, 31, 16154), (17, 238, 32, 16587), (17, 239, 33, 17246), (17, 240, 34, 17534), (17, 241, 35, 17907), (17, 242, 36, 18227), (17, 419, 37, 18729), (17, 420, 38, 19506), (17, 421, 39, 19941),
-- 34: Bến xe Mỹ Đình - Bến xe Gia Lâm
(18, 408, 1, 0), (18, 422, 2, 610), (18, 423, 3, 1437), (18, 26, 4, 1764), (18, 424, 5, 2095), (18, 106, 6, 2361), (18, 425, 7, 2784), (18, 426, 8, 3078), (18, 427, 9, 3582), (18, 31, 10, 4298), (18, 121, 11, 4918), (18, 60, 12, 6074), (18, 38, 13, 6539), (18, 110, 14, 7188), (18, 108, 15, 7664), (18, 91, 16, 8228), (18, 118, 17, 8670), (18, 129, 18, 9219), (18, 88, 19, 9609), (18, 68, 20, 10029), (18, 207, 21, 10367), (18, 208, 22, 10780), (18, 71, 23, 11413), (18, 29, 24, 11694), (18, 50, 25, 12598), (18, 312, 26, 15075), (18, 313, 27, 15685), (18, 314, 28, 16513), (18, 224, 29, 17035),
-- 38: Mai Động - Tân Xuân
(19, 428, 1, 0), (19, 429, 2, 518), (19, 53, 3, 971), (19, 76, 4, 1531), (19, 253, 5, 2066), (19, 254, 6, 2612), (19, 67, 7, 3084), (19, 11, 8, 3225), (19, 12, 9, 3705), (19, 10, 10, 4108), (19, 204, 11, 4714), (19, 125, 12, 5184), (19, 105, 13, 6059), (19, 430, 14, 6362), (19, 230, 15, 7209), (19, 431, 16, 8070), (19, 432, 17, 8562), (19, 433, 18, 8852), (19, 434, 19, 9877), (19, 32, 20, 10570), (19, 435, 21, 11598), (19, 182, 22, 12418), (19, 102, 23, 13196), (19, 52, 24, 13504), (19, 111, 25, 14129), (19, 51, 26, 14863), (19, 187, 27, 15330), (19, 48, 28, 15802), (19, 188, 29, 16084), (19, 189, 30, 16615), (19, 190, 31, 16967), (19, 191, 32, 17314), (19, 117, 33, 17684), (19, 192, 34, 18211), (19, 193, 35, 19145), (19, 194, 36, 19644), (19, 195, 37, 20833), (19, 436, 38, 21723),
-- 50: Long Biên - Khu đô thị An Lạc (Hoài Đức)
(20, 437, 1, 0), (20, 107, 2, 1349), (20, 382, 3, 2046), (20, 263, 4, 2596), (20, 388, 5, 3468), (20, 389, 6, 4224), (20, 435, 7, 5069), (20, 438, 8, 6046), (20, 439, 9, 6810), (20, 440, 10, 7473), (20, 115, 11, 8601), (20, 103, 12, 9092), (20, 82, 13, 9766), (20, 441, 14, 10248), (20, 442, 15, 11317), (20, 443, 16, 11811), (20, 444, 17, 12346), (20, 445, 18, 13343), (20, 446, 19, 13864), (20, 447, 20, 14914), (20, 448, 21, 15731), (20, 449, 22, 16317), (20, 341, 23, 16828), (20, 342, 24, 17658), (20, 450, 25, 20188), (20, 451, 26, 20709), (20, 452, 27, 21301), (20, 453, 28, 22146),
-- METRO2A: Cát Linh - Hà Đông
(21, 454, 1, 0), (21, 455, 2, 991), (21, 456, 3, 1913), (21, 457, 4, 2946), (21, 458, 5, 4051), (21, 459, 6, 5120), (21, 460, 7, 6684), (21, 461, 8, 7875), (21, 462, 9, 9273), (21, 463, 10, 10439), (21, 464, 11, 11956), (21, 465, 12, 13050),
-- METRO3: Nhổn - Cầu Giấy
(22, 466, 1, 0), (22, 467, 2, 1199), (22, 468, 3, 2520), (22, 469, 4, 3446), (22, 470, 5, 4711), (22, 471, 6, 5854), (22, 472, 7, 7233), (22, 473, 8, 8500);
GO

/* Cap nhat tram dau / tram cuoi cho moi tuyen */
UPDATE r
SET StartStationId = (SELECT TOP 1 StationId FROM RouteStations WHERE RouteId = r.RouteId ORDER BY StopOrder ASC),
    EndStationId   = (SELECT TOP 1 StationId FROM RouteStations WHERE RouteId = r.RouteId ORDER BY StopOrder DESC)
FROM Routes r;
GO

/* ---------------------------------------------------------------------
   7 + 8. Trips + StopTimes (sinh tu dong)
   - Gio chay:
       Bus     05:00 - 21:00, 20 phut/chuyen (gio chay pho bien cua cac tuyen trong bai Vinpearl)
       Metro 2A  05:15 - 22:30, 10 phut/chuyen (metrohanoi.vn)
       Metro 3.1 05:30 - 22:00, 10 phut/chuyen (metrohanoi.vn)
   - Toc do (m/phut) dung chung voi backend (src/config/routing.config.ts):
       Bus 333 (~20km/h), Metro 583 (~35km/h)
   - Moi tram dung 1 phut
   - Xe dap / xe dien khong co lich chay (thue - tra tu do)
   --------------------------------------------------------------------- */
DECLARE @Mode TABLE (TransportTypeId INT PRIMARY KEY, Headway INT, SpeedMPerMin DECIMAL(10,2));
INSERT INTO @Mode VALUES (1, 20, 333), (2, 10, 583);

DECLARE @Schedule TABLE (RouteId INT PRIMARY KEY, FirstDeparture TIME, LastOffsetMinutes INT);
INSERT INTO @Schedule (RouteId, FirstDeparture, LastOffsetMinutes)
SELECT RouteId,
       CASE RouteCode WHEN 'METRO2A' THEN '05:15' WHEN 'METRO3' THEN '05:30' ELSE '05:00' END,
       CASE RouteCode WHEN 'METRO2A' THEN 1035   WHEN 'METRO3' THEN 990     ELSE 960 END
FROM Routes;

;WITH Nums AS (
    SELECT TOP (200) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects
)
INSERT INTO Trips (RouteId, VehicleId, TripCode, DepartureTime, ArrivalTime, Status)
SELECT
    r.RouteId,
    v.VehicleId,
    CONCAT(r.RouteCode, '-T', RIGHT('000' + CAST(n.n + 1 AS VARCHAR(4)), 3)),
    DATEADD(MINUTE, n.n * m.Headway, sc.FirstDeparture),
    DATEADD(MINUTE, n.n * m.Headway
                    + CAST(CEILING(d.MaxDistance / m.SpeedMPerMin) AS INT)
                    + (d.StopCount - 1),
            sc.FirstDeparture),
    'SCHEDULED'
FROM Routes r
JOIN @Mode m      ON m.TransportTypeId = r.TransportTypeId
JOIN @Schedule sc ON sc.RouteId = r.RouteId
CROSS APPLY (
    SELECT MAX(ISNULL(DistanceFromStart, 0)) AS MaxDistance, COUNT(*) AS StopCount
    FROM RouteStations WHERE RouteId = r.RouteId
) d
CROSS APPLY (
    SELECT COUNT(*) AS Cnt FROM Vehicles
    WHERE TransportTypeId = r.TransportTypeId AND Status = 'ACTIVE'
) vc
CROSS JOIN Nums n
CROSS APPLY (
    -- Xoay vong xe cung loai cho cac chuyen (xe thu k = (n + RouteId) mod so xe)
    SELECT x.VehicleId FROM (
        SELECT VehicleId, ROW_NUMBER() OVER (ORDER BY VehicleId) - 1 AS rn
        FROM Vehicles
        WHERE TransportTypeId = r.TransportTypeId AND Status = 'ACTIVE'
    ) x
    WHERE x.rn = (n.n + r.RouteId) % vc.Cnt
) v
WHERE n.n * m.Headway <= sc.LastOffsetMinutes;

INSERT INTO StopTimes (TripId, StationId, ArrivalTime, DepartureTime, StopOrder)
SELECT
    t.TripId,
    rs.StationId,
    DATEADD(MINUTE,
            CAST(CEILING(ISNULL(rs.DistanceFromStart, 0) / m.SpeedMPerMin) AS INT) + (rs.StopOrder - 1),
            t.DepartureTime),
    DATEADD(MINUTE,
            CAST(CEILING(ISNULL(rs.DistanceFromStart, 0) / m.SpeedMPerMin) AS INT) + (rs.StopOrder - 1)
            + CASE WHEN rs.StopOrder = 1 THEN 0 ELSE 1 END,
            t.DepartureTime),
    rs.StopOrder
FROM Trips t
JOIN Routes r         ON r.RouteId = t.RouteId
JOIN @Mode m          ON m.TransportTypeId = r.TransportTypeId
JOIN RouteStations rs ON rs.RouteId = t.RouteId;

/* ---------------------------------------------------------------------
   Doi xe theo tuyen: moi chuyen co 1 xe rieng, KHONG xe nao chay 2 chuyen cung luc.
     So xe can cho 1 tuyen = CEILING((thoi gian 1 chuyen + 10 phut quay dau) / gian cach)
     Chuyen thu n cua tuyen -> xe so (n mod so_xe) + 1
   Chi gan lai cac chuyen mau (ma <RouteCode>-Txxx); chuyen admin tu tao giu nguyen.
   --------------------------------------------------------------------- */
DECLARE @Fleet TABLE (RouteId INT PRIMARY KEY, RouteCode VARCHAR(50), TransportTypeId INT, Need INT);
;WITH seedTrips AS (
    SELECT t.TripId, t.RouteId, r.RouteCode, r.TransportTypeId,
           DATEDIFF(MINUTE, t.DepartureTime, t.ArrivalTime) AS Dur,
           DATEDIFF(MINUTE, LAG(t.DepartureTime) OVER (PARTITION BY t.RouteId ORDER BY t.DepartureTime), t.DepartureTime) AS Gap
    FROM Trips t JOIN Routes r ON r.RouteId = t.RouteId
    WHERE t.TripCode LIKE r.RouteCode + '-T[0-9][0-9][0-9]'
)
INSERT INTO @Fleet (RouteId, RouteCode, TransportTypeId, Need)
SELECT RouteId, RouteCode, TransportTypeId,
       CASE WHEN MIN(Gap) IS NULL OR MIN(Gap) <= 0 THEN COUNT(*)
            ELSE CEILING((MAX(Dur) + 10.0) / MIN(Gap)) END
FROM seedTrips GROUP BY RouteId, RouteCode, TransportTypeId;

;WITH Nums AS (SELECT TOP (100) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS k FROM sys.all_objects)
INSERT INTO Vehicles (TransportTypeId, VehicleCode, VehicleName, Capacity, Status)
SELECT f.TransportTypeId,
       CONCAT(CASE f.TransportTypeId WHEN 2 THEN 'TAU-' ELSE 'BUS-' END, f.RouteCode, '-', RIGHT('0' + CAST(n.k AS VARCHAR(3)), 2)),
       CASE f.TransportTypeId
            WHEN 2 THEN CONCAT(N'Tàu ', REPLACE(f.RouteCode, 'METRO', N'Metro '), N' - đoàn ', RIGHT('0' + CAST(n.k AS VARCHAR(3)), 2))
            ELSE CONCAT(N'Xe buýt tuyến ', f.RouteCode, N' - xe ', RIGHT('0' + CAST(n.k AS VARCHAR(3)), 2)) END,
       CASE f.TransportTypeId WHEN 2 THEN 900 ELSE 60 END,
       'ACTIVE'
FROM @Fleet f JOIN Nums n ON n.k <= f.Need
WHERE NOT EXISTS (
    SELECT 1 FROM Vehicles v
    WHERE v.VehicleCode = CONCAT(CASE f.TransportTypeId WHEN 2 THEN 'TAU-' ELSE 'BUS-' END, f.RouteCode, '-', RIGHT('0' + CAST(n.k AS VARCHAR(3)), 2)));

;WITH ordered AS (
    SELECT t.TripId, f.RouteCode, f.TransportTypeId, f.Need,
           ROW_NUMBER() OVER (PARTITION BY t.RouteId ORDER BY t.DepartureTime, t.TripId) - 1 AS n
    FROM Trips t JOIN @Fleet f ON f.RouteId = t.RouteId
    WHERE t.TripCode LIKE f.RouteCode + '-T[0-9][0-9][0-9]'
)
UPDATE t SET VehicleId = v.VehicleId
FROM Trips t
JOIN ordered o ON o.TripId = t.TripId
JOIN Vehicles v ON v.VehicleCode = CONCAT(CASE o.TransportTypeId WHEN 2 THEN 'TAU-' ELSE 'BUS-' END, o.RouteCode, '-',
                                          RIGHT('0' + CAST(o.n % o.Need + 1 AS VARCHAR(3)), 2));
GO

/* ---------------------------------------------------------------------
   9. TouristAttractions (20 diem) - noi dung mo ta tong quan.
   Gio mo cua / gia ve chi mang tinh tham khao, can kiem chung lai
   tu nguon chinh thuc truoc khi dua vao bao cao.
   --------------------------------------------------------------------- */
INSERT INTO TouristAttractions
(Name, Description, History, Highlights, Address, Latitude, Longitude, Category, OpeningHours, TicketPrice, PopularityScore,
 HoursSummary, PriceFrom, VisitDuration, BestTime, Tips)
VALUES
(N'Hồ Hoàn Kiếm',
 N'Hồ nước rộng khoảng 12 ha giữa trung tâm Hà Nội, được xem là trái tim của thủ đô. Quanh hồ là phố đi bộ, Đền Ngọc Sơn, Tháp Bút và các con phố cổ, phố Pháp.',
 N'Xưa kia hồ có tên Lục Thủy vì nước xanh quanh năm. Theo truyền thuyết, sau khi đánh thắng quân Minh, vua Lê Lợi dạo thuyền trên hồ và trả lại gươm thần cho Rùa Vàng, từ đó hồ mang tên Hoàn Kiếm (trả gươm). Tháp Rùa trên gò giữa hồ được xây năm 1886. Từ năm 2016, các tuyến phố quanh hồ trở thành không gian đi bộ vào cuối tuần.',
 N'Tháp Rùa trên gò giữa hồ, lung linh khi lên đèn|Cầu Thê Húc sơn đỏ dẫn vào Đền Ngọc Sơn|Tháp Bút – Đài Nghiên ở cửa đền|Phố đi bộ cuối tuần với biểu diễn đường phố, trò chơi dân gian|Buổi sáng sớm người dân tập thể dục, đi bộ quanh hồ',
 N'Hoàn Kiếm, Hà Nội', 21.028511, 105.854444, N'Danh thắng',
 N'Khu vực công cộng, mở cửa 24/24. Phố đi bộ quanh hồ: từ 19:00 thứ Sáu đến 24:00 Chủ nhật hằng tuần.',
 N'Miễn phí. Riêng Đền Ngọc Sơn trên hồ thu vé 50.000đ/người lớn.', 98,
 N'Cả ngày · Phố đi bộ T6–CN', N'Miễn phí', N'1 – 2 giờ',
 N'Sáng sớm (5:30–7:00) khi hồ yên tĩnh, hoặc tối thứ Sáu – Chủ nhật khi có phố đi bộ.',
 N'Đi một vòng quanh hồ khoảng 1,7 km, mất 30–40 phút đi bộ|Cuối tuần ô tô, xe máy bị cấm quanh hồ – nên đi bộ hoặc gửi xe ở các phố lân cận|Kết hợp Đền Ngọc Sơn, Nhà hát Múa rối Thăng Long và phố cổ trong cùng một buổi'),

(N'Đền Ngọc Sơn',
 N'Ngôi đền trên đảo Ngọc ở phía bắc hồ Hoàn Kiếm, nối với bờ bằng cầu Thê Húc sơn đỏ – một trong những hình ảnh biểu tượng của Hà Nội.',
 N'Đền thờ Văn Xương Đế Quân (vị thần coi việc văn chương, thi cử) và Đức Thánh Trần Hưng Đạo – người ba lần đánh thắng quân Nguyên Mông. Năm 1865, nhà nho Nguyễn Văn Siêu đứng ra tu sửa đền, dựng thêm Tháp Bút, Đài Nghiên và cầu Thê Húc. Trong đền hiện trưng bày tiêu bản cụ Rùa Hồ Gươm – cá thể rùa Hoàn Kiếm mất năm 2016.',
 N'Cầu Thê Húc ("nơi đậu ánh sáng ban mai")|Tháp Bút và Đài Nghiên ở lối vào|Đắc Nguyệt Lâu và Trấn Ba Đình|Tiêu bản cụ Rùa Hồ Gươm trong tủ kính|Kiến trúc đình, đền thế kỷ XIX',
 N'Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội', 21.030035, 105.852640, N'Di tích',
 N'Thứ Hai – thứ Sáu: 7:00 – 18:00. Thứ Bảy, Chủ nhật: 7:00 – 21:00. Giờ có thể thay đổi dịp Tết và lễ lớn.',
 N'Người lớn: 50.000đ (áp dụng từ 01/2024). Nên hỏi quầy vé về mức giảm cho học sinh, sinh viên.', 88,
 N'7:00 – 18:00 (cuối tuần đến 21:00)', N'50.000đ', N'30 – 45 phút',
 N'Buổi sáng để có ánh sáng đẹp trên cầu Thê Húc; tối cuối tuần khi hồ lên đèn.',
 N'Ăn mặc kín đáo (che vai, đầu gối), giữ trật tự trong khu thờ|Không chạm vào ban thờ, đồ lễ; chụp ảnh người đang lễ cần tế nhị|Cầu Thê Húc có thể đóng vào các dịp lễ hội lớn'),

(N'Phố cổ Hà Nội',
 N'Khu "36 phố phường" phía bắc hồ Hoàn Kiếm với những dãy nhà ống, mái ngói cổ và các con phố mang tên nghề truyền thống như Hàng Bạc, Hàng Mã, Hàng Đường, Hàng Gai.',
 N'Khu phố cổ hình thành từ thời Lý – Trần, là nơi các phường thợ thủ công và thương nhân tụ họp buôn bán bên ngoài hoàng thành. Mỗi phố thường chuyên một mặt hàng nên tên phố gắn với chữ "Hàng". Ô Quan Chưởng là cửa ô duy nhất còn lại của kinh thành Thăng Long; nhà cổ 87 Mã Mây giữ nguyên kiến trúc nhà ống cuối thế kỷ XIX.',
 N'Ô Quan Chưởng – cửa ô cổ duy nhất còn lại|Nhà cổ 87 Mã Mây, đình Kim Ngân, đền Bạch Mã|Phố Hàng Mã rực rỡ đồ trang trí theo mùa lễ hội|Chợ đêm cuối tuần Hàng Đào – Đồng Xuân|Ẩm thực đường phố: phở, bún chả, bánh cuốn, cà phê trứng',
 N'Hoàn Kiếm, Hà Nội', 21.034000, 105.850000, N'Khu phố',
 N'Khu dân cư mở cửa cả ngày. Chợ đêm phố cổ: khoảng 18:00 – 24:00 thứ Sáu, thứ Bảy, Chủ nhật (Hàng Đào → Đồng Xuân).',
 N'Đi dạo miễn phí. Một số di tích bán vé riêng (ví dụ nhà cổ 87 Mã Mây).', 95,
 N'Cả ngày · Chợ đêm T6–CN', N'Miễn phí', N'Nửa ngày',
 N'Sáng sớm để thấy nhịp sống buôn bán, hoặc tối cuối tuần khi có phố đi bộ và chợ đêm.',
 N'Đường hẹp, đông xe máy – đi bộ cẩn thận, giữ túi xách phía trước|Mặc cả khi mua hàng lưu niệm|Nên đi theo tuyến Hàng Đào – Hàng Ngang – Hàng Đường để tới chợ Đồng Xuân'),

(N'Chợ Đồng Xuân',
 N'Chợ có mái che lâu đời và lớn nhất Hà Nội, ba tầng bán buôn, bán lẻ đủ loại hàng: vải vóc, quần áo, đồ gia dụng, đồ khô và đặc sản.',
 N'Chợ được người Pháp xây dựng năm 1889 để tập trung buôn bán trong khu phố cổ, mặt tiền có 5 vòm cổng đặc trưng. Năm 1994, một trận hỏa hoạn lớn thiêu rụi phần lớn công trình; chợ được xây lại và hoàn thành năm 1996, giữ lại mặt tiền năm vòm.',
 N'Mặt tiền năm vòm cổng từ thời Pháp|Tầng 1: vải vóc, quần áo, đồ khô, thực phẩm|Các tầng trên: đồ gia dụng, phụ kiện, hàng bán buôn|Phố ẩm thực Hàng Khoai phía sau chợ buổi tối|Điểm cuối của chợ đêm phố cổ cuối tuần',
 N'Đồng Xuân, Hoàn Kiếm, Hà Nội', 21.038100, 105.849700, N'Chợ',
 N'Chợ hoạt động từ sáng sớm đến chiều (khoảng 6:00 – 18:00, nhiều quầy dọn hàng từ sau 14:00). Chợ đêm khu Đồng Xuân: khoảng 18:00 – 24:00 thứ Sáu – Chủ nhật.',
 N'Vào chợ miễn phí.', 80,
 N'Khoảng 6:00 – 18:00', N'Miễn phí', N'1 – 1,5 giờ',
 N'9:00 – 11:00 khi chợ đã đông hàng nhưng bớt cảnh bốc dỡ buổi sáng sớm.',
 N'Mang tiền mặt, phần lớn quầy không nhận thẻ|Vải ở đây thường rẻ hơn nhiều so với phố Hàng Gai; nên mặc cả|Hỏi trước khi chụp ảnh người bán; giữ đồ cẩn thận ở chỗ đông'),

(N'Nhà hát Lớn Hà Nội',
 N'Công trình kiến trúc Pháp tiêu biểu tại Quảng trường Cách mạng Tháng Tám, nơi biểu diễn opera, nhạc giao hưởng và các chương trình nghệ thuật lớn của thủ đô.',
 N'Nhà hát được xây dựng từ năm 1901 đến 1911, lấy cảm hứng từ Nhà hát Opera Garnier ở Paris, mang phong cách tân cổ điển kết hợp chi tiết Baroque. Tháng 8/1945, quảng trường trước nhà hát là nơi diễn ra cuộc mít tinh lớn mở đầu cho cuộc Tổng khởi nghĩa giành chính quyền ở Hà Nội.',
 N'Mặt tiền tân cổ điển với mái vòm và cột đá|Cầu thang đá hình chữ T ở sảnh chính|Phòng Gương dành cho lễ tân, hội họp|Khán phòng hình móng ngựa khoảng 600 ghế|Quảng trường Cách mạng Tháng Tám phía trước',
 N'Số 1 Tràng Tiền, Hoàn Kiếm, Hà Nội', 21.024206, 105.857265, N'Kiến trúc',
 N'Tham quan bên trong theo tour có hướng dẫn vào các ngày, khung giờ cố định (60 – 90 phút) và theo lịch biểu diễn buổi tối. Nên xem lịch trên kênh chính thức của nhà hát trước khi đi.',
 N'Tour tham quan: khoảng 120.000 – 400.000đ tùy gói (có gói kèm biểu diễn ngắn). Vé biểu diễn từ khoảng 300.000đ, các đêm gala cao hơn nhiều.', 85,
 N'Theo lịch tour và biểu diễn', N'Từ ~120.000đ (tour)', N'1 – 1,5 giờ (tour)',
 N'Chiều muộn để chụp mặt tiền; buổi tối khi có chương trình biểu diễn.',
 N'Đặt tour hoặc vé trước vài ngày, dịp lễ nên đặt trước 2 – 4 tuần|Trang phục lịch sự, tránh quần đùi, dép lê khi xem biểu diễn|Chụp ảnh thường được phép trong tour nhưng bị cấm khi đang biểu diễn'),

(N'Nhà tù Hỏa Lò',
 N'Di tích nhà tù do thực dân Pháp xây dựng, nơi giam giữ nhiều thế hệ chiến sĩ cách mạng Việt Nam và sau này là phi công Mỹ bị bắn rơi trong chiến tranh.',
 N'Nhà tù được người Pháp xây năm 1896 với tên Maison Centrale, là một trong những nhà tù lớn nhất Đông Dương thời bấy giờ. Nhiều lãnh đạo cách mạng từng bị giam tại đây. Trong chiến tranh chống Mỹ, nơi này giam giữ phi công Mỹ và được họ gọi đùa là "Hanoi Hilton". Phần lớn khu nhà tù bị phá dỡ vào thập niên 1990; phần còn lại được bảo tồn làm di tích.',
 N'Cổng "Maison Centrale" nguyên bản|Khu tái hiện buồng giam, xà lim, máy chém|Đường hầm và câu chuyện những cuộc vượt ngục|Khu trưng bày về phi công Mỹ – "Hanoi Hilton"|Đài tưởng niệm các chiến sĩ cách mạng',
 N'Số 1 Hỏa Lò, Hoàn Kiếm, Hà Nội', 21.025700, 105.846800, N'Di tích',
 N'8:00 – 17:00 tất cả các ngày, kể cả lễ, Tết (quầy vé thường dừng bán khoảng 16:30). Tour đêm "Đêm thiêng liêng": tối thứ Sáu và thứ Bảy, 19:00 – 21:00, cần đặt trước.',
 N'Người lớn: 50.000đ. Học sinh, sinh viên, người từ 60 tuổi: 25.000đ. Trẻ em dưới 15 tuổi: miễn phí. Thuyết minh tự động: 50.000đ/máy. Tour đêm: 399.000 – 499.000đ.', 84,
 N'8:00 – 17:00 hằng ngày', N'50.000đ', N'1,5 – 2 giờ',
 N'Sáng các ngày trong tuần để tránh đông; tối thứ Sáu, thứ Bảy nếu tham gia tour đêm.',
 N'Nên thuê máy thuyết minh tự động để hiểu rõ từng khu trưng bày|Bỏ mũ, kính râm ở khu xà lim và khu tưởng niệm|Gửi balo lớn ở quầy gửi đồ miễn phí trước cửa soát vé'),

(N'Hoàng thành Thăng Long',
 N'Quần thể di tích gắn với lịch sử kinh thành Thăng Long – Hà Nội suốt hơn 13 thế kỷ, được UNESCO công nhận là Di sản Văn hóa Thế giới năm 2010.',
 N'Năm 1010, vua Lý Thái Tổ dời đô từ Hoa Lư về Đại La, đặt tên là Thăng Long, mở đầu thời kỳ kinh đô kéo dài qua các triều Lý, Trần, Lê. Khu khảo cổ 18 Hoàng Diệu đã phát lộ nhiều tầng văn hóa chồng lên nhau từ thời tiền Thăng Long đến thời Nguyễn. Trong kháng chiến chống Mỹ, khu vực này là Sở chỉ huy Bộ Quốc phòng với Nhà và Hầm D67.',
 N'Đoan Môn – cổng chính vào cấm thành|Nền điện Kính Thiên với đôi rồng đá thời Lê|Hậu Lâu (lầu Công chúa) và Bắc Môn|Khu khảo cổ 18 Hoàng Diệu|Nhà và Hầm D67, Cột cờ Hà Nội (xây năm 1812) gần đó',
 N'19C Hoàng Diệu, Ba Đình, Hà Nội', 21.035600, 105.841700, N'Di sản',
 N'8:00 – 17:00 tất cả các ngày trong tuần.',
 N'Người lớn: 100.000đ. Học sinh, sinh viên từ 16 tuổi, người từ 60 tuổi: 50.000đ. Trẻ em dưới 16 tuổi: miễn phí. (Giá tham khảo, nên kiểm tra tại quầy vé.)', 86,
 N'8:00 – 17:00 hằng ngày', N'100.000đ', N'2 – 3 giờ',
 N'Sáng sớm hoặc chiều muộn để tránh nắng, vì khu di tích rộng và nhiều đoạn ngoài trời.',
 N'Vé có thể mua online trên trang đặt vé của di tích (thanh toán thẻ)|Mang theo nước, mũ và giày thoải mái vì phải đi bộ nhiều|Kết hợp tham quan Cột cờ Hà Nội và Lăng Bác ở gần'),

(N'Lăng Chủ tịch Hồ Chí Minh',
 N'Nơi lưu giữ thi hài Chủ tịch Hồ Chí Minh, nằm trên Quảng trường Ba Đình, là công trình mang ý nghĩa thiêng liêng đặc biệt với người dân Việt Nam.',
 N'Lăng được khởi công ngày 2/9/1973 và khánh thành ngày 29/8/1975, với kiến trúc đá hoa cương mang dáng đài sen. Quần thể xung quanh gồm Phủ Chủ tịch, Nhà sàn Bác Hồ, ao cá, Bảo tàng Hồ Chí Minh và Chùa Một Cột.',
 N'Viếng Bác trong phòng thi hài trang nghiêm|Đội tiêu binh danh dự đổi gác|Nhà sàn và ao cá Bác Hồ trong khu Phủ Chủ tịch|Bảo tàng Hồ Chí Minh|Lễ thượng cờ, hạ cờ trên Quảng trường Ba Đình',
 N'Số 2 Hùng Vương, Ba Đình, Hà Nội', 21.036800, 105.834900, N'Di tích',
 N'Mùa hè (1/4 – 31/10): thứ Ba – thứ Năm 7:30 – 10:30; thứ Bảy, Chủ nhật, ngày lễ 7:30 – 11:00. Mùa đông (1/11 – 31/3): thứ Ba – thứ Năm 8:00 – 11:00; thứ Bảy, Chủ nhật, ngày lễ 8:00 – 11:30. Nghỉ thứ Hai và thứ Sáu. Hằng năm tạm dừng viếng khoảng 2 tháng để tu bổ (thường vào mùa thu) – cần xem thông báo chính thức.',
 N'Viếng Lăng miễn phí.', 92,
 N'Sáng T3, T4, T5, T7, CN', N'Miễn phí', N'1 – 1,5 giờ (riêng Lăng), 3 – 4 giờ cả quần thể',
 N'Đến sớm 30 – 45 phút trước giờ mở cửa, nhất là cuối tuần và ngày lễ.',
 N'Trang phục lịch sự: không mặc quần đùi, váy ngắn, áo hai dây, áo hở lưng|Gửi balo, máy ảnh ở nơi gửi đồ; không quay phim, chụp ảnh trong phòng thi hài|Bỏ mũ, không cho tay vào túi quần, giữ im lặng khi vào Lăng|Trẻ em dưới 3 tuổi không vào phòng thi hài'),

(N'Quảng trường Ba Đình',
 N'Quảng trường lớn nhất Hà Nội, nơi diễn ra nhiều sự kiện chính trị quan trọng của đất nước, nằm trước Lăng Chủ tịch Hồ Chí Minh.',
 N'Ngày 2/9/1945, tại đây Chủ tịch Hồ Chí Minh đọc bản Tuyên ngôn Độc lập khai sinh nước Việt Nam Dân chủ Cộng hòa. Quảng trường gồm 168 ô cỏ xanh, là nơi tổ chức lễ duyệt binh, mít tinh trong các dịp kỷ niệm lớn.',
 N'Lễ thượng cờ buổi sáng và hạ cờ lúc 21:00|Thảm cỏ rộng với 168 ô cỏ|Tầm nhìn ra Lăng Bác, Phủ Chủ tịch, Nhà Quốc hội|Không khí trang nghiêm, thoáng đãng buổi tối',
 N'Ba Đình, Hà Nội', 21.036700, 105.835000, N'Quảng trường',
 N'Khu vực công cộng. Lễ thượng cờ: 6:00 (tháng 4 – 10) hoặc 6:30 (tháng 11 – 3). Lễ hạ cờ: 21:00 hằng ngày.',
 N'Miễn phí.', 82,
 N'Cả ngày · Thượng cờ 6:00 / 6:30', N'Miễn phí', N'30 – 60 phút',
 N'Sáng sớm để xem lễ thượng cờ, hoặc 21:00 xem lễ hạ cờ.',
 N'Đến trước 20 – 30 phút để có chỗ xem lễ chào cờ|Đứng nghiêm, bỏ mũ trong lúc làm lễ; không đi vào khu vực có biển cấm|Không ngồi, nằm trên thảm cỏ'),

(N'Chùa Một Cột',
 N'Ngôi chùa độc đáo hình đóa sen mọc lên từ mặt nước, đặt trên một cột đá giữa hồ vuông nhỏ, nằm trong khu di tích Ba Đình.',
 N'Chùa được xây năm 1049 dưới thời vua Lý Thái Tông, tên chữ là Diên Hựu. Theo sử chép, vua mộng thấy Phật Bà Quan Âm ngồi trên tòa sen dắt vua lên đài, sau đó cho dựng chùa theo hình ảnh ấy. Năm 1954, quân Pháp phá hủy chùa trước khi rút khỏi Hà Nội; chùa được dựng lại năm 1955 theo kiến trúc cũ.',
 N'Đài sen gỗ trên cột trụ giữa hồ vuông|Tượng Quán Thế Âm Bồ Tát thờ trong điện|Cầu thang đá dẫn lên chùa|Hồ sen bao quanh|Ngay cạnh Lăng Bác và Bảo tàng Hồ Chí Minh',
 N'Chùa Một Cột, Ba Đình, Hà Nội', 21.035800, 105.833800, N'Tôn giáo',
 N'Khoảng 7:00 – 18:00 hằng ngày (mùa đông đóng sớm hơn, khoảng 17:30). Có thể tạm đóng khi có sự kiện tại khu Lăng.',
 N'Miễn phí.', 85,
 N'Khoảng 7:00 – 18:00', N'Miễn phí', N'15 – 30 phút',
 N'7:00 – 8:00 hoặc sau 16:00 để tránh đoàn khách; ánh sáng buổi sáng chụp đẹp nhất.',
 N'Trang phục kín đáo, bỏ mũ khi lên điện thờ|Đông khách vào ngày rằm, mùng một âm lịch|Kết hợp với tham quan Lăng Bác, Phủ Chủ tịch trong cùng buổi sáng'),

(N'Văn Miếu - Quốc Tử Giám',
 N'Quần thể di tích thờ Khổng Tử và các bậc hiền triết, đồng thời là trường đại học đầu tiên của Việt Nam – biểu tượng của truyền thống hiếu học.',
 N'Văn Miếu được xây năm 1070 dưới thời vua Lý Thánh Tông; năm 1076 vua Lý Nhân Tông lập Quốc Tử Giám để dạy con em hoàng tộc, sau mở rộng cho người học giỏi trong cả nước. 82 tấm bia tiến sĩ khắc tên những người đỗ đạt từ năm 1442 đến 1779 đã được UNESCO ghi danh là Di sản tư liệu thế giới. Khuê Văn Các được dựng năm 1805, nay là biểu tượng của Hà Nội.',
 N'Khuê Văn Các – biểu tượng của thủ đô|82 bia tiến sĩ đặt trên lưng rùa đá|Giếng Thiên Quang|Điện Đại Thành thờ Khổng Tử|Khu Thái Học – nơi tưởng niệm các vị vua có công với giáo dục',
 N'58 Quốc Tử Giám, Đống Đa, Hà Nội', 21.027039, 105.835650, N'Di tích',
 N'Mùa hè: 7:30 – 17:30. Mùa đông: 8:00 – 17:00. Mở cửa hằng ngày, kể cả lễ, Tết.',
 N'Người lớn: 30.000đ. Học sinh, sinh viên Việt Nam, người từ 60 tuổi: 15.000đ. Trẻ em dưới 15 tuổi: miễn phí. Vé chỉ dùng trong ngày.', 94,
 N'7:30 – 17:30 (đông: 8:00 – 17:00)', N'30.000đ', N'1 – 1,5 giờ',
 N'Sáng sớm các ngày thường; mùa thi (tháng 5 – 6) và đầu năm rất đông sĩ tử đến cầu may.',
 N'Không xoa đầu rùa, không chạm vào bia đá|Mang thẻ học sinh, sinh viên để được giảm giá|Nhiều bạn trẻ chụp ảnh kỷ yếu, áo dài tại đây – nên đến sớm để có ảnh đẹp'),

(N'Bảo tàng Mỹ thuật Việt Nam',
 N'Bảo tàng lưu giữ hàng nghìn tác phẩm tiêu biểu của mỹ thuật Việt Nam từ thời tiền sử đến hiện đại: điêu khắc, tranh sơn mài, tranh lụa, gốm và tranh dân gian.',
 N'Tòa nhà được xây năm 1937 thời Pháp thuộc, vốn là ký túc xá dành cho nữ sinh, mang phong cách kiến trúc Đông Dương với mái ngói nhiều tầng. Bảo tàng Mỹ thuật Việt Nam được thành lập ngày 24/6/1966, hiện lưu giữ hơn 20.000 hiện vật. Trong bộ sưu tập có tượng Phật Bà Quan Âm nghìn mắt nghìn tay (1656) và nhiều tác phẩm của các danh họa như Tô Ngọc Vân, Nguyễn Gia Trí, Bùi Xuân Phái.',
 N'Tượng Phật Bà Quan Âm nghìn mắt nghìn tay (1656)|Tranh sơn mài, tranh lụa của các danh họa|Điêu khắc Chăm và tượng gỗ đình làng|Tranh dân gian Đông Hồ, Hàng Trống|Không gian sáng tạo cho trẻ em ở tầng 3',
 N'66 Nguyễn Thái Học, Ba Đình, Hà Nội', 21.029500, 105.833500, N'Bảo tàng',
 N'8:30 – 17:00 hằng ngày.',
 N'Người lớn: 40.000đ. Sinh viên: 20.000đ. Học sinh 6 – 16 tuổi: 10.000đ. Trẻ em dưới 6 tuổi: miễn phí. Thuyết minh tự động: 50.000đ (sinh viên 30.000đ), có nhiều ngôn ngữ.', 72,
 N'8:30 – 17:00', N'40.000đ', N'1,5 – 2 giờ',
 N'Buổi sáng các ngày trong tuần, yên tĩnh để xem tranh.',
 N'Thuê thuyết minh tự động để hiểu câu chuyện từng tác phẩm|Không chạm vào hiện vật; xem quy định chụp ảnh ở từng phòng|Ngay đối diện cổng sau Văn Miếu – có thể đi bộ kết hợp'),

(N'Bảo tàng Lịch sử Quốc gia',
 N'Bảo tàng lưu giữ hiện vật quý về lịch sử Việt Nam từ thời tiền sử, văn hóa Đông Sơn đến triều Nguyễn, đặt trong tòa nhà kiến trúc Đông Dương nổi tiếng.',
 N'Tòa nhà do kiến trúc sư Ernest Hébrard thiết kế, xây dựng từ năm 1926 đến 1932 cho Viện Viễn Đông Bác cổ (Bảo tàng Louis Finot), kết hợp kiến trúc Pháp với mái và chi tiết phương Đông. Bảo tàng Lịch sử Quốc gia hiện nay được hợp nhất năm 2011 từ Bảo tàng Lịch sử Việt Nam và Bảo tàng Cách mạng Việt Nam.',
 N'Trống đồng Đông Sơn và bộ sưu tập đồ đồng|Hiện vật thời Lý, Trần, Lê và triều Nguyễn|Cọc gỗ trận Bạch Đằng|Mô hình thuyền chiến Đại Việt|Kiến trúc Đông Dương độc đáo của tòa nhà',
 N'1 Tràng Tiền, Hoàn Kiếm, Hà Nội', 21.025300, 105.858000, N'Bảo tàng',
 N'Sáng 8:00 – 12:00, chiều 13:30 – 17:00. Nghỉ thứ Hai đầu tiên của mỗi tháng (nếu trùng ngày lễ vẫn mở cửa).',
 N'Người lớn: 40.000đ. Sinh viên: 20.000đ. Học sinh: 10.000đ. Trẻ em dưới 6 tuổi, người khuyết tật: miễn phí.', 75,
 N'8:00 – 12:00, 13:30 – 17:00', N'40.000đ', N'1,5 – 2 giờ',
 N'Buổi sáng, tránh giờ nghỉ trưa 12:00 – 13:30.',
 N'Bảo tàng có 2 điểm: số 1 Tràng Tiền và 216 Trần Quang Khải (lịch sử cách mạng)|Ngay sau Nhà hát Lớn – có thể kết hợp tham quan|Kiểm tra thông báo nghỉ thứ Hai đầu tháng trước khi đi'),

(N'Bảo tàng Dân tộc học Việt Nam',
 N'Bảo tàng giới thiệu văn hóa của 54 dân tộc Việt Nam và các nước Đông Nam Á, nổi tiếng với khu vườn trưng bày nhà truyền thống nguyên mẫu ngoài trời.',
 N'Bảo tàng khánh thành năm 1997, thuộc Viện Hàn lâm Khoa học Xã hội Việt Nam. Tòa nhà Trống Đồng do kiến trúc sư Hà Đức Lịnh (dân tộc Tày) thiết kế; khu vườn kiến trúc có các ngôi nhà được tháo dỡ và dựng lại nguyên bản bởi chính người dân các dân tộc.',
 N'Tòa nhà Trống Đồng: văn hóa 54 dân tộc Việt Nam|Tòa nhà Cánh Diều: văn hóa Đông Nam Á|Nhà rông Ba Na, nhà dài Ê Đê, nhà sàn Tày, nhà H''Mông ngoài trời|Nhà mồ Gia Rai, Cơ Tu với tượng gỗ độc đáo|Múa rối nước tại thủy đình trong khuôn viên',
 N'Nguyễn Văn Huyên, Cầu Giấy, Hà Nội', 21.040700, 105.798300, N'Bảo tàng',
 N'8:30 – 17:30, thứ Ba đến Chủ nhật. Nghỉ thứ Hai và một số ngày Tết.',
 N'Người lớn: 40.000đ. Sinh viên: 20.000đ. Trẻ em dưới 15 tuổi: miễn phí. Máy ảnh chuyên nghiệp: 50.000đ. Múa rối nước bán vé riêng.', 80,
 N'8:30 – 17:30 (nghỉ thứ Hai)', N'40.000đ', N'2 – 3 giờ',
 N'8:30 – 10:00 hoặc sau 14:30 để tránh nắng gắt ở khu vườn ngoài trời.',
 N'Xem khu trong nhà trước, khu vườn sau; được vào bên trong các nhà truyền thống|Mang nước, mũ vì khu vườn ít bóng râm|Bảo tàng ở Cầu Giấy, cách Hồ Gươm khoảng 7 – 8 km – nên đi xe buýt hoặc taxi'),

(N'Hồ Tây',
 N'Hồ nước tự nhiên lớn nhất nội thành Hà Nội, rộng khoảng 500 ha với chu vi khoảng 17 km, nổi tiếng với cảnh hoàng hôn và nhiều di tích quanh hồ.',
 N'Hồ Tây từng có các tên Đầm Xác Cáo, hồ Kim Ngưu, Lãng Bạc, Dâm Đàm; năm 1573 hồ được đổi tên thành Tây Hồ để kiêng húy vua Lê Thế Tông. Quanh hồ có nhiều di tích nổi tiếng như chùa Trấn Quốc, Phủ Tây Hồ, đền Quán Thánh. Ven hồ là các làng cổ như Nghi Tàm, Quảng An, Nhật Tân với nghề trồng hoa, trồng đào.',
 N'Ngắm hoàng hôn trên đường Thanh Niên|Chùa Trấn Quốc, Phủ Tây Hồ ven hồ|Đạp xe vòng quanh hồ|Ẩm thực: bánh tôm Hồ Tây, ốc nóng|Cà phê ven hồ và phố Trịnh Công Sơn',
 N'Tây Hồ, Hà Nội', 21.055300, 105.818900, N'Danh thắng',
 N'Khu vực công cộng, mở cửa cả ngày.',
 N'Miễn phí.', 90,
 N'Cả ngày', N'Miễn phí', N'2 – 3 giờ',
 N'Chiều muộn (16:30 – 18:30) để ngắm hoàng hôn; sáng sớm mùa thu rất mát.',
 N'Có thể thuê xe đạp TNGo tại các trạm quanh hồ để đạp vòng hồ|Đường Thanh Niên rất đông vào giờ tan tầm|Kết hợp tham quan chùa Trấn Quốc trước 18:00'),

(N'Chùa Trấn Quốc',
 N'Ngôi chùa cổ nhất Hà Nội, nằm trên bán đảo nhỏ phía đông Hồ Tây, nổi bật với bảo tháp nhiều tầng soi bóng mặt hồ.',
 N'Chùa được dựng từ thế kỷ VI thời Lý Nam Đế với tên Khai Quốc, ban đầu ở bãi sông Hồng. Năm 1615, do bờ sông bị lở, chùa được dời vào đảo Kim Ngư trên Hồ Tây; tấm bia năm 1815 ghi lại lịch sử chùa. Bảo tháp 11 tầng được xây năm 1998; cây bồ đề trong chùa là cây chiết từ cây bồ đề nơi Đức Phật thành đạo, do Tổng thống Ấn Độ Rajendra Prasad tặng năm 1959.',
 N'Bảo tháp 11 tầng, mỗi tầng có tượng Phật bằng đá quý|Cây bồ đề do Tổng thống Ấn Độ tặng năm 1959|Tượng Phật Thích Ca nhập Niết Bàn|Bia đá ghi lịch sử chùa (1815)|Khung cảnh chùa soi bóng Hồ Tây',
 N'Thanh Niên, Tây Hồ, Hà Nội', 21.048000, 105.836000, N'Tôn giáo',
 N'7:30 – 11:30 và 13:30 – 18:00 hằng ngày. Ngày rằm, mùng một mở từ 7:00. Giờ có thể thay đổi dịp Tết.',
 N'Miễn phí (không có quầy vé).', 87,
 N'7:30 – 11:30, 13:30 – 18:00', N'Miễn phí', N'30 – 60 phút',
 N'7:30 – 9:00 yên tĩnh, ánh sáng đẹp; hoặc chiều 16:00 – 17:30 ngắm hoàng hôn.',
 N'Trang phục che vai và đầu gối – cổng chùa có kiểm tra|Chùa đóng cửa buổi trưa (11:30 – 13:30)|Rằm, mùng một rất đông người đi lễ'),

(N'Phố Tạ Hiện',
 N'Con phố nhỏ trong phố cổ được mệnh danh là "phố Tây", sôi động về đêm với hàng quán bia, đồ nướng và khách du lịch từ khắp nơi.',
 N'Thời Pháp thuộc, các đoạn phố cũ được gộp lại và mang tên Rue Géraud. Từ năm 1945, phố được đổi tên theo Tạ Hiện (1841 – 1887), một tướng lĩnh của phong trào Cần Vương chống Pháp. Người dân còn quen gọi là ngõ Quảng Lạc, theo tên rạp hát Quảng Lạc giữa phố. Ngày nay ngã tư Tạ Hiện – Lương Ngọc Quyến là điểm hẹn "bia hơi" nổi tiếng, được gọi là "ngã tư quốc tế"; từ năm 2014 phố nằm trong khu phố đi bộ cuối tuần.',
 N'Ngã tư Tạ Hiện – Lương Ngọc Quyến náo nhiệt về đêm|Bia hơi, đồ nướng, ăn vặt đường phố|Không khí giao lưu với du khách quốc tế|Nằm trong khu phố đi bộ cuối tuần',
 N'Tạ Hiện, Hoàn Kiếm, Hà Nội', 21.034900, 105.851000, N'Khu phố',
 N'Sôi động nhất từ khoảng 18:00 đến khuya, đặc biệt tối thứ Sáu – Chủ nhật.',
 N'Đi dạo miễn phí; chi phí ăn uống tùy quán.', 78,
 N'Từ 18:00 đến khuya', N'Miễn phí', N'1 – 2 giờ',
 N'Tối cuối tuần khi phố đi bộ hoạt động.',
 N'Hỏi giá trước khi gọi món, nhất là ở các quán đông khách du lịch|Giữ ví, điện thoại cẩn thận nơi đông người|Ban ngày phố khá yên tĩnh, ít quán mở'),

(N'Phố sách Hà Nội',
 N'Tuyến phố dành riêng cho sách trên phố 19 Tháng 12, với các ki-ốt của nhiều nhà xuất bản, quán cà phê sách và không gian đọc dưới tán cây.',
 N'Phố sách Hà Nội đi vào hoạt động năm 2017 trên tuyến phố 19 Tháng 12 (cạnh Tòa án nhân dân thành phố), là một trong những không gian văn hóa đọc tiêu biểu của thủ đô. Nơi đây thường tổ chức giới thiệu sách, giao lưu tác giả, triển lãm và ngày hội đọc sách.',
 N'Ki-ốt của nhiều nhà xuất bản: Kim Đồng, Nhã Nam, Trẻ…|Cà phê sách và chỗ ngồi đọc dưới hàng cây|Giao lưu tác giả, ra mắt sách cuối tuần|Ngày hội khuyến đọc, Hội sách theo mùa',
 N'Phố 19 Tháng 12, Hoàn Kiếm, Hà Nội', 21.027500, 105.849000, N'Văn hóa',
 N'8:00 – 22:00 hằng ngày.',
 N'Miễn phí vào cửa.', 65,
 N'8:00 – 22:00', N'Miễn phí', N'1 – 2 giờ',
 N'Ngày thường để đọc sách yên tĩnh; cuối tuần có nhiều sự kiện.',
 N'Nhiều nhà sách có giảm giá so với giá bìa|Đi xe buýt tới trạm gần phố Lý Thường Kiệt hoặc Hai Bà Trưng|Gần Phố sách có trạm xe đạp công cộng TNGo'),

(N'Cầu Long Biên',
 N'Cây cầu thép hơn trăm tuổi bắc qua sông Hồng, chứng nhân lịch sử của Hà Nội và là điểm ngắm sông Hồng, chụp ảnh nổi tiếng.',
 N'Cầu được khởi công năm 1898, khánh thành năm 1902 với tên ban đầu là cầu Doumer (theo tên Toàn quyền Đông Dương Paul Doumer), do công ty Daydé & Pillé của Pháp thi công. Phần cầu qua sông dài khoảng 2,3 km. Trong chiến tranh chống Mỹ, cầu bị ném bom nhiều lần và được sửa chữa để giữ mạch giao thông; nhiều nhịp cầu vẫn mang dấu vết bom đạn.',
 N'Kết cấu dầm thép cổ hơn 120 năm tuổi|Tàu hỏa chạy giữa, xe máy và người đi bộ hai bên|Ngắm bình minh, hoàng hôn trên sông Hồng|Bãi giữa sông Hồng với vườn ngô, vườn chuối|Chợ Long Biên sầm uất dưới chân cầu',
 N'Long Biên, Hà Nội', 21.043700, 105.850200, N'Kiến trúc',
 N'Mở cửa cả ngày.',
 N'Miễn phí.', 83,
 N'Cả ngày', N'Miễn phí', N'45 – 90 phút',
 N'Bình minh hoặc hoàng hôn; mùa thu trời trong, ánh sáng đẹp.',
 N'Trên cầu xe cộ đi bên trái – người đi bộ đi trên lối đi riêng hai bên|Không đứng trên đường ray khi tàu chạy|Có thể xuống bãi giữa sông Hồng từ chân cầu phía Long Biên'),

(N'Nhà hát Múa rối Thăng Long',
 N'Nhà hát chuyên biểu diễn múa rối nước – loại hình nghệ thuật dân gian độc đáo của đồng bằng Bắc Bộ, ngay bên hồ Hoàn Kiếm.',
 N'Nhà hát Múa rối Thăng Long được thành lập năm 1969, đã biểu diễn và lưu diễn ở hàng chục quốc gia. Múa rối nước ra đời từ nền văn minh lúa nước, các nghệ nhân đứng sau mành tre, dưới nước điều khiển con rối bằng sào và dây, kèm dàn nhạc dân tộc và hát chèo.',
 N'Chú Tễu dẫn chuyện hài hước mở màn|Múa rồng, múa phượng, múa lân trên mặt nước|Cảnh cày cấy, chăn trâu, bắt vịt đời thường|Tích Lê Lợi trả gươm cho Rùa Vàng|Dàn nhạc dân tộc và hát chèo biểu diễn trực tiếp',
 N'57B Đinh Tiên Hoàng, Hoàn Kiếm, Hà Nội', 21.031700, 105.852700, N'Nghệ thuật',
 N'Thứ Hai – thứ Bảy: suất 16:10, 17:20, 18:30, 20:00. Chủ nhật thêm suất 9:30, 11:00, 14:00. Mỗi suất khoảng 50 phút. Lịch có thể thay đổi dịp lễ, Tết.',
 N'Ghế thường: 100.000đ. Ghế hạng nhất: 150.000đ. Ghế VIP (hàng đầu): 200.000đ. Phí chụp ảnh 20.000đ, quay phim 50.000đ.', 86,
 N'Suất 16:10, 17:20, 18:30, 20:00', N'100.000đ', N'~50 phút',
 N'Suất chiều 16:10 hoặc 17:20 dễ mua vé; suất tối nên đặt trước.',
 N'Mùa cao điểm (tháng 11 – 3) nên đặt vé trước 3 – 7 ngày|Đến sớm 20 – 30 phút; cửa đóng khi bắt đầu diễn|Hàng ghế đầu có thể bị nước bắn vào|Không dùng đèn flash trong lúc biểu diễn');
GO

/* Anh dai dien diem tham quan: anh tu Wikimedia Commons (giay phep tu do CC0 / CC BY / CC BY-SA / Public domain),
   luu tai frontend/public/images/attractions/ ; ImageCredit + ImageSourceUrl de ghi nguon theo yeu cau giay phep */
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/01-ho-hoan-kiem.jpg', ImageCredit = N'Ảnh: Chuhai07 / CC0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Hoan_Kiem_10082026.jpg' WHERE Name = N'Hồ Hoàn Kiếm';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/02-den-ngoc-son.jpg', ImageCredit = N'Ảnh: Bùi Thụy Đào Nguyên / CC BY-SA 3.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:C%E1%BB%95ng_%C4%91%E1%BB%81n_Ng%E1%BB%8Dc_S%C6%A1n.jpg' WHERE Name = N'Đền Ngọc Sơn';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/03-pho-co-ha-noi.jpg', ImageCredit = N'Ảnh: Sgnpkd / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Hanoi_shophouse_2.jpg' WHERE Name = N'Phố cổ Hà Nội';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/04-cho-dong-xuan.jpg', ImageCredit = N'Ảnh: NKSTTSSHNVN / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Ch%E1%BB%A3_%C4%90%E1%BB%93ng_Xu%C3%A2n_-_NKS.jpg' WHERE Name = N'Chợ Đồng Xuân';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/05-nha-hat-lon.jpg', ImageCredit = N'Ảnh: Dennis G. Jarvis / CC BY-SA 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Hanoi_Opera_House_1.jpg' WHERE Name = N'Nhà hát Lớn Hà Nội';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/06-nha-tu-hoa-lo.jpg', ImageCredit = N'Ảnh: thalling55 / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Ho%E1%BA%A3_L%C3%B2.jpg' WHERE Name = N'Nhà tù Hỏa Lò';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/07-hoang-thanh-thang-long.jpg', ImageCredit = N'Ảnh: Christophe95 / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Doan_Mon_Gate_1.jpg' WHERE Name = N'Hoàng thành Thăng Long';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/08-lang-chu-tich-ho-chi-minh.jpg', ImageCredit = N'Ảnh: NKSTTSSHNVN / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:L%C4%83ng_B%C3%A1c_-_NKS.jpg' WHERE Name = N'Lăng Chủ tịch Hồ Chí Minh';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/09-quang-truong-ba-dinh.jpg', ImageCredit = N'Ảnh: Vyacheslav Argenberg / CC BY 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Hanoi,_Vietnam,_Ba_Dinh_Square.jpg' WHERE Name = N'Quảng trường Ba Đình';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/10-chua-mot-cot.jpg', ImageCredit = N'Ảnh: Staffan Scherz / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:One_Pillar_Pagoda_Hanoi.jpg' WHERE Name = N'Chùa Một Cột';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/11-van-mieu-quoc-tu-giam.jpg', ImageCredit = N'Ảnh: Sai Gon Dep Lam / CC BY 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Khue_Van_Cac_2024.jpg' WHERE Name = N'Văn Miếu - Quốc Tử Giám';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/12-bao-tang-my-thuat.jpg', ImageCredit = N'Ảnh: Daaé / Public domain / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Vietnam_National_Museum_of_Fine_Arts_01.JPG' WHERE Name = N'Bảo tàng Mỹ thuật Việt Nam';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/13-bao-tang-lich-su-quoc-gia.jpg', ImageCredit = N'Ảnh: Khoitran1957 / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:4G4A7248A_HDR.jpg' WHERE Name = N'Bảo tàng Lịch sử Quốc gia';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/14-bao-tang-dan-toc-hoc.jpg', ImageCredit = N'Ảnh: Rungbachduong / CC BY-SA 3.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Dan_toc_hoc_1.jpg' WHERE Name = N'Bảo tàng Dân tộc học Việt Nam';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/15-ho-tay.jpg', ImageCredit = N'Ảnh: NKSTTSSHNVN / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:H%E1%BB%93_T%C3%A2y_ho%C3%A0ng_h%C3%B4n_-_NKS.jpg' WHERE Name = N'Hồ Tây';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/16-chua-tran-quoc.jpg', ImageCredit = N'Ảnh: Thang Nguyen / CC BY-SA 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Ch%C3%B9a_Tr%E1%BA%A5n_Qu%E1%BB%91c,_H%C3%A0_N%E1%BB%99i.jpg' WHERE Name = N'Chùa Trấn Quốc';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/17-pho-ta-hien.jpg', ImageCredit = N'Ảnh: Christophe95 / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:T%E1%BA%A1_Hi%E1%BB%87n_Street,_Hanoi.jpg' WHERE Name = N'Phố Tạ Hiện';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/18-pho-sach-ha-noi.jpg', ImageCredit = N'Ảnh: Newone / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Newone_-_ph%E1%BB%91_s%C3%A1ch_19_th%C3%A1ng_12.jpg' WHERE Name = N'Phố sách Hà Nội';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/19-cau-long-bien.jpg', ImageCredit = N'Ảnh: Pierre De Hanscutter / CC BY-SA 3.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Long_bien_bridge.jpg' WHERE Name = N'Cầu Long Biên';
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/20-nha-hat-mua-roi-thang-long.jpg', ImageCredit = N'Ảnh: CEphoto, Uwe Aranas / CC BY-SA 3.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Hanoi_Vietnam_Thang-Long-Water-Puppet-Theatre-01.jpg' WHERE Name = N'Nhà hát Múa rối Thăng Long';
GO

/* Bo suu tap anh (3 - 5 anh / dia diem) tu Wikimedia Commons - giay phep tu do,
   file nam tai frontend/public/images/attractions/gallery/ ; Credit = tac gia / giay phep */
INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder) VALUES
(1, '/images/attractions/gallery/01-ho-hoan-kiem-1.jpg', N'Tháp Rùa lung linh về đêm', N'Isabell Schulz / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Hoan_Kiem%2C_Hanoi_%2844478561440%29.jpg', 1),
(1, '/images/attractions/gallery/01-ho-hoan-kiem-2.jpg', N'Mặt hồ xanh giữa lòng phố', N'Bem photography / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Ho_Hoan_Kiem_%2813574475044%29.jpg', 2),
(1, '/images/attractions/gallery/01-ho-hoan-kiem-3.jpg', N'Buổi sớm bên bờ hồ', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Angler_at_Hoan_Kiem_Lake.jpg', 3),
(1, '/images/attractions/gallery/01-ho-hoan-kiem-4.jpg', N'Ánh đèn quanh hồ buổi tối', N'Bem photography / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Ho_Hoan_Kiem_%2812313745773%29.jpg', 4),
(1, '/images/attractions/gallery/01-ho-hoan-kiem-5.jpg', N'Không gian xanh quanh hồ', N'choi kwangmo / CC0', 'https://commons.wikimedia.org/wiki/File:20190923_164624lake_park_in_h%C3%A0_n%E1%BB%99i.jpg', 5),
(2, '/images/attractions/gallery/02-den-ngoc-son-1.jpg', N'Đền Ngọc Sơn soi bóng mặt hồ', N'P. Hughes / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_-_Ngoc_Son_Temple.jpg', 1),
(2, '/images/attractions/gallery/02-den-ngoc-son-2.jpg', N'Cổng vào đền', N'Clay Gilliland / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_Vietnam_%2812042291376%29.jpg', 2),
(2, '/images/attractions/gallery/02-den-ngoc-son-3.jpg', N'Gian thờ chính', N'Mig Gilbert / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Den_Ngoc_Son_shrine_%2838457884970%29.jpg', 3),
(2, '/images/attractions/gallery/02-den-ngoc-son-4.jpg', N'Nội thất đền', N'RThiele / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:019Jadebergtempel_innen.jpg', 4),
(2, '/images/attractions/gallery/02-den-ngoc-son-5.jpg', N'Hương án và hoành phi câu đối', N'Ziegler175 / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:ICHanoiNgocSon1.jpg', 5),
(3, '/images/attractions/gallery/03-pho-co-ha-noi-1.jpg', N'Nhịp sống khu phố cổ', N'yeowatzup / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Old_Quarter%2C_Hanoi%2C_Vietnam_%285246284208%29.jpg', 1),
(3, '/images/attractions/gallery/03-pho-co-ha-noi-2.jpg', N'Một góc phố cổ', N'Gonzo Gooner / CC BY 3.0', 'https://commons.wikimedia.org/wiki/File:Old_Quarter%2C_Hanoi_-_panoramio.jpg', 2),
(3, '/images/attractions/gallery/03-pho-co-ha-noi-3.jpg', N'Phố cổ ngày thường', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Old_Quarter_street_scene%2C_Hanoi_%282%29_%2838496798321%29.jpg', 3),
(3, '/images/attractions/gallery/03-pho-co-ha-noi-4.jpg', N'Dãy nhà ống đặc trưng', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Old_Quarter_street_scene%2C_Hanoi_%283%29_%2838464656402%29.jpg', 4),
(3, '/images/attractions/gallery/03-pho-co-ha-noi-5.jpg', N'Phố cổ Hà Nội', N'yeowatzup / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Old_Quarter%2C_Hanoi%2C_Vietnam_%285246306092%29.jpg', 5),
(4, '/images/attractions/gallery/04-cho-dong-xuan-1.jpg', N'Mặt tiền chợ Đồng Xuân', N'shankar s. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Dong_Xuan_Market_market_in_the_Hanoi_old_quarter_%2830645886763%29.jpg', 1),
(4, '/images/attractions/gallery/04-cho-dong-xuan-2.jpg', N'Chợ đêm khu Đồng Xuân', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_Night_Market_3.jpg', 2),
(4, '/images/attractions/gallery/04-cho-dong-xuan-3.jpg', N'Bên trong chợ', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:%C4%90%E1%BB%93ng_Xu%C3%A2n_Market_6.jpg', 3),
(4, '/images/attractions/gallery/04-cho-dong-xuan-4.jpg', N'Gian hàng trong chợ', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:%C4%90%E1%BB%93ng_Xu%C3%A2n_Market_2.jpg', 4),
(4, '/images/attractions/gallery/04-cho-dong-xuan-5.jpg', N'Khu bán vải, quần áo', N'Sandra Cohen-Rose and Colin Rose / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Dong_Xuan_Market_%2823144327176%29.jpg', 5),
(5, '/images/attractions/gallery/05-nha-hat-lon-1.jpg', N'Mặt tiền Nhà hát Lớn', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_Opera_House%2C_1901-11_%283%29_%2837779750014%29.jpg', 1),
(5, '/images/attractions/gallery/05-nha-hat-lon-2.jpg', N'Nhà hát Lớn lên đèn', N'Bem photography / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Nha_hat_lon_%2812358211094%29.jpg', 2),
(5, '/images/attractions/gallery/05-nha-hat-lon-3.jpg', N'Kiến trúc Pháp tân cổ điển', N'Edgardo W. Olivera / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Opera_House%2C_Hanoi%2C_Vietnam_%2836761966601%29.jpg', 3),
(5, '/images/attractions/gallery/05-nha-hat-lon-4.jpg', N'Nhà hát nhìn từ quảng trường', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_Opera_House_2018.jpg', 4),
(5, '/images/attractions/gallery/05-nha-hat-lon-5.jpg', N'Nhà hát Lớn Hà Nội', N'The Hanoian / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Nh%C3%A0_h%C3%A1t_L%E1%BB%9Bn_H%C3%A0_N%E1%BB%99i_-_2022-09-02_03.jpg', 5),
(6, '/images/attractions/gallery/06-nha-tu-hoa-lo-1.jpg', N'Khu tái hiện buồng giam tù chính trị', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:Communist_Prisoners_of_the_French%2C_Hoa_Lo_Prison_%289754076916%29.jpg', 1),
(6, '/images/attractions/gallery/06-nha-tu-hoa-lo-2.jpg', N'Giường của phi công Mỹ bị giam giữ', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:Bunk_Bed_for_American_Prisoners%2C_Hoa_Lo_Prison_%289754110835%29.jpg', 2),
(6, '/images/attractions/gallery/06-nha-tu-hoa-lo-3.jpg', N'Ảnh tư liệu: tù binh Mỹ rời Hỏa Lò năm 1973', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:American_Prisoners_Leaving_Hoa_Lo_Prison%2C_1973_%289754154193%29.jpg', 3),
(7, '/images/attractions/gallery/07-hoang-thanh-thang-long-1.jpg', N'Khu trung tâm Hoàng thành', N'katiebordner / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Central_Sector_of_the_Imperial_Citadel_of_Thang_Long_-_Hanoi_%2826246667851%29.jpg', 1),
(7, '/images/attractions/gallery/07-hoang-thanh-thang-long-2.jpg', N'Đoan Môn nhìn từ bên trong', N'katiebordner / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Central_Sector_of_the_Imperial_Citadel_of_Thang_Long_-_Hanoi.jpg', 2),
(7, '/images/attractions/gallery/07-hoang-thanh-thang-long-3.jpg', N'Kiến trúc trong Hoàng thành', N'Guerinf / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Citadelle_de_Hano%C3%AF_%281%29.jpg', 3),
(7, '/images/attractions/gallery/07-hoang-thanh-thang-long-4.jpg', N'Cổng thành', N'Guerinf / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Citadelle_de_Hano%C3%AF_%284%29.jpg', 4),
(7, '/images/attractions/gallery/07-hoang-thanh-thang-long-5.jpg', N'Cửa trái Đoan Môn', N'Phan Minh Tuấn / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:C%E1%BB%95ng_tr%C3%A1i_%C4%90oan_M%C3%B4n%2C_Ho%C3%A0ng_th%C3%A0nh_Th%C4%83ng_Long%2C_H%C3%A0_N%E1%BB%99i_001.JPG', 5),
(8, '/images/attractions/gallery/08-lang-chu-tich-ho-chi-minh-1.jpg', N'Lăng Chủ tịch Hồ Chí Minh', N'shankar s. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:HCM_Mausoleum-_closed_as_his_preserved_body_wan%27t_it_%2831454165115%29.jpg', 1),
(8, '/images/attractions/gallery/08-lang-chu-tich-ho-chi-minh-2.jpg', N'Đội tiêu binh trước Lăng', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Guards_of_the_Ho_Chi_Minh_Mausoleum.jpg', 2),
(8, '/images/attractions/gallery/08-lang-chu-tich-ho-chi-minh-3.jpg', N'Khu vực Lăng và quảng trường', N'rhjpage / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_day_2_%2842633365842%29.jpg', 3),
(8, '/images/attractions/gallery/08-lang-chu-tich-ho-chi-minh-4.jpg', N'Hàng cờ trước Lăng', N'flowcomm / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_Vietnam_%2849538245913%29.jpg', 4),
(8, '/images/attractions/gallery/08-lang-chu-tich-ho-chi-minh-5.jpg', N'Vườn cây quanh Lăng', N'Esin Üstün / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Gardeners_in_the_Ho_Chi_Minh_Mausoleum_-_Vietnam_%2815860257192%29.jpg', 5),
(9, '/images/attractions/gallery/09-quang-truong-ba-dinh-1.jpg', N'Quảng trường Ba Đình', N'Vyacheslav Argenberg / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_Vietnam%2C_Ho_Chi_Minh_Mausoleum_on_Ba_Dinh_Square.jpg', 1),
(9, '/images/attractions/gallery/09-quang-truong-ba-dinh-2.jpg', N'Quảng trường về đêm', N'Nguyễn Thanh Quang / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Qu%E1%BA%A3ng_tr%C6%B0%E1%BB%9Dng_Ba_%C4%90%C3%ACnh_v%E1%BB%81_%C4%91%C3%AAm.JPG', 2),
(9, '/images/attractions/gallery/09-quang-truong-ba-dinh-3.jpg', N'Quảng trường và Lăng Bác', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Ba_Dinh_Square%2C_Hanoi_%2837609038445%29.jpg', 3),
(9, '/images/attractions/gallery/09-quang-truong-ba-dinh-4.jpg', N'Thảm cỏ quảng trường', N'Cvbr / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Mausoleo_de_Ho_Chi_Minh.JPG', 4),
(10, '/images/attractions/gallery/10-chua-mot-cot-1.jpg', N'Chùa Một Cột', N'dronepicr / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Eins%C3%A4ulenpagode_Ngoc_Son_Hanoi_%2839513844382%29.jpg', 1),
(10, '/images/attractions/gallery/10-chua-mot-cot-2.jpg', N'Chùa nhìn từ hồ sen', N'lumoplank / CC0', 'https://commons.wikimedia.org/wiki/File:Hanoi_-_Hanoi1638.jpg', 2),
(10, '/images/attractions/gallery/10-chua-mot-cot-3.jpg', N'Ban thờ Quán Thế Âm', N'Chitra sivakumar / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Ch%C3%B9a_M%E1%BB%99t_C%E1%BB%99t_5.JPG', 3),
(10, '/images/attractions/gallery/10-chua-mot-cot-4.jpg', N'Hồ sen quanh chùa', N'Chitra sivakumar / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Ch%C3%B9a_M%E1%BB%99t_C%E1%BB%99t_4.JPG', 4),
(10, '/images/attractions/gallery/10-chua-mot-cot-5.jpg', N'Khuôn viên chùa', N'Clay Gilliland / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_Vietnam_%2812041825854%29.jpg', 5),
(11, '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-1.jpg', N'Cổng Văn Miếu', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:20220605_Temple_of_Literature%2C_Hanoi_14.jpg', 1),
(11, '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-2.jpg', N'Gác trong khuôn viên Văn Miếu', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:20220605_Temple_of_Literature%2C_Hanoi_16.jpg', 2),
(11, '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-3.jpg', N'Giếng Thiên Quang', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:20220605_Temple_of_Literature%2C_Hanoi_04.jpg', 3),
(11, '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-4.jpg', N'Nhà bia tiến sĩ', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:20220605_Temple_of_Literature%2C_Hanoi_28.jpg', 4),
(11, '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-5.jpg', N'Lối đi rợp bóng cây', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:20220605_Temple_of_Literature%2C_Hanoi_24.jpg', 5),
(12, '/images/attractions/gallery/12-bao-tang-my-thuat-1.jpg', N'Cánh cửa chạm rồng (1262)', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Doors_carved_with_dragon_motifs%2C_1262%2C_Museum_of_Fine_Arts%2C_Hanoi_%281%29_%2824628505508%29.jpg', 1),
(12, '/images/attractions/gallery/12-bao-tang-my-thuat-2.jpg', N'Tượng bà chúa (1632)', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Statue_of_a_duchess%2C_1632%2C_Museum_of_Fine_Arts%2C_Hanoi_%281%29_%2824628273508%29.jpg', 2),
(12, '/images/attractions/gallery/12-bao-tang-my-thuat-3.jpg', N'Tượng bò thần Nandi, nghệ thuật Chăm (thế kỷ VIII–IX)', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Nandi_bull%2C_8th-9th_cents.%2C_Museum_of_Fine_Arts%2C_Hanoi_%2837785222234%29.jpg', 3),
(12, '/images/attractions/gallery/12-bao-tang-my-thuat-4.jpg', N'Tượng nghê (đầu thế kỷ XVII)', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Mythological_lion%2C_early_17th_century%2C_Museum_of_Fine_Arts%2C_Hanoi_%282%29_%2838468435862%29.jpg', 4),
(12, '/images/attractions/gallery/12-bao-tang-my-thuat-5.jpg', N'Tượng Kinnari đánh trống (1087)', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Kinnari_drumming%2C_1087%2C_Museum_of_Fine_Arts%2C_Hanoi_%2837613891045%29.jpg', 5),
(13, '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-1.jpg', N'Tòa nhà bảo tàng', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:Vietnam_History_Museum_%289753022072%29.jpg', 1),
(13, '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-2.jpg', N'Kiến trúc Đông Dương của bảo tàng', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:Vietnam_History_Museum_%289753023741%29.jpg', 2),
(13, '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-3.jpg', N'Bảo tàng Lịch sử Việt Nam', N'Casablanca1911 / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:B%E1%BA%A3o_t%C3%A0ng_LSVN.jpg', 3),
(13, '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-4.jpg', N'Mô hình thuyền chiến Đại Việt', N'PTDTCH / Public domain', 'https://commons.wikimedia.org/wiki/File:ThuyenchienDaiViet1.JPG', 4),
(13, '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-5.jpg', N'Hiện vật trưng bày', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:Vietnam_History_Museum_%289753230575%29.jpg', 5),
(14, '/images/attractions/gallery/14-bao-tang-dan-toc-hoc-1.jpg', N'Nhà dài Ê Đê', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Ede_longhouse%2C_Museum_of_Ethnology%2C_Hanoi_%2837608576475%29.jpg', 1),
(14, '/images/attractions/gallery/14-bao-tang-dan-toc-hoc-2.jpg', N'Nhà mồ Gia Rai', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Giarai_tomb%2C_Museum_of_Ethnology%2C_Hanoi_%282%29_%2838439476326%29.jpg', 2),
(14, '/images/attractions/gallery/14-bao-tang-dan-toc-hoc-3.jpg', N'Ngôi nhà truyền thống', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Traditional_Hanoi_dwelling%2C_Museum_of_Ethnology%2C_Hanoi_%281%29_%2838497797791%29.jpg', 3),
(14, '/images/attractions/gallery/14-bao-tang-dan-toc-hoc-4.jpg', N'Nhà mồ Cơ Tu', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Cotu_tomb%2C_Museum_of_Ethnology%2C_Hanoi_%282%29_%2838495337181%29.jpg', 4),
(14, '/images/attractions/gallery/14-bao-tang-dan-toc-hoc-5.jpg', N'Nhà truyền thống của người Việt', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Traditional_Hanoi_dwelling%2C_Museum_of_Ethnology%2C_Hanoi_%287%29_%2826722014039%29.jpg', 5),
(15, '/images/attractions/gallery/15-ho-tay-1.jpg', N'Hoàng hôn trên Hồ Tây', N'NKSTTSSHNVN / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Ho%C3%A0ng_h%C3%B4n_h%E1%BB%93_T%C3%A2y_-_NKS.jpg', 1),
(15, '/images/attractions/gallery/15-ho-tay-2.jpg', N'Hoa giấy bên bờ Hồ Tây', N'Alexey Komarov / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_10_March_2019.jpg', 2),
(15, '/images/attractions/gallery/15-ho-tay-3.jpg', N'Hàng cọ ven hồ', N'Alex 69200 vx / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Lac-ouest-hanoi-4.jpg', 3),
(15, '/images/attractions/gallery/15-ho-tay-4.jpg', N'Chùa Trấn Quốc nhìn từ mặt hồ lúc chiều tà', N'NKSTTSSHNVN / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Chi%E1%BB%81u_h%E1%BB%93_T%C3%A2y_-_NKS.jpg', 4),
(15, '/images/attractions/gallery/15-ho-tay-5.jpg', N'Hồ Tây về đêm', N'cloud.shepherd / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Night_in_Hanoi_%2830053395432%29.jpg', 5),
(16, '/images/attractions/gallery/16-chua-tran-quoc-1.jpg', N'Bảo tháp về đêm', N'katiebordner / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_Vietnam_%2826246682151%29.jpg', 1),
(16, '/images/attractions/gallery/16-chua-tran-quoc-2.jpg', N'Chùa soi bóng Hồ Tây', N'Bùi Thụy Đào Nguyên / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Ch%C3%B9a_Tr%E1%BA%A5n_Qu%E1%BB%91c_%28H%C3%A0_N%E1%BB%99i%29.jpg', 2),
(16, '/images/attractions/gallery/16-chua-tran-quoc-3.jpg', N'Cổng tam quan', N'shankar s. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:An_impressive_arch_leads_up_to_the_temple_%2831417104356%29.jpg', 3),
(16, '/images/attractions/gallery/16-chua-tran-quoc-4.jpg', N'Khu tháp mộ các nhà sư', N'shankar s. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Area_with_shrines_for_the_ashes_of_departed_monks_%2831454177605%29.jpg', 4),
(16, '/images/attractions/gallery/16-chua-tran-quoc-5.jpg', N'Cây bồ đề trong chùa', N'Bùi Thụy Đào Nguyên / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:C%C3%A2y_b%E1%BB%93_%C4%91%E1%BB%81_ch%C3%B9a_Tr%E1%BA%A5n_Qu%E1%BB%91c.jpg', 5),
(17, '/images/attractions/gallery/17-pho-ta-hien-1.jpg', N'Phố Tạ Hiện', N'NKSTTSSHNVN / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Ph%E1%BB%91_T%E1%BA%A1_Hi%E1%BB%87n_-_NKS.jpg', 1),
(17, '/images/attractions/gallery/17-pho-ta-hien-2.jpg', N'Phố Tạ Hiện ban ngày', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:T%E1%BA%A1_Hi%E1%BB%87n_Street.jpg', 2),
(17, '/images/attractions/gallery/17-pho-ta-hien-3.jpg', N'Phố Tạ Hiện', N'9636137 (Pixabay) / CC0', 'https://commons.wikimedia.org/wiki/File:Ta-hien-street-3559133.jpg', 3),
(17, '/images/attractions/gallery/17-pho-ta-hien-4.jpg', N'Góc phố Tạ Hiện', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:T%E1%BA%A1_Hi%E1%BB%87n_Street%2C_Hanoi%2C_Vietnam_13.jpg', 4),
(17, '/images/attractions/gallery/17-pho-ta-hien-5.jpg', N'Phố Tạ Hiện lên đèn', N'choi kwangmo / CC0', 'https://commons.wikimedia.org/wiki/File:20190923_170333ph%E1%BB%91_t%E1%BA%A1_hi%E1%BB%87n_h%C3%A0_n%E1%BB%99i.jpg', 5),
(18, '/images/attractions/gallery/18-pho-sach-ha-noi-1.jpg', N'Gian hàng sách', N'Newone / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_06.jpg', 1),
(18, '/images/attractions/gallery/18-pho-sach-ha-noi-2.jpg', N'Không gian phố sách', N'Newone / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_16.jpg', 2),
(18, '/images/attractions/gallery/18-pho-sach-ha-noi-3.jpg', N'Phố sách buổi tối', N'Newone / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_17.jpg', 3),
(18, '/images/attractions/gallery/18-pho-sach-ha-noi-4.jpg', N'Sách bày bán', N'Newone / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_03.jpg', 4),
(18, '/images/attractions/gallery/18-pho-sach-ha-noi-5.jpg', N'Ngày hội khuyến đọc', N'Newone / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_05.jpg', 5),
(19, '/images/attractions/gallery/19-cau-long-bien-1.jpg', N'Cầu Long Biên nhìn từ bãi giữa sông Hồng', N'cloud.shepherd / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Farm_%26_bridge_%2827730838553%29.jpg', 1),
(19, '/images/attractions/gallery/19-cau-long-bien-2.jpg', N'Cầu Long Biên về đêm', N'Miyako Fujimiya / CC0', 'https://commons.wikimedia.org/wiki/File:C%E1%BA%A7u_Long_Bi%C3%AAn_v%C3%A0o_%C4%91%C3%AAm.jpg', 2),
(19, '/images/attractions/gallery/19-cau-long-bien-3.jpg', N'Đường ray trên cầu', N'Minhquangdo / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:C%E1%BA%A7u_Long_Bi%C3%AAn_28-2-2016.JPG', 3),
(19, '/images/attractions/gallery/19-cau-long-bien-4.jpg', N'Kết cấu thép của cầu', N'Velvet / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_pont_long_Bien.jpg', 4),
(19, '/images/attractions/gallery/19-cau-long-bien-5.jpg', N'Sông Hồng dưới chân cầu', N'Minhquangdo / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:28-2-2016_IMG_1667.JPG', 5),
(20, '/images/attractions/gallery/20-nha-hat-mua-roi-thang-long-1.jpg', N'Sân khấu thủy đình', N'Gryffindor / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Thang_Long_Water_Puppet_Theatre1.JPG', 1),
(20, '/images/attractions/gallery/20-nha-hat-mua-roi-thang-long-2.jpg', N'Tiết mục múa rối nước', N'Gryffindor / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Thang_Long_Water_Puppet_Theatre3.JPG', 2),
(20, '/images/attractions/gallery/20-nha-hat-mua-roi-thang-long-3.jpg', N'Dàn nhạc dân tộc phục vụ buổi diễn', N'Ziegler175 / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:ICHanoi21.jpg', 3),
(20, '/images/attractions/gallery/20-nha-hat-mua-roi-thang-long-4.jpg', N'Toàn cảnh sân khấu', N'thalling55 / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Water_Puppet_Theater%2C_Hanoi_%281344448995%29.jpg', 4),
(20, '/images/attractions/gallery/20-nha-hat-mua-roi-thang-long-5.jpg', N'Mặt tiền nhà hát', N'xiquinhosilva / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:04391-Hanoi_%2832139687983%29.jpg', 5);
GO

/* ---- Du kien nhanh + moc lich su (moi dong: nhan | gia tri) ---- */
UPDATE TouristAttractions SET Facts = N'Tên cũ | Hồ Lục Thủy
Diện tích | Khoảng 12 ha
Xếp hạng | Di tích quốc gia đặc biệt (2013, cùng đền Ngọc Sơn)
Biểu tượng | Tháp Rùa (1886)', Timeline = N'Thế kỷ XV | Theo truyền thuyết, vua Lê Lợi trả gươm thần cho Rùa Vàng, hồ mang tên Hoàn Kiếm
1886 | Tháp Rùa được xây trên gò giữa hồ
2013 | Hồ Hoàn Kiếm và đền Ngọc Sơn được xếp hạng Di tích quốc gia đặc biệt
2016 | Các tuyến phố quanh hồ trở thành không gian đi bộ cuối tuần' WHERE Name = N'Hồ Hoàn Kiếm';
UPDATE TouristAttractions SET Facts = N'Thờ | Văn Xương Đế Quân và Đức Thánh Trần Hưng Đạo
Vị trí | Đảo Ngọc, phía bắc hồ Hoàn Kiếm
Lối vào | Cầu Thê Húc sơn đỏ
Xếp hạng | Di tích quốc gia đặc biệt (2013)', Timeline = N'1865 | Nhà nho Nguyễn Văn Siêu tu sửa đền, dựng Tháp Bút, Đài Nghiên và cầu Thê Húc
2013 | Cùng hồ Hoàn Kiếm được xếp hạng Di tích quốc gia đặc biệt
2016 | Cụ Rùa Hồ Gươm mất; tiêu bản sau đó được trưng bày trong đền' WHERE Name = N'Đền Ngọc Sơn';
UPDATE TouristAttractions SET Facts = N'Hình thành | Thời Lý – Trần
Đặc trưng | Phố nghề mang tên "Hàng…", nhà ống mái ngói
Xếp hạng | Di tích quốc gia (2004)
Cửa ô còn lại | Ô Quan Chưởng', Timeline = N'Thời Lý – Trần | Phường thợ và chợ buôn bán hình thành bên ngoài hoàng thành
Cuối thế kỷ XIX | Những ngôi nhà ống như nhà cổ 87 Mã Mây được xây dựng
2004 | Khu phố cổ được xếp hạng Di tích quốc gia' WHERE Name = N'Phố cổ Hà Nội';
UPDATE TouristAttractions SET Facts = N'Xây dựng | 1889, thời Pháp thuộc
Kiến trúc | Mặt tiền năm vòm cổng
Quy mô | Ba tầng, bán buôn và bán lẻ
Diện tích | Khoảng 6.500 m² có mái che', Timeline = N'1889 | Người Pháp xây chợ để tập trung buôn bán trong khu phố cổ
1994 | Hỏa hoạn lớn thiêu rụi phần lớn công trình
1996 | Chợ được xây lại, giữ mặt tiền năm vòm' WHERE Name = N'Chợ Đồng Xuân';
UPDATE TouristAttractions SET Facts = N'Xây dựng | 1901 – 1911
Phong cách | Tân cổ điển, chi tiết Baroque
Lấy cảm hứng | Nhà hát Opera Garnier, Paris
Khán phòng | Khoảng 600 ghế', Timeline = N'1901 | Khởi công xây dựng
1911 | Hoàn thành công trình
8/1945 | Mít tinh lớn trên quảng trường trước nhà hát mở đầu Tổng khởi nghĩa ở Hà Nội' WHERE Name = N'Nhà hát Lớn Hà Nội';
UPDATE TouristAttractions SET Facts = N'Xây dựng | 1896, tên Maison Centrale
Tên gọi khác | "Hanoi Hilton"
Diện tích | Ban đầu hơn 12.000 m², nay còn 2.434 m²
Hiện nay | Phần còn lại được bảo tồn làm di tích', Timeline = N'1896 | Người Pháp xây nhà tù Maison Centrale
1964 – 1973 | Giam giữ phi công Mỹ bị bắn rơi – nơi họ gọi đùa là "Hanoi Hilton"
Thập niên 1990 | Phần lớn khu nhà tù bị phá dỡ; phần còn lại được bảo tồn làm di tích' WHERE Name = N'Nhà tù Hỏa Lò';
UPDATE TouristAttractions SET Facts = N'Khởi đầu | 1010, vua Lý Thái Tổ dời đô
Di sản | Di sản văn hóa thế giới (UNESCO, 2010)
Khảo cổ | Khu 18 Hoàng Diệu
Công trình tiêu biểu | Đoan Môn, điện Kính Thiên, Hậu Lâu', Timeline = N'1010 | Vua Lý Thái Tổ dời đô từ Hoa Lư về Đại La, đặt tên là Thăng Long
1812 | Cột cờ Hà Nội được xây dựng
1967 | Xây Nhà và Hầm D67 – Sở chỉ huy Bộ Quốc phòng
2010 | Khu trung tâm Hoàng thành Thăng Long được UNESCO công nhận Di sản văn hóa thế giới' WHERE Name = N'Hoàng thành Thăng Long';
UPDATE TouristAttractions SET Facts = N'Khởi công | 2/9/1973
Khánh thành | 29/8/1975
Kiến trúc | Đá hoa cương, dáng đài sen
Quần thể | Phủ Chủ tịch, Nhà sàn, Bảo tàng Hồ Chí Minh', Timeline = N'2/9/1969 | Chủ tịch Hồ Chí Minh qua đời
2/9/1973 | Khởi công xây Lăng
29/8/1975 | Khánh thành Lăng' WHERE Name = N'Lăng Chủ tịch Hồ Chí Minh';
UPDATE TouristAttractions SET Facts = N'Sự kiện lịch sử | Tuyên ngôn Độc lập, 2/9/1945
Tên gọi | Theo khởi nghĩa Ba Đình (1886 – 1887) ở Thanh Hóa
Thảm cỏ | 168 ô cỏ
Nghi lễ | Thượng cờ sáng sớm, hạ cờ lúc 21:00', Timeline = N'Đầu thế kỷ XX | Người Pháp làm vườn hoa tròn Rond-point Puginier
1945 | Thị trưởng Trần Văn Lai đổi tên thành vườn hoa Ba Đình, ghi nhớ cuộc khởi nghĩa Ba Đình chống Pháp
2/9/1945 | Chủ tịch Hồ Chí Minh đọc Tuyên ngôn Độc lập khai sinh nước Việt Nam Dân chủ Cộng hòa
1963 | Hội trường Ba Đình bên quảng trường hoàn thành
29/8/1975 | Lăng Chủ tịch Hồ Chí Minh khánh thành bên quảng trường' WHERE Name = N'Quảng trường Ba Đình';
UPDATE TouristAttractions SET Facts = N'Khởi dựng | 1049, thời vua Lý Thái Tông
Tên chữ | Diên Hựu tự
Thờ | Quán Thế Âm Bồ Tát
Kỷ lục | Ngôi chùa có kiến trúc độc đáo nhất châu Á (2012)', Timeline = N'1049 | Vua Lý Thái Tông cho dựng chùa sau giấc mộng thấy Phật Bà Quan Âm
1954 | Quân Pháp phá hủy chùa trước khi rút khỏi Hà Nội
1955 | Chùa được dựng lại theo kiến trúc cũ
2012 | Được xác lập kỷ lục châu Á: ngôi chùa có kiến trúc độc đáo nhất' WHERE Name = N'Chùa Một Cột';
UPDATE TouristAttractions SET Facts = N'Khởi dựng | 1070
Trường đại học đầu tiên | Quốc Tử Giám (1076)
Di sản tư liệu | 82 bia tiến sĩ (UNESCO, 2010)
Xếp hạng | Di tích quốc gia đặc biệt (2012)', Timeline = N'1070 | Xây Văn Miếu thời vua Lý Thánh Tông
1076 | Vua Lý Nhân Tông lập Quốc Tử Giám
1442 – 1779 | Tên những người đỗ tiến sĩ được khắc trên 82 tấm bia đá
1805 | Dựng Khuê Văn Các
2010 | 82 bia tiến sĩ được UNESCO ghi danh Di sản tư liệu thế giới
2012 | Xếp hạng Di tích quốc gia đặc biệt' WHERE Name = N'Văn Miếu - Quốc Tử Giám';
UPDATE TouristAttractions SET Facts = N'Tòa nhà | Xây năm 1937, kiến trúc Đông Dương
Thành lập | 24/6/1966
Bộ sưu tập | Hơn 20.000 hiện vật, 9 bảo vật quốc gia (2021)
Hiện vật tiêu biểu | Tượng Quan Âm nghìn mắt nghìn tay (1656)', Timeline = N'1937 | Xây tòa nhà, vốn là ký túc xá dành cho nữ sinh
24/6/1966 | Bảo tàng Mỹ thuật Việt Nam chính thức được thành lập
2021 | Ra mắt ứng dụng thuyết minh đa phương tiện iMuseum VFA với 8 ngôn ngữ' WHERE Name = N'Bảo tàng Mỹ thuật Việt Nam';
UPDATE TouristAttractions SET Facts = N'Thiết kế | Kiến trúc sư Ernest Hébrard
Xây dựng | 1926 – 1932
Tên cũ | Bảo tàng Louis Finot (từ 1932)
Hình thành | Hợp nhất năm 2011', Timeline = N'1910 | Viện Viễn Đông Bác cổ lập bảo tàng đầu tiên tại Hà Nội
1926 – 1932 | Xây tòa nhà hiện nay; từ năm 1932 bảo tàng mang tên Louis Finot
1958 | Việt Nam tiếp quản, đổi tên thành Bảo tàng Lịch sử Việt Nam và mở cửa ngày 3/9/1958
6/1/1959 | Thành lập Bảo tàng Cách mạng Việt Nam
26/9/2011 | Hợp nhất Bảo tàng Lịch sử Việt Nam và Bảo tàng Cách mạng Việt Nam' WHERE Name = N'Bảo tàng Lịch sử Quốc gia';
UPDATE TouristAttractions SET Facts = N'Khánh thành | 12/11/1997
Thiết kế | KTS Hà Đức Lịnh (dân tộc Tày), tòa nhà hình trống đồng
Trưng bày | 54 dân tộc Việt Nam và văn hóa Đông Nam Á
Khu ngoài trời | Khoảng 2 ha, nhà truyền thống dựng nguyên mẫu', Timeline = N'14/12/1987 | Đề án xây dựng bảo tàng được phê duyệt
1987 – 1995 | Xây tòa nhà Trống Đồng; kiến trúc sư người Pháp Véronique Dollfus thiết kế nội thất
12/11/1997 | Bảo tàng mở cửa đón khách
2013 | Khánh thành tòa nhà Cánh Diều, trưng bày văn hóa Đông Nam Á' WHERE Name = N'Bảo tàng Dân tộc học Việt Nam';
UPDATE TouristAttractions SET Facts = N'Diện tích | Khoảng 500 ha
Chu vi | Khoảng 17 km
Tên cũ | Đầm Xác Cáo, Kim Ngưu, Lãng Bạc, Dâm Đàm
Di tích ven hồ | Chùa Trấn Quốc, Phủ Tây Hồ, đền Quán Thánh', Timeline = N'Thế kỷ XI | Hồ mang tên Dâm Đàm, nghĩa là "đầm mù sương"
1573 | Đổi tên thành Tây Hồ để kiêng húy vua Lê Thế Tông (Lê Duy Đàm)
1615 | Chùa Trấn Quốc được dời ra gò Kim Ngư trên hồ
1957 | Thanh niên Hà Nội mở rộng đường Cổ Ngư ven hồ, sau được Bác Hồ đặt tên là đường Thanh Niên' WHERE Name = N'Hồ Tây';
UPDATE TouristAttractions SET Facts = N'Khởi dựng | Thế kỷ VI, thời Lý Nam Đế
Tên ban đầu | Khai Quốc
Bảo tháp | 11 tầng (1998)
Cây bồ đề | Tổng thống Ấn Độ tặng năm 1959', Timeline = N'Thế kỷ VI | Dựng chùa Khai Quốc bên bãi sông Hồng
1615 | Bờ sông lở, chùa được dời vào đảo Kim Ngư trên Hồ Tây
1815 | Dựng bia đá ghi lại lịch sử chùa
1959 | Tổng thống Ấn Độ Rajendra Prasad tặng cây bồ đề
1998 | Xây bảo tháp 11 tầng' WHERE Name = N'Chùa Trấn Quốc';
UPDATE TouristAttractions SET Facts = N'Thời Pháp | Rue Géraud
Tên phố | Từ 1945, theo tướng Tạ Hiện (1841 – 1887)
Tên dân gian | Ngõ Quảng Lạc, theo rạp hát cũ giữa phố
Nổi tiếng | "Ngã tư quốc tế" Tạ Hiện – Lương Ngọc Quyến', Timeline = N'Thời Pháp thuộc | Các đoạn phố cũ được gộp lại, mang tên Rue Géraud
1945 | Đổi tên thành phố Tạ Hiện, theo tên vị tướng của phong trào Cần Vương
2014 | Trở thành một trong sáu tuyến phố đi bộ mở rộng của khu phố cổ' WHERE Name = N'Phố Tạ Hiện';
UPDATE TouristAttractions SET Facts = N'Khai trương | 1/5/2017
Vị trí | Phố 19 Tháng 12, quận Hoàn Kiếm
Tên phố | Theo ngày Toàn quốc kháng chiến 19/12/1946
Hoạt động | Giới thiệu sách, giao lưu tác giả, ngày hội đọc', Timeline = N'1986 | Chợ 19-12 (dân gian gọi là chợ Âm Phủ) hình thành trên phố
1/5/2017 | Phố sách Hà Nội khai trương với 16 gian hàng sách' WHERE Name = N'Phố sách Hà Nội';
UPDATE TouristAttractions SET Facts = N'Xây dựng | 1898 – 1902
Thi công | Công ty Daydé & Pillé (Pháp)
Tên ban đầu | Cầu Doumer
Chiều dài | Khoảng 2,3 km phần qua sông', Timeline = N'1898 | Khởi công xây cầu
1902 | Khánh thành với tên cầu Doumer
Chiến tranh chống Mỹ | Bị ném bom nhiều lần, được sửa chữa để giữ mạch giao thông' WHERE Name = N'Cầu Long Biên';
UPDATE TouristAttractions SET Facts = N'Thành lập | 10/10/1969
Loại hình | Múa rối nước truyền thống
Âm nhạc | Dàn nhạc dân tộc và hát chèo biểu diễn trực tiếp
Lưu diễn | Hơn 40 quốc gia', Timeline = N'10/10/1969 | Thành lập với tên Đoàn Nghệ thuật Kim Đồng, ban đầu có 9 thành viên
1975 | Đổi tên thành Đoàn Múa rối Hà Nội
2001 | Mang tên Nhà hát Múa rối Thăng Long
2024 | Kỷ niệm 55 năm thành lập, đón nhận Huân chương Lao động hạng Ba' WHERE Name = N'Nhà hát Múa rối Thăng Long';

/* ---- Anh dai dien moi (do phan giai cao, dung chu de) ---- */
UPDATE TouristAttractions SET ImageCredit = N'Ảnh: dronepicr / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Hanoi_Altstadt_(38647529885).jpg' WHERE Name = N'Phố cổ Hà Nội';
UPDATE TouristAttractions SET ImageCredit = N'Ảnh: Cvbr / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Mausoleo_de_Ho_Chi_Minh.JPG' WHERE Name = N'Quảng trường Ba Đình';
UPDATE TouristAttractions SET ImageCredit = N'Ảnh: dronepicr / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Eins%C3%A4ulenpagode_Ngoc_Son_Hanoi_(39513844382).jpg' WHERE Name = N'Chùa Một Cột';
UPDATE TouristAttractions SET ImageCredit = N'Ảnh: Xiquinho Silva / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Constellation_of_Literature_pavilion_-_Temple_of_Literature,_Hanoi_(32342168616).jpg' WHERE Name = N'Văn Miếu - Quốc Tử Giám';
UPDATE TouristAttractions SET ImageCredit = N'Ảnh: Gary Todd from Xinzheng, China / CC0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Vietnam_History_Museum_(9753223996).jpg' WHERE Name = N'Bảo tàng Lịch sử Quốc gia';

/* ---- Bo suu tap: anh thay the / bo sung (cung ten file) ---- */
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/03-pho-co-ha-noi-3.jpg')
    UPDATE AttractionImages SET Caption = N'Ô Quan Chưởng – cửa ô cổ duy nhất còn lại của kinh thành', Credit = N'xiquinhosilva / CC BY 2.0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:04369-Hanoi_(32236414221).jpg' WHERE ImageUrl = '/images/attractions/gallery/03-pho-co-ha-noi-3.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/03-pho-co-ha-noi-3.jpg', N'Ô Quan Chưởng – cửa ô cổ duy nhất còn lại của kinh thành', N'xiquinhosilva / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:04369-Hanoi_(32236414221).jpg', 3 FROM TouristAttractions WHERE Name = N'Phố cổ Hà Nội';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/03-pho-co-ha-noi-5.jpg')
    UPDATE AttractionImages SET Caption = N'Áo dài trong một con phố nhỏ', Credit = N'Alexkom000 / CC BY 4.0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:2024-11-03_Hanoi%27s_Old_Quarter_2.jpg' WHERE ImageUrl = '/images/attractions/gallery/03-pho-co-ha-noi-5.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/03-pho-co-ha-noi-5.jpg', N'Áo dài trong một con phố nhỏ', N'Alexkom000 / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:2024-11-03_Hanoi%27s_Old_Quarter_2.jpg', 5 FROM TouristAttractions WHERE Name = N'Phố cổ Hà Nội';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/06-nha-tu-hoa-lo-1.jpg')
    UPDATE AttractionImages SET Caption = N'Buồng giam tập thể được tái hiện', Credit = N'Gary Todd from Xinzheng, China / CC0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:Hoa_Lo_Prison_(9754201116).jpg' WHERE ImageUrl = '/images/attractions/gallery/06-nha-tu-hoa-lo-1.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/06-nha-tu-hoa-lo-1.jpg', N'Buồng giam tập thể được tái hiện', N'Gary Todd from Xinzheng, China / CC0', 'https://commons.wikimedia.org/wiki/File:Hoa_Lo_Prison_(9754201116).jpg', 1 FROM TouristAttractions WHERE Name = N'Nhà tù Hỏa Lò';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/06-nha-tu-hoa-lo-2.jpg')
    UPDATE AttractionImages SET Caption = N'Tượng tù nhân bị cùm chân trên sàn gỗ', Credit = N'Richard Mortel from Riyadh, Saudi Arabia / CC BY 2.0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:Hoa_Lo_Prison_Museum,_Hanoi_(4)_(37781176004).jpg' WHERE ImageUrl = '/images/attractions/gallery/06-nha-tu-hoa-lo-2.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/06-nha-tu-hoa-lo-2.jpg', N'Tượng tù nhân bị cùm chân trên sàn gỗ', N'Richard Mortel from Riyadh, Saudi Arabia / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hoa_Lo_Prison_Museum,_Hanoi_(4)_(37781176004).jpg', 2 FROM TouristAttractions WHERE Name = N'Nhà tù Hỏa Lò';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/06-nha-tu-hoa-lo-3.jpg')
    UPDATE AttractionImages SET Caption = N'Hành lang dãy xà lim', Credit = N'Richard Mortel from Riyadh, Saudi Arabia / CC BY 2.0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:French_era_guillotine,_Hoa_Lo_Prison_Museum,_Hanoi_(1)_(24623024918).jpg' WHERE ImageUrl = '/images/attractions/gallery/06-nha-tu-hoa-lo-3.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/06-nha-tu-hoa-lo-3.jpg', N'Hành lang dãy xà lim', N'Richard Mortel from Riyadh, Saudi Arabia / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:French_era_guillotine,_Hoa_Lo_Prison_Museum,_Hanoi_(1)_(24623024918).jpg', 3 FROM TouristAttractions WHERE Name = N'Nhà tù Hỏa Lò';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/06-nha-tu-hoa-lo-4.jpg')
    UPDATE AttractionImages SET Caption = N'Đài tưởng niệm các chiến sĩ cách mạng', Credit = N'Gary Todd from Xinzheng, China / CC0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:Hoa_Lo_Prison_(9753880271).jpg' WHERE ImageUrl = '/images/attractions/gallery/06-nha-tu-hoa-lo-4.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/06-nha-tu-hoa-lo-4.jpg', N'Đài tưởng niệm các chiến sĩ cách mạng', N'Gary Todd from Xinzheng, China / CC0', 'https://commons.wikimedia.org/wiki/File:Hoa_Lo_Prison_(9753880271).jpg', 4 FROM TouristAttractions WHERE Name = N'Nhà tù Hỏa Lò';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/06-nha-tu-hoa-lo-5.jpg')
    UPDATE AttractionImages SET Caption = N'Bộ đồ bay của phi công John McCain ở khu "Hanoi Hilton"', Credit = N'Richard Mortel from Riyadh, Saudi Arabia / CC BY 2.0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:Flight_suit_of_John_McCain,_Hoa_Lo_Prison_Museum,_Hanoi_(38439531806).jpg' WHERE ImageUrl = '/images/attractions/gallery/06-nha-tu-hoa-lo-5.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/06-nha-tu-hoa-lo-5.jpg', N'Bộ đồ bay của phi công John McCain ở khu "Hanoi Hilton"', N'Richard Mortel from Riyadh, Saudi Arabia / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Flight_suit_of_John_McCain,_Hoa_Lo_Prison_Museum,_Hanoi_(38439531806).jpg', 5 FROM TouristAttractions WHERE Name = N'Nhà tù Hỏa Lò';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/09-quang-truong-ba-dinh-1.jpg')
    UPDATE AttractionImages SET Caption = N'Khẩu hiệu và hàng cột cờ bên quảng trường', Credit = N'Richard Mortel from Riyadh, Saudi Arabia / CC BY 2.0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:Patriotic_banner_in_Ba_Dinh_Square,_Hanoi_(37610558745).jpg' WHERE ImageUrl = '/images/attractions/gallery/09-quang-truong-ba-dinh-1.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/09-quang-truong-ba-dinh-1.jpg', N'Khẩu hiệu và hàng cột cờ bên quảng trường', N'Richard Mortel from Riyadh, Saudi Arabia / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Patriotic_banner_in_Ba_Dinh_Square,_Hanoi_(37610558745).jpg', 1 FROM TouristAttractions WHERE Name = N'Quảng trường Ba Đình';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/09-quang-truong-ba-dinh-4.jpg')
    UPDATE AttractionImages SET Caption = N'Hoàng hôn trên quảng trường', Credit = N'Rungbachduong / CC BY-SA 3.0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:Ba_Dinh_Square_2007.jpg' WHERE ImageUrl = '/images/attractions/gallery/09-quang-truong-ba-dinh-4.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/09-quang-truong-ba-dinh-4.jpg', N'Hoàng hôn trên quảng trường', N'Rungbachduong / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Ba_Dinh_Square_2007.jpg', 4 FROM TouristAttractions WHERE Name = N'Quảng trường Ba Đình';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/10-chua-mot-cot-3.jpg')
    UPDATE AttractionImages SET Caption = N'Sân chùa Diên Hựu ngay cạnh Chùa Một Cột', Credit = N'Bùi Thụy Đào Nguyên / CC BY-SA 4.0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:Ch%C3%B9a_Di%C3%AAn_H%E1%BB%B1u.jpg' WHERE ImageUrl = '/images/attractions/gallery/10-chua-mot-cot-3.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/10-chua-mot-cot-3.jpg', N'Sân chùa Diên Hựu ngay cạnh Chùa Một Cột', N'Bùi Thụy Đào Nguyên / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Ch%C3%B9a_Di%C3%AAn_H%E1%BB%B1u.jpg', 3 FROM TouristAttractions WHERE Name = N'Chùa Một Cột';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/10-chua-mot-cot-4.jpg')
    UPDATE AttractionImages SET Caption = N'Cổng chùa Diên Hựu', Credit = N'Bùi Thụy Đào Nguyên / CC BY-SA 3.0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:C%E1%BB%95ng_ch%C3%B9a_Di%C3%AAn_H%E1%BB%B1u.jpg' WHERE ImageUrl = '/images/attractions/gallery/10-chua-mot-cot-4.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/10-chua-mot-cot-4.jpg', N'Cổng chùa Diên Hựu', N'Bùi Thụy Đào Nguyên / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:C%E1%BB%95ng_ch%C3%B9a_Di%C3%AAn_H%E1%BB%B1u.jpg', 4 FROM TouristAttractions WHERE Name = N'Chùa Một Cột';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-4.jpg')
    UPDATE AttractionImages SET Caption = N'Nhà bia: bia tiến sĩ đặt trên lưng rùa đá', Credit = N'Daderot / CC0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:Stelae_of_Doctors_-_Temple_of_Literature,_Hanoi_-_DSC04678.JPG' WHERE ImageUrl = '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-4.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-4.jpg', N'Nhà bia: bia tiến sĩ đặt trên lưng rùa đá', N'Daderot / CC0', 'https://commons.wikimedia.org/wiki/File:Stelae_of_Doctors_-_Temple_of_Literature,_Hanoi_-_DSC04678.JPG', 4 FROM TouristAttractions WHERE Name = N'Văn Miếu - Quốc Tử Giám';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/18-pho-sach-ha-noi-1.jpg')
    UPDATE AttractionImages SET Caption = N'Sách mới bày bán trong ngày hội', Credit = N'Newone / CC BY-SA 4.0 (đã cắt viền dưới)', SourceUrl = 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_20.jpg' WHERE ImageUrl = '/images/attractions/gallery/18-pho-sach-ha-noi-1.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/18-pho-sach-ha-noi-1.jpg', N'Sách mới bày bán trong ngày hội', N'Newone / CC BY-SA 4.0 (đã cắt viền dưới)', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_20.jpg', 1 FROM TouristAttractions WHERE Name = N'Phố sách Hà Nội';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/18-pho-sach-ha-noi-2.jpg')
    UPDATE AttractionImages SET Caption = N'Những bàn sách dưới mái lều', Credit = N'Newone / CC BY-SA 4.0 (đã cắt viền dưới)', SourceUrl = 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_19.jpg' WHERE ImageUrl = '/images/attractions/gallery/18-pho-sach-ha-noi-2.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/18-pho-sach-ha-noi-2.jpg', N'Những bàn sách dưới mái lều', N'Newone / CC BY-SA 4.0 (đã cắt viền dưới)', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_19.jpg', 2 FROM TouristAttractions WHERE Name = N'Phố sách Hà Nội';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/18-pho-sach-ha-noi-3.jpg')
    UPDATE AttractionImages SET Caption = N'Sân khấu Ngày hội khuyến đọc', Credit = N'Newone / CC BY-SA 4.0 (đã cắt viền dưới)', SourceUrl = 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_14.jpg' WHERE ImageUrl = '/images/attractions/gallery/18-pho-sach-ha-noi-3.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/18-pho-sach-ha-noi-3.jpg', N'Sân khấu Ngày hội khuyến đọc', N'Newone / CC BY-SA 4.0 (đã cắt viền dưới)', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_14.jpg', 3 FROM TouristAttractions WHERE Name = N'Phố sách Hà Nội';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/18-pho-sach-ha-noi-4.jpg')
    UPDATE AttractionImages SET Caption = N'Sách bày theo chủ đề', Credit = N'Newone / CC BY-SA 4.0 (đã cắt viền dưới)', SourceUrl = 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_18.jpg' WHERE ImageUrl = '/images/attractions/gallery/18-pho-sach-ha-noi-4.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/18-pho-sach-ha-noi-4.jpg', N'Sách bày theo chủ đề', N'Newone / CC BY-SA 4.0 (đã cắt viền dưới)', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_18.jpg', 4 FROM TouristAttractions WHERE Name = N'Phố sách Hà Nội';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/18-pho-sach-ha-noi-5.jpg')
    UPDATE AttractionImages SET Caption = N'Giao lưu trên sân khấu buổi tối', Credit = N'Newone / CC BY-SA 4.0 (đã cắt viền dưới)', SourceUrl = 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_06.jpg' WHERE ImageUrl = '/images/attractions/gallery/18-pho-sach-ha-noi-5.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/18-pho-sach-ha-noi-5.jpg', N'Giao lưu trên sân khấu buổi tối', N'Newone / CC BY-SA 4.0 (đã cắt viền dưới)', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_06.jpg', 5 FROM TouristAttractions WHERE Name = N'Phố sách Hà Nội';
IF EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/10-chua-mot-cot-1.jpg')
    UPDATE AttractionImages SET Caption = N'Chùa Một Cột giữa hồ vuông', Credit = N'rhjpage / CC BY 2.0', SourceUrl = 'https://commons.wikimedia.org/wiki/File:Hanoi_day_2-3_(42633363262).jpg' WHERE ImageUrl = '/images/attractions/gallery/10-chua-mot-cot-1.jpg';
ELSE
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/10-chua-mot-cot-1.jpg', N'Chùa Một Cột giữa hồ vuông', N'rhjpage / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_day_2-3_(42633363262).jpg', 1 FROM TouristAttractions WHERE Name = N'Chùa Một Cột';
IF NOT EXISTS (SELECT 1 FROM AttractionImages WHERE ImageUrl = '/images/attractions/gallery/09-quang-truong-ba-dinh-5.jpg')
    INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
    SELECT AttractionId, '/images/attractions/gallery/09-quang-truong-ba-dinh-5.jpg', N'Lăng Bác nhìn từ thảm cỏ quảng trường', N'Vyacheslav Argenberg / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi,_Vietnam,_Ba_Dinh_Square.jpg', 5 FROM TouristAttractions WHERE Name = N'Quảng trường Ba Đình';

/* ---- Sua chu thich khong khop noi dung anh ---- */
UPDATE AttractionImages SET Caption = N'Hồ Gươm lung linh về đêm' WHERE ImageUrl = '/images/attractions/gallery/01-ho-hoan-kiem-1.jpg';
UPDATE AttractionImages SET Caption = N'Hàng cau và cờ trong khuôn viên khu di tích' WHERE ImageUrl = '/images/attractions/gallery/08-lang-chu-tich-ho-chi-minh-4.jpg';
UPDATE AttractionImages SET Caption = N'Chiến sĩ đi đều trên quảng trường' WHERE ImageUrl = '/images/attractions/gallery/09-quang-truong-ba-dinh-3.jpg';
UPDATE AttractionImages SET Caption = N'Gác trong khuôn viên Văn Miếu' WHERE ImageUrl = '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-2.jpg';
UPDATE AttractionImages SET Caption = N'Sảnh trưng bày bên trong bảo tàng' WHERE ImageUrl = '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-3.jpg';
UPDATE AttractionImages SET Caption = N'Tranh vẽ thuyền chiến Đại Việt' WHERE ImageUrl = '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-4.jpg';
UPDATE AttractionImages SET Caption = N'Khu vườn trong khuôn viên bảo tàng' WHERE ImageUrl = '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-5.jpg';
UPDATE AttractionImages SET Caption = N'Những ngôi nhà cũ trên phố Tạ Hiện' WHERE ImageUrl = '/images/attractions/gallery/17-pho-ta-hien-1.jpg';
UPDATE AttractionImages SET Caption = N'Phố bia Tạ Hiện về đêm' WHERE ImageUrl = '/images/attractions/gallery/17-pho-ta-hien-2.jpg';
UPDATE AttractionImages SET Caption = N'Áo dài và cờ đỏ trên phố' WHERE ImageUrl = '/images/attractions/gallery/17-pho-ta-hien-3.jpg';
UPDATE AttractionImages SET Caption = N'Góc phố Tạ Hiện lúc vắng khách' WHERE ImageUrl = '/images/attractions/gallery/17-pho-ta-hien-4.jpg';
UPDATE AttractionImages SET Caption = N'Phố Tạ Hiện ban ngày' WHERE ImageUrl = '/images/attractions/gallery/17-pho-ta-hien-5.jpg';
UPDATE AttractionImages SET Caption = N'Hành lang dãy xà lim' WHERE ImageUrl = '/images/attractions/gallery/06-nha-tu-hoa-lo-3.jpg';
GO

/* ---------------------------------------------------------------------
   10. AttractionStations
   --------------------------------------------------------------------- */
INSERT INTO AttractionStations (AttractionId, StationId, WalkingDistance, WalkingDuration) VALUES
(1, 75, 160, 2), (1, 208, 350, 5), (1, 86, 510, 7), (1, 514, 180, 3), (1, 563, 180, 3),
(2, 75, 460, 6), (2, 71, 480, 6), (2, 146, 510, 7), (2, 514, 460, 6), (2, 563, 460, 6),
(3, 130, 550, 7), (3, 73, 560, 7), (3, 146, 580, 8), (3, 489, 940, 12), (3, 538, 940, 12),
(4, 50, 270, 4), (4, 228, 360, 5), (4, 145, 410, 6), (4, 491, 450, 6), (4, 540, 450, 6),
(5, 207, 100, 2), (5, 176, 150, 2), (5, 248, 340, 5), (5, 511, 90, 2), (5, 560, 90, 2),
(6, 129, 60, 1), (6, 230, 60, 1), (6, 229, 170, 3), (6, 506, 50, 1), (6, 555, 50, 1),
(7, 382, 400, 5), (7, 73, 540, 7), (7, 107, 540, 7), (7, 488, 610, 8), (7, 537, 610, 8),
(8, 179, 380, 5), (8, 382, 640, 8), (8, 120, 650, 9), (8, 498, 830, 11), (8, 547, 830, 11),
(9, 179, 370, 5), (9, 382, 620, 8), (9, 120, 660, 9), (9, 498, 840, 11), (9, 547, 840, 11),
(10, 179, 220, 3), (10, 120, 460, 6), (10, 263, 630, 8), (10, 454, 1330, 17), (10, 486, 740, 10), (10, 535, 740, 10),
(11, 432, 80, 1), (11, 264, 240, 3), (11, 431, 440, 6), (11, 454, 1100, 14), (11, 487, 480, 6), (11, 536, 480, 6),
(12, 433, 180, 3), (12, 108, 220, 3), (12, 264, 300, 4), (12, 454, 820, 11), (12, 487, 430, 6), (12, 536, 430, 6),
(13, 248, 210, 3), (13, 207, 280, 4), (13, 208, 300, 4), (13, 512, 50, 1), (13, 561, 50, 1),
(14, 111, 70, 1), (14, 359, 570, 8), (14, 52, 630, 8), (14, 472, 950, 12),
(15, 322, 1310, 17), (15, 493, 880, 11), (15, 542, 880, 11),
(16, 212, 680, 9), (16, 85, 720, 9), (16, 492, 400, 5), (16, 541, 400, 5),
(17, 29, 490, 7), (17, 146, 490, 7), (17, 50, 550, 7), (17, 491, 900, 12), (17, 540, 900, 12),
(18, 132, 160, 2), (18, 229, 210, 3), (18, 133, 300, 4), (18, 515, 200, 3), (18, 564, 200, 3),
(19, 209, 330, 5), (19, 347, 330, 5), (19, 437, 340, 5), (19, 491, 640, 8), (19, 540, 640, 8),
(20, 146, 320, 4), (20, 71, 390, 5), (20, 29, 450, 6), (20, 513, 640, 8), (20, 562, 640, 8);
GO

/* ---------------------------------------------------------------------
   11. TicketTypes  (PHAI insert truoc OrderDetails / Tickets)
   --------------------------------------------------------------------- */
INSERT INTO TicketTypes (Name, TransportTypeId, Type, Price, DurationMinutes, Description) VALUES
(N'Vé lượt Bus',        1, 'SINGLE',  7000,  120,   N'Một lượt xe buýt - giá 7.000đ theo bảng giá phổ biến (Vinpearl)'),
(N'Vé lượt Metro',      2, 'SINGLE',  15000, 120,   N'Một lượt Metro (mức tối đa của khung giá 8.000 - 15.000đ)'),
(N'Vé tháng Bus',       1, 'MONTHLY', 200000, 43200, N'Vé tháng mô phỏng - đi không giới hạn 30 ngày'),
(N'Vé tháng Metro',     2, 'MONTHLY', 300000, 43200, N'Vé tháng mô phỏng - đi không giới hạn 30 ngày'),
(N'Vé lượt Xe đạp',     3, 'SINGLE',  5000,  60,    N'Thuê xe đạp công cộng tối đa 60 phút'),
(N'Vé lượt Xe điện',    4, 'SINGLE',  10000, 60,    N'Một lượt xe điện công cộng trong 60 phút');
GO

/* ---------------------------------------------------------------------
   12. FareRules
     - Bus: dong gia 7.000d/luot (theo Vinpearl) -> dung gia mac dinh, khong can FareRule
     - Metro: gia theo quang duong MO PHONG trong khung 8.000 - 15.000d
       (8.000d + 1.000d moi 1.5 km, toi da 15.000d) - ap dung ca 2 chieu
     - Xe dap / xe dien: gia mac dinh moi luot (routing.config.ts)
   --------------------------------------------------------------------- */
INSERT INTO FareRules (TransportTypeId, FromStationId, ToStationId, Price) VALUES
(2, 454, 455, 8000), (2, 454, 456, 9000), (2, 454, 457, 9000), (2, 454, 458, 10000), (2, 454, 459, 11000), (2, 454, 460, 12000), (2, 454, 461, 13000), (2, 454, 462, 14000),
(2, 454, 463, 14000), (2, 454, 464, 15000), (2, 454, 465, 15000), (2, 455, 456, 8000), (2, 455, 457, 9000), (2, 455, 458, 10000), (2, 455, 459, 10000), (2, 455, 460, 11000),
(2, 455, 461, 12000), (2, 455, 462, 13000), (2, 455, 463, 14000), (2, 455, 464, 15000), (2, 455, 465, 15000), (2, 456, 457, 8000), (2, 456, 458, 9000), (2, 456, 459, 10000),
(2, 456, 460, 11000), (2, 456, 461, 11000), (2, 456, 462, 12000), (2, 456, 463, 13000), (2, 456, 464, 14000), (2, 456, 465, 15000), (2, 457, 458, 8000), (2, 457, 459, 9000),
(2, 457, 460, 10000), (2, 457, 461, 11000), (2, 457, 462, 12000), (2, 457, 463, 12000), (2, 457, 464, 14000), (2, 457, 465, 14000), (2, 458, 459, 8000), (2, 458, 460, 9000),
(2, 458, 461, 10000), (2, 458, 462, 11000), (2, 458, 463, 12000), (2, 458, 464, 13000), (2, 458, 465, 13000), (2, 459, 460, 9000), (2, 459, 461, 9000), (2, 459, 462, 10000),
(2, 459, 463, 11000), (2, 459, 464, 12000), (2, 459, 465, 13000), (2, 460, 461, 8000), (2, 460, 462, 9000), (2, 460, 463, 10000), (2, 460, 464, 11000), (2, 460, 465, 12000),
(2, 461, 462, 8000), (2, 461, 463, 9000), (2, 461, 464, 10000), (2, 461, 465, 11000), (2, 462, 463, 8000), (2, 462, 464, 9000), (2, 462, 465, 10000), (2, 463, 464, 9000),
(2, 463, 465, 9000), (2, 464, 465, 8000), (2, 466, 467, 8000), (2, 466, 468, 9000), (2, 466, 469, 10000), (2, 466, 470, 11000), (2, 466, 471, 11000), (2, 466, 472, 12000),
(2, 466, 473, 13000), (2, 467, 468, 8000), (2, 467, 469, 9000), (2, 467, 470, 10000), (2, 467, 471, 11000), (2, 467, 472, 12000), (2, 467, 473, 12000), (2, 468, 469, 8000),
(2, 468, 470, 9000), (2, 468, 471, 10000), (2, 468, 472, 11000), (2, 468, 473, 11000), (2, 469, 470, 8000), (2, 469, 471, 9000), (2, 469, 472, 10000), (2, 469, 473, 11000),
(2, 470, 471, 8000), (2, 470, 472, 9000), (2, 470, 473, 10000), (2, 471, 472, 8000), (2, 471, 473, 9000), (2, 472, 473, 8000);
GO

/* ---------------------------------------------------------------------
   13..16. Orders, OrderDetails, Payments, Tickets
   --------------------------------------------------------------------- */
-- 3 don hang mau cua nhom (giu nguyen y nghia)
INSERT INTO Orders (UserId, TotalAmount, Status) VALUES
(1, 7000,   'PAID'),
(2, 300000, 'PAID'),
(3, 15000,  'PENDING');

INSERT INTO OrderDetails (OrderId, TicketTypeId, Quantity, UnitPrice) VALUES
(1, 1, 1, 7000),
(2, 4, 1, 300000),
(3, 2, 1, 15000);

INSERT INTO Payments (OrderId, Amount, PaymentMethod, Status, TransactionCode, PaidAt, CardBrand, CardLast4, TransferContent, ExpiresAt) VALUES
(1, 7000,   'CARD',          'SUCCESS', 'CARD-TXN-000001', SYSDATETIME(), 'VISA', '4242', NULL, NULL),
(2, 300000, 'BANK_TRANSFER', 'SUCCESS', 'BANK-TXN-000002', SYSDATETIME(), NULL, NULL, 'HNG2SEED', NULL),
(3, 15000,  'BANK_TRANSFER', 'EXPIRED', NULL, NULL, NULL, NULL, 'HNG3SEED', DATEADD(MINUTE, -30, SYSDATETIME()));

-- Tai khoan nhan chuyen khoan: de trong, admin dien tai Quan tri > Thanh toan
INSERT INTO PaymentSettings (SettingId, TransferExpiryMinutes) VALUES (1, 30);

INSERT INTO Tickets (OrderId, TicketTypeId, TicketCode, QRCode, ValidFrom, ValidTo, Status) VALUES
(1, 1, 'TICKET-000001', NULL, SYSDATETIME(), DATEADD(HOUR, 2, SYSDATETIME()), 'ACTIVE'),
(2, 4, 'TICKET-000002', NULL, SYSDATETIME(), DATEADD(DAY, 30, SYSDATETIME()), 'ACTIVE');
GO

-- Sinh them ~24 don hang da thanh toan trong 14 ngay qua (phuc vu bieu do thong ke)
DECLARE @i INT = 1;
WHILE @i <= 24
BEGIN
    DECLARE @UserId INT       = ((@i - 1) % 3) + 1;
    DECLARE @TypeId INT       = CASE (@i % 6) WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 1 WHEN 3 THEN 5 WHEN 4 THEN 6 ELSE 3 END;
    DECLARE @Qty INT          = CASE WHEN @TypeId IN (3, 4) THEN 1 ELSE ((@i % 3) + 1) END;
    DECLARE @Price DECIMAL(12,2), @Duration INT;
    SELECT @Price = Price, @Duration = DurationMinutes FROM TicketTypes WHERE TicketTypeId = @TypeId;

    DECLARE @CreatedAt DATETIME2 = DATEADD(HOUR, -((@i * 13) % 24), DATEADD(DAY, -((@i * 5) % 14) - 1, SYSDATETIME()));
    DECLARE @OrderId INT;

    INSERT INTO Orders (UserId, TotalAmount, Status, CreatedAt)
    VALUES (@UserId, @Price * @Qty, 'PAID', @CreatedAt);
    SET @OrderId = SCOPE_IDENTITY();

    INSERT INTO OrderDetails (OrderId, TicketTypeId, Quantity, UnitPrice)
    VALUES (@OrderId, @TypeId, @Qty, @Price);

    INSERT INTO Payments (OrderId, Amount, PaymentMethod, Status, TransactionCode, PaidAt, CardBrand, CardLast4, CreatedAt)
    VALUES (@OrderId, @Price * @Qty, 'CARD', 'SUCCESS',
            CONCAT('CARD-TXN-', RIGHT('000000' + CAST(@OrderId AS VARCHAR(10)), 6)), @CreatedAt,
            CASE @OrderId % 3 WHEN 0 THEN 'MASTERCARD' WHEN 1 THEN 'VISA' ELSE 'NAPAS' END,
            RIGHT('0000' + CAST((@OrderId * 37) % 10000 AS VARCHAR(4)), 4), @CreatedAt);

    DECLARE @k INT = 1;
    WHILE @k <= @Qty
    BEGIN
        DECLARE @ValidTo DATETIME2 = DATEADD(MINUTE, @Duration, @CreatedAt);
        INSERT INTO Tickets (OrderId, TicketTypeId, TicketCode, QRCode, ValidFrom, ValidTo, Status)
        VALUES (@OrderId, @TypeId,
                CONCAT('TICKET-S', RIGHT('0000' + CAST(@OrderId AS VARCHAR(10)), 4), '-', @k),
                NULL, @CreatedAt, @ValidTo,
                CASE WHEN @ValidTo < SYSDATETIME() THEN (CASE WHEN @k = 1 THEN 'USED' ELSE 'EXPIRED' END)
                     ELSE 'ACTIVE' END);
        SET @k += 1;
    END

    SET @i += 1;
END
GO

/* ---------------------------------------------------------------------
   17. TripHistories
   --------------------------------------------------------------------- */
INSERT INTO TripHistories (UserId, Origin, Destination, RouteData, StartedAt, CompletedAt) VALUES
(1, N'Hồ Hoàn Kiếm', N'Văn Miếu - Quốc Tử Giám',
 N'{"preference":"FASTEST","route":"09A","transfers":0,"duration":22}',
 DATEADD(DAY, -2, SYSDATETIME()), DATEADD(MINUTE, 20, DATEADD(DAY, -2, SYSDATETIME()))),
(2, N'Hồ Hoàn Kiếm', N'Hoàng thành Thăng Long',
 N'{"preference":"FEWEST_TRANSFERS","route":"BIKE-SHARE","transfers":0,"duration":18}',
 DATEADD(DAY, -1, SYSDATETIME()), DATEADD(MINUTE, 25, DATEADD(DAY, -1, SYSDATETIME()))),
(1, N'Nhà tù Hỏa Lò', N'Chùa Trấn Quốc',
 N'{"preference":"CHEAPEST","route":"09A>BIKE-SHARE","transfers":1,"duration":34}',
 DATEADD(DAY, -3, SYSDATETIME()), DATEADD(MINUTE, 34, DATEADD(DAY, -3, SYSDATETIME())));
GO

/* Kiem tra nhanh so luong ban ghi */
SELECT 'Users' AS TableName, COUNT(*) AS Total FROM Users
UNION ALL SELECT 'TransportTypes', COUNT(*) FROM TransportTypes
UNION ALL SELECT 'Vehicles', COUNT(*) FROM Vehicles
UNION ALL SELECT 'Stations', COUNT(*) FROM Stations
UNION ALL SELECT 'Routes', COUNT(*) FROM Routes
UNION ALL SELECT 'RouteStations', COUNT(*) FROM RouteStations
UNION ALL SELECT 'Trips', COUNT(*) FROM Trips
UNION ALL SELECT 'StopTimes', COUNT(*) FROM StopTimes
UNION ALL SELECT 'TouristAttractions', COUNT(*) FROM TouristAttractions
UNION ALL SELECT 'AttractionStations', COUNT(*) FROM AttractionStations
UNION ALL SELECT 'TicketTypes', COUNT(*) FROM TicketTypes
UNION ALL SELECT 'FareRules', COUNT(*) FROM FareRules
UNION ALL SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL SELECT 'OrderDetails', COUNT(*) FROM OrderDetails
UNION ALL SELECT 'Payments', COUNT(*) FROM Payments
UNION ALL SELECT 'Tickets', COUNT(*) FROM Tickets
UNION ALL SELECT 'TripHistories', COUNT(*) FROM TripHistories;
GO
