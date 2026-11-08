/**
 * Service: Thanh toan bang THE NGAN HANG va CHUYEN KHOAN QR (VietQR / Napas 247)
 *
 *  THE : POST /payments/card  -> cong thanh toan MO PHONG duyet / tu choi ngay -> SUCCESS thi sinh ve
 *  QR  : POST /payments/bank-transfer -> Payment PENDING + ma VietQR (so tien + noi dung CK co dinh)
 *        Khach quet QR bang app ngan hang -> bam "Toi da chuyen khoan" -> VAN PENDING
 *        Chi khi tien THUC SU ve tai khoan moi sinh ve:
 *          - admin doi soat sao ke va bam "Xac nhan da nhan tien", hoac
 *          - webhook SePay bao co giao dich tien vao dung noi dung + du so tien
 */
import crypto from 'crypto';
import { paymentRepository, TicketToIssue, TicketBuilder } from '../repositories/payment.repository';
import { orderRepository } from '../repositories/order.repository';
import { AppError } from '../utils/AppError';
import { AuthUser } from '../types/express';
import { buildQrPayload, generateTicketCode, qrToDataUrl } from '../utils/qr';
import { CardInput, mockGatewayDecision, validateCard } from '../utils/card';
import { BANKS, bankByBin, buildVietQrPayload } from '../utils/vietqr';
import { env } from '../config/env';

const buildTickets: TicketBuilder = (details) => {
  const out: TicketToIssue[] = [];
  for (const d of details) {
    for (let i = 0; i < d.quantity; i++) {
      const ticketCode = generateTicketCode();
      out.push({ ticketTypeId: d.ticketTypeId, ticketCode, qrCode: buildQrPayload(ticketCode), durationMinutes: d.durationMinutes });
    }
  }
  return out;
};

const txnCode = (prefix: string) => `${prefix}-${Date.now()}-${crypto.randomBytes(3).toString('hex').toUpperCase()}`;

/** Noi dung CK: HNG<orderId><4 chu cai> - chi chu in hoa + so (moi ngan hang deu giu nguyen) */
const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // chi chu cai -> tach ro voi ma don
function makeTransferContent(orderId: number) {
  const bytes = crypto.randomBytes(4);
  let suffix = '';
  for (const b of bytes) suffix += ALPHABET[b % ALPHABET.length];
  return `HNG${orderId}${suffix}`;
}
const CONTENT_RE = /HNG\d+[A-Z]{4}/;

function transferConfigured(s: Awaited<ReturnType<typeof paymentRepository.getSettings>>) {
  return Boolean(s.bankBin && s.accountNo && s.accountName);
}

async function ownPayment(paymentId: number, user: AuthUser) {
  await paymentRepository.expireOverdue();
  const p = await paymentRepository.getById(paymentId);
  if (!p) throw AppError.notFound('Không tìm thấy giao dịch', 'PAYMENT_NOT_FOUND');
  if (p.userId !== user.userId && user.role !== 'ADMIN') throw AppError.forbidden('Giao dịch không thuộc về bạn', 'PAYMENT_FORBIDDEN');
  return p;
}

/** Du lieu hien thi trang chuyen khoan: thong tin TK nhan + QR + trang thai */
async function transferView(p: any) {
  const settings = await paymentRepository.getSettings();
  const bank = settings.bankBin ? bankByBin(settings.bankBin) : null;
  const view: any = {
    paymentId: p.paymentId,
    orderId: p.orderId,
    paymentMethod: p.paymentMethod,
    status: p.status,
    amount: p.amount,
    transferContent: p.transferContent,
    expiresAt: p.expiresAt,
    secondsLeft: p.secondsLeft,
    customerNotifiedAt: p.customerNotifiedAt,
    paidAt: p.paidAt,
    confirmedBy: p.confirmedBy,
    note: p.note,
    cardBrand: p.cardBrand,
    cardLast4: p.cardLast4,
    bank: null as any,
    qrPayload: null as string | null,
    qrImage: null as string | null,
    ticketIds: [] as number[],
  };
  if (p.paymentMethod === 'BANK_TRANSFER' && transferConfigured(settings)) {
    view.bank = {
      bin: settings.bankBin,
      code: bank?.code ?? null,
      name: settings.bankName || bank?.name || settings.bankBin,
      accountNo: settings.accountNo,
      accountName: settings.accountName,
    };
    if (p.status === 'PENDING') {
      view.qrPayload = buildVietQrPayload({
        bin: settings.bankBin!,
        accountNo: settings.accountNo!,
        amount: p.amount,
        content: p.transferContent,
      });
      view.qrImage = await qrToDataUrl(view.qrPayload);
    }
  }
  if (p.status === 'SUCCESS') {
    const order = await orderRepository.getById(p.orderId);
    view.ticketIds = (order?.tickets ?? []).map((t: any) => t.ticketId);
  }
  return view;
}

export const paymentService = {
  /** Phuong thuc dang mo + danh sach ngan hang (cho form the noi dia / admin) */
  async methods() {
    const s = await paymentRepository.getSettings();
    return {
      card: { enabled: true, simulated: true },
      bankTransfer: {
        enabled: transferConfigured(s),
        bankName: transferConfigured(s) ? s.bankName || bankByBin(s.bankBin!)?.name : null,
        expiryMinutes: s.transferExpiryMinutes,
        autoConfirm: Boolean(env.payment.sepayApiKey),
      },
      banks: BANKS,
    };
  },

  /* ---------------- THE ---------------- */
  async payByCard(user: AuthUser, orderId: number, card: CardInput) {
    const check = validateCard(card);
    if (!check.valid) throw AppError.badRequest('Thông tin thẻ chưa hợp lệ', 'CARD_INVALID', check.errors);
    if (card.cardKind === 'DOMESTIC' && !bankByBin(String(card.bankBin))) {
      throw AppError.badRequest('Ngân hàng phát hành không hợp lệ', 'CARD_INVALID', { bankBin: 'Ngân hàng không hợp lệ' });
    }
    const decision = mockGatewayDecision(check.number);
    const result = await paymentRepository.payByCard({
      orderId,
      userId: user.userId,
      approved: decision.approved,
      failReason: decision.reason,
      cardBrand: check.brand,
      cardLast4: check.last4,
      transactionCode: txnCode('CARD'),
      buildTickets,
    });
    return {
      paymentId: result.paymentId,
      orderId,
      amount: result.amount,
      status: result.status,
      message: decision.reason ?? null,
      cardBrand: check.brand,
      cardLast4: check.last4,
      ticketIds: result.ticketIds,
      order: await orderRepository.getById(orderId),
    };
  },

  /* ---------------- CHUYEN KHOAN QR ---------------- */
  async createTransfer(user: AuthUser, orderId: number) {
    const s = await paymentRepository.getSettings();
    if (!transferConfigured(s)) {
      throw new AppError(503, 'Chuyển khoản chưa được cấu hình tài khoản nhận. Vui lòng thanh toán bằng thẻ.', 'TRANSFER_NOT_CONFIGURED');
    }
    const r = await paymentRepository.createOrReuseTransfer({
      orderId,
      userId: user.userId,
      expiryMinutes: s.transferExpiryMinutes,
      makeContent: () => makeTransferContent(orderId),
    });
    return transferView(await paymentRepository.getById(r.paymentId));
  },

  async getPayment(user: AuthUser, paymentId: number) {
    return transferView(await ownPayment(paymentId, user));
  },

  async notifyTransferred(user: AuthUser, paymentId: number) {
    const p = await ownPayment(paymentId, user);
    if (p.paymentMethod !== 'BANK_TRANSFER') throw AppError.badRequest('Không phải giao dịch chuyển khoản', 'PAYMENT_NOT_TRANSFER');
    if (p.status !== 'PENDING') {
      throw AppError.conflict(
        p.status === 'EXPIRED' ? 'Mã chuyển khoản đã hết hạn, vui lòng tạo mã mới' : 'Giao dịch không còn chờ thanh toán',
        'PAYMENT_NOT_PENDING',
      );
    }
    await paymentRepository.markCustomerNotified(paymentId);
    return transferView(await paymentRepository.getById(paymentId));
  },

  /* ---------------- ADMIN ---------------- */
  async confirmTransfer(admin: AuthUser, paymentId: number, bankReference?: string | null) {
    await paymentRepository.confirmTransfer({
      paymentId,
      confirmedBy: `ADMIN #${admin.userId}`,
      bankReference: bankReference || null,
      transactionCode: txnCode('BANK'),
      buildTickets,
    });
    return paymentRepository.getById(paymentId);
  },

  async rejectTransfer(admin: AuthUser, paymentId: number, note?: string | null) {
    const ok = await paymentRepository.rejectTransfer(paymentId, `ADMIN #${admin.userId}`, note || 'Không nhận được tiền chuyển khoản');
    if (!ok) throw AppError.conflict('Chỉ từ chối được giao dịch chuyển khoản đang chờ', 'PAYMENT_NOT_PENDING');
    return paymentRepository.getById(paymentId);
  },

  async listAll(q: { status?: string; method?: string; search?: string; offset: number; pageSize: number }) {
    await paymentRepository.expireOverdue();
    return paymentRepository.listAll(q);
  },

  getSettings: () => paymentRepository.getSettings(),
  clearSettings: () => paymentRepository.clearSettings(),

  async updateSettings(input: { bankBin: string; accountNo: string; accountName: string; transferExpiryMinutes?: number }) {
    const bank = bankByBin(input.bankBin);
    if (!bank) throw AppError.badRequest('Ngân hàng không hợp lệ', 'VALIDATION_ERROR', { bankBin: 'Chọn ngân hàng trong danh sách' });
    const accountNo = input.accountNo.replace(/\s/g, '');
    if (!/^[0-9A-Za-z]{4,30}$/.test(accountNo)) {
      throw AppError.badRequest('Số tài khoản không hợp lệ', 'VALIDATION_ERROR', { accountNo: 'Chỉ gồm chữ số (4 - 30 ký tự)' });
    }
    return paymentRepository.updateSettings({
      bankBin: bank.bin,
      bankName: bank.name,
      accountNo,
      accountName: input.accountName
        .normalize('NFD')
        .replace(/[̀-ͯ]/g, '')
        .replace(/đ/g, 'd')
        .replace(/Đ/g, 'D')
        .toUpperCase()
        .trim(),
      transferExpiryMinutes: input.transferExpiryMinutes ?? 30,
    });
  },

  /* ---------------- WEBHOOK SePay ---------------- */
  /**
   * SePay goi POST moi khi tai khoan co bien dong. Header: Authorization: Apikey <SEPAY_API_KEY>
   * Khop: tien VAO + noi dung chua HNG... + so tien >= so tien don. Phai tra 200 {success:true}.
   */
  async sepayWebhook(authHeader: string | undefined, body: any) {
    const key = env.payment.sepayApiKey;
    if (!key) throw AppError.forbidden('Webhook SePay chưa được bật (thiếu SEPAY_API_KEY)', 'WEBHOOK_DISABLED');
    const expected = Buffer.from(`Apikey ${key}`);
    const got = Buffer.from(String(authHeader ?? ''));
    if (expected.length !== got.length || !crypto.timingSafeEqual(expected, got)) {
      throw AppError.unauthorized('Sai API key webhook', 'WEBHOOK_UNAUTHORIZED');
    }
    if (body?.transferType !== 'in') return { matched: false, reason: 'Không phải giao dịch tiền vào' };

    const ref = body?.id !== undefined ? `SEPAY-${body.id}` : null;
    if (ref && (await paymentRepository.findByBankReference(ref))) return { matched: true, duplicate: true };

    const text = `${body?.code ?? ''} ${body?.content ?? ''} ${body?.description ?? ''}`.toUpperCase().replace(/[^A-Z0-9 ]/g, '');
    const m = CONTENT_RE.exec(text);
    if (!m) return { matched: false, reason: 'Không tìm thấy mã đơn trong nội dung' };
    const p = await paymentRepository.findByTransferContent(m[0]);
    if (!p) return { matched: false, reason: 'Không có giao dịch khớp nội dung' };
    if (p.status === 'SUCCESS') return { matched: true, duplicate: true };
    if (Number(body?.transferAmount) < p.amount) return { matched: false, reason: 'Số tiền chuyển thiếu' };

    try {
      await paymentRepository.confirmTransfer({
        paymentId: p.paymentId,
        confirmedBy: 'SEPAY',
        bankReference: ref ?? body?.referenceCode ?? null,
        transactionCode: String(body?.referenceCode || txnCode('BANK')),
        buildTickets,
      });
    } catch (err) {
      // Don da huy / da tra bang the: van tra success de SePay khong gui lai; admin xu ly hoan tien
      if (err instanceof AppError && err.statusCode === 409) return { matched: true, applied: false, reason: err.message };
      throw err;
    }
    return { matched: true, applied: true, paymentId: p.paymentId };
  },
};
