<template>
  <div class="register-page">
    <div class="register-container card-shadow">
      <div class="register-header">
        <h2 class="register-title">用户注册</h2>
        <p class="register-subtitle">创建新账户，享受更多优惠</p>
      </div>
      
      <el-form 
        ref="registerFormRef" 
        :model="registerForm" 
        :rules="registerRules" 
        class="register-form"
      >
        <el-form-item prop="username">
          <el-input 
            v-model="registerForm.username" 
            placeholder="请输入用户名"
            prefix-icon="el-icon-user"
            size="large"
          ></el-input>
        </el-form-item>
        
        <el-form-item prop="password">
          <el-input 
            v-model="registerForm.password" 
            type="password" 
            placeholder="请输入密码（6-20位）"
            prefix-icon="el-icon-lock"
            size="large"
            show-password
          ></el-input>
        </el-form-item>
        
        <el-form-item prop="confirmPassword">
          <el-input 
            v-model="registerForm.confirmPassword" 
            type="password" 
            placeholder="请确认密码"
            prefix-icon="el-icon-lock"
            size="large"
            show-password
          ></el-input>
        </el-form-item>
        
        <el-form-item prop="email">
          <el-input 
            v-model="registerForm.email" 
            placeholder="请输入邮箱"
            prefix-icon="el-icon-message"
            size="large"
          ></el-input>
        </el-form-item>
        
        <el-form-item prop="phone">
          <el-input 
            v-model="registerForm.phone" 
            placeholder="请输入手机号"
            prefix-icon="el-icon-phone"
            size="large"
          ></el-input>
        </el-form-item>
        
        <el-form-item>
          <el-button 
            type="primary" 
            class="register-btn" 
            size="large" 
            :loading="loading"
            @click="handleRegister"
          >
            注册
          </el-button>
        </el-form-item>
      </el-form>
      
      <div class="form-footer">
        <span class="login-link">已有账户？</span>
        <router-link to="/login" class="login-btn-text">立即登录</router-link>
      </div>
      
      <div class="error-message" v-if="error">
        <i class="el-icon-warning-outline"></i> {{ error }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const registerFormRef = ref(null)
const loading = ref(false)
const error = ref('')

const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  email: '',
  phone: ''
})

const registerRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度3-20位', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度6-20位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== registerForm.password) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
  ]
}

const handleRegister = async () => {
  // 表单验证
  const valid = await registerFormRef.value.validate()
  if (!valid) return
  
  loading.value = true
  error.value = ''
  
  try {
    const response = await userStore.register(registerForm)
    if (response.code === 200) {
      // 注册成功，跳转到登录页
      ElMessage.success('注册成功，请登录')
      router.push('/login')
    }
  } catch (err) {
    error.value = err.message || '注册失败，请稍后重试'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.register-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--el-bg-color);
  padding: 20px;
}

.register-container {
  background-color: #FFFFFF;
  border-radius: 12px;
  padding: 40px;
  width: 100%;
  max-width: 450px;
  box-sizing: border-box;
}

.register-header {
  text-align: center;
  margin-bottom: 30px;
}

.register-title {
  font-size: 24px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 8px;
  font-family: 'Times New Roman', serif;
}

.register-subtitle {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 0;
}

.register-form {
  margin-bottom: 20px;
}

.form-footer {
  text-align: center;
  margin-top: 20px;
  font-size: 14px;
}

.login-link {
  color: var(--el-text-color-secondary);
  margin-right: 5px;
}

.login-btn-text {
  color: var(--el-color-primary);
  text-decoration: none;
  transition: color 0.3s ease;
}

.login-btn-text:hover {
  color: var(--el-color-primary-light-3);
  text-decoration: underline;
}

.register-btn {
  width: 100%;
  padding: 12px;
  font-size: 16px;
  background-color: var(--el-color-primary);
  border-color: var(--el-color-primary);
  color: #FFFFFF;
  transition: all 0.3s ease;
}

.register-btn:hover {
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
  .register-container {
    padding: 20px;
  }
  
  .register-title {
    font-size: 20px;
  }
}
</style>
