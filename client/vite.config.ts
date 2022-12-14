import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    open: true,
    port: 3333,
    host: '0.0.0.0',
  },
  build: {
    outDir: 'build'
  },
  preview: {
    open: true,
    port: 3333,
  },
});
