/* =====================================================================
   15_illustrations.sql - Lotte Mall Tay Ho: 2 anh that chup cong trinh nam 2022
   (Wikimedia Commons, CC BY-SA 4.0), xep cuoi bo suu tap.
   (Ban dau file nay dat anh minh hoa cho Bao tang Thien nhien va Lotte Mall; nay da thay
   bang anh chup that do nhom suu tam: xem 16_lotte_photos.sql, 17_museum_photos.sql.)
   An toan khi chay lai.
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
GO
USE PublicTransportDBV2;
GO
/* ---- Bo suu tap Lotte Mall Tay Ho: 2 anh that chup cong trinh nam 2022 (Wikimedia Commons) ---- */
INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
SELECT a.AttractionId, v.ImageUrl, v.Caption, v.Credit, v.SourceUrl, v.SortOrder
FROM (VALUES
(N'Lotte Mall Tây Hồ', '/images/attractions/gallery/32-lotte-mall-tay-ho-1.jpg', N'Khối công trình Lotte Mall Tây Hồ nhìn từ đường Võ Chí Công (7/2022, trước khi khai trương)', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:2022-07-26_V%C3%B5_Ch%C3%AD_C%C3%B4ng_Road,_Hanoi_004.jpg', 7),
(N'Lotte Mall Tây Hồ', '/images/attractions/gallery/32-lotte-mall-tay-ho-2.jpg', N'Hàng rào công trường khu thủy cung Lotte Mall Tây Hồ (1/2022)', N'Ltn12345 / CC BY-SA 4.0', 'https://commons.wikimedia.org/wiki/File:V%C3%B5_Ch%C3%AD_C%C3%B4ng_Road,_Hanoi_8688.jpg', 8)
) v(Name, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
JOIN TouristAttractions a ON a.Name = v.Name
WHERE NOT EXISTS (SELECT 1 FROM AttractionImages x WHERE x.ImageUrl = v.ImageUrl);
GO

SELECT a.AttractionId, a.Name, a.ImageUrl, (SELECT COUNT(*) FROM AttractionImages i WHERE i.AttractionId = a.AttractionId) AS Images
FROM TouristAttractions a WHERE a.Name IN (N'Bảo tàng Thiên nhiên Việt Nam', N'Lotte Mall Tây Hồ') ORDER BY a.AttractionId;
GO
