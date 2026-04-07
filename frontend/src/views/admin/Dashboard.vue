<template>
  <div class="admin-dashboard">
    <div class="dashboard-header">
      <h2 class="dashboard-title">管理控制台</h2>
      <p class="dashboard-subtitle">欢迎回来，{{ user.username }}</p>
    </div>
    
    <div class="dashboard-stats">
      <div class="stat-card">
        <div class="stat-icon orders-icon">
          <el-icon><ShoppingCart /></el-icon>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ dashboardData.totalOrders }}</div>
          <div class="stat-label">今日订单</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon sales-icon">
          <el-icon><Goods /></el-icon>
        </div>
        <div class="stat-content">
          <div class="stat-value">¥{{ dashboardData.totalSales.toFixed(2) }}</div>
          <div class="stat-label">今日销售额</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon users-icon">
          <el-icon><UserFilled /></el-icon>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ dashboardData.totalUsers }}</div>
          <div class="stat-label">今日新增用户</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon products-icon">
          <el-icon><Collection /></el-icon>
        </div>
        <div class="stat-content">
          <div class="stat-value">{{ dashboardData.totalProducts }}</div>
          <div class="stat-label">商品总数</div>
        </div>
      </div>
    </div>
    
    <div class="dashboard-content">
      <div class="content-card">
        <h3 class="card-title">最近订单</h3>
        <el-table :data="recentOrders" style="width: 100%">
          <el-table-column prop="orderNo" label="订单号" min-width="180"></el-table-column>
          <el-table-column prop="userId" label="用户ID" width="80"></el-table-column>
          <el-table-column prop="totalAmount" label="总金额" width="100">
            <template #default="scope">
              ¥{{ scope.row.totalAmount.toFixed(2) }}
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="scope">
              <el-tag :type="getStatusType(scope.row.status)">
                {{ getStatusText(scope.row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createdAt" label="创建时间" width="180"></el-table-column>
        </el-table>
      </div>
      
      <div class="content-card">
        <h3 class="card-title">热销商品</h3>
        <el-table :data="hotProducts" style="width: 100%">
          <el-table-column prop="name" label="商品名称" min-width="150"></el-table-column>
          <el-table-column prop="price" label="价格" width="100">
            <template #default="scope">
              ¥{{ scope.row.price.toFixed(2) }}
            </template>
          </el-table-column>
          <el-table-column prop="sales" label="销量" width="80"></el-table-column>
          <el-table-column prop="stock" label="库存" width="80"></el-table-column>
        </el-table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElIcon, ElMessage } from 'element-plus'
import { HomeFilled, Goods, UserFilled, ShoppingCart, Collection, DataAnalysis } from '@element-plus/icons-vue'
import * as adminApi from '@/api/admin'

const user = ref(JSON.parse(localStorage.getItem('user') || '{}'))

const dashboardData = reactive({
  totalOrders: 0,
  totalSales: 0,
  totalUsers: 0,
  totalProducts: 0
})

const recentOrders = ref([])
const hotProducts = ref([])

const getStatusText = (status) => {
  const statusMap = {
    0: '待支付',
    1: '待发货',
    2: '待收货',
    3: '已完成',
    4: '已取消',
    5: '已退款'
  }
  return statusMap[status] || '未知'
}

const getStatusType = (status) => {
  const typeMap = {
    0: 'warning',
    1: 'info',
    2: 'primary',
    3: 'success',
    4: 'danger',
    5: 'danger'
  }
  return typeMap[status] || 'info'
}

const loadDashboardData = async () => {
  try {
    // 获取销售统计数据
    const salesStats = await adminApi.getSalesStats()
    if (salesStats.code === 200) {
      dashboardData.totalOrders = salesStats.data.totalOrders || 0
      dashboardData.totalSales = salesStats.data.totalSales || 0
    }
    
    // 获取用户统计数据
    const userStats = await adminApi.getUserStats()
    if (userStats.code === 200) {
      dashboardData.totalUsers = userStats.data.totalUsers || 0
    }
    
    // 获取商品统计数据
    const productStats = await adminApi.getProductStats()
    if (productStats.code === 200) {
      dashboardData.totalProducts = productStats.data.totalProducts || 0
    }
    
    // 获取最近订单
    const orderList = await adminApi.getOrderList({ page: 1, size: 5, status: null, keyword: null })
    if (orderList.code === 200) {
      recentOrders.value = orderList.data.records || []
    }
    
    // 获取热销商品（按销量排序）
    const productList = await adminApi.getProductList({ page: 1, size: 5, categoryId: null, keyword: null, status: null })
    if (productList.code === 200) {
      // 按销量排序
      hotProducts.value = (productList.data.records || []).sort((a, b) => b.sales - a.sales)
    }
  } catch (error) {
    console.error('获取仪表盘数据失败:', error)
    ElMessage.error('获取数据失败，请稍后重试')
  }
}

onMounted(() => {
  loadDashboardData()
})
</script>

<style scoped>
.admin-dashboard {
  width: 100%;
}

.dashboard-header {
  margin-bottom: 30px;
}

.dashboard-title {
  font-size: 24px;
  font-weight: 600;
  color: #333;
  margin: 0 0 5px;
}

.dashboard-subtitle {
  font-size: 14px;
  color: #666;
  margin: 0;
}

.dashboard-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  display: flex;
  align-items: center;
  background: #f5f7fa;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.stat-icon {
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

.orders-icon {
  background: linear-gradient(135deg, #409eff, #69c0ff);
}

.sales-icon {
  background: linear-gradient(135deg, #67c23a, #85ce61);
}

.users-icon {
  background: linear-gradient(135deg, #e6a23c, #ebb563);
}

.products-icon {
  background: linear-gradient(135deg, #f56c6c, #f78989);
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.dashboard-content {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.content-card {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin: 0 0 15px;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .dashboard-stats {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .dashboard-content {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .dashboard-stats {
    grid-template-columns: 1fr;
  }
}
</style>