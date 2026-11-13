/* =====================================================================
   06_attraction_details.sql - Thong tin chi tiet + bo suu tap anh cho 20 diem tham quan
   Chay tren database DA CO du lieu (khong xoa du lieu khac). Chay sau 05_attraction_images.sql.
   - Them cot HoursSummary, PriceFrom, VisitDuration, BestTime, Tips
   - Tao bang AttractionImages (bo suu tap anh)
   - Cap nhat noi dung: gioi thieu, lich su, diem noi bat, gio mo cua, gia ve, luu y
     (gio mo cua / gia ve tra cuu thang 11/2026 - co the thay doi)
   ===================================================================== */
USE PublicTransportDBV2;
GO
ALTER TABLE TouristAttractions ALTER COLUMN OpeningHours NVARCHAR(500) NULL;
IF COL_LENGTH('TouristAttractions', 'HoursSummary') IS NULL ALTER TABLE TouristAttractions ADD HoursSummary NVARCHAR(100) NULL;
IF COL_LENGTH('TouristAttractions', 'PriceFrom') IS NULL ALTER TABLE TouristAttractions ADD PriceFrom NVARCHAR(50) NULL;
IF COL_LENGTH('TouristAttractions', 'VisitDuration') IS NULL ALTER TABLE TouristAttractions ADD VisitDuration NVARCHAR(100) NULL;
IF COL_LENGTH('TouristAttractions', 'BestTime') IS NULL ALTER TABLE TouristAttractions ADD BestTime NVARCHAR(300) NULL;
IF COL_LENGTH('TouristAttractions', 'Tips') IS NULL ALTER TABLE TouristAttractions ADD Tips NVARCHAR(MAX) NULL;
GO
IF OBJECT_ID('AttractionImages', 'U') IS NULL
BEGIN
    CREATE TABLE AttractionImages (
        ImageId       INT IDENTITY(1,1) PRIMARY KEY,
        AttractionId  INT            NOT NULL,
        ImageUrl      VARCHAR(500)   NOT NULL,
        Caption       NVARCHAR(200)  NULL,
        Credit        NVARCHAR(300)  NULL,
        SourceUrl     VARCHAR(500)   NULL,
        SortOrder     INT            NOT NULL DEFAULT 0,
        CONSTRAINT FK_AttractionImages_Attractions FOREIGN KEY (AttractionId)
            REFERENCES TouristAttractions(AttractionId)
    );
    CREATE INDEX IX_AttractionImages_Attraction ON AttractionImages(AttractionId, SortOrder);
END
GO

UPDATE TouristAttractions SET
  Description = N'Hồ nước rộng khoảng 12 ha giữa trung tâm Hà Nội, được xem là trái tim của thủ đô. Quanh hồ là phố đi bộ, Đền Ngọc Sơn, Tháp Bút và các con phố cổ, phố Pháp.',
  History = N'Xưa kia hồ có tên Lục Thủy vì nước xanh quanh năm. Theo truyền thuyết, sau khi đánh thắng quân Minh, vua Lê Lợi dạo thuyền trên hồ và trả lại gươm thần cho Rùa Vàng, từ đó hồ mang tên Hoàn Kiếm (trả gươm). Tháp Rùa trên gò giữa hồ được xây năm 1886. Từ năm 2016, các tuyến phố quanh hồ trở thành không gian đi bộ vào cuối tuần.',
  Highlights = N'Tháp Rùa trên gò giữa hồ, lung linh khi lên đèn|Cầu Thê Húc sơn đỏ dẫn vào Đền Ngọc Sơn|Tháp Bút – Đài Nghiên ở cửa đền|Phố đi bộ cuối tuần với biểu diễn đường phố, trò chơi dân gian|Buổi sáng sớm người dân tập thể dục, đi bộ quanh hồ',
  OpeningHours = N'Khu vực công cộng, mở cửa 24/24. Phố đi bộ quanh hồ: từ 19:00 thứ Sáu đến 24:00 Chủ nhật hằng tuần.',
  TicketPrice = N'Miễn phí. Riêng Đền Ngọc Sơn trên hồ thu vé 50.000đ/người lớn.',
  HoursSummary = N'Cả ngày · Phố đi bộ T6–CN', PriceFrom = N'Miễn phí', VisitDuration = N'1 – 2 giờ',
  BestTime = N'Sáng sớm (5:30–7:00) khi hồ yên tĩnh, hoặc tối thứ Sáu – Chủ nhật khi có phố đi bộ.',
  Tips = N'Đi một vòng quanh hồ khoảng 1,7 km, mất 30–40 phút đi bộ|Cuối tuần ô tô, xe máy bị cấm quanh hồ – nên đi bộ hoặc gửi xe ở các phố lân cận|Kết hợp Đền Ngọc Sơn, Nhà hát Múa rối Thăng Long và phố cổ trong cùng một buổi',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Hồ Hoàn Kiếm';
UPDATE TouristAttractions SET
  Description = N'Ngôi đền trên đảo Ngọc ở phía bắc hồ Hoàn Kiếm, nối với bờ bằng cầu Thê Húc sơn đỏ – một trong những hình ảnh biểu tượng của Hà Nội.',
  History = N'Đền thờ Văn Xương Đế Quân (vị thần coi việc văn chương, thi cử) và Đức Thánh Trần Hưng Đạo – người ba lần đánh thắng quân Nguyên Mông. Năm 1865, nhà nho Nguyễn Văn Siêu đứng ra tu sửa đền, dựng thêm Tháp Bút, Đài Nghiên và cầu Thê Húc. Trong đền hiện trưng bày tiêu bản cụ Rùa Hồ Gươm – cá thể rùa Hoàn Kiếm mất năm 2016.',
  Highlights = N'Cầu Thê Húc ("nơi đậu ánh sáng ban mai")|Tháp Bút và Đài Nghiên ở lối vào|Đắc Nguyệt Lâu và Trấn Ba Đình|Tiêu bản cụ Rùa Hồ Gươm trong tủ kính|Kiến trúc đình, đền thế kỷ XIX',
  OpeningHours = N'Thứ Hai – thứ Sáu: 7:00 – 18:00. Thứ Bảy, Chủ nhật: 7:00 – 21:00. Giờ có thể thay đổi dịp Tết và lễ lớn.',
  TicketPrice = N'Người lớn: 50.000đ (áp dụng từ 01/2024). Nên hỏi quầy vé về mức giảm cho học sinh, sinh viên.',
  HoursSummary = N'7:00 – 18:00 (cuối tuần đến 21:00)', PriceFrom = N'50.000đ', VisitDuration = N'30 – 45 phút',
  BestTime = N'Buổi sáng để có ánh sáng đẹp trên cầu Thê Húc; tối cuối tuần khi hồ lên đèn.',
  Tips = N'Ăn mặc kín đáo (che vai, đầu gối), giữ trật tự trong khu thờ|Không chạm vào ban thờ, đồ lễ; chụp ảnh người đang lễ cần tế nhị|Cầu Thê Húc có thể đóng vào các dịp lễ hội lớn',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Đền Ngọc Sơn';
UPDATE TouristAttractions SET
  Description = N'Khu "36 phố phường" phía bắc hồ Hoàn Kiếm với những dãy nhà ống, mái ngói cổ và các con phố mang tên nghề truyền thống như Hàng Bạc, Hàng Mã, Hàng Đường, Hàng Gai.',
  History = N'Khu phố cổ hình thành từ thời Lý – Trần, là nơi các phường thợ thủ công và thương nhân tụ họp buôn bán bên ngoài hoàng thành. Mỗi phố thường chuyên một mặt hàng nên tên phố gắn với chữ "Hàng". Ô Quan Chưởng là cửa ô duy nhất còn lại của kinh thành Thăng Long; nhà cổ 87 Mã Mây giữ nguyên kiến trúc nhà ống cuối thế kỷ XIX.',
  Highlights = N'Ô Quan Chưởng – cửa ô cổ duy nhất còn lại|Nhà cổ 87 Mã Mây, đình Kim Ngân, đền Bạch Mã|Phố Hàng Mã rực rỡ đồ trang trí theo mùa lễ hội|Chợ đêm cuối tuần Hàng Đào – Đồng Xuân|Ẩm thực đường phố: phở, bún chả, bánh cuốn, cà phê trứng',
  OpeningHours = N'Khu dân cư mở cửa cả ngày. Chợ đêm phố cổ: khoảng 18:00 – 24:00 thứ Sáu, thứ Bảy, Chủ nhật (Hàng Đào → Đồng Xuân).',
  TicketPrice = N'Đi dạo miễn phí. Một số di tích bán vé riêng (ví dụ nhà cổ 87 Mã Mây).',
  HoursSummary = N'Cả ngày · Chợ đêm T6–CN', PriceFrom = N'Miễn phí', VisitDuration = N'Nửa ngày',
  BestTime = N'Sáng sớm để thấy nhịp sống buôn bán, hoặc tối cuối tuần khi có phố đi bộ và chợ đêm.',
  Tips = N'Đường hẹp, đông xe máy – đi bộ cẩn thận, giữ túi xách phía trước|Mặc cả khi mua hàng lưu niệm|Nên đi theo tuyến Hàng Đào – Hàng Ngang – Hàng Đường để tới chợ Đồng Xuân',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Phố cổ Hà Nội';
UPDATE TouristAttractions SET
  Description = N'Chợ có mái che lâu đời và lớn nhất Hà Nội, ba tầng bán buôn, bán lẻ đủ loại hàng: vải vóc, quần áo, đồ gia dụng, đồ khô và đặc sản.',
  History = N'Chợ được người Pháp xây dựng năm 1889 để tập trung buôn bán trong khu phố cổ, mặt tiền có 5 vòm cổng đặc trưng. Năm 1994, một trận hỏa hoạn lớn thiêu rụi phần lớn công trình; chợ được xây lại và hoàn thành năm 1996, giữ lại mặt tiền năm vòm.',
  Highlights = N'Mặt tiền năm vòm cổng từ thời Pháp|Tầng 1: vải vóc, quần áo, đồ khô, thực phẩm|Các tầng trên: đồ gia dụng, phụ kiện, hàng bán buôn|Phố ẩm thực Hàng Khoai phía sau chợ buổi tối|Điểm cuối của chợ đêm phố cổ cuối tuần',
  OpeningHours = N'Chợ hoạt động từ sáng sớm đến chiều (khoảng 6:00 – 18:00, nhiều quầy dọn hàng từ sau 14:00). Chợ đêm khu Đồng Xuân: khoảng 18:00 – 24:00 thứ Sáu – Chủ nhật.',
  TicketPrice = N'Vào chợ miễn phí.',
  HoursSummary = N'Khoảng 6:00 – 18:00', PriceFrom = N'Miễn phí', VisitDuration = N'1 – 1,5 giờ',
  BestTime = N'9:00 – 11:00 khi chợ đã đông hàng nhưng bớt cảnh bốc dỡ buổi sáng sớm.',
  Tips = N'Mang tiền mặt, phần lớn quầy không nhận thẻ|Vải ở đây thường rẻ hơn nhiều so với phố Hàng Gai; nên mặc cả|Hỏi trước khi chụp ảnh người bán; giữ đồ cẩn thận ở chỗ đông',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Chợ Đồng Xuân';
UPDATE TouristAttractions SET
  Description = N'Công trình kiến trúc Pháp tiêu biểu tại Quảng trường Cách mạng Tháng Tám, nơi biểu diễn opera, nhạc giao hưởng và các chương trình nghệ thuật lớn của thủ đô.',
  History = N'Nhà hát được xây dựng từ năm 1901 đến 1911, lấy cảm hứng từ Nhà hát Opera Garnier ở Paris, mang phong cách tân cổ điển kết hợp chi tiết Baroque. Tháng 8/1945, quảng trường trước nhà hát là nơi diễn ra cuộc mít tinh lớn mở đầu cho cuộc Tổng khởi nghĩa giành chính quyền ở Hà Nội.',
  Highlights = N'Mặt tiền tân cổ điển với mái vòm và cột đá|Cầu thang đá hình chữ T ở sảnh chính|Phòng Gương dành cho lễ tân, hội họp|Khán phòng hình móng ngựa khoảng 600 ghế|Quảng trường Cách mạng Tháng Tám phía trước',
  OpeningHours = N'Tham quan bên trong theo tour có hướng dẫn vào các ngày, khung giờ cố định (60 – 90 phút) và theo lịch biểu diễn buổi tối. Nên xem lịch trên kênh chính thức của nhà hát trước khi đi.',
  TicketPrice = N'Tour tham quan: khoảng 120.000 – 400.000đ tùy gói (có gói kèm biểu diễn ngắn). Vé biểu diễn từ khoảng 300.000đ, các đêm gala cao hơn nhiều.',
  HoursSummary = N'Theo lịch tour và biểu diễn', PriceFrom = N'Từ ~120.000đ (tour)', VisitDuration = N'1 – 1,5 giờ (tour)',
  BestTime = N'Chiều muộn để chụp mặt tiền; buổi tối khi có chương trình biểu diễn.',
  Tips = N'Đặt tour hoặc vé trước vài ngày, dịp lễ nên đặt trước 2 – 4 tuần|Trang phục lịch sự, tránh quần đùi, dép lê khi xem biểu diễn|Chụp ảnh thường được phép trong tour nhưng bị cấm khi đang biểu diễn',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Nhà hát Lớn Hà Nội';
UPDATE TouristAttractions SET
  Description = N'Di tích nhà tù do thực dân Pháp xây dựng, nơi giam giữ nhiều thế hệ chiến sĩ cách mạng Việt Nam và sau này là phi công Mỹ bị bắn rơi trong chiến tranh.',
  History = N'Nhà tù được người Pháp xây năm 1896 với tên Maison Centrale, là một trong những nhà tù lớn nhất Đông Dương thời bấy giờ. Nhiều lãnh đạo cách mạng từng bị giam tại đây. Trong chiến tranh chống Mỹ, nơi này giam giữ phi công Mỹ và được họ gọi đùa là "Hanoi Hilton". Phần lớn khu nhà tù bị phá dỡ vào thập niên 1990; phần còn lại được bảo tồn làm di tích.',
  Highlights = N'Cổng "Maison Centrale" nguyên bản|Khu tái hiện buồng giam, xà lim, máy chém|Đường hầm và câu chuyện những cuộc vượt ngục|Khu trưng bày về phi công Mỹ – "Hanoi Hilton"|Đài tưởng niệm các chiến sĩ cách mạng',
  OpeningHours = N'8:00 – 17:00 tất cả các ngày, kể cả lễ, Tết (quầy vé thường dừng bán khoảng 16:30). Tour đêm "Đêm thiêng liêng": tối thứ Sáu và thứ Bảy, 19:00 – 21:00, cần đặt trước.',
  TicketPrice = N'Người lớn: 50.000đ. Học sinh, sinh viên, người từ 60 tuổi: 25.000đ. Trẻ em dưới 15 tuổi: miễn phí. Thuyết minh tự động: 50.000đ/máy. Tour đêm: 399.000 – 499.000đ.',
  HoursSummary = N'8:00 – 17:00 hằng ngày', PriceFrom = N'50.000đ', VisitDuration = N'1,5 – 2 giờ',
  BestTime = N'Sáng các ngày trong tuần để tránh đông; tối thứ Sáu, thứ Bảy nếu tham gia tour đêm.',
  Tips = N'Nên thuê máy thuyết minh tự động để hiểu rõ từng khu trưng bày|Bỏ mũ, kính râm ở khu xà lim và khu tưởng niệm|Gửi balo lớn ở quầy gửi đồ miễn phí trước cửa soát vé',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Nhà tù Hỏa Lò';
UPDATE TouristAttractions SET
  Description = N'Quần thể di tích gắn với lịch sử kinh thành Thăng Long – Hà Nội suốt hơn 13 thế kỷ, được UNESCO công nhận là Di sản Văn hóa Thế giới năm 2010.',
  History = N'Năm 1010, vua Lý Thái Tổ dời đô từ Hoa Lư về Đại La, đặt tên là Thăng Long, mở đầu thời kỳ kinh đô kéo dài qua các triều Lý, Trần, Lê. Khu khảo cổ 18 Hoàng Diệu đã phát lộ nhiều tầng văn hóa chồng lên nhau từ thời tiền Thăng Long đến thời Nguyễn. Trong kháng chiến chống Mỹ, khu vực này là Sở chỉ huy Bộ Quốc phòng với Nhà và Hầm D67.',
  Highlights = N'Đoan Môn – cổng chính vào cấm thành|Nền điện Kính Thiên với đôi rồng đá thời Lê|Hậu Lâu (lầu Công chúa) và Bắc Môn|Khu khảo cổ 18 Hoàng Diệu|Nhà và Hầm D67, Cột cờ Hà Nội (xây năm 1812) gần đó',
  OpeningHours = N'8:00 – 17:00 tất cả các ngày trong tuần.',
  TicketPrice = N'Người lớn: 100.000đ. Học sinh, sinh viên từ 16 tuổi, người từ 60 tuổi: 50.000đ. Trẻ em dưới 16 tuổi: miễn phí. (Giá tham khảo, nên kiểm tra tại quầy vé.)',
  HoursSummary = N'8:00 – 17:00 hằng ngày', PriceFrom = N'100.000đ', VisitDuration = N'2 – 3 giờ',
  BestTime = N'Sáng sớm hoặc chiều muộn để tránh nắng, vì khu di tích rộng và nhiều đoạn ngoài trời.',
  Tips = N'Vé có thể mua online trên trang đặt vé của di tích (thanh toán thẻ)|Mang theo nước, mũ và giày thoải mái vì phải đi bộ nhiều|Kết hợp tham quan Cột cờ Hà Nội và Lăng Bác ở gần',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Hoàng thành Thăng Long';
UPDATE TouristAttractions SET
  Description = N'Nơi lưu giữ thi hài Chủ tịch Hồ Chí Minh, nằm trên Quảng trường Ba Đình, là công trình mang ý nghĩa thiêng liêng đặc biệt với người dân Việt Nam.',
  History = N'Lăng được khởi công ngày 2/9/1973 và khánh thành ngày 29/8/1975, với kiến trúc đá hoa cương mang dáng đài sen. Quần thể xung quanh gồm Phủ Chủ tịch, Nhà sàn Bác Hồ, ao cá, Bảo tàng Hồ Chí Minh và Chùa Một Cột.',
  Highlights = N'Viếng Bác trong phòng thi hài trang nghiêm|Đội tiêu binh danh dự đổi gác|Nhà sàn và ao cá Bác Hồ trong khu Phủ Chủ tịch|Bảo tàng Hồ Chí Minh|Lễ thượng cờ, hạ cờ trên Quảng trường Ba Đình',
  OpeningHours = N'Mùa hè (1/4 – 31/10): thứ Ba – thứ Năm 7:30 – 10:30; thứ Bảy, Chủ nhật, ngày lễ 7:30 – 11:00. Mùa đông (1/11 – 31/3): thứ Ba – thứ Năm 8:00 – 11:00; thứ Bảy, Chủ nhật, ngày lễ 8:00 – 11:30. Nghỉ thứ Hai và thứ Sáu. Hằng năm tạm dừng viếng khoảng 2 tháng để tu bổ (thường vào mùa thu) – cần xem thông báo chính thức.',
  TicketPrice = N'Viếng Lăng miễn phí.',
  HoursSummary = N'Sáng T3, T4, T5, T7, CN', PriceFrom = N'Miễn phí', VisitDuration = N'1 – 1,5 giờ (riêng Lăng), 3 – 4 giờ cả quần thể',
  BestTime = N'Đến sớm 30 – 45 phút trước giờ mở cửa, nhất là cuối tuần và ngày lễ.',
  Tips = N'Trang phục lịch sự: không mặc quần đùi, váy ngắn, áo hai dây, áo hở lưng|Gửi balo, máy ảnh ở nơi gửi đồ; không quay phim, chụp ảnh trong phòng thi hài|Bỏ mũ, không cho tay vào túi quần, giữ im lặng khi vào Lăng|Trẻ em dưới 3 tuổi không vào phòng thi hài',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Lăng Chủ tịch Hồ Chí Minh';
UPDATE TouristAttractions SET
  Description = N'Quảng trường lớn nhất Hà Nội, nơi diễn ra nhiều sự kiện chính trị quan trọng của đất nước, nằm trước Lăng Chủ tịch Hồ Chí Minh.',
  History = N'Ngày 2/9/1945, tại đây Chủ tịch Hồ Chí Minh đọc bản Tuyên ngôn Độc lập khai sinh nước Việt Nam Dân chủ Cộng hòa. Quảng trường gồm 168 ô cỏ xanh, là nơi tổ chức lễ duyệt binh, mít tinh trong các dịp kỷ niệm lớn.',
  Highlights = N'Lễ thượng cờ buổi sáng và hạ cờ lúc 21:00|Thảm cỏ rộng với 168 ô cỏ|Tầm nhìn ra Lăng Bác, Phủ Chủ tịch, Nhà Quốc hội|Không khí trang nghiêm, thoáng đãng buổi tối',
  OpeningHours = N'Khu vực công cộng. Lễ thượng cờ: 6:00 (tháng 4 – 10) hoặc 6:30 (tháng 11 – 3). Lễ hạ cờ: 21:00 hằng ngày.',
  TicketPrice = N'Miễn phí.',
  HoursSummary = N'Cả ngày · Thượng cờ 6:00 / 6:30', PriceFrom = N'Miễn phí', VisitDuration = N'30 – 60 phút',
  BestTime = N'Sáng sớm để xem lễ thượng cờ, hoặc 21:00 xem lễ hạ cờ.',
  Tips = N'Đến trước 20 – 30 phút để có chỗ xem lễ chào cờ|Đứng nghiêm, bỏ mũ trong lúc làm lễ; không đi vào khu vực có biển cấm|Không ngồi, nằm trên thảm cỏ',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Quảng trường Ba Đình';
UPDATE TouristAttractions SET
  Description = N'Ngôi chùa độc đáo hình đóa sen mọc lên từ mặt nước, đặt trên một cột đá giữa hồ vuông nhỏ, nằm trong khu di tích Ba Đình.',
  History = N'Chùa được xây năm 1049 dưới thời vua Lý Thái Tông, tên chữ là Diên Hựu. Theo sử chép, vua mộng thấy Phật Bà Quan Âm ngồi trên tòa sen dắt vua lên đài, sau đó cho dựng chùa theo hình ảnh ấy. Năm 1954, quân Pháp phá hủy chùa trước khi rút khỏi Hà Nội; chùa được dựng lại năm 1955 theo kiến trúc cũ.',
  Highlights = N'Đài sen gỗ trên cột trụ giữa hồ vuông|Tượng Quán Thế Âm Bồ Tát thờ trong điện|Cầu thang đá dẫn lên chùa|Hồ sen bao quanh|Ngay cạnh Lăng Bác và Bảo tàng Hồ Chí Minh',
  OpeningHours = N'Khoảng 7:00 – 18:00 hằng ngày (mùa đông đóng sớm hơn, khoảng 17:30). Có thể tạm đóng khi có sự kiện tại khu Lăng.',
  TicketPrice = N'Miễn phí.',
  HoursSummary = N'Khoảng 7:00 – 18:00', PriceFrom = N'Miễn phí', VisitDuration = N'15 – 30 phút',
  BestTime = N'7:00 – 8:00 hoặc sau 16:00 để tránh đoàn khách; ánh sáng buổi sáng chụp đẹp nhất.',
  Tips = N'Trang phục kín đáo, bỏ mũ khi lên điện thờ|Đông khách vào ngày rằm, mùng một âm lịch|Kết hợp với tham quan Lăng Bác, Phủ Chủ tịch trong cùng buổi sáng',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Chùa Một Cột';
UPDATE TouristAttractions SET
  Description = N'Quần thể di tích thờ Khổng Tử và các bậc hiền triết, đồng thời là trường đại học đầu tiên của Việt Nam – biểu tượng của truyền thống hiếu học.',
  History = N'Văn Miếu được xây năm 1070 dưới thời vua Lý Thánh Tông; năm 1076 vua Lý Nhân Tông lập Quốc Tử Giám để dạy con em hoàng tộc, sau mở rộng cho người học giỏi trong cả nước. 82 tấm bia tiến sĩ khắc tên những người đỗ đạt từ năm 1442 đến 1779 đã được UNESCO ghi danh là Di sản tư liệu thế giới. Khuê Văn Các được dựng năm 1805, nay là biểu tượng của Hà Nội.',
  Highlights = N'Khuê Văn Các – biểu tượng của thủ đô|82 bia tiến sĩ đặt trên lưng rùa đá|Giếng Thiên Quang|Điện Đại Thành thờ Khổng Tử|Khu Thái Học – nơi tưởng niệm các vị vua có công với giáo dục',
  OpeningHours = N'Mùa hè: 7:30 – 17:30. Mùa đông: 8:00 – 17:00. Mở cửa hằng ngày, kể cả lễ, Tết.',
  TicketPrice = N'Người lớn: 30.000đ. Học sinh, sinh viên Việt Nam, người từ 60 tuổi: 15.000đ. Trẻ em dưới 15 tuổi: miễn phí. Vé chỉ dùng trong ngày.',
  HoursSummary = N'7:30 – 17:30 (đông: 8:00 – 17:00)', PriceFrom = N'30.000đ', VisitDuration = N'1 – 1,5 giờ',
  BestTime = N'Sáng sớm các ngày thường; mùa thi (tháng 5 – 6) và đầu năm rất đông sĩ tử đến cầu may.',
  Tips = N'Không xoa đầu rùa, không chạm vào bia đá|Mang thẻ học sinh, sinh viên để được giảm giá|Nhiều bạn trẻ chụp ảnh kỷ yếu, áo dài tại đây – nên đến sớm để có ảnh đẹp',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Văn Miếu - Quốc Tử Giám';
UPDATE TouristAttractions SET
  Description = N'Bảo tàng lưu giữ hàng nghìn tác phẩm tiêu biểu của mỹ thuật Việt Nam từ thời tiền sử đến hiện đại: điêu khắc, tranh sơn mài, tranh lụa, gốm và tranh dân gian.',
  History = N'Tòa nhà được xây năm 1937 thời Pháp thuộc, vốn là ký túc xá dành cho nữ sinh, mang phong cách kiến trúc Đông Dương với mái ngói nhiều tầng. Bảo tàng Mỹ thuật Việt Nam được thành lập ngày 24/6/1966, hiện lưu giữ hơn 20.000 hiện vật. Trong bộ sưu tập có tượng Phật Bà Quan Âm nghìn mắt nghìn tay (1656) và nhiều tác phẩm của các danh họa như Tô Ngọc Vân, Nguyễn Gia Trí, Bùi Xuân Phái.',
  Highlights = N'Tượng Phật Bà Quan Âm nghìn mắt nghìn tay (1656)|Tranh sơn mài, tranh lụa của các danh họa|Điêu khắc Chăm và tượng gỗ đình làng|Tranh dân gian Đông Hồ, Hàng Trống|Không gian sáng tạo cho trẻ em ở tầng 3',
  OpeningHours = N'8:30 – 17:00 hằng ngày.',
  TicketPrice = N'Người lớn: 40.000đ. Sinh viên: 20.000đ. Học sinh 6 – 16 tuổi: 10.000đ. Trẻ em dưới 6 tuổi: miễn phí. Thuyết minh tự động: 50.000đ (sinh viên 30.000đ), có nhiều ngôn ngữ.',
  HoursSummary = N'8:30 – 17:00', PriceFrom = N'40.000đ', VisitDuration = N'1,5 – 2 giờ',
  BestTime = N'Buổi sáng các ngày trong tuần, yên tĩnh để xem tranh.',
  Tips = N'Thuê thuyết minh tự động để hiểu câu chuyện từng tác phẩm|Không chạm vào hiện vật; xem quy định chụp ảnh ở từng phòng|Ngay đối diện cổng sau Văn Miếu – có thể đi bộ kết hợp',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Bảo tàng Mỹ thuật Việt Nam';
UPDATE TouristAttractions SET
  Description = N'Bảo tàng lưu giữ hiện vật quý về lịch sử Việt Nam từ thời tiền sử, văn hóa Đông Sơn đến triều Nguyễn, đặt trong tòa nhà kiến trúc Đông Dương nổi tiếng.',
  History = N'Tòa nhà do kiến trúc sư Ernest Hébrard thiết kế, xây dựng từ năm 1926 đến 1932 cho Viện Viễn Đông Bác cổ (Bảo tàng Louis Finot), kết hợp kiến trúc Pháp với mái và chi tiết phương Đông. Bảo tàng Lịch sử Quốc gia hiện nay được hợp nhất năm 2011 từ Bảo tàng Lịch sử Việt Nam và Bảo tàng Cách mạng Việt Nam.',
  Highlights = N'Trống đồng Đông Sơn và bộ sưu tập đồ đồng|Hiện vật thời Lý, Trần, Lê và triều Nguyễn|Cọc gỗ trận Bạch Đằng|Mô hình thuyền chiến Đại Việt|Kiến trúc Đông Dương độc đáo của tòa nhà',
  OpeningHours = N'Sáng 8:00 – 12:00, chiều 13:30 – 17:00. Nghỉ thứ Hai đầu tiên của mỗi tháng (nếu trùng ngày lễ vẫn mở cửa).',
  TicketPrice = N'Người lớn: 40.000đ. Sinh viên: 20.000đ. Học sinh: 10.000đ. Trẻ em dưới 6 tuổi, người khuyết tật: miễn phí.',
  HoursSummary = N'8:00 – 12:00, 13:30 – 17:00', PriceFrom = N'40.000đ', VisitDuration = N'1,5 – 2 giờ',
  BestTime = N'Buổi sáng, tránh giờ nghỉ trưa 12:00 – 13:30.',
  Tips = N'Bảo tàng có 2 điểm: số 1 Tràng Tiền và 216 Trần Quang Khải (lịch sử cách mạng)|Ngay sau Nhà hát Lớn – có thể kết hợp tham quan|Kiểm tra thông báo nghỉ thứ Hai đầu tháng trước khi đi',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Bảo tàng Lịch sử Quốc gia';
UPDATE TouristAttractions SET
  Description = N'Bảo tàng giới thiệu văn hóa của 54 dân tộc Việt Nam và các nước Đông Nam Á, nổi tiếng với khu vườn trưng bày nhà truyền thống nguyên mẫu ngoài trời.',
  History = N'Bảo tàng khánh thành năm 1997, thuộc Viện Hàn lâm Khoa học Xã hội Việt Nam. Tòa nhà Trống Đồng do kiến trúc sư Hà Đức Lịnh (dân tộc Tày) thiết kế; khu vườn kiến trúc có các ngôi nhà được tháo dỡ và dựng lại nguyên bản bởi chính người dân các dân tộc.',
  Highlights = N'Tòa nhà Trống Đồng: văn hóa 54 dân tộc Việt Nam|Tòa nhà Cánh Diều: văn hóa Đông Nam Á|Nhà rông Ba Na, nhà dài Ê Đê, nhà sàn Tày, nhà H''Mông ngoài trời|Nhà mồ Gia Rai, Cơ Tu với tượng gỗ độc đáo|Múa rối nước tại thủy đình trong khuôn viên',
  OpeningHours = N'8:30 – 17:30, thứ Ba đến Chủ nhật. Nghỉ thứ Hai và một số ngày Tết.',
  TicketPrice = N'Người lớn: 40.000đ. Sinh viên: 20.000đ. Trẻ em dưới 15 tuổi: miễn phí. Máy ảnh chuyên nghiệp: 50.000đ. Múa rối nước bán vé riêng.',
  HoursSummary = N'8:30 – 17:30 (nghỉ thứ Hai)', PriceFrom = N'40.000đ', VisitDuration = N'2 – 3 giờ',
  BestTime = N'8:30 – 10:00 hoặc sau 14:30 để tránh nắng gắt ở khu vườn ngoài trời.',
  Tips = N'Xem khu trong nhà trước, khu vườn sau; được vào bên trong các nhà truyền thống|Mang nước, mũ vì khu vườn ít bóng râm|Bảo tàng ở Cầu Giấy, cách Hồ Gươm khoảng 7 – 8 km – nên đi xe buýt hoặc taxi',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Bảo tàng Dân tộc học Việt Nam';
UPDATE TouristAttractions SET
  Description = N'Hồ nước tự nhiên lớn nhất nội thành Hà Nội, rộng khoảng 500 ha với chu vi khoảng 17 km, nổi tiếng với cảnh hoàng hôn và nhiều di tích quanh hồ.',
  History = N'Hồ Tây từng có các tên Đầm Xác Cáo, hồ Kim Ngưu, Lãng Bạc, Dâm Đàm; năm 1573 hồ được đổi tên thành Tây Hồ để kiêng húy vua Lê Thế Tông. Quanh hồ có nhiều di tích nổi tiếng như chùa Trấn Quốc, Phủ Tây Hồ, đền Quán Thánh. Ven hồ là các làng cổ như Nghi Tàm, Quảng An, Nhật Tân với nghề trồng hoa, trồng đào.',
  Highlights = N'Ngắm hoàng hôn trên đường Thanh Niên|Chùa Trấn Quốc, Phủ Tây Hồ ven hồ|Đạp xe vòng quanh hồ|Ẩm thực: bánh tôm Hồ Tây, ốc nóng|Cà phê ven hồ và phố Trịnh Công Sơn',
  OpeningHours = N'Khu vực công cộng, mở cửa cả ngày.',
  TicketPrice = N'Miễn phí.',
  HoursSummary = N'Cả ngày', PriceFrom = N'Miễn phí', VisitDuration = N'2 – 3 giờ',
  BestTime = N'Chiều muộn (16:30 – 18:30) để ngắm hoàng hôn; sáng sớm mùa thu rất mát.',
  Tips = N'Có thể thuê xe đạp TNGo tại các trạm quanh hồ để đạp vòng hồ|Đường Thanh Niên rất đông vào giờ tan tầm|Kết hợp tham quan chùa Trấn Quốc trước 18:00',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Hồ Tây';
UPDATE TouristAttractions SET
  Description = N'Ngôi chùa cổ nhất Hà Nội, nằm trên bán đảo nhỏ phía đông Hồ Tây, nổi bật với bảo tháp nhiều tầng soi bóng mặt hồ.',
  History = N'Chùa được dựng từ thế kỷ VI thời Lý Nam Đế với tên Khai Quốc, ban đầu ở bãi sông Hồng. Năm 1615, do bờ sông bị lở, chùa được dời vào đảo Kim Ngư trên Hồ Tây; tấm bia năm 1815 ghi lại lịch sử chùa. Bảo tháp 11 tầng được xây năm 1998; cây bồ đề trong chùa là cây chiết từ cây bồ đề nơi Đức Phật thành đạo, do Tổng thống Ấn Độ Rajendra Prasad tặng năm 1959.',
  Highlights = N'Bảo tháp 11 tầng, mỗi tầng có tượng Phật bằng đá quý|Cây bồ đề do Tổng thống Ấn Độ tặng năm 1959|Tượng Phật Thích Ca nhập Niết Bàn|Bia đá ghi lịch sử chùa (1815)|Khung cảnh chùa soi bóng Hồ Tây',
  OpeningHours = N'7:30 – 11:30 và 13:30 – 18:00 hằng ngày. Ngày rằm, mùng một mở từ 7:00. Giờ có thể thay đổi dịp Tết.',
  TicketPrice = N'Miễn phí (không có quầy vé).',
  HoursSummary = N'7:30 – 11:30, 13:30 – 18:00', PriceFrom = N'Miễn phí', VisitDuration = N'30 – 60 phút',
  BestTime = N'7:30 – 9:00 yên tĩnh, ánh sáng đẹp; hoặc chiều 16:00 – 17:30 ngắm hoàng hôn.',
  Tips = N'Trang phục che vai và đầu gối – cổng chùa có kiểm tra|Chùa đóng cửa buổi trưa (11:30 – 13:30)|Rằm, mùng một rất đông người đi lễ',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Chùa Trấn Quốc';
UPDATE TouristAttractions SET
  Description = N'Con phố nhỏ trong phố cổ được mệnh danh là "phố Tây", sôi động về đêm với hàng quán bia, đồ nướng và khách du lịch từ khắp nơi.',
  History = N'Thời Pháp thuộc, các đoạn phố cũ được gộp lại và mang tên Rue Géraud. Từ năm 1945, phố được đổi tên theo Tạ Hiện (1841 – 1887), một tướng lĩnh của phong trào Cần Vương chống Pháp. Người dân còn quen gọi là ngõ Quảng Lạc, theo tên rạp hát Quảng Lạc giữa phố. Ngày nay ngã tư Tạ Hiện – Lương Ngọc Quyến là điểm hẹn "bia hơi" nổi tiếng, được gọi là "ngã tư quốc tế"; từ năm 2014 phố nằm trong khu phố đi bộ cuối tuần.',
  Highlights = N'Ngã tư Tạ Hiện – Lương Ngọc Quyến náo nhiệt về đêm|Bia hơi, đồ nướng, ăn vặt đường phố|Không khí giao lưu với du khách quốc tế|Nằm trong khu phố đi bộ cuối tuần',
  OpeningHours = N'Sôi động nhất từ khoảng 18:00 đến khuya, đặc biệt tối thứ Sáu – Chủ nhật.',
  TicketPrice = N'Đi dạo miễn phí; chi phí ăn uống tùy quán.',
  HoursSummary = N'Từ 18:00 đến khuya', PriceFrom = N'Miễn phí', VisitDuration = N'1 – 2 giờ',
  BestTime = N'Tối cuối tuần khi phố đi bộ hoạt động.',
  Tips = N'Hỏi giá trước khi gọi món, nhất là ở các quán đông khách du lịch|Giữ ví, điện thoại cẩn thận nơi đông người|Ban ngày phố khá yên tĩnh, ít quán mở',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Phố Tạ Hiện';
UPDATE TouristAttractions SET
  Description = N'Tuyến phố dành riêng cho sách trên phố 19 Tháng 12, với các ki-ốt của nhiều nhà xuất bản, quán cà phê sách và không gian đọc dưới tán cây.',
  History = N'Phố sách Hà Nội đi vào hoạt động năm 2017 trên tuyến phố 19 Tháng 12 (cạnh Tòa án nhân dân thành phố), là một trong những không gian văn hóa đọc tiêu biểu của thủ đô. Nơi đây thường tổ chức giới thiệu sách, giao lưu tác giả, triển lãm và ngày hội đọc sách.',
  Highlights = N'Ki-ốt của nhiều nhà xuất bản: Kim Đồng, Nhã Nam, Trẻ…|Cà phê sách và chỗ ngồi đọc dưới hàng cây|Giao lưu tác giả, ra mắt sách cuối tuần|Ngày hội khuyến đọc, Hội sách theo mùa',
  OpeningHours = N'8:00 – 22:00 hằng ngày.',
  TicketPrice = N'Miễn phí vào cửa.',
  HoursSummary = N'8:00 – 22:00', PriceFrom = N'Miễn phí', VisitDuration = N'1 – 2 giờ',
  BestTime = N'Ngày thường để đọc sách yên tĩnh; cuối tuần có nhiều sự kiện.',
  Tips = N'Nhiều nhà sách có giảm giá so với giá bìa|Đi xe buýt tới trạm gần phố Lý Thường Kiệt hoặc Hai Bà Trưng|Gần Phố sách có trạm xe đạp công cộng TNGo',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Phố sách Hà Nội';
UPDATE TouristAttractions SET
  Description = N'Cây cầu thép hơn trăm tuổi bắc qua sông Hồng, chứng nhân lịch sử của Hà Nội và là điểm ngắm sông Hồng, chụp ảnh nổi tiếng.',
  History = N'Cầu được khởi công năm 1898, khánh thành năm 1902 với tên ban đầu là cầu Doumer (theo tên Toàn quyền Đông Dương Paul Doumer), do công ty Daydé & Pillé của Pháp thi công. Phần cầu qua sông dài khoảng 2,3 km. Trong chiến tranh chống Mỹ, cầu bị ném bom nhiều lần và được sửa chữa để giữ mạch giao thông; nhiều nhịp cầu vẫn mang dấu vết bom đạn.',
  Highlights = N'Kết cấu dầm thép cổ hơn 120 năm tuổi|Tàu hỏa chạy giữa, xe máy và người đi bộ hai bên|Ngắm bình minh, hoàng hôn trên sông Hồng|Bãi giữa sông Hồng với vườn ngô, vườn chuối|Chợ Long Biên sầm uất dưới chân cầu',
  OpeningHours = N'Mở cửa cả ngày.',
  TicketPrice = N'Miễn phí.',
  HoursSummary = N'Cả ngày', PriceFrom = N'Miễn phí', VisitDuration = N'45 – 90 phút',
  BestTime = N'Bình minh hoặc hoàng hôn; mùa thu trời trong, ánh sáng đẹp.',
  Tips = N'Trên cầu xe cộ đi bên trái – người đi bộ đi trên lối đi riêng hai bên|Không đứng trên đường ray khi tàu chạy|Có thể xuống bãi giữa sông Hồng từ chân cầu phía Long Biên',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Cầu Long Biên';
UPDATE TouristAttractions SET
  Description = N'Nhà hát chuyên biểu diễn múa rối nước – loại hình nghệ thuật dân gian độc đáo của đồng bằng Bắc Bộ, ngay bên hồ Hoàn Kiếm.',
  History = N'Nhà hát Múa rối Thăng Long được thành lập năm 1969, đã biểu diễn và lưu diễn ở hàng chục quốc gia. Múa rối nước ra đời từ nền văn minh lúa nước, các nghệ nhân đứng sau mành tre, dưới nước điều khiển con rối bằng sào và dây, kèm dàn nhạc dân tộc và hát chèo.',
  Highlights = N'Chú Tễu dẫn chuyện hài hước mở màn|Múa rồng, múa phượng, múa lân trên mặt nước|Cảnh cày cấy, chăn trâu, bắt vịt đời thường|Tích Lê Lợi trả gươm cho Rùa Vàng|Dàn nhạc dân tộc và hát chèo biểu diễn trực tiếp',
  OpeningHours = N'Thứ Hai – thứ Bảy: suất 16:10, 17:20, 18:30, 20:00. Chủ nhật thêm suất 9:30, 11:00, 14:00. Mỗi suất khoảng 50 phút. Lịch có thể thay đổi dịp lễ, Tết.',
  TicketPrice = N'Ghế thường: 100.000đ. Ghế hạng nhất: 150.000đ. Ghế VIP (hàng đầu): 200.000đ. Phí chụp ảnh 20.000đ, quay phim 50.000đ.',
  HoursSummary = N'Suất 16:10, 17:20, 18:30, 20:00', PriceFrom = N'100.000đ', VisitDuration = N'~50 phút',
  BestTime = N'Suất chiều 16:10 hoặc 17:20 dễ mua vé; suất tối nên đặt trước.',
  Tips = N'Mùa cao điểm (tháng 11 – 3) nên đặt vé trước 3 – 7 ngày|Đến sớm 20 – 30 phút; cửa đóng khi bắt đầu diễn|Hàng ghế đầu có thể bị nước bắn vào|Không dùng đèn flash trong lúc biểu diễn',
  UpdatedAt = SYSDATETIME()
WHERE Name = N'Nhà hát Múa rối Thăng Long';
GO

DELETE FROM AttractionImages WHERE ImageUrl LIKE '/images/attractions/gallery/%';
/* Bo suu tap anh (3 - 5 anh / dia diem) tu Wikimedia Commons - giay phep tu do,
   file nam tai frontend/public/images/attractions/gallery/ ; Credit = tac gia / giay phep */
INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder) VALUES
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hồ Hoàn Kiếm'), '/images/attractions/gallery/01-ho-hoan-kiem-1.jpg', N'Tháp Rùa lung linh về đêm', N'Isabell Schulz / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Hoan_Kiem%2C_Hanoi_%2844478561440%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hồ Hoàn Kiếm'), '/images/attractions/gallery/01-ho-hoan-kiem-2.jpg', N'Mặt hồ xanh giữa lòng phố', N'Bem photography / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Ho_Hoan_Kiem_%2813574475044%29.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hồ Hoàn Kiếm'), '/images/attractions/gallery/01-ho-hoan-kiem-3.jpg', N'Buổi sớm bên bờ hồ', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Angler_at_Hoan_Kiem_Lake.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hồ Hoàn Kiếm'), '/images/attractions/gallery/01-ho-hoan-kiem-4.jpg', N'Ánh đèn quanh hồ buổi tối', N'Bem photography / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Ho_Hoan_Kiem_%2812313745773%29.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hồ Hoàn Kiếm'), '/images/attractions/gallery/01-ho-hoan-kiem-5.jpg', N'Không gian xanh quanh hồ', N'choi kwangmo / CC0', 'https://commons.wikimedia.org/wiki/File:20190923_164624lake_park_in_h%C3%A0_n%E1%BB%99i.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Đền Ngọc Sơn'), '/images/attractions/gallery/02-den-ngoc-son-1.jpg', N'Đền Ngọc Sơn soi bóng mặt hồ', N'P. Hughes / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_-_Ngoc_Son_Temple.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Đền Ngọc Sơn'), '/images/attractions/gallery/02-den-ngoc-son-2.jpg', N'Cổng vào đền', N'Clay Gilliland / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_Vietnam_%2812042291376%29.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Đền Ngọc Sơn'), '/images/attractions/gallery/02-den-ngoc-son-3.jpg', N'Gian thờ chính', N'Mig Gilbert / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Den_Ngoc_Son_shrine_%2838457884970%29.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Đền Ngọc Sơn'), '/images/attractions/gallery/02-den-ngoc-son-4.jpg', N'Nội thất đền', N'RThiele / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:019Jadebergtempel_innen.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Đền Ngọc Sơn'), '/images/attractions/gallery/02-den-ngoc-son-5.jpg', N'Hương án và hoành phi câu đối', N'Ziegler175 / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:ICHanoiNgocSon1.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố cổ Hà Nội'), '/images/attractions/gallery/03-pho-co-ha-noi-1.jpg', N'Nhịp sống khu phố cổ', N'yeowatzup / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Old_Quarter%2C_Hanoi%2C_Vietnam_%285246284208%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố cổ Hà Nội'), '/images/attractions/gallery/03-pho-co-ha-noi-2.jpg', N'Một góc phố cổ', N'Gonzo Gooner / CC BY 3.0', 'https://commons.wikimedia.org/wiki/File:Old_Quarter%2C_Hanoi_-_panoramio.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố cổ Hà Nội'), '/images/attractions/gallery/03-pho-co-ha-noi-3.jpg', N'Phố cổ ngày thường', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Old_Quarter_street_scene%2C_Hanoi_%282%29_%2838496798321%29.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố cổ Hà Nội'), '/images/attractions/gallery/03-pho-co-ha-noi-4.jpg', N'Dãy nhà ống đặc trưng', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Old_Quarter_street_scene%2C_Hanoi_%283%29_%2838464656402%29.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố cổ Hà Nội'), '/images/attractions/gallery/03-pho-co-ha-noi-5.jpg', N'Phố cổ Hà Nội', N'yeowatzup / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Old_Quarter%2C_Hanoi%2C_Vietnam_%285246306092%29.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chợ Đồng Xuân'), '/images/attractions/gallery/04-cho-dong-xuan-1.jpg', N'Mặt tiền chợ Đồng Xuân', N'shankar s. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Dong_Xuan_Market_market_in_the_Hanoi_old_quarter_%2830645886763%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chợ Đồng Xuân'), '/images/attractions/gallery/04-cho-dong-xuan-2.jpg', N'Chợ đêm khu Đồng Xuân', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_Night_Market_3.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chợ Đồng Xuân'), '/images/attractions/gallery/04-cho-dong-xuan-3.jpg', N'Bên trong chợ', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:%C4%90%E1%BB%93ng_Xu%C3%A2n_Market_6.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chợ Đồng Xuân'), '/images/attractions/gallery/04-cho-dong-xuan-4.jpg', N'Gian hàng trong chợ', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:%C4%90%E1%BB%93ng_Xu%C3%A2n_Market_2.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chợ Đồng Xuân'), '/images/attractions/gallery/04-cho-dong-xuan-5.jpg', N'Khu bán vải, quần áo', N'Sandra Cohen-Rose and Colin Rose / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Dong_Xuan_Market_%2823144327176%29.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà hát Lớn Hà Nội'), '/images/attractions/gallery/05-nha-hat-lon-1.jpg', N'Mặt tiền Nhà hát Lớn', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_Opera_House%2C_1901-11_%283%29_%2837779750014%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà hát Lớn Hà Nội'), '/images/attractions/gallery/05-nha-hat-lon-2.jpg', N'Nhà hát Lớn lên đèn', N'Bem photography / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Nha_hat_lon_%2812358211094%29.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà hát Lớn Hà Nội'), '/images/attractions/gallery/05-nha-hat-lon-3.jpg', N'Kiến trúc Pháp tân cổ điển', N'Edgardo W. Olivera / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Opera_House%2C_Hanoi%2C_Vietnam_%2836761966601%29.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà hát Lớn Hà Nội'), '/images/attractions/gallery/05-nha-hat-lon-4.jpg', N'Nhà hát nhìn từ quảng trường', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_Opera_House_2018.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà hát Lớn Hà Nội'), '/images/attractions/gallery/05-nha-hat-lon-5.jpg', N'Nhà hát Lớn Hà Nội', N'The Hanoian / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Nh%C3%A0_h%C3%A1t_L%E1%BB%9Bn_H%C3%A0_N%E1%BB%99i_-_2022-09-02_03.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà tù Hỏa Lò'), '/images/attractions/gallery/06-nha-tu-hoa-lo-1.jpg', N'Khu tái hiện buồng giam tù chính trị', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:Communist_Prisoners_of_the_French%2C_Hoa_Lo_Prison_%289754076916%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà tù Hỏa Lò'), '/images/attractions/gallery/06-nha-tu-hoa-lo-2.jpg', N'Giường của phi công Mỹ bị giam giữ', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:Bunk_Bed_for_American_Prisoners%2C_Hoa_Lo_Prison_%289754110835%29.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà tù Hỏa Lò'), '/images/attractions/gallery/06-nha-tu-hoa-lo-3.jpg', N'Ảnh tư liệu: tù binh Mỹ rời Hỏa Lò năm 1973', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:American_Prisoners_Leaving_Hoa_Lo_Prison%2C_1973_%289754154193%29.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hoàng thành Thăng Long'), '/images/attractions/gallery/07-hoang-thanh-thang-long-1.jpg', N'Khu trung tâm Hoàng thành', N'katiebordner / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Central_Sector_of_the_Imperial_Citadel_of_Thang_Long_-_Hanoi_%2826246667851%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hoàng thành Thăng Long'), '/images/attractions/gallery/07-hoang-thanh-thang-long-2.jpg', N'Đoan Môn nhìn từ bên trong', N'katiebordner / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Central_Sector_of_the_Imperial_Citadel_of_Thang_Long_-_Hanoi.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hoàng thành Thăng Long'), '/images/attractions/gallery/07-hoang-thanh-thang-long-3.jpg', N'Kiến trúc trong Hoàng thành', N'Guerinf / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Citadelle_de_Hano%C3%AF_%281%29.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hoàng thành Thăng Long'), '/images/attractions/gallery/07-hoang-thanh-thang-long-4.jpg', N'Cổng thành', N'Guerinf / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Citadelle_de_Hano%C3%AF_%284%29.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hoàng thành Thăng Long'), '/images/attractions/gallery/07-hoang-thanh-thang-long-5.jpg', N'Cửa trái Đoan Môn', N'Phan Minh Tuấn / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:C%E1%BB%95ng_tr%C3%A1i_%C4%90oan_M%C3%B4n%2C_Ho%C3%A0ng_th%C3%A0nh_Th%C4%83ng_Long%2C_H%C3%A0_N%E1%BB%99i_001.JPG', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Lăng Chủ tịch Hồ Chí Minh'), '/images/attractions/gallery/08-lang-chu-tich-ho-chi-minh-1.jpg', N'Lăng Chủ tịch Hồ Chí Minh', N'shankar s. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:HCM_Mausoleum-_closed_as_his_preserved_body_wan%27t_it_%2831454165115%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Lăng Chủ tịch Hồ Chí Minh'), '/images/attractions/gallery/08-lang-chu-tich-ho-chi-minh-2.jpg', N'Đội tiêu binh trước Lăng', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Guards_of_the_Ho_Chi_Minh_Mausoleum.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Lăng Chủ tịch Hồ Chí Minh'), '/images/attractions/gallery/08-lang-chu-tich-ho-chi-minh-3.jpg', N'Khu vực Lăng và quảng trường', N'rhjpage / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_day_2_%2842633365842%29.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Lăng Chủ tịch Hồ Chí Minh'), '/images/attractions/gallery/08-lang-chu-tich-ho-chi-minh-4.jpg', N'Hàng cờ trước Lăng', N'flowcomm / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_Vietnam_%2849538245913%29.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Lăng Chủ tịch Hồ Chí Minh'), '/images/attractions/gallery/08-lang-chu-tich-ho-chi-minh-5.jpg', N'Vườn cây quanh Lăng', N'Esin Üstün / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Gardeners_in_the_Ho_Chi_Minh_Mausoleum_-_Vietnam_%2815860257192%29.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Quảng trường Ba Đình'), '/images/attractions/gallery/09-quang-truong-ba-dinh-1.jpg', N'Quảng trường Ba Đình', N'Vyacheslav Argenberg / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_Vietnam%2C_Ho_Chi_Minh_Mausoleum_on_Ba_Dinh_Square.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Quảng trường Ba Đình'), '/images/attractions/gallery/09-quang-truong-ba-dinh-2.jpg', N'Quảng trường về đêm', N'Nguyễn Thanh Quang / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Qu%E1%BA%A3ng_tr%C6%B0%E1%BB%9Dng_Ba_%C4%90%C3%ACnh_v%E1%BB%81_%C4%91%C3%AAm.JPG', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Quảng trường Ba Đình'), '/images/attractions/gallery/09-quang-truong-ba-dinh-3.jpg', N'Quảng trường và Lăng Bác', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Ba_Dinh_Square%2C_Hanoi_%2837609038445%29.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Quảng trường Ba Đình'), '/images/attractions/gallery/09-quang-truong-ba-dinh-4.jpg', N'Thảm cỏ quảng trường', N'Cvbr / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Mausoleo_de_Ho_Chi_Minh.JPG', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chùa Một Cột'), '/images/attractions/gallery/10-chua-mot-cot-1.jpg', N'Chùa Một Cột', N'dronepicr / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Eins%C3%A4ulenpagode_Ngoc_Son_Hanoi_%2839513844382%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chùa Một Cột'), '/images/attractions/gallery/10-chua-mot-cot-2.jpg', N'Chùa nhìn từ hồ sen', N'lumoplank / CC0', 'https://commons.wikimedia.org/wiki/File:Hanoi_-_Hanoi1638.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chùa Một Cột'), '/images/attractions/gallery/10-chua-mot-cot-3.jpg', N'Ban thờ Quán Thế Âm', N'Chitra sivakumar / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Ch%C3%B9a_M%E1%BB%99t_C%E1%BB%99t_5.JPG', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chùa Một Cột'), '/images/attractions/gallery/10-chua-mot-cot-4.jpg', N'Hồ sen quanh chùa', N'Chitra sivakumar / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Ch%C3%B9a_M%E1%BB%99t_C%E1%BB%99t_4.JPG', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chùa Một Cột'), '/images/attractions/gallery/10-chua-mot-cot-5.jpg', N'Khuôn viên chùa', N'Clay Gilliland / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_Vietnam_%2812041825854%29.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Văn Miếu - Quốc Tử Giám'), '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-1.jpg', N'Cổng Văn Miếu', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:20220605_Temple_of_Literature%2C_Hanoi_14.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Văn Miếu - Quốc Tử Giám'), '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-2.jpg', N'Gác trong khuôn viên Văn Miếu', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:20220605_Temple_of_Literature%2C_Hanoi_16.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Văn Miếu - Quốc Tử Giám'), '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-3.jpg', N'Giếng Thiên Quang', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:20220605_Temple_of_Literature%2C_Hanoi_04.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Văn Miếu - Quốc Tử Giám'), '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-4.jpg', N'Nhà bia tiến sĩ', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:20220605_Temple_of_Literature%2C_Hanoi_28.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Văn Miếu - Quốc Tử Giám'), '/images/attractions/gallery/11-van-mieu-quoc-tu-giam-5.jpg', N'Lối đi rợp bóng cây', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:20220605_Temple_of_Literature%2C_Hanoi_24.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Mỹ thuật Việt Nam'), '/images/attractions/gallery/12-bao-tang-my-thuat-1.jpg', N'Cánh cửa chạm rồng (1262)', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Doors_carved_with_dragon_motifs%2C_1262%2C_Museum_of_Fine_Arts%2C_Hanoi_%281%29_%2824628505508%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Mỹ thuật Việt Nam'), '/images/attractions/gallery/12-bao-tang-my-thuat-2.jpg', N'Tượng bà chúa (1632)', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Statue_of_a_duchess%2C_1632%2C_Museum_of_Fine_Arts%2C_Hanoi_%281%29_%2824628273508%29.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Mỹ thuật Việt Nam'), '/images/attractions/gallery/12-bao-tang-my-thuat-3.jpg', N'Tượng bò thần Nandi, nghệ thuật Chăm (thế kỷ VIII–IX)', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Nandi_bull%2C_8th-9th_cents.%2C_Museum_of_Fine_Arts%2C_Hanoi_%2837785222234%29.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Mỹ thuật Việt Nam'), '/images/attractions/gallery/12-bao-tang-my-thuat-4.jpg', N'Tượng nghê (đầu thế kỷ XVII)', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Mythological_lion%2C_early_17th_century%2C_Museum_of_Fine_Arts%2C_Hanoi_%282%29_%2838468435862%29.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Mỹ thuật Việt Nam'), '/images/attractions/gallery/12-bao-tang-my-thuat-5.jpg', N'Tượng Kinnari đánh trống (1087)', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Kinnari_drumming%2C_1087%2C_Museum_of_Fine_Arts%2C_Hanoi_%2837613891045%29.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Lịch sử Quốc gia'), '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-1.jpg', N'Tòa nhà bảo tàng', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:Vietnam_History_Museum_%289753022072%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Lịch sử Quốc gia'), '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-2.jpg', N'Kiến trúc Đông Dương của bảo tàng', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:Vietnam_History_Museum_%289753023741%29.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Lịch sử Quốc gia'), '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-3.jpg', N'Bảo tàng Lịch sử Việt Nam', N'Casablanca1911 / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:B%E1%BA%A3o_t%C3%A0ng_LSVN.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Lịch sử Quốc gia'), '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-4.jpg', N'Mô hình thuyền chiến Đại Việt', N'PTDTCH / Public domain', 'https://commons.wikimedia.org/wiki/File:ThuyenchienDaiViet1.JPG', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Lịch sử Quốc gia'), '/images/attractions/gallery/13-bao-tang-lich-su-quoc-gia-5.jpg', N'Hiện vật trưng bày', N'Gary Todd / CC0', 'https://commons.wikimedia.org/wiki/File:Vietnam_History_Museum_%289753230575%29.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Dân tộc học Việt Nam'), '/images/attractions/gallery/14-bao-tang-dan-toc-hoc-1.jpg', N'Nhà dài Ê Đê', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Ede_longhouse%2C_Museum_of_Ethnology%2C_Hanoi_%2837608576475%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Dân tộc học Việt Nam'), '/images/attractions/gallery/14-bao-tang-dan-toc-hoc-2.jpg', N'Nhà mồ Gia Rai', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Giarai_tomb%2C_Museum_of_Ethnology%2C_Hanoi_%282%29_%2838439476326%29.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Dân tộc học Việt Nam'), '/images/attractions/gallery/14-bao-tang-dan-toc-hoc-3.jpg', N'Ngôi nhà truyền thống', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Traditional_Hanoi_dwelling%2C_Museum_of_Ethnology%2C_Hanoi_%281%29_%2838497797791%29.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Dân tộc học Việt Nam'), '/images/attractions/gallery/14-bao-tang-dan-toc-hoc-4.jpg', N'Nhà mồ Cơ Tu', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Cotu_tomb%2C_Museum_of_Ethnology%2C_Hanoi_%282%29_%2838495337181%29.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Bảo tàng Dân tộc học Việt Nam'), '/images/attractions/gallery/14-bao-tang-dan-toc-hoc-5.jpg', N'Nhà truyền thống của người Việt', N'Richard Mortel / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Traditional_Hanoi_dwelling%2C_Museum_of_Ethnology%2C_Hanoi_%287%29_%2826722014039%29.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hồ Tây'), '/images/attractions/gallery/15-ho-tay-1.jpg', N'Hoàng hôn trên Hồ Tây', N'NKSTTSSHNVN / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Ho%C3%A0ng_h%C3%B4n_h%E1%BB%93_T%C3%A2y_-_NKS.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hồ Tây'), '/images/attractions/gallery/15-ho-tay-2.jpg', N'Hồ Tây', N'Alexey Komarov / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_10_March_2019.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hồ Tây'), '/images/attractions/gallery/15-ho-tay-3.jpg', N'Bờ Hồ Tây', N'Alex 69200 vx / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Lac-ouest-hanoi-4.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hồ Tây'), '/images/attractions/gallery/15-ho-tay-4.jpg', N'Chiều Hồ Tây', N'NKSTTSSHNVN / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Chi%E1%BB%81u_h%E1%BB%93_T%C3%A2y_-_NKS.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Hồ Tây'), '/images/attractions/gallery/15-ho-tay-5.jpg', N'Hồ Tây về đêm', N'cloud.shepherd / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Night_in_Hanoi_%2830053395432%29.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chùa Trấn Quốc'), '/images/attractions/gallery/16-chua-tran-quoc-1.jpg', N'Bảo tháp về đêm', N'katiebordner / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Hanoi%2C_Vietnam_%2826246682151%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chùa Trấn Quốc'), '/images/attractions/gallery/16-chua-tran-quoc-2.jpg', N'Chùa soi bóng Hồ Tây', N'Bùi Thụy Đào Nguyên / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Ch%C3%B9a_Tr%E1%BA%A5n_Qu%E1%BB%91c_%28H%C3%A0_N%E1%BB%99i%29.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chùa Trấn Quốc'), '/images/attractions/gallery/16-chua-tran-quoc-3.jpg', N'Cổng tam quan', N'shankar s. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:An_impressive_arch_leads_up_to_the_temple_%2831417104356%29.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chùa Trấn Quốc'), '/images/attractions/gallery/16-chua-tran-quoc-4.jpg', N'Khu tháp mộ các nhà sư', N'shankar s. / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Area_with_shrines_for_the_ashes_of_departed_monks_%2831454177605%29.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Chùa Trấn Quốc'), '/images/attractions/gallery/16-chua-tran-quoc-5.jpg', N'Cây bồ đề trong chùa', N'Bùi Thụy Đào Nguyên / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:C%C3%A2y_b%E1%BB%93_%C4%91%E1%BB%81_ch%C3%B9a_Tr%E1%BA%A5n_Qu%E1%BB%91c.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố Tạ Hiện'), '/images/attractions/gallery/17-pho-ta-hien-1.jpg', N'Phố Tạ Hiện', N'NKSTTSSHNVN / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Ph%E1%BB%91_T%E1%BA%A1_Hi%E1%BB%87n_-_NKS.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố Tạ Hiện'), '/images/attractions/gallery/17-pho-ta-hien-2.jpg', N'Phố Tạ Hiện ban ngày', N'Christophe95 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:T%E1%BA%A1_Hi%E1%BB%87n_Street.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố Tạ Hiện'), '/images/attractions/gallery/17-pho-ta-hien-3.jpg', N'Phố Tạ Hiện', N'9636137 (Pixabay) / CC0', 'https://commons.wikimedia.org/wiki/File:Ta-hien-street-3559133.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố Tạ Hiện'), '/images/attractions/gallery/17-pho-ta-hien-4.jpg', N'Góc phố Tạ Hiện', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:T%E1%BA%A1_Hi%E1%BB%87n_Street%2C_Hanoi%2C_Vietnam_13.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố Tạ Hiện'), '/images/attractions/gallery/17-pho-ta-hien-5.jpg', N'Phố Tạ Hiện lên đèn', N'choi kwangmo / CC0', 'https://commons.wikimedia.org/wiki/File:20190923_170333ph%E1%BB%91_t%E1%BA%A1_hi%E1%BB%87n_h%C3%A0_n%E1%BB%99i.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố sách Hà Nội'), '/images/attractions/gallery/18-pho-sach-ha-noi-1.jpg', N'Gian hàng sách', N'Newone / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_06.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố sách Hà Nội'), '/images/attractions/gallery/18-pho-sach-ha-noi-2.jpg', N'Không gian phố sách', N'Newone / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_16.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố sách Hà Nội'), '/images/attractions/gallery/18-pho-sach-ha-noi-3.jpg', N'Phố sách buổi tối', N'Newone / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_17.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố sách Hà Nội'), '/images/attractions/gallery/18-pho-sach-ha-noi-4.jpg', N'Sách bày bán', N'Newone / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_03.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Phố sách Hà Nội'), '/images/attractions/gallery/18-pho-sach-ha-noi-5.jpg', N'Ngày hội khuyến đọc', N'Newone / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:NewOne_-_Ph%E1%BB%91_S%C3%A1ch_H%C3%A0_N%E1%BB%99i_ng%C3%A0y_h%E1%BB%99i_khuy%E1%BA%BFn_%C4%91%E1%BB%8Dc_05.jpg', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Cầu Long Biên'), '/images/attractions/gallery/19-cau-long-bien-1.jpg', N'Cầu Long Biên nhìn từ bãi giữa sông Hồng', N'cloud.shepherd / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Farm_%26_bridge_%2827730838553%29.jpg', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Cầu Long Biên'), '/images/attractions/gallery/19-cau-long-bien-2.jpg', N'Cầu Long Biên về đêm', N'Miyako Fujimiya / CC0', 'https://commons.wikimedia.org/wiki/File:C%E1%BA%A7u_Long_Bi%C3%AAn_v%C3%A0o_%C4%91%C3%AAm.jpg', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Cầu Long Biên'), '/images/attractions/gallery/19-cau-long-bien-3.jpg', N'Đường ray trên cầu', N'Minhquangdo / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:C%E1%BA%A7u_Long_Bi%C3%AAn_28-2-2016.JPG', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Cầu Long Biên'), '/images/attractions/gallery/19-cau-long-bien-4.jpg', N'Kết cấu thép của cầu', N'Velvet / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_pont_long_Bien.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Cầu Long Biên'), '/images/attractions/gallery/19-cau-long-bien-5.jpg', N'Sông Hồng dưới chân cầu', N'Minhquangdo / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:28-2-2016_IMG_1667.JPG', 5),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà hát Múa rối Thăng Long'), '/images/attractions/gallery/20-nha-hat-mua-roi-thang-long-1.jpg', N'Sân khấu thủy đình', N'Gryffindor / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Thang_Long_Water_Puppet_Theatre1.JPG', 1),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà hát Múa rối Thăng Long'), '/images/attractions/gallery/20-nha-hat-mua-roi-thang-long-2.jpg', N'Tiết mục múa rối nước', N'Gryffindor / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:Thang_Long_Water_Puppet_Theatre3.JPG', 2),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà hát Múa rối Thăng Long'), '/images/attractions/gallery/20-nha-hat-mua-roi-thang-long-3.jpg', N'Dàn nhạc dân tộc phục vụ buổi diễn', N'Ziegler175 / CC BY-SA 3.0', 'https://commons.wikimedia.org/wiki/File:ICHanoi21.jpg', 3),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà hát Múa rối Thăng Long'), '/images/attractions/gallery/20-nha-hat-mua-roi-thang-long-4.jpg', N'Toàn cảnh sân khấu', N'thalling55 / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:Water_Puppet_Theater%2C_Hanoi_%281344448995%29.jpg', 4),
((SELECT AttractionId FROM TouristAttractions WHERE Name = N'Nhà hát Múa rối Thăng Long'), '/images/attractions/gallery/20-nha-hat-mua-roi-thang-long-5.jpg', N'Mặt tiền nhà hát', N'xiquinhosilva / CC BY 2.0', 'https://commons.wikimedia.org/wiki/File:04391-Hanoi_%2832139687983%29.jpg', 5);
GO

SELECT a.AttractionId, a.Name, a.PriceFrom, COUNT(i.ImageId) AS Images
FROM TouristAttractions a LEFT JOIN AttractionImages i ON i.AttractionId = a.AttractionId
GROUP BY a.AttractionId, a.Name, a.PriceFrom ORDER BY a.AttractionId;
GO
