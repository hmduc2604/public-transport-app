import { api } from './api';
import { PaymentResult } from '../types';

export const paymentApi = {
  /** Thanh toan mo phong. simulate = 'FAILED' de demo truong hop that bai */
  pay: (orderId: number, simulate: 'SUCCESS' | 'FAILED' = 'SUCCESS') =>
    api.post<PaymentResult>('/payments', { orderId, method: 'MOCK', simulate }),
};
