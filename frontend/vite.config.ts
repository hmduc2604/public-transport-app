import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    // Goi /api/... se duoc chuyen tiep sang backend -> khong lo loi CORS khi dev
    proxy: {
      '/api': 'http://localhost:5000',
    },
  },
});
