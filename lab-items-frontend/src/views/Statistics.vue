<template>
  <div class="statistics">
    <el-card>
      <template #header>
        <div class="card-header">
          <h2>数据统计分析</h2>
          <el-button type="primary" @click="refreshData">刷新数据</el-button>
        </div>
      </template>

      <!-- 统计卡片 -->
      <el-row :gutter="20" class="stats-cards">
        <el-col :span="6">
          <el-card class="stat-card">
            <el-statistic title="物品总数" :value="statistics.totalItems">
              <template #prefix>📦</template>
            </el-statistic>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <el-statistic title="本月入库" :value="statistics.monthlyInbound">
              <template #prefix>📥</template>
            </el-statistic>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <el-statistic title="本月出库" :value="statistics.monthlyOutbound">
              <template #prefix>📤</template>
            </el-statistic>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="stat-card">
            <el-statistic title="借用次数" :value="statistics.borrowCount">
              <template #prefix>📋</template>
            </el-statistic>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="20" class="stats-cards" style="margin-top: 20px">
        <el-col :span="8">
          <el-card class="stat-card">
            <el-statistic title="维修次数" :value="statistics.repairCount">
              <template #prefix>🔧</template>
            </el-statistic>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="stat-card">
            <el-statistic title="报废数量" :value="statistics.scrapCount">
              <template #prefix>⚠️</template>
            </el-statistic>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="stat-card">
            <el-statistic title="库存预警" :value="statistics.alertCount">
              <template #prefix>🔔</template>
            </el-statistic>
          </el-card>
        </el-col>
      </el-row>

      <!-- 图表区域 -->
      <el-divider content-position="left">📊 库存趋势分析</el-divider>
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card>
            <div ref="inboundChart" style="width: 100%; height: 300px"></div>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card>
            <div ref="outboundChart" style="width: 100%; height: 300px"></div>
          </el-card>
        </el-col>
      </el-row>

      <el-divider content-position="left">📊 分类统计</el-divider>
      <el-row :gutter="20">
        <el-col :span="12">
          <el-card>
            <div ref="categoryChart" style="width: 100%; height: 350px"></div>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card>
            <div ref="statusChart" style="width: 100%; height: 350px"></div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 数据表格 -->
      <el-divider content-position="left">📋 物品使用排行</el-divider>
      <el-table :data="topItems" style="width: 100%" v-loading="loading">
        <el-table-column type="index" label="排名" width="80" />
        <el-table-column prop="itemName" label="物品名称" width="200" />
        <el-table-column prop="itemCode" label="物品编号" width="150" />
        <el-table-column prop="borrowCount" label="借用次数" width="120" sortable />
        <el-table-column prop="lastBorrowDate" label="最后借用时间" width="180" />
        <el-table-column prop="category" label="类别" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'

// 统计数据
const statistics = reactive({
  totalItems: 1256,
  monthlyInbound: 89,
  monthlyOutbound: 67,
  borrowCount: 234,
  repairCount: 23,
  scrapCount: 12,
  alertCount: 5
})

// 物品排行数据
const topItems = ref([
  { itemName: '烧杯', itemCode: 'ITEM001', borrowCount: 45, lastBorrowDate: '2023-01-15 10:30', category: '实验设备' },
  { itemName: '试管', itemCode: 'ITEM002', borrowCount: 38, lastBorrowDate: '2023-01-14 14:20', category: '实验设备' },
  { itemName: '显微镜', itemCode: 'ITEM003', borrowCount: 32, lastBorrowDate: '2023-01-13 09:15', category: '实验设备' },
  { itemName: '电脑', itemCode: 'ITEM004', borrowCount: 28, lastBorrowDate: '2023-01-12 16:45', category: '办公设备' },
  { itemName: '打印机', itemCode: 'ITEM005', borrowCount: 25, lastBorrowDate: '2023-01-11 11:00', category: '办公设备' }
])

const loading = ref(false)

// 图表实例
let inboundChartInstance: echarts.ECharts | null = null
let outboundChartInstance: echarts.ECharts | null = null
let categoryChartInstance: echarts.ECharts | null = null
let statusChartInstance: echarts.ECharts | null = null

// 图表DOM引用
const inboundChart = ref<HTMLElement>()
const outboundChart = ref<HTMLElement>()
const categoryChart = ref<HTMLElement>()
const statusChart = ref<HTMLElement>()

// 初始化入库趋势图表
const initInboundChart = () => {
  if (inboundChart.value) {
    inboundChartInstance = echarts.init(inboundChart.value)
    const option = {
      title: { text: '入库趋势' },
      tooltip: { trigger: 'axis' },
      legend: { data: ['入库数量'] },
      xAxis: {
        type: 'category',
        data: ['1月', '2月', '3月', '4月', '5月', '6月']
      },
      yAxis: {
        type: 'value',
        name: '数量'
      },
      series: [{
        name: '入库数量',
        type: 'line',
        data: [120, 132, 101, 134, 90, 89],
        smooth: true,
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(58, 77, 233, 0.5)' },
            { offset: 1, color: 'rgba(58, 77, 233, 0.1)' }
          ])
        }
      }]
    }
    inboundChartInstance.setOption(option)
  }
}

// 初始化出库趋势图表
const initOutboundChart = () => {
  if (outboundChart.value) {
    outboundChartInstance = echarts.init(outboundChart.value)
    const option = {
      title: { text: '出库趋势' },
      tooltip: { trigger: 'axis' },
      legend: { data: ['出库数量'] },
      xAxis: {
        type: 'category',
        data: ['1月', '2月', '3月', '4月', '5月', '6月']
      },
      yAxis: {
        type: 'value',
        name: '数量'
      },
      series: [{
        name: '出库数量',
        type: 'bar',
        data: [85, 92, 78, 105, 87, 67],
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: '#83bff6' },
            { offset: 0.5, color: '#188df0' },
            { offset: 1, color: '#188df0' }
          ])
        }
      }]
    }
    outboundChartInstance.setOption(option)
  }
}

// 初始化分类统计图表
const initCategoryChart = () => {
  if (categoryChart.value) {
    categoryChartInstance = echarts.init(categoryChart.value)
    const option = {
      title: { text: '物品分类统计' },
      tooltip: { trigger: 'item' },
      legend: { orient: 'vertical', left: 'left' },
      series: [{
        name: '物品分类',
        type: 'pie',
        radius: '50%',
        data: [
          { value: 456, name: '实验设备' },
          { value: 321, name: '办公设备' },
          { value: 289, name: '耗材' },
          { value: 190, name: '工具' }
        ],
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }]
    }
    categoryChartInstance.setOption(option)
  }
}

// 初始化状态统计图表
const initStatusChart = () => {
  if (statusChart.value) {
    statusChartInstance = echarts.init(statusChart.value)
    const option = {
      title: { text: '物品状态分布' },
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      legend: {},
      xAxis: {
        type: 'category',
        data: ['可用', '借用中', '维修中', '报废', '丢失']
      },
      yAxis: {
        type: 'value',
        name: '数量'
      },
      series: [{
        name: '数量',
        type: 'bar',
        data: [856, 234, 45, 12, 9],
        itemStyle: {
          color: function(params: any) {
            const colors = ['#67c23a', '#e6a23c', '#f56c6c', '#909399', '#606266']
            return colors[params.dataIndex]
          }
        }
      }]
    }
    statusChartInstance.setOption(option)
  }
}

// 刷新数据
const refreshData = () => {
  loading.value = true
  try {
    // 模拟API调用
    setTimeout(() => {
      ElMessage.success('数据刷新成功')
      loading.value = false
    }, 500)
  } catch (error) {
    ElMessage.error('数据刷新失败')
    loading.value = false
  }
}

// 窗口大小变化时重新调整图表
const handleResize = () => {
  inboundChartInstance?.resize()
  outboundChartInstance?.resize()
  categoryChartInstance?.resize()
  statusChartInstance?.resize()
}

// 页面加载时初始化
onMounted(() => {
  // 初始化图表
  setTimeout(() => {
    initInboundChart()
    initOutboundChart()
    initCategoryChart()
    initStatusChart()
  }, 100)

  // 监听窗口大小变化
  window.addEventListener('resize', handleResize)
})

// 页面卸载时清理
onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  inboundChartInstance?.dispose()
  outboundChartInstance?.dispose()
  categoryChartInstance?.dispose()
  statusChartInstance?.dispose()
})
</script>

<style scoped lang="scss">
.statistics {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    
    h2 {
      margin: 0;
      font-size: 18px;
    }
  }
  
  .stats-cards {
    .stat-card {
      text-align: center;
      box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
      transition: all 0.3s;
      
      &:hover {
        transform: translateY(-5px);
        box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.15);
      }
    }
  }
}
</style>