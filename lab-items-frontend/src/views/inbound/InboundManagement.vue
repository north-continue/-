<template>
  <div class="inbound-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <h2>入库管理</h2>
          <el-button type="primary" @click="handleAdd">新增入库单</el-button>
        </div>
      </template>

      <!-- 搜索表单 -->
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="入库单号">
          <el-input v-model="searchForm.orderNo" placeholder="请输入入库单号" clearable />
        </el-form-item>
        <el-form-item label="入库类型">
          <el-select v-model="searchForm.orderType" placeholder="请选择入库类型" clearable>
            <el-option label="采购入库" value="PURCHASE" />
            <el-option label="退货入库" value="RETURN" />
            <el-option label="调拨入库" value="TRANSFER" />
            <el-option label="其他入库" value="OTHER" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="草稿" value="DRAFT" />
            <el-option label="待审核" value="PENDING" />
            <el-option label="已审核" value="APPROVED" />
            <el-option label="已完成" value="COMPLETED" />
            <el-option label="已取消" value="CANCELLED" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" border style="width: 100%" v-loading="loading">
        <el-table-column prop="orderNo" label="入库单号" width="180" />
        <el-table-column prop="orderType" label="入库类型" width="120">
          <template #default="{ row }">
            <el-tag v-if="row.orderType === 'PURCHASE'" type="success">采购入库</el-tag>
            <el-tag v-else-if="row.orderType === 'RETURN'" type="warning">退货入库</el-tag>
            <el-tag v-else-if="row.orderType === 'TRANSFER'" type="info">调拨入库</el-tag>
            <el-tag v-else>其他入库</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="supplierName" label="供应商" width="150" />
        <el-table-column prop="warehouseName" label="仓库" width="120" />
        <el-table-column prop="totalQuantity" label="总数量" width="100" align="right" />
        <el-table-column prop="totalAmount" label="总金额" width="120" align="right">
          <template #default="{ row }">
            ¥{{ row.totalAmount?.toFixed(2) || '0.00' }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.status === 'DRAFT'" type="info">草稿</el-tag>
            <el-tag v-else-if="row.status === 'PENDING'" type="warning">待审核</el-tag>
            <el-tag v-else-if="row.status === 'APPROVED'" type="success">已审核</el-tag>
            <el-tag v-else-if="row.status === 'COMPLETED'" type="success">已完成</el-tag>
            <el-tag v-else-if="row.status === 'CANCELLED'" type="info">已取消</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="350" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleView(row)">查看</el-button>
            <el-button v-if="row.status === 'DRAFT'" size="small" type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button v-if="row.status === 'DRAFT'" size="small" type="warning" @click="handleSubmitForApproval(row)">提交审核</el-button>
            <el-button v-if="row.status === 'PENDING'" size="small" type="success" @click="handleApprove(row)">审核</el-button>
            <el-button v-if="row.status === 'APPROVED'" size="small" type="success" @click="handleComplete(row)">完成</el-button>
            <el-button v-if="row.status === 'DRAFT' || row.status === 'PENDING'" size="small" type="danger" @click="handleCancel(row)">取消</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="pagination.pageNum"
          v-model:page-size="pagination.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="showEditDialog"
      :title="editDialogTitle"
      width="80%"
      @close="resetForm"
    >
      <el-form :model="form" :rules="formRules" ref="formRef" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="入库类型" prop="orderType">
              <el-select v-model="form.order.orderType" placeholder="请选择入库类型" style="width: 100%">
                <el-option label="采购入库" value="PURCHASE" />
                <el-option label="退货入库" value="RETURN" />
                <el-option label="调拨入库" value="TRANSFER" />
                <el-option label="其他入库" value="OTHER" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="供应商" prop="supplierId">
              <el-select v-model="form.order.supplierId" placeholder="请选择供应商" style="width: 100%">
                <el-option
                  v-for="supplier in suppliers"
                  :key="supplier.supplierId"
                  :label="supplier.supplierName"
                  :value="supplier.supplierId"
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="仓库" prop="warehouseId">
              <el-select v-model="form.order.warehouseId" placeholder="请选择仓库" style="width: 100%">
                <el-option
                  v-for="warehouse in warehouses"
                  :key="warehouse.warehouseId"
                  :label="warehouse.warehouseName"
                  :value="warehouse.warehouseId"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="预计到货日期" prop="arrivalDate">
              <el-date-picker
                v-model="form.order.arrivalDate"
                type="date"
                placeholder="请选择预计到货日期"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="发票号" prop="invoiceNo">
              <el-input v-model="form.order.invoiceNo" placeholder="请输入发票号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="合同号" prop="contractNo">
              <el-input v-model="form.order.contractNo" placeholder="请输入合同号" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.order.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>

        <!-- 入库明细 -->
        <el-divider>入库明细</el-divider>
        <div class="detail-actions">
          <el-button type="primary" size="small" @click="addDetail">+ 添加明细</el-button>
        </div>
        <el-table :data="form.details" border style="width: 100%; margin-top: 10px">
          <el-table-column label="物品名称" width="200">
            <template #default="{ row }">
              <el-input v-model="row.itemName" placeholder="请输入物品名称" />
            </template>
          </el-table-column>
          <el-table-column label="规格型号" width="150">
            <template #default="{ row }">
              <el-input v-model="row.specification" placeholder="请输入规格型号" />
            </template>
          </el-table-column>
          <el-table-column label="单位" width="100">
            <template #default="{ row }">
              <el-input v-model="row.unit" placeholder="请输入单位" />
            </template>
          </el-table-column>
          <el-table-column label="数量" width="120">
            <template #default="{ row }">
              <el-input-number v-model="row.quantity" :min="1" style="width: 100%" />
            </template>
          </el-table-column>
          <el-table-column label="单价" width="120">
            <template #default="{ row }">
              <el-input-number v-model="row.unitPrice" :min="0" :precision="2" style="width: 100%" />
            </template>
          </el-table-column>
          <el-table-column label="总价" width="120">
            <template #default="{ row }">
              {{ (row.quantity * (row.unitPrice || 0)).toFixed(2) }}
            </template>
          </el-table-column>
          <el-table-column label="批次号" width="150">
            <template #default="{ row }">
              <el-input v-model="row.batchNo" placeholder="请输入批次号" />
            </template>
          </el-table-column>
          <el-table-column label="操作" width="100" fixed="right">
            <template #default="{ $index }">
              <el-button size="small" type="danger" @click="removeDetail($index)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-form>
      <template #footer>
        <el-button @click="showEditDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>

    <!-- 查看详情对话框 -->
    <el-dialog v-model="showViewDialog" title="入库单详情" width="80%">
      <div v-if="currentOrder">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="入库单号">{{ currentOrder.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="入库类型">
            <el-tag v-if="currentOrder.orderType === 'PURCHASE'" type="success">采购入库</el-tag>
            <el-tag v-else-if="currentOrder.orderType === 'RETURN'" type="warning">退货入库</el-tag>
            <el-tag v-else-if="currentOrder.orderType === 'TRANSFER'" type="info">调拨入库</el-tag>
            <el-tag v-else>其他入库</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="供应商">{{ currentOrder.supplierName }}</el-descriptions-item>
          <el-descriptions-item label="仓库">{{ currentOrder.warehouseName }}</el-descriptions-item>
          <el-descriptions-item label="总数量">{{ currentOrder.totalQuantity }}</el-descriptions-item>
          <el-descriptions-item label="总金额">¥{{ currentOrder.totalAmount?.toFixed(2) || '0.00' }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag v-if="currentOrder.status === 'DRAFT'" type="info">草稿</el-tag>
            <el-tag v-else-if="currentOrder.status === 'PENDING'" type="warning">待审核</el-tag>
            <el-tag v-else-if="currentOrder.status === 'APPROVED'" type="success">已审核</el-tag>
            <el-tag v-else-if="currentOrder.status === 'COMPLETED'" type="success">已完成</el-tag>
            <el-tag v-else-if="currentOrder.status === 'CANCELLED'" type="info">已取消</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="创建人">{{ currentOrder.operatorName }}</el-descriptions-item>
          <el-descriptions-item label="预计到货日期">{{ currentOrder.arrivalDate }}</el-descriptions-item>
          <el-descriptions-item label="实际到货日期">{{ currentOrder.actualArrivalDate }}</el-descriptions-item>
          <el-descriptions-item label="发票号">{{ currentOrder.invoiceNo }}</el-descriptions-item>
          <el-descriptions-item label="合同号">{{ currentOrder.contractNo }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ currentOrder.createTime }}</el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ currentOrder.remark }}</el-descriptions-item>
        </el-descriptions>

        <el-divider>入库明细</el-divider>
        <el-table :data="currentDetails" border style="width: 100%">
          <el-table-column prop="itemName" label="物品名称" width="200" />
          <el-table-column prop="specification" label="规格型号" width="150" />
          <el-table-column prop="unit" label="单位" width="100" />
          <el-table-column prop="quantity" label="数量" width="120" align="right" />
          <el-table-column prop="unitPrice" label="单价" width="120" align="right">
            <template #default="{ row }">
              ¥{{ row.unitPrice?.toFixed(2) || '0.00' }}
            </template>
          </el-table-column>
          <el-table-column prop="totalPrice" label="总价" width="120" align="right">
            <template #default="{ row }">
              ¥{{ row.totalPrice?.toFixed(2) || '0.00' }}
            </template>
          </el-table-column>
          <el-table-column prop="batchNo" label="批次号" width="150" />
          <el-table-column prop="remark" label="备注" />
        </el-table>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getPageList,
  getById,
  create,
  update,
  deleteOrder,
  approve,
  complete,
  cancel,
  submitForApproval,
  listSuppliers,
  listWarehouses,
  type InboundOrder,
  type InboundOrderDetail
} from '@/api/inbound'

// 表格数据
const tableData = ref<InboundOrder[]>([])
const loading = ref(false)

// 搜索表单
const searchForm = reactive({
  orderNo: '',
  orderType: '',
  status: '',
  supplierId: null as number | null
})

// 分页
const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

// 编辑对话框
const showEditDialog = ref(false)
const editDialogTitle = computed(() => form.order.orderId ? '编辑入库单' : '新增入库单')
const formRef = ref<FormInstance>()
const submitting = ref(false)

// 表单数据
const form = reactive({
  order: {
    orderType: 'PURCHASE',
    supplierId: undefined as number | undefined,
    warehouseId: undefined as number | undefined,
    arrivalDate: '',
    invoiceNo: '',
    contractNo: '',
    remark: ''
  } as InboundOrder,
  details: [] as InboundOrderDetail[]
})

// 表单验证规则
const formRules: FormRules = {
  orderType: [{ required: true, message: '请选择入库类型', trigger: 'change' }],
  supplierId: [{ required: true, message: '请选择供应商', trigger: 'change' }],
  warehouseId: [{ required: true, message: '请选择仓库', trigger: 'change' }]
}

// 查看详情对话框
const showViewDialog = ref(false)
const currentOrder = ref<InboundOrder | null>(null)
const currentDetails = ref<InboundOrderDetail[]>([])

// 供应商和仓库数据
const suppliers = ref<any[]>([])
const warehouses = ref<any[]>([])

// 获取入库单列表
const fetchOrders = async () => {
  loading.value = true
  try {
    const response = await getPageList(
      pagination.pageNum,
      pagination.pageSize,
      searchForm.orderNo || null,
      searchForm.status || null,
      searchForm.supplierId,
      searchForm.orderType || null
    )

    if (response.code === 200) {
      tableData.value = response.data.records || []
      pagination.total = response.data.total || 0
    } else {
      ElMessage.error(response.message || '获取入库单列表失败')
    }
  } catch (error) {
    console.error('获取入库单列表失败:', error)
    ElMessage.error('获取入库单列表失败，请检查网络连接')
  } finally {
    loading.value = false
  }
}

// 获取供应商列表
const fetchSuppliers = async () => {
  try {
    const response = await listSuppliers()
    if (response.code === 200) {
      suppliers.value = response.data || []
    }
  } catch (error) {
    console.error('获取供应商列表失败:', error)
  }
}

// 获取仓库列表
const fetchWarehouses = async () => {
  try {
    const response = await listWarehouses()
    if (response.code === 200) {
      warehouses.value = response.data || []
    }
  } catch (error) {
    console.error('获取仓库列表失败:', error)
  }
}

// 搜索
const handleSearch = () => {
  pagination.pageNum = 1
  fetchOrders()
}

// 重置
const handleReset = () => {
  searchForm.orderNo = ''
  searchForm.orderType = ''
  searchForm.status = ''
  searchForm.supplierId = null
  handleSearch()
}

// 新增
const handleAdd = () => {
  resetForm()
  showEditDialog.value = true
}

// 编辑
const handleEdit = async (row: InboundOrder) => {
  try {
    const response = await getById(row.orderId!)
    if (response.code === 200) {
      form.order = { ...response.data.order }
      form.details = [...response.data.details]
      showEditDialog.value = true
    }
  } catch (error) {
    console.error('获取入库单详情失败:', error)
    ElMessage.error('获取入库单详情失败')
  }
}

// 查看
const handleView = async (row: InboundOrder) => {
  try {
    const response = await getById(row.orderId!)
    if (response.code === 200) {
      currentOrder.value = response.data.order
      currentDetails.value = response.data.details
      showViewDialog.value = true
    }
  } catch (error) {
    console.error('获取入库单详情失败:', error)
    ElMessage.error('获取入库单详情失败')
  }
}

// 审核
const handleApprove = async (row: InboundOrder) => {
  try {
    await ElMessageBox.confirm('确定要审核通过此入库单吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const response = await approve(row.orderId!, 1, '管理员', true)
    if (response.code === 200) {
      ElMessage.success('审核成功')
      fetchOrders()
    } else {
      ElMessage.error(response.message || '审核失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('审核失败:', error)
      ElMessage.error('审核失败')
    }
  }
}

// 完成
const handleComplete = async (row: InboundOrder) => {
  try {
    await ElMessageBox.confirm('确定要完成此入库单吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const response = await complete(row.orderId!)
    if (response.code === 200) {
      ElMessage.success('完成成功')
      fetchOrders()
    } else {
      ElMessage.error(response.message || '完成失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('完成失败:', error)
      ElMessage.error('完成失败')
    }
  }
}

// 取消
const handleCancel = async (row: InboundOrder) => {
  try {
    await ElMessageBox.confirm('确定要取消此入库单吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const response = await cancel(row.orderId!)
    if (response.code === 200) {
      ElMessage.success('取消成功')
      fetchOrders()
    } else {
      ElMessage.error(response.message || '取消失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('取消失败:', error)
      ElMessage.error('取消失败')
    }
  }
}

// 提交审核
const handleSubmitForApproval = async (row: InboundOrder) => {
  try {
    await ElMessageBox.confirm('确定要提交此入库单进行审核吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const response = await submitForApproval(row.orderId!)
    if (response.code === 200) {
      ElMessage.success('提交审核成功')
      fetchOrders()
    } else {
      ElMessage.error(response.message || '提交审核失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('提交审核失败:', error)
      ElMessage.error('提交审核失败')
    }
  }
}

// 添加明细
const addDetail = () => {
  form.details.push({
    itemId: 0,
    itemName: '',
    specification: '',
    unit: '',
    quantity: 1,
    unitPrice: 0,
    totalPrice: 0,
    batchNo: ''
  })
}

// 删除明细
const removeDetail = (index: number) => {
  form.details.splice(index, 1)
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (valid) {
      if (form.details.length === 0) {
        ElMessage.warning('请至少添加一条入库明细')
        return
      }

      submitting.value = true
      try {
        const response = form.order.orderId
          ? await update(form.order.orderId!, form)
          : await create(form)

        if (response.code === 200) {
          ElMessage.success(form.order.orderId ? '更新成功' : '创建成功')
          showEditDialog.value = false
          resetForm()
          fetchOrders()
        } else {
          ElMessage.error(response.message || '操作失败')
        }
      } catch (error) {
        console.error('操作失败:', error)
        ElMessage.error('操作失败，请检查网络连接')
      } finally {
        submitting.value = false
      }
    }
  })
}

// 重置表单
const resetForm = () => {
  form.order = {
    orderType: 'PURCHASE',
    supplierId: undefined,
    warehouseId: undefined,
    arrivalDate: '',
    invoiceNo: '',
    contractNo: '',
    remark: ''
  }
  form.details = []
  formRef.value?.resetFields()
}

// 分页
const handleSizeChange = (val: number) => {
  pagination.pageSize = val
  fetchOrders()
}

const handleCurrentChange = (val: number) => {
  pagination.pageNum = val
  fetchOrders()
}

// 初始化
onMounted(() => {
  fetchOrders()
  fetchSuppliers()
  fetchWarehouses()
})
</script>

<style scoped>
.inbound-management {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  margin-bottom: 20px;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.detail-actions {
  margin-bottom: 10px;
}
</style>
