import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// Element Plus
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'

// Pinia
import { createPinia } from 'pinia'

const app = createApp(App)

// 挂载 Pinia
const pinia = createPinia()
app.use(pinia)

// 挂载路由和 Element Plus
app.use(router)
app.use(ElementPlus)

app.mount('#app')
