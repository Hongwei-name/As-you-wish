<template>
  <div class="order-list">
    <div class="container">
      <h2 class="page-title">我的订单</h2>
      
      <!-- 订单状态筛选 -->
      <div class="status-filter">
        <el-radio-group v-model="status" @change="handleStatusChange">
          <el-radio value="">全部</el-radio>
          <el-radio value="0">待支付</el-radio>
          <el-radio value="1">待发货</el-radio>
          <el-radio value="2">待收货</el-radio>
          <el-radio value="3">已完成</el-radio>
          <el-radio value="4">已取消</el-radio>
        </el-radio-group>
      </div>
      
      <!-- 订单列表 -->
      <div class="order-container" v-if="orders.length > 0">
        <div 
          v-for="order in orders" 
          :key="order.id"
          class="order-item"
        >
          <div class="order-header">
            <div class="order-info">
              <span class="order-no">订单号：{{ order.orderNo }}</span>
              <span class="order-status" :class="getOrderStatusClass(order.status)">
                {{ getOrderStatusText(order.status) }}
              </span>
            </div>
            <div class="order-time">
              {{ formatDate(order.createdAt) }}
            </div>
          </div>
          
          <div class="order-items">
            <div 
              v-for="item in order.items" 
              :key="item.id"
              class="order-item-product"
            >
              <router-link :to="`/product/${item.productId}`" class="product-link">
                <img :src="item.productImage" :alt="item.productName" class="product-image">
                <div class="product-info">
                  <h4 class="product-name">{{ item.productName }}</h4>
                  <div class="product-price">
                    <span class="price">¥{{ item.price.toFixed(2) }}</span>
                    <span class="quantity">×{{ item.quantity }}</span>
                  </div>
                </div>
              </router-link>
            </div>
            <div v-if="!order.items || order.items.length === 0" class="no-items">
              <p>暂无商品信息</p>
            </div>
          </div>
          
          <div class="order-footer">
            <div class="order-total">
              共 {{ order.items?.length || 0 }} 件商品，合计：
              <span class="total-amount">¥{{ order.payAmount.toFixed(2) }}</span>
            </div>
            <div class="order-actions">
              <el-button 
                v-if="order.status === 0"
                type="primary" 
                size="small"
                @click="handlePay(order.id)"
              >
                去支付
              </el-button>
              <el-button 
                v-if="order.status === 0"
                type="danger" 
                size="small"
                @click="handleCancel(order.id)"
              >
                取消订单
              </el-button>
              <el-button 
                v-if="order.status === 2"
                type="success" 
                size="small"
                @click="handleReceive(order.id)"
              >
                确认收货
              </el-button>
              <el-button 
                v-if="order.status === 3 || order.status === 4"
                type="default" 
                size="small"
                @click="handleDelete(order.id)"
              >
                删除订单
              </el-button>
              <router-link :to="`/order/${order.id}`" class="view-detail">
                查看详情
              </router-link>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 空状态 -->
      <div class="empty-state" v-else-if="!loading">
        <i class="el-icon-document"></i>
        <p>暂无订单</p>
        <router-link to="/product/list" class="go-shopping-btn">去购物</router-link>
      </div>
      
      <!-- 加载中 -->
      <div class="loading" v-else>
        <el-icon class="is-loading"><i class="el-icon-loading"></i></el-icon>
        <span>加载中...</span>
      </div>
      
      <!-- 分页 -->
      <div class="pagination" v-if="total > 0">
        <el-pagination
          v-model:current-page="queryParams.page"
          v-model:page-size="queryParams.size"
          :page-sizes="[10, 20, 30]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { api } from '@/utils/request'

const router = useRouter()
const loading = ref(false)
const orders = ref([])
const total = ref(0)
const status = ref('')

const queryParams = ref({
  page: 1,
  size: 10
})

// 获取订单状态文本
const getOrderStatusText = (status) => {
  const statusMap = {
    0: '待支付',
    1: '待发货',
    2: '待收货',
    3: '已完成',
    4: '已取消',
    5: '已退款'
  }
  return statusMap[status] || '未知状态'
}

// 获取订单状态样式类
const getOrderStatusClass = (status) => {
  const classMap = {
    0: 'status-pending',
    1: 'status-processing',
    2: 'status-shipping',
    3: 'status-completed',
    4: 'status-cancelled',
    5: 'status-refunded'
  }
  return classMap[status] || ''
}

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString()
}

// 处理状态筛选
const handleStatusChange = () => {
  queryParams.value.page = 1
  getOrderList()
}

// 处理分页大小变化
const handleSizeChange = (size) => {
  queryParams.value.size = size
  getOrderList()
}

// 处理页码变化
const handleCurrentChange = (page) => {
  queryParams.value.page = page
  getOrderList()
}

// 处理支付
const handlePay = (orderId) => {
  router.push(`/order/${orderId}`)
}

// 处理取消订单
const handleCancel = async (orderId) => {
  try {
    await ElMessageBox.confirm('确定要取消这个订单吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const response = await api.order.cancel(orderId)
    if (response.code === 200) {
      ElMessage.success('订单已取消')
      getOrderList()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '取消失败')
    }
  }
}

// 处理确认收货
const handleReceive = async (orderId) => {
  try {
    await ElMessageBox.confirm('确定已收到商品吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const response = await api.order.receive(orderId)
    if (response.code === 200) {
      ElMessage.success('确认收货成功')
      getOrderList()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '操作失败')
    }
  }
}

// 处理删除订单
const handleDelete = async (orderId) => {
  try {
    await ElMessageBox.confirm('确定要删除这个订单吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const response = await api.order.delete(orderId)
    if (response.code === 200) {
      ElMessage.success('订单已删除')
      getOrderList()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

// 获取订单列表
const getOrderList = async () => {
  loading.value = true
  try {
    const params = {
      page: queryParams.value.page,
      size: queryParams.value.size,
      status: status.value
    }
    
    const response = await api.order.list(params)
    orders.value = response.data.records
    total.value = response.data.total
  } catch (error) {
    console.error('获取订单列表失败:', error)
  } finally {
    loading.value = false
  }
}

// 初始化
onMounted(() => {
  getOrderList()
})
</script>

<style scoped>
.order-list {
  padding: 20px 0;
}

.page-title {
  font-size: 20px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 20px;
  text-align: center;
  position: relative;
  padding-bottom: 10px;
}

.page-title::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 60px;
  height: 2px;
  background-color: var(--el-color-primary);
}

.status-filter {
  background-color: #FFFFFF;
  padding: 15px 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
}

.order-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.order-item {
  background-color: #FFFFFF;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
  overflow: hidden;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  border-bottom: 1px solid var(--el-border-color);
  background-color: var(--el-bg-color-overlay);
}

.order-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.order-no {
  font-size: 14px;
  color: var(--el-text-color-primary);
}

.order-status {
  font-size: 14px;
  font-weight: bold;
  padding: 2px 8px;
  border-radius: 10px;
}

.status-pending {
  background-color: rgba(245, 108, 108, 0.1);
  color: #F56C6C;
}

.status-processing {
  background-color: rgba(230, 162, 60, 0.1);
  color: #E6A23C;
}

.status-shipping {
  background-color: rgba(54, 162, 235, 0.1);
  color: #409EFF;
}

.status-completed {
  background-color: rgba(103, 194, 58, 0.1);
  color: #67C23A;
}

.status-cancelled {
  background-color: rgba(144, 147, 153, 0.1);
  color: #909399;
}

.status-refunded {
  background-color: rgba(190, 190, 190, 0.1);
  color: #B4B4B4;
}

.order-time {
  font-size: 12px;
  color: var(--el-text-color-placeholder);
}

.order-items {
  padding: 20px;
  border-bottom: 1px solid var(--el-border-color);
}

.order-item-product {
  display: flex;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid var(--el-border-color-light);
}

.order-item-product:last-child {
  border-bottom: none;
}

.no-items {
  text-align: center;
  padding: 30px 0;
  color: var(--el-text-color-placeholder);
  font-size: 14px;
}

.product-link {
  display: flex;
  align-items: center;
  text-decoration: none;
  color: inherit;
  width: 100%;
}

.product-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 4px;
  border: 1px solid var(--el-border-color);
  margin-right: 15px;
}

.product-info {
  flex: 1;
  min-width: 0;
}

.product-name {
  font-size: 14px;
  color: var(--el-text-color-primary);
  margin: 0 0 10px;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.product-price {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.price {
  font-size: 14px;
  color: var(--el-color-primary);
  font-weight: bold;
}

.quantity {
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
}

.order-total {
  font-size: 14px;
  color: var(--el-text-color-primary);
}

.total-amount {
  font-size: 16px;
  font-weight: bold;
  color: var(--el-color-primary);
  margin-left: 5px;
}

.order-actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.view-detail {
  font-size: 14px;
  color: var(--el-color-primary);
  text-decoration: none;
  transition: color 0.3s ease;
}

.view-detail:hover {
  color: var(--el-color-primary-light-3);
  text-decoration: underline;
}

.empty-state {
  text-align: center;
  padding: 60px 0;
  background-color: #FFFFFF;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
}

.empty-state i {
  font-size: 64px;
  color: var(--el-text-color-placeholder);
  margin-bottom: 20px;
  display: block;
}

.empty-state p {
  font-size: 16px;
  color: var(--el-text-color-secondary);
  margin-bottom: 30px;
}

.go-shopping-btn {
  display: inline-block;
  padding: 10px 32px;
  background-color: var(--el-color-primary);
  color: #FFFFFF;
  text-decoration: none;
  border-radius: 4px;
  font-size: 14px;
  transition: all 0.3s ease;
}

.go-shopping-btn:hover {
  background-color: var(--el-color-primary-light-3);
}

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 60px 0;
  color: var(--el-text-color-secondary);
}

.loading i {
  font-size: 24px;
  margin-right: 10px;
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 30px;
}

/* 响应式 */
@media (max-width: 768px) {
  .order-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .order-footer {
    flex-direction: column;
    align-items: stretch;
    gap: 15px;
  }
  
  .order-actions {
    justify-content: center;
  }
  
  .order-total {
    text-align: center;
  }
}
</style>
