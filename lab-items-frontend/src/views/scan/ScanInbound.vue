<template>
  <div class="scan-inbound">
    <el-row :gutter="20">
      <!-- 左侧：扫码区域 -->
      <el-col :span="8">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>扫码入库</span>
              <el-tag type="success">入库模式</el-tag>
            </div>
          </template>

          <!-- 扫码输入 -->
          <div class="scan-input-area">
            <el-input
              ref="scanInputRef"
              v-model="scanCode"
              placeholder="请扫描物品二维码或输入物品编码"
              size="large"
              clearable
              @keyup.enter="handleScan"
            >
              <template #prefix>
                <el-icon><Camera /></el-icon>
              </template>
              <template #append>
                <el-button @click="handleScan" type="primary">确认</el-button>
              </template>
            </el-input>
            <p class="scan-tip">支持扫码枪或手动输入物品编码</p>
          </div>

          <!-- 快捷操作 -->
          <el-divider />
          <div class="quick-actions">
            <el-button type="primary" size="large" @click="showManualDialog = true">
              <el-icon><Edit /></el-icon>
              手动输入
            </el-button>
            <el-button size="large" @click="resetScan">
              <el-icon><Refresh /></el-icon>
              重置
            </el-button>
          </div>
        </el-card>

        <!-- 已扫描物品列表 -->
        <el-card style="margin-top: 20px">
          <template #header>
            <div class="card-header">
              <span>已扫描物品</span>
              <el-badge :value="scannedItems.length" type="primary" />
            </div>
          </template>
          <el-table :data="scannedItems" size="small" max-height="300">
            <el-table-column prop="itemCode" label="编码" width="100" />
            <el-table-column prop="itemName" label="名称" />
            <el-table-column prop="quantity" label="数量" width="60">
              <template #default="{ row }">
                <el-input-number
                  v-model="row.quantity"
                  :min="1"
                  size="small"
                  style="width: 70px"
                />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="50">
              <template #default="{ $index }">
                <el-button
                  type="danger"
                  size="small"
                  link
                  @click="removeScannedItem($index)"
                >
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="scannedItems.length === 0" description="暂无扫描记录" />
        </el-card>
      </el-col>

      <!-- 右侧：入库详情 -->
      <el-col :span="16">
        <!-- 当前扫描的物品信息 -->
        <el-card v-if="currentItem">
          <template #header>
            <div class="card-header">
              <span>物品信息</span>
              <el-tag :type="getStatusType(currentItem.status)">
                {{ getStatusText(currentItem.status) }}
              </el-tag>
            </div>
          </template>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="物品编码">{{ currentItem.itemCode }}</el-descriptions-item>
            <el-descriptions-item label="物品名称">{{ currentItem.itemName }}</el-descriptions-item>
            <el-descriptions-item label="规格型号">{{ currentItem.specification || '-' }}</el-descriptions-item>
            <el-descriptions-item label="品牌">{{ currentItem.brand || '-' }}</el-descriptions-item>
            <el-descriptions-item label="单位">{{ currentItem.unit || '-' }}</el-descriptions-item>
            <el-descriptions-item label="存放位置">{{ currentItem.location || '-' }}</el-descriptions-item>
            <el-descriptions-item label="当前库存">{{ currentItem.totalQuantity || 0 }}</el-descriptions-item>
            <el-descriptions-item label="可用数量">{{ currentItem.availableQuantity || 0 }}</el-descriptions-item>
            <el-descriptions-item label="借出数量">{{ currentItem.borrowedQuantity || 0 }}</el-descriptions-item>
          </el-descriptions>

          <!-- 入库数量输入 -->
          <el-divider />
          <el-form :model="inboundForm" label-width="100px">
            <el-row :gutter="20">
              <el-col :span="8">
                <el-form-item label="入库数量" required>
                  <el-input-number
                    v-model="inboundForm.quantity"
                    :min="1"
                    style="width: 100%"
                  />
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="入库类型">
                  <el-select v-model="inboundForm.inType" style="width: 100%">
                    <el-option label="采购入库" value="PURCHASE" />
                    <el-option label="归还入库" value="RETURN" />
                    <el-option label="调拨入库" value="TRANSFER" />
                    <el-option label="其他入库" value="OTHER" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="供应商">
                  <el-input v-model="inboundForm.supplier" placeholder="选填" />
                </el-form-item>
              </el-col>
            </el-row>
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="发票号">
                  <el-input v-model="inboundForm.invoiceNo" placeholder="选填" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="备注">
                  <el-input v-model="inboundForm.remark" placeholder="选填" />
                </el-form-item>
              </el-col>
            </el-row>
            <el-form-item>
              <el-button type="primary" size="large" @click="addToScanList">
                添加到入库列表
              </el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 入库操作面板 -->
        <el-card v-else>
          <el-empty description="请扫描物品二维码或输入物品编码">
            <el-button type="primary" @click="showManualDialog = true">
              手动输入编码
            </el-button>
          </el-empty>
        </el-card>

        <!-- 提交入库 -->
        <el-card style="margin-top: 20px" v-if="scannedItems.length > 0">
          <div class="submit-panel">
            <div class="summary">
              <span>共 <strong>{{ scannedItems.length }}</strong> 项物品</span>
              <span>总数量：<strong>{{ totalQuantity }}</strong></span>
            </div>
            <el-button type="primary" size="large" @click="submitInbound" :loading="submitting">
              确认入库
            </el-button>
          </div>
        </el-card>

        <!-- 最近入库记录 -->
        <el-card style="margin-top: 20px">
          <template #header>
            <span>最近入库记录</span>
          </template>
          <el-table :data="recentRecords" size="small">
            <el-table-column prop="inNo" label="入库单号" width="160" />
            <el-table-column prop="itemCode" label="物品编码" width="100" />
            <el-table-column prop="itemName" label="物品名称" />
            <el-table-column prop="quantity" label="数量" width="80" align="right" />
            <el-table-column prop="inType" label="类型" width="100">
              <template #default="{ row }">
                <el-tag :type="getInTypeTag(row.inType)" size="small">
                  {{ getInTypeText(row.inType) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createTime" label="入库时间" width="180" />
          </el-table>
          <el-empty v-if="recentRecords.length === 0" description="暂无入库记录" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 手动输入对话框 -->
    <el-dialog v-model="showManualDialog" title="手动输入物品编码" width="400px">
      <el-input
        v-model="manualCode"
        placeholder="请输入物品编码"
        size="large"
        @keyup.enter="handleManualInput"
      />
      <template #footer>
        <el-button @click="showManualDialog = false">取消</el-button>
        <el-button type="primary" @click="handleManualInput">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { request } from '@/utils/request'

// 扫码相关
const scanCode = ref('')
const scanInputRef = ref()
const showManualDialog = ref(false)
const manualCode = ref('')

// 当前扫描的物品
const currentItem = ref<any>(null)

// 已扫描物品列表
const scannedItems = ref<any[]>([])

// 入库表单
const inboundForm = ref({
  quantity: 1,
  inType: 'PURCHASE',
  supplier: '',
  invoiceNo: '',
  remark: ''
})

// 最近入库记录
const recentRecords = ref<any[]>([])

// 提交状态
const submitting = ref(false)

// 用户信息
const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')

// 总数量
const totalQuantity = computed(() => {
  return scannedItems.value.reduce((sum, item) => sum + item.quantity, 0)
})

// 扫码处理
const handleScan = async () => {
  if (!scanCode.value.trim()) {
    ElMessage.warning('请输入物品编码')
    return
  }

  try {
    const res = await request.get(`/scan/item/${scanCode.value.trim()}`)
    if (res.code === 200) {
      currentItem.value = res.data
      inboundForm.value.quantity = 1
      ElMessage.success('扫描成功：' + res.data.itemName)
    } else {
      ElMessage.error(res.message || '未找到该物品')
    }
  } catch (error) {
    console.error('扫码失败:', error)
    ElMessage.error('扫码失败，请检查网络连接')
  }

  // 清空输入，准备下一次扫描
  scanCode.value = ''
  // 聚焦输入框
  setTimeout(() => {
    scanInputRef.value?.focus()
  }, 100)
}

// 手动输入处理
const handleManualInput = () => {
  if (!manualCode.value.trim()) {
    ElMessage.warning('请输入物品编码')
    return
  }
  scanCode.value = manualCode.value.trim()
  showManualDialog.value = false
  manualCode.value = ''
  handleScan()
}

// 添加到扫描列表
const addToScanList = () => {
  if (!currentItem.value) return

  // 检查是否已存在
  const existIndex = scannedItems.value.findIndex(
    item => item.itemCode === currentItem.value.itemCode
  )

  if (existIndex >= 0) {
    // 已存在则更新数量
    scannedItems.value[existIndex].quantity += inboundForm.value.quantity
  } else {
    // 不存在则添加
    scannedItems.value.push({
      ...currentItem.value,
      quantity: inboundForm.value.quantity,
      inType: inboundForm.value.inType,
      supplier: inboundForm.value.supplier,
      invoiceNo: inboundForm.value.invoiceNo,
      remark: inboundForm.value.remark
    })
  }

  ElMessage.success('已添加到入库列表')
  currentItem.value = null
  inboundForm.value = {
    quantity: 1,
    inType: 'PURCHASE',
    supplier: '',
    invoiceNo: '',
    remark: ''
  }
}

// 移除扫描物品
const removeScannedItem = (index: number) => {
  scannedItems.value.splice(index, 1)
}

// 重置扫描
const resetScan = () => {
  scannedItems.value = []
  currentItem.value = null
  scanCode.value = ''
  inboundForm.value = {
    quantity: 1,
    inType: 'PURCHASE',
    supplier: '',
    invoiceNo: '',
    remark: ''
  }
  ElMessage.success('已重置')
}

// 提交入库
const submitInbound = async () => {
  if (scannedItems.value.length === 0) {
    ElMessage.warning('请先添加入库物品')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确认入库 ${scannedItems.value.length} 项物品，总数量 ${totalQuantity.value}？`,
      '确认入库',
      { confirmButtonText: '确认', cancelButtonText: '取消', type: 'info' }
    )

    submitting.value = true

    // 逐个提交入库
    for (const item of scannedItems.value) {
      await request.post('/scan/inbound', {
        itemCode: item.itemCode,
        quantity: item.quantity,
        inType: item.inType,
        supplier: item.supplier,
        invoiceNo: item.invoiceNo,
        operatorId: userInfo.userId,
        remark: item.remark
      })
    }

    ElMessage.success('入库成功！')
    
    // 刷新最近记录
    loadRecentRecords()
    
    // 重置
    resetScan()
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('入库失败:', error)
      ElMessage.error('入库失败，请重试')
    }
  } finally {
    submitting.value = false
  }
}

// 加载最近入库记录
const loadRecentRecords = async () => {
  try {
    const res = await request.get('/in-records', {
      params: { pageNum: 1, pageSize: 10 }
    })
    if (res.code === 200) {
      recentRecords.value = res.data?.records || []
    }
  } catch (error) {
    console.error('加载入库记录失败:', error)
  }
}

// 获取状态类型
const getStatusType = (status: string) => {
  const types: Record<string, any> = {
    AVAILABLE: 'success',
    BORROWED: 'warning',
    REPAIRING: 'danger',
    SCRAPPED: 'info',
    LOST: 'danger'
  }
  return types[status] || 'info'
}

// 获取状态文本
const getStatusText = (status: string) => {
  const texts: Record<string, string> = {
    AVAILABLE: '可用',
    BORROWED: '借出',
    REPAIRING: '维修中',
    SCRAPPED: '已报废',
    LOST: '丢失'
  }
  return texts[status] || status
}

// 获取入库类型标签
const getInTypeTag = (type: string) => {
  const tags: Record<string, any> = {
    PURCHASE: 'success',
    RETURN: 'warning',
    TRANSFER: 'info',
    OTHER: ''
  }
  return tags[type] || ''
}

// 获取入库类型文本
const getInTypeText = (type: string) => {
  const texts: Record<string, string> = {
    PURCHASE: '采购入库',
    RETURN: '归还入库',
    TRANSFER: '调拨入库',
    OTHER: '其他入库'
  }
  return texts[type] || type
}

onMounted(() => {
  // 自动聚焦扫码输入框
  scanInputRef.value?.focus()
  // 加载最近记录
  loadRecentRecords()
})
</script>

<style scoped lang="scss">
.scan-inbound {
  padding: 20px;

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .scan-input-area {
    margin-bottom: 20px;

    .scan-tip {
      margin-top: 10px;
      font-size: 12px;
      color: #909399;
      text-align: center;
    }
  }

  .quick-actions {
    display: flex;
    gap: 10px;
    justify-content: center;
  }

  .submit-panel {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .summary {
      font-size: 14px;
      color: #606266;

      strong {
        color: #409EFF;
        font-size: 18px;
      }

      span {
        margin-right: 20px;
      }
    }
  }
}
</style>
