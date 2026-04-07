import request from '@/utils/request'

// 管理员登录
export const login = (data) => {
  return request({
    url: '/api/admin/login',
    method: 'post',
    data
  })
}

// 用户管理
export const getUserList = (params) => {
  return request({
    url: '/api/admin/user/list',
    method: 'get',
    params
  })
}

export const getUserById = (id) => {
  return request({
    url: `/api/admin/user/${id}`,
    method: 'get'
  })
}

export const updateUserStatus = (id, status) => {
  return request({
    url: `/api/admin/user/status/${id}`,
    method: 'put',
    params: { status }
  })
}

// 商品管理
export const getProductList = (params) => {
  return request({
    url: '/api/admin/product/list',
    method: 'get',
    params
  })
}

export const addProduct = (data) => {
  return request({
    url: '/api/admin/product/add',
    method: 'post',
    data
  })
}

export const updateProduct = (data) => {
  return request({
    url: '/api/admin/product/update',
    method: 'put',
    data
  })
}

export const deleteProduct = (id) => {
  return request({
    url: `/api/admin/product/${id}`,
    method: 'delete'
  })
}

export const updateProductStatus = (id, status) => {
  return request({
    url: `/api/admin/product/status/${id}`,
    method: 'put',
    params: { status }
  })
}

// 分类管理
export const getCategoryList = () => {
  return request({
    url: '/api/admin/category/list',
    method: 'get'
  })
}

export const addCategory = (data) => {
  return request({
    url: '/api/admin/category/add',
    method: 'post',
    data
  })
}

export const updateCategory = (data) => {
  return request({
    url: '/api/admin/category/update',
    method: 'put',
    data
  })
}

export const deleteCategory = (id) => {
  return request({
    url: `/api/admin/category/${id}`,
    method: 'delete'
  })
}

// 订单管理
export const getOrderList = (params) => {
  return request({
    url: '/api/admin/order/list',
    method: 'get',
    params
  })
}

export const getOrderById = (id) => {
  return request({
    url: `/api/admin/order/${id}`,
    method: 'get'
  })
}

export const updateOrderStatus = (id, status) => {
  return request({
    url: `/api/admin/order/status/${id}`,
    method: 'put',
    params: { status }
  })
}

// 数据统计
export const getStatistics = (dateRange) => {
  return request({
    url: '/api/admin/stats',
    method: 'get',
    params: { dateRange }
  })
}

export const getSalesStats = () => {
  return request({
    url: '/api/admin/stats/sales',
    method: 'get'
  })
}

export const getUserStats = () => {
  return request({
    url: '/api/admin/stats/users',
    method: 'get'
  })
}

export const getProductStats = () => {
  return request({
    url: '/api/admin/stats/products',
    method: 'get'
  })
}

// 轮播图管理
export const getBannerList = () => {
  return request({
    url: '/api/admin/banner/list',
    method: 'get'
  })
}

export const addBanner = (data) => {
  return request({
    url: '/api/admin/banner/add',
    method: 'post',
    data
  })
}

export const updateBanner = (data) => {
  return request({
    url: '/api/admin/banner/update',
    method: 'put',
    data
  })
}

export const deleteBanner = (id) => {
  return request({
    url: `/api/admin/banner/${id}`,
    method: 'delete'
  })
}

export const updateBannerStatus = (id, status) => {
  return request({
    url: `/api/admin/banner/status/${id}`,
    method: 'put',
    params: { status }
  })
}