import { api } from './api';
import { CardPaymentInput, CardPaymentResult, PaymentMethods, PaymentView } from '../types';

export const paymentApi = {
  /** Phuong thuc dang mo + danh sach ngan hang */
  methods: () => api.get<PaymentMethods>('/payments/methods'),
  /** Thanh toan the (cong thanh toan mo phong): SUCCESS -> ve phat hanh ngay; FAILED -> thu lai */
  payByCard: (input: CardPaymentInput) => api.post<CardPaymentResult>('/payments/card', input),
  /** Tao (hoac lay lai) ma QR chuyen khoan cho don - trang thai PENDING */
  createTransfer: (orderId: number) => api.post<PaymentView>('/payments/bank-transfer', { orderId }),
  get: (paymentId: number) => api.get<PaymentView>(`/payments/${paymentId}`),
  /** Khach bao "Toi da chuyen khoan" - VAN cho xac nhan tien ve */
  notifyTransferred: (paymentId: number) => api.post<PaymentView>(`/payments/${paymentId}/transferred`),
};
