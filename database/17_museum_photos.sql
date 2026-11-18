/* =====================================================================
   17_museum_photos.sql - Anh chup that cho Bao tang Thien nhien Viet Nam (nhom suu tam, 18/11/2026):
   anh dai dien (toa nha + mo hinh khung long) thay anh minh hoa + 6 anh bo suu tap
   (cong vao, phong trung bay, tu hoa thach, tu sinh vat bien, duong ham thuy cung, xuong khung long). Anh nhom suu tam, khong phai
   giay phep tu do: ghi nguon "Anh suu tam"; anh tu sinh vat bien ghi nguon Bao VietNamNet.
   An toan khi chay lai.
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
GO
USE PublicTransportDBV2;
GO
/* ---- Anh dai dien: anh chup that (thay anh minh hoa neu con; khong ghi de neu nhom da doi sang anh khac) ---- */
UPDATE TouristAttractions SET ImageUrl = '/images/attractions/28-bao-tang-thien-nhien-viet-nam.jpg', ImageCredit = N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', ImageSourceUrl = NULL WHERE Name = N'Bảo tàng Thiên nhiên Việt Nam' AND (ImageUrl IS NULL OR ImageCredit LIKE N'Ảnh minh họa%');
GO
/* ---- Bo suu tap ---- */
INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
SELECT a.AttractionId, v.ImageUrl, v.Caption, v.Credit, NULL, v.SortOrder
FROM (VALUES
(N'Bảo tàng Thiên nhiên Việt Nam', '/images/attractions/gallery/28-bao-tang-thien-nhien-viet-nam-1.jpg', N'Cổng vào khu trưng bày ở số 18 Hoàng Quốc Việt', N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', 1),
(N'Bảo tàng Thiên nhiên Việt Nam', '/images/attractions/gallery/28-bao-tang-thien-nhien-viet-nam-2.jpg', N'Phòng trưng bày về sự sống và tiến hóa với mô hình, tiêu bản', N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', 2),
(N'Bảo tàng Thiên nhiên Việt Nam', '/images/attractions/gallery/28-bao-tang-thien-nhien-viet-nam-3.jpg', N'Tủ hóa thạch theo các kỷ địa chất (Cambri, Ordovic, Silur...)', N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', 3),
(N'Bảo tàng Thiên nhiên Việt Nam', '/images/attractions/gallery/28-bao-tang-thien-nhien-viet-nam-4.jpg', N'Tủ tiêu bản sinh vật biển: cá mập, cá đuối, vỏ ốc, san hô', N'Báo VietNamNet (vietnamnet.vn)', 4),
(N'Bảo tàng Thiên nhiên Việt Nam', '/images/attractions/gallery/28-bao-tang-thien-nhien-viet-nam-5.jpg', N'Đường hầm thủy cung với cá đuối, cá mập', N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', 5),
(N'Bảo tàng Thiên nhiên Việt Nam', '/images/attractions/gallery/28-bao-tang-thien-nhien-viet-nam-6.jpg', N'Bộ xương khủng long trong khu trưng bày', N'Ảnh sưu tầm (nhóm HanoiGo cung cấp)', 6)
) v(Name, ImageUrl, Caption, Credit, SortOrder)
JOIN TouristAttractions a ON a.Name = v.Name
WHERE NOT EXISTS (SELECT 1 FROM AttractionImages x WHERE x.ImageUrl = v.ImageUrl);
GO

SELECT a.AttractionId, a.Name, a.ImageCredit, (SELECT COUNT(*) FROM AttractionImages i WHERE i.AttractionId = a.AttractionId) AS Images
FROM TouristAttractions a WHERE a.Name = N'Bảo tàng Thiên nhiên Việt Nam';
GO
