/** Repository: TouristAttractions + AttractionStations */
import { getPool, sql } from '../config/database';
import { ColumnMap, haversineSql, insertRow, updateRow, withTransaction } from '../utils/sqlHelpers';

const FIELDS = `
  a.AttractionId AS attractionId, a.Name AS name, a.Description AS description,
  a.History AS history, a.Highlights AS highlights, a.Address AS address,
  CAST(a.Latitude AS FLOAT) AS latitude, CAST(a.Longitude AS FLOAT) AS longitude,
  a.Category AS category, a.OpeningHours AS openingHours, a.TicketPrice AS ticketPrice,
  a.ImageUrl AS imageUrl, a.ImageCredit AS imageCredit, a.ImageSourceUrl AS imageSourceUrl,
  a.HoursSummary AS hoursSummary, a.PriceFrom AS priceFrom, a.VisitDuration AS visitDuration,
  a.BestTime AS bestTime, a.Tips AS tips,
  a.PopularityScore AS popularityScore, a.Status AS status,
  a.CreatedAt AS createdAt, a.UpdatedAt AS updatedAt`;

const COLUMNS: ColumnMap = {
  name: { column: 'Name', type: sql.NVarChar(200) },
  description: { column: 'Description', type: sql.NVarChar(1000) },
  history: { column: 'History', type: sql.NVarChar(sql.MAX) },
  highlights: { column: 'Highlights', type: sql.NVarChar(sql.MAX) },
  address: { column: 'Address', type: sql.NVarChar(255) },
  latitude: { column: 'Latitude', type: sql.Decimal(9, 6) },
  longitude: { column: 'Longitude', type: sql.Decimal(9, 6) },
  category: { column: 'Category', type: sql.NVarChar(100) },
  openingHours: { column: 'OpeningHours', type: sql.NVarChar(500) },
  ticketPrice: { column: 'TicketPrice', type: sql.NVarChar(500) },
  imageUrl: { column: 'ImageUrl', type: sql.VarChar(500) },
  imageCredit: { column: 'ImageCredit', type: sql.NVarChar(300) },
  imageSourceUrl: { column: 'ImageSourceUrl', type: sql.VarChar(500) },
  hoursSummary: { column: 'HoursSummary', type: sql.NVarChar(100) },
  priceFrom: { column: 'PriceFrom', type: sql.NVarChar(50) },
  visitDuration: { column: 'VisitDuration', type: sql.NVarChar(100) },
  bestTime: { column: 'BestTime', type: sql.NVarChar(300) },
  tips: { column: 'Tips', type: sql.NVarChar(sql.MAX) },
  popularityScore: { column: 'PopularityScore', type: sql.Int },
  status: { column: 'Status', type: sql.VarChar(20) },
};

const SORTS: Record<string, string> = {
  popular: 'a.PopularityScore DESC, a.Name ASC',
  name: 'a.Name ASC',
  newest: 'a.CreatedAt DESC',
};

export const attractionRepository = {
  /** GET /attractions?category=&search=&sort= (ket hop duoc) */
  async list(opts: { category?: string; search?: string; sort?: string; includeInactive?: boolean } = {}) {
    const pool = await getPool();
    const req = pool.request();
    const where = ['1 = 1'];
    if (!opts.includeInactive) where.push("a.Status = 'ACTIVE'");
    if (opts.category) {
      where.push('a.Category = @category');
      req.input('category', sql.NVarChar(100), opts.category);
    }
    if (opts.search) {
      where.push('(a.Name LIKE @search OR a.Description LIKE @search OR a.Address LIKE @search OR a.Category LIKE @search)');
      req.input('search', sql.NVarChar(200), `%${opts.search}%`);
    }
    const order = opts.sort && Object.prototype.hasOwnProperty.call(SORTS, opts.sort) ? SORTS[opts.sort] : SORTS.popular;
    const r = await req.query(`SELECT ${FIELDS} FROM TouristAttractions a WHERE ${where.join(' AND ')} ORDER BY ${order}`);
    return r.recordset;
  },

  async featured(limit: number) {
    const pool = await getPool();
    const r = await pool.request().input('limit', sql.Int, limit).query(`
      SELECT TOP (@limit) ${FIELDS} FROM TouristAttractions a
      WHERE a.Status = 'ACTIVE'
      ORDER BY a.PopularityScore DESC, a.Name ASC`);
    return r.recordset;
  },

  async categories() {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT Category AS category, COUNT(*) AS total
      FROM TouristAttractions
      WHERE Status = 'ACTIVE' AND Category IS NOT NULL
      GROUP BY Category ORDER BY total DESC, Category`);
    return r.recordset as { category: string; total: number }[];
  },

  async getById(id: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, id).query(`SELECT ${FIELDS} FROM TouristAttractions a WHERE a.AttractionId = @id`);
    return r.recordset[0] ?? null;
  },

  /** Bo suu tap anh cua diem tham quan (AttractionImages) */
  async images(attractionId: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, attractionId).query(`
      SELECT ImageId AS imageId, ImageUrl AS imageUrl, Caption AS caption, Credit AS credit,
             SourceUrl AS sourceUrl, SortOrder AS sortOrder
      FROM AttractionImages WHERE AttractionId = @id
      ORDER BY SortOrder, ImageId`);
    return r.recordset;
  },

  /** Tat ca anh bo suu tap (admin) */
  async allImages() {
    const pool = await getPool();
    const r = await pool.request().query(`
      SELECT AttractionId AS attractionId, ImageUrl AS imageUrl, Caption AS caption, Credit AS credit, SourceUrl AS sourceUrl
      FROM AttractionImages ORDER BY AttractionId, SortOrder, ImageId`);
    return r.recordset as any[];
  },

  /** Dem so anh trong bo suu tap cua tung diem (hien tren the "Kham pha") */
  async imageCounts(): Promise<Map<number, number>> {
    const pool = await getPool();
    const r = await pool.request().query('SELECT AttractionId AS id, COUNT(*) AS total FROM AttractionImages GROUP BY AttractionId');
    return new Map(r.recordset.map((x: any) => [x.id as number, x.total as number]));
  },

  /** Admin: thay toan bo bo suu tap anh */
  replaceImages(
    attractionId: number,
    images: { imageUrl: string; caption?: string | null; credit?: string | null; sourceUrl?: string | null }[],
  ) {
    return withTransaction(async (tx) => {
      await new sql.Request(tx).input('id', sql.Int, attractionId).query('DELETE FROM AttractionImages WHERE AttractionId = @id');
      let order = 1;
      for (const img of images) {
        await new sql.Request(tx)
          .input('aid', sql.Int, attractionId)
          .input('url', sql.VarChar(500), img.imageUrl)
          .input('cap', sql.NVarChar(200), img.caption ?? null)
          .input('cre', sql.NVarChar(300), img.credit ?? null)
          .input('src', sql.VarChar(500), img.sourceUrl ?? null)
          .input('ord', sql.Int, order++)
          .query(
            `INSERT INTO AttractionImages (AttractionId, ImageUrl, Caption, Credit, SourceUrl, SortOrder)
             VALUES (@aid, @url, @cap, @cre, @src, @ord)`,
          );
      }
    });
  },

  /** Diem tham quan gan toa do (truy van so 4) */
  async nearby(lat: number, lng: number, radiusKm: number, limit: number) {
    const pool = await getPool();
    const r = await pool
      .request()
      .input('lat', sql.Float, lat)
      .input('lng', sql.Float, lng)
      .input('radius', sql.Float, radiusKm)
      .input('limit', sql.Int, limit).query(`
      SELECT TOP (@limit) * FROM (
        SELECT ${FIELDS}, ${haversineSql('a.Latitude', 'a.Longitude')} AS distanceKm
        FROM TouristAttractions a WHERE a.Status = 'ACTIVE'
      ) x WHERE x.distanceKm <= @radius ORDER BY x.distanceKm`);
    return r.recordset;
  },

  /** Tram gan diem tham quan (truy van so 5) */
  async nearbyStations(attractionId: number) {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, attractionId).query(`
      SELECT s.StationId AS stationId, s.StationCode AS stationCode, s.StationName AS stationName,
             CAST(s.Latitude AS FLOAT) AS latitude, CAST(s.Longitude AS FLOAT) AS longitude,
             s.TransportTypeId AS transportTypeId, t.Name AS transportTypeName,
             CAST(ats.WalkingDistance AS FLOAT) AS walkingDistance, ats.WalkingDuration AS walkingDuration
      FROM AttractionStations ats
      JOIN Stations s ON ats.StationId = s.StationId
      JOIN TransportTypes t ON s.TransportTypeId = t.TransportTypeId
      WHERE ats.AttractionId = @id AND s.Status = 'ACTIVE'
      ORDER BY ats.WalkingDistance`);
    return r.recordset;
  },

  create: (data: Record<string, any>) => insertRow('TouristAttractions', 'AttractionId', COLUMNS, data),
  update: (id: number, data: Record<string, any>) =>
    updateRow('TouristAttractions', 'AttractionId', id, COLUMNS, data, ['UpdatedAt = SYSDATETIME()']),

  replaceStations(
    attractionId: number,
    stations: { stationId: number; walkingDistance?: number | null; walkingDuration?: number | null }[],
  ) {
    return withTransaction(async (tx) => {
      await new sql.Request(tx).input('id', sql.Int, attractionId).query('DELETE FROM AttractionStations WHERE AttractionId = @id');
      for (const s of stations) {
        await new sql.Request(tx)
          .input('aid', sql.Int, attractionId)
          .input('sid', sql.Int, s.stationId)
          .input('dist', sql.Decimal(10, 2), s.walkingDistance ?? null)
          .input('dur', sql.Int, s.walkingDuration ?? null)
          .query(
            `INSERT INTO AttractionStations (AttractionId, StationId, WalkingDistance, WalkingDuration)
             VALUES (@aid, @sid, @dist, @dur)`,
          );
      }
    });
  },
};
