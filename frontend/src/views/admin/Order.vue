<template>
  <div class="admin-order">
    <div class="admin-page-header">
      <h2 class="admin-page-title">订单管理</h2>
    </div>
    
    <div class="admin-card">
      <div class="admin-search-bar">
        <el-form :inline="true" :model="searchForm" class="admin-search-form">
          <el-form-item label="订单号">
            <el-input v-model="searchForm.keyword" placeholder="请输入订单号" clearable></el-input>
          </el-form-item>
          <el-form-item label="状态">
            <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
              <el-option label="待支付" value="0"></el-option>
              <el-option label="待发货" value="1"></el-option>
              <el-option label="待收货" value="2"></el-option>
              <el-option label="已完成" value="3"></el-option>
              <el-option label="已取消" value="4"></el-option>
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
      
      <el-table :data="orderList" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="订单ID" width="80"></el-table-column>
        <el-table-column prop="orderNo" label="订单号" min-width="180"></el-table-column>
        <el-table-column prop="userId" label="用户ID" width="80"></el-table-column>
        <el-table-column prop="totalAmount" label="总金额" width="100">
          <template #default="scope">
            ¥{{ scope.row.totalAmount.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180"></el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button type="primary" size="small" @click="handleViewOrder(scope.row)">
              查看
            </el-button>
            <el-button type="warning" size="small" @click="handleUpdateStatus(scope.row)" :disabled="!canUpdateStatus(scope.row.status)">
              处理
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
    
    <!-- 订单详情对话框 -->
    <el-dialog v-model="orderDialogVisible" title="订单详情" width="800px">
      <div v-if="currentOrder">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="订单号">{{ currentOrder.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="用户ID">{{ currentOrder.userId }}</el-descriptions-item>
          <el-descriptions-item label="收货人">{{ currentOrder.receiver }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ currentOrder.phone }}</el-descriptions-item>
          <el-descriptions-item label="收货地址">{{ currentOrder.address }}</el-descriptions-item>
          <el-descriptions-item label="总金额">¥{{ currentOrder.totalAmount.toFixed(2) }}</el-descriptions-item>
          <el-descriptions-item label="实付金额">¥{{ currentOrder.payAmount.toFixed(2) }}</el-descriptions-item>
          <el-descriptions-item label="运费">¥{{ currentOrder.freightAmount.toFixed(2) }}</el-descriptions-item>
          <el-descriptions-item label="订单状态">
            <el-tag :type="getStatusType(currentOrder.status)">{{ currentOrder.statusDesc }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ currentOrder.createdAt }}</el-descriptions-item>
          <el-descriptions-item label="支付时间">{{ currentOrder.paymentTime || '未支付' }}</el-descriptions-item>
          <el-descriptions-item label="发货时间">{{ currentOrder.deliveryTime || '未发货' }}</el-descriptions-item>
          <el-descriptions-item label="收货时间">{{ currentOrder.receiveTime || '未收货' }}</el-descriptions-item>
        </el-descriptions>
        
        <h3 style="margin-top: 20px; margin-bottom: 10px;">订单商品</h3>
        <el-table :data="currentOrder.orderItems" style="width: 100%">
          <el-table-column prop="productName" label="商品名称" min-width="200"></el-table-column>
          <el-table-column prop="price" label="单价" width="100">
            <template #default="scope">
              ¥{{ scope.row.price.toFixed(2) }}
            </template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" width="80"></el-table-column>
          <el-table-column prop="totalAmount" label="小计" width="100">
            <template #default="scope">
              ¥{{ scope.row.totalAmount.toFixed(2) }}
            </template>
          </el-table-column>
        </el-table>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="orderDialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
    
    <!-- 状态更新对话框 -->
    <el-dialog v-model="statusDialogVisible" title="更新订单状态" width="400px">
      <el-form :model="statusForm" label-width="80px">
        <el-form-item label="当前状态">
          <el-tag :type="getStatusType(statusForm.currentStatus)">{{ getStatusText(statusForm.currentStatus) }}</el-tag>
        </el-form-item>
        <el-form-item label="目标状态" prop="newStatus">
          <el-select v-model="statusForm.newStatus" placeholder="请选择目标状态">
            <el-option
              v-for="option in statusOptions"
              :key="option.value"
              :label="option.label"
              :value="option.value"
            ></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="statusDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleConfirmStatusUpdate">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import * as adminApi from '@/api/admin'

const loading = ref(false)
const orderList = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)

const searchForm = reactive({
  keyword: '',
  status: ''
})

const orderDialogVisible = ref(false)
const currentOrder = ref({})

const statusDialogVisible = ref(false)
const statusForm = reactive({
  orderId: '',
  currentStatus: '',
  newStatus: ''
})

const statusOptions = computed(() => {
  const options = []
  switch (statusForm.currentStatus) {
    case 0:
      options.push({ label: '标记为已支付', value: 1 })
      options.push({ label: '取消订单', value: 4 })
      break
    case 1:
      options.push({ label: '标记为已发货', value: 2 })
      break
    case 2:
      options.push({ label: '标记为已完成', value: 3 })
      break
  }
  return options
})

const getStatusText = (status) => {
  const statusMap = {
    0: '待支付',
    1: '待发货',
    2: '待收货',
    3: '已完成',
    4: '已取消',
    5: '已退款'
  }
  return statusMap[status] || '未知'
}

const getStatusType = (status) => {
  const typeMap = {
    0: 'warning',
    1: 'info',
    2: 'primary',
    3: 'success',
    4: 'danger',
    5: 'danger'
  }
  return typeMap[status] || 'info'
}

const canUpdateStatus = (status) => {
  return [0, 1, 2].includes(status)
}

const loadOrderList = async () => {
  loading.value = true
  try {
    const response = await adminApi.getOrderList({
      page: currentPage.value,
      size: pageSize.value,
      keyword: searchForm.keyword,
      status: searchForm.status
    })
    if (response.code === 200) {
      orderList.value = response.data.records
      total.value = response.data.total
    }
  } catch (error) {
    ElMessage.error('获取订单列表失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  currentPage.value = 1
  loadOrderList()
}

const resetSearch = () => {
  searchForm.keyword = ''
  searchForm.status = ''
  currentPage.value = 1
  loadOrderList()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  loadOrderList()
}

const handleCurrentChange = (current) => {
  currentPage.value = current
  loadOrderList()
}

const handleViewOrder = async (order) => {
  try {
    const response = await adminApi.getOrderById(order.id)
    if (response.code === 200) {
      currentOrder.value = response.data
      orderDialogVisible.value = true
    }
  } catch (error) {
    ElMessage.error('获取订单详情失败')
  }
}

const handleUpdateStatus = (order) => {
  statusForm.orderId = order.id
  statusForm.currentStatus = order.status
  statusForm.newStatus = ''
  statusDialogVisible.value = true
}

const handleConfirmStatusUpdate = async () => {
  if (!statusForm.newStatus) {
    ElMessage.warning('请选择目标状态')
    return
  }
  
  try {
    const response = await adminApi.updateOrderStatus(statusForm.orderId, statusForm.newStatus)
    if (response.code === 200) {
      ElMessage.success('状态更新成功')
      statusDialogVisible.value = false
      loadOrderList()
    } else {
      ElMessage.error(response.message || '状态更新失败')
    }
  } catch (error) {
    ElMessage.error('状态更新失败，请稍后重试')
  }
}

onMounted(() => {
  loadOrderList()
})
</script>

<style scoped>
.admin-order {
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