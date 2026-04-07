<template>
  <div class="address">
    <div class="container">
      <h2 class="page-title">地址管理</h2>
      
      <!-- 操作按钮 -->
      <div class="action-bar">
        <el-button type="primary" @click="showAddDialog = true">
          <i class="el-icon-plus"></i> 添加地址
        </el-button>
      </div>
      
      <!-- 地址列表 -->
      <div class="address-list" v-if="addresses.length > 0">
        <div 
          v-for="address in addresses" 
          :key="address.id"
          class="address-item card-shadow"
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
          </div>
          <div class="address-actions">
            <el-button type="primary" size="small" @click="editAddress(address)">
              编辑
            </el-button>
            <el-button type="success" size="small" v-if="!address.isDefault" @click="setDefault(address.id)">
              默认
            </el-button>
            <el-button type="danger" size="small" @click="deleteAddress(address.id)">
              删除
            </el-button>
          </div>
        </div>
      </div>
      
      <!-- 空状态 -->
      <div class="empty-state" v-else>
        <i class="el-icon-location"></i>
        <p>暂无收货地址</p>
        <el-button type="primary" @click="showAddDialog = true">添加地址</el-button>
      </div>
      
      <!-- 添加/编辑地址弹窗 -->
      <el-dialog
        v-model="showAddDialog"
        :title="editingAddress ? '编辑地址' : '添加地址'"
        width="500px"
      >
        <el-form :model="addressForm" :rules="addressRules" ref="addressFormRef">
          <el-form-item label="收货人" prop="receiver">
            <el-input v-model="addressForm.receiver" placeholder="请输入收货人姓名"></el-input>
          </el-form-item>
          <el-form-item label="手机号" prop="phone">
            <el-input v-model="addressForm.phone" placeholder="请输入手机号"></el-input>
          </el-form-item>
          <el-form-item label="省份" prop="province">
            <el-input v-model="addressForm.province" placeholder="请输入省份"></el-input>
          </el-form-item>
          <el-form-item label="城市" prop="city">
            <el-input v-model="addressForm.city" placeholder="请输入城市"></el-input>
          </el-form-item>
          <el-form-item label="区县" prop="district">
            <el-input v-model="addressForm.district" placeholder="请输入区县"></el-input>
          </el-form-item>
          <el-form-item label="详细地址" prop="detail">
            <el-input type="textarea" v-model="addressForm.detail" placeholder="请输入详细地址"></el-input>
          </el-form-item>
          <el-form-item label="是否默认">
            <el-switch v-model="addressForm.isDefault"></el-switch>
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="showAddDialog = false">取消</el-button>
          <el-button type="primary" @click="saveAddress">保存</el-button>
        </template>
      </el-dialog>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { api } from '@/utils/request'

const router = useRouter()
const showAddDialog = ref(false)
const addresses = ref([])
const editingAddress = ref(null)
const addressFormRef = ref(null)

const addressForm = reactive({
  id: '',
  receiver: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detail: '',
  isDefault: false
})

const addressRules = {
  receiver: [
    { required: true, message: '请输入收货人姓名', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  province: [
    { required: true, message: '请输入省份', trigger: 'blur' }
  ],
  city: [
    { required: true, message: '请输入城市', trigger: 'blur' }
  ],
  district: [
    { required: true, message: '请输入区县', trigger: 'blur' }
  ],
  detail: [
    { required: true, message: '请输入详细地址', trigger: 'blur' }
  ]
}

// 获取地址列表
const getAddresses = async () => {
  try {
    const response = await api.address.list()
    addresses.value = response.data
  } catch (error) {
    console.error('获取地址失败:', error)
    ElMessage.error('获取地址失败')
  }
}

// 保存地址
const saveAddress = async () => {
  const valid = await addressFormRef.value.validate()
  if (!valid) return
  
  try {
    if (editingAddress.value) {
      // 编辑地址
      await api.address.update(addressForm)
      ElMessage.success('地址编辑成功')
    } else {
      // 添加地址
      await api.address.add(addressForm)
      ElMessage.success('地址添加成功')
    }
    showAddDialog.value = false
    getAddresses()
  } catch (error) {
    console.error('保存地址失败:', error)
    ElMessage.error('保存地址失败')
  }
}

// 编辑地址
const editAddress = (address) => {
  editingAddress.value = address
  Object.assign(addressForm, address)
  showAddDialog.value = true
}

// 设置默认地址
const setDefault = async (addressId) => {
  try {
    await api.address.setDefault(addressId)
    ElMessage.success('设置默认地址成功')
    getAddresses()
  } catch (error) {
    console.error('设置默认地址失败:', error)
    ElMessage.error('设置默认地址失败')
  }
}

// 删除地址
const deleteAddress = async (addressId) => {
  try {
    await ElMessageBox.confirm('确定要删除这个地址吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await api.address.delete(addressId)
    ElMessage.success('地址删除成功')
    getAddresses()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除地址失败:', error)
      ElMessage.error('删除地址失败')
    }
  }
}

// 初始化
onMounted(() => {
  getAddresses()
})
</script>

<style scoped>
.address {
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

.action-bar {
  margin-bottom: 20px;
  text-align: right;
}

.address-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.address-item {
  background-color: #FFFFFF;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  transition: all 0.3s ease;
}

.address-item:hover {
  box-shadow: 0 4px 12px rgba(184, 149, 110, 0.15);
}

.address-content {
  flex: 1;
  min-width: 0;
  margin-right: 20px;
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
  font-size: 16px;
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
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.address-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.empty-state {
  text-align: center;
  padding: 60px 0;
  background-color: #FFFFFF;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(184, 149, 110, 0.1);
  color: var(--el-text-color-placeholder);
}

.empty-state i {
  font-size: 48px;
  margin-bottom: 16px;
  display: block;
}

.empty-state p {
  font-size: 16px;
  margin-bottom: 20px;
}

/* 响应式 */
@media (max-width: 768px) {
  .address-list {
    grid-template-columns: 1fr;
  }
  
  .address-item {
    flex-direction: column;
    align-items: stretch;
  }
  
  .address-content {
    margin-right: 0;
    margin-bottom: 15px;
  }
  
  .address-actions {
    flex-direction: row;
    justify-content: flex-end;
  }
}
</style>