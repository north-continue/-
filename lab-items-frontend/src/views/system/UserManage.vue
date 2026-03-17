<template>
  <div class="user-manage">
    <el-card>
      <template #header>
        <div class="card-header">
          <h2>系统管理</h2>
        </div>
      </template>

      <el-tabs v-model="activeTab" type="border-card">
        <!-- 用户管理 -->
        <el-tab-pane label="用户管理" name="users">
          <div class="tab-content">
            <div class="toolbar">
              <el-button type="primary" @click="showUserDialog = true">新增用户</el-button>
              <el-button type="danger" @click="handleBatchDelete">批量删除</el-button>
            </div>

            <!-- 搜索表单 -->
            <el-form :inline="true" :model="userSearchForm" class="search-form">
              <el-form-item label="用户名">
                <el-input v-model="userSearchForm.username" placeholder="请输入用户名" clearable />
              </el-form-item>
              <el-form-item label="角色">
                <el-select v-model="userSearchForm.role" placeholder="请选择角色" clearable>
                  <el-option label="系统管理员" value="ADMIN" />
                  <el-option label="实验室管理员" value="LAB_ADMIN" />
                  <el-option label="教师" value="TEACHER" />
                  <el-option label="学生" value="STUDENT" />
                </el-select>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="searchUsers">搜索</el-button>
                <el-button @click="resetUserSearch">重置</el-button>
              </el-form-item>
            </el-form>

            <!-- 用户表格 -->
            <el-table :data="users" style="width: 100%" v-loading="userLoading" @selection-change="handleUserSelectionChange">
              <el-table-column type="selection" width="55" />
              <el-table-column prop="userId" label="用户ID" width="100" />
              <el-table-column prop="username" label="用户名" width="120" />
              <el-table-column prop="realName" label="真实姓名" width="120" />
              <el-table-column prop="email" label="邮箱" width="180" />
              <el-table-column prop="phone" label="手机号" width="120" />
              <el-table-column prop="role" label="角色" width="120">
                <template #default="{ row }">
                  <el-tag :type="getRoleTag(row.role)">{{ getRoleText(row.role) }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="department" label="部门" width="150" />
              <el-table-column prop="status" label="状态" width="80">
                <template #default="{ row }">
                  <el-tag :type="row.status === 1 ? 'success' : 'danger'">
                    {{ row.status === 1 ? '启用' : '禁用' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="lastLoginTime" label="最后登录时间" width="180" />
              <el-table-column label="操作" width="200" fixed="right">
                <template #default="{ row }">
                  <el-button type="primary" size="small" @click="editUser(row)">编辑</el-button>
                  <el-button type="warning" size="small" @click="resetPassword(row)">重置密码</el-button>
                  <el-button type="danger" size="small" @click="deleteUser(row)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>

            <!-- 分页 -->
            <el-pagination
              v-model:current-page="userPagination.pageNum"
              v-model:page-size="userPagination.pageSize"
              :page-sizes="[10, 20, 50, 100]"
              :total="userPagination.total"
              layout="total, sizes, prev, pager, next, jumper"
              @size-change="handleUserSizeChange"
              @current-change="handleUserCurrentChange"
              style="margin-top: 20px; justify-content: flex-end"
            />
          </div>
        </el-tab-pane>

        <!-- 角色管理 -->
        <el-tab-pane label="角色管理" name="roles">
          <div class="tab-content">
            <div class="role-cards">
              <el-row :gutter="20">
                <el-col :span="6" v-for="role in roles" :key="role.code">
                  <el-card class="role-card">
                    <div class="role-icon">{{ role.icon }}</div>
                    <h3>{{ role.name }}</h3>
                    <p>{{ role.description }}</p>
                    <div class="role-permissions">
                      <el-tag v-for="perm in role.permissions" :key="perm" size="small" style="margin: 2px">
                        {{ perm }}
                      </el-tag>
                    </div>
                  </el-card>
                </el-col>
              </el-row>
            </div>
          </div>
        </el-tab-pane>

        <!-- 操作日志 -->
        <el-tab-pane label="操作日志" name="logs">
          <div class="tab-content">
            <el-form :inline="true" :model="logSearchForm" class="search-form">
              <el-form-item label="操作人">
                <el-input v-model="logSearchForm.username" placeholder="请输入操作人" clearable />
              </el-form-item>
              <el-form-item label="操作类型">
                <el-select v-model="logSearchForm.operation" placeholder="请选择操作类型" clearable>
                  <el-option label="新增" value="CREATE" />
                  <el-option label="修改" value="UPDATE" />
                  <el-option label="删除" value="DELETE" />
                  <el-option label="查询" value="QUERY" />
                </el-select>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="searchLogs">搜索</el-button>
                <el-button @click="resetLogSearch">重置</el-button>
              </el-form-item>
            </el-form>

            <el-table :data="logs" style="width: 100%" v-loading="logLoading">
              <el-table-column prop="logId" label="日志ID" width="100" />
              <el-table-column prop="username" label="操作人" width="120" />
              <el-table-column prop="operation" label="操作类型" width="100" />
              <el-table-column prop="method" label="请求方法" width="200" />
              <el-table-column prop="ip" label="IP地址" width="120" />
              <el-table-column prop="status" label="状态" width="80">
                <template #default="{ row }">
                  <el-tag :type="row.status === 1 ? 'success' : 'danger'">
                    {{ row.status === 1 ? '成功' : '失败' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="createTime" label="创建时间" width="180" />
              <el-table-column label="操作" width="100">
                <template #default="{ row }">
                  <el-button type="primary" size="small" @click="viewLogDetail(row)">详情</el-button>
                </template>
              </el-table-column>
            </el-table>

            <el-pagination
              v-model:current-page="logPagination.pageNum"
              v-model:page-size="logPagination.pageSize"
              :page-sizes="[10, 20, 50, 100]"
              :total="logPagination.total"
              layout="total, sizes, prev, pager, next, jumper"
              @size-change="handleLogSizeChange"
              @current-change="handleLogCurrentChange"
              style="margin-top: 20px; justify-content: flex-end"
            />
          </div>
        </el-tab-pane>

        <!-- 系统配置 -->
        <el-tab-pane label="系统配置" name="config">
          <div class="tab-content">
            <el-form :model="systemConfig" :rules="configRules" ref="configFormRef" label-width="150px">
              <el-divider content-position="left">借用配置</el-divider>
              <el-form-item label="借用最大天数" prop="maxBorrowDays">
                <el-input-number v-model="systemConfig.maxBorrowDays" :min="1" :max="365" />
              </el-form-item>
              <el-form-item label="每人借用上限" prop="maxBorrowPerUser">
                <el-input-number v-model="systemConfig.maxBorrowPerUser" :min="1" :max="100" />
              </el-form-item>
              <el-form-item label="逾期提醒天数" prop="overdueRemindDays">
                <el-input-number v-model="systemConfig.overdueRemindDays" :min="1" :max="30" />
              </el-form-item>

              <el-divider content-position="left">库存预警配置</el-divider>
              <el-form-item label="最低库存预警" prop="minStockAlert">
                <el-input-number v-model="systemConfig.minStockAlert" :min="0" :max="1000" />
              </el-form-item>
              <el-form-item label="预警通知方式" prop="alertMethods">
                <el-checkbox-group v-model="systemConfig.alertMethods">
                  <el-checkbox label="email">邮件通知</el-checkbox>
                  <el-checkbox label="sms">短信通知</el-checkbox>
                  <el-checkbox label="system">系统消息</el-checkbox>
                </el-checkbox-group>
              </el-form-item>

              <el-divider content-position="left">系统设置</el-divider>
              <el-form-item label="系统名称" prop="systemName">
                <el-input v-model="systemConfig.systemName" placeholder="请输入系统名称" />
              </el-form-item>
              <el-form-item label="系统描述" prop="systemDescription">
                <el-input v-model="systemConfig.systemDescription" type="textarea" :rows="3" />
              </el-form-item>

              <el-form-item>
                <el-button type="primary" @click="saveConfig">保存配置</el-button>
                <el-button @click="resetConfig">重置默认</el-button>
              </el-form-item>
            </el-form>
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <!-- 用户对话框 -->
    <el-dialog v-model="showUserDialog" :title="userDialogTitle" width="600px">
      <el-form :model="userForm" :rules="userRules" ref="userFormRef" label-width="100px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="userForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!isEditUser">
          <el-input v-model="userForm.password" type="password" placeholder="请输入密码" />
        </el-form-item>
        <el-form-item label="真实姓名" prop="realName">
          <el-input v-model="userForm.realName" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="userForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="userForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="userForm.role" placeholder="请选择角色">
            <el-option label="系统管理员" value="ADMIN" />
            <el-option label="实验室管理员" value="LAB_ADMIN" />
            <el-option label="教师" value="TEACHER" />
            <el-option label="学生" value="STUDENT" />
          </el-select>
        </el-form-item>
        <el-form-item label="部门" prop="department">
          <el-input v-model="userForm.department" placeholder="请输入部门" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="userForm.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showUserDialog = false">取消</el-button>
        <el-button type="primary" @click="handleUserSubmit" :loading="userSubmitting">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

// 当前激活的标签页
const activeTab = ref('users')

// 用户管理相关
const users = ref([])
const userLoading = ref(false)
const userSearchForm = reactive({
  username: '',
  role: ''
})
const userPagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})
const selectedUsers = ref([])
const showUserDialog = ref(false)
const userDialogTitle = ref('新增用户')
const isEditUser = ref(false)
const userSubmitting = ref(false)

const userFormRef = ref<FormInstance>()
const userForm = reactive({
  userId: null as number | null,
  username: '',
  password: '',
  realName: '',
  email: '',
  phone: '',
  role: 'STUDENT',
  department: '',
  status: 1
})

const userRules: FormRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能小于6位', trigger: 'blur' }
  ],
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ]
}

// 角色管理相关
const roles = [
  {
    code: 'ADMIN',
    name: '系统管理员',
    description: '拥有系统所有权限，可以管理所有功能和数据',
    icon: '👑',
    permissions: ['用户管理', '角色管理', '系统配置', '数据管理', '日志查看']
  },
  {
    code: 'LAB_ADMIN',
    name: '实验室管理员',
    description: '负责实验室物品的日常管理工作',
    icon: '🔑',
    permissions: ['物品管理', '入库管理', '出库管理', '借用审批', '报废报修']
  },
  {
    code: 'TEACHER',
    name: '教师',
    description: '可以申请借用物品，查看相关信息',
    icon: '👨‍🏫',
    permissions: ['物品查询', '借用申请', '归还操作', '报修申请']
  },
  {
    code: 'STUDENT',
    name: '学生',
    description: '可以查询物品信息，申请借用',
    icon: '👨‍🎓',
    permissions: ['物品查询', '借用申请', '归还操作']
  }
]

// 操作日志相关
const logs = ref([])
const logLoading = ref(false)
const logSearchForm = reactive({
  username: '',
  operation: ''
})
const logPagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

// 系统配置相关
const configFormRef = ref<FormInstance>()
const systemConfig = reactive({
  maxBorrowDays: 30,
  maxBorrowPerUser: 10,
  overdueRemindDays: 7,
  minStockAlert: 5,
  alertMethods: ['system'],
  systemName: '实验室物品管理平台',
  systemDescription: '基于Web的实验室物品全生命周期管理系统'
})

const configRules: FormRules = {
  maxBorrowDays: [
    { required: true, message: '请输入借用最大天数', trigger: 'blur' }
  ],
  maxBorrowPerUser: [
    { required: true, message: '请输入每人借用上限', trigger: 'blur' }
  ],
  minStockAlert: [
    { required: true, message: '请输入最低库存预警', trigger: 'blur' }
  ],
  systemName: [
    { required: true, message: '请输入系统名称', trigger: 'blur' }
  ]
}

// 获取角色文本
const getRoleText = (role: string) => {
  const roleMap: Record<string, string> = {
    'ADMIN': '系统管理员',
    'LAB_ADMIN': '实验室管理员',
    'TEACHER': '教师',
    'STUDENT': '学生'
  }
  return roleMap[role] || role
}

// 获取角色标签样式
const getRoleTag = (role: string) => {
  const roleMap: Record<string, string> = {
    'ADMIN': 'danger',
    'LAB_ADMIN': 'warning',
    'TEACHER': 'primary',
    'STUDENT': 'info'
  }
  return roleMap[role] || ''
}

// 搜索用户
const searchUsers = () => {
  userPagination.pageNum = 1
  fetchUsers()
}

// 重置用户搜索
const resetUserSearch = () => {
  userSearchForm.username = ''
  userSearchForm.role = ''
  searchUsers()
}

// 获取用户列表
const fetchUsers = async () => {
  userLoading.value = true
  try {
    // 模拟API调用
    setTimeout(() => {
      users.value = [
        {
          userId: 1,
          username: 'admin',
          realName: '管理员',
          email: 'admin@lab.com',
          phone: '13800138000',
          role: 'ADMIN',
          department: '信息中心',
          status: 1,
          lastLoginTime: '2023-01-15 10:30:00'
        },
        {
          userId: 2,
          username: 'labadmin',
          realName: '实验室管理员',
          email: 'labadmin@lab.com',
          phone: '13800138001',
          role: 'LAB_ADMIN',
          department: '实验中心',
          status: 1,
          lastLoginTime: '2023-01-15 09:15:00'
        }
      ]
      userPagination.total = 2
      userLoading.value = false
    }, 500)
  } catch (error) {
    ElMessage.error('获取用户列表失败')
    userLoading.value = false
  }
}

// 用户选择变化
const handleUserSelectionChange = (selection: any[]) => {
  selectedUsers.value = selection
}

// 编辑用户
const editUser = (row: any) => {
  isEditUser.value = true
  userDialogTitle.value = '编辑用户'
  Object.assign(userForm, row)
  showUserDialog.value = true
}

// 删除用户
const deleteUser = (row: any) => {
  ElMessageBox.confirm(
    `确定要删除用户 ${row.username} 吗？`,
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('删除成功')
    fetchUsers()
  }).catch(() => {
    // 取消删除
  })
}

// 批量删除
const handleBatchDelete = () => {
  if (selectedUsers.value.length === 0) {
    ElMessage.warning('请选择要删除的用户')
    return
  }
  
  ElMessageBox.confirm(
    `确定要删除选中的 ${selectedUsers.value.length} 个用户吗？`,
    '批量删除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('批量删除成功')
    fetchUsers()
  }).catch(() => {
    // 取消删除
  })
}

// 重置密码
const resetPassword = (row: any) => {
  ElMessageBox.confirm(
    `确定要重置用户 ${row.username} 的密码吗？`,
    '重置密码',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('密码重置成功，新密码为：123456')
  }).catch(() => {
    // 取消重置
  })
}

// 提交用户表单
const handleUserSubmit = async () => {
  if (!userFormRef.value) return
  
  await userFormRef.value.validate(async (valid) => {
    if (valid) {
      userSubmitting.value = true
      try {
        ElMessage.success(isEditUser.value ? '用户更新成功' : '用户创建成功')
        showUserDialog.value = false
        resetUserForm()
        fetchUsers()
      } catch (error) {
        ElMessage.error(isEditUser.value ? '用户更新失败' : '用户创建失败')
      } finally {
        userSubmitting.value = false
      }
    }
  })
}

// 重置用户表单
const resetUserForm = () => {
  userForm.userId = null
  userForm.username = ''
  userForm.password = ''
  userForm.realName = ''
  userForm.email = ''
  userForm.phone = ''
  userForm.role = 'STUDENT'
  userForm.department = ''
  userForm.status = 1
  isEditUser.value = false
  userDialogTitle.value = '新增用户'
  userFormRef.value?.resetFields()
}

// 搜索日志
const searchLogs = () => {
  logPagination.pageNum = 1
  fetchLogs()
}

// 重置日志搜索
const resetLogSearch = () => {
  logSearchForm.username = ''
  logSearchForm.operation = ''
  searchLogs()
}

// 获取日志列表
const fetchLogs = async () => {
  logLoading.value = true
  try {
    // 模拟API调用
    setTimeout(() => {
      logs.value = [
        {
          logId: 1,
          username: 'admin',
          operation: 'CREATE',
          method: 'POST /api/items',
          ip: '192.168.1.100',
          status: 1,
          createTime: '2023-01-15 10:30:00'
        },
        {
          logId: 2,
          username: 'labadmin',
          operation: 'UPDATE',
          method: 'PUT /api/items/1',
          ip: '192.168.1.101',
          status: 1,
          createTime: '2023-01-15 09:15:00'
        }
      ]
      logPagination.total = 2
      logLoading.value = false
    }, 500)
  } catch (error) {
    ElMessage.error('获取日志列表失败')
    logLoading.value = false
  }
}

// 查看日志详情
const viewLogDetail = (row: any) => {
  ElMessage.info(`查看日志详情：${row.logId}`)
}

// 用户分页
const handleUserSizeChange = (size: number) => {
  userPagination.pageSize = size
  fetchUsers()
}

const handleUserCurrentChange = (page: number) => {
  userPagination.pageNum = page
  fetchUsers()
}

// 日志分页
const handleLogSizeChange = (size: number) => {
  logPagination.pageSize = size
  fetchLogs()
}

const handleLogCurrentChange = (page: number) => {
  logPagination.pageNum = page
  fetchLogs()
}

// 保存配置
const saveConfig = async () => {
  if (!configFormRef.value) return
  
  await configFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        ElMessage.success('系统配置保存成功')
      } catch (error) {
        ElMessage.error('系统配置保存失败')
      }
    }
  })
}

// 重置配置
const resetConfig = () => {
  systemConfig.maxBorrowDays = 30
  systemConfig.maxBorrowPerUser = 10
  systemConfig.overdueRemindDays = 7
  systemConfig.minStockAlert = 5
  systemConfig.alertMethods = ['system']
  systemConfig.systemName = '实验室物品管理平台'
  systemConfig.systemDescription = '基于Web的实验室物品全生命周期管理系统'
  configFormRef.value?.resetFields()
}

// 页面加载时获取数据
onMounted(() => {
  fetchUsers()
  fetchLogs()
})
</script>

<style scoped lang="scss">
.user-manage {
  .card-header {
    h2 {
      margin: 0;
      font-size: 18px;
    }
  }
  
  .tab-content {
    padding: 20px;
  }
  
  .toolbar {
    margin-bottom: 20px;
  }
  
  .search-form {
    margin-bottom: 20px;
  }
  
  .role-cards {
    .role-card {
      text-align: center;
      margin-bottom: 20px;
      transition: all 0.3s;
      
      &:hover {
        transform: translateY(-5px);
        box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.15);
      }
      
      .role-icon {
        font-size: 48px;
        margin-bottom: 10px;
      }
      
      h3 {
        margin: 10px 0;
        font-size: 16px;
      }
      
      p {
        color: #666;
        margin-bottom: 15px;
        font-size: 14px;
      }
      
      .role-permissions {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        gap: 5px;
      }
    }
  }
}
</style>