<template>
  <div class="item-detail">
    <el-card v-loading="loading">
      <template #header>
        <div class="card-header">
          <el-button @click="$router.back()">
            <el-icon><ArrowLeft /></el-icon>
            返回
          </el-button>
          <span>物品详情</span>
        </div>
      </template>

      <el-descriptions v-if="item" title="基本信息" :column="2" border>
        <el-descriptions-item label="物品编号">{{ item.itemCode || '-' }}</el-descriptions-item>
        <el-descriptions-item label="物品名称">{{ item.itemName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="规格型号">{{ item.specification || '-' }}</el-descriptions-item>
        <el-descriptions-item label="品牌">{{ item.brand || '-' }}</el-descriptions-item>
        <el-descriptions-item label="单位">{{ item.unit || '-' }}</el-descriptions-item>
        <el-descriptions-item label="单价">¥{{ (item.price || 0).toFixed(2) }}</el-descriptions-item>
        <el-descriptions-item label="总数量">{{ item.totalQuantity || 0 }}</el-descriptions-item>
        <el-descriptions-item label="可用数量">{{ item.availableQuantity || 0 }}</el-descriptions-item>
        <el-descriptions-item label="借出数量">{{ item.borrowedQuantity || 0 }}</el-descriptions-item>
        <el-descriptions-item label="存放位置">{{ item.location || '-' }}</el-descriptions-item>
        <el-descriptions-item label="房间号">{{ item.labRoom || '-' }}</el-descriptions-item>
        <el-descriptions-item label="货架号">{{ item.shelf || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(item.status)">{{ getStatusText(item.status) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ item.createTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ item.remark || '-' }}</el-descriptions-item>
      </el-descriptions>

      <el-empty v-else-if="!loading" description="物品不存在或已删除" />

      <el-divider />

      <el-tabs>
        <el-tab-pane label="出入库记录">
          <el-table :data="inOutRecords" stripe v-loading="recordsLoading">
            <el-table-column prop="type" label="类型" width="100">
              <template #default="{ row }">
                <el-tag :type="row.type === 'IN' ? 'success' : 'warning'">
                  {{ row.type === 'IN' ? '入库' : '出库' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="quantity" label="数量" width="80" />
            <el-table-column prop="operator" label="操作人" width="100" />
            <el-table-column prop="time" label="时间" width="180" />
            <el-table-column prop="remark" label="备注" />
          </el-table>
          <el-empty v-if="inOutRecords.length === 0 && !recordsLoading" description="暂无记录" />
        </el-tab-pane>
        <el-tab-pane label="借用记录">
          <el-table :data="borrowRecords" stripe v-loading="recordsLoading">
            <el-table-column prop="borrower" label="借用人" width="100" />
            <el-table-column prop="quantity" label="数量" width="80" />
            <el-table-column prop="borrowDate" label="借用日期" width="120" />
            <el-table-column prop="returnDate" label="归还日期" width="120" />
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="getBorrowStatusType(row.status)">{{ getBorrowStatusText(row.status) }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="borrowRecords.length === 0 && !recordsLoading" description="暂无记录" />
        </el-tab-pane>
        <el-tab-pane label="维修记录">
          <el-table :data="repairRecords" stripe v-loading="recordsLoading">
            <el-table-column prop="type" label="类型" width="80">
              <template #default="{ row }">
                <el-tag :type="row.type === 'REPAIR' ? 'warning' : 'info'">
                  {{ row.type === 'REPAIR' ? '维修' : '报废' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="description" label="故障描述" />
            <el-table-column prop="handler" label="处理人" width="100" />
            <el-table-column prop="time" label="时间" width="180" />
            <el-table-column prop="status" label="状态" width="80" />
          </el-table>
          <el-empty v-if="repairRecords.length === 0 && !recordsLoading" description="暂无记录" />
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getItemDetailApi, type Item } from '@/api'

const route = useRoute()
const loading = ref(false)
const recordsLoading = ref(false)
const item = ref<Item | null>(null)

// 记录数据
const inOutRecords = ref<any[]>([])
const borrowRecords = ref<any[]>([])
const repairRecords = ref<any[]>([])

// 加载物品详情
const loadItemDetail = async () => {
  const id = route.params.id as string
  if (!id) {
    ElMessage.error('物品ID不存在')
    return
  }

  loading.value = true
  try {
    const res = await getItemDetailApi(Number(id))
    if (res.code === 200) {
      item.value = res.data
    } else {
      ElMessage.error(res.message || '获取物品详情失败')
    }
  } catch (error) {
    console.error('获取物品详情失败:', error)
    ElMessage.error('获取物品详情失败，请检查网络连接')
  } finally {
    loading.value = false
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

// 获取借用状态类型
const getBorrowStatusType = (status: string) => {
  const types: Record<string, any> = {
    PENDING: 'warning',
    APPROVED: 'success',
    REJECTED: 'danger',
    RETURNED: 'info'
  }
  return types[status] || 'info'
}

// 获取借用状态文本
const getBorrowStatusText = (status: string) => {
  const texts: Record<string, string> = {
    PENDING: '待审批',
    APPROVED: '已批准',
    REJECTED: '已拒绝',
    RETURNED: '已归还'
  }
  return texts[status] || status
}

onMounted(() => {
  loadItemDetail()
})
</script>

<style scoped lang="scss">
.item-detail {
  .card-header {
    display: flex;
    align-items: center;
    gap: 15px;
    font-weight: bold;
  }
}
</style>
