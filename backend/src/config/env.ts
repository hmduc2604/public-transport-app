/**
 * Doc bien moi truong tu file .env va gom vao 1 object duy nhat.
 * Moi noi khac trong code chi import `env` tu day, khong goi process.env truc tiep.
 */
import dotenv from 'dotenv';
import path from 'path';

// .env: cau hinh chung (run-all.bat tu ghi lai moi lan chay)
// .env.local: thong tin bi mat do ban tu dien (SMTP, SMS) - KHONG bi ghi de, KHONG day len GitHub
dotenv.config();
dotenv.config({ path: path.resolve(process.cwd(), '.env.local'), override: true });

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

  /** Ma xac nhan (OTP) khi dang ky */
  otp: {
    length: 6,
    ttlMinutes: Number(process.env.OTP_TTL_MINUTES || 5),
    resendSeconds: Number(process.env.OTP_RESEND_SECONDS || 60),
    maxAttempts: Number(process.env.OTP_MAX_ATTEMPTS || 5),
    /** So lan gui toi da toi 1 email / so dien thoai trong 1 gio (chong spam) */
    maxSendsPerHour: Number(process.env.OTP_MAX_SENDS_PER_HOUR || 5),
  },

  /** Gui email qua SMTP (vd. Gmail: smtp.gmail.com:465 + App Password) */
  mail: {
    provider: (process.env.MAIL_PROVIDER || 'smtp').toLowerCase(), // smtp | console (chi de thu)
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: Number(process.env.SMTP_PORT || 465),
    secure: bool('SMTP_SECURE', true),
    user: process.env.SMTP_USER || '',
    pass: process.env.SMTP_PASS || '',
    from: process.env.MAIL_FROM || process.env.SMTP_USER || '',
  },

  /** Gui SMS: twilio | esms | speedsms | console (chi de thu) */
  sms: {
    provider: (process.env.SMS_PROVIDER || '').toLowerCase(),
    twilio: {
      accountSid: process.env.TWILIO_ACCOUNT_SID || '',
      authToken: process.env.TWILIO_AUTH_TOKEN || '',
      from: process.env.TWILIO_FROM || '',
      messagingServiceSid: process.env.TWILIO_MESSAGING_SERVICE_SID || '',
    },
    esms: {
      apiKey: process.env.ESMS_API_KEY || '',
      secretKey: process.env.ESMS_SECRET_KEY || '',
      brandname: process.env.ESMS_BRANDNAME || '',
      sandbox: bool('ESMS_SANDBOX', false),
    },
    speedsms: {
      token: process.env.SPEEDSMS_TOKEN || '',
      sender: process.env.SPEEDSMS_SENDER || '',
      smsType: Number(process.env.SPEEDSMS_TYPE || 2),
    },
  },
};
