import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: '0.0.0.0',  // 允许局域网访问
    port: 5173,       // 指定端口号
    open: true,       // 自动打开浏览器
  }
}) 