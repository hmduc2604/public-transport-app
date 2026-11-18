/* =====================================================================
   13_more_attractions_2.sql - Them 16 dia diem (dot 3, tong cong 50 dia diem):
   bao tang, den chua, di tich, cong vien, vui choi o Ha Noi (tra cuu web 17/11/2026).
   Chay tren database DA CO du lieu, an toan khi chay lai (them theo ten, khong trung).
   - Thong tin: gioi thieu, lich su, diem noi bat, gio mo cua, gia ve, thong tin nhanh, moc lich su
   - Toa do: OpenStreetMap (Nominatim)
   - Anh: Wikimedia Commons (CC0 / Public domain / CC BY / CC BY-SA)
   - Tram gan + quang duong di bo THAT (OSRM, du lieu OpenStreetMap)
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
GO
USE PublicTransportDBV2;
GO
/* ---- 1. Dia diem moi (giu so thu tu AttractionId lien mach neu IDENTITY bi nhay) ---- */
DECLARE @mx INT = (SELECT ISNULL(MAX(AttractionId), 0) FROM TouristAttractions);
IF NOT EXISTS (SELECT 1 FROM TouristAttractions WHERE Name = N'Bảo tàng Phụ nữ Việt Nam')
   AND IDENT_CURRENT('TouristAttractions') > @mx
    DBCC CHECKIDENT ('TouristAttractions', RESEED, @mx) WITH NO_INFOMSGS;
GO
INSERT INTO TouristAttractions
(Name, Description, History, Highlights, Address, Latitude, Longitude, Category, OpeningHours, TicketPrice, PopularityScore,
 HoursSummary, PriceFrom, VisitDuration, BestTime, Tips, Facts, Timeline)
SELECT v.Name, v.Description, v.History, v.Highlights, v.Address, v.Latitude, v.Longitude, v.Category, v.OpeningHours, v.TicketPrice,
       v.PopularityScore, v.HoursSummary, v.PriceFrom, v.VisitDuration, v.BestTime, v.Tips, v.Facts, v.Timeline
FROM (VALUES
(35, N'Bảo tàng Phụ nữ Việt Nam',
 N'Bảo tàng về lịch sử, văn hóa và vai trò của phụ nữ Việt Nam – từ hôn nhân, gia đình, trang phục đến những người mẹ, người chiến sĩ trong kháng chiến. Cách trưng bày hiện đại, có chú thích tiếng Anh và tiếng Pháp, thuộc nhóm bảo tàng được khách quốc tế đánh giá cao nhất Hà Nội.',
 N'Bảo tàng do Hội Liên hiệp Phụ nữ Việt Nam thành lập năm 1987, hiện thực hóa tâm nguyện của bà Nguyễn Thị Định – Chủ tịch Hội khi đó – về một nơi lưu giữ ký ức của phụ nữ Việt Nam. Năm 1995 bảo tàng chính thức mở cửa đón khách tại số 36 Lý Thường Kiệt. Sau đợt cải tạo, đổi mới toàn bộ hệ thống trưng bày, bảo tàng mở cửa trở lại năm 2010; năm 2015 lọt top 25 bảo tàng hấp dẫn nhất châu Á. Hiện bảo tàng lưu giữ gần 30.000 tài liệu, hiện vật.',
 N'Ba chủ đề trưng bày chính: Phụ nữ trong gia đình, Phụ nữ trong lịch sử, Thời trang phụ nữ|Bộ sưu tập trang phục, trang sức của phụ nữ các dân tộc Việt Nam|Không gian tri ân các Mẹ Việt Nam Anh hùng|Triển lãm chuyên đề thay đổi thường xuyên|Chú thích song ngữ Anh – Pháp, hợp đưa bạn bè nước ngoài đi cùng',
 N'36 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội',
 21.023351, 105.851596,
 N'Bảo tàng',
 N'8:00 – 17:00 tất cả các ngày trong tuần, kể cả ngày lễ.',
 N'Người lớn 40.000đ; sinh viên 20.000đ (có thẻ); học sinh 10.000đ.',
 76,
 N'8:00 – 17:00 hằng ngày',
 N'Từ 10.000đ',
 N'1,5 – 2 giờ',
 N'Buổi sáng ngày thường để xem yên tĩnh; hợp cả ngày mưa vì toàn bộ trưng bày trong nhà.',
 N'Dành ít nhất 1,5 giờ để xem hết các tầng|Mang thẻ học sinh, sinh viên để được giảm giá vé|Có thể kết hợp Chùa Quán Sứ (khoảng 600 m) và Hồ Gươm|Nên xem theo thứ tự từ tầng trên xuống để theo mạch trưng bày',
 N'Thành lập | 1987
Mở cửa đón khách | 1995
Đơn vị quản lý | Hội Liên hiệp Phụ nữ Việt Nam
Hiện vật | Gần 30.000 tài liệu, hiện vật
Thuyết minh | Tiếng Việt, Anh, Pháp',
 N'1987 | Bảo tàng Phụ nữ Việt Nam được thành lập
1995 | Chính thức mở cửa đón khách tại 36 Lý Thường Kiệt
2010 | Mở cửa trở lại sau đợt cải tạo, đổi mới toàn bộ trưng bày
2015 | Lọt top 25 bảo tàng hấp dẫn nhất châu Á'),
(36, N'Đền Quán Thánh',
 N'Một trong "Thăng Long tứ trấn" – ngôi đền trấn giữ phía Bắc kinh thành, thờ Huyền Thiên Trấn Vũ. Đền nổi tiếng với pho tượng đồng đen cao gần 4 m đúc năm 1677 (Bảo vật quốc gia), nằm ở góc phố Quán Thánh – Thanh Niên, sát hồ Trúc Bạch.',
 N'Theo truyền thuyết và văn bia, đền được dựng từ thời Lý Thái Tổ khi dời đô về Thăng Long (thế kỷ XI) với tên chữ Trấn Vũ Quán, thờ Huyền Thiên Trấn Vũ – vị thần phương Bắc có công trừ yêu quái, giữ yên kinh thành. Năm 1677, dưới triều Lê Hy Tông, các nghệ nhân làng đúc đồng Ngũ Xã đúc pho tượng Trấn Vũ bằng đồng đen cao gần 4 m, nặng khoảng 4 tấn cùng quả chuông đồng lớn treo trên gác tam quan. Đền được trùng tu nhiều lần qua các thời Lê – Trịnh và Nguyễn; năm 2016 pho tượng được công nhận là Bảo vật quốc gia.',
 N'Tượng Huyền Thiên Trấn Vũ bằng đồng đen cao gần 4 m, nặng khoảng 4 tấn|Quả chuông đồng đúc năm 1677 treo trên gác tam quan|Cổng tứ trụ với các câu đối cổ|Nhà bia lưu văn bia ghi các lần trùng tu từ Lý, Lê đến Nguyễn|Sân đền rợp cây cổ thụ, ngay cạnh hồ Trúc Bạch',
 N'190 Quán Thánh, Ba Đình, Hà Nội',
 21.043006, 105.836587,
 N'Tôn giáo',
 N'Khoảng 8:00 – 17:00 hằng ngày; mùng 1, ngày rằm và tháng Giêng rất đông người đi lễ.',
 N'10.000đ/lượt (phí tham quan theo quy định của thành phố).',
 78,
 N'Khoảng 8:00 – 17:00',
 N'10.000đ',
 N'30 – 45 phút',
 N'Sáng sớm ngày thường; chiều muộn kết hợp ngắm hoàng hôn trên hồ Trúc Bạch, đường Thanh Niên.',
 N'Ăn mặc lịch sự, kín đáo khi vào điện thờ|Mùng 1, rằm rất đông – nên đi sớm hoặc ngày thường|Đi bộ ra đường Thanh Niên, Chùa Trấn Quốc khoảng 1 km|Không chạm tay vào tượng và đồ thờ',
 N'Tên chữ | Trấn Vũ Quán
Thờ | Huyền Thiên Trấn Vũ
Vị trí trong tứ trấn | Trấn Bắc
Tượng đồng | Cao gần 4 m, nặng khoảng 4 tấn, đúc năm 1677
Bảo vật quốc gia | Tượng Trấn Vũ (công nhận năm 2016)',
 N'Thế kỷ XI | Dựng đền thời Lý Thái Tổ, gọi là Trấn Vũ Quán
1677 | Đúc tượng Huyền Thiên Trấn Vũ và chuông đồng (triều Lê Hy Tông)
Thời Lê – Trịnh, Nguyễn | Đền nhiều lần được trùng tu, tôn tạo
2016 | Tượng Trấn Vũ được công nhận Bảo vật quốc gia'),
(37, N'Đền Bạch Mã',
 N'Ngôi đền trấn giữ phía Đông kinh thành (một trong "Thăng Long tứ trấn"), thờ thần Long Đỗ – thành hoàng của Thăng Long. Đền nằm giữa phố Hàng Buồm và được coi là ngôi đền cổ nhất khu phố cổ.',
 N'Đền thờ thần Long Đỗ (thần núi Nùng) đã có từ trước khi Lý Thái Tổ dời đô; theo sự tích, từ thế kỷ IX Cao Biền đã gặp thần và dân lập đền thờ. Truyền thuyết kể khi vua Lý Thái Tổ xây thành Thăng Long, thành nhiều lần bị sụt lở; vua sai người đến cầu đảo thì thấy một con ngựa trắng (bạch mã) từ đền đi ra, để lại vết chân, vua cho đắp thành theo dấu ấy và thành không còn đổ. Thần được phong làm thành hoàng của kinh đô, đền từ đó mang tên Bạch Mã. Đền được trùng tu nhiều lần (năm 1687 dân ba giáp sửa đền, dựng bia) và được xếp hạng di tích lịch sử – văn hóa năm 1986.',
 N'Mái vòm hình mai cua nối phương đình với đại bái|Cột gỗ, hoành phi, câu đối sơn son thếp vàng chạm khắc tinh xảo|Ban thờ Bạch Mã đại vương ở chính giữa, lư hương đặt trong phương đình|Nằm giữa phố cổ, gần chợ Đồng Xuân và phố đi bộ Hàng Buồm về đêm',
 N'76 Hàng Buồm, Hoàn Kiếm, Hà Nội',
 21.035934, 105.850987,
 N'Tôn giáo',
 N'Khoảng 9:00 – 17:30 hằng ngày; dịp lễ hội và mùng 1, rằm đông người đi lễ.',
 N'Miễn phí vào cửa; công đức tùy tâm.',
 70,
 N'Khoảng 9:00 – 17:30',
 N'Miễn phí',
 N'20 – 30 phút',
 N'Buổi sáng khi phố cổ còn vắng; lễ hội đền ngày 12 – 13 tháng Hai âm lịch.',
 N'Ăn mặc kín đáo, giữ trật tự trong điện thờ|Kết hợp dạo phố đi bộ Hàng Buồm – Tạ Hiện buổi tối|Chợ Đồng Xuân và Ô Quan Chưởng đều chỉ cách khoảng 300 m',
 N'Thờ | Thần Long Đỗ (Quảng Lợi Bạch Mã đại vương)
Vị trí trong tứ trấn | Trấn Đông
Địa chỉ | 76 Hàng Buồm
Xếp hạng | Di tích lịch sử – văn hóa (1986)
Lễ hội | 12 – 13 tháng Hai âm lịch',
 N'Thế kỷ IX | Theo sự tích, dân lập đền thờ thần Long Đỗ
1010 | Lý Thái Tổ dời đô; truyền thuyết ngựa trắng chỉ đường đắp thành, thần được phong thành hoàng Thăng Long
1687 | Dân ba giáp trùng tu đền, dựng bia
1986 | Được xếp hạng di tích lịch sử – văn hóa'),
(38, N'Chùa Quán Sứ',
 N'Ngôi chùa giữa trung tâm Hà Nội, trụ sở Trung ương Giáo hội Phật giáo Việt Nam. Xưa kia đây là nơi các sứ thần nước ngoài theo đạo Phật đến lễ Phật khi lưu lại kinh thành, nên chùa có tên Quán Sứ.',
 N'Theo sử cũ, khoảng thế kỷ XV triều đình dựng nhà Quán Sứ để tiếp đón sứ thần các nước phương Nam sang Thăng Long; vì sứ thần sùng đạo Phật nên dựng thêm ngôi chùa cạnh đó để họ hành lễ, gọi là chùa Quán Sứ. Năm 1934 chùa trở thành trụ sở Hội Phật giáo Bắc Kỳ. Năm 1942 chùa được xây dựng lại theo thiết kế của hai kiến trúc sư Nguyễn Ngọc Ngoạn và Nguyễn Xuân Tùng, giữ dáng dấp chùa cổ miền Bắc nhưng dùng vật liệu mới. Năm 1981 Hội nghị thống nhất Phật giáo Việt Nam họp tại chùa, từ đó chùa là trụ sở Trung ương Giáo hội Phật giáo Việt Nam.',
 N'Tam quan ba tầng mái, gác chuông ở giữa|Đại hùng bảo điện rộng, nhiều pho tượng Phật trang nghiêm|Nhà thờ Tổ thờ lịch đại Tổ sư Phật giáo Việt Nam|Các đại lễ Phật Đản, Vu Lan tổ chức quy mô lớn',
 N'73 Quán Sứ, Hoàn Kiếm, Hà Nội',
 21.024467, 105.845419,
 N'Tôn giáo',
 N'Sáng 7:30 – 11:30, chiều 13:30 – 17:30, tất cả các ngày.',
 N'Miễn phí.',
 72,
 N'7:30 – 11:30, 13:30 – 17:30',
 N'Miễn phí',
 N'30 – 45 phút',
 N'Sáng sớm ngày thường; dịp Phật Đản, Vu Lan để xem đại lễ (rất đông).',
 N'Ăn mặc kín đáo, giữ yên lặng trong chính điện|Dịp lễ lớn nên đi sớm, giữ đồ cẩn thận|Cách Hồ Gươm khoảng 1 km, gần Bảo tàng Phụ nữ Việt Nam',
 N'Địa chỉ | 73 phố Quán Sứ
Nguồn gốc tên | Nơi sứ thần nước ngoài đến lễ Phật
Xây dựng lại | Năm 1942
Kiến trúc sư | Nguyễn Ngọc Ngoạn, Nguyễn Xuân Tùng
Vai trò | Trụ sở Trung ương Giáo hội Phật giáo Việt Nam',
 N'Thế kỷ XV | Dựng chùa cạnh nhà Quán Sứ tiếp đón sứ thần
1934 | Trở thành trụ sở Hội Phật giáo Bắc Kỳ
1942 | Xây dựng lại với kiến trúc như ngày nay
1981 | Hội nghị thống nhất Phật giáo Việt Nam họp tại chùa; chùa thành trụ sở Trung ương Giáo hội'),
(39, N'Phủ Tây Hồ',
 N'Nơi thờ Thánh Mẫu Liễu Hạnh nổi tiếng bậc nhất Hà Nội, nằm trên doi đất nhỏ nhô ra Hồ Tây. Người Hà Nội thường đến lễ dịp đầu năm, mùng 1 và ngày rằm; quanh phủ có nhiều hàng bánh tôm, bún ốc.',
 N'Phủ được cho là dựng khoảng thế kỷ XVII, gắn với truyền thuyết Công chúa Liễu Hạnh – con gái Ngọc Hoàng giáng trần – dạo chơi Hồ Tây, mở quán nước bên hồ và xướng họa thơ với Trạng Bùng Phùng Khắc Khoan. Phủ thờ Mẫu Liễu Hạnh, một trong "tứ bất tử" của tín ngưỡng dân gian Việt (cùng Tản Viên Sơn Thánh, Thánh Gióng, Chử Đồng Tử), là trung tâm sinh hoạt tín ngưỡng thờ Mẫu của Thủ đô. Ngày 13/02/1996, Phủ Tây Hồ được xếp hạng di tích lịch sử – văn hóa.',
 N'Phủ chính, điện Sơn Trang, lầu Cô, lầu Cậu theo tín ngưỡng Tứ phủ|Vị trí trên doi đất giữa Hồ Tây, ngắm hoàng hôn rất đẹp|Lễ giỗ Mẫu mùng 3 tháng Ba âm lịch|Hàng bánh tôm, bún ốc nổi tiếng quanh phủ',
 N'52 Đặng Thai Mai, Tây Hồ, Hà Nội',
 21.055728, 105.819642,
 N'Tôn giáo',
 N'5:00 – 19:00 hằng ngày.',
 N'Miễn phí; công đức tùy tâm.',
 80,
 N'5:00 – 19:00',
 N'Miễn phí',
 N'30 – 60 phút',
 N'Ngày thường hoặc chiều muộn để tránh đông và ngắm hoàng hôn Hồ Tây; tháng Giêng rất đông.',
 N'Mùng 1, rằm và tháng Giêng rất đông – nên đi sớm hoặc ngày thường|Cảnh giác người chèo kéo mua đồ lễ, xin tiền|Đường Đặng Thai Mai nhỏ; từ trạm xe buýt gần nhất cần đi bộ thêm một đoạn – xem chỉ đường trong ứng dụng|Có thể thuê xe đạp dạo quanh Hồ Tây',
 N'Thờ | Thánh Mẫu Liễu Hạnh
Xây dựng | Khoảng thế kỷ XVII
Xếp hạng | Di tích lịch sử – văn hóa (13/02/1996)
Lễ chính | Giỗ Mẫu mùng 3 tháng Ba âm lịch
Giờ mở cửa | 5:00 – 19:00',
 N'Thế kỷ XVII | Phủ được dựng bên Hồ Tây (theo truyền ngôn)
1996 | Được xếp hạng di tích lịch sử – văn hóa (13/02)
Hằng năm | Lễ giỗ Mẫu mùng 3 tháng Ba và mùa lễ đầu xuân thu hút rất đông người dân'),
(40, N'Ngôi nhà di sản 87 Mã Mây',
 N'Ngôi nhà ống cổ cuối thế kỷ XIX giữa phố cổ, được trùng tu để giới thiệu kiến trúc nhà ở và nếp sinh hoạt của một gia đình buôn bán Hà Nội xưa: mặt tiền hẹp, sân trời, gian thờ, bếp và đồ dùng gia đình.',
 N'Ngôi nhà được xây khoảng năm 1890 theo kiểu nhà ống hai tầng "mặt tiền hẹp, nở hậu" đặc trưng của phố cổ, phía trước là cửa hàng, phía sau và trên gác là nơi ở, thờ cúng. Qua nhiều biến động, đến cuối thế kỷ XX nhiều hộ gia đình cùng sinh sống trong nhà. Từ cuối năm 1998, trong khuôn khổ hợp tác giữa Hà Nội và thành phố Toulouse (Pháp), ngôi nhà được trùng tu và hoàn thành ngày 27/10/1999, mở cửa thành "Ngôi nhà di sản". Ngày 16/2/2004 ngôi nhà được công nhận là di tích; từ 2/1/2025 bắt đầu thu phí tham quan.',
 N'Mặt tiền gỗ hẹp, sân trời lấy ánh sáng và gió|Gian thờ tổ tiên trang nghiêm trên tầng hai|Bếp, giếng và đồ dùng sinh hoạt của gia đình Hà Nội xưa|Cầu thang gỗ, cửa bức bàn đặc trưng nhà phố cổ',
 N'87 Mã Mây, Hoàn Kiếm, Hà Nội',
 21.034366, 105.853593,
 N'Di tích',
 N'Khoảng 8:00 – 12:00 và 13:30 – 20:00 hằng ngày (giờ có thể thay đổi theo mùa).',
 N'20.000đ/lượt (từ 2/1/2025, theo Nghị quyết 44/2024/NQ-HĐND).',
 66,
 N'8:00 – 12:00, 13:30 – 20:00',
 N'20.000đ',
 N'20 – 30 phút',
 N'Buổi sáng hoặc chiều tối ngày thường; ghé khi dạo phố cổ.',
 N'Cầu thang gỗ dốc, đi lại cẩn thận|Không gian nhỏ – tránh lúc đông khách đoàn|Ô Quan Chưởng và Đền Bạch Mã đều chỉ cách vài trăm mét',
 N'Năm xây | Khoảng 1890
Kiểu nhà | Nhà ống 2 tầng "mặt tiền hẹp, nở hậu"
Trùng tu | 1998 – 1999, hợp tác Hà Nội – Toulouse (Pháp)
Công nhận di tích | 16/02/2004
Vé | 20.000đ/lượt',
 N'Khoảng 1890 | Ngôi nhà được xây dựng
1999 | Hoàn thành trùng tu (27/10), mở cửa thành Ngôi nhà di sản
2004 | Được công nhận di tích (16/02)
2025 | Bắt đầu thu phí tham quan 20.000đ/lượt (2/1)'),
(41, N'Ô Quan Chưởng',
 N'Cửa ô duy nhất còn lại của kinh thành Thăng Long xưa, nằm ở đầu phố Hàng Chiếu giữa khu phố cổ – kiến trúc cửa vòm gạch vồ với vọng lâu phía trên.',
 N'Ô Quan Chưởng được xây năm 1749 (năm Cảnh Hưng thứ 10, đời vua Lê Hiển Tông) trên vòng lũy bao quanh kinh thành, tên chữ là Đông Hà Môn vì thuộc phường Đông Hà, mở ra phía sông Hồng. Năm 1804, thời Gia Long, cửa ô được xây lại, mở rộng như hiện nay. Theo truyền ngôn, tên Quan Chưởng gắn với viên chưởng cơ chỉ huy quân giữ cửa đã chiến đấu đến cùng khi quân Pháp đánh thành Hà Nội năm 1873. Năm 1881 Tổng đốc Hoàng Diệu cho gắn bia đá bên cửa ghi lệnh cấm lính canh sách nhiễu người qua lại. Thời Pháp thuộc các cửa ô khác lần lượt bị phá, chỉ còn Ô Quan Chưởng.',
 N'Cửa vòm và vọng lâu bốn mái nơi lính gác quan sát|Tường gạch vồ cỡ lớn phủ rêu cổ kính|Tấm bia năm 1881 của Tổng đốc Hoàng Diệu bên cửa|Góc chụp ảnh phố cổ đẹp lúc sáng sớm, chiều muộn',
 N'Phố Ô Quan Chưởng (đầu phố Hàng Chiếu), Hoàn Kiếm, Hà Nội',
 21.037331, 105.852209,
 N'Di tích',
 N'Ngắm bên ngoài cả ngày; cửa ô nằm giữa phố, xe cộ vẫn qua lại.',
 N'Miễn phí.',
 64,
 N'Cả ngày',
 N'Miễn phí',
 N'10 – 20 phút',
 N'Sáng sớm hoặc chiều muộn khi phố vắng, ánh sáng đẹp để chụp ảnh.',
 N'Xe cộ qua cửa ô đông – đứng chụp ảnh trên vỉa hè|Đi bộ khoảng 5 phút tới Ngôi nhà di sản 87 Mã Mây|Buổi tối khu Hàng Buồm – Tạ Hiện ngay gần rất nhộn nhịp',
 N'Tên chữ | Đông Hà Môn (còn gọi Thanh Hà Môn)
Xây dựng | Năm 1749
Xây lại | Năm 1804 (thời Gia Long)
Đặc điểm | Cửa ô duy nhất còn lại của Thăng Long
Vị trí | Đầu phố Hàng Chiếu, gần cầu Chương Dương',
 N'1749 | Xây dựng trên vòng lũy kinh thành, tên Đông Hà Môn
1804 | Xây lại, mở rộng như hiện nay
1873 | Theo truyền ngôn, viên Quan Chưởng giữ cửa chiến đấu đến cùng khi Pháp đánh thành
1881 | Tổng đốc Hoàng Diệu cho gắn bia đá bên cửa'),
(42, N'Cột cờ Hà Nội',
 N'Kỳ đài cao 33,4 m xây đầu thời Nguyễn, biểu tượng của Thủ đô, nằm trên trục chính tâm của Khu di sản Hoàng thành Thăng Long (đường Điện Biên Phủ). Từ 2025 Cột cờ mở cửa đón khách với trưng bày và tour trải nghiệm "Ký ức Cột cờ".',
 N'Cột cờ được xây từ năm 1805 đến 1812 dưới triều Gia Long, cùng thời với việc xây thành Hà Nội, ở cực nam trục chính tâm, trên nền cổng Chu Tước thời Lê. Khi Pháp phá thành Hà Nội cuối thế kỷ XIX, Cột cờ được giữ lại làm đài quan sát. Năm 1945, sau Cách mạng Tháng Tám, lá cờ đỏ sao vàng lần đầu tung bay trên đỉnh Cột cờ; 15 giờ ngày 10/10/1954 lễ chào cờ lịch sử mừng giải phóng Thủ đô diễn ra tại đây. Sau khi Bảo tàng Lịch sử Quân sự chuyển đi, từ 1/1/2025 Cột cờ do Trung tâm Bảo tồn Di sản Thăng Long – Hà Nội quản lý và mở cửa đón khách.',
 N'Ba tầng đế hình chóp vuông cụt và thân cột bát giác|Vọng lâu trên đỉnh với lá cờ Tổ quốc 4 × 6 m|Trưng bày "Cột cờ và khát vọng hòa bình"|Tour trải nghiệm "Ký ức Cột cờ" kết hợp công nghệ số',
 N'28A Điện Biên Phủ, Ba Đình, Hà Nội',
 21.032590, 105.839825,
 N'Di tích',
 N'8:00 – 17:00 hằng ngày. Hiện chỉ tham quan bên ngoài và tầng đế thứ nhất; các tầng trên và đỉnh cột tạm đóng để bảo tồn.',
 N'Dùng vé chung Khu di sản Hoàng thành Thăng Long: người lớn 100.000đ; học sinh, sinh viên, người cao tuổi 50.000đ; dưới 16 tuổi miễn phí.',
 78,
 N'8:00 – 17:00 hằng ngày',
 N'100.000đ (vé Hoàng thành)',
 N'30 – 45 phút',
 N'Buổi sáng; dịp 10/10 (Giải phóng Thủ đô) và 2/9 có nhiều hoạt động kỷ niệm.',
 N'Mua vé ở quầy Hoàng thành; lối vào Cột cờ cách cổng Hoàng thành khoảng 100 m|Kết hợp Hoàng thành Thăng Long và Lăng Bác trong nửa ngày|Mang giấy tờ tùy thân để được giảm hoặc miễn vé',
 N'Tên khác | Kỳ đài Hà Nội
Xây dựng | 1805 – 1812 (thời Gia Long)
Chiều cao | 33,4 m (hơn 40 m tính cả cán cờ)
Tầng đế dưới cùng | Mỗi cạnh 42,5 m, cao 3,1 m
Đỉnh | Vọng lâu bát giác cao 3,3 m, 8 cửa sổ',
 N'1805 – 1812 | Xây dựng cùng thành Hà Nội thời Gia Long
1945 | Cờ đỏ sao vàng lần đầu tung bay trên đỉnh Cột cờ
10/10/1954 | Lễ chào cờ lịch sử mừng giải phóng Thủ đô
2025 | Trung tâm Bảo tồn Di sản Thăng Long – Hà Nội tiếp nhận, mở cửa đón khách (1/1)'),
(43, N'Hồ Hữu Tiệp (xác máy bay B-52)',
 N'Hồ nước nhỏ giữa làng hoa Ngọc Hà, nơi còn nguyên phần xác máy bay ném bom B-52 bị bắn rơi đêm 27/12/1972 – chứng tích độc đáo của chiến thắng "Hà Nội – Điện Biên Phủ trên không".',
 N'Lúc 23 giờ 3 phút ngày 27/12/1972, trong chiến dịch tập kích đường không 12 ngày đêm của Mỹ vào Hà Nội, một máy bay B-52 trúng tên lửa SAM-2 của Tiểu đoàn 72, Trung đoàn tên lửa 285 và rơi xuống hồ Hữu Tiệp thuộc làng hoa Ngọc Hà. Phần xác máy bay được giữ lại giữa lòng hồ làm chứng tích. Năm 1992 hồ Hữu Tiệp cùng xác B-52 được xếp hạng Di tích lịch sử cấp quốc gia; dịp kỷ niệm 50 năm chiến thắng (2022), hồ được tôn tạo và có triển lãm ảnh ngay bên hồ.',
 N'Phần xác B-52 nằm giữa lòng hồ|Bia ghi chiến công Tiểu đoàn 72, Trung đoàn 285|Không gian làng hoa Ngọc Hà, đình Ngọc Hà gần đó|Bảo tàng Chiến thắng B-52 chỉ cách vài trăm mét',
 N'Ngõ 55 Hoàng Hoa Thám, Ba Đình, Hà Nội',
 21.037968, 105.827004,
 N'Di tích',
 N'Ngắm từ bờ hồ cả ngày.',
 N'Miễn phí.',
 68,
 N'Cả ngày',
 N'Miễn phí',
 N'15 – 30 phút',
 N'Sáng sớm hoặc chiều muộn; dịp kỷ niệm chiến thắng cuối tháng 12.',
 N'Hồ nằm trong ngõ nhỏ – đi bộ hoặc xe máy vào thuận hơn ô tô|Quán cà phê quanh hồ có góc nhìn thẳng ra xác máy bay|Tôn trọng sinh hoạt của người dân trong ngõ',
 N'Thời điểm | 23 giờ 3 phút ngày 27/12/1972
Đơn vị bắn rơi | Tiểu đoàn 72, Trung đoàn tên lửa 285
Vũ khí | Tên lửa SAM-2
Xếp hạng | Di tích lịch sử cấp quốc gia (1992)
Tên khác | Hồ B-52',
 N'27/12/1972 | Máy bay B-52 bị bắn rơi xuống hồ Hữu Tiệp
1992 | Được xếp hạng Di tích lịch sử cấp quốc gia
2022 | Dịp 50 năm chiến thắng: hồ được tôn tạo, có triển lãm ảnh bên hồ'),
(44, N'Bảo tàng Chiến thắng B-52',
 N'Bảo tàng kể về 12 ngày đêm cuối tháng 12/1972 quân dân Hà Nội đánh trả cuộc tập kích bằng B-52 của Mỹ, với khu trưng bày ngoài trời có tên lửa, pháo cao xạ và mảnh xác máy bay B-52 thật. Vào cửa miễn phí.',
 N'Bảo tàng khánh thành ngày 22/12/1997 nhân kỷ niệm 25 năm chiến thắng "Hà Nội – Điện Biên Phủ trên không". Tên gọi nhắc đến các máy bay B-52 bị bắn rơi trong chiến dịch 12 ngày đêm (18 – 29/12/1972). Tầng 1 giới thiệu quá trình xây dựng, chiến đấu của lực lượng vũ trang Hà Nội; tầng 2 dành cho trận "Điện Biên Phủ trên không" với bản đồ tác chiến, ảnh tư liệu, thư tay, nhật ký thời chiến. Khu ngoài trời rộng khoảng 4.000 m² trưng bày vũ khí, khí tài và xác máy bay.',
 N'Khu trưng bày ngoài trời khoảng 4.000 m²: tên lửa SAM-2, pháo cao xạ, ra-đa|Mảnh xác máy bay B-52 thật|Tầng 2 kể chi tiết trận "Điện Biên Phủ trên không"|Bản đồ tác chiến, thư tay, nhật ký thời chiến',
 N'157 Đội Cấn, Ba Đình, Hà Nội',
 21.035547, 105.826095,
 N'Bảo tàng',
 N'Sáng 8:00 – 11:00, chiều 13:30 – 16:30; nghỉ thứ Hai và thứ Sáu.',
 N'Miễn phí.',
 70,
 N'8:00 – 11:00, 13:30 – 16:30 (nghỉ T2, T6)',
 N'Miễn phí',
 N'1 – 1,5 giờ',
 N'Buổi sáng; dịp kỷ niệm chiến thắng 18 – 29/12 có nhiều hoạt động, giao lưu nhân chứng.',
 N'Kiểm tra ngày mở cửa – bảo tàng nghỉ thứ Hai và thứ Sáu|Khu ngoài trời nắng, nên đi sáng sớm hoặc chiều muộn|Kết hợp Hồ Hữu Tiệp (xác B-52) chỉ cách vài trăm mét',
 N'Khánh thành | 22/12/1997
Chủ đề | Chiến thắng 12 ngày đêm tháng 12/1972
Trưng bày ngoài trời | Khoảng 4.000 m²
Vé | Miễn phí
Ngày nghỉ | Thứ Hai, thứ Sáu',
 N'18 – 29/12/1972 | Chiến dịch 12 ngày đêm "Hà Nội – Điện Biên Phủ trên không"
22/12/1997 | Bảo tàng khánh thành (25 năm chiến thắng)
Hằng năm | Tháng 12 tổ chức nhiều hoạt động kỷ niệm, giao lưu nhân chứng lịch sử'),
(45, N'Bảo tàng Lịch sử Quân sự Việt Nam',
 N'Bảo tàng quân sự lớn nhất cả nước, mở cửa từ 11/2024 tại Đại lộ Thăng Long với tháp Chiến thắng cao 45 m, hơn 150.000 hiện vật và 4 bảo vật quốc gia: hai máy bay MiG-21 (số hiệu 4324, 5121), xe tăng T-54B số hiệu 843 và bản đồ Quyết tâm chiến đấu trong Chiến dịch Hồ Chí Minh.',
 N'Bảo tàng được thành lập năm 1956, là một trong 6 bảo tàng quốc gia và nhiều năm đặt tại 28A Điện Biên Phủ cạnh Cột cờ Hà Nội. Từ năm 2019, Bộ Quốc phòng xây dựng bảo tàng mới tại Km 6+500 Đại lộ Thăng Long (phường Tây Mỗ, Đại Mỗ cũ). Cơ sở cũ đóng cửa ngày 30/9/2024; bảo tàng mới mở cửa miễn phí từ 1/11/2024 và bắt đầu bán vé từ 12/4/2025. Đến tháng 6/2026 bảo tàng đã đón gần 4 triệu lượt khách.',
 N'Tháp Chiến thắng cao 45 m|Bảo vật quốc gia: máy bay MiG-21 số 4324, 5121 và xe tăng T-54B số 843|Khu trưng bày ngoài trời rộng với máy bay, xe tăng, pháo|Khu trải nghiệm: đẩy xe đạp thồ, kéo pháo, tái hiện 12 ngày đêm bảo vệ Thủ đô',
 N'Km 6+500 Đại lộ Thăng Long, Nam Từ Liêm, Hà Nội',
 21.011587, 105.754706,
 N'Bảo tàng',
 N'Sáng 8:00 – 11:30, chiều 13:00 – 16:30; nghỉ thứ Hai và thứ Sáu.',
 N'40.000đ/người/lượt; học sinh, sinh viên từ 16 tuổi 20.000đ; người dưới 16 tuổi, người từ 80 tuổi và một số đối tượng chính sách được miễn phí.',
 84,
 N'8:00 – 11:30, 13:00 – 16:30 (nghỉ T2, T6)',
 N'Từ 20.000đ',
 N'2 – 3 giờ',
 N'Buổi sáng ngày thường; dịp 30/4, 2/9 rất đông.',
 N'Nghỉ thứ Hai và thứ Sáu – kiểm tra trước khi đi|Diện tích rất rộng, nên dành nửa ngày và đi giày thoải mái|Dịp lễ nên đến từ sáng sớm|Có bãi gửi xe miễn phí bên trái lối vào|Bảo tàng nằm xa trung tâm (khoảng 10 km); theo thông tin du lịch, các tuyến buýt 107, 157 có chạy qua Đại lộ Thăng Long',
 N'Thành lập | 1956
Vị trí mới | Km 6+500 Đại lộ Thăng Long
Mở cửa (cơ sở mới) | 1/11/2024
Hiện vật | Hơn 150.000
Bảo vật quốc gia | 4 (2 máy bay MiG-21, xe tăng T-54B 843, bản đồ Quyết tâm chiến đấu)',
 N'1956 | Thành lập bảo tàng
2019 | Khởi công cơ sở mới trên Đại lộ Thăng Long
30/9/2024 | Đóng cửa cơ sở cũ tại 28A Điện Biên Phủ
1/11/2024 | Cơ sở mới mở cửa đón khách miễn phí
12/4/2025 | Bắt đầu bán vé 40.000đ/lượt
6/2026 | Đón gần 4 triệu lượt khách'),
(46, N'Bảo tàng Phòng không – Không quân',
 N'Bảo tàng của Quân chủng Phòng không – Không quân, trưng bày máy bay chiến đấu, tên lửa, pháo cao xạ, ra-đa và câu chuyện bảo vệ bầu trời trong hai cuộc kháng chiến. Khu ngoài trời rộng, rất hợp với các bạn nhỏ thích máy bay.',
 N'Bảo tàng được thành lập năm 1963, sưu tầm và trưng bày hiện vật về quá trình xây dựng, chiến đấu và trưởng thành của bộ đội Phòng không – Không quân, đặc biệt trong cuộc chiến chống chiến tranh phá hoại bằng không quân của Mỹ và chiến dịch 12 ngày đêm cuối năm 1972. Khu trưng bày ngoài trời rộng khoảng 15.000 m² với hơn 100 hiện vật lớn như máy bay chiến đấu, trực thăng, tên lửa, pháo cao xạ.',
 N'Khu ngoài trời khoảng 15.000 m² với hơn 100 hiện vật lớn|Máy bay chiến đấu MiG, trực thăng, máy bay vận tải ở cự ly gần|Tên lửa SAM-2, pháo cao xạ, ra-đa thời chiến|Phòng trưng bày về chiến dịch 12 ngày đêm tháng 12/1972',
 N'173C Trường Chinh, Thanh Xuân, Hà Nội',
 20.999541, 105.829242,
 N'Bảo tàng',
 N'Sáng 8:00 – 11:00, chiều 13:00 – 16:00; nghỉ thứ Hai. Lịch mở cửa từng ngày có thể thay đổi, nên kiểm tra trước khi đi.',
 N'Khoảng 30.000đ/người lớn; trẻ mẫu giáo miễn phí.',
 66,
 N'8:00 – 11:00, 13:00 – 16:00 (nghỉ T2)',
 N'Khoảng 30.000đ',
 N'1 – 1,5 giờ',
 N'Buổi sáng mát trời; hợp đi cùng trẻ em vào cuối tuần.',
 N'Khu ngoài trời nắng – mang mũ, nước|Trẻ em rất thích xem máy bay ở cự ly gần|Lịch mở cửa có thể thay đổi, nên kiểm tra trước',
 N'Thành lập | 1963
Đơn vị quản lý | Quân chủng Phòng không – Không quân
Trưng bày ngoài trời | Khoảng 15.000 m²
Hiện vật ngoài trời | Hơn 100
Địa chỉ | 173C Trường Chinh',
 N'1963 | Thành lập bảo tàng
1965 – 1972 | Bộ đội Phòng không – Không quân chiến đấu chống chiến tranh phá hoại bằng không quân – nội dung trưng bày chính
12/1972 | Chiến dịch 12 ngày đêm đánh bại cuộc tập kích B-52'),
(47, N'Bảo tàng Hà Nội',
 N'Bảo tàng của Thủ đô với kiến trúc "kim tự tháp ngược" độc đáo trên đường Phạm Hùng, lưu giữ hơn 70.000 hiện vật, tài liệu về lịch sử, văn hóa Thăng Long – Hà Nội, trong đó có 6 nhóm bảo vật quốc gia.',
 N'Bảo tàng Hà Nội được thành lập năm 1982. Tòa nhà mới khởi công ngày 19/5/2008 và khánh thành ngày 6/10/2010 nhân Đại lễ 1.000 năm Thăng Long – Hà Nội, do các kiến trúc sư Meinhard von Gerkan và Nikolaus Goetze (gmp, Đức) thiết kế: 4 tầng nổi, 2 tầng hầm, tầng trên cùng rộng nhất và nhỏ dần xuống dưới. Công trình từng được tạp chí ArtNet (Mỹ) bình chọn trong 36 bảo tàng đẹp nhất thế giới. Ngày 30/3/2026, UBND thành phố công nhận Bảo tàng Hà Nội là điểm du lịch cấp thành phố.',
 N'Kiến trúc kim tự tháp ngược cao 30,7 m|7 chủ đề, 35 chuyên đề trưng bày; 6 nhóm bảo vật quốc gia|Khu trải nghiệm trong nhà và ngoài trời|Đường dốc xoắn bên trong và sảnh rộng – góc chụp ảnh đẹp',
 N'Đường Phạm Hùng, Nam Từ Liêm, Hà Nội',
 21.010013, 105.786309,
 N'Bảo tàng',
 N'9:00 – 17:00 từ thứ Ba đến Chủ nhật; nghỉ thứ Hai.',
 N'50.000đ/vé; học sinh, sinh viên và người từ 60 tuổi giảm 50%; trẻ em dưới 16 tuổi miễn phí.',
 70,
 N'9:00 – 17:00 (nghỉ T2)',
 N'Từ 25.000đ',
 N'1,5 – 2 giờ',
 N'Buổi sáng ngày thường; dịp 18/5 (Ngày Quốc tế Bảo tàng) có hoạt động miễn phí.',
 N'Bảo tàng nghỉ thứ Hai|Mang thẻ học sinh, sinh viên để được giảm 50%|Kết hợp Trung tâm Hội nghị Quốc gia, Keangnam (Sky72) ở gần',
 N'Thành lập | 1982
Khánh thành tòa nhà mới | 6/10/2010
Diện tích | Gần 54.000 m²
Chiều cao | 30,7 m (4 tầng nổi, 2 tầng hầm)
Hiện vật | Hơn 70.000; 6 nhóm bảo vật quốc gia',
 N'1982 | Thành lập Bảo tàng Hà Nội
19/5/2008 | Khởi công tòa nhà mới trên đường Phạm Hùng
6/10/2010 | Khánh thành dịp Đại lễ 1.000 năm Thăng Long – Hà Nội
30/3/2026 | Được công nhận điểm du lịch cấp thành phố'),
(48, N'Con đường gốm sứ sông Hồng',
 N'Bức tranh gốm ghép dài gần 4 km trên tường đê sông Hồng – công trình kỷ niệm 1.000 năm Thăng Long, được Guinness công nhận kỷ lục thế giới năm 2010. Tranh tái hiện lịch sử, làng nghề, lễ hội và hoa văn Việt qua nhiều thời kỳ.',
 N'Công trình do họa sĩ, nhà báo Nguyễn Thu Thủy khởi xướng, thực hiện từ năm 2007 bằng nguồn xã hội hóa, với sự tham gia của nhiều họa sĩ và hơn 100 nghệ nhân, thợ thủ công từ các làng gốm Bát Tràng, Phù Lãng, Chu Đậu, Bàu Trúc... Ngày 5/10/2010, con đường gốm sứ dài khoảng 3,85 km, diện tích gần 6.950 m² được khánh thành, gắn biển công trình kỷ niệm 1.000 năm Thăng Long – Hà Nội và nhận bằng kỷ lục Guinness. Tranh chạy dọc các phố Trần Nhật Duật – Yên Phụ – Trần Khánh Dư – Trần Quang Khải; về sau hơn 600 m tranh đã bị tháo dỡ để mở rộng đường.',
 N'Đoạn "Hoa văn Việt Nam trong dòng chảy lịch sử" dài 810 m – đoạn lập kỷ lục|Tranh về các triều đại, phố cổ, làng nghề, lễ hội|Gốm của nhiều làng nghề: Bát Tràng, Phù Lãng, Chu Đậu, Bàu Trúc|Góc chụp ảnh nhiều màu sắc gần cầu Long Biên',
 N'Dọc đê sông Hồng (Yên Phụ – Trần Nhật Duật – Trần Quang Khải), Hà Nội',
 21.045356, 105.845973,
 N'Văn hóa',
 N'Ngắm cả ngày, dọc vỉa hè các tuyến phố ven đê.',
 N'Miễn phí.',
 62,
 N'Cả ngày',
 N'Miễn phí',
 N'30 – 60 phút',
 N'Sáng sớm hoặc chiều muộn khi nắng dịu, ánh sáng đẹp để chụp ảnh.',
 N'Đi bộ hoặc đạp xe trên vỉa hè sát tường đê, chú ý xe cộ|Đoạn gần cầu Long Biên dễ kết hợp đi bộ lên cầu|Mang nước, mũ vì tuyến đường dài và ít bóng râm',
 N'Chiều dài | Khoảng 3,85 km
Diện tích | Khoảng 6.950 m²
Khởi xướng | Họa sĩ, nhà báo Nguyễn Thu Thủy
Kỷ lục | Guinness – bức tranh gốm sứ lớn nhất thế giới (2010)
Khánh thành | 5/10/2010',
 N'2007 | Bắt đầu thực hiện dự án
5/10/2010 | Khánh thành, nhận bằng kỷ lục Guinness, gắn biển công trình 1.000 năm Thăng Long
Về sau | Hơn 600 m tranh bị tháo dỡ để mở rộng đường'),
(49, N'Vườn Bách Thảo Hà Nội',
 N'Công viên cây xanh lâu đời ngay sau Lăng Bác và Phủ Chủ tịch, nhiều cây cổ thụ, hồ nước và núi Sưa – "lá phổi xanh" yên tĩnh của quận Ba Đình, hợp đi dạo, chạy bộ, picnic.',
 N'Vườn được người Pháp lập năm 1890 trên khu đất rộng khoảng 33 ha phía sau dinh Toàn quyền, vừa làm vườn ươm, nghiên cứu cây trồng vừa nuôi thú, nên người Hà Nội xưa còn gọi là "Trại hoa" hay "Vườn thú". Ngày nay vườn là công viên Bách Thảo với hàng trăm loài cây, nhiều cây cổ thụ hàng trăm năm tuổi. Trên đỉnh núi Sưa trong vườn có đền Núi Sưa thờ Huyền Thiên Hắc Đế, được xếp hạng di tích năm 2015. Đầu năm 2026 hàng rào sắt quanh công viên được hạ xuống cho không gian thông thoáng hơn.',
 N'Hàng trăm loài cây, nhiều cây cổ thụ hàng trăm năm tuổi|Núi Sưa và đền Núi Sưa trên đỉnh|Hồ nước, đảo chim bồ câu, lối đi rợp bóng cây|Chỉ vài phút đi bộ tới Lăng Bác, Chùa Một Cột, Bảo tàng Hồ Chí Minh',
 N'3 Hoàng Hoa Thám, Ba Đình, Hà Nội (cổng phụ: 2 Ngọc Hà)',
 21.040158, 105.830700,
 N'Công viên',
 N'Khoảng 5:30 – 22:00 hằng ngày.',
 N'Miễn phí hoặc vé rất rẻ (trước đây khoảng 2.000đ/lượt).',
 64,
 N'Khoảng 5:30 – 22:00',
 N'Miễn phí – 2.000đ',
 N'1 – 2 giờ',
 N'Sáng sớm hoặc chiều mát; mùa thu lá vàng rất đẹp.',
 N'Sáng sớm, chiều mát có nhiều người tập thể dục, chạy bộ|Mang thảm, đồ ăn nhẹ để picnic (giữ vệ sinh chung)|Mùa hè nhiều muỗi – mang kem chống côn trùng',
 N'Thành lập | 1890
Diện tích ban đầu | Khoảng 33 ha
Cổng chính | 3 Hoàng Hoa Thám
Cổng phụ | 2 Ngọc Hà
Tên gọi khác | Công viên Bách Thảo',
 N'1890 | Người Pháp lập vườn bách thảo sau dinh Toàn quyền
2015 | Đền Núi Sưa trong vườn được xếp hạng di tích
2026 | Hạ rào sắt quanh công viên cho thông thoáng'),
(50, N'Rạp xiếc Trung ương',
 N'Sân khấu tròn khoảng 1.300 chỗ của Liên đoàn Xiếc Việt Nam, cạnh Công viên Thống Nhất – nơi diễn xiếc, ảo thuật và kịch xiếc thiếu nhi vào cuối tuần, dịp hè, lễ, Tết. Điểm vui chơi quen thuộc của các gia đình có trẻ nhỏ.',
 N'Liên đoàn Xiếc Việt Nam có tiền thân là Đoàn Xiếc nhân dân Trung ương, thành lập ngày 16/1/1956, do NSND Tạ Duy Hiển đặt nền móng. Rạp xiếc Trung ương – sân khấu tròn tại 67–69 Trần Nhân Tông – hoàn thành cuối năm 1991, là nơi tổ chức nhiều liên hoan xiếc toàn quốc và quốc tế. Năm 2025 Liên đoàn khai trương thêm Trung tâm nghệ thuật biểu diễn ("sân khấu vuông", khoảng 300 chỗ) ngay cạnh rạp; năm 2026 kỷ niệm 70 năm thành lập và mở bán vé trực tuyến.',
 N'Sân khấu tròn khoảng 1.300 chỗ ngồi|Tiết mục nhào lộn, đu bay, ảo thuật, xiếc thú|Kịch xiếc thiếu nhi dịp 1/6, Trung thu, Tết|Mua vé trực tuyến, nhận mã QR trên điện thoại',
 N'67–69 Trần Nhân Tông, Hai Bà Trưng, Hà Nội',
 21.016726, 105.842420,
 N'Vui chơi',
 N'Theo lịch diễn: thường tối cuối tuần, thêm suất sáng/chiều dịp hè, lễ, Tết.',
 N'Thường khoảng 150.000 – 250.000đ tùy chương trình; mua tại quầy hoặc trực tuyến (xiecvietnam.vn).',
 72,
 N'Theo lịch diễn (tối cuối tuần)',
 N'Từ ~150.000đ',
 N'1,5 – 2 giờ',
 N'Tối thứ Bảy, Chủ nhật; dịp 1/6, Trung thu, Tết có chương trình riêng cho thiếu nhi.',
 N'Xem lịch diễn và đặt vé trước trên xiecvietnam.vn|Đến sớm 15 – 20 phút để gửi xe, ổn định chỗ ngồi|Kết hợp dạo Công viên Thống Nhất ngay bên cạnh',
 N'Đơn vị | Liên đoàn Xiếc Việt Nam
Thành lập | 16/1/1956 (Đoàn Xiếc nhân dân Trung ương)
Sức chứa | Khoảng 1.300 chỗ (sân khấu tròn)
Địa chỉ | 67–69 Trần Nhân Tông
Vé | Khoảng 150.000 – 250.000đ',
 N'1956 | Thành lập Đoàn Xiếc nhân dân Trung ương (16/1)
1991 | Hoàn thành rạp xiếc sân khấu tròn
2025 | Khai trương sân khấu vuông khoảng 300 chỗ cạnh rạp
2026 | Kỷ niệm 70 năm thành lập, mở bán vé trực tuyến')
) v(SortNo, Name, Description, History, Highlights, Address, Latitude, Longitude, Category, OpeningHours, TicketPrice, PopularityScore,
     HoursSummary, PriceFrom, VisitDuration, BestTime, Tips, Facts, Timeline)
WHERE NOT EXISTS (SELECT 1 FROM TouristAttractions a WHERE a.Name = v.Name)
ORDER BY v.SortNo;
GO
/* ---- 2. Anh dai dien + bo suu tap (Wikimedia Commons) ---- */
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/35-bao-tang-phu-nu-viet-nam.jpg', ImageCredit = N'Ảnh: Christophe95 / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Vietnamese_Women''s_Museum.jpg' WHERE Name = N'Bảo tàng Phụ nữ Việt Nam' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/35-bao-tang-phu-nu-viet-nam.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/36-den-quan-thanh.jpg', ImageCredit = N'Ảnh: Richard Mortel / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Quan_Thanh_Taoist_Temple,_Hanoi,_11th_century_and_later_(2)_(38496996631).jpg' WHERE Name = N'Đền Quán Thánh' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/36-den-quan-thanh.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/37-den-bach-ma.jpg', ImageCredit = N'Ảnh: Donald Trung / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Bach_Ma_Temple,_Hanoi_(2018)_01.jpg' WHERE Name = N'Đền Bạch Mã' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/37-den-bach-ma.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/38-chua-quan-su.jpg', ImageCredit = N'Ảnh: Benjamin Smith / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Hanoi_-_Qu%C3%A1n_S%E1%BB%A9_Temple_-_1.jpg' WHERE Name = N'Chùa Quán Sứ' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/38-chua-quan-su.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/39-phu-tay-ho.jpg', ImageCredit = N'Ảnh: Bùi Thụy Đào Nguyên / CC BY-SA 3.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Ph%E1%BB%A7_T%C3%A2y_H%E1%BB%93.jpg' WHERE Name = N'Phủ Tây Hồ' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/39-phu-tay-ho.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/40-ngoi-nha-di-san-87-ma-may.jpg', ImageCredit = N'Ảnh: Christophe95 / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Heritage_House_in_Hanoi.jpg' WHERE Name = N'Ngôi nhà di sản 87 Mã Mây' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/40-ngoi-nha-di-san-87-ma-may.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/41-o-quan-chuong.jpg', ImageCredit = N'Ảnh: Alex 69200 vx / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Quan-chuong-hanoi.jpg' WHERE Name = N'Ô Quan Chưởng' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/41-o-quan-chuong.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/42-cot-co-ha-noi.jpg', ImageCredit = N'Ảnh: Richard Mortel / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Flag_Tower_of_Hanoi,_1812_(2)_(37608528975).jpg' WHERE Name = N'Cột cờ Hà Nội' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/42-cot-co-ha-noi.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/43-ho-huu-tiep.jpg', ImageCredit = N'Ảnh: Richard Mortel / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Wreckage_of_American_B52_bomber_shot_down_in_1972,_Hanoi_(2)_(26721531019).jpg' WHERE Name = N'Hồ Hữu Tiệp (xác máy bay B-52)' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/43-ho-huu-tiep.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/44-bao-tang-chien-thang-b52.jpg', ImageCredit = N'Ảnh: kitmasterbloke / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:B-52_tail_fin_wreck.jpg' WHERE Name = N'Bảo tàng Chiến thắng B-52' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/44-bao-tang-chien-thang-b52.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/45-bao-tang-lich-su-quan-su-viet-nam.jpg', ImageCredit = N'Ảnh: Namdinhvodich / CC BY 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:B%E1%BA%A3o_t%C3%A0ng_L%E1%BB%8Bch_s%E1%BB%AD_Qu%C3%A2n_S%E1%BB%B1_Vi%E1%BB%87t_Nam_2024.jpg' WHERE Name = N'Bảo tàng Lịch sử Quân sự Việt Nam' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/45-bao-tang-lich-su-quan-su-viet-nam.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/46-bao-tang-phong-khong-khong-quan.jpg', ImageCredit = N'Ảnh: kitmasterbloke / CC BY 2.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:132_Douglas_AD-6_Skyraider_with_U-17_764_behind.jpg' WHERE Name = N'Bảo tàng Phòng không – Không quân' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/46-bao-tang-phong-khong-khong-quan.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/47-bao-tang-ha-noi.jpg', ImageCredit = N'Ảnh: Daaé / Public domain / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Hanoi_Museum_02.JPG' WHERE Name = N'Bảo tàng Hà Nội' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/47-bao-tang-ha-noi.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/48-con-duong-gom-su-song-hong.jpg', ImageCredit = N'Ảnh: Diggers2004 / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:2017_11_25_141702_Vietnam_Hanoi_Ceramic-Mosaic-Mural_01.jpg' WHERE Name = N'Con đường gốm sứ sông Hồng' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/48-con-duong-gom-su-song-hong.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/49-vuon-bach-thao-ha-noi.jpg', ImageCredit = N'Ảnh: Daderot / CC0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:General_view_-_Hanoi_Botanical_Garden_-_Hanoi,_Vietnam_-_DSC03557.JPG' WHERE Name = N'Vườn Bách Thảo Hà Nội' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/49-vuon-bach-thao-ha-noi.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/50-rap-xiec-trung-uong.jpg', ImageCredit = N'Ảnh: Newone / CC BY-SA 3.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:RapxiecTrungUong-HaNoi-18122008476.jpg' WHERE Name = N'Rạp xiếc Trung ương' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/50-rap-xiec-trung-uong.jpg');
GO
INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
SELECT a.AttractionId, v.ImageUrl, v.Caption, v.Credit, v.SourceUrl, v.SortOrder
FROM (VALUES
(N'Bảo tàng Phụ nữ Việt Nam', '/images/attractions/gallery/35-bao-tang-phu-nu-viet-nam-1.jpg', N'Nón, mẹt sắp đặt lơ lửng giữa giếng trời bảo tàng', N'Daderot / CC0', 'https://commons.wikimedia.org/wiki/File:Interior_view_-_Vietnamese_Women''s_Museum_-_Hanoi,_Vietnam_-_DSC04226.JPG', 1),
(N'Bảo tàng Phụ nữ Việt Nam', '/images/attractions/gallery/35-bao-tang-phu-nu-viet-nam-2.jpg', N'Phòng trưng bày Thời trang phụ nữ', N'Aumusee / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Vietnamese_Women''s_Museum,_Women''s_Fashion_section.JPG', 2),
(N'Bảo tàng Phụ nữ Việt Nam', '/images/attractions/gallery/35-bao-tang-phu-nu-viet-nam-3.jpg', N'Chuyên đề Phụ nữ trong lịch sử', N'Aumusee / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Vietnamese_Women''s_Museum,_Women_in_History_section.JPG', 3),
(N'Bảo tàng Phụ nữ Việt Nam', '/images/attractions/gallery/35-bao-tang-phu-nu-viet-nam-4.jpg', N'Tượng Mẹ Việt Nam ở sảnh chính', N'Clément Chevallier / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Hall_of_Vietnamese_Women''s_Museum.jpg', 4),
(N'Bảo tàng Phụ nữ Việt Nam', '/images/attractions/gallery/35-bao-tang-phu-nu-viet-nam-5.jpg', N'Trưng bày đồ dùng sinh hoạt trong gia đình', N'Daderot / CC0', 'https://commons.wikimedia.org/wiki/File:Everyday_objects_display_-_Vietnamese_Women''s_Museum_-_Hanoi,_Vietnam_-_DSC04214.JPG', 5),
(N'Đền Quán Thánh', '/images/attractions/gallery/36-den-quan-thanh-1.jpg', N'Tượng Huyền Thiên Trấn Vũ bằng đồng đen', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:Quan_Thanh_Temple_(9753836445).jpg', 1),
(N'Đền Quán Thánh', '/images/attractions/gallery/36-den-quan-thanh-2.jpg', N'Sân đền rợp bóng cây cổ thụ', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Quan_Thanh_Taoist_Temple,_Hanoi,_11th_century_and_later_(8)_(24624774308).jpg', 2),
(N'Đền Quán Thánh', '/images/attractions/gallery/36-den-quan-thanh-3.jpg', N'Đắp nổi rồng chầu trên cổng đền', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Quan_Thanh_Taoist_Temple,_Hanoi,_11th_century_and_later_(20)_(26721111609).jpg', 3),
(N'Đền Quán Thánh', '/images/attractions/gallery/36-den-quan-thanh-4.jpg', N'Khánh đồng cổ trong đền', N'Nguyễn Thanh Quang / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Kh%C3%A1nh_%C4%91%E1%BB%93ng,_%C4%91%E1%BB%81n_Qu%C3%A1n_Th%C3%A1nh.JPG', 4),
(N'Đền Quán Thánh', '/images/attractions/gallery/36-den-quan-thanh-5.jpg', N'Đền Quán Thánh trên bưu ảnh đầu thế kỷ XX', N'Không rõ tác giả / Public domain', 'https://commons.wikimedia.org/wiki/File:Hano%C3%AF_-_Pagode_du_Grand_Bouddha.jpg', 5),
(N'Đền Bạch Mã', '/images/attractions/gallery/37-den-bach-ma-1.jpg', N'Đền Bạch Mã ở góc phố Hàng Buồm – Hàng Giầy', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:B%E1%BA%A1ch_M%C3%A3_Temple_1.jpg', 1),
(N'Đền Bạch Mã', '/images/attractions/gallery/37-den-bach-ma-2.jpg', N'Tượng ngựa trắng – biểu tượng của đền', N'Greg Willis / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Bac_Ma_Temple_-_there''s_the_white_horse.jpg', 2),
(N'Đền Bạch Mã', '/images/attractions/gallery/37-den-bach-ma-3.jpg', N'Đồ lễ dâng trong đền', N'Caitriana Nicholson / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Temple_offering_(4855450265).jpg', 3),
(N'Đền Bạch Mã', '/images/attractions/gallery/37-den-bach-ma-4.jpg', N'Bảng giới thiệu di tích trong đền', N'Donald Trung / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Bach_Ma_Temple,_Hanoi_(2018)_02.jpg', 4),
(N'Chùa Quán Sứ', '/images/attractions/gallery/38-chua-quan-su-1.jpg', N'Cổng tam quan với gác chuông', N'Guerinf / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Pagode_Qu%C3%A1n_S%E1%BB%A9_(1).jpg', 1),
(N'Chùa Quán Sứ', '/images/attractions/gallery/38-chua-quan-su-2.jpg', N'Tượng Phật trên ban thờ chính điện', N'Jean-Pierre Dalbéra / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Autel_dans_la_pagode_des_Ambassadeurs_(Hanoi)_(4359941582).jpg', 2),
(N'Chùa Quán Sứ', '/images/attractions/gallery/38-chua-quan-su-3.jpg', N'Lối vào chính điện với lư hương lớn', N'Jean-Pierre Dalbéra / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Lentr%C3%A9e_de_la_pagode_des_Ambassadeurs_(Hanoi)_(4359941764).jpg', 3),
(N'Chùa Quán Sứ', '/images/attractions/gallery/38-chua-quan-su-4.jpg', N'Mái ngói cong trong khuôn viên chùa', N'Guerinf / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Pagode_Qu%C3%A1n_S%E1%BB%A9_(7).jpg', 4),
(N'Chùa Quán Sứ', '/images/attractions/gallery/38-chua-quan-su-5.jpg', N'Chùa Quán Sứ lên đèn về đêm', N'Alexey Komarov / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Quan_Su_Pagoda_at_night,_Hanoi,_14_March_2019.jpg', 5),
(N'Phủ Tây Hồ', '/images/attractions/gallery/39-phu-tay-ho-1.jpg', N'Cổng Phủ Tây Hồ', N'Vuong Tri Binh / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Phu_Tay_Ho_in_2015_01.jpg', 1),
(N'Phủ Tây Hồ', '/images/attractions/gallery/39-phu-tay-ho-2.jpg', N'Một gian điện thờ trong khuôn viên phủ', N'Vuong Tri Binh / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Phu_Tay_Ho_in_2015_03.jpg', 2),
(N'Phủ Tây Hồ', '/images/attractions/gallery/39-phu-tay-ho-3.jpg', N'Lầu thờ với bậc thềm đá', N'Vuong Tri Binh / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Phu_Tay_Ho_in_2015_05.jpg', 3),
(N'Phủ Tây Hồ', '/images/attractions/gallery/39-phu-tay-ho-4.jpg', N'Sân phủ nhìn ra Hồ Tây', N'Vuong Tri Binh / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Phu_Tay_Ho_in_2015_04.jpg', 4),
(N'Phủ Tây Hồ', '/images/attractions/gallery/39-phu-tay-ho-5.jpg', N'Mái ngói cổ trong khuôn viên phủ', N'Vuong Tri Binh / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Phu_Tay_Ho_in_2015_10.jpg', 5),
(N'Ngôi nhà di sản 87 Mã Mây', '/images/attractions/gallery/40-ngoi-nha-di-san-87-ma-may-1.jpg', N'Gian thờ tổ tiên trang nghiêm', N'Guerinf / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Maison_longue_traditionnelle_(1).jpg', 1),
(N'Ngôi nhà di sản 87 Mã Mây', '/images/attractions/gallery/40-ngoi-nha-di-san-87-ma-may-2.jpg', N'Sân trời và hành lang tầng hai', N'Guerinf / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Maison_longue_traditionnelle_(4).jpg', 2),
(N'Ngôi nhà di sản 87 Mã Mây', '/images/attractions/gallery/40-ngoi-nha-di-san-87-ma-may-3.jpg', N'Cửa bức bàn bằng gỗ', N'Guerinf / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Maison_longue_traditionnelle_(2).jpg', 3),
(N'Ngôi nhà di sản 87 Mã Mây', '/images/attractions/gallery/40-ngoi-nha-di-san-87-ma-may-4.jpg', N'Mặt nhà gỗ nhìn từ sân trong', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Heritage_House_(Hanoi).jpg', 4),
(N'Ngôi nhà di sản 87 Mã Mây', '/images/attractions/gallery/40-ngoi-nha-di-san-87-ma-may-5.jpg', N'Phố Mã Mây (phố Cờ Đen) trên bưu ảnh thời Pháp', N'Pierre Dieulefils / Public domain', 'https://commons.wikimedia.org/wiki/File:Hano%C3%AF_-_Rue_des_Pavillons_Noirs.jpg', 5),
(N'Ô Quan Chưởng', '/images/attractions/gallery/41-o-quan-chuong-1.jpg', N'Vọng lâu phía trên cửa ô', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:%C4%90%C3%B4ng-Hoa_Gate.jpg', 1),
(N'Ô Quan Chưởng', '/images/attractions/gallery/41-o-quan-chuong-2.jpg', N'Tấm bia đá gắn bên cửa ô', N'Phan Minh Tuấn / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Bia_%C4%91%C3%A1,_%C3%B4_Quan_Ch%C6%B0%E1%BB%9Fng,_H%C3%A0_N%E1%BB%99i_001.JPG', 2),
(N'Ô Quan Chưởng', '/images/attractions/gallery/41-o-quan-chuong-3.jpg', N'Cánh cổng gỗ cũ của cửa ô', N'Phan Minh Tuấn / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:C%E1%BB%95ng_g%E1%BB%97,_%C3%B4_Quan_Ch%C6%B0%E1%BB%9Fng,_H%C3%A0_N%E1%BB%99i_001.JPG', 3),
(N'Ô Quan Chưởng', '/images/attractions/gallery/41-o-quan-chuong-4.jpg', N'Lối đi nhỏ phía bắc cửa ô', N'Phan Minh Tuấn / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:L%E1%BB%91i_b%C3%AAn_b%E1%BA%AFc_%C3%B4_Quan_Ch%C6%B0%E1%BB%9Fng,_H%C3%A0_N%E1%BB%99i_001.JPG', 4),
(N'Ô Quan Chưởng', '/images/attractions/gallery/41-o-quan-chuong-5.jpg', N'Cửa ô nhìn từ phố Đào Duy Từ', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:%C4%90%C3%B4ng-Hoa_Gate_and_%C4%90%C3%A0o_Duy_T%E1%BB%AB_Street.jpg', 5),
(N'Cột cờ Hà Nội', '/images/attractions/gallery/42-cot-co-ha-noi-1.jpg', N'Vọng lâu bát giác và lá cờ trên đỉnh', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Flag_Tower_of_Hanoi,_1812_(3)_(37608503235).jpg', 1),
(N'Cột cờ Hà Nội', '/images/attractions/gallery/42-cot-co-ha-noi-2.jpg', N'Ba tầng đế hình chóp vuông cụt', N'Chelsea Hicks / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_Flag_Tower.jpg', 2),
(N'Cột cờ Hà Nội', '/images/attractions/gallery/42-cot-co-ha-noi-3.jpg', N'Cột cờ lên đèn về đêm', N'Bex Walton / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_Flag_Tower_by_night_(26400791083).jpg', 3),
(N'Cột cờ Hà Nội', '/images/attractions/gallery/42-cot-co-ha-noi-4.jpg', N'Cột cờ giữa hàng cây xanh', N'Khoitran1957 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:20180506_Flag_Tower_of_Hanoi_HDR.jpg', 4),
(N'Cột cờ Hà Nội', '/images/attractions/gallery/42-cot-co-ha-noi-5.jpg', N'Cột cờ và hàng phượng vĩ năm 1921 (ảnh màu autochrome)', N'Léon Busy / CC0', 'https://commons.wikimedia.org/wiki/File:Les_flamboyants_et_la_tour_Cot_Co_(%22_Tour_du_drapeau_%22)_-_A36139.jpg', 5),
(N'Hồ Hữu Tiệp (xác máy bay B-52)', '/images/attractions/gallery/43-ho-huu-tiep-1.jpg', N'Hồ Hữu Tiệp giữa khu dân cư Ngọc Hà', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Wreckage_of_American_B52_bomber_shot_down_in_1972,_Hanoi_(1)_(24625091328).jpg', 1),
(N'Hồ Hữu Tiệp (xác máy bay B-52)', '/images/attractions/gallery/43-ho-huu-tiep-2.jpg', N'Xác B-52 nhìn từ bờ hồ', N'Pdhadam / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:B52_wreckage,_H%E1%BB%AFu_Ti%E1%BB%87p_Lake,_Hanoi_(landscape).jpg', 2),
(N'Hồ Hữu Tiệp (xác máy bay B-52)', '/images/attractions/gallery/43-ho-huu-tiep-3.jpg', N'Bia kỷ niệm chiến công bên hồ', N'David Berkowitz / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:H%E1%BB%93_H%E1%BB%AFu_Ti%E1%BB%87p.jpg', 3),
(N'Hồ Hữu Tiệp (xác máy bay B-52)', '/images/attractions/gallery/43-ho-huu-tiep-4.jpg', N'Biển ghi lại sự kiện đêm 27/12/1972', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Plaque_about_American_B52_bomber_shot_down_over_Hanoi_in_1972_(26721472819).jpg', 4),
(N'Hồ Hữu Tiệp (xác máy bay B-52)', '/images/attractions/gallery/43-ho-huu-tiep-5.jpg', N'Phần xác máy bay nằm giữa mặt nước', N'Mark Limb / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Wreckage_of_B52_bomber,_downtown_Hanoi,_Vietnam.jpg', 5),
(N'Bảo tàng Chiến thắng B-52', '/images/attractions/gallery/44-bao-tang-chien-thang-b52-1.jpg', N'Mảnh xác máy bay B-52 ngoài trời', N'kitmasterbloke / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:B-52_wreckage.jpg', 1),
(N'Bảo tàng Chiến thắng B-52', '/images/attractions/gallery/44-bao-tang-chien-thang-b52-2.jpg', N'Động cơ máy bay B-52 bị bắn rơi', N'Mztourist / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:B-52_engines.jpg', 2),
(N'Bảo tàng Chiến thắng B-52', '/images/attractions/gallery/44-bao-tang-chien-thang-b52-3.jpg', N'Đuôi B-52 trước nhà trưng bày', N'Mztourist / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:B-52_tail_section_and_museum_building.jpg', 3),
(N'Bảo tàng Chiến thắng B-52', '/images/attractions/gallery/44-bao-tang-chien-thang-b52-4.jpg', N'Pháo cao xạ trong khu trưng bày ngoài trời', N'kitmasterbloke / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Left-_14.5mm_AA_gune_which_downed_an_F-4_140572_and_right_-_37mm_AA_gun_from_Hanoi_division.jpg', 4),
(N'Bảo tàng Lịch sử Quân sự Việt Nam', '/images/attractions/gallery/45-bao-tang-lich-su-quan-su-viet-nam-1.jpg', N'Máy bay MiG-21 trong không gian trưng bày', N'Namdinhvodich / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:B%E1%BA%A3o_t%C3%A0ng_L%E1%BB%8Bch_s%E1%BB%AD_Qu%C3%A2n_S%E1%BB%B1_Vi%E1%BB%87t_Nam_2024_(2).jpg', 1),
(N'Bảo tàng Lịch sử Quân sự Việt Nam', '/images/attractions/gallery/45-bao-tang-lich-su-quan-su-viet-nam-2.jpg', N'Tòa nhà trưng bày chính', N'kitmasterbloke / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Museum_building_Vietnam_Military_History_Museum.jpg', 2),
(N'Bảo tàng Lịch sử Quân sự Việt Nam', '/images/attractions/gallery/45-bao-tang-lich-su-quan-su-viet-nam-3.jpg', N'Xe tăng T-34 và T-54B ngoài trời', N'kitmasterbloke / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:250_T-34_and_985_T-54B_used_to_capture_the_South_Vietnam_HQ.jpg', 3),
(N'Bảo tàng Lịch sử Quân sự Việt Nam', '/images/attractions/gallery/45-bao-tang-lich-su-quan-su-viet-nam-4.jpg', N'Tên lửa SAM-2 và bệ phóng', N'kitmasterbloke / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:SAM-2_Guideline_missile_and_launcher.jpg', 4),
(N'Bảo tàng Lịch sử Quân sự Việt Nam', '/images/attractions/gallery/45-bao-tang-lich-su-quan-su-viet-nam-5.jpg', N'Xe vận tải quân sự trong khu trưng bày', N'Namdinhvodich / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:B%E1%BA%A3o_t%C3%A0ng_L%E1%BB%8Bch_s%E1%BB%AD_Qu%C3%A2n_S%E1%BB%B1_Vi%E1%BB%87t_Nam_2024_(6).jpg', 5),
(N'Bảo tàng Phòng không – Không quân', '/images/attractions/gallery/46-bao-tang-phong-khong-khong-quan-1.jpg', N'Động cơ, mảnh xác B-52 và F-4 bị bắn rơi', N'kitmasterbloke / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Wrecked_engines_from_B52_and_F4_and_McDonnell_Phantom_II_wreckage.jpg', 1),
(N'Bảo tàng Phòng không – Không quân', '/images/attractions/gallery/46-bao-tang-phong-khong-khong-quan-2.jpg', N'Máy bay TL-1 do Việt Nam chế tạo', N'kitmasterbloke / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:01_TL-1_Reconnaissance_aircraft_First_Flight_240980.jpg', 2),
(N'Bảo tàng Phòng không – Không quân', '/images/attractions/gallery/46-bao-tang-phong-khong-khong-quan-3.jpg', N'Máy bay Ilyushin Il-14 của Hàng không Việt Nam', N'Aeroprints.com / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:VN-C482_Ilyushin_IL.14_Hang_Khong_Viet_Nam_(7879773402).jpg', 3),
(N'Bảo tàng Phòng không – Không quân', '/images/attractions/gallery/46-bao-tang-phong-khong-khong-quan-4.jpg', N'Ra-đa P-35 thời chiến', N'kitmasterbloke / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Soviet_P-35_Radar_antenna.jpg', 4),
(N'Bảo tàng Phòng không – Không quân', '/images/attractions/gallery/46-bao-tang-phong-khong-khong-quan-5.jpg', N'Máy bay huấn luyện trưng bày ngoài trời', N'kitmasterbloke / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Trainer_-_54425974664.jpg', 5),
(N'Bảo tàng Hà Nội', '/images/attractions/gallery/47-bao-tang-ha-noi-1.jpg', N'Mặt tiền bảo tàng với hàng cờ', N'Daaé / Public domain', 'https://commons.wikimedia.org/wiki/File:Hanoi_Museum_04.JPG', 1),
(N'Bảo tàng Hà Nội', '/images/attractions/gallery/47-bao-tang-ha-noi-2.jpg', N'Đường dốc xoắn bên trong bảo tàng', N'Daaé / Public domain', 'https://commons.wikimedia.org/wiki/File:Hanoi_Museum_Stairway_03.JPG', 2),
(N'Bảo tàng Hà Nội', '/images/attractions/gallery/47-bao-tang-ha-noi-3.jpg', N'Đồ gốm thế kỷ I – III', N'Daaé / Public domain', 'https://commons.wikimedia.org/wiki/File:Ceramic,_1st_-_3rd_centery,_at_Hanoi_Museum.JPG', 3),
(N'Bảo tàng Hà Nội', '/images/attractions/gallery/47-bao-tang-ha-noi-4.jpg', N'Đồ gốm và tiền cổ thời Hán', N'Daaé / Public domain', 'https://commons.wikimedia.org/wiki/File:Coins,_Han_Dynasty,_Hanoi_Museum.JPG', 4),
(N'Bảo tàng Hà Nội', '/images/attractions/gallery/47-bao-tang-ha-noi-5.jpg', N'Không gian trưng bày tầng 2', N'Daaé / Public domain', 'https://commons.wikimedia.org/wiki/File:Hanoi_Museum_-_2nd_floor_01.JPG', 5),
(N'Con đường gốm sứ sông Hồng', '/images/attractions/gallery/48-con-duong-gom-su-song-hong-1.jpg', N'Tranh gốm chạy dọc tuyến phố ven đê', N'Diggers2004 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:2017_11_25_142837_Vietnam_Hanoi_Ceramic-Mosaic-Mural_x_20.jpg', 1),
(N'Con đường gốm sứ sông Hồng', '/images/attractions/gallery/48-con-duong-gom-su-song-hong-2.jpg', N'Đàn voi ghép bằng gốm', N'Diggers2004 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:2017_11_25_142837_Vietnam_Hanoi_Ceramic-Mosaic-Mural_x_12.jpg', 2),
(N'Con đường gốm sứ sông Hồng', '/images/attractions/gallery/48-con-duong-gom-su-song-hong-3.jpg', N'Tranh đình làng truyền thống', N'Diggers2004 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:2017_11_25_142218_Vietnam_Hanoi_Ceramic-Mosaic-Mural_copy_30.jpg', 3),
(N'Con đường gốm sứ sông Hồng', '/images/attractions/gallery/48-con-duong-gom-su-song-hong-4.jpg', N'Thuyền buồm trên tranh gốm', N'Diggers2004 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:2017_11_25_142218_Vietnam_Hanoi_Ceramic-Mosaic-Mural_copy_27.jpg', 4),
(N'Con đường gốm sứ sông Hồng', '/images/attractions/gallery/48-con-duong-gom-su-song-hong-5.jpg', N'Tranh gốm theo phong cách tranh thiếu nhi', N'Diggers2004 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:2017_11_25_141702_Vietnam_Hanoi_Ceramic-Mosaic-Mural_22.jpg', 5),
(N'Vườn Bách Thảo Hà Nội', '/images/attractions/gallery/49-vuon-bach-thao-ha-noi-1.jpg', N'Cổng vườn Bách Thảo', N'Daderot / CC0', 'https://commons.wikimedia.org/wiki/File:Gate_-_Hanoi_Botanical_Garden_-_Hanoi,_Vietnam_-_DSC03532.JPG', 1),
(N'Vườn Bách Thảo Hà Nội', '/images/attractions/gallery/49-vuon-bach-thao-ha-noi-2.jpg', N'Lồng chim nhiều tầng trong vườn', N'Daderot / CC0', 'https://commons.wikimedia.org/wiki/File:Bird_cage_-_Hanoi_Botanical_Garden_-_Hanoi,_Vietnam_-_DSC03538.JPG', 2),
(N'Vườn Bách Thảo Hà Nội', '/images/attractions/gallery/49-vuon-bach-thao-ha-noi-3.jpg', N'Ghế đá dưới tán cây cổ thụ', N'Daderot / CC0', 'https://commons.wikimedia.org/wiki/File:Couple_-_Hanoi_Botanical_Garden_-_Hanoi,_Vietnam_-_DSC03571.JPG', 3),
(N'Vườn Bách Thảo Hà Nội', '/images/attractions/gallery/49-vuon-bach-thao-ha-noi-4.jpg', N'Cây cảnh, non bộ trong vườn', N'Daderot / CC0', 'https://commons.wikimedia.org/wiki/File:Bridge_-_Hanoi_Botanical_Garden_-_Hanoi,_Vietnam_-_DSC03606.JPG', 4),
(N'Vườn Bách Thảo Hà Nội', '/images/attractions/gallery/49-vuon-bach-thao-ha-noi-5.jpg', N'Quán giải khát dưới bóng cây', N'Daderot / CC0', 'https://commons.wikimedia.org/wiki/File:Cafe_-_Hanoi_Botanical_Garden_-_Hanoi,_Vietnam_-_DSC03619.JPG', 5),
(N'Rạp xiếc Trung ương', '/images/attractions/gallery/50-rap-xiec-trung-uong-1.jpg', N'Rạp xiếc Trung ương trang trí mùa Giáng sinh', N'Newone / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:RapxiecTrungUong-HaNoi-18122008478.jpg', 1)
) v(Name, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
JOIN TouristAttractions a ON a.Name = v.Name
WHERE NOT EXISTS (SELECT 1 FROM AttractionImages x WHERE x.ImageUrl = v.ImageUrl);
GO
/* ---- 3. Tram gan (quang duong di bo that tu OSRM, du lieu OpenStreetMap) ---- */
INSERT INTO AttractionStations (AttractionId, StationId, WalkingDistance, WalkingDuration)
SELECT a.AttractionId, s.StationId, v.Dist, v.Dur
FROM (VALUES
(N'Bảo tàng Phụ nữ Việt Nam', 'BUS-0128', 33, 1),
(N'Bảo tàng Phụ nữ Việt Nam', 'BUS-0093', 248, 3),
(N'Bảo tàng Phụ nữ Việt Nam', 'BUS-0177', 311, 4),
(N'Bảo tàng Phụ nữ Việt Nam', 'BIKE-062', 76, 1),
(N'Bảo tàng Phụ nữ Việt Nam', 'EV-062', 76, 1),
(N'Đền Quán Thánh', 'BUS-0107', 821, 11),
(N'Đền Quán Thánh', 'BUS-0381', 953, 13),
(N'Đền Quán Thánh', 'BUS-0212', 1158, 15),
(N'Đền Quán Thánh', 'BIKE-037', 186, 2),
(N'Đền Quán Thánh', 'EV-037', 186, 2),
(N'Đền Bạch Mã', 'BUS-0050', 427, 6),
(N'Đền Bạch Mã', 'BUS-0029', 534, 7),
(N'Đền Bạch Mã', 'BUS-0228', 554, 7),
(N'Đền Bạch Mã', 'BIKE-025', 738, 10),
(N'Đền Bạch Mã', 'EV-025', 738, 10),
(N'Chùa Quán Sứ', 'BUS-0114', 75, 1),
(N'Chùa Quán Sứ', 'BUS-0112', 156, 2),
(N'Chùa Quán Sứ', 'BUS-0129', 284, 4),
(N'Chùa Quán Sứ', 'BIKE-059', 275, 4),
(N'Chùa Quán Sứ', 'EV-059', 275, 4),
(N'Phủ Tây Hồ', 'BUS-0379', 1930, 26),
(N'Phủ Tây Hồ', 'BUS-0378', 1953, 26),
(N'Phủ Tây Hồ', 'BUS-0214', 2025, 27),
(N'Ngôi nhà di sản 87 Mã Mây', 'BUS-0146', 221, 3),
(N'Ngôi nhà di sản 87 Mã Mây', 'BUS-0029', 232, 3),
(N'Ngôi nhà di sản 87 Mã Mây', 'BUS-0071', 426, 6),
(N'Ngôi nhà di sản 87 Mã Mây', 'BIKE-067', 795, 11),
(N'Ngôi nhà di sản 87 Mã Mây', 'EV-067', 795, 11),
(N'Ô Quan Chưởng', 'BUS-0050', 271, 4),
(N'Ô Quan Chưởng', 'BUS-0029', 486, 6),
(N'Ô Quan Chưởng', 'BUS-0146', 582, 8),
(N'Ô Quan Chưởng', 'BIKE-025', 793, 11),
(N'Ô Quan Chưởng', 'EV-025', 793, 11),
(N'Cột cờ Hà Nội', 'BUS-0178', 29, 1),
(N'Cột cờ Hà Nội', 'BUS-0382', 241, 3),
(N'Cột cờ Hà Nội', 'BUS-0119', 314, 4),
(N'Cột cờ Hà Nội', 'BIKE-022', 138, 2),
(N'Cột cờ Hà Nội', 'EV-022', 138, 2),
(N'Hồ Hữu Tiệp (xác máy bay B-52)', 'BUS-0120', 828, 11),
(N'Hồ Hữu Tiệp (xác máy bay B-52)', 'BUS-0180', 874, 12),
(N'Hồ Hữu Tiệp (xác máy bay B-52)', 'BUS-0388', 1024, 14),
(N'Hồ Hữu Tiệp (xác máy bay B-52)', 'BIKE-006', 787, 10),
(N'Hồ Hữu Tiệp (xác máy bay B-52)', 'EV-006', 787, 10),
(N'Bảo tàng Chiến thắng B-52', 'BUS-0180', 382, 5),
(N'Bảo tàng Chiến thắng B-52', 'BUS-0120', 556, 7),
(N'Bảo tàng Chiến thắng B-52', 'BUS-0434', 683, 9),
(N'Bảo tàng Chiến thắng B-52', 'METRO2A-01', 938, 13),
(N'Bảo tàng Chiến thắng B-52', 'BIKE-006', 115, 2),
(N'Bảo tàng Chiến thắng B-52', 'EV-006', 115, 2),
(N'Bảo tàng Lịch sử Quân sự Việt Nam', 'BUS-0446', 2985, 40),
(N'Bảo tàng Lịch sử Quân sự Việt Nam', 'BUS-0445', 3117, 42),
(N'Bảo tàng Lịch sử Quân sự Việt Nam', 'BUS-0452', 3573, 48),
(N'Bảo tàng Phòng không – Không quân', 'BUS-0090', 370, 5),
(N'Bảo tàng Phòng không – Không quân', 'BUS-0257', 1015, 14),
(N'Bảo tàng Phòng không – Không quân', 'BUS-0139', 1036, 14),
(N'Bảo tàng Phòng không – Không quân', 'BIKE-057', 927, 12),
(N'Bảo tàng Phòng không – Không quân', 'EV-057', 927, 12),
(N'Bảo tàng Hà Nội', 'BUS-0284', 195, 3),
(N'Bảo tàng Hà Nội', 'BUS-0442', 435, 6),
(N'Bảo tàng Hà Nội', 'BUS-0285', 630, 8),
(N'Con đường gốm sứ sông Hồng', 'BUS-0210', 225, 3),
(N'Con đường gốm sứ sông Hồng', 'BUS-0211', 235, 3),
(N'Con đường gốm sứ sông Hồng', 'BUS-0016', 265, 4),
(N'Con đường gốm sứ sông Hồng', 'BIKE-025', 752, 10),
(N'Con đường gốm sứ sông Hồng', 'EV-025', 752, 10),
(N'Vườn Bách Thảo Hà Nội', 'BUS-0120', 837, 11),
(N'Vườn Bách Thảo Hà Nội', 'BUS-0179', 945, 13),
(N'Vườn Bách Thảo Hà Nội', 'BUS-0388', 1068, 14),
(N'Vườn Bách Thảo Hà Nội', 'BIKE-037', 836, 11),
(N'Vườn Bách Thảo Hà Nội', 'EV-037', 836, 11),
(N'Rạp xiếc Trung ương', 'BUS-0383', 347, 5),
(N'Rạp xiếc Trung ương', 'BUS-0308', 362, 5),
(N'Rạp xiếc Trung ương', 'BUS-0030', 510, 7),
(N'Rạp xiếc Trung ương', 'BIKE-081', 889, 12),
(N'Rạp xiếc Trung ương', 'EV-081', 889, 12)
) v(Name, Code, Dist, Dur)
JOIN TouristAttractions a ON a.Name = v.Name
JOIN Stations s ON s.StationCode = v.Code
WHERE NOT EXISTS (SELECT 1 FROM AttractionStations x WHERE x.AttractionId = a.AttractionId AND x.StationId = s.StationId);
GO
SELECT COUNT(*) AS Attractions FROM TouristAttractions WHERE Status = 'ACTIVE';
SELECT a.AttractionId, a.Name, a.Category,
       (SELECT COUNT(*) FROM AttractionImages i WHERE i.AttractionId = a.AttractionId) AS Images,
       (SELECT COUNT(*) FROM AttractionStations s WHERE s.AttractionId = a.AttractionId) AS Stations
FROM TouristAttractions a WHERE a.AttractionId > 34 ORDER BY a.AttractionId;
GO
