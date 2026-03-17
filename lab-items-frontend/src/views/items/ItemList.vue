<template>
  <div class="item-list">
    <el-card>
      <!-- 搜索栏 -->
      <el-form :model="searchForm" inline>
        <el-form-item label="物品名称">
          <el-input v-model="searchForm.itemName" placeholder="请输入物品名称" clearable />
        </el-form-item>
        <el-form-item label="物品状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="可用" value="AVAILABLE" />
            <el-option label="借出中" value="BORROWED" />
            <el-option label="维修中" value="REPAIRING" />
            <el-option label="已报废" value="SCRAPPED" />
            <el-option label="丢失" value="LOST" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button type="success" @click="handleAdd" v-if="canManage">新增物品</el-button>
          <el-button type="warning" @click="handleBatchImport" v-if="canManage">批量导入</el-button>
        </el-form-item>
      </el-form>

      <!-- 表格 -->
      <el-table :data="tableData" v-loading="loading" border stripe>
        <el-table-column prop="itemCode" label="物品编号" width="120" />
        <el-table-column prop="itemName" label="物品名称" min-width="150" />
        <el-table-column prop="specification" label="规格型号" width="120" />
        <el-table-column prop="brand" label="品牌" width="100" />
        <el-table-column prop="unit" label="单位" width="60" />
        <el-table-column prop="availableQuantity" label="可用数量" width="80" />
        <el-table-column prop="totalQuantity" label="总数量" width="80" />
        <el-table-column prop="location" label="存放位置" width="120" />
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleView(row)">详情</el-button>
            <el-button link type="primary" @click="handleEdit(row)" v-if="canManage">编辑</el-button>
            <el-button link type="danger" @click="handleDelete(row)" v-if="canManage">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="pagination.pageNum"
        v-model:page-size="pagination.pageSize"
        :total="pagination.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handlePageChange"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="800px"
      @close="handleDialogClose"
    >
      <el-form :model="formData" :rules="rules" ref="formRef" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="物品名称" prop="itemName">
              <el-input v-model="formData.itemName" placeholder="请输入物品名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="规格型号" prop="specification">
              <el-input v-model="formData.specification" placeholder="请输入规格型号" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="品牌" prop="brand">
              <el-input v-model="formData.brand" placeholder="请输入品牌" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="单位" prop="unit">
              <el-input v-model="formData.unit" placeholder="个/台/件" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="单价" prop="price">
              <el-input-number v-model="formData.price" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="总数量" prop="totalQuantity">
              <el-input-number v-model="formData.totalQuantity" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="存放位置" prop="location">
              <el-input v-model="formData.location" placeholder="请输入存放位置" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="实验室房间号" prop="labRoom">
              <el-input v-model="formData.labRoom" placeholder="请输入房间号" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="formData.remark" type="textarea" :rows="3" placeholder="请输入备注" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { getItemsApi, createItemApi, updateItemApi, deleteItemApi, type Item } from '@/api'

const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
const canManage = computed(() => ['ADMIN', 'LAB_ADMIN'].includes(userInfo.role))

const loading = ref(false)
const tableData = ref<Item[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('')
const submitLoading = ref(false)
const formRef = ref<FormInstance>()

const searchForm = reactive({
  itemName: '',
  status: ''
})

const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const formData = reactive<Partial<Item>>({
  itemName: '',
  specification: '',
  brand: '',
  unit: '',
  price: 0,
  totalQuantity: 0,
  availableQuantity: 0,
  location: '',
  labRoom: '',
  remark: '',
  status: 'AVAILABLE'
})

const rules: FormRules = {
  itemName: [{ required: true, message: '请输入物品名称', trigger: 'blur' }],
  unit: [{ required: true, message: '请输入单位', trigger: 'blur' }],
  location: [{ required: true, message: '请输入存放位置', trigger: 'blur' }]
}

onMounted(() => {
  loadData()
})

const loadData = async () => {
  loading.value = true
  try {
    const res = await getItemsApi({
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize,
      itemName: searchForm.itemName || undefined,
      status: searchForm.status || undefined
    })
    tableData.value = res.data.records
    pagination.total = res.data.total
  } catch (error) {
    console.error('加载数据失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.pageNum = 1
  loadData()
}

const handleReset = () => {
  searchForm.itemName = ''
  searchForm.status = ''
  handleSearch()
}

const handleAdd = () => {
  dialogTitle.value = '新增物品'
  dialogVisible.value = true
}

const handleEdit = (row: Item) => {
  dialogTitle.value = '编辑物品'
  Object.assign(formData, row)
  dialogVisible.value = true
}

const handleView = (row: Item) => {
  // 跳转到详情页
  console.log('查看详情:', row)
}

const handleDelete = async (row: Item) => {
  try {
    await ElMessageBox.confirm('确定要删除该物品吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await deleteItemApi(row.itemId)
    ElMessage.success('删除成功')
    loadData()
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
    }
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true
      try {
        if (formData.itemId) {
          await updateItemApi(formData as Item)
          ElMessage.success('更新成功')
        } else {
          await createItemApi(formData)
          ElMessage.success('创建成功')
        }
        dialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('提交失败:', error)
      } finally {
        submitLoading.value = false
      }
    }
  })
}

const handleDialogClose = () => {
  formRef.value?.resetFields()
  Object.keys(formData).forEach(key => {
    delete formData[key as keyof Item]
  })
}

const handleSizeChange = () => {
  loadData()
}

const handlePageChange = () => {
  loadData()
}

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

const getStatusText = (status: string) => {
  const texts: Record<string, string> = {
    AVAILABLE: '可用',
    BORROWED: '借出',
    REPAIRING: '维修',
    SCRAPPED: '报废',
    LOST: '丢失'
  }
  return texts[status] || status
}
</script>

<style scoped lang="scss">
.item-list {
  .el-card {
    margin-bottom: 20px;
  }
}
</style>
