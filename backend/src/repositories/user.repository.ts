/** Repository: bang Users */
import { getPool, sql } from '../config/database';
import { ColumnMap, insertRow, updateRow } from '../utils/sqlHelpers';

export interface UserRow {
  userId: number;
  fullName: string;
  email: string;
  phone: string | null;
  role: 'USER' | 'ADMIN';
  status: 'ACTIVE' | 'LOCKED';
  createdAt: Date;
  updatedAt: Date | null;
  emailVerifiedAt?: Date | null;
  phoneVerifiedAt?: Date | null;
}

export interface UserWithPassword extends UserRow {
  passwordHash: string;
}

const SELECT_USER = `
  SELECT UserId AS userId, FullName AS fullName, Email AS email, Phone AS phone,
         Role AS role, Status AS status, CreatedAt AS createdAt, UpdatedAt AS updatedAt,
         EmailVerifiedAt AS emailVerifiedAt, PhoneVerifiedAt AS phoneVerifiedAt
  FROM Users`;

const COLUMNS: ColumnMap = {
  fullName: { column: 'FullName', type: sql.NVarChar(100) },
  email: { column: 'Email', type: sql.VarChar(150) },
  passwordHash: { column: 'PasswordHash', type: sql.VarChar(255) },
  phone: { column: 'Phone', type: sql.VarChar(20) },
  role: { column: 'Role', type: sql.VarChar(20) },
  status: { column: 'Status', type: sql.VarChar(20) },
  emailVerifiedAt: { column: 'EmailVerifiedAt', type: sql.DateTime2 },
  phoneVerifiedAt: { column: 'PhoneVerifiedAt', type: sql.DateTime2 },
};

export const userRepository = {
  async findByEmail(email: string): Promise<UserWithPassword | null> {
    const pool = await getPool();
    const r = await pool
      .request()
      .input('email', sql.VarChar(150), email)
      .query(
        `SELECT UserId AS userId, FullName AS fullName, Email AS email, Phone AS phone, Role AS role,
                Status AS status, CreatedAt AS createdAt, UpdatedAt AS updatedAt, PasswordHash AS passwordHash
         FROM Users WHERE Email = @email`,
      );
    return r.recordset[0] ?? null;
  },

  /** Dang nhap bang so dien thoai (Phone da chuan hoa 0xxxxxxxxx) */
  async findByPhone(phone: string): Promise<UserWithPassword | null> {
    const pool = await getPool();
    const r = await pool
      .request()
      .input('phone', sql.VarChar(20), phone)
      .query(
        `SELECT UserId AS userId, FullName AS fullName, Email AS email, Phone AS phone, Role AS role,
                Status AS status, CreatedAt AS createdAt, UpdatedAt AS updatedAt, PasswordHash AS passwordHash
         FROM Users WHERE Phone = @phone`,
      );
    return r.recordset[0] ?? null;
  },

  async findById(userId: number): Promise<UserRow | null> {
    const pool = await getPool();
    const r = await pool.request().input('id', sql.Int, userId).query(`${SELECT_USER} WHERE UserId = @id`);
    return r.recordset[0] ?? null;
  },

  async getPasswordHash(userId: number): Promise<string | null> {
    const pool = await getPool();
    const r = await pool
      .request()
      .input('id', sql.Int, userId)
      .query('SELECT PasswordHash AS passwordHash FROM Users WHERE UserId = @id');
    return r.recordset[0]?.passwordHash ?? null;
  },

  create(data: {
    fullName: string;
    email: string;
    passwordHash: string;
    phone?: string | null;
    role?: string;
    emailVerifiedAt?: Date | null;
    phoneVerifiedAt?: Date | null;
  }) {
    return insertRow('Users', 'UserId', COLUMNS, { role: 'USER', status: 'ACTIVE', ...data });
  },

  update(userId: number, data: Partial<Record<keyof typeof COLUMNS, any>>) {
    return updateRow('Users', 'UserId', userId, COLUMNS, data, ['UpdatedAt = SYSDATETIME()']);
  },

  /** Danh sach co tim kiem + loc + phan trang (Admin) */
  async list(opts: { search?: string; role?: string; status?: string; offset: number; pageSize: number }) {
    const pool = await getPool();
    const where: string[] = ['1 = 1'];
    const req = pool.request();
    if (opts.search) {
      where.push('(FullName LIKE @search OR Email LIKE @search OR Phone LIKE @search)');
      req.input('search', sql.NVarChar(200), `%${opts.search}%`);
    }
    if (opts.role) {
      where.push('Role = @role');
      req.input('role', sql.VarChar(20), opts.role);
    }
    if (opts.status) {
      where.push('Status = @status');
      req.input('status', sql.VarChar(20), opts.status);
    }
    req.input('offset', sql.Int, opts.offset).input('pageSize', sql.Int, opts.pageSize);
    const r = await req.query(`
      SELECT COUNT(*) AS total FROM Users WHERE ${where.join(' AND ')};
      SELECT u.UserId AS userId, u.FullName AS fullName, u.Email AS email, u.Phone AS phone,
             u.Role AS role, u.Status AS status, u.CreatedAt AS createdAt, u.UpdatedAt AS updatedAt,
             (SELECT COUNT(*) FROM Orders o WHERE o.UserId = u.UserId AND o.Status = 'PAID') AS paidOrders
      FROM Users u WHERE ${where.join(' AND ')}
      ORDER BY u.UserId DESC
      OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY;`);
    const sets = r.recordsets as any[];
    return { total: sets[0][0].total as number, items: sets[1] as (UserRow & { paidOrders: number })[] };
  },
};
