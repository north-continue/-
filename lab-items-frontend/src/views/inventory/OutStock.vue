<template>
  <div class="out-stock">
    <el-card>
      <template #header>
        <div class="card-header">
          <h2>出库管理</h2>
          <el-button type="primary" @click="showAddDialog = true">新增出库</el-button>
        </div>
      </template>

      <!-- 搜索表单 -->
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="出库单号">
          <el-input v-model="searchForm.outNo" placeholder="请输入出库单号" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" style="width: 100%" v-loading="loading">
        <el-table-column prop="outNo" label="出库单号" width="180" />
        <el-table-column prop="itemId" label="物品ID" width="100" />
        <el-table-column prop="quantity" label="出库数量" width="100" />
        <el-table-column prop="outType" label="出库类型" width="120">
          <template #default="{ row }">
            <el-tag :type="getOutTypeTag(row.outType)">{{ getOutTypeText(row.outType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="receiverId" label="领用人ID" width="100" />
        <el-table-column prop="operatorId" label="操作人ID" width="100" />
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column prop="remark" label="备注" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
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
        <el-form-item label="出库数量" prop="quantity">
          <el-input-number v-model="form.quantity" :min="1" :max="9999" />
        </el-form-item>
        <el-form-item label="出库类型" prop="outType">
          <el-select v-model="form.outType" placeholder="请选择出库类型">
            <el-option label="借用出库" value="BORROW" />
            <el-option label="领用出库" value="USE" />
            <el-option label="调拨出库" value="TRANSFER" />
            <el-option label="其他出库" value="OTHER" />
          </el-select>
        </el-form-item>
        <el-form-item label="领用人ID">
          <el-input v-model="form.receiverId" placeholder="请输入领用人ID" />
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
  outNo: '',
  itemId: null as number | null
})

// 分页
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

// 对话框
const showAddDialog = ref(false)
const dialogTitle = ref('新增出库')
const submitting = ref(false)

// 表单
const formRef = ref<FormInstance>()
const form = reactive({
  itemId: null as number | null,
  quantity: 1,
  outType: 'USE',
  receiverId: null as number | null,
  remark: ''
})

// 表单验证规则
const rules: FormRules = {
  itemId: [
    { required: true, message: '请输入物品ID', trigger: 'blur' }
  ],
  quantity: [
    { required: true, message: '请输入出库数量', trigger: 'blur' }
  ],
  outType: [
    { required: true, message: '请选择出库类型', trigger: 'change' }
  ]
}

// 获取出库类型文本
const getOutTypeText = (type: string) => {
  const typeMap: Record<string, string> = {
    'BORROW': '借用出库',
    'USE': '领用出库',
    'TRANSFER': '调拨出库',
    'OTHER': '其他出库'
  }
  return typeMap[type] || type
}

// 获取出库类型标签样式
const getOutTypeTag = (type: string) => {
  const typeMap: Record<string, string> = {
    'BORROW': 'warning',
    'USE': 'success',
    'TRANSFER': 'info',
    'OTHER': ''
  }
  return typeMap[type] || ''
}

// 获取出库记录列表
const fetchOutRecords = async () => {
  loading.value = true
  try {
    const params = {
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize,
      outNo: searchForm.outNo || undefined,
      itemId: searchForm.itemId || undefined
    }
    
    // 模拟API调用
    setTimeout(() => {
      tableData.value = [
        {
          recordId: 1,
          outNo: 'OUT20230115120000',
          itemId: 1,
          quantity: 5,
          outType: 'USE',
          receiverId: 2,
          operatorId: 1,
          remark: '测试出库记录',
          createTime: '2023-01-15 12:00:00'
        }
      ]
      pagination.total = 1
      loading.value = false
    }, 500)
  } catch (error) {
    ElMessage.error('获取出库记录失败')
    loading.value = false
  }
}

// 搜索
const handleSearch = () => {
  pagination.pageNum = 1
  fetchOutRecords()
}

// 重置
const handleReset = () => {
  searchForm.outNo = ''
  searchForm.itemId = null
  handleSearch()
}

// 分页大小改变
const handleSizeChange = (size: number) => {
  pagination.pageSize = size
  fetchOutRecords()
}

// 当前页改变
const handleCurrentChange = (page: number) => {
  pagination.pageNum = page
  fetchOutRecords()
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true
      try {
        ElMessage.success('出库记录创建成功')
        showAddDialog.value = false
        resetForm()
        fetchOutRecords()
      } catch (error) {
        ElMessage.error('创建出库记录失败')
      } finally {
        submitting.value = false
      }
    }
  })
}

// 查看详情
const handleView = (row: any) => {
  ElMessage.info(`查看出库记录：${row.outNo}`)
}

// 删除记录
const handleDelete = (row: any) => {
  ElMessageBox.confirm(
    `确定要删除出库记录 ${row.outNo} 吗？`,
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('删除成功')
    fetchOutRecords()
  }).catch(() => {
    // 取消删除
  })
}

// 重置表单
const resetForm = () => {
  form.itemId = null
  form.quantity = 1
  form.outType = 'USE'
  form.receiverId = null
  form.remark = ''
  formRef.value?.resetFields()
}

// 页面加载时获取数据
onMounted(() => {
  fetchOutRecords()
})
</script>

<style scoped lang="scss">
.out-stock {
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