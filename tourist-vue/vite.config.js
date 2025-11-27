import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'
import { viteMockServe } from 'vite-plugin-mock'

export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
    viteMockServe({
      mockPath: 'src/mock',       // mock 文件夹路径，自己建在 src/mock 或项目根目录
      localEnabled: true,     // 开发环境启用
      prodEnabled: false,     // 生产环境禁用
      supportTs: true,        // 支持 ts 文件
      watchFiles: true,       // 文件修改时热更新
    })
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
})
