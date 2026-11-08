import { api } from './api';
import { AdminPayment, Order, Paginated, PaymentSettings, Statistics, Ticket, User } from '../types';

type Q = Record<string, string | number | undefined>;

/** Tao nhanh bo ham CRUD cho 1 resource admin */
export function crudApi<T = any>(resource: string) {
  return {
    list: (q?: Q) => api.get<T[]>(`/admin/${resource}`, q),
    get: (id: number) => api.get<T>(`/admin/${resource}/${id}`),
    create: (data: Partial<T>) => api.post<T>(`/admin/${resource}`, data),
    update: (id: number, data: Partial<T>) => api.put<T>(`/admin/${resource}/${id}`, data),
    remove: (id: number) => api.delete<null>(`/admin/${resource}/${id}`),
  };
}

export const adminApi = {
  statistics: (days = 30) => api.get<Statistics>('/admin/statistics', { days }),
  rebuildGraph: () => api.post<{ nodes: number; edges: number; lines: number; stations: number }>('/admin/routing/rebuild'),

  users: (q: Q) => api.get<Paginated<User & { paidOrders: number }>>('/admin/users', q),
  updateUser: (id: number, data: Partial<{ fullName: string; phone: string; role: string; status: string }>) =>
    api.put<User>(`/admin/users/${id}`, data),

  orders: (q: Q) => api.get<Paginated<Order>>('/admin/orders', q),
  order: (id: number) => api.get<Order>(`/admin/orders/${id}`),
  cancelOrder: (id: number) => api.post<Order>(`/admin/orders/${id}/cancel`),

  tickets: (q: Q) => api.get<Paginated<Ticket>>('/admin/tickets', q),
  updateTicketStatus: (id: number, status: string) => api.patch<Ticket>(`/admin/tickets/${id}/status`, { status }),
  verifyTicket: (qrData: string, markUsed = true) =>
    api.post<{ valid: boolean; reason: string; ticket: Ticket | null }>('/admin/tickets/verify', { qrData, markUsed }),

  payments: (q: Q) => api.get<Paginated<AdminPayment>>('/admin/payments', q),
  confirmPayment: (id: number, bankReference?: string) => api.post<AdminPayment>(`/admin/payments/${id}/confirm`, { bankReference }),
  rejectPayment: (id: number, note?: string) => api.post<AdminPayment>(`/admin/payments/${id}/reject`, { note }),
  paymentSettings: () => api.get<PaymentSettings>('/admin/payment-settings'),
  updatePaymentSettings: (data: { bankBin: string; accountNo: string; accountName: string; transferExpiryMinutes: number }) =>
    api.put<PaymentSettings>('/admin/payment-settings', data),
  clearPaymentSettings: () => api.delete<PaymentSettings>('/admin/payment-settings'),

  routeStations: (id: number) => api.get<any[]>(`/admin/routes/${id}/stations`),
  replaceRouteStations: (id: number, stations: { stationId: number; distanceFromStart?: number | null }[]) =>
    api.put<any[]>(`/admin/routes/${id}/stations`, { stations }),

  transportTypes: crudApi('transport-types'),
  vehicles: crudApi('vehicles'),
  stations: crudApi('stations'),
  routes: crudApi('routes'),
  trips: crudApi('trips'),
  ticketTypes: crudApi('ticket-types'),
  fareRules: crudApi('fare-rules'),
  attractions: crudApi('attractions'),
};
