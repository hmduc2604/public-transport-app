/* =====================================================================
   14_more_photos.sql - Bo sung anh (Wikimedia Commons, giay phep tu do) cho cac dia diem
   truoc day chua co / co it anh: Pho sach Dinh Le, Thuy cung Times City (anh dai dien + bo suu tap),
   Cong vien nuoc Ho Tay, Den Bach Ma, Bao tang Chien thang B-52 (them anh bo suu tap).
   Bao tang Thien nhien Viet Nam, Lotte Mall Tay Ho: chua tim duoc anh giay phep tu do.
   An toan khi chay lai (them anh theo duong dan, khong trung).
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
GO
USE PublicTransportDBV2;
GO
/* ---- Anh dai dien moi (dia diem truoc day chua co anh) ---- */
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/24-pho-sach-dinh-le.jpg', ImageCredit = N'Ảnh: Amenoc / CC0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Electric_toy_cars_in_pedestrian_zone_around_Hoan_Kiem.jpg' WHERE Name = N'Phố sách Đinh Lễ' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/24-pho-sach-dinh-le.jpg');
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/30-thuy-cung-times-city.jpg', ImageCredit = N'Ảnh: Newone / CC BY-SA 4.0 / Wikimedia Commons', ImageSourceUrl = 'https://commons.wikimedia.org/wiki/File:Newone_-_th%E1%BB%A7y_cung_Times_City.jpg' WHERE Name = N'Thủy cung Times City' AND (ImageUrl IS NULL OR ImageUrl <> '/images/attractions/30-thuy-cung-times-city.jpg');
GO
/* ---- Bo suu tap: anh moi / anh them ---- */
INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
SELECT a.AttractionId, v.ImageUrl, v.Caption, v.Credit, v.SourceUrl, v.SortOrder
FROM (VALUES
(N'Phố sách Đinh Lễ', '/images/attractions/gallery/24-pho-sach-dinh-le-1.jpg', N'Tòa nhà Bưu điện Hà Nội ở đầu phố Đinh Lễ', N'Nguyenmy2302 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:T%C3%B2a_nh%C3%A0_B%C6%B0u_%C4%91i%E1%BB%87n_%C4%90inh_L%E1%BB%85,_H%C3%A0_N%E1%BB%99i_(1).jpg', 1),
(N'Phố sách Đinh Lễ', '/images/attractions/gallery/24-pho-sach-dinh-le-2.jpg', N'Một góc tòa nhà bưu điện giáp phố Đinh Lễ', N'Nguyenmy2302 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:T%C3%B2a_nh%C3%A0_B%C6%B0u_%C4%91i%E1%BB%87n_%C4%90inh_L%E1%BB%85,_H%C3%A0_N%E1%BB%99i_(2).jpg', 2),
(N'Phố sách Đinh Lễ', '/images/attractions/gallery/24-pho-sach-dinh-le-3.jpg', N'Góc phố Đinh Lễ – Đinh Tiên Hoàng thời Pháp thuộc', N'Không rõ tác giả / Public domain', 'https://commons.wikimedia.org/wiki/File:B%C6%B0u_%C4%91i%E1%BB%87n_tr%C3%AAn_%C4%91%C6%B0%E1%BB%9Dng_%C4%90inh_Ti%C3%AAn_Ho%C3%A0ng_gi%C3%A1p_ph%E1%BB%91_%C4%90inh_L%E1%BB%85_x%C6%B0a.jpg', 3),
(N'Phố sách Đinh Lễ', '/images/attractions/gallery/24-pho-sach-dinh-le-4.jpg', N'Bưu điện Hà Nội trên phố Đinh Tiên Hoàng năm 1900', N'Không rõ tác giả / Public domain', 'https://commons.wikimedia.org/wiki/File:T%C3%B2a_nh%C3%A0_B%C6%B0u_%C4%91i%E1%BB%87n_n%E1%BA%B1m_gi%E1%BB%AFa_ph%E1%BB%91_%C4%90inh_Ti%C3%AAn_Ho%C3%A0ng_x%C6%B0a.jpg', 4),
(N'Công viên nước Hồ Tây', '/images/attractions/gallery/29-cong-vien-nuoc-ho-tay-1.jpg', N'Hồ Tây và vòng quay lúc hoàng hôn', N'Chris Lewis / CC BY 3.0', 'https://commons.wikimedia.org/wiki/File:WestLake,Hanoi.png', 1),
(N'Công viên nước Hồ Tây', '/images/attractions/gallery/29-cong-vien-nuoc-ho-tay-2.jpg', N'Vòng quay bên Hồ Tây nhìn từ xa', N'Chris Lewis / CC BY 3.0', 'https://commons.wikimedia.org/wiki/File:H%E1%BB%93_T%C3%A2y,_H%C3%A0_N%E1%BB%99i.png', 2),
(N'Thủy cung Times City', '/images/attractions/gallery/30-thuy-cung-times-city-1.jpg', N'Bể cá lớn với đàn cá biển', N'Góc nhọn nào đó / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Th%E1%BB%A7y_cung_Times_City_2.jpg', 1),
(N'Thủy cung Times City', '/images/attractions/gallery/30-thuy-cung-times-city-2.jpg', N'Khu chim cánh cụt', N'Góc nhọn nào đó / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Th%E1%BB%A7y_cung_Times_City_5.jpg', 2),
(N'Thủy cung Times City', '/images/attractions/gallery/30-thuy-cung-times-city-3.jpg', N'Rùa biển trong thủy cung', N'Góc nhọn nào đó / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:R%C3%B9a_t%E1%BA%A1i_th%E1%BB%A7y_cung_Times_City.jpg', 3),
(N'Thủy cung Times City', '/images/attractions/gallery/30-thuy-cung-times-city-4.jpg', N'Đường hầm kính xuyên qua bể cá', N'Góc nhọn nào đó / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Th%E1%BB%A7y_cung_Times_City_3.jpg', 4),
(N'Thủy cung Times City', '/images/attractions/gallery/30-thuy-cung-times-city-5.jpg', N'Lối đi trong khu trưng bày', N'Góc nhọn nào đó / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Th%E1%BB%A7y_cung_Times_City_1.jpg', 5),
(N'Đền Bạch Mã', '/images/attractions/gallery/37-den-bach-ma-5.jpg', N'Ban thờ chính trong đền', N'Benjamin Smith / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:Hanoi_-_B%E1%BA%A1ch_M%C3%A3_Temple.jpg', 5),
(N'Đền Bạch Mã', '/images/attractions/gallery/37-den-bach-ma-6.jpg', N'Phù điêu trang trí trong khuôn viên đền', N'Jakub Hałun / CC BY 4.0', 'https://commons.wikimedia.org/wiki/File:B%E1%BA%A1ch_M%C3%A3_Temple,_Hanoi,_20240123_0817_3022.jpg', 6),
(N'Bảo tàng Chiến thắng B-52', '/images/attractions/gallery/44-bao-tang-chien-thang-b52-5.jpg', N'Tòa nhà Bảo tàng Chiến thắng B-52', N'calflier001 / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:B52_VICTORY_CENTRE_HUU_TIEP_LAKE_BA_DINH_DISTRICT_HANOI_VIETNAM_JAN_2012_(6964117741).jpg', 5),
(N'Bảo tàng Chiến thắng B-52', '/images/attractions/gallery/44-bao-tang-chien-thang-b52-6.jpg', N'Tên lửa SAM-2 trong khu trưng bày ngoài trời', N'calflier001 / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:SURFACE_TO_AIR_MISSLES_AT_THE_B52_VICTORY_CENTRE_HUU_TIEP_LAKE_HA_NOI_VIETNAM_FEB_2012_(6979074507).jpg', 6),
(N'Bảo tàng Chiến thắng B-52', '/images/attractions/gallery/44-bao-tang-chien-thang-b52-7.jpg', N'Máy bay MiG-21 trưng bày ngoài trời', N'calflier001 / CC BY-SA 2.0', 'https://commons.wikimedia.org/wiki/File:MIG_21_VIETNAMESE_AIR_FORCE_AT_THE_B52_VICTORY_CENTRE_HUU_TIEP_LAKE_HA_NOI_VIETNAM_FEB_2012_(6832950578).jpg', 7)
) v(Name, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
JOIN TouristAttractions a ON a.Name = v.Name
WHERE NOT EXISTS (SELECT 1 FROM AttractionImages x WHERE x.ImageUrl = v.ImageUrl);
GO
SELECT a.AttractionId, a.Name, CASE WHEN a.ImageUrl IS NULL THEN 0 ELSE 1 END AS Hero,
       (SELECT COUNT(*) FROM AttractionImages i WHERE i.AttractionId = a.AttractionId) AS Images
FROM TouristAttractions a WHERE a.Name IN (N'Phố sách Đinh Lễ', N'Bảo tàng Thiên nhiên Việt Nam', N'Công viên nước Hồ Tây', N'Thủy cung Times City',
  N'Lotte Mall Tây Hồ', N'Đền Bạch Mã', N'Bảo tàng Chiến thắng B-52', N'Rạp xiếc Trung ương') ORDER BY a.AttractionId;
GO
