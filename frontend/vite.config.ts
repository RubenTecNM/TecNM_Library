import vue from '@vitejs/plugin-vue'
import { defineConfig } from 'vite'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: 'localhost',
    port: 6050,
    strictPort: true,
    proxy: {
      '/api': { target: 'http://localhost:6060', changeOrigin: true },
    },
  },
})
