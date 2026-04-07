<template>
  <div class="home">
    <!-- 轮播图 -->
    <div class="banner">
      <el-carousel :interval="5000" type="card" height="400px">
        <el-carousel-item v-for="item in bannerList" :key="item.id">
          <img :src="item.image" :alt="item.title" class="banner-image">
          <div class="banner-content">
            <h2 class="banner-title">{{ item.title }}</h2>
            <p class="banner-desc">{{ item.description }}</p>
            <router-link :to="item.link" class="banner-btn">立即查看</router-link>
          </div>
        </el-carousel-item>
      </el-carousel>
    </div>
    
    <!-- 分类导航 -->
    <div class="category-nav">
      <div class="container">
        <h3 class="section-title">商品分类</h3>
        <div class="category-grid">
          <div 
            v-for="category in categories" 
            :key="category.id"
            class="category-item card-shadow"
          >
            <router-link :to="`/product/list?categoryId=${category.id}`" class="category-link">
              <div class="category-icon">
                <el-icon :size="24" color="var(--el-color-primary)"><Grid /></el-icon>
              </div>
              <h4 class="category-name">{{ category.name }}</h4>
              <p class="category-count">{{ category.children?.length || 0 }} 个子分类</p>
            </router-link>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 热门商品 -->
    <div class="hot-products">
      <div class="container">
        <div class="section-header">
          <h3 class="section-title">热门商品</h3>
          <router-link to="/product/list?hot=1" class="more-link">查看更多 <i class="el-icon-arrow-right"></i></router-link>
        </div>
        <div class="product-grid">
          <div 
            v-for="product in hotProducts" 
            :key="product.id"
            class="product-item card-shadow"
          >
            <router-link :to="`/product/${product.id}`" class="product-link">
              <div class="product-image">
                <img :src="product.image" :alt="product.name">
              </div>
              <div class="product-info">
                <h4 class="product-name">{{ product.name }}</h4>
                <p class="product-desc">{{ product.description }}</p>
                <div class="product-price">
                  <span class="price">{{ product.price }}</span>
                  <span class="original-price" v-if="product.originalPrice > product.price">
                    {{ product.originalPrice }}
                  </span>
                </div>
                <div class="product-sales">已售 {{ product.sales }} 件</div>
              </div>
            </router-link>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 推荐商品 -->
    <div class="recommend-products">
      <div class="container">
        <div class="section-header">
          <h3 class="section-title">为您推荐</h3>
          <router-link to="/product/list?recommend=1" class="more-link">查看更多 <i class="el-icon-arrow-right"></i></router-link>
        </div>
        <div class="product-grid">
          <div 
            v-for="product in recommendProducts" 
            :key="product.id"
            class="product-item card-shadow"
          >
            <router-link :to="`/product/${product.id}`" class="product-link">
              <div class="product-image">
                <img :src="product.image" :alt="product.name">
              </div>
              <div class="product-info">
                <h4 class="product-name">{{ product.name }}</h4>
                <p class="product-desc">{{ product.description }}</p>
                <div class="product-price">
                  <span class="price">{{ product.price }}</span>
                  <span class="original-price" v-if="product.originalPrice > product.price">
                    {{ product.originalPrice }}
                  </span>
                </div>
                <div class="product-sales">已售 {{ product.sales }} 件</div>
              </div>
            </router-link>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 个性化推荐商品 -->
    <div v-if="userStore.isLogin && personalizedProducts.length > 0" class="personalized-products">
      <div class="container">
        <div class="section-header">
          <h3 class="section-title">个性化推荐</h3>
          <router-link to="/product/list?personalized=1" class="more-link">查看更多 <i class="el-icon-arrow-right"></i></router-link>
        </div>
        <div class="product-grid">
          <div 
            v-for="product in personalizedProducts" 
            :key="product.id"
            class="product-item card-shadow"
          >
            <router-link :to="`/product/${product.id}`" class="product-link">
              <div class="product-image">
                <img :src="product.image" :alt="product.name">
              </div>
              <div class="product-info">
                <h4 class="product-name">{{ product.name }}</h4>
                <p class="product-desc">{{ product.description }}</p>
                <div class="product-price">
                  <span class="price">{{ product.price }}</span>
                  <span class="original-price" v-if="product.originalPrice > product.price">
                    {{ product.originalPrice }}
                  </span>
                </div>
                <div class="product-sales">已售 {{ product.sales }} 件</div>
              </div>
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { api } from '@/utils/request'
import { getBannerList } from '@/api/banner'
import { Grid } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const bannerList = ref([])

const categories = ref([])
const hotProducts = ref([])
const recommendProducts = ref([])
const personalizedProducts = ref([])
const userStore = useUserStore()

// 获取轮播图列表
const getBanners = async () => {
  try {
    const response = await getBannerList()
    if (response.code === 200) {
      bannerList.value = response.data
    }
  } catch (error) {
    console.error('获取轮播图失败:', error)
  }
}

// 获取分类列表
const getCategories = async () => {
  try {
    const response = await api.category.list()
    categories.value = response.data
  } catch (error) {
    console.error('获取分类失败:', error)
  }
}

// 获取热门商品
const getHotProducts = async () => {
  try {
    const response = await api.product.hot({ limit: 6 })
    hotProducts.value = response.data
  } catch (error) {
    console.error('获取热门商品失败:', error)
  }
}

// 获取推荐商品
const getRecommendProducts = async () => {
  try {
    const response = await api.product.recommend({ limit: 6 })
    recommendProducts.value = response.data
  } catch (error) {
    console.error('获取推荐商品失败:', error)
  }
}

// 获取个性化推荐商品
const getPersonalizedProducts = async () => {
  if (userStore.isLogin) {
    try {
      const response = await api.recommendation.recommended({ limit: 6 })
      personalizedProducts.value = response.data
    } catch (error) {
      console.error('获取个性化推荐商品失败:', error)
    }
  }
}

// 初始化
onMounted(async () => {
  await Promise.all([
    getBanners(),
    getCategories(),
    getHotProducts(),
    getRecommendProducts(),
    getPersonalizedProducts()
  ])
})
</script>

<style scoped>
.home {
  background-color: var(--el-bg-color);
}

/* 轮播图 */
.banner {
  position: relative;
  margin-bottom: 40px;
}

.banner-image {
  width: 100%;
  height: 400px;
  object-fit: cover;
  border-radius: 4px;
}

.banner-content {
  position: absolute;
  top: 50%;
  left: 10%;
  transform: translateY(-50%);
  color: #FFFFFF;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
  max-width: 400px;
}

.banner-title {
  font-size: 32px;
  font-weight: bold;
  margin: 0 0 10px;
  font-family: 'Times New Roman', serif;
}

.banner-desc {
  font-size: 16px;
  margin: 0 0 20px;
  line-height: 1.5;
}

.banner-btn {
  display: inline-block;
  padding: 10px 24px;
  background-color: var(--el-color-primary);
  color: #FFFFFF;
  text-decoration: none;
  border-radius: 4px;
  font-size: 14px;
  transition: all 0.3s ease;
  border: 1px solid transparent;
}

.banner-btn:hover {
  background-color: var(--el-color-primary-light-3);
  transform: translateY(-2px);
}

/* 分类导航 */
.category-nav {
  padding: 40px 0;
  background-color: #FFFFFF;
  margin-bottom: 40px;
}

.section-title {
  font-size: 20px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 20px;
  text-align: center;
  position: relative;
  padding-bottom: 10px;
}

.section-title::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 60px;
  height: 2px;
  background-color: var(--el-color-primary);
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-top: 30px;
}

.category-item {
  background-color: #FFFFFF;
  border-radius: 8px;
  padding: 30px 20px;
  text-align: center;
  transition: all 0.3s ease;
  border: 1px solid var(--el-border-color);
}

.category-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(184, 149, 110, 0.15);
}

.category-icon {
  width: 60px;
  height: 60px;
  background-color: var(--el-bg-color-overlay);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 15px;
  font-size: 24px;
  color: var(--el-color-primary);
}

.category-name {
  font-size: 16px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 8px;
}

.category-count {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 0;
}

.category-link {
  text-decoration: none;
  display: block;
  color: inherit;
}

/* 商品区域 */
.hot-products,
.recommend-products,
.personalized-products {
  padding: 40px 0;
  margin-bottom: 40px;
}

.personalized-products {
  background-color: #f9f9f9;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.more-link {
  color: var(--el-text-color-secondary);
  text-decoration: none;
  font-size: 14px;
  transition: color 0.3s ease;
  display: flex;
  align-items: center;
}

.more-link:hover {
  color: var(--el-color-primary);
}

.more-link i {
  margin-left: 5px;
  font-size: 12px;
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 15px;
  margin-top: 30px;
  width: 100%;
  max-width: 100%;
}

.product-item {
  background-color: #FFFFFF;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s ease;
  border: 1px solid var(--el-border-color);
}

.product-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(184, 149, 110, 0.15);
}

.product-link {
  text-decoration: none;
  display: block;
  color: inherit;
}

.product-image {
  height: 200px;
  overflow: hidden;
}

.product-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.product-item:hover .product-image img {
  transform: scale(1.05);
}

.product-info {
  padding: 15px;
}

.product-name {
  font-size: 16px;
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

.product-desc {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 0 0 12px;
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
  margin-bottom: 8px;
}

.price {
  font-size: 18px;
  font-weight: bold;
  color: var(--el-color-primary);
  margin-right: 10px;
}

.original-price {
  font-size: 14px;
  color: var(--el-text-color-placeholder);
  text-decoration: line-through;
}

.product-sales {
  font-size: 12px;
  color: var(--el-text-color-placeholder);
}

/* 响应式 */
@media (max-width: 768px) {
  .banner-content {
    left: 5%;
    max-width: 300px;
  }
  
  .banner-title {
    font-size: 24px;
  }
  
  .banner-desc {
    font-size: 14px;
  }
  
  .category-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .product-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .product-image {
    height: 150px;
  }
}
</style>
