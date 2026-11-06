/**
 * Ham tro giup INSERT / UPDATE dong cho cac bang CRUD (Admin).
 * Ten bang / ten cot lay tu hang so trong code (KHONG lay tu input nguoi dung)
 * -> an toan SQL injection. Gia tri luon truyen qua tham so @param.
 */
import { getPool, sql } from '../config/database';

export type SqlType = sql.ISqlType | sql.ISqlTypeFactoryWithNoParams | (() => sql.ISqlType);

export interface ColumnDef {
  column: string;
  type: SqlType;
}

export type ColumnMap = Record<string, ColumnDef>;

type Executor = sql.ConnectionPool | sql.Transaction;

async function newRequest(executor?: Executor): Promise<sql.Request> {
  if (executor) return new sql.Request(executor as any);
  const pool = await getPool();
  return pool.request();
}

/** INSERT 1 dong, tra ve ID vua tao */
export async function insertRow(
  table: string,
  idColumn: string,
  columns: ColumnMap,
  data: Record<string, any>,
  executor?: Executor,
): Promise<number> {
  const req = await newRequest(executor);
  const cols: string[] = [];
  const params: string[] = [];
  for (const [key, def] of Object.entries(columns)) {
    if (data[key] === undefined) continue;
    cols.push(def.column);
    params.push(`@${key}`);
    req.input(key, def.type as any, data[key]);
  }
  const result = await req.query(
    `INSERT INTO ${table} (${cols.join(', ')}) OUTPUT INSERTED.${idColumn} AS id VALUES (${params.join(', ')})`,
  );
  return result.recordset[0].id;
}

/** UPDATE theo ID - chi cap nhat cac field co trong data. Tra ve true neu co dong bi anh huong */
export async function updateRow(
  table: string,
  idColumn: string,
  id: number,
  columns: ColumnMap,
  data: Record<string, any>,
  extraSet: string[] = [],
  executor?: Executor,
): Promise<boolean> {
  const req = await newRequest(executor);
  const sets: string[] = [...extraSet];
  for (const [key, def] of Object.entries(columns)) {
    if (data[key] === undefined) continue;
    sets.push(`${def.column} = @${key}`);
    req.input(key, def.type as any, data[key]);
  }
  if (sets.length === 0) return true;
  req.input('__id', sql.Int, id);
  const result = await req.query(`UPDATE ${table} SET ${sets.join(', ')} WHERE ${idColumn} = @__id`);
  return result.rowsAffected[0] > 0;
}

export async function deleteRow(table: string, idColumn: string, id: number): Promise<boolean> {
  const pool = await getPool();
  const result = await pool.request().input('id', sql.Int, id).query(`DELETE FROM ${table} WHERE ${idColumn} = @id`);
  return result.rowsAffected[0] > 0;
}

/** Chay nhieu cau lenh trong 1 transaction (tu rollback neu loi) */
export async function withTransaction<T>(fn: (tx: sql.Transaction) => Promise<T>): Promise<T> {
  const pool = await getPool();
  const tx = new sql.Transaction(pool);
  await tx.begin();
  try {
    const result = await fn(tx);
    await tx.commit();
    return result;
  } catch (err) {
    try {
      await tx.rollback();
    } catch {
      /* transaction da bi SQL Server huy */
    }
    throw err;
  }
}

/** Chuoi Haversine (km) dung trong SQL - giong truy van so 3 trong file "Truy van db" */
export function haversineSql(latCol: string, lngCol: string, latParam = '@lat', lngParam = '@lng'): string {
  return `(6371 * 2 * ASIN(SQRT(
      POWER(SIN(RADIANS(${latCol} - ${latParam}) / 2), 2)
    + COS(RADIANS(${latParam})) * COS(RADIANS(${latCol}))
    * POWER(SIN(RADIANS(${lngCol} - ${lngParam}) / 2), 2)
  )))`;
}
