<template>
  <div class="borrow-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <h2>借用管理</h2>
          <el-button type="primary" @click="showAddDialog = true">申请借用</el-button>
        </div>
      </template>

      <!-- 搜索表单 -->
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="借用单号">
          <el-input v-model="searchForm.borrowNo" placeholder="请输入借用单号" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="待审核" value="PENDING" />
            <el-option label="已批准" value="APPROVED" />
            <el-option label="已拒绝" value="REJECTED" />
            <el-option label="借用中" value="BORROWED" />
            <el-option label="已归还" value="RETURNED" />
            <el-option label="已逾期" value="OVERDUE" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" style="width: 100%" v-loading="loading">
        <el-table-column prop="borrowNo" label="借用单号" width="180" />
        <el-table-column prop="itemId" label="物品ID" width="100" />
        <el-table-column prop="quantity" label="借用数量" width="100" />
        <el-table-column prop="borrowerUserId" label="借用人ID" width="100" />
        <el-table-column prop="borrowDepartment" label="借用部门" width="150" />
        <el-table-column prop="expectedReturnDate" label="预计归还日期" width="120" />
        <el-table-column prop="borrowStatus" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.borrowStatus)">{{ getStatusText(row.borrowStatus) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button 
              v-if="row.borrowStatus === 'BORROWED'" 
              type="success" 
              size="small" 
              @click="handleReturn(row)">
              归还
            </el-button>
            <el-button 
              v-if="row.borrowStatus === 'PENDING'" 
              type="warning" 
              size="small" 
              @click="handleApprove(row)">
              审批
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
      <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
        <el-form-item label="物品ID" prop="itemId">
          <el-input v-model="form.itemId" placeholder="请输入物品ID" />
        </el-form-item>
        <el-form-item label="借用数量" prop="quantity">
          <el-input-number v-model="form.quantity" :min="1" :max="9999" />
        </el-form-item>
        <el-form-item label="借用用途" prop="borrowPurpose">
          <el-input v-model="form.borrowPurpose" placeholder="请输入借用用途" />
        </el-form-item>
        <el-form-item label="预计归还日期" prop="expectedReturnDate">
          <el-date-picker
            v-model="form.expectedReturnDate"
            type="date"
            placeholder="选择日期"
            style="width: 100%"
          />
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
  borrowNo: '',
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
const dialogTitle = ref('申请借用')
const submitting = ref(false)

// 表单
const formRef = ref<FormInstance>()
const form = reactive({
  itemId: null as number | null,
  quantity: 1,
  borrowPurpose: '',
  expectedReturnDate: '',
  remark: ''
})

// 表单验证规则
const rules: FormRules = {
  itemId: [
    { required: true, message: '请输入物品ID', trigger: 'blur' }
  ],
  quantity: [
    { required: true, message: '请输入借用数量', trigger: 'blur' }
  ],
  borrowPurpose: [
    { required: true, message: '请输入借用用途', trigger: 'blur' }
  ]
}

// 获取状态文本
const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    'PENDING': '待审核',
    'APPROVED': '已批准',
    'REJECTED': '已拒绝',
    'BORROWED': '借用中',
    'RETURNED': '已归还',
    'OVERDUE': '已逾期'
  }
  return statusMap[status] || status
}

// 获取状态标签样式
const getStatusTag = (status: string) => {
  const statusMap: Record<string, string> = {
    'PENDING': 'warning',
    'APPROVED': 'info',
    'REJECTED': 'danger',
    'BORROWED': 'primary',
    'RETURNED': 'success',
    'OVERDUE': 'danger'
  }
  return statusMap[status] || ''
}

// 获取借用记录列表
const fetchBorrowRecords = async () => {
  loading.value = true
  try {
    const params = {
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize,
      borrowNo: searchForm.borrowNo || undefined,
      status: searchForm.status || undefined
    }
    
    // 模拟API调用
    setTimeout(() => {
      tableData.value = [
        {
          recordId: 1,
          borrowNo: 'BORROW20230115120000',
          itemId: 1,
          quantity: 2,
          borrowerUserId: 2,
          borrowerDepartment: '计算机学院',
          borrowPurpose: '实验使用',
          expectedReturnDate: '2023-01-20',
          borrowStatus: 'BORROWED',
          createTime: '2023-01-15 12:00:00'
        }
      ]
      pagination.total = 1
      loading.value = false
    }, 500)
  } catch (error) {
    ElMessage.error('获取借用记录失败')
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.pageNum = 1
  fetchBorrowRecords()
}

// 重置
const handleReset = () => {
  searchForm.borrowNo = ''
  searchForm.status = ''
  handleSearch()
}

// 分页大小改变
const handleSizeChange = (size: number) => {
  pagination.pageSize = size
  fetchBorrowRecords()
}

// 当前页改变
const handleCurrentChange = (page: number) => {
  pagination.pageNum = page
  fetchBorrowRecords()
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true
      try {
        ElMessage.success('借用申请提交成功')
        showAddDialog.value = false
        resetForm()
        fetchBorrowRecords()
      } catch (error) {
        ElMessage.error('提交借用申请失败')
      } finally {
        submitting.value = false
      }
    }
  })
}

// 查看详情
const handleView = (row: any) => {
  ElMessage.info(`查看借用记录：${row.borrowNo}`)
}

// 归还物品
const handleReturn = (row: any) => {
  ElMessageBox.confirm(
    `确定要归还借用记录 ${row.borrowNo} 吗？`,
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('归还成功')
    fetchBorrowRecords()
  }).catch(() => {
    // 取消归还
  })
}

// 审批借用
const handleApprove = (row: any) => {
  ElMessageBox.confirm(
    `确定要批准借用记录 ${row.borrowNo} 吗？`,
    '审批',
    {
      confirmButtonText: '批准',
      cancelButtonText: '拒绝',
      distinguishCancelAndClose: true,
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('审批成功')
    fetchBorrowRecords()
  }).catch((action) => {
    if (action === 'cancel') {
      ElMessage.info('已拒绝')
      fetchBorrowRecords()
    }
  })
}

// 重置表单
const resetForm = () => {
  form.itemId = null
  form.quantity = 1
  form.borrowPurpose = ''
  form.expectedReturnDate = ''
  form.remark = ''
  formRef.value?.resetFields()
}

// 页面加载时获取数据
onMounted(() => {
  fetchBorrowRecords()
})
</script>

<style scoped lang="scss">
.borrow-list {
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