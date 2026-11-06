import { api } from './api';
import { Order, Ticket, TicketType, TripHistory } from '../types';

export const ticketApi = {
  ticketTypes: (q?: { type?: string; transportTypeId?: number }) => api.get<TicketType[]>('/ticket-types', q),
  myTickets: (status?: string) => api.get<Ticket[]>('/tickets/me', { status }),
  ticket: (id: number) => api.get<Ticket>(`/tickets/${id}`),
  qr: (id: number) => api.get<{ ticketId: number; ticketCode: string; payload: string; image: string; status: string }>(`/tickets/${id}/qr`),

  createOrder: (items: { ticketTypeId: number; quantity: number }[]) => api.post<Order>('/orders', { items }),
  myOrders: () => api.get<Order[]>('/orders/me'),
  order: (id: number) => api.get<Order>(`/orders/${id}`),
  cancelOrder: (id: number) => api.post<Order>(`/orders/${id}/cancel`),

  tripHistories: () => api.get<TripHistory[]>('/trip-histories'),
  saveTrip: (data: { origin: string; destination: string; routeData: unknown }) =>
    api.post<{ tripHistoryId: number }>('/trip-histories', data),
  deleteTrip: (id: number) => api.delete<null>(`/trip-histories/${id}`),
};
