/* =====================================================================
   16_lotte_photos.sql - Anh chup that cho Lotte Mall Tay Ho (nhom suu tam, 18/11/2026):
   anh dai dien (mat tien) thay anh minh hoa + 6 anh bo suu tap (mat tien, gieng troi,
   thang cuon, hanh lang, toan canh). Anh nhom suu tam, khong phai giay phep tu do:
   ghi nguon "Anh suu tam"; anh toan canh ghi nguon Bao Lao Dong.
   An toan khi chay lai.
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
GO
USE PublicTransportDBV2;
GO
/* ---- Anh dai dien: thay anh minh hoa bang anh chup that (khong ghi de neu nhom da doi sang anh khac) ---- */
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/32-lotte-mall-tay-ho.jpg', ImageCredit = N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', ImageSourceUrl = NULL WHERE Name = N'Lotte Mall Tây Hồ' AND (ImageUrl IS NULL OR ImageCredit LIKE N'Ảnh minh họa%');
GO
/* ---- Bo suu tap: 6 anh moi xep truoc, 2 anh cong truong 2022 xep cuoi ---- */
INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
SELECT a.AttractionId, v.ImageUrl, v.Caption, v.Credit, NULL, v.SortOrder
FROM (VALUES
(N'Lotte Mall Tây Hồ', '/images/attractions/gallery/32-lotte-mall-tay-ho-3.jpg', N'Quảng trường trước lối vào chính với đài phun nước', N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', 1),
(N'Lotte Mall Tây Hồ', '/images/attractions/gallery/32-lotte-mall-tay-ho-4.jpg', N'Giếng trời nhiều tầng với mái kính lấy sáng', N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', 2),
(N'Lotte Mall Tây Hồ', '/images/attractions/gallery/32-lotte-mall-tay-ho-5.jpg', N'Đèn trang trí hình bồ công anh ở khu giếng trời', N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', 3),
(N'Lotte Mall Tây Hồ', '/images/attractions/gallery/32-lotte-mall-tay-ho-6.jpg', N'Thang cuốn nối các tầng mua sắm', N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', 4),
(N'Lotte Mall Tây Hồ', '/images/attractions/gallery/32-lotte-mall-tay-ho-7.jpg', N'Hành lang mua sắm với các cửa hàng thời trang, mỹ phẩm', N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', 5),
(N'Lotte Mall Tây Hồ', '/images/attractions/gallery/32-lotte-mall-tay-ho-8.jpg', N'Toàn cảnh tổ hợp: trung tâm thương mại, khách sạn L7 và tòa văn phòng Lotte', N'Báo Lao Động (laodong.vn)', 6)
) v(Name, ImageUrl, Caption, Credit, SortOrder)
JOIN TouristAttractions a ON a.Name = v.Name
WHERE NOT EXISTS (SELECT 1 FROM AttractionImages x WHERE x.ImageUrl = v.ImageUrl);
UPDATE AttractionImages SET SortOrder = 7 WHERE ImageUrl = '/images/attractions/gallery/32-lotte-mall-tay-ho-1.jpg';
UPDATE AttractionImages SET SortOrder = 8 WHERE ImageUrl = '/images/attractions/gallery/32-lotte-mall-tay-ho-2.jpg';
GO

SELECT a.AttractionId, a.Name, a.ImageCredit, (SELECT COUNT(*) FROM AttractionImages i WHERE i.AttractionId = a.AttractionId) AS Images
FROM TouristAttractions a WHERE a.Name = N'Lotte Mall Tây Hồ';
GO
