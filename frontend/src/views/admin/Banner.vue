<template>
  <div class="admin-banner">
    <div class="banner-header">
      <h2 class="banner-title">轮播图管理</h2>
    </div>
    
    <div class="banner-actions">
      <el-button type="primary" @click="dialogVisible = true">
        <el-icon><Plus /></el-icon>
        新增轮播图
      </el-button>
    </div>
    
    <div class="banner-list">
      <el-table :data="banners" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column label="图片" width="150">
          <template #default="scope">
            <el-image
              :src="scope.row.image"
              fit="cover"
              :preview-src-list="[scope.row.image]"
              style="width: 100px; height: 50px"
            ></el-image>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="标题" min-width="150"></el-table-column>
        <el-table-column prop="link" label="链接" min-width="200"></el-table-column>
        <el-table-column prop="sort" label="排序" width="80"></el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-switch
              v-model="scope.row.status"
              active-value="1"
              inactive-value="0"
              @change="(value) => handleStatusChange(scope.row, value)"
            ></el-switch>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180"></el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="scope">
            <el-button type="primary" size="small" @click="editBanner(scope.row)">
              <el-icon><Edit /></el-icon>
              编辑
            </el-button>
            <el-button type="danger" size="small" @click="deleteBanner(scope.row.id)">
              <el-icon><Delete /></el-icon>
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
    
    <!-- 轮播图对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
    >
      <el-form :model="bannerForm" label-width="100px">
        <el-form-item label="图片">
          <el-upload
            class="avatar-uploader"
            :action="uploadUrl"
            :show-file-list="false"
            :on-success="handleUploadSuccess"
            :before-upload="beforeUpload"
          >
            <el-image
              v-if="bannerForm.image"
              :src="bannerForm.image"
              fit="cover"
              style="width: 100%; height: 200px; cursor: pointer"
            ></el-image>
            <div v-else class="upload-dragger">
              <el-icon class="upload-icon"><Plus /></el-icon>
              <div class="upload-text">点击或拖拽上传图片</div>
              <div class="upload-hint">支持 JPG、PNG 格式，建议尺寸 1920x500</div>
            </div>
          </el-upload>
        </el-form-item>
        <el-form-item label="标题">
          <el-input v-model="bannerForm.title" placeholder="请输入轮播图标题"></el-input>
        </el-form-item>
        <el-form-item label="链接">
          <el-input v-model="bannerForm.link" placeholder="请输入跳转链接"></el-input>
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="bannerForm.sort" :min="0" :max="999" placeholder="请输入排序值"></el-input-number>
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="bannerForm.status" active-value="1" inactive-value="0"></el-switch>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveBanner">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElIcon, ElMessage } from 'element-plus'
import { Plus, Edit, Delete } from '@element-plus/icons-vue'
import * as adminApi from '@/api/admin'

const banners = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增轮播图')
const uploadUrl = '/api/admin/banner/upload' // 假设的上传接口

const bannerForm = reactive({
  id: null,
  title: '',
  image: '',
  link: '',
  sort: 0,
  status: '1'
})

const loadBanners = async () => {
  try {
    const response = await adminApi.getBannerList()
    if (response.code === 200) {
      banners.value = response.data
    }
  } catch (error) {
    console.error('获取轮播图列表失败:', error)
    ElMessage.error('获取轮播图列表失败')
  }
}

const handleStatusChange = async (banner, value) => {
  try {
    const status = parseInt(value)
    const response = await adminApi.updateBannerStatus(banner.id, status)
    if (response.code !== 200) {
      ElMessage.error('更新状态失败')
      // 回滚状态
      banner.status = banner.status === "1" ? "0" : "1"
    }
  } catch (error) {
    console.error('更新状态失败:', error)
    ElMessage.error('更新状态失败')
    // 回滚状态
    banner.status = banner.status === "1" ? "0" : "1"
  }
}

const editBanner = (banner) => {
  dialogTitle.value = '编辑轮播图'
  Object.assign(bannerForm, banner)
  dialogVisible.value = true
}

const deleteBanner = async (id) => {
  try {
    const response = await adminApi.deleteBanner(id)
    if (response.code === 200) {
      ElMessage.success('删除成功')
      loadBanners()
    }
  } catch (error) {
    console.error('删除失败:', error)
    ElMessage.error('删除失败')
  }
}

const handleUploadSuccess = (response, file) => {
  if (response.code === 200) {
    bannerForm.image = response.data.url
  } else {
    ElMessage.error('上传失败')
  }
}

const beforeUpload = (file) => {
  const isJpgOrPng = file.type === 'image/jpeg' || file.type === 'image/png'
  if (!isJpgOrPng) {
    ElMessage.error('只能上传 JPG 或 PNG 格式的图片')
  }
  const isLt2M = file.size / 1024 / 1024 < 2
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB')
  }
  return isJpgOrPng && isLt2M
}

const saveBanner = async () => {
  try {
    let response
    if (bannerForm.id) {
      response = await adminApi.updateBanner(bannerForm)
    } else {
      response = await adminApi.addBanner(bannerForm)
    }
    if (response.code === 200) {
      ElMessage.success(bannerForm.id ? '更新成功' : '添加成功')
      dialogVisible.value = false
      loadBanners()
      resetForm()
    }
  } catch (error) {
    console.error('保存失败:', error)
    ElMessage.error('保存失败')
  }
}

const resetForm = () => {
  bannerForm.id = null
  bannerForm.title = ''
  bannerForm.image = ''
  bannerForm.link = ''
  bannerForm.sort = 0
  bannerForm.status = '1'
}

onMounted(() => {
  loadBanners()
})
</script>

<style scoped>
.admin-banner {
  width: 100%;
}

.banner-header {
  margin-bottom: 20px;
}

.banner-title {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

.banner-actions {
  margin-bottom: 20px;
}

.banner-list {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.upload-dragger {
  width: 100%;
  height: 200px;
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: border-color 0.3s;
}

.upload-dragger:hover {
  border-color: #409eff;
}

.upload-icon {
  font-size: 48px;
  color: #c0c4cc;
  margin-bottom: 16px;
}

.upload-text {
  font-size: 14px;
  color: #606266;
  margin-bottom: 8px;
}

.upload-hint {
  font-size: 12px;
  color: #909399;
}

.dialog-footer {
  width: 100%;
  display: flex;
  justify-content: flex-end;
}
</style>