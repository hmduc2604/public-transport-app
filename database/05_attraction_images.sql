/* =====================================================================
   05_attraction_images.sql - Them anh cho 20 diem tham quan (chay tren DB da co)
   - Them cot ImageCredit, ImageSourceUrl (neu chua co)
   - Gan ImageUrl = /images/attractions/... (file nam trong frontend/public)
   ===================================================================== */
USE PublicTransportDBV2;
GO
IF COL_LENGTH('TouristAttractions', 'ImageCredit') IS NULL
    ALTER TABLE TouristAttractions ADD ImageCredit NVARCHAR(300) NULL;
IF COL_LENGTH('TouristAttractions', 'ImageSourceUrl') IS NULL
    ALTER TABLE TouristAttractions ADD ImageSourceUrl VARCHAR(500) NULL;
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

SELECT AttractionId, Name, ImageUrl FROM TouristAttractions ORDER BY AttractionId;
GO
