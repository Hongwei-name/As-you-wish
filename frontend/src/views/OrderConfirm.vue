<template>
  <div class="order-confirm">
    <div class="container">
      <h2 class="page-title">确认订单</h2>
      
      <!-- 收货地址 -->
      <div class="section">
        <h3 class="section-title">收货地址</h3>
        <div class="address-section">
          <div v-if="addresses.length > 0" class="address-list">
            <div 
              v-for="address in addresses" 
              :key="address.id"
              class="address-item"
              :class="{ active: selectedAddressId === address.id }"
              @click="selectAddress(address.id)"
            >
              <div class="address-content">
                <div class="address-header">
                  <span class="receiver">{{ address.receiver }}</span>
                  <span class="phone">{{ address.phone }}</span>
                  <span class="default-tag" v-if="address.isDefault">默认</span>
                </div>
                <div class="address-detail">
                  {{ address.province }}{{ address.city }}{{ address.district }}{{ address.detail }}
                </div>
              </div>
              <el-radio v-model="selectedAddressId" :value="address.id"></el-radio>
            </div>
          </div>
          <div v-else class="no-address">
            <p>请添加收货地址</p>
            <el-button type="primary" @click="addAddress">添加地址</el-button>
          </div>
        </div>
      </div>
      
      <!-- 商品信息 -->
      <div class="section">
        <h3 class="section-title">商品信息</h3>
        <div class="product-list">
          <div 
            v-for="item in selectedItems" 
            :key="item.id"
            class="product-item"
          >
            <div class="product-info">
              <img :src="item.productImage" :alt="item.productName" class="product-image">
              <div class="product-details">
                <h4 class="product-name">{{ item.productName }}</h4>
                <div class="product-price">¥{{ item.productPrice.toFixed(2) }}</div>
              </div>
            </div>
            <div class="product-quantity">×{{ item.quantity }}</div>
            <div class="product-subtotal">¥{{ (item.productPrice * item.quantity).toFixed(2) }}</div>
          </div>
        </div>
      </div>
      
      <!-- 订单信息 -->
      <div class="section">
        <h3 class="section-title">订单信息</h3>
        <div class="order-info">
          <div class="info-item">
            <span class="label">商品总额：</span>
            <span class="value">¥{{ goodsTotal.toFixed(2) }}</span>
          </div>
          <div class="info-item">
            <span class="label">运费：</span>
            <span class="value">¥{{ freight.toFixed(2) }}</span>
          </div>
          <div class="info-item total">
            <span class="label">应付总额：</span>
            <span class="value">¥{{ totalAmount.toFixed(2) }}</span>
          </div>
        </div>
      </div>
      
      <!-- 支付方式 -->
      <div class="section">
        <h3 class="section-title">支付方式</h3>
        <div class="payment-method">
          <el-radio-group v-model="paymentType">
            <el-radio value="1">支付宝</el-radio>
            <el-radio value="2">微信支付</el-radio>
            <el-radio value="3">银行卡</el-radio>
          </el-radio-group>
        </div>
      </div>
      
      <!-- 操作按钮 -->
      <div class="action-bar">
        <div class="total-section">
          <span class="total-label">合计：</span>
          <span class="total-amount">¥{{ totalAmount.toFixed(2) }}</span>
        </div>
        <el-button 
          type="primary" 
          size="large" 
          :loading="loading"
          @click="submitOrder"
        >
          提交订单
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useCartStore } from '@/stores/cart'
import { api } from '@/utils/request'

const router = useRouter()
const cartStore = useCartStore()
const loading = ref(false)
const addresses = ref([])
const selectedAddressId = ref('')
const paymentType = ref('1')

// 计算属性
const selectedItems = computed(() => {
  return cartStore.cartItems.filter(item => item.selected)
})

const goodsTotal = computed(() => {
  return selectedItems.value.reduce((total, item) => total + (item.productPrice * item.quantity), 0)
})

const freight = computed(() => {
  return goodsTotal.value >= 99 ? 0 : 10
})

const totalAmount = computed(() => {
  return goodsTotal.value + freight.value
})

// 选择地址
const selectAddress = (addressId) => {
  selectedAddressId.value = addressId
}

// 添加地址
const addAddress = () => {
  // 跳转到地址管理页面
  router.push('/address')
}

// 提交订单
const submitOrder = async () => {
  if (!selectedAddressId.value) {
    ElMessage.warning('请选择收货地址')
    return
  }
  
  if (selectedItems.value.length === 0) {
    ElMessage.warning('请选择商品')
    return
  }
  
  loading.value = true
  try {
    const orderData = {
      addressId: selectedAddressId.value,
      totalAmount: totalAmount.value,
      payAmount: totalAmount.value,
      freightAmount: freight.value
    }
    
    const response = await api.order.create(orderData)
    if (response.code === 200) {
      const orderId = response.data.orderId
      
      // 跳转到订单详情页
      router.push(`/order/${orderId}`)
      ElMessage.success('订单创建成功')
    }
  } catch (error) {
    ElMessage.error(error.message || '订单创建失败')
  } finally {
    loading.value = false
  }
}

// 获取地址列表
const getAddresses = async () => {
  try {
    const response = await api.address.list()
    addresses.value = response.data
    
    // 默认选择默认地址
    const defaultAddress = addresses.value.find(addr => addr.isDefault)
    if (defaultAddress) {
      selectedAddressId.value = defaultAddress.id
    } else if (addresses.value.length > 0) {
      selectedAddressId.value = addresses.value[0].id
    }
  } catch (error) {
    console.error('获取地址失败:', error)
  }
}

// 初始化
onMounted(async () => {
  // 获取购物车数据
  try {
    await cartStore.getCartList()
  } catch (error) {
    console.error('获取购物车失败:', error)
  }
  
  // 获取地址列表
  await getAddresses()
  
  // 检查是否有选中商品
  if (selectedItems.value.length === 0) {
    ElMessage.warning('请先选择要结算的商品')
    router.push('/cart')
  }
})
</script>

<style scoped>
.order-confirm {
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

.section {
  background-color: #FFFFFF;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
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

.address-list {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.address-item {
  flex: 1;
  min-width: 280px;
  padding: 15px;
  border: 2px solid var(--el-border-color);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.address-item:hover {
  border-color: var(--el-color-primary-light-3);
}

.address-item.active {
  border-color: var(--el-color-primary);
  background-color: rgba(184, 149, 110, 0.05);
}

.address-content {
  flex: 1;
  min-width: 0;
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

.default-tag {
  background-color: var(--el-color-primary);
  color: #FFFFFF;
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 10px;
}

.address-detail {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.no-address {
  text-align: center;
  padding: 40px 0;
  color: var(--el-text-color-secondary);
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

.product-info {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 15px;
  min-width: 0;
}

.product-image {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border-radius: 4px;
  border: 1px solid var(--el-border-color);
}

.product-details {
  flex: 1;
  min-width: 0;
}

.product-name {
  font-size: 14px;
  color: var(--el-text-color-primary);
  margin: 0 0 5px;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.product-price {
  font-size: 14px;
  color: var(--el-color-primary);
  font-weight: bold;
}

.product-quantity {
  width: 80px;
  text-align: center;
  color: var(--el-text-color-secondary);
}

.product-subtotal {
  width: 100px;
  text-align: right;
  font-weight: bold;
  color: var(--el-text-color-primary);
}

.order-info {
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
  font-size: 18px;
  font-weight: bold;
  color: var(--el-color-primary);
}

.payment-method {
  border-top: 1px solid var(--el-border-color);
  padding-top: 15px;
}

.action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #FFFFFF;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
  margin-top: 30px;
}

.total-section {
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.total-label {
  font-size: 14px;
  color: var(--el-text-color-primary);
}

.total-amount {
  font-size: 20px;
  font-weight: bold;
  color: var(--el-color-primary);
}

/* 响应式 */
@media (max-width: 768px) {
  .address-list {
    flex-direction: column;
  }
  
  .address-item {
    min-width: 100%;
  }
  
  .action-bar {
    flex-direction: column;
    align-items: stretch;
    gap: 15px;
  }
  
  .total-section {
    justify-content: center;
  }
}
</style>
