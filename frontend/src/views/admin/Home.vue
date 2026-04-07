<template>
  <div class="admin-home">
    <div class="admin-header">
      <div class="admin-header-left">
        <h1 class="admin-logo">如你所愿 - 管理系统</h1>
      </div>
      <div class="admin-header-right">
        <el-dropdown>
          <span class="admin-user">
            <el-avatar :size="32" :src="user.avatar || 'https://i.cetsteam.com/imgs/2026/04/01/f37915722ac27d20.jpg'"></el-avatar>
            <span class="admin-username">{{ user.username }}</span>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="handleLogout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
    
    <div class="admin-container">
      <div class="admin-sidebar">
        <el-menu
          :default-active="activeMenu"
          class="admin-menu"
          @select="handleMenuSelect"
          background-color="#f8f9fa"
          text-color="#333"
          active-text-color="#409eff"
        >
          <el-menu-item index="">
            <el-icon><HomeFilled /></el-icon>
            <template #title>首页</template>
          </el-menu-item>
          <el-menu-item index="product">
            <el-icon><Goods /></el-icon>
            <template #title>商品管理</template>
          </el-menu-item>
          <el-menu-item index="user">
            <el-icon><UserFilled /></el-icon>
            <template #title>用户管理</template>
          </el-menu-item>
          <el-menu-item index="order">
            <el-icon><ShoppingCart /></el-icon>
            <template #title>订单管理</template>
          </el-menu-item>
          <el-menu-item index="category">
            <el-icon><Collection /></el-icon>
            <template #title>分类管理</template>
          </el-menu-item>
          <el-menu-item index="banner">
            <el-icon><Picture /></el-icon>
            <template #title>轮播图管理</template>
          </el-menu-item>
          <el-menu-item index="stats">
            <el-icon><DataAnalysis /></el-icon>
            <template #title>数据统计</template>
          </el-menu-item>
        </el-menu>
      </div>
      
      <div class="admin-content">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElIcon } from 'element-plus'
import { HomeFilled, Goods, UserFilled, ShoppingCart, Collection, DataAnalysis, Picture } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

const user = ref(JSON.parse(localStorage.getItem('user') || '{}'))

const activeMenu = computed(() => {
  // 从绝对路径中提取相对路径作为菜单索引
  const path = route.path
  if (path === '/admin') {
    return ''
  } else {
    return path.replace('/admin/', '')
  }
})

const handleMenuSelect = (key) => {
  // 处理菜单选择，使用相对路径导航
  if (key === '') {
    router.push('/admin')
  } else {
    // 对于其他菜单，使用相对路径
    router.push(`/admin/${key}`)
  }
}

const handleLogout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  ElMessage.success('退出登录成功')
  router.push('/admin/login')
}
</script>

<style scoped>
.admin-home {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f8f9fa;
}

.admin-header {
  height: 60px;
  background: #fff;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.admin-logo {
  font-size: 20px;
  font-weight: 600;
  color: var(--el-color-primary);
  margin: 0;
}

.admin-user {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.admin-user:hover {
  background: #f0f2f5;
}

.admin-username {
  margin-left: 8px;
  font-size: 14px;
  color: #333;
}

.admin-container {
  flex: 1;
  display: flex;
  overflow: hidden;
}

.admin-sidebar {
  width: 200px;
  background: #f8f9fa;
  border-right: 1px solid #e9ecef;
  overflow-y: auto;
}

.admin-menu {
  border-right: none;
  min-height: 100%;
}

.admin-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background: #f8f9fa;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .admin-sidebar {
    width: 180px;
  }
  
  .admin-content {
    padding: 10px;
  }
}
</style>