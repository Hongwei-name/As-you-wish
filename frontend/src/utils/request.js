import axios from 'axios'

// 创建 axios 实例
const service = axios.create({
  baseURL: 'http://localhost:8080', // 后端 API 地址
  timeout: 10000, // 超时时间
  headers: {
    'Content-Type': 'application/json'
  }
})

// 请求拦截器
service.interceptors.request.use(
  config => {
    // 添加 token
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  response => {
    const res = response.data
    
    // 检查响应状态
    if (res.code !== 200) {
      // 处理错误
      if (res.code === 401) {
        // 未登录或 token 过期
        localStorage.removeItem('token')
        window.location.href = '/login'
      }
      return Promise.reject(new Error(res.message || '请求失败'))
    }
    return res
  },
  error => {
    // 网络错误
    const message = error.message || '网络异常'
    return Promise.reject(new Error(message))
  }
)

export default service

// 导出 API 方法
export const api = {
  // 用户相关
  user: {
    register: (data) => service.post('/api/user/register', data),
    login: (data) => service.post('/api/user/login', data),
    getInfo: () => service.get('/api/user/info'),
    update: (data) => service.put('/api/user/update', data),
    changePassword: (data) => service.put('/api/user/password', data)
  },
  
  // 商品相关
  product: {
    list: (params) => service.get('/api/product/list', { params }),
    detail: (id) => service.get(`/api/product/${id}`),
    hot: (params) => service.get('/api/product/hot', { params }),
    recommend: (params) => service.get('/api/product/recommend', { params })
  },
  
  // 分类相关
  category: {
    list: () => service.get('/api/category/list'),
    children: (parentId) => service.get(`/api/category/children/${parentId}`)
  },
  
  // 购物车相关
  cart: {
    list: () => service.get('/api/cart/list'),
    add: (data) => service.post('/api/cart/add', data),
    updateQuantity: (data) => service.put('/api/cart/quantity', data),
    delete: (id) => service.delete(`/api/cart/${id}`),
    clear: () => service.delete('/api/cart/clear'),
    select: (id, selected) => service.put(`/api/cart/select/${id}`, {}, { params: { selected } }),
    selectAll: (selected) => service.put('/api/cart/selectAll', {}, { params: { selected } }),
    count: () => service.get('/api/cart/count')
  },
  
  // 订单相关
  order: {
    create: (data) => service.post('/api/order/create', data),
    detail: (id) => service.get(`/api/order/${id}`),
    list: (params) => service.get('/api/order/list', { params }),
    cancel: (id) => service.put(`/api/order/cancel/${id}`),
    receive: (id) => service.put(`/api/order/receive/${id}`),
    delete: (id) => service.delete(`/api/order/${id}`)
  },
  
  // 支付相关
  payment: {
    create: (data) => service.post('/api/payment/create', data),
    pay: (paymentId) => service.post('/api/payment/pay', { paymentId }),
    status: (orderId) => service.get(`/api/payment/status/${orderId}`)
  },
  
  // 地址相关
  address: {
    list: () => service.get('/api/address/list'),
    detail: (id) => service.get(`/api/address/${id}`),
    add: (data) => service.post('/api/address/add', data),
    update: (data) => service.put('/api/address/update', data),
    delete: (id) => service.delete(`/api/address/${id}`),
    setDefault: (id) => service.put(`/api/address/default/${id}`)
  },
  
  // 推荐相关
  recommendation: {
    recommended: (params) => service.get('/api/recommendation/recommended', { params }),
    related: (productId, params) => service.get(`/api/recommendation/related/${productId}`, { params })
  },
  
  // 浏览历史相关
  browseHistory: {
    record: (productId) => service.post(`/api/browse-history/record/${productId}`),
    recent: (params) => service.get('/api/browse-history/recent', { params }),
    clear: () => service.post('/api/browse-history/clear')
  },
  
  // 优惠券相关
  coupon: {
    available: () => service.get('/api/coupon/available'),
    user: () => service.get('/api/coupon/user'),
    receive: (couponId) => service.post(`/api/coupon/receive/${couponId}`),
    create: (data) => service.post('/api/coupon/create', data),
    update: (data) => service.put('/api/coupon/update', data),
    delete: (id) => service.delete(`/api/coupon/delete/${id}`),
    list: () => service.get('/api/coupon/list')
  },
  
  // 促销活动相关
  promotion: {
    active: () => service.get('/api/promotion/active'),
    products: (promotionId) => service.get(`/api/promotion/products/${promotionId}`),
    product: (productId) => service.get(`/api/promotion/product/${productId}`),
    create: (data) => service.post('/api/promotion/create', data),
    update: (data) => service.put('/api/promotion/update', data),
    delete: (id) => service.delete(`/api/promotion/delete/${id}`),
    addProduct: (data) => service.post('/api/promotion/product/add', data),
    updateProduct: (data) => service.put('/api/promotion/product/update', data),
    deleteProduct: (id) => service.delete(`/api/promotion/product/delete/${id}`),
    list: () => service.get('/api/promotion/list')
  },
  
  // 积分相关
  point: {
    balance: () => service.get('/api/point/balance'),
    records: (params) => service.get('/api/point/records', { params }),
    add: (data) => service.post('/api/point/add', data),
    deduct: (data) => service.post('/api/point/deduct', data)
  },
  
  // 物流相关
  logistics: {
    getByOrder: (orderId) => service.get(`/api/logistics/order/${orderId}`),
    getTracks: (logisticsId) => service.get(`/api/logistics/tracks/${logisticsId}`),
    ship: (data) => service.post('/api/logistics/ship', data),
    updateStatus: (data) => service.post('/api/logistics/updateStatus', data)
  },
  
  // 客服相关
  cs: {
    sessions: () => service.get('/api/cs/sessions'),
    getUnfinishedSession: () => service.get('/api/cs/session/unfinished'),
    createSession: () => service.post('/api/cs/session/create'),
    endSession: (sessionId) => service.post(`/api/cs/session/end/${sessionId}`),
    sendMessage: (data) => service.post('/api/cs/message/send', data),
    getMessages: (sessionId, params) => service.get(`/api/cs/messages/${sessionId}`, { params })
  }
}
