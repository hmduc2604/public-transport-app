/* =====================================================================
   12_more_attractions.sql - Them 14 dia diem (tham khao bai "Ha Noi di dau choi"
   cua Vietnam Airlines) + sua tram gan Ho Tay sau khi doi toa do.
   Chay tren database DA CO du lieu, an toan khi chay lai (them theo ten, khong trung).
   - Thong tin: gioi thieu, lich su, diem noi bat, gio mo cua, gia ve (tra cuu 11/2026),
     thong tin nhanh, moc lich su
   - Anh: Wikimedia Commons (CC0 / Public domain / CC BY / CC BY-SA) - 4 dia diem chua co
     anh giay phep tu do (Pho sach Dinh Le, BT Thien nhien, Thuy cung Times City, Lotte Mall)
   - Tram gan + quang duong di bo THAT (OSRM, du lieu OpenStreetMap)
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
GO
USE PublicTransportDBV2;
GO
/* ---- 1. Dia diem moi ---- */
INSERT INTO TouristAttractions
(Name, Description, History, Highlights, Address, Latitude, Longitude, Category, OpeningHours, TicketPrice, PopularityScore,
 HoursSummary, PriceFrom, VisitDuration, BestTime, Tips, Facts, Timeline)
SELECT v.* FROM (VALUES
(N'Nhà thờ Lớn Hà Nội',
 N'Nhà thờ chính tòa Thánh Giuse – nhà thờ Công giáo lâu đời và nổi tiếng nhất Hà Nội, kiến trúc tân Gothic với hai tháp chuông vuông, nằm cuối phố Nhà Chung giữa khu phố cổ.',
 N'Nhà thờ do Giám mục Puginier cho khởi công năm 1884 trên khu đất từng là chùa Báo Thiên – ngôi chùa nổi tiếng thời Lý có tháp Báo Thiên dựng khoảng năm 1057 – và khánh thành vào dịp Lễ Giáng sinh năm 1886. Công trình xây theo phong cách tân Gothic, thường được ví như phiên bản thu nhỏ của Nhà thờ Đức Bà Paris, dùng gạch, đá và nhân công địa phương. Đây là nhà thờ chính tòa của Tổng giáo phận Hà Nội.',
 N'Mặt tiền tân Gothic với hai tháp chuông cao khoảng 31,5 m|Cửa sổ hoa hồng và kính màu trong thánh đường|Tượng Đức Mẹ giữa khoảng sân trước nhà thờ|Không khí Giáng sinh rực rỡ mỗi dịp cuối năm|Trà chanh, cà phê quanh phố Nhà Chung',
 N'40 Nhà Chung, Hoàn Kiếm, Hà Nội',
 21.028648, 105.848857,
 N'Tôn giáo',
 N'Bên ngoài và sân nhà thờ mở cả ngày. Bên trong thường đón khách khoảng 8:00 – 11:00 và 14:00 – 20:00 (Chủ nhật theo giờ lễ); khi đang có thánh lễ chỉ vào dự lễ, giữ trật tự.',
 N'Miễn phí.',
 88,
 N'8:00 – 11:00, 14:00 – 20:00',
 N'Miễn phí',
 N'30 – 60 phút',
 N'Sáng sớm khi phố còn vắng hoặc buổi tối khi tháp chuông lên đèn; đẹp nhất mùa Giáng sinh.',
 N'Ăn mặc kín đáo (che vai, gối) khi vào thánh đường|Không đi lại, chụp ảnh khi đang có thánh lễ|Đêm 24/12 rất đông, nên đi sớm và giữ đồ cẩn thận|Đi bộ ra Hồ Gươm chỉ khoảng 5 phút',
 N'Tên chính thức | Nhà thờ chính tòa Thánh Giuse
Phong cách | Tân Gothic
Kích thước | Dài 64,5 m, rộng 20,5 m
Tháp chuông | 2 tháp, cao khoảng 31,5 m
Vai trò | Nhà thờ chính tòa Tổng giáo phận Hà Nội',
 N'Khoảng 1057 | Thời Lý dựng tháp Báo Thiên trong chùa Báo Thiên – khu đất sau này xây nhà thờ
1884 | Giám mục Puginier cho khởi công xây nhà thờ
1886 | Khánh thành vào dịp Lễ Giáng sinh'),
(N'Bảo tàng Hồ Chí Minh',
 N'Bảo tàng lớn nhất về cuộc đời và sự nghiệp của Chủ tịch Hồ Chí Minh, nằm trong quần thể di tích Ba Đình, cạnh Lăng Bác và Chùa Một Cột.',
 N'Bảo tàng được thành lập ngày 25/11/1970. Tòa nhà hiện nay khởi công ngày 31/8/1985 với sự giúp đỡ của Liên Xô và khánh thành ngày 19/5/1990, đúng dịp kỷ niệm 100 năm Ngày sinh Chủ tịch Hồ Chí Minh. Đây là bảo tàng đầu ngành trong hệ thống các bảo tàng, di tích lưu niệm Chủ tịch Hồ Chí Minh trên cả nước, lưu giữ hàng vạn tài liệu, hiện vật quý về Người.',
 N'Hành trình cuộc đời Chủ tịch Hồ Chí Minh qua tài liệu, hiện vật, ảnh tư liệu|Các không gian trưng bày nghệ thuật sắp đặt độc đáo|Không gian tưởng niệm Chủ tịch Hồ Chí Minh|Đi bộ vài phút tới Lăng Bác, Phủ Chủ tịch, Chùa Một Cột',
 N'19 Ngọc Hà, Ba Đình, Hà Nội',
 21.035617, 105.832629,
 N'Bảo tàng',
 N'Thứ Ba, Tư, Năm, Bảy, Chủ nhật: 8:00 – 12:00 và 14:00 – 16:30. Đóng cửa thứ Hai và thứ Sáu.',
 N'Miễn phí với công dân Việt Nam; khách nước ngoài 40.000đ.',
 80,
 N'8:00 – 12:00, 14:00 – 16:30 (nghỉ T2, T6)',
 N'Miễn phí (khách VN)',
 N'1,5 – 2 giờ',
 N'Buổi sáng, kết hợp viếng Lăng Bác rồi đi bộ sang bảo tàng.',
 N'Trang phục lịch sự, không mặc quần short, áo hở vai|Gửi ba lô, túi lớn tại quầy gửi đồ|Thứ Hai và thứ Sáu bảo tàng đóng cửa|Đi bộ khoảng 5 phút từ Lăng Bác',
 N'Thành lập | 25/11/1970
Khởi công tòa nhà | 31/8/1985
Khánh thành | 19/5/1990 (100 năm Ngày sinh Bác)
Địa chỉ | 19 Ngọc Hà, Ba Đình',
 N'1970 | Thành lập Bảo tàng Hồ Chí Minh (25/11)
1985 | Khởi công xây dựng tòa nhà bảo tàng (31/8)
1990 | Khánh thành nhân 100 năm Ngày sinh Chủ tịch Hồ Chí Minh (19/5)'),
(N'Khu di tích Phủ Chủ tịch',
 N'Nơi Chủ tịch Hồ Chí Minh sống và làm việc từ cuối năm 1954 đến năm 1969, gồm tòa Phủ Chủ tịch màu vàng, nhà sàn gỗ, ao cá, vườn cây và gara ô tô giản dị.',
 N'Tòa nhà chính do người Pháp xây đầu thế kỷ XX làm Phủ Toàn quyền Đông Dương. Cuối năm 1954, khi về Thủ đô, Chủ tịch Hồ Chí Minh không ở trong tòa nhà lớn mà chọn ngôi nhà nhỏ của người thợ điện (Nhà 54). Từ tháng 5/1958, Người chuyển sang ngôi nhà sàn gỗ bên ao cá, sống và làm việc tại đây đến những ngày cuối đời (1969). Khu di tích được xếp hạng di tích quốc gia đặc biệt năm 2009.',
 N'Nhà sàn gỗ hai tầng nơi Bác sống và làm việc 1958 – 1969|Ao cá Bác Hồ và vườn cây quanh ao|Tòa Phủ Chủ tịch kiến trúc Pháp màu vàng (ngắm từ bên ngoài)|Gara trưng bày những chiếc ô tô Bác từng dùng',
 N'Phủ Chủ tịch, Ba Đình, Hà Nội (lối vào cạnh Lăng Bác)',
 21.038171, 105.833152,
 N'Di tích',
 N'Mùa hè (1/4 – 31/10): 7:30 – 11:00 và 13:30 – 16:00. Mùa đông (1/11 – 31/3): 8:00 – 11:00 và 13:30 – 16:00. Đóng cửa chiều thứ Hai và chiều thứ Sáu.',
 N'Miễn phí với công dân Việt Nam; khách nước ngoài 40.000đ.',
 84,
 N'7:30 – 11:00, 13:30 – 16:00 (đông mở 8:00)',
 N'Miễn phí (khách VN)',
 N'1 – 1,5 giờ',
 N'Buổi sáng, ngay sau khi viếng Lăng Bác.',
 N'Trang phục lịch sự, che vai và đầu gối|Chiều thứ Hai và chiều thứ Sáu không mở cửa|Đi theo lối tham quan một chiều, không vào khu có biển cấm|Khách nước ngoài mua vé tại cổng vào khu di tích',
 N'Tên đầy đủ | Khu Di tích Chủ tịch Hồ Chí Minh tại Phủ Chủ tịch
Thời gian Bác sống, làm việc | 1954 – 1969
Nhà sàn | Bác ở từ tháng 5/1958
Ao cá | Rộng khoảng 3.300 m²
Xếp hạng | Di tích quốc gia đặc biệt (2009)',
 N'1954 | Chủ tịch Hồ Chí Minh về sống và làm việc tại khu Phủ Chủ tịch (Nhà 54)
1958 | Bác chuyển sang ở nhà sàn gỗ bên ao cá (tháng 5)
2009 | Xếp hạng di tích quốc gia đặc biệt'),
(N'Phố sách Đinh Lễ',
 N'Con phố ngắn sát Hồ Gươm nổi tiếng với các hiệu sách cũ và mới, sách ngoại văn, sách hiếm – địa chỉ quen thuộc của người mê sách Hà Nội.',
 N'Phố mang tên Đinh Lễ, danh tướng của nghĩa quân Lam Sơn từng cùng Nguyễn Xí lập công trong trận Tốt Động – Chúc Động (1426). Thời Pháp phố có tên Rue Fourès; sau năm 1945 đổi tên Tô Hiến Thành, rồi mang tên Đinh Lễ như ngày nay. Từ cuối thế kỷ XX, các hiệu sách mọc lên dọc phố cùng phố Nguyễn Xí, Tràng Tiền, tạo thành khu bán sách sầm uất bậc nhất Hà Nội; hiệu sách trên gác hai số 5 Đinh Lễ là địa chỉ quen thuộc của nhiều thế hệ.',
 N'Hiệu sách cũ trên gác hai số 5 Đinh Lễ với hàng vạn đầu sách|Sách ngoại văn, sách hiếm, sách cũ giá mềm|Tô tượng, cà phê sách ngay trên phố|Vài phút đi bộ ra Hồ Gươm, phố Tràng Tiền',
 N'Phố Đinh Lễ, Hoàn Kiếm, Hà Nội',
 21.025741, 105.854355,
 N'Văn hóa',
 N'Các hiệu sách thường mở khoảng 8:00 – 21:00, tùy cửa hàng.',
 N'Miễn phí vào xem; giá sách tùy đầu sách.',
 62,
 N'Khoảng 8:00 – 21:00',
 N'Miễn phí',
 N'30 – 60 phút',
 N'Sáng hoặc chiều ngày thường để chọn sách thong thả; cuối tuần đông vui hơn.',
 N'Đọc tên sách cần tìm cho chủ hiệu – họ thuộc kho sách rất nhanh|Hỏi trước khi chụp ảnh bên trong hiệu sách|Có thể trả giá nhẹ nhàng với sách cũ|Kết hợp Phố sách 19/12 và phố đi bộ Hồ Gươm cuối tuần',
 N'Tên phố | Danh tướng Lam Sơn Đinh Lễ (thế kỷ XV)
Tên thời Pháp | Rue Fourès
Vị trí | Sát Hồ Gươm, cắt ngang phố Nguyễn Xí
Hiệu sách tiêu biểu | Gác hai số 5 Đinh Lễ (khoảng 200 m²)',
 N'1426 | Đinh Lễ cùng Nguyễn Xí lập công trong trận Tốt Động – Chúc Động
Thời Pháp | Phố mang tên Rue Fourès
Sau 1945 | Phố đổi tên Tô Hiến Thành, rồi mang tên Đinh Lễ
Cuối thế kỷ XX | Các hiệu sách mọc lên, hình thành phố sách'),
(N'Hồ Trúc Bạch',
 N'Hồ nước rộng khoảng 22 ha nằm sát Hồ Tây, ngăn cách bởi đường Thanh Niên; mặt hồ yên ả với đạp vịt, cà phê ven hồ, đền Thủy Trung Tiên và bán đảo Ngũ Xã.',
 N'Trúc Bạch vốn là một phần của Hồ Tây. Năm 1620, dân các làng ven hồ đắp đê Cổ Ngư để đánh bắt cá, tách phần hồ phía đông thành hồ Trúc Bạch; đê Cổ Ngư nay là đường Thanh Niên. Thế kỷ XVIII, chúa Trịnh Giang dựng phủ Trúc Lâm bên hồ, sau thành nơi giam các cung nữ phạm tội; họ dệt thứ lụa nổi tiếng gọi là lụa Trúc Bạch, từ đó hồ mang tên này. Năm 1967, máy bay của phi công Mỹ John McCain bị bắn rơi xuống hồ; bên hồ có phù điêu ghi lại sự kiện.',
 N'Đạp vịt trên hồ lúc hoàng hôn|Đền Thủy Trung Tiên trên đảo nhỏ Châu Chử|Bán đảo Ngũ Xã – làng đúc đồng nổi tiếng|Phù điêu ghi dấu sự kiện bắn rơi máy bay của John McCain (1967)|Đường Thanh Niên rợp bóng cây giữa hai hồ',
 N'Phố Trúc Bạch, Ba Đình, Hà Nội',
 21.045500, 105.842000,
 N'Danh thắng',
 N'Khu vực công cộng, mở cửa cả ngày.',
 N'Miễn phí; đạp vịt tính phí theo giờ.',
 72,
 N'Cả ngày',
 N'Miễn phí',
 N'1 – 2 giờ',
 N'Chiều muộn đến tối, khi mặt hồ lặng và đèn ven hồ bật sáng.',
 N'Hỏi giá đạp vịt trước khi lên thuyền|Đi bộ một vòng hồ khoảng 1,8 km|Kết hợp Hồ Tây, chùa Trấn Quốc, đền Quán Thánh ngay gần|Cuối tuần ven hồ khá đông, nên đi chiều ngày thường',
 N'Diện tích | Khoảng 22 ha
Chu vi | Hơn 1,8 km
Tách khỏi Hồ Tây | Năm 1620 (đắp đê Cổ Ngư)
Đảo, bán đảo | Châu Chử, Ngũ Xã',
 N'1620 | Dân làng đắp đê Cổ Ngư, tách hồ Trúc Bạch khỏi Hồ Tây
Thế kỷ XVIII | Chúa Trịnh Giang dựng phủ Trúc Lâm bên hồ; lụa Trúc Bạch ra đời
1967 | Máy bay của phi công Mỹ John McCain bị bắn rơi xuống hồ'),
(N'Công viên Thống Nhất',
 N'Công viên lớn nhất nội đô Hà Nội, rộng khoảng 50 ha bao quanh hồ Bảy Mẫu – lá phổi xanh để đi dạo, tập thể dục và vui chơi cuối tuần; từ cuối năm 2022 là công viên mở, vào cửa miễn phí.',
 N'Công viên được xây dựng từ năm 1958 bằng những ngày công lao động tình nguyện của người dân Thủ đô trên vùng đất trũng quanh hồ Bảy Mẫu, mang tên Thống Nhất thể hiện khát vọng thống nhất đất nước. Trên đảo giữa hồ có tượng đài Chủ tịch Hồ Chí Minh và Chủ tịch Tôn Đức Thắng. Cuối tháng 12/2022, khoảng 400 m hàng rào được tháo dỡ để công viên trở thành không gian mở, miễn phí cho người dân.',
 N'Hồ Bảy Mẫu giữa công viên với những cây cầu cong|Tượng đài Bác Hồ – Bác Tôn trên đảo Thống Nhất|Tàu hỏa mini, khu vui chơi thiếu nhi|Đường dạo rợp bóng cây, sân chơi đá cầu, cầu lông',
 N'354A Lê Duẩn, Hai Bà Trưng, Hà Nội',
 21.014200, 105.842000,
 N'Công viên',
 N'Công viên mở, phục vụ khoảng 5:00 – 22:00 hằng ngày.',
 N'Miễn phí vào cửa; trò chơi, đạp vịt tính phí riêng.',
 70,
 N'Khoảng 5:00 – 22:00',
 N'Miễn phí',
 N'1 – 2 giờ',
 N'Sáng sớm hoặc chiều mát; cuối tuần có nhiều hoạt động biểu diễn.',
 N'Mang theo nước và mũ vào mùa hè|Trò chơi trẻ em tính phí riêng|Kết hợp đi bộ quanh hồ Thiền Quang ngay cạnh|Nhiều cổng vào: Lê Duẩn, Trần Nhân Tông, Đại Cồ Việt',
 N'Diện tích | Khoảng 50 ha
Xây dựng | Năm 1958 (lao động tình nguyện)
Hồ chính | Hồ Bảy Mẫu
Mô hình | Công viên mở, miễn phí từ 12/2022',
 N'1958 | Người dân Thủ đô lao động tình nguyện xây dựng công viên
2022 | Tháo dỡ khoảng 400 m hàng rào, chuyển sang công viên mở, miễn phí'),
(N'Công viên Thủ Lệ',
 N'Vườn thú Hà Nội – công viên rộng khoảng 28 ha quanh hồ Thủ Lệ, nơi trẻ em được ngắm hổ, voi, hươu, khỉ, cá sấu, chim và chơi các trò chơi ngoài trời.',
 N'Công viên được khởi công ngày 19/5/1975 trên khu đất quanh hồ Thủ Lệ. Ngày 6/8/1976, Vườn thú Hà Nội được thành lập khi các chuồng thú được chuyển từ vườn Bách Thảo về đây. Vườn thú còn lưu giữ những con vật gắn với lịch sử như đàn sếu được tặng Bác Hồ. Năm 2026, Vườn thú Hà Nội kỷ niệm 50 năm thành lập.',
 N'Vườn thú với hổ, voi, hươu, khỉ, cá sấu và nhiều loài chim|Cho hươu ăn, đạp vịt trên hồ Thủ Lệ|Khu trò chơi thiếu nhi: tàu lượn, đu quay, cầu trượt|Vườn hoa, bãi cỏ rộng cho cả gia đình',
 N'Đường Bưởi, Thủ Lệ, Ba Đình, Hà Nội',
 21.031200, 105.803000,
 N'Công viên',
 N'Khoảng 7:00 – 18:00 hằng ngày.',
 N'Người lớn 50.000đ, trẻ em 30.000đ; trò chơi tính phí riêng.',
 74,
 N'7:00 – 18:00',
 N'Từ 30.000đ',
 N'2 – 3 giờ',
 N'Buổi sáng, khi trời mát và các con vật hoạt động nhiều.',
 N'Không cho thú ăn đồ mang từ ngoài vào|Đi giày thoải mái vì khuôn viên rộng|Ga Metro Cầu Giấy (tuyến 3) cách vài phút đi bộ|Cuối tuần, ngày lễ rất đông trẻ em',
 N'Tên khác | Vườn thú Hà Nội
Diện tích | Khoảng 28 ha (hồ khoảng 6 ha)
Khởi công | 19/5/1975
Thành lập Vườn thú | 6/8/1976',
 N'1975 | Khởi công xây dựng công viên (19/5)
1976 | Thành lập Vườn thú Hà Nội, chuyển chuồng thú từ vườn Bách Thảo về (6/8)
2026 | Kỷ niệm 50 năm thành lập Vườn thú Hà Nội'),
(N'Bảo tàng Thiên nhiên Việt Nam',
 N'Bảo tàng khoa học tự nhiên quốc gia với hàng chục nghìn mẫu vật động – thực vật, hóa thạch; nổi bật là khu tiến hóa sự sống và mẫu xương khủng long, rất hợp cho trẻ em và học sinh.',
 N'Ý tưởng xây dựng một bảo tàng thiên nhiên cấp quốc gia được Thủ tướng Phạm Văn Đồng nêu từ năm 1980. Tháng 3/2006, Bảo tàng Thiên nhiên Việt Nam chính thức thành lập, trực thuộc Viện Hàn lâm Khoa học và Công nghệ Việt Nam; khu trưng bày đặt tại nhà A20 trong khuôn viên viện ở số 18 Hoàng Quốc Việt. Năm 2026, bảo tàng kỷ niệm 20 năm thành lập.',
 N'Mẫu xương khủng long và mô hình sinh vật tiền sử|Khu tiến hóa sự sống và tiến hóa loài người|Tiêu bản côn trùng, bò sát, sinh vật biển, nấm và thực vật|Hoạt động trải nghiệm cho học sinh: làm tiêu bản, mô hình',
 N'Nhà A20, 18 Hoàng Quốc Việt, Cầu Giấy, Hà Nội',
 21.048073, 105.800537,
 N'Bảo tàng',
 N'Thứ Ba – Chủ nhật: 8:30 – 11:30 và 13:30 – 16:30. Đóng cửa thứ Hai và các ngày lễ.',
 N'Miễn phí.',
 66,
 N'8:30 – 11:30, 13:30 – 16:30 (nghỉ T2)',
 N'Miễn phí',
 N'1 – 1,5 giờ',
 N'Sáng ngày thường khi vắng đoàn học sinh; cuối tuần đông gia đình.',
 N'Vào cổng số 2 (số 18 Hoàng Quốc Việt), bảo tàng ở nhà A20 bên trong|Thứ Hai đóng cửa|Đi theo đoàn đông nên liên hệ trước|Phù hợp trẻ từ 4 – 5 tuổi trở lên',
 N'Thành lập | Tháng 3/2006
Trực thuộc | Viện Hàn lâm Khoa học và Công nghệ Việt Nam
Mẫu vật | Khoảng 40.000 mẫu
Mẫu nổi bật | Xương khủng long Velociraptor',
 N'1980 | Thủ tướng Phạm Văn Đồng nêu ý tưởng xây dựng bảo tàng thiên nhiên quốc gia
2006 | Bảo tàng Thiên nhiên Việt Nam chính thức thành lập (tháng 3)
2026 | Kỷ niệm 20 năm thành lập'),
(N'Công viên nước Hồ Tây',
 N'Công viên nước ngoài trời bên bờ Hồ Tây với bể tạo sóng, sông lười, nhiều đường trượt và khu nước cho trẻ em – điểm giải nhiệt quen thuộc của Hà Nội mỗi mùa hè.',
 N'Công viên nằm trên đường Lạc Long Quân, ven bờ bắc Hồ Tây, gồm khu vui chơi dưới nước và khu vui chơi khô có vòng quay lớn. Công viên nước chỉ mở theo mùa hè, thường từ khoảng tháng 4 đến cuối tháng 9: mùa hè năm 2018 mở cửa từ ngày 21/4; năm 2021 mở cửa trở lại cũng vào ngày 21/4 sau thời gian tạm đóng vì dịch COVID-19.',
 N'Bể tạo sóng và sông lười thả phao|Đường trượt cảm giác mạnh và đường trượt nhỏ cho trẻ em|Khu vui chơi khô với vòng quay, nhà hơi|Ngay cạnh Lotte Mall Tây Hồ',
 N'614 Lạc Long Quân, Tây Hồ, Hà Nội',
 21.075700, 105.816600,
 N'Vui chơi',
 N'Mở theo mùa hè (khoảng tháng 4 – tháng 9). Thứ Hai – thứ Sáu: 9:00 – 17:00; thứ Bảy, Chủ nhật: 9:00 – 19:30.',
 N'Theo chiều cao: trên 1,35 m khoảng 180.000 – 195.000đ; 0,9 – 1,35 m khoảng 150.000 – 170.000đ; dưới 0,9 m miễn phí; sau 17:00 khoảng 120.000đ.',
 70,
 N'9:00 – 17:00 (cuối tuần đến 19:30), mùa hè',
 N'Từ ~120.000đ',
 N'Nửa ngày',
 N'Sáng ngày thường đầu mùa hè, khi chưa quá đông.',
 N'Chỉ mở mùa hè, kiểm tra lịch trước khi đi|Mang đồ bơi, kem chống nắng, khăn|Tuân thủ quy định chiều cao ở từng đường trượt|Sau 17:00 giá vé rẻ hơn',
 N'Mùa hoạt động | Khoảng tháng 4 – tháng 9
Địa chỉ | 614 Lạc Long Quân, Tây Hồ
Giá vé | Theo chiều cao, dưới 0,9 m miễn phí
Khu trò chơi | Bể tạo sóng, sông lười, đường trượt, khu khô',
 N'2018 | Mở cửa mùa hè từ ngày 21/4
2021 | Mở cửa trở lại ngày 21/4 sau thời gian tạm đóng vì dịch COVID-19'),
(N'Thủy cung Times City',
 N'Thủy cung trong nhà rộng khoảng 4.000 m² dưới tầng hầm Times City với hơn 30.000 sinh vật, đường hầm kính, chim cánh cụt và show nàng tiên cá – điểm vui chơi trong nhà rất được trẻ em yêu thích.',
 N'Thủy cung Vinpearl Aquarium khai trương ngày 24/12/2013 cùng Trung tâm thương mại Vincom Mega Mall Times City, khi đó là thủy cung lớn nhất Việt Nam và là thủy cung có đường hầm đầu tiên ở Hà Nội. Nhiều loài lần đầu xuất hiện tại Việt Nam như chim cánh cụt, cua nhện khổng lồ; chú chim cánh cụt đầu tiên được sinh ra ở Việt Nam cũng chào đời tại đây.',
 N'Đường hầm kính đi dưới bể cá lớn|Chim cánh cụt trong khu băng giá|Show nàng tiên cá và giờ cho cá ăn|Hang động bò sát, khu rừng nhiệt đới|Khu vui chơi hướng nghiệp VinKE ngay bên cạnh',
 N'Tầng B1 Vincom Mega Mall Times City, 458 Minh Khai, Hai Bà Trưng, Hà Nội',
 20.996372, 105.867893,
 N'Vui chơi',
 N'Thứ Hai – thứ Sáu: 10:00 – 22:00; thứ Bảy, Chủ nhật, ngày lễ: 9:30 – 22:00.',
 N'Khoảng 160.000 – 270.000đ/người tùy đối tượng và ngày; có combo cùng VinKE.',
 78,
 N'10:00 – 22:00 (cuối tuần từ 9:30)',
 N'Từ ~160.000đ',
 N'1,5 – 2 giờ',
 N'Sáng ngày thường; xem lịch show nàng tiên cá để đến đúng giờ.',
 N'Mua vé online thường rẻ hơn mua tại quầy|Xem giờ show trước khi đi|Không dùng đèn flash khi chụp sinh vật|Gửi xe trong hầm Times City',
 N'Diện tích | Khoảng 4.000 m²
Sinh vật | Hơn 30.000 cá thể
Khai trương | 24/12/2013
Vị trí | Tầng B1 Vincom Mega Mall Times City',
 N'2013 | Khai trương cùng Vincom Mega Mall Times City (24/12), là thủy cung lớn nhất Việt Nam lúc đó
Sau khai trương | Chú chim cánh cụt đầu tiên sinh ra tại Việt Nam chào đời ở thủy cung'),
(N'Landmark 72 – Đài quan sát Sky72',
 N'Tòa tháp 72 tầng từng là tòa nhà cao nhất Việt Nam (2011 – 2018); đài quan sát Sky72 ở tầng trên cùng cho tầm nhìn toàn cảnh Hà Nội, đẹp nhất lúc hoàng hôn.',
 N'Keangnam Hanoi Landmark Tower (nay là Landmark 72) do tập đoàn Keangnam (Hàn Quốc) đầu tư, hoàn thành năm 2011 và giữ danh hiệu tòa nhà cao nhất Việt Nam đến năm 2018, khi Landmark 81 ở TP. Hồ Chí Minh vượt qua. Tổ hợp gồm tòa tháp 72 tầng, hai tòa căn hộ và khối đế trung tâm thương mại, tổng diện tích sàn khoảng 609.673 m²; khu Sky72 có đài quan sát, thế giới 3D và rạp phim 5D.',
 N'Toàn cảnh Hà Nội 360° từ tầng 72|Ngắm hoàng hôn rồi xem thành phố lên đèn|Thế giới 3D, rạp chiếu phim 5D trong khu Sky72|Trung tâm thương mại, ẩm thực ở khối đế',
 N'Lô E6 Phạm Hùng, Nam Từ Liêm, Hà Nội',
 21.017220, 105.784170,
 N'Vui chơi',
 N'Khoảng 9:00 – 22:00 hằng ngày (nên kiểm tra trước khi đi).',
 N'Khoảng 100.000 – 240.000đ/người tùy gói; trẻ dưới 0,8 m miễn phí.',
 72,
 N'Khoảng 9:00 – 22:00',
 N'Từ ~100.000đ',
 N'1 – 1,5 giờ',
 N'Chiều muộn để xem hoàng hôn rồi ngắm thành phố lên đèn.',
 N'Chọn ngày trời quang để nhìn được xa|Kiểm tra giờ mở cửa đài quan sát trước khi đi|Tối cuối tuần thường phải xếp hàng|Có xe buýt chạy qua đường Phạm Hùng',
 N'Số tầng | 72
Chiều cao | 328,6 m (theo CTBUH)
Cao nhất Việt Nam | 2011 – 2018
Tổng diện tích sàn | Khoảng 609.673 m²',
 N'2011 | Hoàn thành, trở thành tòa nhà cao nhất Việt Nam
2018 | Landmark 81 (TP. Hồ Chí Minh) vượt qua về chiều cao'),
(N'Lotte Mall Tây Hồ',
 N'Tổ hợp thương mại lớn gần Hồ Tây (Lotte Mall West Lake Hanoi) với 7 tầng mua sắm, ẩm thực, rạp chiếu phim và thủy cung Lotte World Aquarium rộng khoảng 9.000 m².',
 N'Tập đoàn Lotte (Hàn Quốc) nhận bàn giao đất năm 2016, mở cửa thử từ ngày 28/7/2023 và khai trương chính thức ngày 22/9/2023 với tổng vốn đầu tư hơn 600 triệu USD. Tổ hợp có tổng diện tích sàn khoảng 354.000 m², gồm trung tâm thương mại 5 tầng nổi và 2 tầng hầm, khách sạn L7, thủy cung Lotte World Aquarium và rạp chiếu phim.',
 N'Thủy cung Lotte World Aquarium với hơn 30.000 sinh vật biển|Siêu thị, khu ẩm thực và hàng trăm cửa hàng|Rạp chiếu phim Lotte Cinema|Sân ngoài trời tầng trên nhìn về phía Hồ Tây',
 N'272 Võ Chí Công, Tây Hồ, Hà Nội',
 21.076019, 105.812550,
 N'Mua sắm',
 N'9:30 – 22:00 hằng ngày.',
 N'Miễn phí vào cửa; thủy cung khoảng 190.000 – 350.000đ (khách Việt Nam).',
 80,
 N'9:30 – 22:00',
 N'Miễn phí',
 N'2 – 4 giờ',
 N'Ngày thường để tránh đông; tối cuối tuần rất nhộn nhịp.',
 N'Thủy cung nhận khách lần cuối khoảng 21:00|Cuối tuần bãi gửi xe khá đông|Mùa hè kết hợp Công viên nước Hồ Tây ngay gần|Xe buýt dừng trên đường Lạc Long Quân, Võ Chí Công',
 N'Khai trương | 22/9/2023
Tổng diện tích sàn | Khoảng 354.000 m²
Vốn đầu tư | Hơn 600 triệu USD
Thủy cung | Khoảng 9.000 m², hơn 30.000 sinh vật',
 N'2016 | Lotte nhận bàn giao đất dự án
2023 | Mở cửa thử (28/7) và khai trương chính thức (22/9)'),
(N'Vincom Center Bà Triệu',
 N'Trung tâm thương mại đầu tiên của hệ thống Vincom, giữa trung tâm Hà Nội, với khu mua sắm, ẩm thực, rạp chiếu phim và khu vui chơi trẻ em.',
 N'Tòa tháp đôi Vincom City Towers tại 191 Bà Triệu ra mắt ngày 23/11/2004, là trung tâm thương mại đầu tiên mang thương hiệu Vincom và từng là một trong những tòa nhà hiện đại nhất Hà Nội đầu những năm 2000. Từ đây, Vincom phát triển thành chuỗi gần 90 trung tâm thương mại trên cả nước.',
 N'Hàng trăm cửa hàng thời trang, mỹ phẩm, ẩm thực|Rạp chiếu phim CGV|Khu vui chơi trẻ em trong nhà|Cầu đi bộ trên cao nối các tòa tháp',
 N'191 Bà Triệu, Hai Bà Trưng, Hà Nội',
 21.011189, 105.849470,
 N'Mua sắm',
 N'Thứ Hai – thứ Sáu: 10:00 – 22:00; thứ Bảy, Chủ nhật: 9:30 – 22:00.',
 N'Miễn phí vào cửa.',
 68,
 N'10:00 – 22:00 (cuối tuần từ 9:30)',
 N'Miễn phí',
 N'1 – 3 giờ',
 N'Chiều tối các ngày trong tuần; cuối tuần đông hơn.',
 N'Trạm xe buýt ngay trước tòa nhà trên phố Bà Triệu|Gửi xe máy dưới tầng hầm|Kết hợp dạo Công viên Thống Nhất cách khoảng 1 km|Khu vui chơi trẻ em tính phí riêng',
 N'Khai trương | 23/11/2004
Tên cũ | Vincom City Towers
Ý nghĩa | Trung tâm thương mại Vincom đầu tiên
Địa chỉ | 191 Bà Triệu, Hai Bà Trưng',
 N'2004 | Tòa tháp đôi Vincom City Towers khai trương (23/11)
2024 | Hệ thống Vincom tròn 20 năm với 88 trung tâm thương mại'),
(N'Vincom Mega Mall Royal City',
 N'Trung tâm thương mại ngầm rộng khoảng 230.000 m² dưới khu đô thị Royal City, nổi tiếng với sân trượt băng trong nhà, khu vui chơi trẻ em, rạp chiếu phim và hàng trăm cửa hàng.',
 N'Vincom Mega Mall Royal City khai trương ngày 26/7/2013, là quần thể thương mại – giải trí đầu tiên ở Việt Nam phát triển theo mô hình mega mall và được giới thiệu là trung tâm thương mại ngầm lớn nhất Đông Nam Á lúc bấy giờ. Khu mua sắm trải trên hai tầng hầm B1, B2, nối liền sáu tòa căn hộ R1 – R6; sân trượt băng rộng khoảng 3.000 m² từng là sân băng trong nhà lớn nhất Việt Nam.',
 N'Sân trượt băng trong nhà Vincom Ice Rink|Khu vui chơi trẻ em, trò chơi điện tử|Cổng vòm và quảng trường kiến trúc tân cổ điển|Rạp chiếu phim, khu ẩm thực dưới tầng hầm',
 N'72A Nguyễn Trãi, Thanh Xuân, Hà Nội',
 21.003500, 105.815000,
 N'Mua sắm',
 N'Khoảng 9:30 – 22:00 hằng ngày.',
 N'Miễn phí vào cửa; trượt băng, trò chơi tính phí riêng.',
 74,
 N'9:30 – 22:00',
 N'Miễn phí',
 N'2 – 3 giờ',
 N'Ngày thường; mùa hè trượt băng là cách giải nhiệt được trẻ em yêu thích.',
 N'Mang tất dày, áo khoác mỏng khi trượt băng|Khu mua sắm ở tầng hầm B1, B2 – xem sơ đồ để khỏi lạc|Bãi gửi xe dưới hầm rất rộng|Cuối tuần, dịp lễ rất đông',
 N'Khai trương | 26/7/2013
Diện tích | Khoảng 230.000 m² (2 tầng hầm)
Sân trượt băng | Khoảng 3.000 m²
Mô hình | Mega mall đầu tiên tại Việt Nam',
 N'2012 | Vingroup giới thiệu dự án Vincom Mega Mall Royal City
2013 | Khai trương (26/7) cùng sân băng trong nhà lớn nhất Việt Nam lúc bấy giờ')
) v(Name, Description, History, Highlights, Address, Latitude, Longitude, Category, OpeningHours, TicketPrice, PopularityScore,
     HoursSummary, PriceFrom, VisitDuration, BestTime, Tips, Facts, Timeline)
WHERE NOT EXISTS (SELECT 1 FROM TouristAttractions a WHERE a.Name = v.Name);
GO
/* ---- 2. Anh dai dien + bo suu tap (Wikimedia Commons) ---- */
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/21-nha-tho-lon-ha-noi.jpg', ImageCredit = N'Ảnh: John Ragai / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:St._Joseph%27s_Cathedral_-_50129345872.jpg' WHERE Name = N'Nhà thờ Lớn Hà Nội' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/21-nha-tho-lon-ha-noi.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/22-bao-tang-ho-chi-minh.jpg', ImageCredit = N'Ảnh: Daderot / CC0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Ho_Chi_Minh_Museum_-_Hanoi,_Vietnam_-_DSC03496.JPG' WHERE Name = N'Bảo tàng Hồ Chí Minh' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/22-bao-tang-ho-chi-minh.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/23-khu-di-tich-phu-chu-tich.jpg', ImageCredit = N'Ảnh: Richard Mortel from Riyadh, Saudi Arabia / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Presidential_Palace,_Hanoi,_1906_(1)_(37781935604).jpg' WHERE Name = N'Khu di tích Phủ Chủ tịch' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/23-khu-di-tich-phu-chu-tich.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/25-ho-truc-bach.jpg', ImageCredit = N'Ảnh: Takeshi Aida from Hong Kong, Hong Kong / CC BY-SA 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Tr%C3%BAc_B%E1%BA%A1ch_Lake_(20231225e)_(53489228064).jpg' WHERE Name = N'Hồ Trúc Bạch' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/25-ho-truc-bach.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/26-cong-vien-thong-nhat.jpg', ImageCredit = N'Ảnh: Trung geo / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Thong_Nhat_Park_Sep_2023.jpg' WHERE Name = N'Công viên Thống Nhất' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/26-cong-vien-thong-nhat.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/27-cong-vien-thu-le.jpg', ImageCredit = N'Ảnh: Nguyễn Thanh Quang / CC BY-SA 3.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:C%C3%B4ng_vi%C3%AAn_Th%E1%BB%A7_L%E1%BB%87.JPG' WHERE Name = N'Công viên Thủ Lệ' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/27-cong-vien-thu-le.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/29-cong-vien-nuoc-ho-tay.jpg', ImageCredit = N'Ảnh: cloud.shepherd / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Hanoi_Westlake_(28221300606).jpg' WHERE Name = N'Công viên nước Hồ Tây' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/29-cong-vien-nuoc-ho-tay.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/31-landmark-72-sky72.jpg', ImageCredit = N'Ảnh: Phan Minh Tuấn / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:T%C3%B2a_nh%C3%A0_Keangnam,_C%E1%BA%A7u_Gi%E1%BA%A5y,_H%C3%A0_N%E1%BB%99i_001.jpg' WHERE Name = N'Landmark 72 – Đài quan sát Sky72' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/31-landmark-72-sky72.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/33-vincom-center-ba-trieu.jpg', ImageCredit = N'Ảnh: Phan Minh Tuấn / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Vincom_B%C3%A0_Tri%E1%BB%87u,_H%C3%A0_N%E1%BB%99i_001.JPG' WHERE Name = N'Vincom Center Bà Triệu' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/33-vincom-center-ba-trieu.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/34-vincom-mega-mall-royal-city.jpg', ImageCredit = N'Ảnh: Quenhitran / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Royal_City_on_Nguy%E1%BB%85n_Tr%C3%A3i_Road_(20140804_174513).jpg' WHERE Name = N'Vincom Mega Mall Royal City' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/34-vincom-mega-mall-royal-city.jpg');
GO
INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
SELECT a.AttractionId, v.ImageUrl, v.Caption, v.Credit, v.SourceUrl, v.SortOrder
FROM (VALUES
(N'Nhà thờ Lớn Hà Nội', '/images/attractions/gallery/21-nha-tho-lon-ha-noi-1.jpg', N'Nhà thờ Lớn lên đèn về đêm', N'lumoplank / CC0', 'https://commons.wikimedia.org/wiki/File:Hanoi_-_Hanoi1612.jpg', 1),
(N'Nhà thờ Lớn Hà Nội', '/images/attractions/gallery/21-nha-tho-lon-ha-noi-2.jpg', N'Đồng hồ và tượng thánh trên mặt tiền', N'Gary Todd from Xinzheng, China / CC0', 'https://commons.wikimedia.org/wiki/File:St._Joseph_Cathedral_(9753936465).jpg', 2),
(N'Nhà thờ Lớn Hà Nội', '/images/attractions/gallery/21-nha-tho-lon-ha-noi-3.jpg', N'Thân nhà thờ nhìn từ phía bên', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:St._Joseph%27s_Cathedral_Hanoi_3.jpg', 3),
(N'Nhà thờ Lớn Hà Nội', '/images/attractions/gallery/21-nha-tho-lon-ha-noi-4.jpg', N'Biển phố Nhà Chung trước nhà thờ', N'Nam-ho Park / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Nha_Chung_street_signs.jpg', 4),
(N'Nhà thờ Lớn Hà Nội', '/images/attractions/gallery/21-nha-tho-lon-ha-noi-5.jpg', N'Bức phù điêu phía sau nhà thờ', N'kitmasterbloke / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Bas-relief_behind_St_Joseph_Cathedral,_Hanoi,_Vietnam_-_54567955567.jpg', 5),
(N'Bảo tàng Hồ Chí Minh', '/images/attractions/gallery/22-bao-tang-ho-chi-minh-1.jpg', N'Bảo tàng giữa khuôn viên cây xanh', N'Adam Jones Adam63 / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Ho_Chi_Minh_Museum_-_Hanoi_-_Vietnam_-_01.JPG', 1),
(N'Bảo tàng Hồ Chí Minh', '/images/attractions/gallery/22-bao-tang-ho-chi-minh-2.jpg', N'Hoa văn bông sen trên lối vào bảo tàng', N'CEphoto, Uwe Aranas / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_Vietnam_Ho-Chi-Minh-Museum-01.jpg', 2),
(N'Bảo tàng Hồ Chí Minh', '/images/attractions/gallery/22-bao-tang-ho-chi-minh-3.jpg', N'Không gian trưng bày bên trong bảo tàng', N'Vyacheslav Argenberg / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi,_Vietnam,_Interiors_of_Ho_Chi_Minh_Museum.jpg', 3),
(N'Bảo tàng Hồ Chí Minh', '/images/attractions/gallery/22-bao-tang-ho-chi-minh-4.jpg', N'Tác phẩm sắp đặt hình kim tự tháp', N'Vyacheslav Argenberg / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi,_Vietnam,_Ho_Chi_Minh_Museum,_The_Pyramid.jpg', 4),
(N'Bảo tàng Hồ Chí Minh', '/images/attractions/gallery/22-bao-tang-ho-chi-minh-5.jpg', N'Khách tham quan trong phòng trưng bày', N'Vyacheslav Argenberg / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi,_Vietnam,_Visitors_at_Ho_Chi_Minh_Museum.jpg', 5),
(N'Khu di tích Phủ Chủ tịch', '/images/attractions/gallery/23-khu-di-tich-phu-chu-tich-1.jpg', N'Nhà sàn Bác Hồ giữa vườn cây', N'shankar s. from Dubai, united arab emirates / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Ho_Chi_Minh%27s_famous_%27house_on_stilts%27_(30645978723).jpg', 1),
(N'Khu di tích Phủ Chủ tịch', '/images/attractions/gallery/23-khu-di-tich-phu-chu-tich-2.jpg', N'Nhà sàn nhìn qua ao cá', N'Dennis G. Jarvis / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Cottage_of_Ho_Chi_Minh_3.jpg', 2),
(N'Khu di tích Phủ Chủ tịch', '/images/attractions/gallery/23-khu-di-tich-phu-chu-tich-3.jpg', N'Phòng làm việc giản dị trên nhà sàn', N'shankar s. from Dubai, united arab emirates / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Humble_interior_of_Uncle_Ho%27s_wooden_house_(31083384310).jpg', 3),
(N'Khu di tích Phủ Chủ tịch', '/images/attractions/gallery/23-khu-di-tich-phu-chu-tich-4.jpg', N'Chiếc Peugeot 404 Bác Hồ từng dùng', N'Jérémy Toma / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Peugeot_404_H%E1%BB%93_Ch%C3%AD_Minh.jpg', 4),
(N'Khu di tích Phủ Chủ tịch', '/images/attractions/gallery/23-khu-di-tich-phu-chu-tich-5.jpg', N'Cổng sắt Phủ Chủ tịch', N'Bex Walton from London, England / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Presidential_Palace_(26910898382).jpg', 5),
(N'Hồ Trúc Bạch', '/images/attractions/gallery/25-ho-truc-bach-1.jpg', N'Cầu dẫn vào đền Thủy Trung Tiên', N'Takeshi Aida from Hong Kong, Hong Kong / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Tr%C3%BAc_B%E1%BA%A1ch_Lake,_%C4%90%E1%BB%81n_Th%E1%BB%A7y_Trung_Ti%C3%AAn_(20231225)_(53489075483).jpg', 1),
(N'Hồ Trúc Bạch', '/images/attractions/gallery/25-ho-truc-bach-2.jpg', N'Mặt hồ phản chiếu những tòa nhà ven hồ', N'Takeshi Aida from Hong Kong, Hong Kong / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Tr%C3%BAc_B%E1%BA%A1ch_Lake,_Pan_Pacific_Hotel_(20231225)_(53488925426).jpg', 2),
(N'Hồ Trúc Bạch', '/images/attractions/gallery/25-ho-truc-bach-3.jpg', N'Phù điêu ghi dấu sự kiện bắn rơi máy bay của John McCain', N'Ptrump16 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:John_McCain_monument_at_Tr%C3%BAc_B%E1%BA%A1ch_Lake,_Hanoi,_VN_(angled).jpg', 3),
(N'Hồ Trúc Bạch', '/images/attractions/gallery/25-ho-truc-bach-4.jpg', N'Hồ Tây và hồ Trúc Bạch nhìn từ trên cao', N'David Berkowitz / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:H%E1%BB%93_T%C3%A2y_v%C3%A0_H%E1%BB%93_Tr%C3%BAc_B%E1%BA%A1ch.jpg', 4),
(N'Hồ Trúc Bạch', '/images/attractions/gallery/25-ho-truc-bach-5.jpg', N'Hồ Trúc Bạch ngày trời lặng', N'Edgardo W. Olivera from Montevideo, Uruguay / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Lago_Truc_Bach,_Hanoi,_Vietnam_(36623730891).jpg', 5),
(N'Công viên Thống Nhất', '/images/attractions/gallery/26-cong-vien-thong-nhat-1.jpg', N'Cổng công viên trên đường Lê Duẩn', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:C%C3%B4ng_vi%C3%AAn_Th%E1%BB%91ng_Nh%E1%BA%A5t_12-Jun-22_11.jpg', 1),
(N'Công viên Thống Nhất', '/images/attractions/gallery/26-cong-vien-thong-nhat-2.jpg', N'Cầu cong bắc qua hồ Bảy Mẫu', N'Guerinf / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Parc_h%E1%BB%93_B%E1%BA%A3y_M%E1%BA%ABu_(5).jpg', 2),
(N'Công viên Thống Nhất', '/images/attractions/gallery/26-cong-vien-thong-nhat-3.jpg', N'Tàu hỏa mini chạy giữa bãi cỏ', N'Guerinf / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Parc_h%E1%BB%93_B%E1%BA%A3y_M%E1%BA%ABu_(6).jpg', 3),
(N'Công viên Thống Nhất', '/images/attractions/gallery/26-cong-vien-thong-nhat-4.jpg', N'Người dân chơi đá cầu trong công viên', N'dronepicr / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Federfu%C3%9Fball_in_Hanoi,_Vietnam_(25672922098).jpg', 4),
(N'Công viên Thống Nhất', '/images/attractions/gallery/26-cong-vien-thong-nhat-5.jpg', N'Lối dạo rợp bóng cây', N'Martin Lewison from Forest Hills, NY, U.S.A. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Thong_Nhat_Park_(49373941641).jpg', 5),
(N'Công viên Thủ Lệ', '/images/attractions/gallery/27-cong-vien-thu-le-1.jpg', N'Hổ Việt Nam trong vườn thú', N'Phương Huy (thảo luận) / Public domain', 'https://commons.wikimedia.org/wiki/File:H%E1%BB%95_Vi%E1%BB%87t_Nam_%E1%BB%9F_V%C6%B0%E1%BB%9Dn_th%C3%BA_Th%E1%BB%A7_L%E1%BB%87_2017(7).jpg', 1),
(N'Công viên Thủ Lệ', '/images/attractions/gallery/27-cong-vien-thu-le-2.jpg', N'Cừu, dê cỏ và hươu sao', N'Phương Huy (thảo luận) / Public domain', 'https://commons.wikimedia.org/wiki/File:C%E1%BB%ABu_Phan_Rang,_d%C3%AA_c%E1%BB%8F_v%C3%A0_h%C6%B0%C6%A1u_sao_Vi%E1%BB%87t_Nam_%E1%BB%9F_V%C6%B0%E1%BB%9Dn_th%C3%BA_Th%E1%BB%A7_L%E1%BB%87_(22).jpg', 2),
(N'Công viên Thủ Lệ', '/images/attractions/gallery/27-cong-vien-thu-le-3.jpg', N'Đoàn tàu trò chơi cho thiếu nhi', N'Martin Lewison from Forest Hills, NY, U.S.A. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Thu_Le_Park_(49373491268).jpg', 3),
(N'Công viên Thủ Lệ', '/images/attractions/gallery/27-cong-vien-thu-le-4.jpg', N'Tàu lượn siêu tốc trong khu trò chơi', N'Martin Lewison from Forest Hills, NY, U.S.A. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Thu_Le_Park_(49358100207).jpg', 4),
(N'Công viên Thủ Lệ', '/images/attractions/gallery/27-cong-vien-thu-le-5.jpg', N'Vườn hoa trong công viên', N'Martin Lewison from Forest Hills, NY, U.S.A. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Somewhere_in_Thu_Le_Park,_Hanoi_(49356771026).jpg', 5),
(N'Landmark 72 – Đài quan sát Sky72', '/images/attractions/gallery/31-landmark-72-sky72-1.jpg', N'Landmark 72 nhìn từ cầu vượt Mễ Trì', N'NKSTTSSHNVN / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Nam_T%E1%BB%AB_Li%C3%AAm_-_NKS.jpg', 1),
(N'Landmark 72 – Đài quan sát Sky72', '/images/attractions/gallery/31-landmark-72-sky72-2.jpg', N'Lối vào khối đế Landmark 72', N'An Nguyễn Hải / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Landmark_72_-_panoramio.jpg', 2),
(N'Landmark 72 – Đài quan sát Sky72', '/images/attractions/gallery/31-landmark-72-sky72-3.jpg', N'Một góc tổ hợp Keangnam', N'An Nguyễn Hải / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:M%E1%BB%99t_g%C3%B3c_KangNam_-_panoramio.jpg', 3),
(N'Landmark 72 – Đài quan sát Sky72', '/images/attractions/gallery/31-landmark-72-sky72-4.jpg', N'Bể bơi khách sạn nhìn từ trên tòa nhà', N'Soyoungah / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Landmark72swimmingpool.JPG', 4),
(N'Landmark 72 – Đài quan sát Sky72', '/images/attractions/gallery/31-landmark-72-sky72-5.jpg', N'Landmark 72 ẩn trong sương mù', N'Vuong Tri Binh / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Keangnam_Hanoi_Landmark_Tower_misty_01.jpg', 5),
(N'Vincom Center Bà Triệu', '/images/attractions/gallery/33-vincom-center-ba-trieu-1.jpg', N'Mặt phố trước Vincom Bà Triệu', N'Phan Minh Tuấn / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Vincom_B%C3%A0_Tri%E1%BB%87u,_H%C3%A0_N%E1%BB%99i_002.JPG', 1),
(N'Vincom Center Bà Triệu', '/images/attractions/gallery/33-vincom-center-ba-trieu-2.jpg', N'Cầu đi bộ trên cao nối các tòa tháp', N'Phan Minh Tuấn / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Skyway,_Vincom_B%C3%A0_Tri%E1%BB%87u,_H%C3%A0_N%E1%BB%99i_001.JPG', 2),
(N'Vincom Center Bà Triệu', '/images/attractions/gallery/33-vincom-center-ba-trieu-3.jpg', N'Hành lang mua sắm tầng 3 tháp B', N'Phan Minh Tuấn / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:T%E1%BA%A7ng_3_th%C3%A1p_B,_Vincom_B%C3%A0_Tri%E1%BB%87u,_H%C3%A0_N%E1%BB%99i_001.JPG', 3),
(N'Vincom Center Bà Triệu', '/images/attractions/gallery/33-vincom-center-ba-trieu-4.jpg', N'Cửa hàng thời trang trong trung tâm', N'Phan Minh Tuấn / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:T%E1%BA%A7ng_3_th%C3%A1p_B,_Vincom_B%C3%A0_Tri%E1%BB%87u,_H%C3%A0_N%E1%BB%99i_002.JPG', 4),
(N'Vincom Center Bà Triệu', '/images/attractions/gallery/33-vincom-center-ba-trieu-5.jpg', N'Dãy cửa hàng tầng 3', N'Phan Minh Tuấn / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:T%E1%BA%A7ng_3_th%C3%A1p_B,_Vincom_B%C3%A0_Tri%E1%BB%87u,_H%C3%A0_N%E1%BB%99i_003.JPG', 5),
(N'Vincom Mega Mall Royal City', '/images/attractions/gallery/34-vincom-mega-mall-royal-city-1.jpg', N'Mặt tiền Vincom Mega Mall', N'Quenhitran / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Royal_City_on_Nguy%E1%BB%85n_Tr%C3%A3i_Road_(20140804_174532).jpg', 1),
(N'Vincom Mega Mall Royal City', '/images/attractions/gallery/34-vincom-mega-mall-royal-city-2.jpg', N'Các tòa căn hộ Royal City', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Royal_City,_Thanh_Xu%C3%A2n,_Hanoi_0395.jpg', 2),
(N'Vincom Mega Mall Royal City', '/images/attractions/gallery/34-vincom-mega-mall-royal-city-3.jpg', N'Khối kiến trúc tân cổ điển bên đường Nguyễn Trãi', N'Quenhitran / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Royal_City_on_Nguy%E1%BB%85n_Tr%C3%A3i_Road_(20140804_174505).jpg', 3),
(N'Vincom Mega Mall Royal City', '/images/attractions/gallery/34-vincom-mega-mall-royal-city-4.jpg', N'Khuôn viên cây xanh giữa các tòa nhà', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:RoyalCity_0393.jpg', 4),
(N'Vincom Mega Mall Royal City', '/images/attractions/gallery/34-vincom-mega-mall-royal-city-5.jpg', N'Cổng vòm nhìn từ đường Nguyễn Trãi', N'Quenhitran / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Royal_City_on_Nguy%E1%BB%85n_Tr%C3%A3i_Road_(20140804_174508).jpg', 5)
) v(Name, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
JOIN TouristAttractions a ON a.Name = v.Name
WHERE NOT EXISTS (SELECT 1 FROM AttractionImages x WHERE x.ImageUrl = v.ImageUrl);
GO
/* ---- 3. Tram gan (quang duong di bo that tu OSRM) ---- */
INSERT INTO AttractionStations (AttractionId, StationId, WalkingDistance, WalkingDuration)
SELECT a.AttractionId, s.StationId, v.Dist, v.Dur
FROM (VALUES
(N'Nhà thờ Lớn Hà Nội', 'BUS-0229', 385, 5),
(N'Nhà thờ Lớn Hà Nội', 'BUS-0132', 433, 6),
(N'Nhà thờ Lớn Hà Nội', 'BUS-0133', 454, 6),
(N'Nhà thờ Lớn Hà Nội', 'BIKE-070', 344, 5),
(N'Nhà thờ Lớn Hà Nội', 'EV-070', 344, 5),
(N'Bảo tàng Hồ Chí Minh', 'BUS-0179', 439, 6),
(N'Bảo tàng Hồ Chí Minh', 'BUS-0120', 464, 6),
(N'Bảo tàng Hồ Chí Minh', 'BUS-0388', 695, 9),
(N'Bảo tàng Hồ Chí Minh', 'BIKE-019', 743, 10),
(N'Bảo tàng Hồ Chí Minh', 'EV-019', 743, 10),
(N'Khu di tích Phủ Chủ tịch', 'BUS-0179', 580, 8),
(N'Khu di tích Phủ Chủ tịch', 'BUS-0120', 834, 11),
(N'Khu di tích Phủ Chủ tịch', 'BUS-0107', 935, 12),
(N'Khu di tích Phủ Chủ tịch', 'BIKE-037', 974, 13),
(N'Khu di tích Phủ Chủ tịch', 'EV-037', 974, 13),
(N'Phố sách Đinh Lễ', 'BUS-0208', 324, 4),
(N'Phố sách Đinh Lễ', 'BUS-0079', 361, 5),
(N'Phố sách Đinh Lễ', 'BUS-0068', 369, 5),
(N'Phố sách Đinh Lễ', 'BIKE-069', 343, 5),
(N'Phố sách Đinh Lễ', 'EV-069', 343, 5),
(N'Hồ Trúc Bạch', 'BUS-0085', 447, 6),
(N'Hồ Trúc Bạch', 'BUS-0380', 464, 6),
(N'Hồ Trúc Bạch', 'BUS-0211', 480, 6),
(N'Hồ Trúc Bạch', 'BIKE-011', 396, 5),
(N'Hồ Trúc Bạch', 'EV-011', 396, 5),
(N'Công viên Thống Nhất', 'BUS-0030', 183, 2),
(N'Công viên Thống Nhất', 'BUS-0383', 370, 5),
(N'Công viên Thống Nhất', 'BUS-0384', 544, 7),
(N'Công viên Thống Nhất', 'BIKE-081', 618, 8),
(N'Công viên Thống Nhất', 'EV-081', 618, 8),
(N'Công viên Thủ Lệ', 'BUS-0089', 316, 4),
(N'Công viên Thủ Lệ', 'BUS-0262', 406, 5),
(N'Công viên Thủ Lệ', 'BUS-0031', 468, 6),
(N'Công viên Thủ Lệ', 'METRO3-08', 360, 5),
(N'Công viên Thủ Lệ', 'BIKE-016', 837, 11),
(N'Công viên Thủ Lệ', 'EV-016', 837, 11),
(N'Bảo tàng Thiên nhiên Việt Nam', 'BUS-0051', 489, 7),
(N'Bảo tàng Thiên nhiên Việt Nam', 'BUS-0186', 506, 7),
(N'Bảo tàng Thiên nhiên Việt Nam', 'BUS-0187', 957, 13),
(N'Công viên nước Hồ Tây', 'BUS-0266', 115, 2),
(N'Công viên nước Hồ Tây', 'BUS-0356', 340, 5),
(N'Công viên nước Hồ Tây', 'BUS-0377', 615, 8),
(N'Công viên nước Hồ Tây', 'BIKE-033', 715, 10),
(N'Công viên nước Hồ Tây', 'EV-033', 715, 10),
(N'Thủy cung Times City', 'BUS-0251', 438, 6),
(N'Thủy cung Times City', 'BUS-0252', 505, 7),
(N'Thủy cung Times City', 'BUS-0250', 760, 10),
(N'Landmark 72 – Đài quan sát Sky72', 'BUS-0443', 571, 8),
(N'Landmark 72 – Đài quan sát Sky72', 'BUS-0282', 622, 8),
(N'Landmark 72 – Đài quan sát Sky72', 'BUS-0444', 689, 9),
(N'Lotte Mall Tây Hồ', 'BUS-0328', 229, 3),
(N'Lotte Mall Tây Hồ', 'BUS-0377', 288, 4),
(N'Lotte Mall Tây Hồ', 'BUS-0356', 426, 6),
(N'Lotte Mall Tây Hồ', 'BIKE-033', 972, 13),
(N'Lotte Mall Tây Hồ', 'EV-033', 972, 13),
(N'Vincom Center Bà Triệu', 'BUS-0135', 216, 3),
(N'Vincom Center Bà Triệu', 'BUS-0204', 403, 5),
(N'Vincom Center Bà Triệu', 'BUS-0066', 523, 7),
(N'Vincom Center Bà Triệu', 'BIKE-081', 567, 8),
(N'Vincom Center Bà Triệu', 'EV-081', 567, 8),
(N'Vincom Mega Mall Royal City', 'BUS-0002', 727, 10),
(N'Vincom Mega Mall Royal City', 'BUS-0037', 1129, 15),
(N'Vincom Mega Mall Royal City', 'BUS-0257', 1163, 16),
(N'Vincom Mega Mall Royal City', 'METRO2A-05', 1196, 16)
) v(Name, Code, Dist, Dur)
JOIN TouristAttractions a ON a.Name = v.Name
JOIN Stations s ON s.StationCode = v.Code
WHERE NOT EXISTS (SELECT 1 FROM AttractionStations x WHERE x.AttractionId = a.AttractionId AND x.StationId = s.StationId);
GO
/* ---- 4. Ho Tay: toa do moi o bo ho (duong Thanh Nien) -> tinh lai tram gan ---- */
IF EXISTS (SELECT 1 FROM TouristAttractions WHERE Name = N'Hồ Tây' AND Latitude = 21.047000)
   AND EXISTS (SELECT 1 FROM AttractionStations x JOIN TouristAttractions a ON a.AttractionId = x.AttractionId
               JOIN Stations s ON s.StationId = x.StationId
               WHERE a.Name = N'Hồ Tây' AND s.StationCode NOT IN ('BUS-0212', 'BUS-0085', 'BUS-0213', 'BIKE-028', 'EV-028'))
BEGIN
    DELETE x FROM AttractionStations x JOIN TouristAttractions a ON a.AttractionId = x.AttractionId WHERE a.Name = N'Hồ Tây';
END
INSERT INTO AttractionStations (AttractionId, StationId, WalkingDistance, WalkingDuration)
SELECT a.AttractionId, s.StationId, v.Dist, v.Dur
FROM (VALUES
('BUS-0212', 557, 7),
('BUS-0085', 567, 8),
('BUS-0213', 954, 13),
('BIKE-028', 252, 3),
('EV-028', 252, 3)
) v(Code, Dist, Dur)
JOIN TouristAttractions a ON a.Name = N'Hồ Tây'
JOIN Stations s ON s.StationCode = v.Code
WHERE NOT EXISTS (SELECT 1 FROM AttractionStations x WHERE x.AttractionId = a.AttractionId AND x.StationId = s.StationId);
GO
SELECT COUNT(*) AS Attractions FROM TouristAttractions WHERE Status = 'ACTIVE';
SELECT a.AttractionId, a.Name, a.Category,
       (SELECT COUNT(*) FROM AttractionImages i WHERE i.AttractionId = a.AttractionId) AS Images,
       (SELECT COUNT(*) FROM AttractionStations s WHERE s.AttractionId = a.AttractionId) AS Stations
FROM TouristAttractions a WHERE a.AttractionId > 20 OR a.Name = N'Hồ Tây' ORDER BY a.AttractionId;
GO
