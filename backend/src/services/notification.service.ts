/**
 * Service: Gui thong bao that qua Email / SMS (dung cho ma xac nhan dang ky).
 *
 * Email : SMTP qua thu vien nodemailer (Gmail, Outlook, Zoho, SendGrid SMTP...)
 * SMS   : Twilio (quoc te) | eSMS.vn | SpeedSMS.vn  - goi REST API bang fetch, khong can thu vien
 *
 * Cau hinh trong backend/.env.local (xem backend/.env.local.example).
 * Chua cau hinh -> bao loi 503 NOTIFY_NOT_CONFIGURED de nguoi dung biet, KHONG gia vo gui.
 */
import nodemailer, { Transporter } from 'nodemailer';
import { env } from '../config/env';
import { AppError } from '../utils/AppError';
import { toE164 } from '../utils/phone';

const notConfigured = (what: string) =>
  new AppError(503, `Hệ thống chưa cấu hình gửi ${what}. Vui lòng chọn cách nhận mã khác hoặc liên hệ quản trị viên.`, 'NOTIFY_NOT_CONFIGURED');

const sendFailed = (what: string, detail: string) => {
  console.error(`[Notify] Gui ${what} that bai: ${detail}`);
  return new AppError(502, `Không gửi được ${what}, vui lòng thử lại sau hoặc chọn cách nhận mã khác.`, 'SEND_FAILED');
};

/* ------------------------------- EMAIL ------------------------------- */
let transporter: Transporter | null = null;

function mailer(): Transporter {
  const m = env.mail;
  if (!m.user || !m.pass) throw notConfigured('email');
  if (!transporter) {
    transporter = nodemailer.createTransport({
      host: m.host,
      port: m.port,
      secure: m.secure,
      auth: { user: m.user, pass: m.pass },
    });
  }
  return transporter;
}

export function emailConfigured() {
  return env.mail.provider === 'console' || Boolean(env.mail.user && env.mail.pass);
}

async function sendEmail(to: string, subject: string, html: string, text: string) {
  if (env.mail.provider === 'console') {
    console.log(`[Notify][EMAIL->${to}] ${subject}\n${text}`);
    return;
  }
  try {
    await mailer().sendMail({ from: `"HanoiGo" <${env.mail.from}>`, to, subject, html, text });
  } catch (err) {
    if (err instanceof AppError) throw err;
    throw sendFailed('email', (err as Error).message);
  }
}

/* -------------------------------- SMS -------------------------------- */
export function smsConfigured() {
  const s = env.sms;
  switch (s.provider) {
    case 'console':
      return true;
    case 'twilio':
      return Boolean(s.twilio.accountSid && s.twilio.authToken && (s.twilio.from || s.twilio.messagingServiceSid));
    case 'esms':
      return Boolean(s.esms.apiKey && s.esms.secretKey && s.esms.brandname);
    case 'speedsms':
      return Boolean(s.speedsms.token);
    default:
      return false;
  }
}

async function postJson(url: string, body: unknown, headers: Record<string, string> = {}) {
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...headers },
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(15000),
  });
  const text = await res.text();
  let json: any = null;
  try {
    json = JSON.parse(text);
  } catch {
    /* khong phai JSON */
  }
  return { ok: res.ok, status: res.status, json, text };
}

/** phone: dang 0xxxxxxxxx (da chuan hoa) */
async function sendSms(phone: string, message: string) {
  const s = env.sms;
  if (!smsConfigured()) throw notConfigured('SMS');

  if (s.provider === 'console') {
    console.log(`[Notify][SMS->${phone}] ${message}`);
    return;
  }

  try {
    if (s.provider === 'twilio') {
      // https://www.twilio.com/docs/messaging/api/message-resource#create-a-message-resource
      const form = new URLSearchParams({ To: toE164(phone), Body: message });
      if (s.twilio.messagingServiceSid) form.set('MessagingServiceSid', s.twilio.messagingServiceSid);
      else form.set('From', s.twilio.from);
      const auth = Buffer.from(`${s.twilio.accountSid}:${s.twilio.authToken}`).toString('base64');
      const res = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${s.twilio.accountSid}/Messages.json`, {
        method: 'POST',
        headers: { Authorization: `Basic ${auth}`, 'Content-Type': 'application/x-www-form-urlencoded' },
        body: form.toString(),
        signal: AbortSignal.timeout(15000),
      });
      const json: any = await res.json().catch(() => null);
      if (!res.ok) throw new Error(`Twilio HTTP ${res.status}: ${json?.code ?? ''} ${json?.message ?? ''}`);
      return;
    }

    if (s.provider === 'esms') {
      // https://developers.esms.vn/en/esms-api/send-sms-api/send-otp-customer-care-message
      const r = await postJson('https://rest.esms.vn/MainService.svc/json/SendMultipleMessage_V4_post_json/', {
        ApiKey: s.esms.apiKey,
        SecretKey: s.esms.secretKey,
        Phone: phone,
        Content: message,
        Brandname: s.esms.brandname,
        SmsType: '2',
        IsUnicode: '0',
        Sandbox: s.esms.sandbox ? '1' : '0',
      });
      if (String(r.json?.CodeResult) !== '100') {
        throw new Error(`eSMS CodeResult ${r.json?.CodeResult ?? r.status}: ${r.json?.ErrorMessage ?? r.text.slice(0, 200)}`);
      }
      return;
    }

    if (s.provider === 'speedsms') {
      // https://speedsms.vn - POST /index.php/sms/send, Basic auth "token:x"
      const auth = Buffer.from(`${s.speedsms.token}:x`).toString('base64');
      const r = await postJson(
        'https://api.speedsms.vn/index.php/sms/send',
        { to: [phone], content: message, sms_type: s.speedsms.smsType, sender: s.speedsms.sender },
        { Authorization: `Basic ${auth}` },
      );
      if (r.json?.status !== 'success') {
        throw new Error(`SpeedSMS ${r.json?.code ?? r.status}: ${r.json?.message ?? r.text.slice(0, 200)}`);
      }
      return;
    }
  } catch (err) {
    throw sendFailed('SMS', (err as Error).message);
  }
}

/* ----------------------------- MA XAC NHAN ----------------------------- */
export const notificationService = {
  emailConfigured,
  smsConfigured,

  async sendVerificationEmail(to: string, fullName: string, code: string, ttlMinutes: number) {
    const subject = `Mã xác nhận đăng ký HanoiGo: ${code}`;
    const text =
      `Xin chào ${fullName},\n\nMã xác nhận đăng ký tài khoản HanoiGo của bạn là: ${code}\n` +
      `Mã có hiệu lực trong ${ttlMinutes} phút. Không chia sẻ mã này cho bất kỳ ai.\n\n` +
      `Nếu bạn không yêu cầu đăng ký, hãy bỏ qua email này.`;
    const html = `
<div style="font-family:Arial,Helvetica,sans-serif;max-width:480px;margin:auto;padding:24px;border:1px solid #e6e1d6;border-radius:12px">
  <h2 style="color:#13294b;margin:0 0 12px">HanoiGo</h2>
  <p>Xin chào <b>${escapeHtml(fullName)}</b>,</p>
  <p>Mã xác nhận đăng ký tài khoản của bạn là:</p>
  <p style="font-size:32px;letter-spacing:8px;font-weight:bold;color:#13294b;background:#faf8f3;padding:12px 16px;border-radius:8px;text-align:center">${code}</p>
  <p>Mã có hiệu lực trong <b>${ttlMinutes} phút</b>. Không chia sẻ mã này cho bất kỳ ai.</p>
  <p style="color:#6b7280;font-size:13px">Nếu bạn không yêu cầu đăng ký, hãy bỏ qua email này.</p>
</div>`;
    await sendEmail(to, subject, html, text);
  },

  async sendVerificationSms(phone: string, code: string, ttlMinutes: number) {
    // Khong dau de tranh tinh phi tin Unicode va loi template nha mang
    await sendSms(phone, `Ma xac nhan dang ky HanoiGo cua ban la ${code}. Ma co hieu luc ${ttlMinutes} phut. Khong chia se ma nay cho bat ky ai.`);
  },
};

function escapeHtml(s: string) {
  return s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]!);
}
