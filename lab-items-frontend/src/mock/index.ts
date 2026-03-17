// Mock 数据服务 - 模拟后端 API

// 模拟物品数据
const mockItems = [
  {
    itemId: 1,
    itemCode: 'ITEM001',
    qrCode: 'QR001',
    itemName: 'Microscope',
    categoryId: 1,
    specification: 'BX53',
    brand: 'Olympus',
    unit: '台',
    price: 1500.00,
    location: 'Lab Building 1F',
    labRoom: 'A101',
    shelf: 'H-01',
    imageUrl: null,
    totalQuantity: 10,
    availableQuantity: 8,
    borrowedQuantity: 2,
    minStock: 2,
    maxStock: 20,
    status: 'AVAILABLE',
    remark: 'High quality microscope',
    createTime: '2024-01-15 10:00:00',
    updateTime: '2024-01-15 10:00:00'
  },
  {
    itemId: 2,
    itemCode: 'ITEM002',
    qrCode: 'QR002',
    itemName: 'Centrifuge',
    categoryId: 1,
    specification: 'TGL-16G',
    brand: 'Sigma',
    unit: '台',
    price: 5000.00,
    location: 'Lab Building 2F',
    labRoom: 'B202',
    shelf: 'H-02',
    imageUrl: null,
    totalQuantity: 5,
    availableQuantity: 3,
    borrowedQuantity: 2,
    minStock: 1,
    maxStock: 10,
    status: 'AVAILABLE',
    remark: 'High speed centrifuge',
    createTime: '2024-01-15 11:00:00',
    updateTime: '2024-01-15 11:00:00'
  },
  {
    itemId: 3,
    itemCode: 'ITEM003',
    qrCode: 'QR003',
    itemName: 'Pipette',
    categoryId: 3,
    specification: 'P1000',
    brand: 'Gilson',
    unit: '支',
    price: 200.00,
    location: 'Lab Building 1F',
    labRoom: 'A102',
    shelf: 'H-03',
    imageUrl: null,
    totalQuantity: 20,
    availableQuantity: 15,
    borrowedQuantity: 5,
    minStock: 5,
    maxStock: 50,
    status: 'AVAILABLE',
    remark: 'Adjustable volume pipette',
    createTime: '2024-01-15 12:00:00',
    updateTime: '2024-01-15 12:00:00'
  },
  {
    itemId: 4,
    itemCode: 'ITEM004',
    qrCode: 'QR004',
    itemName: 'Test Tube Rack',
    categoryId: 3,
    specification: '50 holes',
    brand: 'Generic',
    unit: '个',
    price: 50.00,
    location: 'Lab Building 2F',
    labRoom: 'B203',
    shelf: 'H-04',
    imageUrl: null,
    totalQuantity: 30,
    availableQuantity: 25,
    borrowedQuantity: 5,
    minStock: 10,
    maxStock: 100,
    status: 'AVAILABLE',
    remark: 'Standard test tube rack',
    createTime: '2024-01-15 13:00:00',
    updateTime: '2024-01-15 13:00:00'
  }
]

// 模拟入库记录
const mockInRecords = [
  {
    recordId: 1,
    inNo: 'IN20240115001',
    itemId: 1,
    quantity: 5,
    inType: 'PURCHASE',
    supplier: 'Scientific Instruments Co',
    invoiceNo: 'INV001',
    operatorId: 1,
    remark: 'Initial stock',
    createTime: '2024-01-15 09:00:00'
  }
]

// 模拟出库记录
const mockOutRecords = [
  {
    recordId: 1,
    outNo: 'OUT20240115001',
    itemId: 1,
    quantity: 2,
    outType: 'BORROW',
    receiverId: 2,
    operatorId: 1,
    remark: 'Lab experiment',
    createTime: '2024-01-15 14:00:00'
  }
]

// 模拟用户数据
const mockUsers = [
  { userId: 1, username: 'admin', realName: 'Admin', role: 'ADMIN' },
  { userId: 2, username: 'labadmin', realName: 'Lab Admin', role: 'LAB_ADMIN' },
  { userId: 3, username: 'teacher1', realName: 'Teacher Wang', role: 'TEACHER' },
  { userId: 4, username: 'student1', realName: 'Student Li', role: 'STUDENT' }
]

// 模拟分类数据
const mockCategories = [
  { categoryId: 1, categoryName: 'Equipment', parentId: 0, level: 1 },
  { categoryId: 2, categoryName: 'Office', parentId: 0, level: 1 },
  { categoryId: 3, categoryName: 'Consumables', parentId: 0, level: 1 }
]

// Mock API 处理函数
export function mockRequest(config: any): any {
  const { url, method, params, data } = config

  // 登录接口
  if (url === '/api/auth/login' && method === 'post') {
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
    return { code: 401, message: 'Invalid credentials', data: null }
  }

  // 扫码获取物品信息
  if (url.match(/\/api\/scan\/item\/(.+)/)) {
    const code = url.match(/\/api\/scan\/item\/(.+)/)?.[1]
    const item = mockItems.find(i => i.itemCode === code || i.qrCode === code)
    if (item) {
      return { code: 200, message: 'success', data: item }
    }
    return { code: 404, message: '未找到该物品', data: null }
  }

  // 扫码入库
  if (url === '/api/scan/inbound' && method === 'post') {
    const { itemCode, quantity, inType, supplier, invoiceNo, operatorId, remark } = data
    const item = mockItems.find(i => i.itemCode === itemCode)
    if (item) {
      item.totalQuantity += quantity
      item.availableQuantity += quantity
      const record = {
        recordId: mockInRecords.length + 1,
        inNo: 'IN' + Date.now(),
        itemId: item.itemId,
        quantity,
        inType: inType || 'PURCHASE',
        supplier,
        invoiceNo,
        operatorId,
        remark,
        createTime: new Date().toISOString()
      }
      mockInRecords.unshift(record)
      return { code: 200, message: 'success', data: record }
    }
    return { code: 404, message: '未找到该物品', data: null }
  }

  // 扫码出库
  if (url === '/api/scan/outbound' && method === 'post') {
    const { itemCode, quantity, outType, receiverId, operatorId, remark } = data
    const item = mockItems.find(i => i.itemCode === itemCode)
    if (item) {
      if (item.availableQuantity < quantity) {
        return { code: 400, message: '库存不足', data: null }
      }
      item.availableQuantity -= quantity
      item.borrowedQuantity += quantity
      const record = {
        recordId: mockOutRecords.length + 1,
        outNo: 'OUT' + Date.now(),
        itemId: item.itemId,
        quantity,
        outType: outType || 'USE',
        receiverId,
        operatorId,
        remark,
        createTime: new Date().toISOString()
      }
      mockOutRecords.unshift(record)
      return { code: 200, message: 'success', data: record }
    }
    return { code: 404, message: '未找到该物品', data: null }
  }

  // 获取入库记录
  if (url === '/api/in-records') {
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
  if (url === '/api/out-records') {
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

  // 获取物品列表
  if (url === '/api/items') {
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
  if (url.match(/\/api\/items\/(\d+)/)) {
    const id = parseInt(url.match(/\/api\/items\/(\d+)/)?.[1] || '0')
    const item = mockItems.find(i => i.itemId === id)
    if (item) {
      return { code: 200, message: 'success', data: item }
    }
    return { code: 404, message: 'Item not found', data: null }
  }

  // 获取用户列表
  if (url === '/api/users') {
    return { code: 200, message: 'success', data: mockUsers }
  }

  // 获取分类列表
  if (url === '/api/categories') {
    return { code: 200, message: 'success', data: mockCategories }
  }

  // 默认返回
  return { code: 404, message: 'API not found', data: null }
}

// 导出 Mock 数据
export { mockItems, mockInRecords, mockOutRecords, mockUsers, mockCategories }
