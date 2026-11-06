/**
 * Loi nghiep vu co HTTP status + errorCode theo API contract cua nhom:
 *   { "success": false, "message": "Route not found", "errorCode": "ROUTE_NOT_FOUND" }
 *
 * Service chi can: throw AppError.notFound('Route not found', 'ROUTE_NOT_FOUND')
 * error.middleware se tu dong tra JSON dung format.
 */
export class AppError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public errorCode: string = 'ERROR',
    public details?: unknown,
  ) {
    super(message);
    this.name = 'AppError';
  }

  static badRequest(message: string, errorCode = 'BAD_REQUEST', details?: unknown) {
    return new AppError(400, message, errorCode, details);
  }
  static unauthorized(message = 'Unauthorized', errorCode = 'UNAUTHORIZED') {
    return new AppError(401, message, errorCode);
  }
  static forbidden(message = 'Forbidden', errorCode = 'FORBIDDEN') {
    return new AppError(403, message, errorCode);
  }
  static notFound(message = 'Not found', errorCode = 'NOT_FOUND') {
    return new AppError(404, message, errorCode);
  }
  static conflict(message: string, errorCode = 'CONFLICT') {
    return new AppError(409, message, errorCode);
  }
}
