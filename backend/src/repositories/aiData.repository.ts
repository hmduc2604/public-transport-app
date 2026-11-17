/**
 * Repository cho 2 chuc nang AI:
 *   AttractionEmbeddings  - vector ngu nghia cua tung dia diem (tinh 1 lan bang Gemini, luu lai)
 *   AttractionViews       - lich su quan tam cua nguoi dung (xem chi tiet / tim duong toi / tro ly goi y)
 */
import { getPool, sql } from '../config/database';

export type InterestSource = 'VIEW' | 'ROUTE' | 'ASSISTANT';

export interface StoredEmbedding {
  attractionId: number;
  model: string;
  contentHash: string;
  vector: number[];
}

export interface InterestRow {
  attractionId: number;
  source: InterestSource;
  daysAgo: number;
}

export const aiDataRepository = {
  async embeddings(model: string): Promise<StoredEmbedding[]> {
    const pool = await getPool();
    const r = await pool.request().input('model', sql.VarChar(100), model).query(`
      SELECT AttractionId AS attractionId, Model AS model, ContentHash AS contentHash, Vector AS vector
      FROM AttractionEmbeddings WHERE Model = @model`);
    return r.recordset.map((x: any) => ({ ...x, vector: JSON.parse(x.vector) as number[] }));
  },

  async saveEmbedding(e: StoredEmbedding) {
    const pool = await getPool();
    await pool
      .request()
      .input('id', sql.Int, e.attractionId)
      .input('model', sql.VarChar(100), e.model)
      .input('hash', sql.VarChar(64), e.contentHash)
      .input('dims', sql.Int, e.vector.length)
      .input('vector', sql.NVarChar(sql.MAX), JSON.stringify(e.vector.map((x) => Math.round(x * 1e6) / 1e6))).query(`
        UPDATE AttractionEmbeddings
           SET Model = @model, ContentHash = @hash, Dimensions = @dims, Vector = @vector, UpdatedAt = SYSDATETIME()
         WHERE AttractionId = @id;
        IF @@ROWCOUNT = 0
          INSERT INTO AttractionEmbeddings (AttractionId, Model, ContentHash, Dimensions, Vector)
          VALUES (@id, @model, @hash, @dims, @vector);`);
  },

  /** Ghi nhan 1 lan quan tam; cung nguoi + dia diem + nguon trong 10 phut chi tinh 1 lan */
  async addInterest(userId: number, attractionId: number, source: InterestSource) {
    const pool = await getPool();
    await pool
      .request()
      .input('userId', sql.Int, userId)
      .input('attractionId', sql.Int, attractionId)
      .input('source', sql.VarChar(20), source).query(`
        IF EXISTS (SELECT 1 FROM TouristAttractions WHERE AttractionId = @attractionId)
           AND NOT EXISTS (SELECT 1 FROM AttractionViews
                           WHERE UserId = @userId AND AttractionId = @attractionId AND Source = @source
                             AND ViewedAt > DATEADD(MINUTE, -10, SYSDATETIME()))
          INSERT INTO AttractionViews (UserId, AttractionId, Source) VALUES (@userId, @attractionId, @source);`);
  },

  /** Lich su quan tam 180 ngay gan nhat (toi da 300 lan) */
  async interests(userId: number): Promise<InterestRow[]> {
    const pool = await getPool();
    const r = await pool.request().input('userId', sql.Int, userId).query(`
      SELECT TOP 300 AttractionId AS attractionId, Source AS source,
             DATEDIFF(MINUTE, ViewedAt, SYSDATETIME()) / 1440.0 AS daysAgo
      FROM AttractionViews
      WHERE UserId = @userId AND ViewedAt > DATEADD(DAY, -180, SYSDATETIME())
      ORDER BY ViewedAt DESC`);
    return r.recordset.map((x: any) => ({ ...x, daysAgo: Number(x.daysAgo) }));
  },
};
