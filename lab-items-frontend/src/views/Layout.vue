<template>
  <el-container class="layout-container">
    <!-- 侧边栏 -->
    <el-aside width="220px" class="sidebar">
      <div class="logo">
        <el-icon><Experiment /></el-icon>
        <span>实验室管理平台</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
        router
      >
        <el-menu-item index="/dashboard">
          <el-icon><Odometer /></el-icon>
          <span>工作台</span>
        </el-menu-item>
        <el-menu-item index="/items">
          <el-icon><Box /></el-icon>
          <span>物品管理</span>
        </el-menu-item>
        <el-menu-item index="/inbound">
          <el-icon><Top /></el-icon>
          <span>入库管理</span>
        </el-menu-item>
        <el-menu-item index="/scan-inbound">
          <el-icon><Camera /></el-icon>
          <span>扫码入库</span>
        </el-menu-item>
        <el-menu-item index="/outstock">
          <el-icon><Bottom /></el-icon>
          <span>出库管理</span>
        </el-menu-item>
        <el-menu-item index="/scan-outbound">
          <el-icon><Camera /></el-icon>
          <span>扫码出库</span>
        </el-menu-item>
        <el-menu-item index="/borrow">
          <el-icon><Collection /></el-icon>
          <span>借用管理</span>
        </el-menu-item>
        <el-menu-item index="/repair">
          <el-icon><Tools /></el-icon>
          <span>报废报修</span>
        </el-menu-item>
        <el-menu-item index="/inventory">
          <el-icon><List /></el-icon>
          <span>盘点管理</span>
        </el-menu-item>
        <el-menu-item index="/statistics">
          <el-icon><TrendCharts /></el-icon>
          <span>数据统计</span>
        </el-menu-item>
        <el-menu-item index="/system" v-if="isAdmin">
          <el-icon><Setting /></el-icon>
          <span>系统管理</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <!-- 主体内容 -->
    <el-container>
      <!-- 顶部导航 -->
      <el-header class="header">
        <div class="header-left">
          <el-icon class="collapse-icon" @click="toggleCollapse">
            <Fold v-if="!isCollapse" />
            <Expand v-else />
          </el-icon>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32" :icon="UserFilled" />
              <span class="username">{{ userInfo.realName }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人信息</el-dropdown-item>
                <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- 内容区域 -->
      <el-main class="main-content">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'
import { logoutApi } from '@/api'

const router = useRouter()
const route = useRoute()

const isCollapse = ref(false)
const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')

const activeMenu = computed(() => route.path)
const isAdmin = computed(() => {
  return ['ADMIN', 'LAB_ADMIN'].includes(userInfo.role)
})

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

const handleCommand = async (command: string) => {
  if (command === 'logout') {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    try {
      await logoutApi()
    } catch (error) {
      console.error('登出失败:', error)
    } finally {
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
      ElMessage.success('已退出登录')
      router.push('/login')
    }
  } else if (command === 'profile') {
    ElMessage.info('个人信息功能开发中')
  }
}
</script>

<style scoped lang="scss">
.layout-container {
  height: 100vh;

  .sidebar {
    background-color: #304156;
    
    .logo {
      height: 60px;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
      color: white;
      font-size: 18px;
      font-weight: bold;
    }
  }

  .header {
    background: white;
    border-bottom: 1px solid #e6e6e6;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 20px;

    .header-left {
      .collapse-icon {
        font-size: 20px;
        cursor: pointer;
        transition: all 0.3s;
        
        &:hover {
          color: #409EFF;
        }
      }
    }

    .header-right {
      .user-info {
        display: flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        
        .username {
          margin: 0 5px;
        }
      }
    }
  }

  .main-content {
    background: #f0f2f5;
    padding: 20px;
  }
}
</style>
