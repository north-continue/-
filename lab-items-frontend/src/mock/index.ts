// Mock 数据服务 - 模拟后端 API

// 模拟物品数据
const mockItems = [
  {
    itemId: 1,
    itemCode: 'ITEM001',
    qrCode: 'QR001',
    itemName: '显微镜',
    categoryId: 1,
    specification: 'BX53',
    brand: 'Olympus',
    unit: '台',
    price: 1500.00,
    location: '实验楼1楼',
    labRoom: 'A101',
    shelf: 'H-01',
    imageUrl: null,
    totalQuantity: 10,
    availableQuantity: 8,
    borrowedQuantity: 2,
    minStock: 2,
    maxStock: 20,
    status: 'AVAILABLE',
    remark: '高倍显微镜',
    createTime: '2024-01-15 10:00:00',
    updateTime: '2024-01-15 10:00:00'
  },
  {
    itemId: 2,
    itemCode: 'ITEM002',
    qrCode: 'QR002',
    itemName: '离心机',
    categoryId: 1,
    specification: 'TGL-16G',
    brand: 'Sigma',
    unit: '台',
    price: 5000.00,
    location: '实验楼2楼',
    labRoom: 'B202',
    shelf: 'H-02',
    imageUrl: null,
    totalQuantity: 5,
    availableQuantity: 3,
    borrowedQuantity: 2,
    minStock: 1,
    maxStock: 10,
    status: 'AVAILABLE',
    remark: '高速离心机',
    createTime: '2024-01-15 11:00:00',
    updateTime: '2024-01-15 11:00:00'
  },
  {
    itemId: 3,
    itemCode: 'ITEM003',
    qrCode: 'QR003',
    itemName: '移液枪',
    categoryId: 3,
    specification: 'P1000',
    brand: 'Gilson',
    unit: '支',
    price: 200.00,
    location: '实验楼1楼',
    labRoom: 'A102',
    shelf: 'H-03',
    imageUrl: null,
    totalQuantity: 20,
    availableQuantity: 15,
    borrowedQuantity: 5,
    minStock: 5,
    maxStock: 50,
    status: 'AVAILABLE',
    remark: '可调量程移液枪',
    createTime: '2024-01-15 12:00:00',
    updateTime: '2024-01-15 12:00:00'
  },
  {
    itemId: 4,
    itemCode: 'ITEM004',
    qrCode: 'QR004',
    itemName: '试管架',
    categoryId: 3,
    specification: '50孔',
    brand: '通用',
    unit: '个',
    price: 50.00,
    location: '实验楼2楼',
    labRoom: 'B203',
    shelf: 'H-04',
    imageUrl: null,
    totalQuantity: 30,
    availableQuantity: 25,
    borrowedQuantity: 5,
    minStock: 10,
    maxStock: 100,
    status: 'AVAILABLE',
    remark: '标准试管架',
    createTime: '2024-01-15 13:00:00',
    updateTime: '2024-01-15 13:00:00'
  }
]

// 模拟入库单数据
let mockInboundOrders = [
  {
    orderId: 1,
    orderNo: 'RK20240115001',
    orderType: 'PURCHASE',
    supplierId: 1,
    supplierName: '科学仪器有限公司',
    warehouseId: 1,
    warehouseName: '主仓库',
    totalQuantity: 15,
    totalAmount: 25000.00,
    status: 'COMPLETED',
    operatorId: 1,
    operatorName: '管理员',
    arrivalDate: '2024-01-15',
    actualArrivalDate: '2024-01-15',
    invoiceNo: 'INV001',
    contractNo: 'CT001',
    remark: '首批采购',
    createTime: '2024-01-15 09:00:00',
    updateTime: '2024-01-15 10:00:00'
  },
  {
    orderId: 2,
    orderNo: 'RK20240120002',
    orderType: 'PURCHASE',
    supplierId: 2,
    supplierName: '实验室设备供应商',
    warehouseId: 1,
    warehouseName: '主仓库',
    totalQuantity: 30,
    totalAmount: 5000.00,
    status: 'APPROVED',
    operatorId: 1,
    operatorName: '管理员',
    arrivalDate: '2024-01-20',
    actualArrivalDate: null,
    invoiceNo: 'INV002',
    contractNo: 'CT002',
    remark: '耗材补充',
    createTime: '2024-01-20 09:00:00',
    updateTime: '2024-01-20 11:00:00'
  },
  {
    orderId: 3,
    orderNo: 'RK20240125003',
    orderType: 'RETURN',
    supplierId: null,
    supplierName: null,
    warehouseId: 1,
    warehouseName: '主仓库',
    totalQuantity: 2,
    totalAmount: 0,
    status: 'PENDING',
    operatorId: 2,
    operatorName: '实验室管理员',
    arrivalDate: '2024-01-25',
    actualArrivalDate: null,
    invoiceNo: null,
    contractNo: null,
    remark: '借用归还',
    createTime: '2024-01-25 14:00:00',
    updateTime: '2024-01-25 14:00:00'
  }
]

// 模拟入库单明细
const mockInboundOrderDetails: any = {
  1: [
    { detailId: 1, orderId: 1, itemId: 1, itemName: '显微镜', specification: 'BX53', unit: '台', quantity: 5, unitPrice: 3000, totalPrice: 15000, batchNo: 'B001' },
    { detailId: 2, orderId: 1, itemId: 2, itemName: '离心机', specification: 'TGL-16G', unit: '台', quantity: 2, unitPrice: 5000, totalPrice: 10000, batchNo: 'B002' }
  ],
  2: [
    { detailId: 3, orderId: 2, itemId: 3, itemName: '移液枪', specification: 'P1000', unit: '支', quantity: 20, unitPrice: 200, totalPrice: 4000, batchNo: 'B003' },
    { detailId: 4, orderId: 2, itemId: 4, itemName: '试管架', specification: '50孔', unit: '个', quantity: 10, unitPrice: 100, totalPrice: 1000, batchNo: 'B004' }
  ],
  3: [
    { detailId: 5, orderId: 3, itemId: 1, itemName: '显微镜', specification: 'BX53', unit: '台', quantity: 2, unitPrice: 0, totalPrice: 0, batchNo: '' }
  ]
}

// 模拟入库记录
let mockInRecords = [
  {
    recordId: 1,
    inNo: 'IN20240115001',
    itemCode: 'ITEM001',
    itemId: 1,
    itemName: '显微镜',
    quantity: 5,
    inType: 'PURCHASE',
    supplier: '科学仪器有限公司',
    invoiceNo: 'INV001',
    operatorId: 1,
    remark: '首次入库',
    createTime: '2024-01-15 09:00:00'
  }
]

// 模拟出库记录
let mockOutRecords = [
  {
    recordId: 1,
    outNo: 'OUT20240115001',
    itemCode: 'ITEM001',
    itemId: 1,
    itemName: '显微镜',
    quantity: 2,
    outType: 'BORROW',
    receiverId: 2,
    receiverName: '实验室管理员',
    operatorId: 1,
    remark: '实验室借用',
    createTime: '2024-01-15 14:00:00'
  }
]

// 模拟用户数据
const mockUsers = [
  { userId: 1, username: 'admin', realName: '管理员', role: 'ADMIN', department: '信息中心' },
  { userId: 2, username: 'labadmin', realName: '实验室管理员', role: 'LAB_ADMIN', department: '实验室' },
  { userId: 3, username: 'teacher1', realName: '王老师', role: 'TEACHER', department: '化学系' },
  { userId: 4, username: 'student1', realName: '李同学', role: 'STUDENT', department: '化学系' }
]

// 模拟分类数据
const mockCategories = [
  { categoryId: 1, categoryName: '仪器设备', parentId: 0, level: 1 },
  { categoryId: 2, categoryName: '办公用品', parentId: 0, level: 1 },
  { categoryId: 3, categoryName: '耗材', parentId: 0, level: 1 }
]

// 模拟供应商数据
const mockSuppliers = [
  { supplierId: 1, supplierCode: 'SUP001', supplierName: '科学仪器有限公司', contactPerson: '张经理', contactPhone: '010-12345678', status: 1 },
  { supplierId: 2, supplierCode: 'SUP002', supplierName: '实验室设备供应商', contactPerson: '李经理', contactPhone: '010-87654321', status: 1 },
  { supplierId: 3, supplierCode: 'SUP003', supplierName: '耗材批发商', contactPerson: '王经理', contactPhone: '010-55556666', status: 1 }
]

// 模拟仓库数据
const mockWarehouses = [
  { warehouseId: 1, warehouseCode: 'WH001', warehouseName: '主仓库', warehouseType: 'MAIN', location: '实验楼1楼', managerId: 1, managerName: '管理员', capacity: 1000, currentStock: 500, status: 1 },
  { warehouseId: 2, warehouseCode: 'WH002', warehouseName: '化学品仓库', warehouseType: 'CHEMICAL', location: '实验楼B区', managerId: 2, managerName: '实验室管理员', capacity: 500, currentStock: 200, status: 1 }
]

// 入库单ID计数器
let inboundOrderIdCounter = 4
let inboundRecordIdCounter = mockInRecords.length + 1
let outRecordIdCounter = mockOutRecords.length + 1

// Mock API 处理函数
export function mockRequest(config: any): any {
  const { url, method, params, data } = config

  console.log('[Mock] 请求:', method, url, params, data)

  // ========== 登录接口 ==========
  if (url === '/auth/login' && method === 'post') {
    const { username, password } = data
    if (password === '123456') {
      const user = mockUsers.find(u => u.username === username)
      if (user) {
        return {
          code: 200,
          message: 'success',
          data: {
            token: 'mock-token-' + Date.now(),
            tokenType: 'Bearer',
            ...user
          }
        }
      }
    }
    return { code: 401, message: '用户名或密码错误', data: null }
  }

  // ========== 扫码相关接口 ==========
  // 扫码获取物品信息
  if (url.match(/\/scan\/item\/(.+)/)) {
    const code = url.match(/\/scan\/item\/(.+)/)?.[1]
    const item = mockItems.find(i => i.itemCode === code || i.qrCode === code)
    if (item) {
      return { code: 200, message: 'success', data: item }
    }
    return { code: 404, message: '未找到该物品', data: null }
  }

  // 扫码入库
  if (url === '/scan/inbound' && method === 'post') {
    const { itemCode, quantity, inType, supplier, invoiceNo, operatorId, remark } = data
    const item = mockItems.find(i => i.itemCode === itemCode)
    if (item) {
      item.totalQuantity += quantity
      item.availableQuantity += quantity
      const record = {
        recordId: inboundRecordIdCounter++,
        inNo: 'IN' + Date.now(),
        itemCode: item.itemCode,
        itemId: item.itemId,
        itemName: item.itemName,
        quantity,
        inType: inType || 'PURCHASE',
        supplier,
        invoiceNo,
        operatorId,
        remark,
        createTime: new Date().toISOString().replace('T', ' ').slice(0, 19)
      }
      mockInRecords.unshift(record)
      return { code: 200, message: 'success', data: record }
    }
    return { code: 404, message: '未找到该物品', data: null }
  }

  // 扫码出库
  if (url === '/scan/outbound' && method === 'post') {
    const { itemCode, quantity, outType, receiverId, operatorId, remark } = data
    const item = mockItems.find(i => i.itemCode === itemCode)
    if (item) {
      if (item.availableQuantity < quantity) {
        return { code: 400, message: '库存不足', data: null }
      }
      item.availableQuantity -= quantity
      item.borrowedQuantity += quantity
      
      const receiver = mockUsers.find(u => u.userId === receiverId)
      const record = {
        recordId: outRecordIdCounter++,
        outNo: 'OUT' + Date.now(),
        itemCode: item.itemCode,
        itemId: item.itemId,
        itemName: item.itemName,
        quantity,
        outType: outType || 'USE',
        receiverId,
        receiverName: receiver?.realName || '',
        operatorId,
        remark,
        createTime: new Date().toISOString().replace('T', ' ').slice(0, 19)
      }
      mockOutRecords.unshift(record)
      return { code: 200, message: 'success', data: record }
    }
    return { code: 404, message: '未找到该物品', data: null }
  }

  // ========== 入库单管理接口 ==========
  // 获取入库单列表
  if (url === '/inbound-orders' && method === 'get') {
    const { pageNum = 1, pageSize = 10, orderNo, status, supplierId, orderType } = params || {}
    
    let filtered = [...mockInboundOrders]
    if (orderNo) filtered = filtered.filter(o => o.orderNo.includes(orderNo))
    if (status) filtered = filtered.filter(o => o.status === status)
    if (supplierId) filtered = filtered.filter(o => o.supplierId === supplierId)
    if (orderType) filtered = filtered.filter(o => o.orderType === orderType)
    
    const start = (pageNum - 1) * pageSize
    const records = filtered.slice(start, start + pageSize)
    
    return {
      code: 200,
      message: 'success',
      data: {
        records,
        total: filtered.length,
        current: pageNum,
        size: pageSize,
        pages: Math.ceil(filtered.length / pageSize)
      }
    }
  }

  // 获取入库单详情
  if (url.match(/\/inbound-orders\/(\d+)/) && method === 'get') {
    const id = parseInt(url.match(/\/inbound-orders\/(\d+)/)?.[1] || '0')
    const order = mockInboundOrders.find(o => o.orderId === id)
    if (order) {
      return {
        code: 200,
        message: 'success',
        data: {
          order,
          details: mockInboundOrderDetails[id] || []
        }
      }
    }
    return { code: 404, message: '入库单不存在', data: null }
  }

  // 创建入库单
  if (url === '/inbound-orders' && method === 'post') {
    const { order, details } = data
    const newOrder = {
      orderId: inboundOrderIdCounter,
      orderNo: 'RK' + Date.now(),
      ...order,
      supplierName: mockSuppliers.find(s => s.supplierId === order.supplierId)?.supplierName || '',
      warehouseName: mockWarehouses.find(w => w.warehouseId === order.warehouseId)?.warehouseName || '',
      totalQuantity: details.reduce((sum: number, d: any) => sum + d.quantity, 0),
      totalAmount: details.reduce((sum: number, d: any) => sum + (d.quantity * (d.unitPrice || 0)), 0),
      status: 'DRAFT',
      operatorId: 1,
      operatorName: '管理员',
      createTime: new Date().toISOString().replace('T', ' ').slice(0, 19),
      updateTime: new Date().toISOString().replace('T', ' ').slice(0, 19)
    }
    mockInboundOrders.unshift(newOrder)
    mockInboundOrderDetails[newOrder.orderId] = details.map((d: any, index: number) => ({
      detailId: index + 1,
      orderId: newOrder.orderId,
      ...d
    }))
    inboundOrderIdCounter++
    return { code: 200, message: 'success', data: newOrder }
  }

  // 更新入库单
  if (url.match(/\/inbound-orders\/(\d+)/) && method === 'put') {
    const id = parseInt(url.match(/\/inbound-orders\/(\d+)/)?.[1] || '0')
    const index = mockInboundOrders.findIndex(o => o.orderId === id)
    if (index >= 0) {
      const { order, details } = data
      mockInboundOrders[index] = {
        ...mockInboundOrders[index],
        ...order,
        supplierName: mockSuppliers.find(s => s.supplierId === order.supplierId)?.supplierName || '',
        warehouseName: mockWarehouses.find(w => w.warehouseId === order.warehouseId)?.warehouseName || '',
        totalQuantity: details.reduce((sum: number, d: any) => sum + d.quantity, 0),
        totalAmount: details.reduce((sum: number, d: any) => sum + (d.quantity * (d.unitPrice || 0)), 0),
        updateTime: new Date().toISOString().replace('T', ' ').slice(0, 19)
      }
      mockInboundOrderDetails[id] = details.map((d: any, idx: number) => ({
        detailId: idx + 1,
        orderId: id,
        ...d
      }))
      return { code: 200, message: 'success', data: mockInboundOrders[index] }
    }
    return { code: 404, message: '入库单不存在', data: null }
  }

  // 提交审核
  if (url.match(/\/inbound-orders\/(\d+)\/submit/) && method === 'post') {
    const id = parseInt(url.match(/\/inbound-orders\/(\d+)\/submit/)?.[1] || '0')
    const order = mockInboundOrders.find(o => o.orderId === id)
    if (order) {
      order.status = 'PENDING'
      order.updateTime = new Date().toISOString().replace('T', ' ').slice(0, 19)
      return { code: 200, message: 'success', data: order }
    }
    return { code: 404, message: '入库单不存在', data: null }
  }

  // 审核
  if (url.match(/\/inbound-orders\/(\d+)\/approve/) && method === 'post') {
    const id = parseInt(url.match(/\/inbound-orders\/(\d+)\/approve/)?.[1] || '0')
    const order = mockInboundOrders.find(o => o.orderId === id)
    if (order) {
      const { approved } = params || {}
      order.status = approved ? 'APPROVED' : 'DRAFT'
      order.approverId = 1
      order.approverName = '管理员'
      order.approveTime = new Date().toISOString().replace('T', ' ').slice(0, 19)
      order.updateTime = new Date().toISOString().replace('T', ' ').slice(0, 19)
      return { code: 200, message: 'success', data: order }
    }
    return { code: 404, message: '入库单不存在', data: null }
  }

  // 完成
  if (url.match(/\/inbound-orders\/(\d+)\/complete/) && method === 'post') {
    const id = parseInt(url.match(/\/inbound-orders\/(\d+)\/complete/)?.[1] || '0')
    const order = mockInboundOrders.find(o => o.orderId === id)
    if (order) {
      order.status = 'COMPLETED'
      order.actualArrivalDate = new Date().toISOString().slice(0, 10)
      order.updateTime = new Date().toISOString().replace('T', ' ').slice(0, 19)
      
      // 更新库存
      const details = mockInboundOrderDetails[id] || []
      details.forEach((d: any) => {
        const item = mockItems.find(i => i.itemName === d.itemName)
        if (item) {
          item.totalQuantity += d.quantity
          item.availableQuantity += d.quantity
        }
      })
      
      return { code: 200, message: 'success', data: order }
    }
    return { code: 404, message: '入库单不存在', data: null }
  }

  // 取消
  if (url.match(/\/inbound-orders\/(\d+)\/cancel/) && method === 'post') {
    const id = parseInt(url.match(/\/inbound-orders\/(\d+)\/cancel/)?.[1] || '0')
    const order = mockInboundOrders.find(o => o.orderId === id)
    if (order) {
      order.status = 'CANCELLED'
      order.updateTime = new Date().toISOString().replace('T', ' ').slice(0, 19)
      return { code: 200, message: 'success', data: order }
    }
    return { code: 404, message: '入库单不存在', data: null }
  }

  // ========== 供应商和仓库接口 ==========
  // 获取供应商列表
  if (url === '/suppliers' && method === 'get') {
    return { code: 200, message: 'success', data: mockSuppliers }
  }

  // 获取仓库列表
  if (url === '/warehouses' && method === 'get') {
    return { code: 200, message: 'success', data: mockWarehouses }
  }

  // ========== 出入库记录接口 ==========
  // 获取入库记录
  if (url === '/in-records') {
    return {
      code: 200,
      message: 'success',
      data: {
        records: mockInRecords,
        total: mockInRecords.length,
        current: 1,
        size: 10
      }
    }
  }

  // 获取出库记录
  if (url === '/out-records') {
    return {
      code: 200,
      message: 'success',
      data: {
        records: mockOutRecords,
        total: mockOutRecords.length,
        current: 1,
        size: 10
      }
    }
  }

  // ========== 物品管理接口 ==========
  // 获取物品列表
  if (url === '/items') {
    return {
      code: 200,
      message: 'success',
      data: {
        records: mockItems,
        total: mockItems.length,
        current: params?.pageNum || 1,
        size: params?.pageSize || 10
      }
    }
  }

  // 获取物品详情
  if (url.match(/\/items\/(\d+)/)) {
    const id = parseInt(url.match(/\/items\/(\d+)/)?.[1] || '0')
    const item = mockItems.find(i => i.itemId === id)
    if (item) {
      return { code: 200, message: 'success', data: item }
    }
    return { code: 404, message: '物品不存在', data: null }
  }

  // ========== 用户管理接口 ==========
  // 获取用户列表
  if (url === '/users') {
    return { code: 200, message: 'success', data: mockUsers }
  }

  // 获取分类列表
  if (url === '/categories') {
    return { code: 200, message: 'success', data: mockCategories }
  }

  // 默认返回
  console.log('[Mock] 未匹配的API:', url)
  return { code: 404, message: 'API not found: ' + url, data: null }
}

// 导出 Mock 数据
export { mockItems, mockInRecords, mockOutRecords, mockUsers, mockCategories, mockInboundOrders, mockSuppliers, mockWarehouses }
