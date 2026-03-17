<template>
  <div class="dashboard">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stat-cards">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #409EFF">
              <el-icon><Box /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalItems }}</div>
              <div class="stat-label">物品总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #67C23A">
              <el-icon><CircleCheck /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.availableItems }}</div>
              <div class="stat-label">可用物品</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #E6A23C">
              <el-icon><Collection /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.borrowedItems }}</div>
              <div class="stat-label">借出物品</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background: #F56C6C">
              <el-icon><WarningFilled /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.alertItems }}</div>
              <div class="stat-label">预警物品</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>物品分类统计</span>
            </div>
          </template>
          <div ref="categoryChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>借用状态分布</span>
            </div>
          </template>
          <div ref="statusChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 最新动态 -->
    <el-card style="margin-top: 20px">
      <template #header>
        <div class="card-header">
          <span>最新动态</span>
        </div>
      </template>
      <el-table :data="recentActivities" stripe>
        <el-table-column prop="type" label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getActivityType(row.type)" size="small">
              {{ row.type }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="200" />
        <el-table-column prop="operator" label="操作人" width="100" />
        <el-table-column prop="time" label="时间" width="180" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'
import type { ECharts } from 'echarts'

const stats = ref({
  totalItems: 0,
  availableItems: 0,
  borrowedItems: 0,
  alertItems: 0
})

const categoryChartRef = ref<HTMLElement>()
const statusChartRef = ref<HTMLElement>()
let categoryChart: ECharts | null = null
let statusChart: ECharts | null = null

const recentActivities = ref([
  { type: '入库', description: '笔记本电脑 10 台入库', operator: '管理员', time: '2024-01-15 10:30:00' },
  { type: '借用', description: '张三 借用 万用表', operator: '张老师', time: '2024-01-15 09:20:00' },
  { type: '归还', description: '李四 归还 示波器', operator: '李老师', time: '2024-01-14 16:45:00' },
  { type: '报修', description: '投影仪 故障报修', operator: '王老师', time: '2024-01-14 14:20:00' }
])

onMounted(() => {
  loadStats()
  initCharts()
})

const loadStats = () => {
  // 模拟数据，实际应从 API 获取
  stats.value = {
    totalItems: 1256,
    availableItems: 892,
    borrowedItems: 234,
    alertItems: 15
  }
}

const initCharts = () => {
  // 分类统计图
  if (categoryChartRef.value) {
    categoryChart = echarts.init(categoryChartRef.value)
    categoryChart.setOption({
      tooltip: {
        trigger: 'item'
      },
      legend: {
        orient: 'vertical',
        left: 'left'
      },
      series: [
        {
          name: '物品分类',
          type: 'pie',
          radius: '60%',
          data: [
            { value: 348, name: '实验设备' },
            { value: 256, name: '办公设备' },
            { value: 412, name: '耗材' },
            { value: 240, name: '工具' }
          ],
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowOffsetX: 0,
              shadowColor: 'rgba(0, 0, 0, 0.5)'
            }
          }
        }
      ]
    })
  }

  // 状态分布图
  if (statusChartRef.value) {
    statusChart = echarts.init(statusChartRef.value)
    statusChart.setOption({
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      xAxis: {
        type: 'category',
        data: ['可用', '借出', '维修', '报废', '丢失']
      },
      yAxis: {
        type: 'value'
      },
      series: [
        {
          name: '数量',
          type: 'bar',
          data: [892, 234, 45, 67, 18],
          itemStyle: {
            color: (params: any) => {
              const colors = ['#67C23A', '#E6A23C', '#F56C6C', '#909399', '#F56C6C']
              return colors[params.dataIndex]
            }
          }
        }
      ]
    })
  }
}

const getActivityType = (type: string) => {
  const types: Record<string, any> = {
    '入库': 'success',
    '出库': 'warning',
    '借用': 'primary',
    '归还': 'success',
    '报修': 'danger',
    '报废': 'info'
  }
  return types[type] || 'info'
}

// 窗口大小改变时重新渲染图表
window.addEventListener('resize', () => {
  categoryChart?.resize()
  statusChart?.resize()
})
</script>

<style scoped lang="scss">
.dashboard {
  .stat-cards {
    .stat-card {
      .stat-content {
        display: flex;
        align-items: center;
        gap: 15px;

        .stat-icon {
          width: 60px;
          height: 60px;
          border-radius: 10px;
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          font-size: 28px;
        }

        .stat-info {
          flex: 1;

          .stat-value {
            font-size: 28px;
            font-weight: bold;
            color: #333;
          }

          .stat-label {
            font-size: 14px;
            color: #999;
            margin-top: 5px;
          }
        }
      }
    }
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-weight: bold;
  }
}
</style>
