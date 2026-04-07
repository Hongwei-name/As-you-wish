<template>
  <div class="product-detail">
    <div class="container">
      <!-- 面包屑导航 -->
      <el-breadcrumb separator="/" class="breadcrumb">
        <el-breadcrumb-item><router-link to="/">首页</router-link></el-breadcrumb-item>
        <el-breadcrumb-item><router-link to="/product/list">全部商品</router-link></el-breadcrumb-item>
        <el-breadcrumb-item v-if="product">{{ product.name }}</el-breadcrumb-item>
        <el-breadcrumb-item v-else>商品详情</el-breadcrumb-item>
      </el-breadcrumb>
      
      <!-- 商品信息 -->
      <div v-if="product" class="product-info">
        <div class="product-main">
          <!-- 商品图片 -->
          <div class="product-image">
            <img :src="product.image" :alt="product.name" class="main-image">
          </div>
          
          <!-- 商品详情 -->
          <div class="product-details">
            <h1 class="product-name">{{ product.name }}</h1>
            <div class="product-price">
              <span class="price">¥{{ product.price.toFixed(2) }}</span>
              <span class="original-price" v-if="product.originalPrice > product.price">
                ¥{{ product.originalPrice.toFixed(2) }}
              </span>
            </div>
            <div class="product-stats">
              <span class="sales">已售 {{ product.sales }} 件</span>
              <span class="stock">库存 {{ product.stock }} 件</span>
            </div>
            <div class="product-description">
              {{ product.description }}
            </div>
            
            <!-- 数量选择 -->
            <div class="quantity-section">
              <span class="quantity-label">数量：</span>
              <el-input-number 
                v-model="quantity" 
                :min="1" 
                :max="product.stock" 
                size="large"
                @change="handleQuantityChange"
              ></el-input-number>
            </div>
            
            <!-- 操作按钮 -->
            <div class="action-buttons">
              <el-button 
                type="primary" 
                size="large" 
                class="add-cart-btn"
                @click="addToCart"
                :loading="loading"
              >
                <i class="el-icon-shopping-cart-plus"></i> 加入购物车
              </el-button>
              <el-button 
                type="success" 
                size="large" 
                class="buy-now-btn"
                @click="buyNow"
                :loading="loading"
              >
                <i class="el-icon-right"></i> 立即购买
              </el-button>
              <el-button 
                type="info" 
                size="large" 
                class="share-btn"
                @click="showShareDialog = true"
              >
                <i class="el-icon-share"></i> 分享
              </el-button>
            </div>
            
            <!-- 分享弹窗 -->
            <el-dialog
              v-model="showShareDialog"
              title="分享商品"
              width="400px"
            >
              <div class="share-content">
                <div class="share-link">
                  <el-input
                    v-model="shareLink"
                    placeholder="商品链接"
                    readonly
                  >
                    <template #append>
                      <el-button @click="copyLink">
                        <i class="el-icon-document-copy"></i> 复制
                      </el-button>
                    </template>
                  </el-input>
                </div>
                <div class="share-platforms">
                  <h4>分享到</h4>
                  <div class="platform-buttons">
                    <el-button 
                      type="primary" 
                      circle
                      @click="shareToWeChat"
                    >
                      <i class="el-icon-chat-line-round"></i>
                    </el-button>
                    <el-button 
                      type="success" 
                      circle
                      @click="shareToWeibo"
                    >
                      <i class="el-icon-s-promotion"></i>
                    </el-button>
                    <el-button 
                      type="warning" 
                      circle
                      @click="shareToQQ"
                    >
                      <i class="el-icon-chat-dot-round"></i>
                    </el-button>
                    <el-button 
                      type="info" 
                      circle
                      @click="shareToLink"
                    >
                      <i class="el-icon-link"></i>
                    </el-button>
                  </div>
                </div>
              </div>
            </el-dialog>
          </div>
        </div>
        
        <!-- 商品详情 -->
        <div class="product-detail-section">
          <div class="section-tabs">
            <el-tabs v-model="activeTab">
              <el-tab-pane label="商品详情" name="detail">
                <div class="detail-content" v-html="product.detail"></div>
              </el-tab-pane>
              <el-tab-pane label="规格参数" name="specs">
                <div class="specs-content">
                  <el-descriptions :column="2" border>
                    <el-descriptions-item label="商品名称">{{ product.name }}</el-descriptions-item>
                    <el-descriptions-item label="分类">{{ categoryName }}</el-descriptions-item>
                    <el-descriptions-item label="价格">{{ product.price.toFixed(2) }}元</el-descriptions-item>
                    <el-descriptions-item label="库存">{{ product.stock }}件</el-descriptions-item>
                    <el-descriptions-item label="销量">{{ product.sales }}件</el-descriptions-item>
                    <el-descriptions-item label="上架时间">{{ formatDate(product.createdAt) }}</el-descriptions-item>
                  </el-descriptions>
                </div>
              </el-tab-pane>
            </el-tabs>
          </div>
        </div>
        
        <!-- 相关推荐商品 -->
        <div v-if="relatedProducts.length > 0" class="related-products">
          <h3 class="section-title">相关推荐</h3>
          <div class="product-grid">
            <div 
              v-for="item in relatedProducts" 
              :key="item.id"
              class="product-item card-shadow"
            >
              <router-link :to="`/product/${item.id}`" class="product-link">
                <div class="product-image">
                  <img :src="item.image" :alt="item.name">
                </div>
                <div class="product-info">
                  <h4 class="product-name">{{ item.name }}</h4>
                  <div class="product-price">
                    <span class="price">¥{{ item.price.toFixed(2) }}</span>
                    <span class="original-price" v-if="item.originalPrice > item.price">
                      ¥{{ item.originalPrice.toFixed(2) }}
                    </span>
                  </div>
                  <div class="product-sales">已售 {{ item.sales }} 件</div>
                </div>
              </router-link>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 加载中 -->
      <div class="loading" v-else-if="loading">
        <el-icon class="is-loading"><i class="el-icon-loading"></i></el-icon>
        <span>加载中...</span>
      </div>
      
      <!-- 商品不存在 -->
      <div class="empty-state" v-else>
        <i class="el-icon-s-goods"></i>
        <p>商品不存在</p>
        <router-link to="/product/list" class="back-link">返回商品列表</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { api } from '@/utils/request'
import { useCartStore } from '@/stores/cart'
import { useUserStore } from '@/stores/user'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()
const loading = ref(false)
const product = ref(null)
const quantity = ref(1)
const activeTab = ref('detail')
const categoryName = ref('')
const showShareDialog = ref(false)
const shareLink = ref('')
const relatedProducts = ref([])

// 生成分享链接
const generateShareLink = () => {
  if (product.value) {
    const baseUrl = window.location.origin
    shareLink.value = `${baseUrl}/product/${product.value.id}`
  }
}

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString()
}

// 处理数量变化
const handleQuantityChange = (value) => {
  if (value > product.value?.stock) {
    quantity.value = product.value.stock
    ElMessage.warning('超过库存数量')
  }
}

// 加入购物车
const addToCart = async () => {
  if (!product.value) return
  
  loading.value = true
  try {
    await cartStore.addToCart(product.value.id, quantity.value)
    ElMessage.success('加入购物车成功')
  } catch (error) {
    ElMessage.error(error.message || '加入购物车失败')
  } finally {
    loading.value = false
  }
}

// 立即购买
const buyNow = async () => {
  if (!product.value) return
  
  // 先加入购物车
  loading.value = true
  try {
    await cartStore.addToCart(product.value.id, quantity.value)
    // 跳转到购物车
    router.push('/cart')
  } catch (error) {
    ElMessage.error(error.message || '操作失败')
  } finally {
    loading.value = false
  }
}

// 复制链接
const copyLink = () => {
  navigator.clipboard.writeText(shareLink.value).then(() => {
    ElMessage.success('链接复制成功')
  }).catch(err => {
    console.error('复制失败:', err)
    ElMessage.error('链接复制失败')
  })
}

// 分享到微信
const shareToWeChat = () => {
  ElMessage.info('请在微信中打开链接分享')
  copyLink()
}

// 分享到微博
const shareToWeibo = () => {
  const url = encodeURIComponent(shareLink.value)
  const title = encodeURIComponent(product.value?.name || '商品')
  const weiboUrl = `https://service.weibo.com/share/share.php?url=${url}&title=${title}`
  window.open(weiboUrl, '_blank')
}

// 分享到QQ
const shareToQQ = () => {
  const url = encodeURIComponent(shareLink.value)
  const title = encodeURIComponent(product.value?.name || '商品')
  const qqUrl = `https://connect.qq.com/widget/shareqq/index.html?url=${url}&title=${title}`
  window.open(qqUrl, '_blank')
}

// 分享链接
const shareToLink = () => {
  if (navigator.share) {
    navigator.share({
      title: product.value?.name || '商品',
      url: shareLink.value
    }).catch(err => {
      console.error('分享失败:', err)
    })
  } else {
    copyLink()
    ElMessage.info('链接已复制，请粘贴分享')
  }
}

// 获取相关推荐商品
const getRelatedProducts = async () => {
  if (product.value) {
    try {
      // 检查是否有token
      const token = localStorage.getItem('token')
      if (!token) {
        // 无token时不请求推荐商品
        return
      }
      const response = await api.recommendation.related(product.value.id, { limit: 6 })
      relatedProducts.value = response.data
    } catch (error) {
      console.error('获取相关推荐商品失败:', error)
      // 忽略token无效的错误，不影响页面显示
    }
  }
}

// 记录浏览历史
const recordBrowseHistory = async () => {
  if (userStore.isLogin && product.value) {
    try {
      await api.browseHistory.record(product.value.id)
    } catch (error) {
      console.error('记录浏览历史失败:', error)
    }
  }
}

// 获取商品详情
const getProductDetail = async () => {
  const productId = route.params.id
  if (!productId) return
  
  loading.value = true
  try {
    const response = await api.product.detail(productId)
    product.value = response.data
    
    // 获取分类名称
    if (product.value.categoryId) {
      const categoriesResponse = await api.category.list()
      const findCategory = (categories, id) => {
        for (const category of categories) {
          if (category.id === product.value.categoryId) {
            return category.name
          }
          if (category.children) {
            const subCategory = findCategory(category.children, id)
            if (subCategory) return subCategory
          }
        }
        return ''
      }
      categoryName.value = findCategory(categoriesResponse.data, product.value.categoryId)
    }
  } catch (error) {
    console.error('获取商品详情失败:', error)
  } finally {
    loading.value = false
    // 生成分享链接
    generateShareLink()
    // 获取相关推荐商品
    getRelatedProducts()
    // 记录浏览历史
    recordBrowseHistory()
  }
}

// 初始化
onMounted(() => {
  getProductDetail()
})
</script>

<style scoped>
.product-detail {
  padding: 20px 0;
}

.breadcrumb {
  margin-bottom: 20px;
}

.product-info {
  background-color: #FFFFFF;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 30px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
}

.product-main {
  display: flex;
  gap: 40px;
  margin-bottom: 30px;
}

.product-image {
  flex: 0 0 400px;
}

.main-image {
  width: 100%;
  height: 400px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid var(--el-border-color);
}

.product-details {
  flex: 1;
  min-width: 0;
}

.product-name {
  font-size: 24px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 15px;
  line-height: 1.3;
}

.product-price {
  margin-bottom: 15px;
}

.price {
  font-size: 28px;
  font-weight: bold;
  color: var(--el-color-primary);
  margin-right: 15px;
}

.original-price {
  font-size: 18px;
  color: var(--el-text-color-placeholder);
  text-decoration: line-through;
}

.product-stats {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

.product-description {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  line-height: 1.5;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid var(--el-border-color);
}

.quantity-section {
  display: flex;
  align-items: center;
  margin-bottom: 30px;
}

.quantity-label {
  margin-right: 15px;
  font-size: 14px;
  color: var(--el-text-color-primary);
}

.action-buttons {
  display: flex;
  gap: 15px;
}

.add-cart-btn,
.buy-now-btn,
.share-btn {
  padding: 12px 32px;
  font-size: 16px;
}

.add-cart-btn {
  background-color: var(--el-color-primary);
  border-color: var(--el-color-primary);
}

.add-cart-btn:hover {
  background-color: var(--el-color-primary-light-3);
  border-color: var(--el-color-primary-light-3);
}

.buy-now-btn {
  background-color: #E8B4A0;
  border-color: #E8B4A0;
}

.buy-now-btn:hover {
  background-color: #D8A490;
  border-color: #D8A490;
}

.share-btn {
  background-color: var(--el-color-info);
  border-color: var(--el-color-info);
}

.share-btn:hover {
  background-color: var(--el-color-info-light-3);
  border-color: var(--el-color-info-light-3);
}

.share-content {
  padding: 20px 0;
}

.share-link {
  margin-bottom: 30px;
}

.share-platforms h4 {
  margin: 0 0 15px;
  font-size: 16px;
  color: var(--el-text-color-primary);
}

.platform-buttons {
  display: flex;
  gap: 20px;
  justify-content: center;
}

.platform-buttons .el-button {
  font-size: 24px;
  width: 50px;
  height: 50px;
}

.product-detail-section {
  margin-top: 30px;
}

.related-products {
  margin-top: 40px;
  padding-top: 30px;
  border-top: 1px solid var(--el-border-color);
}

.related-products .section-title {
  font-size: 20px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 20px;
  text-align: left;
  position: relative;
  padding-bottom: 10px;
}

.related-products .section-title::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  width: 60px;
  height: 2px;
  background-color: var(--el-color-primary);
}

.related-products .product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 15px;
  margin-top: 20px;
}

.related-products .product-item {
  background-color: #FFFFFF;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s ease;
  border: 1px solid var(--el-border-color);
}

.related-products .product-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(184, 149, 110, 0.15);
}

.related-products .product-image {
  height: 150px;
  overflow: hidden;
}

.related-products .product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.related-products .product-item:hover .product-image img {
  transform: scale(1.05);
}

.related-products .product-info {
  padding: 10px;
}

.related-products .product-name {
  font-size: 14px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 8px;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.related-products .product-price {
  display: flex;
  align-items: center;
  margin-bottom: 5px;
}

.related-products .price {
  font-size: 16px;
  font-weight: bold;
  color: var(--el-color-primary);
  margin-right: 8px;
}

.related-products .original-price {
  font-size: 12px;
  color: var(--el-text-color-placeholder);
  text-decoration: line-through;
}

.related-products .product-sales {
  font-size: 12px;
  color: var(--el-text-color-placeholder);
}

.section-tabs {
  background-color: #FFFFFF;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
}

.detail-content {
  padding: 20px 0;
  line-height: 1.6;
  color: var(--el-text-color-primary);
}

.detail-content img {
  max-width: 100%;
  height: auto;
  margin: 10px 0;
}

.specs-content {
  padding: 20px 0;
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
  color: var(--el-text-color-placeholder);
}

.empty-state i {
  font-size: 48px;
  margin-bottom: 16px;
  display: block;
}

.back-link {
  display: inline-block;
  margin-top: 20px;
  padding: 8px 24px;
  background-color: var(--el-color-primary);
  color: #FFFFFF;
  text-decoration: none;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.back-link:hover {
  background-color: var(--el-color-primary-light-3);
}

/* 响应式 */
@media (max-width: 768px) {
  .product-main {
    flex-direction: column;
    align-items: center;
  }
  
  .product-image {
    flex: 0 0 100%;
    max-width: 300px;
  }
  
  .main-image {
    height: 300px;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .add-cart-btn,
  .buy-now-btn {
    width: 100%;
  }
}
</style>
