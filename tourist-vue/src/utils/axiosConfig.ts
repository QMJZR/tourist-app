import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../store/user'

// 创建axios实例
const service = axios.create({
  baseURL: '/api', // 基础URL
  timeout: 10000 // 请求超时时间
})

// 请求拦截器
service.interceptors.request.use(
  config => {
    // 获取用户token
    const userStore = useUserStore()
    if (userStore.token) {
      // 将token添加到请求头
      config.headers.Authorization = `Bearer ${userStore.token}`
    }
    return config
  },
  error => {
    // 请求错误处理
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  response => {
    // 只返回响应的数据部分
    return response
  },
  error => {
    // 处理响应错误
    let message = '请求失败'
    if (error.response) {
      // 服务器返回了错误状态码
      const { status, data } = error.response
      switch (status) {
        case 401:
          message = '未授权，请重新登录'
          // 清除用户信息并跳转到登录页
          const userStore = useUserStore()
          userStore.logout()
          window.location.href = '/login'
          break
        case 403:
          message = '拒绝访问'
          break
        case 404:
          message = '请求的资源不存在'
          break
        case 500:
          message = '服务器内部错误'
          break
        default:
          message = data.message || `请求错误 (${status})`
      }
    } else if (error.request) {
      // 请求已发送但没有收到响应
      message = '网络错误，服务器无响应'
    } else {
      // 请求配置错误
      message = error.message
    }
    
    // 显示错误信息
    ElMessage.error(message)
    return Promise.reject(error)
  }
)

export default service