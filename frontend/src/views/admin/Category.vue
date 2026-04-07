<template>
  <div class="admin-category">
    <div class="admin-page-header">
      <h2 class="admin-page-title">分类管理</h2>
      <el-button type="primary" @click="handleAddCategory" class="add-btn">
        <el-icon><Plus /></el-icon>
        新增分类
      </el-button>
    </div>
    
    <div class="admin-card">
      <el-tree
        :data="categoryTree"
        :props="defaultProps"
        node-key="id"
        :expand-on-click-node="false"
        @node-click="handleNodeClick"
      >
        <template #default="{ node, data }">
          <div class="category-node">
            <span>{{ data.name }}</span>
            <span class="category-actions">
              <el-button type="primary" size="small" @click.stop="handleAddSubCategory(data)">
                添加子分类
              </el-button>
              <el-button type="warning" size="small" @click.stop="handleEditCategory(data)">
                编辑
              </el-button>
              <el-button type="danger" size="small" @click.stop="handleDeleteCategory(data)" :disabled="data.level === 1 && data.children && data.children.length > 0">
                删除
              </el-button>
            </span>
          </div>
        </template>
      </el-tree>
    </div>
    
    <!-- 分类编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px">
      <el-form :model="categoryForm" :rules="categoryRules" ref="categoryFormRef" label-width="80px">
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="categoryForm.name" placeholder="请输入分类名称"></el-input>
        </el-form-item>
        <el-form-item label="父分类" prop="parentId" v-if="!isRootCategory">
          <el-select v-model="categoryForm.parentId" placeholder="请选择父分类">
            <el-option
              v-for="category in categoryList"
              :key="category.id"
              :label="category.name"
              :value="category.id"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input v-model="categoryForm.sort" type="number" placeholder="请输入排序值" min="0"></el-input>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-switch v-model="categoryForm.status" active-value="1" inactive-value="0"></el-switch>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSaveCategory">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import * as adminApi from '@/api/admin'

const categoryList = ref([])
const categoryTree = ref([])
const defaultProps = {
  children: 'children',
  label: 'name'
}

const dialogVisible = ref(false)
const dialogTitle = ref('新增分类')
const isRootCategory = ref(false)

const categoryForm = reactive({
  id: '',
  name: '',
  parentId: 0,
  sort: 0,
  status: 1
})

const categoryRules = {
  name: [{ required: true, message: '请输入分类名称', trigger: 'blur' }],
  sort: [{ required: true, message: '请输入排序值', trigger: 'blur' }]
}

const categoryFormRef = ref(null)

const loadCategoryList = async () => {
  try {
    const response = await adminApi.getCategoryList()
    if (response.code === 200) {
      categoryList.value = response.data
      buildCategoryTree()
    }
  } catch (error) {
    ElMessage.error('获取分类列表失败')
  }
}

const buildCategoryTree = () => {
  const rootCategories = categoryList.value.filter(cat => cat.parentId === 0)
  const buildTree = (categories, parentId) => {
    return categories
      .filter(cat => cat.parentId === parentId)
      .map(cat => ({
        ...cat,
        children: buildTree(categories, cat.id)
      }))
  }
  categoryTree.value = buildTree(categoryList.value, 0)
}

const handleNodeClick = (data) => {
  console.log('Node clicked:', data)
}

const handleAddCategory = () => {
  dialogTitle.value = '新增分类'
  isRootCategory.value = true
  Object.assign(categoryForm, {
    id: '',
    name: '',
    parentId: 0,
    sort: 0,
    status: 1
  })
  dialogVisible.value = true
}

const handleAddSubCategory = (parentCategory) => {
  dialogTitle.value = '新增子分类'
  isRootCategory.value = false
  Object.assign(categoryForm, {
    id: '',
    name: '',
    parentId: parentCategory.id,
    sort: 0,
    status: 1
  })
  dialogVisible.value = true
}

const handleEditCategory = (category) => {
  dialogTitle.value = '编辑分类'
  isRootCategory.value = category.parentId === 0
  Object.assign(categoryForm, category)
  dialogVisible.value = true
}

const handleSaveCategory = async () => {
  if (!categoryFormRef.value) return
  
  await categoryFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        let response
        if (categoryForm.id) {
          response = await adminApi.updateCategory(categoryForm)
        } else {
          response = await adminApi.addCategory(categoryForm)
        }
        if (response.code === 200) {
          ElMessage.success(categoryForm.id ? '更新成功' : '添加成功')
          dialogVisible.value = false
          loadCategoryList()
        } else {
          ElMessage.error(response.message || '操作失败')
        }
      } catch (error) {
        ElMessage.error('操作失败，请稍后重试')
      }
    }
  })
}

const handleDeleteCategory = (category) => {
  const message = category.children && category.children.length > 0 ? '该分类下有子分类，确定要删除吗？' : '确定要删除这个分类吗？'
  
  ElMessageBox.confirm(message, '删除确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await adminApi.deleteCategory(category.id)
      if (response.code === 200) {
        ElMessage.success('删除成功')
        loadCategoryList()
      } else {
        ElMessage.error(response.message || '删除失败')
      }
    } catch (error) {
      ElMessage.error('删除失败，请稍后重试')
    }
  })
}

onMounted(() => {
  loadCategoryList()
})
</script>

<style scoped>
.admin-category {
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

.add-btn {
  margin-left: 10px;
}

.admin-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  padding: 20px;
}

.category-node {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.category-actions {
  display: flex;
  gap: 5px;
}

:deep(.el-tree-node__content) {
  height: 40px;
  line-height: 40px;
}
</style>