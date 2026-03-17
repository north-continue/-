import axios from 'axios'
import type { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'
import { mockRequest } from '@/mock'

// 是否使用 Mock 模式（后端不可用时自动启用）
let useMock = false

// 响应数据接口
export interface ResponseData<T = any> {
  code: number
  message: string
  data: T
  timestamp: number
}

// 创建 axios 实例
const service: AxiosInstance = axios.create({
  baseURL: '/api',
  timeout: 5000
})

// 请求拦截器
service.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  (response: AxiosResponse<ResponseData>) => {
    const res = response.data
    
    if (res.code !== 200) {
      ElMessage.error(res.message || '请求失败')
      
      if (res.code === 401) {
        localStorage.removeItem('token')
        router.push('/login')
      }
      
      return Promise.reject(new Error(res.message || 'Error'))
    }
    
    return res
  },
  (error) => {
    console.error('响应错误:', error)
    
    // 网络错误时自动切换到 Mock 模式
    if (error.code === 'ERR_NETWORK' || error.message?.includes('Network Error')) {
      useMock = true
      console.log('后端不可用，已切换到 Mock 模式')
    }
    
    if (error.response) {
      switch (error.response.status) {
        case 401:
          ElMessage.error('未授权，请重新登录')
          localStorage.removeItem('token')
          router.push('/login')
          break
        case 403:
          ElMessage.error('拒绝访问')
          break
        case 404:
          ElMessage.error('请求地址不存在')
          break
        case 500:
          ElMessage.error('服务器内部错误')
          break
        default:
          ElMessage.error(error.response.data?.message || '请求失败')
      }
    } else {
      ElMessage.error('网络异常，已切换到演示模式')
    }
    
    return Promise.reject(error)
  }
)

// Mock 请求处理
async function handleMockRequest(method: string, url: string, params?: any, data?: any): Promise<ResponseData> {
  const result = mockRequest({
    url,
    method,
    params,
    data
  })
  
  // 模拟网络延迟
  await new Promise(resolve => setTimeout(resolve, 100))
  
  return {
    ...result,
    timestamp: Date.now()
  }
}

// 导出请求方法
export const request = {
  async get<T = any>(url: string, params?: object): Promise<ResponseData<T>> {
    // 如果 Mock 模式已启用，直接使用 Mock 数据
    if (useMock) {
      return handleMockRequest('get', url, params)
    }
    
    try {
      return await service.get(url, { params })
    } catch (error: any) {
      // 如果网络错误，切换到 Mock 模式并重试
      if (error.code === 'ERR_NETWORK' || error.message?.includes('Network Error')) {
        useMock = true
        return handleMockRequest('get', url, params)
      }
      throw error
    }
  },

  async post<T = any>(url: string, data?: object, config?: any): Promise<ResponseData<T>> {
    if (useMock) {
      return handleMockRequest('post', url, undefined, data)
    }
    
    try {
      return await service.post(url, data, config)
    } catch (error: any) {
      if (error.code === 'ERR_NETWORK' || error.message?.includes('Network Error')) {
        useMock = true
        return handleMockRequest('post', url, undefined, data)
      }
      throw error
    }
  },

  async put<T = any>(url: string, data?: object): Promise<ResponseData<T>> {
    if (useMock) {
      return handleMockRequest('put', url, undefined, data)
    }
    
    try {
      return await service.put(url, data)
    } catch (error: any) {
      if (error.code === 'ERR_NETWORK' || error.message?.includes('Network Error')) {
        useMock = true
        return handleMockRequest('put', url, undefined, data)
      }
      throw error
    }
  },

  async delete<T = any>(url: string): Promise<ResponseData<T>> {
    if (useMock) {
      return handleMockRequest('delete', url)
    }
    
    try {
      return await service.delete(url)
    } catch (error: any) {
      if (error.code === 'ERR_NETWORK' || error.message?.includes('Network Error')) {
        useMock = true
        return handleMockRequest('delete', url)
      }
      throw error
    }
  }
}
