/* =====================================================================
   10_attraction_guide.sql - Trang chi tiet dia diem day du hon + sua anh
   Chay tren database DA CO du lieu (an toan khi chay lai).
   - Them cot Facts (du kien nhanh) va Timeline (moc lich su): moi dong "nhan | gia tri"
   - Anh dai dien moi cho Pho co, Quang truong Ba Dinh, Chua Mot Cot, Van Mieu, Bao tang Lich su
     (anh cu: doc, do phan giai thap hoac trung voi bo suu tap)
   - Bo suu tap: thay anh co dau ngay gio / watermark, them anh cho Hoa Lo, Ba Dinh; sua chu thich sai
   Nguon anh: Wikimedia Commons (giay phep tu do) - xem frontend/public/images/attractions/CREDITS.md
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
USE PublicTransportDBV2;
GO
IF COL_LENGTH('TouristAttractions', 'Facts') IS NULL ALTER TABLE TouristAttractions ADD Facts NVARCHAR(MAX) NULL;
IF COL_LENGTH('TouristAttractions', 'Timeline') IS NULL ALTER TABLE TouristAttractions ADD Timeline NVARCHAR(MAX) NULL;
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

/* ---- Lich su: bo chi tiet chua kiem chung, bo sung moc da tra cuu ---- */
UPDATE TouristAttractions SET History = REPLACE(History, N'Phố mang tên Tạ Hiện, một tướng lĩnh chống Pháp cuối thế kỷ XIX. Trước đây phố có tên Hàng Guột. Từ những năm 2000, ngã tư Tạ Hiện – Lương Ngọc Quyến trở thành điểm hẹn "bia hơi" nổi tiếng, được gọi là "ngã tư quốc tế".', N'Thời Pháp thuộc, các đoạn phố cũ được gộp lại và mang tên Rue Géraud. Từ năm 1945, phố được đổi tên theo Tạ Hiện (1841 – 1887), một tướng lĩnh của phong trào Cần Vương chống Pháp. Người dân còn quen gọi là ngõ Quảng Lạc, theo tên rạp hát Quảng Lạc giữa phố. Ngày nay ngã tư Tạ Hiện – Lương Ngọc Quyến là điểm hẹn "bia hơi" nổi tiếng, được gọi là "ngã tư quốc tế"; từ năm 2014 phố nằm trong khu phố đi bộ cuối tuần.') WHERE History LIKE N'%Phố mang tên Tạ Hiện, một tướng lĩnh chố%';
UPDATE TouristAttractions SET History = REPLACE(History, N'Bảo tàng chính thức mở cửa năm 1966.', N'Bảo tàng Mỹ thuật Việt Nam được thành lập ngày 24/6/1966, hiện lưu giữ hơn 20.000 hiện vật.') WHERE History LIKE N'%Bảo tàng chính thức mở cửa năm 1966.%';
UPDATE TouristAttractions SET History = REPLACE(History, N'tên Tây Hồ có từ thời Lê.', N'năm 1573 hồ được đổi tên thành Tây Hồ để kiêng húy vua Lê Thế Tông.') WHERE History LIKE N'%tên Tây Hồ có từ thời Lê.%';

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
UPDATE AttractionImages SET Caption = N'Hoa giấy bên bờ Hồ Tây' WHERE ImageUrl = '/images/attractions/gallery/15-ho-tay-2.jpg';
UPDATE AttractionImages SET Caption = N'Hàng cọ ven hồ' WHERE ImageUrl = '/images/attractions/gallery/15-ho-tay-3.jpg';
UPDATE AttractionImages SET Caption = N'Chùa Trấn Quốc nhìn từ mặt hồ lúc chiều tà' WHERE ImageUrl = '/images/attractions/gallery/15-ho-tay-4.jpg';
GO
SELECT a.AttractionId, a.Name,
       (SELECT COUNT(*) FROM AttractionImages i WHERE i.AttractionId = a.AttractionId) AS Images,
       CASE WHEN a.Facts IS NULL THEN 0 ELSE 1 END AS HasFacts,
       CASE WHEN a.Timeline IS NULL THEN 0 ELSE 1 END AS HasTimeline
FROM TouristAttractions a ORDER BY a.AttractionId;
GO
