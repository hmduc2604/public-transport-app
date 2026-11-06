/* Du lieu trich tu database/02_seed.sql de test thuat toan khong can SQL Server */
import { TransitNetworkData } from '../../src/algorithms/routing';

const TYPE_NAMES: Record<number, string> = { 1: 'Bus', 2: 'Metro', 3: 'Bicycle', 4: 'Electric Vehicle' };

const stations: [string, string, number, number, number][] = [
  ['BUS-ST01', 'Bờ Hồ Hoàn Kiếm', 21.028511, 105.854444, 1],
  ['BUS-ST02', 'Nhà hát Lớn', 21.024206, 105.857265, 1],
  ['BUS-ST03', 'Chợ Đồng Xuân', 21.038100, 105.849700, 1],
  ['BUS-ST04', 'Văn Miếu', 21.027039, 105.835650, 1],
  ['BUS-ST05', 'Lăng Chủ tịch Hồ Chí Minh', 21.036800, 105.834900, 1],
  ['BUS-ST06', 'Hoàng thành Thăng Long', 21.035600, 105.841700, 1],
  ['BUS-ST07', 'Hồ Tây', 21.055300, 105.818900, 1],
  ['BUS-ST08', 'Cầu Long Biên', 21.043700, 105.850200, 1],
  ['METRO-ST01', 'Cát Linh', 21.027600, 105.841200, 2],
  ['METRO-ST02', 'La Thành', 21.021500, 105.814000, 2],
  ['METRO-ST03', 'Thái Hà', 21.013700, 105.821600, 2],
  ['METRO-ST04', 'Láng', 21.008600, 105.801900, 2],
  ['BIKE-ST01', 'Điểm xe đạp Hoàn Kiếm', 21.028900, 105.852000, 3],
  ['BIKE-ST02', 'Điểm xe đạp Nhà hát Lớn', 21.023900, 105.858000, 3],
  ['BIKE-ST03', 'Điểm xe đạp Văn Miếu', 21.027200, 105.834800, 3],
  ['BIKE-ST04', 'Điểm xe đạp Ba Đình', 21.034900, 105.837500, 3],
  ['EV-ST01', 'Điểm xe điện Hoàn Kiếm', 21.030000, 105.854500, 4],
  ['EV-ST02', 'Điểm xe điện Phố cổ', 21.034500, 105.850500, 4],
  ['EV-ST03', 'Điểm xe điện Ba Đình', 21.035800, 105.839000, 4],
  ['EV-ST04', 'Điểm xe điện Hồ Tây', 21.053500, 105.817500, 4],
  ['BUS-ST09', 'Ga Hà Nội', 21.024400, 105.841100, 1],
  ['BUS-ST10', 'Nhà tù Hỏa Lò', 21.025500, 105.846300, 1],
  ['BUS-ST11', 'Bảo tàng Dân tộc học', 21.040500, 105.799000, 1],
  ['BUS-ST12', 'Chùa Trấn Quốc', 21.047800, 105.836700, 1],
  ['BIKE-ST05', 'Điểm xe đạp Hồ Tây', 21.048500, 105.835500, 3],
  ['BIKE-ST06', 'Điểm xe đạp Phố cổ', 21.034200, 105.851500, 3],
  ['EV-ST05', 'Điểm xe điện Nhà hát Lớn', 21.024600, 105.856600, 4],
];

const routes: [string, string, number][] = [
  ['BUS01', 'Hoàn Kiếm - Văn Miếu', 1],
  ['BUS02', 'Hoàn Kiếm - Ba Đình', 1],
  ['BUS03', 'Hoàn Kiếm - Hồ Tây', 1],
  ['BUS04', 'Nhà hát Lớn - Chợ Đồng Xuân', 1],
  ['BUS05', 'Văn Miếu - Hoàng thành', 1],
  ['BUS06', 'Ba Đình - Hồ Tây', 1],
  ['BUS07', 'Hoàn Kiếm - Cầu Long Biên', 1],
  ['BUS08', 'Cầu Long Biên - Hồ Tây', 1],
  ['METRO2A', 'Cát Linh - Hà Đông', 2],
  ['BIKE01', 'Xe đạp khu vực Hoàn Kiếm', 3],
  ['EV01', 'Xe điện khu vực Hoàn Kiếm - Ba Đình', 4],
  ['BUS09', 'Ga Hà Nội - Nhà hát Lớn', 1],
  ['BUS10', 'Cầu Giấy - Hồ Tây - Ba Đình', 1],
  ['BUS11', 'Ga Hà Nội - Lăng Bác', 1],
  ['BIKE02', 'Xe đạp Hồ Tây - Văn Miếu', 3],
  ['BIKE03', 'Xe đạp Phố cổ - Nhà hát Lớn', 3],
  ['EV02', 'Xe điện Nhà hát Lớn - Hồ Tây', 4],
];

const routeStops: [number, number, number, number][] = [
  [1, 1, 1, 0], [1, 4, 2, 2200], [1, 9, 3, 3000], [2, 1, 1, 0], [2, 6, 2, 2500], [2, 5, 3, 3500], [3, 1, 1, 0], [3, 3, 2, 1800], [3, 7, 3, 4500], [4, 2, 1, 0], [4, 3, 2, 2500], [4, 8, 3, 4000], [5, 4, 1, 0], [5, 6, 2, 1800], [5, 5, 3, 3000], [6, 5, 1, 0], [6, 6, 2, 1000], [6, 7, 3, 3500], [7, 1, 1, 0], [7, 3, 2, 1800], [7, 8, 3, 3000], [8, 8, 1, 0], [8, 3, 2, 3000], [8, 7, 3, 6000], [9, 9, 1, 0], [9, 10, 2, 1800], [9, 11, 3, 3200], [9, 12, 4, 5000], [10, 13, 1, 0], [10, 14, 2, 1500], [10, 15, 3, 3500], [11, 17, 1, 0], [11, 18, 2, 1200], [11, 19, 3, 2500], [12, 21, 1, 0], [12, 22, 2, 720], [12, 1, 3, 1900], [12, 2, 4, 2630], [13, 23, 1, 0], [13, 7, 2, 3430], [13, 24, 3, 6070], [13, 5, 4, 7680], [14, 21, 1, 0], [14, 4, 2, 830], [14, 6, 3, 2310], [14, 5, 4, 3240], [15, 25, 1, 0], [15, 16, 2, 1980], [15, 15, 3, 3160], [16, 26, 1, 0], [16, 13, 2, 770], [16, 14, 3, 1850], [17, 27, 1, 0], [17, 17, 2, 830], [17, 18, 3, 1680], [17, 20, 4, 6910]
];

const fareRules: [number, number, number, number][] = [
  [1, 1, 4, 10000], [1, 1, 5, 10000], [1, 1, 7, 15000], [1, 2, 3, 10000], [1, 23, 5, 15000], [1, 8, 7, 15000], [2, 9, 10, 10000], [2, 9, 11, 12000], [2, 9, 12, 15000], [2, 10, 11, 8000], [2, 10, 12, 10000], [2, 11, 12, 8000], [3, 13, 14, 5000], [3, 14, 15, 5000], [4, 17, 18, 10000], [4, 18, 19, 10000], [4, 27, 20, 20000]
];

const attractionAccess: [number, number, number, number][] = [
  [1, 1, 200, 3], [1, 13, 250, 3], [1, 17, 200, 3], [2, 1, 350, 5], [2, 17, 150, 2], [3, 1, 500, 7], [3, 3, 400, 5], [3, 18, 100, 2], [3, 26, 100, 2], [4, 3, 200, 3], [5, 2, 200, 3], [5, 14, 100, 2], [5, 27, 100, 2], [6, 1, 900, 12], [6, 4, 1200, 15], [6, 22, 100, 2], [7, 6, 300, 4], [7, 9, 900, 12], [7, 19, 300, 4], [8, 5, 200, 3], [8, 6, 700, 9], [9, 5, 150, 2], [10, 5, 500, 7], [11, 4, 250, 3], [11, 9, 500, 6], [11, 15, 150, 2], [12, 5, 400, 5], [12, 15, 250, 3], [13, 2, 300, 4], [13, 27, 200, 3], [14, 7, 1500, 20], [14, 23, 250, 3], [15, 7, 300, 4], [15, 20, 200, 3], [16, 7, 1200, 15], [16, 24, 100, 2], [16, 25, 150, 2], [17, 3, 500, 7], [17, 26, 100, 2], [18, 1, 600, 8], [18, 22, 350, 5], [19, 8, 400, 5], [20, 1, 350, 5], [20, 17, 200, 3]
];

export const attractions: { id: number; name: string; latitude: number; longitude: number }[] = [
  { id: 1, name: 'Hồ Hoàn Kiếm', latitude: 21.028511, longitude: 105.854444 },
  { id: 2, name: 'Đền Ngọc Sơn', latitude: 21.030035, longitude: 105.852640 },
  { id: 3, name: 'Phố cổ Hà Nội', latitude: 21.034000, longitude: 105.850000 },
  { id: 4, name: 'Chợ Đồng Xuân', latitude: 21.038100, longitude: 105.849700 },
  { id: 5, name: 'Nhà hát Lớn Hà Nội', latitude: 21.024206, longitude: 105.857265 },
  { id: 6, name: 'Nhà tù Hỏa Lò', latitude: 21.025700, longitude: 105.846800 },
  { id: 7, name: 'Hoàng thành Thăng Long', latitude: 21.035600, longitude: 105.841700 },
  { id: 8, name: 'Lăng Chủ tịch Hồ Chí Minh', latitude: 21.036800, longitude: 105.834900 },
  { id: 9, name: 'Quảng trường Ba Đình', latitude: 21.036700, longitude: 105.835000 },
  { id: 10, name: 'Chùa Một Cột', latitude: 21.035800, longitude: 105.833800 },
  { id: 11, name: 'Văn Miếu - Quốc Tử Giám', latitude: 21.027039, longitude: 105.835650 },
  { id: 12, name: 'Bảo tàng Mỹ thuật Việt Nam', latitude: 21.029500, longitude: 105.833500 },
  { id: 13, name: 'Bảo tàng Lịch sử Quốc gia', latitude: 21.025300, longitude: 105.858000 },
  { id: 14, name: 'Bảo tàng Dân tộc học Việt Nam', latitude: 21.040700, longitude: 105.798300 },
  { id: 15, name: 'Hồ Tây', latitude: 21.055300, longitude: 105.818900 },
  { id: 16, name: 'Chùa Trấn Quốc', latitude: 21.048000, longitude: 105.836000 },
  { id: 17, name: 'Phố Tạ Hiện', latitude: 21.034900, longitude: 105.851000 },
  { id: 18, name: 'Phố sách Hà Nội', latitude: 21.027500, longitude: 105.849000 },
  { id: 19, name: 'Cầu Long Biên', latitude: 21.043700, longitude: 105.850200 },
  { id: 20, name: 'Nhà hát Múa rối Thăng Long', latitude: 21.031700, longitude: 105.852700 },
];

export const seedNetworkData: TransitNetworkData = {
  stations: stations.map(([code, name, lat, lng, typeId], i) => ({
    stationId: i + 1,
    stationCode: code,
    stationName: name,
    latitude: lat,
    longitude: lng,
    address: null,
    transportTypeId: typeId,
    transportTypeName: TYPE_NAMES[typeId],
    status: 'ACTIVE',
  })),
  routes: routes.map(([code, name, typeId], i) => ({
    routeId: i + 1,
    routeCode: code,
    routeName: name,
    transportTypeId: typeId,
    transportTypeName: TYPE_NAMES[typeId],
    mode: typeId === 1 ? 'BUS' : typeId === 2 ? 'METRO' : typeId === 3 ? 'BICYCLE' : 'ELECTRIC_VEHICLE',
    status: 'ACTIVE',
  })),
  routeStops: routeStops.map(([routeId, stationId, stopOrder, distanceFromStart]) => ({
    routeId,
    stationId,
    stopOrder,
    distanceFromStart,
  })),
  fareRules: fareRules.map(([transportTypeId, fromStationId, toStationId, price]) => ({
    transportTypeId,
    fromStationId,
    toStationId,
    price,
  })),
  attractionAccess: attractionAccess.map(([attractionId, stationId, walkingDistance, walkingDuration]) => ({
    attractionId,
    stationId,
    walkingDistance,
    walkingDuration,
  })),
  departures: {
    // BUS01 tai Bo Ho (tram 1): 05:30 -> 22:00 moi 20 phut
    '1:1': Array.from({ length: 50 }, (_, i) => {
      const m = 330 + i * 20;
      return `${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`;
    }),
  },
};
