/** Service: Lich su chuyen di */
import { tripHistoryRepository } from '../repositories/tripHistory.repository';
import { AppError } from '../utils/AppError';

export const tripHistoryService = {
  list: (userId: number) => tripHistoryRepository.listByUser(userId),

  async create(
    userId: number,
    data: { origin: string; destination: string; routeData?: unknown; startedAt?: string; completedAt?: string },
  ) {
    const id = await tripHistoryRepository.create({
      userId,
      origin: data.origin,
      destination: data.destination,
      routeData: data.routeData ?? null,
      startedAt: data.startedAt ? new Date(data.startedAt) : new Date(),
      completedAt: data.completedAt ? new Date(data.completedAt) : null,
    });
    return { tripHistoryId: id };
  },

  async complete(id: number, userId: number) {
    if (!(await tripHistoryRepository.complete(id, userId))) {
      throw AppError.notFound('Không tìm thấy chuyến đi', 'TRIP_HISTORY_NOT_FOUND');
    }
  },

  async remove(id: number, userId: number) {
    if (!(await tripHistoryRepository.delete(id, userId))) {
      throw AppError.notFound('Không tìm thấy chuyến đi', 'TRIP_HISTORY_NOT_FOUND');
    }
  },
};
