<template>
  <div class="admin-login-page">
    <div class="admin-login-container card-shadow">
      <div class="admin-login-header">
        <h2 class="admin-login-title">管理登录</h2>
        <p class="admin-login-subtitle">请输入管理员账号和密码</p>
      </div>
      
      <el-form :model="loginForm" :rules="loginRules" ref="loginFormRef" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="loginForm.username" placeholder="请输入用户名">
            <template #prefix>
              <el-icon><UserFilled /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        
        <el-form-item label="密码" prop="password">
          <el-input v-model="loginForm.password" type="password" placeholder="请输入密码" show-password>
            <template #prefix>
              <el-icon><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" class="login-btn" @click="handleLogin" :loading="loading">
            登录
          </el-button>
        </el-form-item>
      </el-form>
      
      <div class="admin-login-footer">
        <p class="admin-login-copyright">© 2026 如你所愿 - 电商管理系统</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElIcon } from 'element-plus'
import { UserFilled, Lock } from '@element-plus/icons-vue'
import { login as adminLogin } from '@/api/admin'

const router = useRouter()
const route = useRoute()
const loginForm = reactive({
  username: '',
  password: ''
})

const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度在 6 到 20 个字符', trigger: 'blur' }
  ]
}

const loading = ref(false)
const loginFormRef = ref(null)

const handleLogin = () => {
  console.log('handleLogin called')
  console.log('loginFormRef.value:', loginFormRef.value)
  console.log('loginForm:', loginForm)
  if (!loginFormRef.value) return
  
  loginFormRef.value.validate((valid) => {
    if (valid) {
      loading.value = true
      adminLogin(loginForm)
        .then(response => {
          if (response.code === 200) {
            const { token, user } = response.data
            localStorage.setItem('token', token)
            localStorage.setItem('user', JSON.stringify(user))
            
            ElMessage.success('登录成功')
            
            // 跳转到管理首页或重定向页面
            const redirect = route.query.redirect || '/admin'
            router.push(redirect)
          } else {
            ElMessage.error(response.message || '登录失败')
          }
        })
        .catch(error => {
          ElMessage.error('登录失败，请稍后重试')
        })
        .finally(() => {
          loading.value = false
        })
    }
  })
}
</script>

<style scoped>
.admin-login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  padding: 20px;
}

.admin-login-container {
  width: 100%;
  max-width: 450px;
  background: #fff;
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.admin-login-header {
  text-align: center;
  margin-bottom: 30px;
}

.admin-login-title {
  font-size: 28px;
  font-weight: 600;
  color: var(--el-color-primary);
  margin-bottom: 8px;
}

.admin-login-subtitle {
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

.login-btn {
  width: 100%;
  height: 48px;
  font-size: 16px;
}

.admin-login-footer {
  text-align: center;
  margin-top: 30px;
}

.admin-login-copyright {
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.card-shadow {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  transition: all 0.3s ease;
}

.card-shadow:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}
</style>