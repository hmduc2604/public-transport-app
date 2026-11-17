import { api } from './api';
import { AssistantHistoryItem, AssistantReply, SuggestionResult } from '../types';

export const aiApi = {
  /** Tro ly AI lap lo trinh (Gemini goi bo tim duong / du lieu cua he thong) */
  chat: (message: string, history: AssistantHistoryItem[], location?: { latitude: number; longitude: number } | null) =>
    api.post<AssistantReply>('/assistant/chat', { message, history, location: location ?? undefined }),
  status: () => api.get<{ configured: boolean; model: string | null }>('/assistant/status'),
  /** Goi y dia diem theo so thich (dang nhap -> ket hop lich su da xem / da tim duong) */
  suggestions: (q: { q?: string; categories?: string; lat?: number; lng?: number; limit?: number }) =>
    api.get<SuggestionResult>('/attractions/suggestions', q),
};
