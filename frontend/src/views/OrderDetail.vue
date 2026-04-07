<template>
  <div class="order-detail">
    <div class="container">
      <!-- 面包屑导航 -->
      <el-breadcrumb separator="/" class="breadcrumb">
        <el-breadcrumb-item><router-link to="/">首页</router-link></el-breadcrumb-item>
        <el-breadcrumb-item><router-link to="/order/list">我的订单</router-link></el-breadcrumb-item>
        <el-breadcrumb-item>订单详情</el-breadcrumb-item>
      </el-breadcrumb>
      
      <!-- 订单信息 -->
      <div v-if="order" class="order-container">
        <!-- 订单状态 -->
        <div class="order-status-section">
          <div class="status-content">
            <div class="status-icon" :class="getStatusIconClass(order.status)">
              <i :class="getStatusIcon(order.status)"></i>
            </div>
            <div class="status-info">
              <h3 class="status-text">{{ getOrderStatusText(order.status) }}</h3>
              <p class="status-desc">{{ getStatusDesc(order.status) }}</p>
            </div>
          </div>
        </div>
        
        <!-- 收货地址 -->
        <div class="section">
          <h3 class="section-title">收货信息</h3>
          <div class="address-info">
            <div class="address-item">
              <div class="address-header">
                <span class="receiver">{{ order.address.receiver }}</span>
                <span class="phone">{{ order.address.phone }}</span>
              </div>
              <div class="address-detail">
                {{ order.address.province }}{{ order.address.city }}{{ order.address.district }}{{ order.address.detail }}
              </div>
            </div>
          </div>
        </div>
        
        <!-- 商品信息 -->
        <div class="section">
          <h3 class="section-title">商品信息</h3>
          <div class="product-list">
            <div 
              v-for="item in order.items" 
              :key="item.id"
              class="product-item"
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
                <div class="product-subtotal">¥{{ item.totalAmount.toFixed(2) }}</div>
              </router-link>
            </div>
          </div>
        </div>
        
        <!-- 订单详情 -->
        <div class="section">
          <h3 class="section-title">订单详情</h3>
          <div class="order-info">
            <div class="info-item">
              <span class="label">订单号：</span>
              <span class="value">{{ order.orderNo }}</span>
            </div>
            <div class="info-item">
              <span class="label">创建时间：</span>
              <span class="value">{{ formatDate(order.createdAt) }}</span>
            </div>
            <div class="info-item" v-if="order.paymentTime">
              <span class="label">支付时间：</span>
              <span class="value">{{ formatDate(order.paymentTime) }}</span>
            </div>
            <div class="info-item" v-if="order.deliveryTime">
              <span class="label">发货时间：</span>
              <span class="value">{{ formatDate(order.deliveryTime) }}</span>
            </div>
            <div class="info-item" v-if="order.receiveTime">
              <span class="label">收货时间：</span>
              <span class="value">{{ formatDate(order.receiveTime) }}</span>
            </div>
          </div>
        </div>
        
        <!-- 费用信息 -->
        <div class="section">
          <h3 class="section-title">费用信息</h3>
          <div class="payment-info">
            <div class="info-item">
              <span class="label">商品总额：</span>
              <span class="value">¥{{ (order.totalAmount - order.freightAmount).toFixed(2) }}</span>
            </div>
            <div class="info-item">
              <span class="label">运费：</span>
              <span class="value">¥{{ order.freightAmount.toFixed(2) }}</span>
            </div>
            <div class="info-item total">
              <span class="label">实付金额：</span>
              <span class="value">¥{{ order.payAmount.toFixed(2) }}</span>
            </div>
          </div>
        </div>
        
        <!-- 操作按钮 -->
        <div class="action-buttons">
          <el-button 
            v-if="order.status === 0"
            type="primary" 
            size="large"
            @click="handlePay"
            :loading="loading"
          >
            立即支付
          </el-button>
          <el-button 
            v-if="order.status === 0"
            type="danger" 
            size="large"
            @click="handleCancel"
          >
            取消订单
          </el-button>
          <el-button 
            v-if="order.status === 2"
            type="success" 
            size="large"
            @click="handleReceive"
          >
            确认收货
          </el-button>
          <el-button 
            v-if="order.status === 3 || order.status === 4"
            type="default" 
            size="large"
            @click="handleDelete"
          >
            删除订单
          </el-button>
          <el-button 
            type="default" 
            size="large"
            @click="goBack"
          >
            返回订单列表
          </el-button>
        </div>
      </div>
      
      <!-- 加载中 -->
      <div class="loading" v-else-if="loading">
        <el-icon class="is-loading"><i class="el-icon-loading"></i></el-icon>
        <span>加载中...</span>
      </div>
      
      <!-- 订单不存在 -->
      <div class="empty-state" v-else>
        <i class="el-icon-document"></i>
        <p>订单不存在</p>
        <router-link to="/order/list" class="back-link">返回订单列表</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { api } from '@/utils/request'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const order = ref(null)

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

// 获取状态描述
const getStatusDesc = (status) => {
  const descMap = {
    0: '请尽快完成支付',
    1: '商家正在处理您的订单',
    2: '商品已发货，请耐心等待',
    3: '订单已完成，感谢您的购买',
    4: '订单已取消',
    5: '订单已退款'
  }
  return descMap[status] || ''
}

// 获取状态图标
const getStatusIcon = (status) => {
  const iconMap = {
    0: 'el-icon-time',
    1: 'el-icon-loading',
    2: 'el-icon-truck',
    3: 'el-icon-check',
    4: 'el-icon-close',
    5: 'el-icon-refresh'
  }
  return iconMap[status] || 'el-icon-info'
}

// 获取状态图标样式类
const getStatusIconClass = (status) => {
  const classMap = {
    0: 'icon-pending',
    1: 'icon-processing',
    2: 'icon-shipping',
    3: 'icon-completed',
    4: 'icon-cancelled',
    5: 'icon-refunded'
  }
  return classMap[status] || ''
}

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString()
}

// 处理支付
const handlePay = async () => {
  loading.value = true
  try {
    // 创建支付记录
    const paymentData = {
      orderId: order.value.id,
      amount: order.value.payAmount,
      paymentType: 1 // 支付宝
    }
    
    const createResponse = await api.payment.create(paymentData)
    if (createResponse.code === 200) {
      const paymentId = createResponse.data.id
      
      // 模拟支付
      const payResponse = await api.payment.pay(paymentId)
      if (payResponse.code === 200) {
        ElMessage.success('支付成功')
        // 重新获取订单详情
        await getOrderDetail()
      }
    }
  } catch (error) {
    ElMessage.error(error.message || '支付失败')
  } finally {
    loading.value = false
  }
}

// 处理取消订单
const handleCancel = async () => {
  try {
    await ElMessageBox.confirm('确定要取消这个订单吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const response = await api.order.cancel(order.value.id)
    if (response.code === 200) {
      ElMessage.success('订单已取消')
      await getOrderDetail()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '取消失败')
    }
  }
}

// 处理确认收货
const handleReceive = async () => {
  try {
    await ElMessageBox.confirm('确定已收到商品吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const response = await api.order.receive(order.value.id)
    if (response.code === 200) {
      ElMessage.success('确认收货成功')
      await getOrderDetail()
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '操作失败')
    }
  }
}

// 处理删除订单
const handleDelete = async () => {
  try {
    await ElMessageBox.confirm('确定要删除这个订单吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    const response = await api.order.delete(order.value.id)
    if (response.code === 200) {
      ElMessage.success('订单已删除')
      router.push('/order/list')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

// 返回订单列表
const goBack = () => {
  router.push('/order/list')
}

// 获取订单详情
const getOrderDetail = async () => {
  const orderId = route.params.id
  if (!orderId || orderId === 'undefined') {
    // 订单ID无效，显示订单不存在
    loading.value = false
    return
  }
  
  loading.value = true
  try {
    const response = await api.order.detail(orderId)
    order.value = response.data
  } catch (error) {
    console.error('获取订单详情失败:', error)
  } finally {
    loading.value = false
  }
}

// 初始化
onMounted(() => {
  getOrderDetail()
})
</script>

<style scoped>
.order-detail {
  padding: 20px 0;
}

.breadcrumb {
  margin-bottom: 20px;
}

.order-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.order-status-section {
  background: linear-gradient(135deg, #F5F0E8 0%, #F0DCC8 100%);
  border-radius: 8px;
  padding: 40px 20px;
  text-align: center;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
}

.status-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  flex-wrap: wrap;
}

.status-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  color: #FFFFFF;
}

.icon-pending {
  background-color: #F56C6C;
}

.icon-processing {
  background-color: #E6A23C;
}

.icon-shipping {
  background-color: #409EFF;
}

.icon-completed {
  background-color: #67C23A;
}

.icon-cancelled {
  background-color: #909399;
}

.icon-refunded {
  background-color: #B4B4B4;
}

.status-info {
  flex: 1;
  min-width: 200px;
}

.status-text {
  font-size: 20px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 8px;
}

.status-desc {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 0;
}

.section {
  background-color: #FFFFFF;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
}

.section-title {
  font-size: 16px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 15px;
  position: relative;
  padding-left: 10px;
}

.section-title::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 4px;
  height: 16px;
  background-color: var(--el-color-primary);
  border-radius: 2px;
}

.address-item {
  padding: 15px;
  border: 1px solid var(--el-border-color);
  border-radius: 8px;
  background-color: var(--el-bg-color-overlay);
}

.address-header {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 8px;
}

.receiver {
  font-weight: bold;
  color: var(--el-text-color-primary);
}

.phone {
  color: var(--el-text-color-secondary);
  font-size: 14px;
}

.address-detail {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  line-height: 1.4;
}

.product-list {
  border-top: 1px solid var(--el-border-color);
  padding-top: 15px;
}

.product-item {
  display: flex;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid var(--el-border-color-light);
}

.product-item:last-child {
  border-bottom: none;
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
  align-items: center;
  gap: 15px;
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

.product-subtotal {
  width: 100px;
  text-align: right;
  font-weight: bold;
  color: var(--el-text-color-primary);
}

.order-info,
.payment-info {
  border-top: 1px solid var(--el-border-color);
  padding-top: 15px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.info-item.total {
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid var(--el-border-color-light);
}

.label {
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

.value {
  font-size: 14px;
  color: var(--el-text-color-primary);
}

.info-item.total .value {
  font-size: 16px;
  font-weight: bold;
  color: var(--el-color-primary);
}

.action-buttons {
  display: flex;
  gap: 15px;
  justify-content: center;
  margin-top: 20px;
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

.back-link {
  display: inline-block;
  padding: 10px 32px;
  background-color: var(--el-color-primary);
  color: #FFFFFF;
  text-decoration: none;
  border-radius: 4px;
  font-size: 14px;
  transition: all 0.3s ease;
}

.back-link:hover {
  background-color: var(--el-color-primary-light-3);
}

/* 响应式 */
@media (max-width: 768px) {
  .status-content {
    flex-direction: column;
    text-align: center;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .action-buttons button {
    width: 100%;
  }
}
</style>
