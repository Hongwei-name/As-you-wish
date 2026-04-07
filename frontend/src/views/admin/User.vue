<template>
  <div class="admin-user">
    <div class="admin-page-header">
      <h2 class="admin-page-title">用户管理</h2>
    </div>
    
    <div class="admin-card">
      <div class="admin-search-bar">
        <el-form :inline="true" :model="searchForm" class="admin-search-form">
          <el-form-item label="关键词">
            <el-input v-model="searchForm.keyword" placeholder="请输入用户名、昵称或手机号" clearable></el-input>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSearch">
              <el-icon><Search /></el-icon>
              搜索
            </el-button>
            <el-button @click="resetSearch">
              重置
            </el-button>
          </el-form-item>
        </el-form>
      </div>
      
      <el-table :data="userList" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="用户ID" width="80"></el-table-column>
        <el-table-column prop="username" label="用户名" min-width="120"></el-table-column>
        <el-table-column prop="nickname" label="昵称" min-width="120"></el-table-column>
        <el-table-column prop="phone" label="手机号" width="150"></el-table-column>
        <el-table-column prop="email" label="邮箱" min-width="150"></el-table-column>
        <el-table-column prop="role" label="角色" width="100">
          <template #default="scope">
            <el-tag v-if="scope.row.role === 1" type="success">管理员</el-tag>
            <el-tag v-else type="info">普通用户</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180"></el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="scope">
            <el-button type="primary" size="small" @click="handleViewUser(scope.row)">
              查看
            </el-button>
            <el-button type="warning" size="small" @click="handleChangeRole(scope.row)">
              {{ scope.row.role === 1 ? '取消管理员' : '设为管理员' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="admin-pagination">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        ></el-pagination>
      </div>
    </div>
    
    <!-- 用户详情对话框 -->
    <el-dialog v-model="userDialogVisible" title="用户详情" width="600px">
      <el-form :model="currentUser" label-width="100px">
        <el-form-item label="用户ID">
          <el-input v-model="currentUser.id" disabled></el-input>
        </el-form-item>
        <el-form-item label="用户名">
          <el-input v-model="currentUser.username" disabled></el-input>
        </el-form-item>
        <el-form-item label="昵称">
          <el-input v-model="currentUser.nickname" disabled></el-input>
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="currentUser.phone" disabled></el-input>
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="currentUser.email" disabled></el-input>
        </el-form-item>
        <el-form-item label="角色">
          <el-tag v-if="currentUser.role === 1" type="success">管理员</el-tag>
          <el-tag v-else type="info">普通用户</el-tag>
        </el-form-item>
        <el-form-item label="创建时间">
          <el-input v-model="currentUser.createdAt" disabled></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="userDialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import * as adminApi from '@/api/admin'

const loading = ref(false)
const userList = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)

const searchForm = reactive({
  keyword: ''
})

const userDialogVisible = ref(false)
const currentUser = reactive({})

const loadUserList = async () => {
  loading.value = true
  try {
    const response = await adminApi.getUserList({
      page: currentPage.value,
      size: pageSize.value,
      keyword: searchForm.keyword
    })
    if (response.code === 200) {
      userList.value = response.data.records
      total.value = response.data.total
    }
  } catch (error) {
    ElMessage.error('获取用户列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadUserList()
}

const resetSearch = () => {
  searchForm.keyword = ''
  currentPage.value = 1
  loadUserList()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  loadUserList()
}

const handleCurrentChange = (current) => {
  currentPage.value = current
  loadUserList()
}

const handleViewUser = async (user) => {
  try {
    const response = await adminApi.getUserById(user.id)
    if (response.code === 200) {
      Object.assign(currentUser, response.data)
      userDialogVisible.value = true
    }
  } catch (error) {
    ElMessage.error('获取用户详情失败')
  }
}

const handleChangeRole = (user) => {
  const newRole = user.role === 1 ? 0 : 1
  const message = user.role === 1 ? '确定要取消该用户的管理员权限吗？' : '确定要将该用户设为管理员吗？'
  
  ElMessageBox.confirm(message, '角色变更确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await adminApi.updateUserStatus(user.id, newRole)
      if (response.code === 200) {
        ElMessage.success('角色变更成功')
        loadUserList()
      } else {
        ElMessage.error(response.message || '角色变更失败')
      }
    } catch (error) {
      ElMessage.error('角色变更失败，请稍后重试')
    }
  })
}

onMounted(() => {
  loadUserList()
})
</script>

<style scoped>
.admin-user {
  width: 100%;
}

.admin-page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.admin-page-title {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

.admin-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  padding: 20px;
}

.admin-search-bar {
  margin-bottom: 20px;
}

.admin-search-form {
  gap: 10px;
}

.admin-pagination {
  margin-top: 20px;
  text-align: right;
}
</style>