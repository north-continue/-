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

// ============ 扫码出入库接口 ============

export interface ScanInboundParams {
  itemCode: string
  quantity: number
  inType?: string
  supplier?: string
  invoiceNo?: string
  operatorId: number
  remark?: string
}

export interface ScanOutboundParams {
  itemCode: string
  quantity: number
  outType?: string
  receiverId?: number
  operatorId: number
  remark?: string
}

export interface InRecord {
  recordId: number
  inNo: string
  itemId: number
  quantity: number
  inType: string
  supplier: string
  invoiceNo: string
  operatorId: number
  remark: string
  createTime: string
}

export interface OutRecord {
  recordId: number
  outNo: string
  itemId: number
  quantity: number
  outType: string
  receiverId: number
  operatorId: number
  remark: string
  createTime: string
}

/**
 * 扫码获取物品信息
 */
export const scanGetItemApi = (code: string) => {
  return request.get<Item>(`/scan/item/${code}`)
}

/**
 * 扫码入库
 */
export const scanInboundApi = (data: ScanInboundParams) => {
  return request.post<InRecord>('/scan/inbound', data)
}

/**
 * 扫码出库
 */
export const scanOutboundApi = (data: ScanOutboundParams) => {
  return request.post<OutRecord>('/scan/outbound', data)
}

/**
 * 快速扫码入库
 */
export const quickScanInboundApi = (params: {
  itemCode: string
  quantity: number
  operatorId: number
  supplier?: string
  remark?: string
}) => {
  return request.post<InRecord>('/scan/quick-inbound', null, { params })
}

/**
 * 快速扫码出库
 */
export const quickScanOutboundApi = (params: {
  itemCode: string
  quantity: number
  operatorId: number
  receiverId?: number
  remark?: string
}) => {
  return request.post<OutRecord>('/scan/quick-outbound', null, { params })
}
