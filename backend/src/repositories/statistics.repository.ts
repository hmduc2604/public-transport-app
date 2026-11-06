/** Repository: thong ke cho Admin Dashboard */
import { getPool, sql } from '../config/database';

export const statisticsRepository = {
  async overview(days: number) {
    const pool = await getPool();
    const r = await pool.request().input('days', sql.Int, days).query(`
      -- 0. Tong quan
      SELECT
        (SELECT COUNT(*) FROM Users WHERE Role = 'USER') AS totalUsers,
        (SELECT COUNT(*) FROM Users WHERE Role = 'USER' AND CreatedAt >= DATEADD(DAY, -@days, SYSDATETIME())) AS newUsers,
        (SELECT COUNT(*) FROM Stations WHERE Status = 'ACTIVE') AS totalStations,
        (SELECT COUNT(*) FROM Routes WHERE Status = 'ACTIVE') AS totalRoutes,
        (SELECT COUNT(*) FROM Vehicles) AS totalVehicles,
        (SELECT COUNT(*) FROM Vehicles WHERE Status = 'ACTIVE') AS activeVehicles,
        (SELECT COUNT(*) FROM Trips) AS totalTrips,
        (SELECT COUNT(*) FROM TouristAttractions WHERE Status = 'ACTIVE') AS totalAttractions,
        (SELECT COUNT(*) FROM Orders) AS totalOrders,
        (SELECT COUNT(*) FROM Orders WHERE Status = 'PAID') AS paidOrders,
        (SELECT COUNT(*) FROM Orders WHERE Status = 'PENDING') AS pendingOrders,
        (SELECT CAST(ISNULL(SUM(Amount), 0) AS FLOAT) FROM Payments WHERE Status = 'SUCCESS') AS totalRevenue,
        (SELECT CAST(ISNULL(SUM(Amount), 0) AS FLOAT) FROM Payments
          WHERE Status = 'SUCCESS' AND PaidAt >= DATEADD(DAY, -@days, SYSDATETIME())) AS periodRevenue,
        (SELECT COUNT(*) FROM Tickets) AS ticketsSold,
        (SELECT COUNT(*) FROM Tickets WHERE Status = 'ACTIVE' AND ValidTo >= SYSDATETIME()) AS activeTickets,
        (SELECT COUNT(*) FROM TripHistories) AS totalTripSearches;

      -- 1. Doanh thu theo ngay
      SELECT CONVERT(VARCHAR(10), CAST(PaidAt AS DATE), 23) AS date,
             CAST(SUM(Amount) AS FLOAT) AS revenue, COUNT(*) AS payments
      FROM Payments
      WHERE Status = 'SUCCESS' AND PaidAt >= DATEADD(DAY, -@days, SYSDATETIME())
      GROUP BY CAST(PaidAt AS DATE)
      ORDER BY CAST(PaidAt AS DATE);

      -- 2. Ve ban theo loai ve
      SELECT tt.TicketTypeId AS ticketTypeId, tt.Name AS name, tt.Type AS type, t.Name AS transportTypeName,
             COUNT(tk.TicketId) AS ticketsSold, CAST(COUNT(tk.TicketId) * tt.Price AS FLOAT) AS revenue
      FROM TicketTypes tt
      JOIN TransportTypes t ON tt.TransportTypeId = t.TransportTypeId
      LEFT JOIN Tickets tk ON tk.TicketTypeId = tt.TicketTypeId
      GROUP BY tt.TicketTypeId, tt.Name, tt.Type, t.Name, tt.Price
      ORDER BY ticketsSold DESC;

      -- 3. Trang thai ve
      SELECT Status AS status, COUNT(*) AS total FROM Tickets GROUP BY Status;

      -- 4. Ha tang theo loai phuong tien
      SELECT t.TransportTypeId AS transportTypeId, t.Name AS name,
             (SELECT COUNT(*) FROM Stations s WHERE s.TransportTypeId = t.TransportTypeId AND s.Status = 'ACTIVE') AS stations,
             (SELECT COUNT(*) FROM Routes r WHERE r.TransportTypeId = t.TransportTypeId AND r.Status = 'ACTIVE') AS routes,
             (SELECT COUNT(*) FROM Vehicles v WHERE v.TransportTypeId = t.TransportTypeId) AS vehicles
      FROM TransportTypes t ORDER BY t.TransportTypeId;

      -- 5. Diem den duoc tim nhieu nhat
      SELECT TOP 5 Destination AS destination, COUNT(*) AS total
      FROM TripHistories GROUP BY Destination ORDER BY total DESC;

      -- 6. Don hang gan day
      SELECT TOP 5 o.OrderId AS orderId, u.FullName AS userName, CAST(o.TotalAmount AS FLOAT) AS totalAmount,
             o.Status AS status, o.CreatedAt AS createdAt
      FROM Orders o JOIN Users u ON o.UserId = u.UserId
      ORDER BY o.CreatedAt DESC;`);
    const s = r.recordsets as any[];
    return {
      overview: s[0][0],
      revenueByDay: s[1],
      ticketsByType: s[2],
      ticketsByStatus: s[3],
      transportSummary: s[4],
      topDestinations: s[5],
      recentOrders: s[6],
    };
  },
};
