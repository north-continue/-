import { request } from '@/utils/request'
import type { ResponseData } from '@/utils/request'

// ============ 类型定义 ============
export interface LoginParams {
  username: string
  password: string
}

export interface UserInfo {
  userId: number
  username: string
  realName: string
  role: string
  department: string
}

export interface Item {
  itemId: number
  itemCode: string
  qrCode: string
  itemName: string
  categoryId: number
  specification: string
  brand: string
  unit: string
  price: number
  location: string
  labRoom: string
  shelf: string
  imageUrl: string
  totalQuantity: number
  availableQuantity: number
  borrowedQuantity: number
  minStock: number
  maxStock: number
  status: string
  remark: string
  createTime: string
  updateTime: string
}

export interface PageResult<T> {
  records: T[]
  total: number
  size: number
  current: number
  pages: number
}

// ============ API 接口 ============

/**
 * 用户登录
 */
export const loginApi = (data: LoginParams) => {
  return request.post<{
    token: string
    tokenType: string
    userId: number
    username: string
    realName: string
    role: string
    department: string
  }>('/auth/login', data)
}

/**
 * 获取当前用户信息
 */
export const getCurrentUserApi = () => {
  return request.get<UserInfo>('/auth/info')
}

/**
 * 登出
 */
export const logoutApi = () => {
  return request.post('/auth/logout')
}

/**
 * 获取物品列表
 */
export const getItemsApi = (params: {
  pageNum: number
  pageSize: number
  itemName?: string
  categoryId?: number
  status?: string
}) => {
  return request.get<PageResult<Item>>('/items', params)
}

/**
 * 获取物品详情
 */
export const getItemDetailApi = (id: number) => {
  return request.get<Item>(`/items/${id}`)
}

/**
 * 创建物品
 */
export const createItemApi = (data: Partial<Item>) => {
  return request.post<Item>('/items', data)
}

/**
 * 更新物品
 */
export const updateItemApi = (data: Item) => {
  return request.put<Item>('/items', data)
}

/**
 * 删除物品
 */
export const deleteItemApi = (id: number) => {
  return request.delete(`/items/${id}`)
}

/**
 * 扫码获取物品
 */
export const getItemByQrCodeApi = (qrCode: string) => {
  return request.get<Item>(`/items/qr/${qrCode}`)
}

/**
 * 批量导入物品
 */
export const batchInsertItemsApi = (data: Partial<Item>[]) => {
  return request.post<boolean>('/items/batch', data)
}
