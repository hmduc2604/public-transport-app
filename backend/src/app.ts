/**
 * Khoi tao Express app (tach rieng khoi server.ts de de test).
 *
 *   React ──HTTP/JSON──> Express ──> routes ──> controllers ──> services ──> repositories ──> SQL Server
 */
import express, { Request, Response } from 'express';
import cors from 'cors';
import morgan from 'morgan';
import { env } from './config/env';
import api from './routes';
import { errorHandler, notFoundHandler } from './middleware/error.middleware';

export function createApp() {
  const app = express();

  app.disable('x-powered-by');
  app.use(
    cors({
      origin: (origin, cb) => {
        // Cho phep: khong co origin (Postman, curl) hoac origin nam trong CORS_ORIGIN
        if (!origin || env.corsOrigin.includes('*') || env.corsOrigin.includes(origin)) return cb(null, true);
        cb(new Error(`CORS: origin ${origin} không được phép`));
      },
      credentials: true,
    }),
  );
  app.use(express.json({ limit: '1mb' }));
  app.use(morgan(env.nodeEnv === 'production' ? 'combined' : 'dev'));

  app.get('/', (_req: Request, res: Response) => {
    res.json({
      success: true,
      data: { name: 'Public Transport Multi-Modal API', version: '1.0.0', docs: '/api/v1/health' },
      message: 'Success',
    });
  });

  app.use('/api/v1', api);

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
