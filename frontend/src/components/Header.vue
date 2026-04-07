<template>
  <header class="header">
    <div class="container">
      <div class="header-content">
        <!-- Logo -->
        <div class="logo">
          <router-link to="/" class="logo-link">
            <h1 class="logo-text">如你所愿</h1>
          </router-link>
        </div>
        
        <!-- 主导航 -->
        <nav class="main-nav">
          <ul class="nav-menu">
            <li class="nav-item">
              <router-link to="/" class="nav-link">首页</router-link>
            </li>
            <li class="nav-item">
              <router-link to="/product/list" class="nav-link">全部商品</router-link>
            </li>
            <li class="nav-item">
              <a href="#" class="nav-link">分类</a>
              <div class="category-dropdown">
                <div class="category-list" v-if="categories.length > 0">
                  <div 
                    v-for="category in categories" 
                    :key="category.id"
                    class="category-item"
                  >
                    <router-link :to="`/product/list?categoryId=${category.id}`" class="category-link">
                      {{ category.name }}
                    </router-link>
                    <div v-if="category.children && category.children.length > 0" class="sub-category">
                      <router-link 
                        v-for="sub in category.children" 
                        :key="sub.id"
                        :to="`/product/list?categoryId=${sub.id}`"
                        class="sub-category-link"
                      >
                        {{ sub.name }}
                      </router-link>
                    </div>
                  </div>
                </div>
                <div v-else class="loading">加载中...</div>
              </div>
            </li>
            <li class="nav-item">
              <router-link to="/product/list?sort=created_desc" class="nav-link">新品上市</router-link>
            </li>
            <li class="nav-item">
              <router-link to="/product/list?sort=sales_desc" class="nav-link">热卖商品</router-link>
            </li>
          </ul>
        </nav>
        
        <!-- 右侧功能区 -->
        <div class="header-actions">
          <!-- 搜索框 -->
          <div class="search-box">
            <input 
              type="text" 
              placeholder="搜索商品..."
              class="search-input"
              v-model="searchKeyword"
              @keyup.enter="handleSearch"
            >
            <button class="search-btn" @click="handleSearch">
              <i class="el-icon-search"></i>
            </button>
          </div>
          
          <!-- 购物车 -->
          <div class="cart-icon">
            <router-link to="/cart" class="cart-link">
              <i class="el-icon-shopping-cart-full"></i>
              <span class="cart-count" v-if="cartCount > 0">{{ cartCount }}</span>
            </router-link>
          </div>
          
          <!-- 用户中心 -->
          <div class="user-center">
            <div v-if="userStore.isLoggedIn" class="user-dropdown">
              <span class="user-name">{{ userStore.user?.username || '用户' }}</span>
              <div class="user-menu">
                <router-link to="/profile" class="user-menu-item">个人中心</router-link>
                <router-link to="/order/list" class="user-menu-item">我的订单</router-link>
                <a href="#" class="user-menu-item" @click="handleLogout">退出登录</a>
              </div>
            </div>
            <div v-else>
              <router-link to="/login" class="login-link">登录</router-link>
              <span class="divider">|</span>
              <router-link to="/register" class="register-link">注册</router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'
import { api } from '@/utils/request'

const router = useRouter()
const userStore = useUserStore()
const cartStore = useCartStore()
const searchKeyword = ref('')
const categories = ref([])

// 购物车数量
const cartCount = computed(() => cartStore.cartCount)

// 处理搜索
const handleSearch = () => {
  if (searchKeyword.value.trim()) {
    router.push(`/product/list?keyword=${encodeURIComponent(searchKeyword.value)}`)
  }
}

// 处理登出
const handleLogout = () => {
  userStore.logout()
  router.push('/login')
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

// 初始化
onMounted(async () => {
  // 获取分类
  await getCategories()
  
  // 如果已登录，获取用户信息和购物车
  if (userStore.isLoggedIn) {
    try {
      await userStore.getUserInfo()
      await cartStore.getCartList()
    } catch (error) {
      console.error('初始化失败:', error)
    }
  }
})
</script>

<style scoped>
.header {
  background-color: #FFFFFF;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
  position: sticky;
  top: 0;
  z-index: 1000;
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 60px;
}

.logo {
  flex: 0 0 150px;
}

.logo-link {
  display: block;
}

.logo-text {
  font-size: 24px;
  font-weight: bold;
  color: var(--el-color-primary);
  margin: 0;
  font-family: 'Times New Roman', serif;
}

.main-nav {
  flex: 1;
  margin: 0 20px;
}

.nav-menu {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
}

.nav-item {
  position: relative;
  margin: 0 15px;
}

.nav-link {
  display: block;
  padding: 0 10px;
  line-height: 60px;
  color: var(--el-text-color-primary);
  text-decoration: none;
  font-size: 14px;
  transition: all 0.3s ease;
  position: relative;
}

.nav-link:hover {
  color: var(--el-color-primary);
}

/* 分类下拉菜单 */
.category-dropdown {
  position: absolute;
  top: 60px;
  left: 0;
  width: 200px;
  background-color: #FFFFFF;
  box-shadow: 0 4px 12px rgba(184, 149, 110, 0.15);
  border-radius: 4px;
  padding: 10px 0;
  display: none;
  z-index: 1001;
}

.nav-item:hover .category-dropdown {
  display: block;
}

.category-list {
  max-height: 300px;
  overflow-y: auto;
}

.category-item {
  padding: 0 15px;
}

.category-link {
  display: block;
  padding: 8px 0;
  color: var(--el-text-color-primary);
  text-decoration: none;
  font-size: 14px;
  transition: color 0.3s ease;
}

.category-link:hover {
  color: var(--el-color-primary);
}

.sub-category {
  margin-top: 5px;
  padding-left: 15px;
  border-left: 1px solid var(--el-border-color);
}

.sub-category-link {
  display: block;
  padding: 6px 0;
  color: var(--el-text-color-secondary);
  text-decoration: none;
  font-size: 12px;
  transition: color 0.3s ease;
}

.sub-category-link:hover {
  color: var(--el-color-primary);
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 20px;
}

.search-box {
  position: relative;
  width: 200px;
}

.search-input {
  width: 100%;
  height: 32px;
  padding: 0 36px 0 12px;
  border: 1px solid var(--el-border-color);
  border-radius: 16px;
  background-color: var(--el-bg-color);
  font-size: 14px;
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: var(--el-color-primary);
  width: 250px;
}

.search-btn {
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: var(--el-text-color-secondary);
  cursor: pointer;
  font-size: 14px;
  padding: 0;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.search-btn:hover {
  color: var(--el-color-primary);
}

.cart-icon {
  position: relative;
}

.cart-link {
  display: block;
  color: var(--el-text-color-primary);
  font-size: 20px;
  text-decoration: none;
  position: relative;
}

.cart-count {
  position: absolute;
  top: -8px;
  right: -8px;
  background-color: var(--el-color-primary);
  color: #FFFFFF;
  font-size: 12px;
  font-weight: bold;
  border-radius: 50%;
  width: 18px;
  height: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.user-center {
  position: relative;
}

.user-name {
  display: block;
  color: var(--el-text-color-primary);
  cursor: pointer;
  padding: 0 10px;
  line-height: 32px;
  border-radius: 4px;
  transition: background-color 0.3s ease;
}

.user-name:hover {
  background-color: var(--el-bg-color-overlay);
}

.user-dropdown:hover .user-menu {
  display: block;
}

.user-menu {
  position: absolute;
  top: 32px;
  right: 0;
  width: 120px;
  background-color: #FFFFFF;
  box-shadow: 0 4px 12px rgba(184, 149, 110, 0.15);
  border-radius: 4px;
  padding: 5px 0;
  display: none;
  z-index: 1001;
}

.user-menu-item {
  display: block;
  padding: 8px 15px;
  color: var(--el-text-color-primary);
  text-decoration: none;
  font-size: 14px;
  transition: background-color 0.3s ease;
}

.user-menu-item:hover {
  background-color: var(--el-bg-color-overlay);
  color: var(--el-color-primary);
}

.login-link,
.register-link {
  color: var(--el-text-color-primary);
  text-decoration: none;
  font-size: 14px;
  transition: color 0.3s ease;
}

.login-link:hover,
.register-link:hover {
  color: var(--el-color-primary);
}

.divider {
  color: var(--el-text-color-placeholder);
  margin: 0 8px;
}

.loading {
  padding: 20px;
  text-align: center;
  color: var(--el-text-color-secondary);
  font-size: 14px;
}
</style>
