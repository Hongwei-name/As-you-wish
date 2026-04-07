<template>
  <div class="login-page">
    <div class="login-container card-shadow">
      <div class="login-header">
        <h2 class="login-title">用户登录</h2>
        <p class="login-subtitle">欢迎回到 如你所愿</p>
      </div>
      
      <el-form 
        ref="loginFormRef" 
        :model="loginForm" 
        :rules="loginRules" 
        class="login-form"
      >
        <el-form-item prop="username">
          <el-input 
            v-model="loginForm.username" 
            placeholder="请输入用户名"
            prefix-icon="el-icon-user"
            size="large"
          ></el-input>
        </el-form-item>
        
        <el-form-item prop="password">
          <el-input 
            v-model="loginForm.password" 
            type="password" 
            placeholder="请输入密码"
            prefix-icon="el-icon-lock"
            size="large"
            show-password
          ></el-input>
        </el-form-item>
        
        <div class="form-footer">
          <el-checkbox v-model="loginForm.remember">记住密码</el-checkbox>
          <router-link to="/register" class="register-link">立即注册</router-link>
        </div>
        
        <el-form-item>
          <el-button 
            type="primary" 
            class="login-btn" 
            size="large" 
            :loading="loading"
            @click="handleLogin"
          >
            登录
          </el-button>
        </el-form-item>
      </el-form>
      
      <div class="error-message" v-if="error">
        <i class="el-icon-warning-outline"></i> {{ error }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const loginFormRef = ref(null)
const loading = ref(false)
const error = ref('')

const loginForm = reactive({
  username: '',
  password: '',
  remember: false
})

const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ]
}

const handleLogin = async () => {
  // 表单验证
  const valid = await loginFormRef.value.validate()
  if (!valid) return
  
  loading.value = true
  error.value = ''
  
  try {
    await userStore.login(loginForm)
        // 登录成功，跳转到首页或回调地址
        const redirect = route.query.redirect || '/' 
        router.push(redirect)
  } catch (err) {
    error.value = err.message || '登录失败，请检查用户名和密码'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--el-bg-color);
  padding: 20px;
}

.login-container {
  background-color: #FFFFFF;
  border-radius: 12px;
  padding: 40px;
  width: 100%;
  max-width: 400px;
  box-sizing: border-box;
}

.login-header {
  text-align: center;
  margin-bottom: 30px;
}

.login-title {
  font-size: 24px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 8px;
  font-family: 'Times New Roman', serif;
}

.login-subtitle {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 0;
}

.login-form {
  margin-bottom: 20px;
}

.form-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.register-link {
  color: var(--el-color-primary);
  text-decoration: none;
  font-size: 14px;
  transition: color 0.3s ease;
}

.register-link:hover {
  color: var(--el-color-primary-light-3);
  text-decoration: underline;
}

.login-btn {
  width: 100%;
  padding: 12px;
  font-size: 16px;
  background-color: var(--el-color-primary);
  border-color: var(--el-color-primary);
  color: #FFFFFF;
  transition: all 0.3s ease;
}

.login-btn:hover {
  background-color: var(--el-color-primary-light-3);
  border-color: var(--el-color-primary-light-3);
}

.error-message {
  background-color: rgba(245, 108, 108, 0.1);
  color: #F56C6C;
  padding: 10px 15px;
  border-radius: 4px;
  font-size: 14px;
  margin-top: 15px;
  display: flex;
  align-items: center;
}

.error-message i {
  margin-right: 8px;
  font-size: 16px;
}

/* 响应式 */
@media (max-width: 480px) {
  .login-container {
    padding: 20px;
  }
  
  .login-title {
    font-size: 20px;
  }
}
</style>
