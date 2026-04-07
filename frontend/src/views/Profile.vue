<template>
  <div class="profile-page">
    <div class="container">
      <h2 class="page-title">个人中心</h2>
      
      <div class="profile-container">
        <!-- 左侧菜单 -->
        <div class="profile-sidebar">
          <div class="user-info">
            <div class="avatar">
              <img :src="userInfo?.avatar || defaultAvatar" :alt="userInfo?.username">
            </div>
            <div class="user-details">
              <h3 class="username">{{ userInfo?.username || '用户' }}</h3>
              <p class="email">{{ userInfo?.email || '未设置邮箱' }}</p>
            </div>
          </div>
          
          <el-menu
            :default-active="activeTab"
            class="profile-menu"
            @select="handleMenuSelect"
          >
            <el-menu-item index="info">
              <el-icon><i class="el-icon-user"></i></el-icon>
              <span>个人信息</span>
            </el-menu-item>
            <el-menu-item index="password">
              <el-icon><i class="el-icon-lock"></i></el-icon>
              <span>修改密码</span>
            </el-menu-item>
            <el-menu-item index="orders">
              <el-icon><i class="el-icon-document"></i></el-icon>
              <span>我的订单</span>
            </el-menu-item>
            <el-menu-item index="address">
              <el-icon><i class="el-icon-location"></i></el-icon>
              <span>收货地址</span>
            </el-menu-item>
            <el-menu-item index="logout">
              <el-icon><i class="el-icon-switch-button"></i></el-icon>
              <span>退出登录</span>
            </el-menu-item>
          </el-menu>
        </div>
        
        <!-- 右侧内容 -->
        <div class="profile-content">
          <!-- 个人信息 -->
          <div v-if="activeTab === 'info'" class="content-section">
            <h3 class="section-title">个人信息</h3>
            <el-form :model="userForm" class="info-form">
              <el-form-item label="用户名">
                <el-input v-model="userForm.username" disabled></el-input>
              </el-form-item>
              <el-form-item label="邮箱">
                <el-input v-model="userForm.email"></el-input>
              </el-form-item>
              <el-form-item label="手机号">
                <el-input v-model="userForm.phone"></el-input>
              </el-form-item>
              <el-form-item label="昵称">
                <el-input v-model="userForm.nickname"></el-input>
              </el-form-item>
              <el-form-item label="性别">
                <el-radio-group v-model="userForm.gender">
                  <el-radio value="0">男</el-radio>
                  <el-radio value="1">女</el-radio>
                  <el-radio value="2">保密</el-radio>
                </el-radio-group>
              </el-form-item>
              <el-form-item label="头像">
                <el-upload
                  class="avatar-uploader"
                  action="#"
                  :auto-upload="false"
                  :show-file-list="false"
                  :on-change="handleAvatarChange"
                >
                  <img v-if="userForm.avatar" :src="userForm.avatar" class="avatar">
                  <el-icon v-else class="avatar-uploader-icon"><i class="el-icon-plus"></i></el-icon>
                </el-upload>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="updateUserInfo" :loading="loading">保存修改</el-button>
              </el-form-item>
            </el-form>
          </div>
          
          <!-- 修改密码 -->
          <div v-else-if="activeTab === 'password'" class="content-section">
            <h3 class="section-title">修改密码</h3>
            <el-form :model="passwordForm" :rules="passwordRules" ref="passwordFormRef" class="password-form">
              <el-form-item label="当前密码" prop="oldPassword">
                <el-input type="password" v-model="passwordForm.oldPassword" placeholder="请输入当前密码"></el-input>
              </el-form-item>
              <el-form-item label="新密码" prop="newPassword">
                <el-input type="password" v-model="passwordForm.newPassword" placeholder="请输入新密码（6-20位）"></el-input>
              </el-form-item>
              <el-form-item label="确认密码" prop="confirmPassword">
                <el-input type="password" v-model="passwordForm.confirmPassword" placeholder="请确认新密码"></el-input>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="changePassword" :loading="loading">修改密码</el-button>
              </el-form-item>
            </el-form>
          </div>
          
          <!-- 我的订单 -->
          <div v-else-if="activeTab === 'orders'" class="content-section">
            <h3 class="section-title">我的订单</h3>
            <div class="order-stats">
              <div class="stat-item">
                <el-icon><i class="el-icon-time"></i></el-icon>
                <span class="stat-text">待支付</span>
                <span class="stat-count">{{ orderStats.pending || 0 }}</span>
              </div>
              <div class="stat-item">
                <el-icon><i class="el-icon-loading"></i></el-icon>
                <span class="stat-text">待发货</span>
                <span class="stat-count">{{ orderStats.processing || 0 }}</span>
              </div>
              <div class="stat-item">
                <el-icon><i class="el-icon-truck"></i></el-icon>
                <span class="stat-text">待收货</span>
                <span class="stat-count">{{ orderStats.shipping || 0 }}</span>
              </div>
              <div class="stat-item">
                <el-icon><i class="el-icon-star-off"></i></el-icon>
                <span class="stat-text">待评价</span>
                <span class="stat-count">{{ orderStats.toEvaluate || 0 }}</span>
              </div>
            </div>
            <el-button type="primary" @click="goToOrderList">查看全部订单</el-button>
          </div>
          
          <!-- 收货地址 -->
          <div v-else-if="activeTab === 'address'" class="content-section">
            <h3 class="section-title">收货地址</h3>
            <div class="address-list">
              <div v-if="addresses.length > 0">
                <div 
                  v-for="address in addresses" 
                  :key="address.id"
                  class="address-item"
                >
                  <div class="address-content">
                    <div class="address-header">
                      <span class="receiver">{{ address.receiver }}</span>
                      <span class="phone">{{ address.phone }}</span>
                      <span class="default-tag" v-if="address.isDefault">默认</span>
                    </div>
                    <div class="address-detail">
                      {{ address.province }}{{ address.city }}{{ address.district }}{{ address.detail }}
                    </div>
                    <div class="address-actions">
                      <el-button type="primary" size="small">编辑</el-button>
                      <el-button type="danger" size="small">删除</el-button>
                    </div>
                  </div>
                </div>
              </div>
              <div v-else class="no-address">
                <p>暂无收货地址</p>
                <el-button type="primary">添加地址</el-button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { api } from '@/utils/request'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const activeTab = ref('info')
const passwordFormRef = ref(null)
const defaultAvatar = 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=user%20avatar%20placeholder%20warm%20colors&image_size=square'

const userInfo = ref(null)
const userForm = reactive({
  username: '',
  email: '',
  phone: '',
  nickname: '',
  gender: 2,
  avatar: ''
})

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入当前密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度6-20位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

const orderStats = reactive({
  pending: 0,
  processing: 0,
  shipping: 0,
  toEvaluate: 0
})

const addresses = ref([])

// 处理菜单选择
const handleMenuSelect = (key) => {
  activeTab.value = key
  
  if (key === 'logout') {
    handleLogout()
  }
}

// 处理头像变更
const handleAvatarChange = (file) => {
  // 这里可以实现头像上传逻辑
  ElMessage.info('头像上传功能开发中')
}

// 更新用户信息
const updateUserInfo = async () => {
  loading.value = true
  try {
    await userStore.updateUserInfo(userForm)
    ElMessage.success('信息更新成功')
  } catch (error) {
    ElMessage.error(error.message || '更新失败')
  } finally {
    loading.value = false
  }
}

// 修改密码
const changePassword = async () => {
  const valid = await passwordFormRef.value.validate()
  if (!valid) return
  
  loading.value = true
  try {
    await userStore.changePassword(passwordForm)
    ElMessage.success('密码修改成功')
    passwordForm.oldPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
  } catch (error) {
    ElMessage.error(error.message || '修改密码失败')
  } finally {
    loading.value = false
  }
}

// 退出登录
const handleLogout = async () => {
  try {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    userStore.logout()
    router.push('/login')
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('退出登录失败')
    }
  }
}

// 跳转到订单列表
const goToOrderList = () => {
  router.push('/order/list')
}

// 获取用户信息
const getUserInfo = async () => {
  try {
    await userStore.getUserInfo()
    userInfo.value = userStore.user
    if (userInfo.value) {
      Object.assign(userForm, userInfo.value)
    }
  } catch (error) {
    console.error('获取用户信息失败:', error)
  }
}

// 获取地址列表
const getAddresses = async () => {
  try {
    const response = await api.address.list()
    addresses.value = response.data
  } catch (error) {
    console.error('获取地址失败:', error)
  }
}

// 初始化
onMounted(async () => {
  await getUserInfo()
  await getAddresses()
})
</script>

<style scoped>
.profile-page {
  padding: 20px 0;
}

.page-title {
  font-size: 20px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 20px;
  text-align: center;
  position: relative;
  padding-bottom: 10px;
}

.page-title::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 60px;
  height: 2px;
  background-color: var(--el-color-primary);
}

.profile-container {
  display: flex;
  gap: 30px;
  background-color: #FFFFFF;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
  overflow: hidden;
}

.profile-sidebar {
  flex: 0 0 250px;
  background-color: var(--el-bg-color-overlay);
  border-right: 1px solid var(--el-border-color);
  padding: 20px;
}

.user-info {
  text-align: center;
  padding: 20px 0;
  border-bottom: 1px solid var(--el-border-color);
  margin-bottom: 20px;
}

.avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  overflow: hidden;
  margin: 0 auto 15px;
  border: 2px solid var(--el-color-primary);
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.user-details h3 {
  margin: 0 0 5px;
  font-size: 16px;
  font-weight: bold;
  color: var(--el-text-color-primary);
}

.user-details p {
  margin: 0;
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

.profile-menu {
  border: none;
  background-color: transparent;
}

.profile-content {
  flex: 1;
  padding: 30px;
}

.content-section {
  min-height: 400px;
}

.section-title {
  font-size: 18px;
  font-weight: bold;
  color: var(--el-text-color-primary);
  margin: 0 0 20px;
  position: relative;
  padding-left: 15px;
}

.section-title::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 4px;
  height: 20px;
  background-color: var(--el-color-primary);
  border-radius: 2px;
}

.info-form,
.password-form {
  max-width: 600px;
}

.avatar-uploader {
  display: flex;
  align-items: center;
}

.avatar-uploader .avatar {
  width: 100px;
  height: 100px;
  border-radius: 8px;
  object-fit: cover;
  border: 1px solid var(--el-border-color);
}

.avatar-uploader-icon {
  width: 100px;
  height: 100px;
  border: 1px dashed var(--el-border-color);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: var(--el-text-color-placeholder);
  cursor: pointer;
}

.order-stats {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
}

.stat-item {
  flex: 1;
  text-align: center;
  padding: 20px;
  background-color: var(--el-bg-color-overlay);
  border-radius: 8px;
  transition: all 0.3s ease;
  cursor: pointer;
}

.stat-item:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 12px rgba(184, 149, 110, 0.15);
}

.stat-item i {
  font-size: 24px;
  color: var(--el-color-primary);
  margin-bottom: 10px;
  display: block;
}

.stat-text {
  display: block;
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin-bottom: 5px;
}

.stat-count {
  display: block;
  font-size: 18px;
  font-weight: bold;
  color: var(--el-text-color-primary);
}

.address-list {
  margin-top: 20px;
}

.address-item {
  padding: 20px;
  border: 1px solid var(--el-border-color);
  border-radius: 8px;
  margin-bottom: 15px;
  transition: all 0.3s ease;
}

.address-item:hover {
  border-color: var(--el-color-primary);
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
}

.address-header {
  display: flex;
  align-items: center;
  gap: 15px;
  margin-bottom: 10px;
}

.receiver {
  font-weight: bold;
  color: var(--el-text-color-primary);
}

.phone {
  color: var(--el-text-color-secondary);
  font-size: 14px;
}

.default-tag {
  background-color: var(--el-color-primary);
  color: #FFFFFF;
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 10px;
}

.address-detail {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  line-height: 1.4;
  margin-bottom: 15px;
}

.address-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.no-address {
  text-align: center;
  padding: 60px 0;
  color: var(--el-text-color-secondary);
}

.no-address p {
  margin-bottom: 20px;
  font-size: 16px;
}

/* 响应式 */
@media (max-width: 768px) {
  .profile-container {
    flex-direction: column;
  }
  
  .profile-sidebar {
    flex: 1;
    border-right: none;
    border-bottom: 1px solid var(--el-border-color);
  }
  
  .profile-content {
    padding: 20px;
  }
  
  .order-stats {
    flex-wrap: wrap;
  }
  
  .stat-item {
    flex: 1 1 calc(50% - 10px);
  }
}
</style>
