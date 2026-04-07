import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/Home.vue'),
    meta: { title: '首页', requiresAuth: false }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录', requiresAuth: false }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/Register.vue'),
    meta: { title: '注册', requiresAuth: false }
  },
  {
    path: '/product/list',
    name: 'ProductList',
    component: () => import('@/views/ProductList.vue'),
    meta: { title: '商品列表', requiresAuth: false }
  },
  {
    path: '/product/:id',
    name: 'ProductDetail',
    component: () => import('@/views/ProductDetail.vue'),
    meta: { title: '商品详情', requiresAuth: false }
  },
  {
    path: '/cart',
    name: 'Cart',
    component: () => import('@/views/Cart.vue'),
    meta: { title: '购物车', requiresAuth: true }
  },
  {
    path: '/order/confirm',
    name: 'OrderConfirm',
    component: () => import('@/views/OrderConfirm.vue'),
    meta: { title: '确认订单', requiresAuth: true }
  },
  {
    path: '/order/list',
    name: 'OrderList',
    component: () => import('@/views/OrderList.vue'),
    meta: { title: '我的订单', requiresAuth: true }
  },
  {
    path: '/order/:id',
    name: 'OrderDetail',
    component: () => import('@/views/OrderDetail.vue'),
    meta: { title: '订单详情', requiresAuth: true }
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('@/views/Profile.vue'),
    meta: { title: '个人中心', requiresAuth: true }
  },
  {
    path: '/address',
    name: 'Address',
    component: () => import('@/views/Address.vue'),
    meta: { title: '地址管理', requiresAuth: true }
  },
  { path: '/:pathMatch(.*)*', name: 'NotFound', component: () => import('@/views/NotFound.vue'), meta: { title: '页面不存在' } },
  
  // 管理端路由
  {
    path: '/admin/login',
    name: 'AdminLogin',
    component: () => import('@/views/admin/Login.vue'),
    meta: { title: '管理登录', requiresAuth: false }
  },
  {
    path: '/admin',
    name: 'AdminHome',
    component: () => import('@/views/admin/Home.vue'),
    meta: { title: '管理首页', requiresAuth: true, requiresAdmin: true },
    children: [
      {
        path: '',
        name: 'AdminDashboard',
        component: () => import('@/views/admin/Dashboard.vue'),
        meta: { title: '管理首页' }
      },
      {
        path: 'product',
        name: 'AdminProduct',
        component: () => import('@/views/admin/Product.vue'),
        meta: { title: '商品管理' }
      },
      {
        path: 'user',
        name: 'AdminUser',
        component: () => import('@/views/admin/User.vue'),
        meta: { title: '用户管理' }
      },
      {
        path: 'order',
        name: 'AdminOrder',
        component: () => import('@/views/admin/Order.vue'),
        meta: { title: '订单管理' }
      },
      {
        path: 'category',
        name: 'AdminCategory',
        component: () => import('@/views/admin/Category.vue'),
        meta: { title: '分类管理' }
      },
      {
        path: 'stats',
        name: 'AdminStats',
        component: () => import('@/views/admin/Statistics.vue'),
        meta: { title: '数据统计' }
      },
      {
        path: 'banner',
        name: 'AdminBanner',
        component: () => import('@/views/admin/Banner.vue'),
        meta: { title: '轮播图管理' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  // 设置页面标题
  if (to.meta.title) {
    document.title = `如你所愿 - ${to.meta.title}`
  }
  
  // 检查是否需要认证
  const requiresAuth = to.meta.requiresAuth !== false
  const token = localStorage.getItem('token')
  
  if (requiresAuth && !token) {
    // 跳转到登录页
    if (to.path.startsWith('/admin')) {
      next({ path: '/admin/login', query: { redirect: to.fullPath } })
    } else {
      next({ path: '/login', query: { redirect: to.fullPath } })
    }
  } else if (to.meta.requiresAdmin) {
    // 检查是否是管理员
    const user = JSON.parse(localStorage.getItem('user') || '{}')
    if (user.role !== 1) {
      next({ path: '/', replace: true })
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
