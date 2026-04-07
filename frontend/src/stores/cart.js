import { defineStore } from 'pinia'
import service from '@/utils/request'

// 购物车状态管理
export const useCartStore = defineStore('cart', {
  state: () => ({
    cartItems: [],
    loading: false,
    error: null
  }),
  
  // 初始化时从本地存储加载购物车数据
  created() {
    this.loadLocalCart()
  },
  
  getters: {
    // 购物车商品数量
    cartCount: (state) => {
      return state.cartItems.reduce((total, item) => total + item.quantity, 0)
    },
    
    // 选中商品数量
    selectedCount: (state) => {
      return state.cartItems.filter(item => item.selected === true || item.selected === 1).reduce((total, item) => total + item.quantity, 0)
    },
    
    // 选中商品总价
    selectedTotal: (state) => {
      return state.cartItems
        .filter(item => item.selected === true || item.selected === 1)
        .reduce((total, item) => total + (item.productPrice * item.quantity), 0)
    },
    
    // 是否全选
    isAllSelected: (state) => {
      return state.cartItems.length > 0 && state.cartItems.every(item => item.selected === true || item.selected === 1)
    }
  },
  
  actions: {
    // 加载本地购物车数据
    loadLocalCart() {
      try {
        const localCart = localStorage.getItem('localCart')
        if (localCart) {
          this.cartItems = JSON.parse(localCart)
        }
      } catch (error) {
        console.error('加载本地购物车失败:', error)
        this.cartItems = []
      }
    },
    
    // 保存购物车数据到本地
    saveLocalCart() {
      try {
        localStorage.setItem('localCart', JSON.stringify(this.cartItems))
      } catch (error) {
        console.error('保存本地购物车失败:', error)
      }
    },
    
    // 同步本地购物车到服务器
    async syncLocalCart() {
      const token = localStorage.getItem('token')
      if (!token) return
      
      try {
        // 先获取服务器购物车数据
        const serverResponse = await service.get('/api/cart/list')
        const serverCart = serverResponse.data.list || []
        
        // 合并本地购物车到服务器
        for (const localItem of this.cartItems) {
          const existingItem = serverCart.find(item => item.productId === localItem.productId)
          if (existingItem) {
            // 更新数量
            await service.put('/api/cart/quantity', {
              id: existingItem.id,
              quantity: existingItem.quantity + localItem.quantity
            })
          } else {
            // 添加新商品
            await service.post('/api/cart/add', {
              productId: localItem.productId,
              quantity: localItem.quantity
            })
          }
        }
        
        // 清空本地购物车
        this.cartItems = []
        this.saveLocalCart()
        
        // 重新获取购物车列表
        await this.getCartList()
      } catch (error) {
        console.error('同步本地购物车失败:', error)
      }
    },
    
    // 获取购物车列表
    async getCartList() {
      const token = localStorage.getItem('token')
      if (!token) {
        // 未登录时从本地加载
        this.loadLocalCart()
        return { list: this.cartItems }
      }
      
      this.loading = true
      try {
        const response = await service.get('/api/cart/list')
        this.cartItems = response.data.list || []
        return response.data
      } catch (error) {
        this.error = error.response?.data?.message || '获取购物车失败'
        throw error
      } finally {
        this.loading = false
      }
    },
    
    // 添加商品到购物车
    async addToCart(productId, quantity = 1) {
      const token = localStorage.getItem('token')
      
      if (!token) {
        // 未登录时添加到本地购物车
        try {
          // 检查商品是否已在购物车中
          const existingItem = this.cartItems.find(item => item.productId === productId)
          if (existingItem) {
            existingItem.quantity += quantity
          } else {
            // 模拟购物车项结构
            this.cartItems.push({
              id: Date.now(), // 本地临时ID
              productId,
              quantity,
              selected: true
            })
          }
          // 保存到本地存储
          this.saveLocalCart()
          return { success: true }
        } catch (error) {
          this.error = '添加购物车失败'
          throw error
        }
      } else {
        // 登录时添加到服务器
        this.loading = true
        try {
          const response = await service.post('/api/cart/add', {
            productId,
            quantity
          })
          // 重新获取购物车列表
          await this.getCartList()
          return response.data
        } catch (error) {
          this.error = error.response?.data?.message || '添加购物车失败'
          throw error
        } finally {
          this.loading = false
        }
      }
    },
    
    // 更新购物车商品数量
    async updateQuantity(cartId, quantity) {
      const token = localStorage.getItem('token')
      
      if (!token) {
        // 未登录时更新本地购物车
        try {
          const item = this.cartItems.find(item => item.id === cartId)
          if (item) {
            item.quantity = quantity
            // 保存到本地存储
            this.saveLocalCart()
          }
          return { success: true }
        } catch (error) {
          this.error = '更新数量失败'
          throw error
        }
      } else {
        // 登录时更新服务器
        this.loading = true
        try {
          const response = await service.put('/api/cart/quantity', {
            id: cartId,
            quantity
          })
          // 重新获取购物车列表
          await this.getCartList()
          return response.data
        } catch (error) {
          this.error = error.response?.data?.message || '更新数量失败'
          throw error
        } finally {
          this.loading = false
        }
      }
    },
    
    // 删除购物车商品
    async deleteCartItem(cartId) {
      const token = localStorage.getItem('token')
      
      if (!token) {
        // 未登录时删除本地购物车商品
        try {
          this.cartItems = this.cartItems.filter(item => item.id !== cartId)
          // 保存到本地存储
          this.saveLocalCart()
          return { success: true }
        } catch (error) {
          this.error = '删除失败'
          throw error
        }
      } else {
        // 登录时删除服务器商品
        this.loading = true
        try {
          const response = await service.delete(`/api/cart/${cartId}`)
          // 重新获取购物车列表
          await this.getCartList()
          return response.data
        } catch (error) {
          this.error = error.response?.data?.message || '删除失败'
          throw error
        } finally {
          this.loading = false
        }
      }
    },
    
    // 清空购物车
    async clearCart() {
      const token = localStorage.getItem('token')
      
      if (!token) {
        // 未登录时清空本地购物车
        try {
          this.cartItems = []
          // 保存到本地存储
          this.saveLocalCart()
          return { success: true }
        } catch (error) {
          this.error = '清空购物车失败'
          throw error
        }
      } else {
        // 登录时清空服务器购物车
        this.loading = true
        try {
          const response = await service.delete('/api/cart/clear')
          this.cartItems = []
          return response.data
        } catch (error) {
          this.error = error.response?.data?.message || '清空购物车失败'
          throw error
        } finally {
          this.loading = false
        }
      }
    },
    
    // 选择/取消选择商品
    async selectCartItem(cartId, selected) {
      const token = localStorage.getItem('token')
      const selectedValue = selected ? 1 : 0
      
      if (!token) {
        // 未登录时更新本地购物车选择状态
        try {
          const item = this.cartItems.find(item => item.id === cartId)
          if (item) {
            item.selected = selected
            // 保存到本地存储
            this.saveLocalCart()
          }
          return { success: true }
        } catch (error) {
          this.error = '操作失败'
          throw error
        }
      } else {
        // 登录时更新服务器选择状态
        this.loading = true
        try {
          const response = await service.put(`/api/cart/select/${cartId}`, {}, {
            params: { selected: selectedValue }
          })
          // 重新获取购物车列表
          await this.getCartList()
          return response.data
        } catch (error) {
          this.error = error.response?.data?.message || '操作失败'
          throw error
        } finally {
          this.loading = false
        }
      }
    },
    
    // 全选/取消全选
    async selectAll(selected) {
      const token = localStorage.getItem('token')
      const selectedValue = selected ? 1 : 0
      
      if (!token) {
        // 未登录时更新本地购物车全选状态
        try {
          this.cartItems.forEach(item => {
            item.selected = selected
          })
          // 保存到本地存储
          this.saveLocalCart()
          return { success: true }
        } catch (error) {
          this.error = '操作失败'
          throw error
        }
      } else {
        // 登录时更新服务器全选状态
        this.loading = true
        try {
          const response = await service.put('/api/cart/selectAll', {}, {
            params: { selected: selectedValue }
          })
          // 重新获取购物车列表
          await this.getCartList()
          return response.data
        } catch (error) {
          this.error = error.response?.data?.message || '操作失败'
          throw error
        } finally {
          this.loading = false
        }
      }
    }
  }
})
