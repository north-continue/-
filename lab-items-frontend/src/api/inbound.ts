import { request } from '@/utils/request'

// 入库单相关接口
export interface InboundOrder {
  orderId?: number
  orderNo?: string
  orderType: string
  supplierId?: number
  supplierName?: string
  warehouseId?: number
  warehouseName?: string
  totalAmount?: number
  totalQuantity?: number
  status?: string
  operatorId?: number
  operatorName?: string
  approverId?: number
  approverName?: string
  approveTime?: string
  arrivalDate?: string
  actualArrivalDate?: string
  invoiceNo?: string
  contractNo?: string
  remark?: string
  createTime?: string
  updateTime?: string
}

export interface InboundOrderDetail {
  detailId?: number
  orderId?: number
  itemId: number
  itemCode?: string
  itemName: string
  specification?: string
  unit?: string
  quantity: number
  unitPrice?: number
  totalPrice?: number
  batchNo?: string
  productionDate?: string
  expiryDate?: string
  qualityStatus?: string
  location?: string
  remark?: string
}

export interface Supplier {
  supplierId?: number
  supplierCode: string
  supplierName: string
  contactPerson?: string
  contactPhone?: string
  contactEmail?: string
  address?: string
  status?: number
  remark?: string
}

export interface Warehouse {
  warehouseId?: number
  warehouseCode: string
  warehouseName: string
  warehouseType?: string
  location?: string
  managerId?: number
  managerName?: string
  capacity?: number
  currentStock?: number
  status?: number
  remark?: string
}

/**
 * 分页查询入库单
 */
export function getPageList(
  pageNum: number,
  pageSize: number,
  orderNo: string | null,
  status: string | null,
  supplierId: number | null,
  orderType: string | null
) {
  return request({
    url: '/inbound-orders',
    method: 'get',
    params: { pageNum, pageSize, orderNo, status, supplierId, orderType },
  })
}

/**
 * 获取入库单详情
 */
export function getById(id: number) {
  return request({
    url: `/inbound-orders/${id}`,
    method: 'get',
  })
}

/**
 * 创建入库单
 */
export function create(data: { order: InboundOrder; details: InboundOrderDetail[] }) {
  return request({
    url: '/inbound-orders',
    method: 'post',
    data,
  })
}

/**
 * 更新入库单
 */
export function update(id: number, data: { order: InboundOrder; details: InboundOrderDetail[] }) {
  return request({
    url: `/inbound-orders/${id}`,
    method: 'put',
    data,
  })
}

/**
 * 删除入库单
 */
export function deleteOrder(id: number) {
  return request({
    url: `/inbound-orders/${id}`,
    method: 'delete',
  })
}

/**
 * 审核入库单
 */
export function approve(id: number, approverId: number, approverName: string, approved: boolean) {
  return request({
    url: `/inbound-orders/${id}/approve`,
    method: 'post',
    params: { approverId, approverName, approved },
  })
}

/**
 * 完成入库单
 */
export function complete(id: number) {
  return request({
    url: `/inbound-orders/${id}/complete`,
    method: 'post',
  })
}

/**
 * 取消入库单
 */
export function cancel(id: number) {
  return request({
    url: `/inbound-orders/${id}/cancel`,
    method: 'post',
  })
}

/**
 * 提交入库单审核
 */
export function submitForApproval(id: number) {
  return request({
    url: `/inbound-orders/${id}/submit`,
    method: 'post',
  })
}

/**
 * 查询所有供应商
 */
export function listSuppliers() {
  return request({
    url: '/suppliers',
    method: 'get',
  })
}

/**
 * 查询所有仓库
 */
export function listWarehouses() {
  return request({
    url: '/warehouses',
    method: 'get',
  })
}
