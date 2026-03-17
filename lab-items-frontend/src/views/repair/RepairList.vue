<template>
  <div class="repair-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <h2>报废报修管理</h2>
          <el-button type="primary" @click="showAddDialog = true">提交申请</el-button>
        </div>
      </template>

      <!-- 搜索表单 -->
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="记录单号">
          <el-input v-model="searchForm.recordNo" placeholder="请输入记录单号" clearable />
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="searchForm.type" placeholder="请选择类型" clearable>
            <el-option label="报修" value="REPAIR" />
            <el-option label="报废" value="SCRAP" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="待处理" value="PENDING" />
            <el-option label="处理中" value="PROCESSING" />
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="已拒绝" value="REJECTED" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" style="width: 100%" v-loading="loading">
        <el-table-column prop="recordNo" label="记录单号" width="180" />
        <el-table-column prop="itemId" label="物品ID" width="100" />
        <el-table-column prop="type" label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.type === 'REPAIR' ? 'warning' : 'danger'">
              {{ row.type === 'REPAIR' ? '报修' : '报废' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="reason" label="原因" width="200" show-overflow-tooltip />
        <el-table-column prop="reporterId" label="报告人ID" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status)">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="handleResult" label="处理结果" width="200" show-overflow-tooltip />
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button 
              v-if="row.status === 'PENDING'" 
              type="success" 
              size="small" 
              @click="handleProcess(row)">
              处理
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

    <!-- 新增/编辑对话框 -->
    <el-dialog v-model="showAddDialog" :title="dialogTitle" width="600px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="物品ID" prop="itemId">
          <el-input v-model="form.itemId" placeholder="请输入物品ID" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-radio-group v-model="form.type">
            <el-radio value="REPAIR">报修</el-radio>
            <el-radio value="SCRAP">报废</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="原因" prop="reason">
          <el-input v-model="form.reason" type="textarea" :rows="4" placeholder="请详细说明原因" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>

    <!-- 处理对话框 -->
    <el-dialog v-model="showProcessDialog" title="处理申请" width="600px">
      <el-form :model="processForm" :rules="processRules" ref="processFormRef" label-width="100px">
        <el-form-item label="处理结果" prop="handleResult">
          <el-input v-model="processForm.handleResult" type="textarea" :rows="4" placeholder="请输入处理结果" />
        </el-form-item>
        <el-form-item label="处理状态" prop="status">
          <el-select v-model="processForm.status" placeholder="请选择处理状态">
            <el-option label="处理中" value="PROCESSING" />
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="已拒绝" value="REJECTED" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showProcessDialog = false">取消</el-button>
        <el-button type="primary" @click="handleProcessSubmit" :loading="processing">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

// 表格数据
const tableData = ref([])
const loading = ref(false)

// 搜索表单
const searchForm = reactive({
  recordNo: '',
  type: '',
  status: ''
})

// 分页
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

// 对话框
const showAddDialog = ref(false)
const showProcessDialog = ref(false)
const dialogTitle = ref('提交申请')
const submitting = ref(false)
const processing = ref(false)

// 表单
const formRef = ref<FormInstance>()
const form = reactive({
  itemId: null as number | null,
  type: 'REPAIR',
  reason: '',
  remark: ''
})

// 处理表单
const processFormRef = ref<FormInstance>()
const processForm = reactive({
  handleResult: '',
  status: 'PROCESSING'
})

// 当前处理的记录
const currentRecord = ref<any>(null)

// 表单验证规则
const rules: FormRules = {
  itemId: [
    { required: true, message: '请输入物品ID', trigger: 'blur' }
  ],
  type: [
    { required: true, message: '请选择类型', trigger: 'change' }
  ],
  reason: [
    { required: true, message: '请输入原因', trigger: 'blur' }
  ]
}

// 处理表单验证规则
const processRules: FormRules = {
  handleResult: [
    { required: true, message: '请输入处理结果', trigger: 'blur' }
  ],
  status: [
    { required: true, message: '请选择处理状态', trigger: 'change' }
  ]
}

// 获取状态文本
const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    'PENDING': '待处理',
    'PROCESSING': '处理中',
    'COMPLETED': '已完成',
    'REJECTED': '已拒绝'
  }
  return statusMap[status] || status
}

// 获取状态标签样式
const getStatusTag = (status: string) => {
  const statusMap: Record<string, string> = {
    'PENDING': 'warning',
    'PROCESSING': 'primary',
    'COMPLETED': 'success',
    'REJECTED': 'danger'
  }
  return statusMap[status] || ''
}

// 获取记录列表
const fetchRecords = async () => {
  loading.value = true
  try {
    const params = {
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize,
      recordNo: searchForm.recordNo || undefined,
      type: searchForm.type || undefined,
      status: searchForm.status || undefined
    }
    
    // 模拟API调用
    setTimeout(() => {
      tableData.value = [
        {
          recordId: 1,
          recordNo: 'REPAIR20230115120000',
          itemId: 1,
          type: 'REPAIR',
          reason: '设备损坏，需要维修',
          reporterId: 2,
          handlerId: null,
          status: 'PENDING',
          handleResult: '',
          handleTime: null,
          remark: '紧急维修',
          createTime: '2023-01-15 12:00:00'
        }
      ]
      pagination.total = 1
      loading.value = false
    }, 500)
  } catch (error) {
    ElMessage.error('获取记录失败')
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.pageNum = 1
  fetchRecords()
}

// 重置
const handleReset = () => {
  searchForm.recordNo = ''
  searchForm.type = ''
  searchForm.status = ''
  handleSearch()
}

// 分页大小改变
const handleSizeChange = (size: number) => {
  pagination.pageSize = size
  fetchRecords()
}

// 当前页改变
const handleCurrentChange = (page: number) => {
  pagination.pageNum = page
  fetchRecords()
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true
      try {
        ElMessage.success('申请提交成功')
        showAddDialog.value = false
        resetForm()
        fetchRecords()
      } catch (error) {
        ElMessage.error('提交申请失败')
      } finally {
        submitting.value = false
      }
    }
  })
}

// 查看详情
const handleView = (row: any) => {
  ElMessage.info(`查看记录：${row.recordNo}`)
}

// 处理申请
const handleProcess = (row: any) => {
  currentRecord.value = row
  processForm.handleResult = ''
  processForm.status = 'PROCESSING'
  showProcessDialog.value = true
}

// 提交处理
const handleProcessSubmit = async () => {
  if (!processFormRef.value) return
  
  await processFormRef.value.validate(async (valid) => {
    if (valid) {
      processing.value = true
      try {
        ElMessage.success('处理成功')
        showProcessDialog.value = false
        fetchRecords()
      } catch (error) {
        ElMessage.error('处理失败')
      } finally {
        processing.value = false
      }
    }
  })
}

// 重置表单
const resetForm = () => {
  form.itemId = null
  form.type = 'REPAIR'
  form.reason = ''
  form.remark = ''
  formRef.value?.resetFields()
}

// 页面加载时获取数据
onMounted(() => {
  fetchRecords()
})
</script>

<style scoped lang="scss">
.repair-list {
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
}
</style>