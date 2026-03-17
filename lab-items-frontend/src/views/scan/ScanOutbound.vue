<template>
  <div class="scan-outbound">
    <el-row :gutter="20">
      <!-- 左侧：扫码区域 -->
      <el-col :span="8">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>扫码出库</span>
              <el-tag type="warning">出库模式</el-tag>
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
              <span>待出库物品</span>
              <el-badge :value="scannedItems.length" type="warning" />
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
                  :max="row.availableQuantity"
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

      <!-- 右侧：出库详情 -->
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
            <el-descriptions-item label="可用数量">
              <span :class="{ 'low-stock': currentItem.availableQuantity <= currentItem.minStock }">
                {{ currentItem.availableQuantity || 0 }}
              </span>
            </el-descriptions-item>
            <el-descriptions-item label="借出数量">{{ currentItem.borrowedQuantity || 0 }}</el-descriptions-item>
          </el-descriptions>

          <!-- 库存警告 -->
          <el-alert
            v-if="currentItem.availableQuantity <= currentItem.minStock"
            type="warning"
            title="库存不足"
            :description="`当前可用数量 ${currentItem.availableQuantity}，低于最低库存 ${currentItem.minStock}`"
            show-icon
            style="margin-top: 15px"
          />

          <!-- 出库数量输入 -->
          <el-divider />
          <el-form :model="outboundForm" label-width="100px">
            <el-row :gutter="20">
              <el-col :span="8">
                <el-form-item label="出库数量" required>
                  <el-input-number
                    v-model="outboundForm.quantity"
                    :min="1"
                    :max="currentItem.availableQuantity"
                    style="width: 100%"
                  />
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="出库类型">
                  <el-select v-model="outboundForm.outType" style="width: 100%">
                    <el-option label="领用出库" value="USE" />
                    <el-option label="借用出库" value="BORROW" />
                    <el-option label="调拨出库" value="TRANSFER" />
                    <el-option label="其他出库" value="OTHER" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="8">
                <el-form-item label="领用人">
                  <el-select v-model="outboundForm.receiverId" style="width: 100%" placeholder="选填">
                    <el-option
                      v-for="user in userList"
                      :key="user.userId"
                      :label="user.realName"
                      :value="user.userId"
                    />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>
            <el-form-item label="备注">
              <el-input v-model="outboundForm.remark" placeholder="选填" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" size="large" @click="addToScanList">
                添加到出库列表
              </el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 出库操作面板 -->
        <el-card v-else>
          <el-empty description="请扫描物品二维码或输入物品编码">
            <el-button type="primary" @click="showManualDialog = true">
              手动输入编码
            </el-button>
          </el-empty>
        </el-card>

        <!-- 提交出库 -->
        <el-card style="margin-top: 20px" v-if="scannedItems.length > 0">
          <div class="submit-panel">
            <div class="summary">
              <span>共 <strong>{{ scannedItems.length }}</strong> 项物品</span>
              <span>总数量：<strong>{{ totalQuantity }}</strong></span>
            </div>
            <el-button type="warning" size="large" @click="submitOutbound" :loading="submitting">
              确认出库
            </el-button>
          </div>
        </el-card>

        <!-- 最近出库记录 -->
        <el-card style="margin-top: 20px">
          <template #header>
            <span>最近出库记录</span>
          </template>
          <el-table :data="recentRecords" size="small">
            <el-table-column prop="outNo" label="出库单号" width="160" />
            <el-table-column prop="itemCode" label="物品编码" width="100" />
            <el-table-column prop="itemName" label="物品名称" />
            <el-table-column prop="quantity" label="数量" width="80" align="right" />
            <el-table-column prop="outType" label="类型" width="100">
              <template #default="{ row }">
                <el-tag :type="getOutTypeTag(row.outType)" size="small">
                  {{ getOutTypeText(row.outType) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createTime" label="出库时间" width="180" />
          </el-table>
          <el-empty v-if="recentRecords.length === 0" description="暂无出库记录" />
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

// 出库表单
const outboundForm = ref({
  quantity: 1,
  outType: 'USE',
  receiverId: null as number | null,
  remark: ''
})

// 最近出库记录
const recentRecords = ref<any[]>([])

// 用户列表（领用人选择）
const userList = ref<any[]>([])

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
      outboundForm.value.quantity = 1
      
      if (res.data.availableQuantity <= 0) {
        ElMessage.warning('该物品库存不足，无法出库')
      } else {
        ElMessage.success('扫描成功：' + res.data.itemName)
      }
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

  if (currentItem.value.availableQuantity <= 0) {
    ElMessage.error('该物品库存不足，无法出库')
    return
  }

  if (outboundForm.value.quantity > currentItem.value.availableQuantity) {
    ElMessage.error('出库数量不能超过可用数量')
    return
  }

  // 检查是否已存在
  const existIndex = scannedItems.value.findIndex(
    item => item.itemCode === currentItem.value.itemCode
  )

  if (existIndex >= 0) {
    // 已存在则更新数量
    const newQty = scannedItems.value[existIndex].quantity + outboundForm.value.quantity
    if (newQty > currentItem.value.availableQuantity) {
      ElMessage.warning('超出可用数量，已调整为最大可用数量')
      scannedItems.value[existIndex].quantity = currentItem.value.availableQuantity
    } else {
      scannedItems.value[existIndex].quantity = newQty
    }
  } else {
    // 不存在则添加
    scannedItems.value.push({
      ...currentItem.value,
      quantity: outboundForm.value.quantity,
      outType: outboundForm.value.outType,
      receiverId: outboundForm.value.receiverId,
      remark: outboundForm.value.remark
    })
  }

  ElMessage.success('已添加到出库列表')
  currentItem.value = null
  outboundForm.value = {
    quantity: 1,
    outType: 'USE',
    receiverId: null,
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
  outboundForm.value = {
    quantity: 1,
    outType: 'USE',
    receiverId: null,
    remark: ''
  }
  ElMessage.success('已重置')
}

// 提交出库
const submitOutbound = async () => {
  if (scannedItems.value.length === 0) {
    ElMessage.warning('请先添加出库物品')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确认出库 ${scannedItems.value.length} 项物品，总数量 ${totalQuantity.value}？`,
      '确认出库',
      { confirmButtonText: '确认', cancelButtonText: '取消', type: 'warning' }
    )

    submitting.value = true

    // 逐个提交出库
    for (const item of scannedItems.value) {
      await request.post('/scan/outbound', {
        itemCode: item.itemCode,
        quantity: item.quantity,
        outType: item.outType,
        receiverId: item.receiverId,
        operatorId: userInfo.userId,
        remark: item.remark
      })
    }

    ElMessage.success('出库成功！')
    
    // 刷新最近记录
    loadRecentRecords()
    
    // 重置
    resetScan()
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('出库失败:', error)
      ElMessage.error('出库失败，请重试')
    }
  } finally {
    submitting.value = false
  }
}

// 加载最近出库记录
const loadRecentRecords = async () => {
  try {
    const res = await request.get('/out-records', {
      params: { pageNum: 1, pageSize: 10 }
    })
    if (res.code === 200) {
      recentRecords.value = res.data?.records || []
    }
  } catch (error) {
    console.error('加载出库记录失败:', error)
  }
}

// 加载用户列表
const loadUserList = async () => {
  try {
    const res = await request.get('/users')
    if (res.code === 200) {
      userList.value = res.data || []
    }
  } catch (error) {
    console.error('加载用户列表失败:', error)
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

// 获取出库类型标签
const getOutTypeTag = (type: string) => {
  const tags: Record<string, any> = {
    USE: 'success',
    BORROW: 'warning',
    TRANSFER: 'info',
    OTHER: ''
  }
  return tags[type] || ''
}

// 获取出库类型文本
const getOutTypeText = (type: string) => {
  const texts: Record<string, string> = {
    USE: '领用出库',
    BORROW: '借用出库',
    TRANSFER: '调拨出库',
    OTHER: '其他出库'
  }
  return texts[type] || type
}

onMounted(() => {
  // 自动聚焦扫码输入框
  scanInputRef.value?.focus()
  // 加载最近记录
  loadRecentRecords()
  // 加载用户列表
  loadUserList()
})
</script>

<style scoped lang="scss">
.scan-outbound {
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
        color: #E6A23C;
        font-size: 18px;
      }

      span {
        margin-right: 20px;
      }
    }
  }

  .low-stock {
    color: #F56C6C;
    font-weight: bold;
  }
}
</style>
