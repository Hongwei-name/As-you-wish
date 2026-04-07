<template>
  <div class="admin-product">
    <div class="admin-page-header">
      <h2 class="admin-page-title">商品管理</h2>
      <el-button type="primary" @click="handleAddProduct" class="add-btn">
        <el-icon><Plus /></el-icon>
        新增商品
      </el-button>
    </div>
    
    <div class="admin-card">
      <div class="admin-search-bar">
        <el-form :inline="true" :model="searchForm" class="admin-search-form">
          <el-form-item label="商品名称">
            <el-input v-model="searchForm.keyword" placeholder="请输入商品名称" clearable></el-input>
          </el-form-item>
          <el-form-item label="分类">
            <el-select v-model="searchForm.categoryId" placeholder="请选择分类" clearable>
              <el-option
                v-for="category in categoryList"
                :key="category.id"
                :label="category.name"
                :value="category.id"
              ></el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
              <el-option label="上架" value="1"></el-option>
              <el-option label="下架" value="0"></el-option>
            </el-select>
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
      
      <el-table :data="productList" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="商品ID" width="80"></el-table-column>
        <el-table-column prop="name" label="商品名称" min-width="150"></el-table-column>
        <el-table-column prop="categoryId" label="分类" width="120">
          <template #default="scope">
            {{ getCategoryName(scope.row.categoryId) }}
          </template>
        </el-table-column>
        <el-table-column prop="price" label="价格" width="100">
          <template #default="scope">
            ¥{{ scope.row.price.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column prop="stock" label="库存" width="80"></el-table-column>
        <el-table-column prop="sales" label="销量" width="80"></el-table-column>
        <el-table-column prop="status" label="状态" width="80">
          <template #default="scope">
            <el-switch
              v-model="scope.row.status"
              active-value="1"
              inactive-value="0"
              @change="(value) => onStatusChange(scope.row, value)"
            ></el-switch>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180"></el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="scope">
            <el-button type="primary" size="small" @click="handleEditProduct(scope.row)">
              编辑
            </el-button>
            <el-button type="danger" size="small" @click="handleDeleteProduct(scope.row.id)">
              删除
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
    
    <!-- 商品编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="800px">
      <el-form :model="productForm" :rules="productRules" ref="productFormRef" label-width="100px">
        <el-form-item label="商品名称" prop="name">
          <el-input v-model="productForm.name" placeholder="请输入商品名称"></el-input>
        </el-form-item>
        <el-form-item label="分类" prop="categoryId">
          <el-select v-model="productForm.categoryId" placeholder="请选择分类">
            <el-option
              v-for="category in categoryList"
              :key="category.id"
              :label="category.name"
              :value="category.id"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="价格" prop="price">
          <el-input v-model="productForm.price" type="number" placeholder="请输入价格" min="0" step="0.01"></el-input>
        </el-form-item>
        <el-form-item label="原价" prop="originalPrice">
          <el-input v-model="productForm.originalPrice" type="number" placeholder="请输入原价" min="0" step="0.01"></el-input>
        </el-form-item>
        <el-form-item label="库存" prop="stock">
          <el-input v-model="productForm.stock" type="number" placeholder="请输入库存" min="0"></el-input>
        </el-form-item>
        <el-form-item label="主图" prop="image">
          <el-input v-model="productForm.image" placeholder="请输入主图URL"></el-input>
        </el-form-item>
        <el-form-item label="商品简介" prop="description">
          <el-input v-model="productForm.description" type="textarea" placeholder="请输入商品简介"></el-input>
        </el-form-item>
        <el-form-item label="商品详情" prop="detail">
          <el-input v-model="productForm.detail" type="textarea" placeholder="请输入商品详情" :rows="4"></el-input>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-switch v-model="productForm.status" active-value="1" inactive-value="0"></el-switch>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSaveProduct">保存</el-button>
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
const productList = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const categoryList = ref([])

const searchForm = reactive({
  keyword: '',
  categoryId: '',
  status: ''
})

const dialogVisible = ref(false)
const dialogTitle = ref('新增商品')
const productForm = reactive({
  id: '',
  name: '',
  categoryId: '',
  price: '',
  originalPrice: '',
  stock: '',
  image: '',
  description: '',
  detail: '',
  status: 1
})

const productRules = {
  name: [{ required: true, message: '请输入商品名称', trigger: 'blur' }],
  categoryId: [{ required: true, message: '请选择分类', trigger: 'change' }],
  price: [{ required: true, message: '请输入价格', trigger: 'blur' }],
  stock: [{ required: true, message: '请输入库存', trigger: 'blur' }]
}

const productFormRef = ref(null)

const getCategoryName = (categoryId) => {
  const category = categoryList.value.find(c => c.id === categoryId)
  return category ? category.name : '未知'
}

const loadProductList = async () => {
  loading.value = true
  try {
    const response = await adminApi.getProductList({
      page: currentPage.value,
      size: pageSize.value,
      keyword: searchForm.keyword,
      categoryId: searchForm.categoryId,
      status: searchForm.status
    })
    if (response.code === 200) {
      // 处理商品列表，确保状态值为字符串类型
      productList.value = response.data.records.map(product => ({
        ...product,
        status: String(product.status)
      }))
      total.value = response.data.total
    }
  } catch (error) {
    ElMessage.error('获取商品列表失败')
  } finally {
    loading.value = false
  }
}

const loadCategoryList = async () => {
  try {
    const response = await adminApi.getCategoryList()
    if (response.code === 200) {
      categoryList.value = response.data
    }
  } catch (error) {
    ElMessage.error('获取分类列表失败')
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadProductList()
}

const resetSearch = () => {
  searchForm.keyword = ''
  searchForm.categoryId = ''
  searchForm.status = ''
  currentPage.value = 1
  loadProductList()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  loadProductList()
}

const handleCurrentChange = (current) => {
  currentPage.value = current
  loadProductList()
}

const handleAddProduct = () => {
  dialogTitle.value = '新增商品'
  Object.assign(productForm, {
    id: '',
    name: '',
    categoryId: '',
    price: '',
    originalPrice: '',
    stock: '',
    image: '',
    description: '',
    detail: '',
    status: 1
  })
  dialogVisible.value = true
}

const handleEditProduct = (product) => {
  dialogTitle.value = '编辑商品'
  Object.assign(productForm, product)
  dialogVisible.value = true
}

const handleSaveProduct = async () => {
  if (!productFormRef.value) return
  
  await productFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        let response
        if (productForm.id) {
          response = await adminApi.updateProduct(productForm)
        } else {
          response = await adminApi.addProduct(productForm)
        }
        if (response.code === 200) {
          ElMessage.success(productForm.id ? '更新成功' : '添加成功')
          dialogVisible.value = false
          loadProductList()
        } else {
          ElMessage.error(response.message || '操作失败')
        }
      } catch (error) {
        ElMessage.error('操作失败，请稍后重试')
      }
    }
  })
}

const handleDeleteProduct = (id) => {
  ElMessageBox.confirm('确定要删除这个商品吗？', '删除确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await adminApi.deleteProduct(id)
      if (response.code === 200) {
        ElMessage.success('删除成功')
        loadProductList()
      } else {
        ElMessage.error(response.message || '删除失败')
      }
    } catch (error) {
      ElMessage.error('删除失败，请稍后重试')
    }
  })
}

// 用于标记是否已完成初始化
const initialized = ref(false)

const onStatusChange = async (product, value) => {
  // 只有在初始化完成后才处理状态变更（避免页面加载时触发）
  if (!initialized.value) {
    return
  }
  
  try {
    // 将字符串转换为数字类型
    const status = parseInt(value)
    const response = await adminApi.updateProductStatus(product.id, status)
    if (response.code !== 200) {
      ElMessage.error(response.message || '更新状态失败')
      // 回滚状态，保持字符串类型
      product.status = product.status === "1" ? "0" : "1"
    } else {
      ElMessage.success('更新状态成功')
      // 不立即刷新商品列表，避免状态被重置
      // loadProductList()
      // 直接更新本地商品状态，保持UI一致性
      product.status = String(status)
    }
  } catch (error) {
    ElMessage.error('更新状态失败，请稍后重试')
    // 回滚状态，保持字符串类型
    product.status = product.status === "1" ? "0" : "1"
  }
}

onMounted(async () => {
  await loadCategoryList()
  await loadProductList()
  // 页面加载完成后标记为已初始化
  initialized.value = true
})
</script>

<style scoped>
.admin-product {
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