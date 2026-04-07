<template>
  <div class="product-list">
    <div class="container">
      <!-- 面包屑导航 -->
      <el-breadcrumb separator="/" class="breadcrumb">
        <el-breadcrumb-item><router-link to="/">首页</router-link></el-breadcrumb-item>
        <el-breadcrumb-item v-if="categoryName">{{ categoryName }}</el-breadcrumb-item>
        <el-breadcrumb-item v-else-if="filterForm.keyword">搜索: {{ filterForm.keyword }}</el-breadcrumb-item>
        <el-breadcrumb-item v-else>全部商品</el-breadcrumb-item>
      </el-breadcrumb>
      
      <div class="content-wrapper">
        <!-- 左侧分类树 -->
        <div class="sidebar">
          <div class="sidebar-section">
            <h3 class="sidebar-title">商品分类</h3>
            <div class="category-tree">
              <el-tree
                :data="categories"
                node-key="id"
                :expand-on-click-node="false"
                :default-expanded-keys="expandedKeys"
                @node-click="handleCategoryClick"
              >
                <template #default="{ node, data }">
                  <span class="category-node">
                    <span class="category-name">{{ data.name }}</span>
                    <span class="category-count" v-if="data.productCount">({{ data.productCount }})</span>
                  </span>
                </template>
              </el-tree>
            </div>
          </div>
          
          <!-- 价格区间 -->
          <div class="sidebar-section">
            <h3 class="sidebar-title">价格区间</h3>
            <div class="price-range">
              <el-slider
                v-model="priceRange"
                :min="0"
                :max="10000"
                range
                @change="handlePriceRangeChange"
              />
              <div class="price-inputs">
                <el-input-number v-model="filterForm.minPrice" placeholder="最低" :min="0" size="small" style="width: 80px; margin-right: 10px"></el-input-number>
                <span>-</span>
                <el-input-number v-model="filterForm.maxPrice" placeholder="最高" :min="0" size="small" style="width: 80px; margin-left: 10px"></el-input-number>
                <el-button type="primary" size="small" @click="handleFilter" style="margin-left: 10px">确定</el-button>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 右侧商品列表 -->
        <div class="main-content">
          <!-- 筛选和排序 -->
          <div class="filter-section">
            <div class="filter-tags">
              <el-tag v-if="filterForm.categoryId" closable @close="clearCategory">
                分类: {{ categoryName }}
              </el-tag>
              <el-tag v-if="filterForm.minPrice || filterForm.maxPrice" closable @close="clearPrice">
                价格: {{ filterForm.minPrice || 0 }}-{{ filterForm.maxPrice || '∞' }}
              </el-tag>
              <el-tag v-if="filterForm.keyword" closable @close="clearKeyword">
                搜索: {{ filterForm.keyword }}
              </el-tag>
            </div>
            
            <div class="sort-section">
              <span class="sort-label">排序：</span>
              <el-radio-group v-model="filterForm.sort" @change="handleFilter">
                <el-radio-button label="">默认</el-radio-button>
                <el-radio-button label="sales_desc">销量</el-radio-button>
                <el-radio-button label="price_asc">价格↑</el-radio-button>
                <el-radio-button label="price_desc">价格↓</el-radio-button>
                <el-radio-button label="created_desc">最新</el-radio-button>
              </el-radio-group>
            </div>
          </div>
          
          <!-- 商品列表 -->
          <div class="product-grid" v-if="products.length > 0">
            <div 
              v-for="product in products" 
              :key="product.id"
              class="product-item card-shadow"
            >
              <router-link :to="`/product/${product.id}`" class="product-link">
                <div class="product-image">
                  <img :src="product.image" :alt="product.name">
                  <div class="product-badges">
                    <span class="badge hot" v-if="product.sales > 1000">热卖</span>
                    <span class="badge new" v-if="isNewProduct(product)">新品</span>
                  </div>
                </div>
                <div class="product-info">
                  <h4 class="product-name">{{ product.name }}</h4>
                  <p class="product-desc">{{ product.description }}</p>
                  <div class="product-price">
                    <span class="price">¥{{ product.price.toFixed(2) }}</span>
                    <span class="original-price" v-if="product.originalPrice > product.price">
                      ¥{{ product.originalPrice.toFixed(2) }}
                    </span>
                  </div>
                  <div class="product-sales">已售 {{ formatSales(product.sales) }} 件</div>
                </div>
              </router-link>
            </div>
          </div>
          
          <!-- 空状态 -->
          <div class="empty-state" v-else-if="!loading">
            <i class="el-icon-s-goods"></i>
            <p>暂无商品</p>
            <router-link to="/" class="back-link">返回首页</router-link>
          </div>
          
          <!-- 加载中 -->
          <div class="loading" v-else>
            <el-icon class="is-loading"><i class="el-icon-loading"></i></el-icon>
            <span>加载中...</span>
          </div>
          
          <!-- 分页 -->
          <div class="pagination" v-if="total > 0">
            <el-pagination
              v-model:current-page="filterForm.page"
              v-model:page-size="filterForm.size"
              :page-sizes="[12, 24, 36]"
              layout="total, sizes, prev, pager, next, jumper"
              :total="total"
              @size-change="handleSizeChange"
              @current-change="handleCurrentChange"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { api } from '@/utils/request'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const products = ref([])
const total = ref(0)
const categories = ref([])
const categoryName = ref('')
const expandedKeys = ref([])
const priceRange = ref([0, 10000])

const filterForm = reactive({
  page: 1,
  size: 24,
  categoryId: '',
  keyword: '',
  sort: '',
  minPrice: null,
  maxPrice: null
})

// 计算分类名称
const getCategoryName = (id) => {
  if (!id) return ''
  const findCategory = (categories, id) => {
    for (const category of categories) {
      if (category.id === Number(id)) {
        return category.name
      }
      if (category.children) {
        const result = findCategory(category.children, id)
        if (result) return result
      }
    }
    return ''
  }
  return findCategory(categories.value, id)
}

// 格式化销量
const formatSales = (sales) => {
  if (sales >= 10000) {
    return (sales / 10000).toFixed(1) + '万'
  }
  return sales
}

// 判断是否为新品
const isNewProduct = (product) => {
  if (!product.createdAt) return false
  const createDate = new Date(product.createdAt)
  const now = new Date()
  const diffDays = (now - createDate) / (1000 * 60 * 60 * 24)
  return diffDays <= 30
}

// 获取分类列表
const getCategories = async () => {
  try {
    const response = await api.category.list()
    categories.value = response.data
    // 默认展开所有分类
    const expandAll = (nodes) => {
      nodes.forEach(node => {
        if (node.children && node.children.length > 0) {
          expandedKeys.value.push(node.id)
          expandAll(node.children)
        }
      })
    }
    expandAll(categories.value)
  } catch (error) {
    console.error('获取分类失败:', error)
  }
}

// 获取商品列表
const getProducts = async () => {
  loading.value = true
  try {
    const params = {
      page: filterForm.page,
      size: filterForm.size,
      categoryId: filterForm.categoryId,
      keyword: filterForm.keyword,
      sort: filterForm.sort,
      minPrice: filterForm.minPrice,
      maxPrice: filterForm.maxPrice
    }
    
    const response = await api.product.list(params)
    products.value = response.data.records
    total.value = response.data.total
  } catch (error) {
    console.error('获取商品列表失败:', error)
  } finally {
    loading.value = false
  }
}

// 处理分类点击


// 处理价格区间变化
const handlePriceRangeChange = (value) => {
  filterForm.minPrice = value[0]
  filterForm.maxPrice = value[1]
  filterForm.page = 1
  getProducts()
}

// 处理筛选
const handleFilter = () => {
  filterForm.page = 1
  getProducts()
}

// 处理分页大小变化
const handleSizeChange = (size) => {
  filterForm.size = size
  getProducts()
}

// 处理页码变化
const handleCurrentChange = (page) => {
  filterForm.page = page
  getProducts()
}

// 清除分类
const clearCategory = () => {
  filterForm.categoryId = ''
  categoryName.value = ''
  filterForm.page = 1
  getProducts()
}

// 清除价格
const clearPrice = () => {
  filterForm.minPrice = null
  filterForm.maxPrice = null
  priceRange.value = [0, 10000]
  filterForm.page = 1
  getProducts()
}

// 清除关键词
const clearKeyword = () => {
  filterForm.keyword = ''
  filterForm.page = 1
  getProducts()
}

// 监听路由参数变化
watch(() => route.query, (newQuery) => {
  if (newQuery.categoryId) {
    filterForm.categoryId = newQuery.categoryId
    categoryName.value = getCategoryName(newQuery.categoryId)
  } else {
    filterForm.categoryId = ''
    categoryName.value = ''
  }
  
  if (newQuery.keyword) {
    filterForm.keyword = newQuery.keyword
  } else {
    filterForm.keyword = ''
  }
  
  if (newQuery.hot) {
    filterForm.sort = 'sales_desc'
  } else if (newQuery.recommend) {
    filterForm.sort = ''
  } else if (newQuery.personalized) {
    filterForm.sort = ''
  }
  
  filterForm.page = 1
  getProducts()
}, { immediate: true })

// 处理分类点击
const handleCategoryClick = (data) => {
  filterForm.categoryId = data.id
  categoryName.value = data.name
  filterForm.page = 1
  getProducts()
  
  // 更新路由参数
  router.push({
    path: '/product/list',
    query: {
      categoryId: data.id
    }
  })
}

// 初始化
onMounted(async () => {
  await getCategories()
  // getProducts() 会在 watch 中调用
})
</script>

<style scoped>
.product-list {
  padding: 20px 0;
  background-color: var(--el-bg-color);
}

.breadcrumb {
  margin-bottom: 20px;
}

.content-wrapper {
  display: flex;
  gap: 20px;
}

/* 左侧边栏 */
.sidebar {
  flex: 0 0 240px;
  background-color: #FFFFFF;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
}

.sidebar-section {
  margin-bottom: 30px;
}

.sidebar-section:last-child {
  margin-bottom: 0;
}

.sidebar-title {
  font-size: 16px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 15px;
  position: relative;
  padding-left: 10px;
}

.sidebar-title::before {
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

.category-tree {
  max-height: 400px;
  overflow-y: auto;
}

.category-node {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  cursor: pointer;
  transition: color 0.3s ease;
}

.category-node:hover {
  color: var(--el-color-primary);
}

.category-name {
  flex: 1;
  font-size: 14px;
}

.category-count {
  font-size: 12px;
  color: var(--el-text-color-placeholder);
  margin-left: 10px;
}

.price-range {
  padding: 10px 0;
}

.price-inputs {
  display: flex;
  align-items: center;
  margin-top: 15px;
  flex-wrap: wrap;
  gap: 10px;
}

/* 右侧主内容 */
.main-content {
  flex: 1;
  min-width: 0;
}

.filter-section {
  background-color: #FFFFFF;
  border-radius: 8px;
  padding: 15px 20px;
  margin-bottom: 20px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 15px;
}

.filter-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.sort-section {
  display: flex;
  align-items: center;
  gap: 10px;
}

.sort-label {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  white-space: nowrap;
}

/* 商品网格 */
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 15px;
  margin-bottom: 30px;
}

.product-item {
  background-color: #FFFFFF;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s ease;
  border: 1px solid var(--el-border-color);
  position: relative;
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
  position: relative;
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

.product-badges {
  position: absolute;
  top: 10px;
  left: 10px;
  display: flex;
  gap: 5px;
}

.badge {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 10px;
  color: #FFFFFF;
  font-weight: bold;
}

.badge.hot {
  background-color: #F56C6C;
}

.badge.new {
  background-color: #67C23A;
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

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 30px;
  background-color: #FFFFFF;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
}

.empty-state {
  text-align: center;
  padding: 60px 0;
  background-color: #FFFFFF;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
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

.loading {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 60px 0;
  background-color: #FFFFFF;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
  color: var(--el-text-color-secondary);
}

.loading i {
  font-size: 24px;
  margin-right: 10px;
}

/* 响应式 */
@media (max-width: 1024px) {
  .content-wrapper {
    flex-direction: column;
  }
  
  .sidebar {
    flex: 1;
    max-width: 100%;
  }
  
  .category-tree {
    max-height: 200px;
  }
}

@media (max-width: 768px) {
  .filter-section {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .product-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 10px;
  }
  
  .product-image {
    height: 150px;
  }
  
  .product-info {
    padding: 10px;
  }
  
  .product-name {
    font-size: 14px;
  }
  
  .product-desc {
    font-size: 12px;
  }
  
  .price {
    font-size: 16px;
  }
}

@media (max-width: 480px) {
  .product-grid {
    grid-template-columns: 1fr;
  }
  
  .price-inputs {
    flex-direction: column;
    align-items: stretch;
  }
  
  .price-inputs .el-input-number {
    width: 100% !important;
    margin: 0 !important;
  }
  
  .price-inputs .el-button {
    margin: 0 !important;
  }
}
</style>
