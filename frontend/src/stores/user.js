import { defineStore } from 'pinia'
import service from '@/utils/request'
import { useCartStore } from './cart'

// 用户状态管理
export const useUserStore = defineStore('user', {
  state: () => ({
    userInfo: null,
    token: localStorage.getItem('token') || '',
    loading: false,
    error: null
  }),
  
  getters: {
    isLoggedIn: (state) => !!state.token,
    user: (state) => state.userInfo
  },
  
  actions: {
    // 登录
    async login(loginData) {
      this.loading = true
      this.error = null
      try {
        const response = await service.post('/api/user/login', loginData)
        const { token } = response.data
        this.token = token
        localStorage.setItem('token', token)
        // 登录成功后获取用户信息
        await this.getUserInfo()
        // 同步本地购物车到服务器
        const cartStore = useCartStore()
        await cartStore.syncLocalCart()
        return response
      } catch (error) {
        this.error = error.response?.data?.message || '登录失败'
        throw error
      } finally {
        this.loading = false
      }
    },
    
    // 注册
    async register(registerData) {
      this.loading = true
      this.error = null
      try {
        const response = await service.post('/api/user/register', registerData)
        return response.data
      } catch (error) {
        this.error = error.response?.data?.message || '注册失败'
        throw error
      } finally {
        this.loading = false
      }
    },
    
    // 获取用户信息
    async getUserInfo() {
      if (!this.token) return
      
      this.loading = true
      try {
        const response = await service.get('/api/user/info')
        this.userInfo = response.data
        return response
      } catch (error) {
        this.logout()
        throw error
      } finally {
        this.loading = false
      }
    },
    
    // 登出
    logout() {
      this.userInfo = null
      this.token = ''
      localStorage.removeItem('token')
    },
    
    // 更新用户信息
    async updateUserInfo(updateData) {
      this.loading = true
      try {
        const response = await service.put('/api/user/update', updateData)
        this.userInfo = response.data
        return response
      } catch (error) {
        this.error = error.response?.data?.message || '更新失败'
        throw error
      } finally {
        this.loading = false
      }
    },
    
    // 修改密码
    async changePassword(passwordData) {
      this.loading = true
      try {
        const response = await service.put('/api/user/password', passwordData)
        return response.data
      } catch (error) {
        this.error = error.response?.data?.message || '修改密码失败'
        throw error
      } finally {
        this.loading = false
      }
    }
  }
})
