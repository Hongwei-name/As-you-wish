<template>
  <div class="admin-statistics">
    <div class="admin-page-header">
      <h2 class="admin-page-title">数据统计</h2>
      <el-select v-model="dateRange" @change="handleDateRangeChange">
        <el-option label="今日" value="today"></el-option>
        <el-option label="近7天" value="7days"></el-option>
        <el-option label="近30天" value="30days"></el-option>
        <el-option label="本月" value="month"></el-option>
        <el-option label="本年" value="year"></el-option>
      </el-select>
    </div>
    
    <div class="admin-card">
      <div class="stats-grid">
        <div class="stats-card">
          <div class="stats-icon sales-icon"></div>
          <div class="stats-content">
            <div class="stats-title">总销售额</div>
            <div class="stats-value">¥{{ statisticsData.totalSales.toFixed(2) }}</div>
            <div class="stats-change" :class="{ positive: statisticsData.salesChange > 0, negative: statisticsData.salesChange < 0 }">
              {{ statisticsData.salesChange > 0 ? '+' : '' }}{{ statisticsData.salesChange.toFixed(2) }}%
            </div>
          </div>
        </div>
        
        <div class="stats-card">
          <div class="stats-icon order-icon"></div>
          <div class="stats-content">
            <div class="stats-title">订单数</div>
            <div class="stats-value">{{ statisticsData.totalOrders }}</div>
            <div class="stats-change" :class="{ positive: statisticsData.orderChange > 0, negative: statisticsData.orderChange < 0 }">
              {{ statisticsData.orderChange > 0 ? '+' : '' }}{{ statisticsData.orderChange.toFixed(2) }}%
            </div>
          </div>
        </div>
        
        <div class="stats-card">
          <div class="stats-icon user-icon"></div>
          <div class="stats-content">
            <div class="stats-title">用户数</div>
            <div class="stats-value">{{ statisticsData.totalUsers }}</div>
            <div class="stats-change" :class="{ positive: statisticsData.userChange > 0, negative: statisticsData.userChange < 0 }">
              {{ statisticsData.userChange > 0 ? '+' : '' }}{{ statisticsData.userChange.toFixed(2) }}%
            </div>
          </div>
        </div>
        
        <div class="stats-card">
          <div class="stats-icon product-icon"></div>
          <div class="stats-content">
            <div class="stats-title">商品数</div>
            <div class="stats-value">{{ statisticsData.totalProducts }}</div>
            <div class="stats-change" :class="{ positive: statisticsData.productChange > 0, negative: statisticsData.productChange < 0 }">
              {{ statisticsData.productChange > 0 ? '+' : '' }}{{ statisticsData.productChange.toFixed(2) }}%
            </div>
          </div>
        </div>
      </div>
      
      <div class="chart-row">
        <div class="chart-card">
          <h3 class="chart-title">销售趋势</h3>
          <div class="chart-container">
            <canvas ref="salesChartRef"></canvas>
          </div>
        </div>
        
        <div class="chart-card">
          <h3 class="chart-title">用户增长</h3>
          <div class="chart-container">
            <canvas ref="userChartRef"></canvas>
          </div>
        </div>
      </div>
      
      <div class="chart-row">
        <div class="chart-card">
          <h3 class="chart-title">商品分类占比</h3>
          <div class="chart-container">
            <canvas ref="categoryChartRef"></canvas>
          </div>
        </div>
        
        <div class="chart-card">
          <h3 class="chart-title">热销商品</h3>
          <div class="chart-container">
            <canvas ref="hotProductChartRef"></canvas>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import * as adminApi from '@/api/admin'
import Chart from 'chart.js/auto'

const dateRange = ref('7days')
const statisticsData = reactive({
  totalSales: 0,
  totalOrders: 0,
  totalUsers: 0,
  totalProducts: 0,
  salesChange: 0,
  orderChange: 0,
  userChange: 0,
  productChange: 0
})

const salesChartRef = ref(null)
const userChartRef = ref(null)
const categoryChartRef = ref(null)
const hotProductChartRef = ref(null)

let salesChart = null
let userChart = null
let categoryChart = null
let hotProductChart = null

const loadStatisticsData = async () => {
  try {
    const response = await adminApi.getStatistics(dateRange.value)
    if (response.code === 200) {
      Object.assign(statisticsData, response.data)
      renderCharts()
    }
  } catch (error) {
    ElMessage.error('获取统计数据失败')
  }
}

const renderCharts = () => {
  renderSalesChart()
  renderUserChart()
  renderCategoryChart()
  renderHotProductChart()
}

const renderSalesChart = () => {
  if (salesChart) {
    salesChart.destroy()
  }
  
  const ctx = salesChartRef.value.getContext('2d')
  salesChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: ['1月', '2月', '3月', '4月', '5月', '6月', '7月'],
      datasets: [{
        label: '销售额',
        data: [12000, 19000, 15000, 21000, 25000, 30000, 35000],
        borderColor: '#409EFF',
        backgroundColor: 'rgba(64, 158, 255, 0.1)',
        tension: 0.4
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false
    }
  })
}

const renderUserChart = () => {
  if (userChart) {
    userChart.destroy()
  }
  
  const ctx = userChartRef.value.getContext('2d')
  userChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: ['1月', '2月', '3月', '4月', '5月', '6月', '7月'],
      datasets: [{
        label: '新增用户',
        data: [120, 190, 150, 210, 250, 300, 350],
        backgroundColor: '#67C23A'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false
    }
  })
}

const renderCategoryChart = () => {
  if (categoryChart) {
    categoryChart.destroy()
  }
  
  const ctx = categoryChartRef.value.getContext('2d')
  categoryChart = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: ['电子产品', '服装', '食品', '家居', '其他'],
      datasets: [{
        data: [35, 25, 20, 15, 5],
        backgroundColor: [
          '#409EFF',
          '#67C23A',
          '#E6A23C',
          '#F56C6C',
          '#909399'
        ]
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false
    }
  })
}

const renderHotProductChart = () => {
  if (hotProductChart) {
    hotProductChart.destroy()
  }
  
  const ctx = hotProductChartRef.value.getContext('2d')
  hotProductChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: ['商品1', '商品2', '商品3', '商品4', '商品5'],
      datasets: [{
        label: '销量',
        data: [1200, 900, 800, 700, 600],
        backgroundColor: '#F56C6C'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      indexAxis: 'y'
    }
  })
}

const handleDateRangeChange = () => {
  loadStatisticsData()
}

onMounted(() => {
  loadStatisticsData()
})
</script>

<style scoped>
.admin-statistics {
  width: 100%;
}

.admin-page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.admin-page-title {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

.admin-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  padding: 20px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.stats-card {
  display: flex;
  align-items: center;
  background: #f5f7fa;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.stats-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  margin-right: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
}

.sales-icon {
  background: linear-gradient(135deg, #409eff, #69c0ff);
}

.order-icon {
  background: linear-gradient(135deg, #67c23a, #85ce61);
}

.user-icon {
  background: linear-gradient(135deg, #e6a23c, #ebb563);
}

.product-icon {
  background: linear-gradient(135deg, #f56c6c, #f78989);
}

.stats-content {
  flex: 1;
}

.stats-title {
  font-size: 14px;
  color: #909399;
  margin-bottom: 5px;
}

.stats-value {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 5px;
}

.stats-change {
  font-size: 12px;
  font-weight: 500;
}

.stats-change.positive {
  color: #67c23a;
}

.stats-change.negative {
  color: #f56c6c;
}

.chart-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.chart-card {
  background: #f5f7fa;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.chart-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 15px;
}

.chart-container {
  height: 300px;
}
</style>