/**
 * Doc bien moi truong tu file .env va gom vao 1 object duy nhat.
 * Moi noi khac trong code chi import `env` tu day, khong goi process.env truc tiep.
 */
import dotenv from 'dotenv';

dotenv.config();

function required(name: string, fallback?: string): string {
  const value = process.env[name] ?? fallback;
  if (value === undefined || value === '') {
    throw new Error(`Missing environment variable: ${name}`);
  }
  return value;
}

function bool(name: string, fallback: boolean): boolean {
  const value = process.env[name];
  if (value === undefined || value === '') return fallback;
  return ['true', '1', 'yes'].includes(value.toLowerCase());
}

export const env = {
  port: Number(process.env.PORT || 5000),
  nodeEnv: process.env.NODE_ENV || 'development',
  corsOrigin: (process.env.CORS_ORIGIN || 'http://localhost:5173')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean),

  db: {
    server: required('DB_SERVER', 'localhost'),
    port: process.env.DB_PORT ? Number(process.env.DB_PORT) : undefined,
    instanceName: process.env.DB_INSTANCE || undefined,
    database: required('DB_DATABASE', 'PublicTransportDBV2'),
    user: required('DB_USER', 'sa'),
    password: process.env.DB_PASSWORD || '',
    encrypt: bool('DB_ENCRYPT', false),
    trustServerCertificate: bool('DB_TRUST_SERVER_CERTIFICATE', true),
  },

  jwt: {
    secret: required('JWT_SECRET', 'dev_jwt_secret_change_me'),
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },

  qrSecret: required('QR_SECRET', 'dev_qr_secret_change_me'),
};
