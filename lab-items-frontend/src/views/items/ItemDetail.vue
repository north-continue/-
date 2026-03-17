<template>
  <div class="item-detail">
    <el-card>
      <template #header>
        <div class="card-header">
          <el-button @click="$router.back()">
            <el-icon><ArrowLeft /></el-icon>
            返回
          </el-button>
          <span>物品详情</span>
        </div>
      </template>

      <el-descriptions title="基本信息" :column="2" border>
        <el-descriptions-item label="物品编号">ITEM20240115001</el-descriptions-item>
        <el-descriptions-item label="物品名称">笔记本电脑</el-descriptions-item>
        <el-descriptions-item label="规格型号">Dell XPS 15</el-descriptions-item>
        <el-descriptions-item label="品牌">Dell</el-descriptions-item>
        <el-descriptions-item label="单位">台</el-descriptions-item>
        <el-descriptions-item label="单价">¥8,999.00</el-descriptions-item>
        <el-descriptions-item label="总数量">50</el-descriptions-item>
        <el-descriptions-item label="可用数量">35</el-descriptions-item>
        <el-descriptions-item label="借出数量">15</el-descriptions-item>
        <el-descriptions-item label="存放位置">实验楼 301</el-descriptions-item>
        <el-descriptions-item label="房间号">A301</el-descriptions-item>
        <el-descriptions-item label="货架号">H-05</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag type="success">可用</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="购买日期">2023-09-01</el-descriptions-item>
        <el-descriptions-item label="保修期">36 个月</el-descriptions-item>
        <el-descriptions-item label="保修到期">2026-09-01</el-descriptions-item>
      </el-descriptions>

      <el-divider />

      <el-tabs>
        <el-tab-pane label="出入库记录">
          <el-table :data="[]" stripe>
            <el-table-column prop="type" label="类型" width="100" />
            <el-table-column prop="quantity" label="数量" width="80" />
            <el-table-column prop="operator" label="操作人" width="100" />
            <el-table-column prop="time" label="时间" width="180" />
            <el-table-column prop="remark" label="备注" />
          </el-table>
          <el-empty description="暂无记录" />
        </el-tab-pane>
        <el-tab-pane label="借用记录">
          <el-table :data="[]" stripe>
            <el-table-column prop="borrower" label="借用人" width="100" />
            <el-table-column prop="quantity" label="数量" width="80" />
            <el-table-column prop="borrowDate" label="借用日期" width="120" />
            <el-table-column prop="returnDate" label="归还日期" width="120" />
            <el-table-column prop="status" label="状态" width="80" />
          </el-table>
          <el-empty description="暂无记录" />
        </el-tab-pane>
        <el-tab-pane label="维修记录">
          <el-table :data="[]" stripe>
            <el-table-column prop="type" label="类型" width="80" />
            <el-table-column prop="description" label="故障描述" />
            <el-table-column prop="handler" label="处理人" width="100" />
            <el-table-column prop="time" label="时间" width="180" />
            <el-table-column prop="status" label="状态" width="80" />
          </el-table>
          <el-empty description="暂无记录" />
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

onMounted(() => {
  console.log('物品 ID:', route.params.id)
  // TODO: 加载物品详情数据
})
</script>

<style scoped lang="scss">
.item-detail {
  .card-header {
    display: flex;
    align-items: center;
    gap: 15px;
    font-weight: bold;
  }
}
</style>
