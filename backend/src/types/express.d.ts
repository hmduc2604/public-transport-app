/** Mo rong kieu Request cua Express: them req.user sau khi xac thuc JWT */
export interface AuthUser {
  userId: number;
  email: string;
  role: 'USER' | 'ADMIN';
  fullName: string;
}

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}
