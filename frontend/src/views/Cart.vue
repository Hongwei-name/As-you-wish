<template>
  <div class="cart-page">
    <div class="container">
      <h2 class="page-title">我的购物车</h2>
      
      <!-- 购物车列表 -->
      <div v-if="cartItems.length > 0" class="cart-container">
        <el-table :data="cartItems" style="width: 100%">
          <el-table-column width="60">
            <template #header>
              <el-checkbox v-model="isAllSelected" @change="handleSelectAll"></el-checkbox>
            </template>
            <template #default="scope">
              <el-checkbox v-model="scope.row.selected" @change="handleSelectItem(scope.row.id, scope.row.selected)"></el-checkbox>
            </template>
          </el-table-column>
          <el-table-column label="商品信息" min-width="300">
            <template #default="scope">
              <div class="product-info">
                <router-link :to="`/product/${scope.row.productId}`" class="product-link">
                  <img :src="scope.row.productImage" :alt="scope.row.productName" class="product-image">
                  <div class="product-details">
                    <h4 class="product-name">{{ scope.row.productName }}</h4>
                    <p class="product-desc">{{ scope.row.productDesc || '暂无描述' }}</p>
                  </div>
                </router-link>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="单价" width="120" align="center">
            <template #default="scope">
              <span class="price">¥{{ scope.row.productPrice.toFixed(2) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="数量" width="180" align="center">
            <template #default="scope">
              <el-input-number 
                v-model="scope.row.quantity" 
                :min="1" 
                :max="scope.row.productStock" 
                @change="handleQuantityChange(scope.row.id, scope.row.quantity)"
              ></el-input-number>
            </template>
          </el-table-column>
          <el-table-column label="小计" width="120" align="center">
            <template #default="scope">
              <span class="subtotal">¥{{ (scope.row.productPrice * scope.row.quantity).toFixed(2) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="100" align="center">
            <template #default="scope">
              <el-button type="danger" size="small" @click="handleDelete(scope.row.id)">
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>
        
        <!-- 结算栏 -->
        <div class="checkout-bar">
          <div class="checkout-left">
            <el-checkbox v-model="isAllSelected" @change="handleSelectAll">全选</el-checkbox>
            <el-button type="danger" @click="handleClearCart">
              清空购物车
            </el-button>
          </div>
          <div class="checkout-right">
            <div class="total-section">
              <span class="total-label">合计：</span>
              <span class="total-amount">¥{{ selectedTotal.toFixed(2) }}</span>
            </div>
            <el-button 
              type="primary" 
              size="large" 
              :disabled="selectedCount === 0"
              @click="handleCheckout"
            >
              结算 ({{ selectedCount }})
            </el-button>
          </div>
        </div>
      </div>
      
      <!-- 空购物车 -->
      <div class="empty-cart" v-else-if="!loading">
        <i class="el-icon-shopping-cart-full"></i>
        <p>购物车是空的</p>
        <router-link to="/product/list" class="go-shopping-btn">去购物</router-link>
      </div>
      
      <!-- 加载中 -->
      <div class="loading" v-else>
        <el-icon class="is-loading"><i class="el-icon-loading"></i></el-icon>
        <span>加载中...</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useCartStore } from '@/stores/cart'

const router = useRouter()
const cartStore = useCartStore()

// 计算属性
const cartItems = computed(() => cartStore.cartItems)
const loading = computed(() => cartStore.loading)
const selectedCount = computed(() => cartStore.selectedCount)
const selectedTotal = computed(() => cartStore.selectedTotal)
const isAllSelected = computed({
  get: () => cartStore.isAllSelected,
  set: (value) => handleSelectAll(value)
})

// 处理选择单个商品
const handleSelectItem = async (cartId, selected) => {
  try {
    await cartStore.selectCartItem(cartId, selected ? 1 : 0)
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

// 处理全选
const handleSelectAll = async (selected) => {
  try {
    await cartStore.selectAll(selected ? 1 : 0)
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

// 处理数量变化
const handleQuantityChange = async (cartId, quantity) => {
  try {
    await cartStore.updateQuantity(cartId, quantity)
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  }
}

// 处理删除
const handleDelete = async (cartId) => {
  try {
    await ElMessageBox.confirm('确定要删除这个商品吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await cartStore.deleteCartItem(cartId)
    ElMessage.success('删除成功')
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

// 处理清空购物车
const handleClearCart = async () => {
  try {
    await ElMessageBox.confirm('确定要清空购物车吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await cartStore.clearCart()
    ElMessage.success('购物车已清空')
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '操作失败')
    }
  }
}

// 处理结算
const handleCheckout = () => {
  if (selectedCount.value === 0) {
    ElMessage.warning('请选择要结算的商品')
    return
  }
  
  // 跳转到订单确认页
  router.push('/order/confirm')
}

// 初始化
onMounted(async () => {
  try {
    await cartStore.getCartList()
  } catch (error) {
    console.error('获取购物车失败:', error)
  }
})
</script>

<style scoped>
.cart-page {
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

.cart-container {
  background-color: #FFFFFF;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
}

.product-info {
  display: flex;
  align-items: center;
  gap: 15px;
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
}

.product-details {
  flex: 1;
  min-width: 0;
}

.product-name {
  font-size: 14px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 5px;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.product-desc {
  font-size: 12px;
  color: var(--el-text-color-secondary);
  margin: 0;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.price {
  font-size: 16px;
  font-weight: bold;
  color: var(--el-color-primary);
}

.subtotal {
  font-size: 16px;
  font-weight: bold;
  color: var(--el-color-primary);
}

.checkout-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid var(--el-border-color);
}

.checkout-left {
  display: flex;
  align-items: center;
  gap: 20px;
}

.checkout-right {
  display: flex;
  align-items: center;
  gap: 20px;
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

.empty-cart {
  text-align: center;
  padding: 60px 0;
  background-color: #FFFFFF;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
}

.empty-cart i {
  font-size: 64px;
  color: var(--el-text-color-placeholder);
  margin-bottom: 20px;
  display: block;
}

.empty-cart p {
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

/* 响应式 */
@media (max-width: 768px) {
  .cart-container {
    padding: 10px;
  }
  
  .checkout-bar {
    flex-direction: column;
    align-items: stretch;
    gap: 15px;
  }
  
  .checkout-left {
    justify-content: center;
  }
  
  .checkout-right {
    flex-direction: column;
    align-items: stretch;
  }
  
  .total-section {
    text-align: center;
  }
}
</style>
