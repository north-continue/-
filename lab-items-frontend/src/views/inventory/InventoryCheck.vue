<template>
  <div class="inventory-check">
    <el-card>
      <template #header>
        <div class="card-header">
          <h2>盘点管理</h2>
          <el-button type="primary" @click="showCreateDialog = true">创建盘点任务</el-button>
        </div>
      </template>

      <!-- 搜索表单 -->
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="盘点单号">
          <el-input v-model="searchForm.checkNo" placeholder="请输入盘点单号" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="进行中" value="IN_PROGRESS" />
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="已审核" value="APPROVED" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" style="width: 100%" v-loading="loading">
        <el-table-column prop="checkNo" label="盘点单号" width="180" />
        <el-table-column prop="checkType" label="盘点类型" width="120">
          <template #default="{ row }">
            <el-tag :type="row.checkType === 'FULL' ? 'primary' : 'warning'">
              {{ row.checkType === 'FULL' ? '全面盘点' : '局部盘点' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="checkDate" label="盘点日期" width="120" />
        <el-table-column prop="checkerId" label="盘点人ID" width="100" />
        <el-table-column prop="totalItems" label="盘点物品数" width="120" />
        <el-table-column prop="diffCount" label="差异数量" width="100">
          <template #default="{ row }">
            <span :class="{ 'diff-positive': row.diffCount > 0, 'diff-negative': row.diffCount < 0 }">
              {{ row.diffCount }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status)">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button 
              v-if="row.status === 'IN_PROGRESS'" 
              type="success" 
              size="small" 
              @click="handleComplete(row)">
              完成
            </el-button>
            <el-button 
              v-if="row.status === 'COMPLETED'" 
              type="warning" 
              size="small" 
              @click="handleApprove(row)">
              审核
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="pagination.pageNum"
        v-model:page-size="pagination.pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>

    <!-- 创建盘点任务对话框 -->
    <el-dialog v-model="showCreateDialog" title="创建盘点任务" width="600px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
        <el-form-item label="盘点类型" prop="checkType">
          <el-radio-group v-model="form.checkType">
            <el-radio value="FULL">全面盘点</el-radio>
            <el-radio value="PARTIAL">局部盘点</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="盘点日期" prop="checkDate">
          <el-date-picker
            v-model="form.checkDate"
            type="date"
            placeholder="选择盘点日期"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="盘点范围">
          <el-select v-model="form.categoryIds" multiple placeholder="请选择物品类别" style="width: 100%">
            <el-option label="实验设备" :value="1" />
            <el-option label="办公设备" :value="2" />
            <el-option label="耗材" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>

    <!-- 盘点详情对话框 -->
    <el-dialog v-model="showDetailDialog" title="盘点详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="盘点单号">{{ currentRecord?.checkNo }}</el-descriptions-item>
        <el-descriptions-item label="盘点类型">
          {{ currentRecord?.checkType === 'FULL' ? '全面盘点' : '局部盘点' }}
        </el-descriptions-item>
        <el-descriptions-item label="盘点日期">{{ currentRecord?.checkDate }}</el-descriptions-item>
        <el-descriptions-item label="盘点人ID">{{ currentRecord?.checkerId }}</el-descriptions-item>
        <el-descriptions-item label="盘点物品数">{{ currentRecord?.totalItems }}</el-descriptions-item>
        <el-descriptions-item label="差异数量">
          <span :class="{ 'diff-positive': currentRecord?.diffCount > 0, 'diff-negative': currentRecord?.diffCount < 0 }">
            {{ currentRecord?.diffCount }}
          </span>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusTag(currentRecord?.status)">{{ getStatusText(currentRecord?.status) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="备注">{{ currentRecord?.remark }}</el-descriptions-item>
      </el-descriptions>

      <el-divider content-position="left">盘点明细</el-divider>
      
      <el-table :data="detailData" style="width: 100%" max-height="400">
        <el-table-column prop="itemName" label="物品名称" width="150" />
        <el-table-column prop="itemCode" label="物品编号" width="120" />
        <el-table-column prop="systemQuantity" label="系统数量" width="100" />
        <el-table-column prop="actualQuantity" label="实际数量" width="100" />
        <el-table-column prop="diffQuantity" label="差异数量" width="100">
          <template #default="{ row }">
            <span :class="{ 'diff-positive': row.diffQuantity > 0, 'diff-negative': row.diffQuantity < 0 }">
              {{ row.diffQuantity }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

// 表格数据
const tableData = ref([])
const detailData = ref([])
const loading = ref(false)

// 搜索表单
const searchForm = reactive({
  checkNo: '',
  status: ''
})

// 分页
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

// 对话框
const showCreateDialog = ref(false)
const showDetailDialog = ref(false)
const submitting = ref(false)

// 表单
const formRef = ref<FormInstance>()
const form = reactive({
  checkType: 'FULL',
  checkDate: '',
  categoryIds: [] as number[],
  remark: ''
})

// 当前记录
const currentRecord = ref<any>(null)

// 表单验证规则
const rules: FormRules = {
  checkType: [
    { required: true, message: '请选择盘点类型', trigger: 'change' }
  ],
  checkDate: [
    { required: true, message: '请选择盘点日期', trigger: 'change' }
  ]
}

// 获取状态文本
const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    'IN_PROGRESS': '进行中',
    'COMPLETED': '已完成',
    'APPROVED': '已审核'
  }
  return statusMap[status] || status
}

// 获取状态标签样式
const getStatusTag = (status: string) => {
  const statusMap: Record<string, string> = {
    'IN_PROGRESS': 'primary',
    'COMPLETED': 'warning',
    'APPROVED': 'success'
  }
  return statusMap[status] || ''
}

// 获取盘点记录列表
const fetchInventoryChecks = async () => {
  loading.value = true
  try {
    const params = {
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize,
      checkNo: searchForm.checkNo || undefined,
      status: searchForm.status || undefined
    }
    
    // 模拟API调用
    setTimeout(() => {
      tableData.value = [
        {
          checkId: 1,
          checkNo: 'CHECK20230115120000',
          checkType: 'FULL',
          checkDate: '2023-01-15',
          checkerId: 1,
          totalItems: 100,
          diffCount: 2,
          status: 'COMPLETED',
          remark: '月度全面盘点',
          createTime: '2023-01-15 12:00:00'
        }
      ]
      pagination.total = 1
      loading.value = false
    }, 500)
  } catch (error) {
    ElMessage.error('获取盘点记录失败')
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.pageNum = 1
  fetchInventoryChecks()
}

// 重置
const handleReset = () => {
  searchForm.checkNo = ''
  searchForm.status = ''
  handleSearch()
}

// 分页大小改变
const handleSizeChange = (size: number) => {
  pagination.pageSize = size
  fetchInventoryChecks()
}

// 当前页改变
const handleCurrentChange = (page: number) => {
  pagination.pageNum = page
  fetchInventoryChecks()
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true
      try {
        ElMessage.success('盘点任务创建成功')
        showCreateDialog.value = false
        resetForm()
        fetchInventoryChecks()
      } catch (error) {
        ElMessage.error('创建盘点任务失败')
      } finally {
        submitting.value = false
      }
    }
  })
}

// 查看详情
const handleView = (row: any) => {
  currentRecord.value = row
  // 模拟盘点明细数据
  detailData.value = [
    {
      itemName: '烧杯',
      itemCode: 'ITEM001',
      systemQuantity: 10,
      actualQuantity: 12,
      diffQuantity: 2,
      remark: '数量差异'
    }
  ]
  showDetailDialog.value = true
}

// 完成盘点
const handleComplete = (row: any) => {
  ElMessageBox.confirm(
    `确定要完成盘点任务 ${row.checkNo} 吗？`,
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('盘点已完成')
    fetchInventoryChecks()
  }).catch(() => {
    // 取消操作
  })
}

// 审核盘点
const handleApprove = (row: any) => {
  ElMessageBox.confirm(
    `确定要审核通过盘点任务 ${row.checkNo} 吗？`,
    '审核',
    {
      confirmButtonText: '通过',
      cancelButtonText: '拒绝',
      distinguishCancelAndClose: true,
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('审核通过')
    fetchInventoryChecks()
  }).catch((action) => {
    if (action === 'cancel') {
      ElMessage.info('已拒绝')
      fetchInventoryChecks()
    }
  })
}

// 重置表单
const resetForm = () => {
  form.checkType = 'FULL'
  form.checkDate = ''
  form.categoryIds = []
  form.remark = ''
  formRef.value?.resetFields()
}

// 页面加载时获取数据
onMounted(() => {
  fetchInventoryChecks()
})
</script>

<style scoped lang="scss">
.inventory-check {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    
    h2 {
      margin: 0;
      font-size: 18px;
    }
  }
  
  .search-form {
    margin-bottom: 20px;
  }
  
  .diff-positive {
    color: #67c23a;
    font-weight: bold;
  }
  
  .diff-negative {
    color: #f56c6c;
    font-weight: bold;
  }
}
</style>