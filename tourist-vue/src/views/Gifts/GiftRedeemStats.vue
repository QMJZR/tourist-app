<template>
  <div class="gift-redeem-stats">
    <h3>{{ giftName }} 兑换统计</h3>
    
    <!-- 日期筛选区域 -->
    <el-form :inline="true" :model="dateFilters" class="filter-form" style="margin-bottom: 20px;">
      <el-form-item label="开始日期">
        <el-date-picker
          v-model="dateFilters.startDate"
          type="date"
          placeholder="选择开始日期"
          format="YYYY-MM-DD"
          value-format="YYYY-MM-DD"
        />
      </el-form-item>
      
      <el-form-item label="结束日期">
        <el-date-picker
          v-model="dateFilters.endDate"
          type="date"
          placeholder="选择结束日期"
          format="YYYY-MM-DD"
          value-format="YYYY-MM-DD"
        />
      </el-form-item>
      
      <el-form-item>
        <el-button type="primary" @click="fetchRedeemStats">查询</el-button>
        <el-button @click="resetFilters">重置</el-button>
      </el-form-item>
    </el-form>
    
    <!-- 兑换记录表格 -->
    <el-table :data="redeemRecords" style="width: 100%" v-loading="loading">
      <el-table-column prop="redeemId" label="兑换ID" width="120" />
      <el-table-column prop="userId" label="用户ID" width="120" />
      <el-table-column prop="username" label="用户名" width="150" />
      <el-table-column prop="pointsUsed" label="消耗积分" width="120" />
      <el-table-column prop="redeemTime" label="兑换时间" width="200" />
      <el-table-column prop="status" label="状态" width="120">
        <template #default="{ row }">
          <el-tag
            :type="row.status === 'redeemed' ? 'success' : row.status === 'pending' ? 'warning' : 'danger'"
          >
            {{ row.status === 'redeemed' ? '已兑换' : row.status === 'pending' ? '待处理' : '已取消' }}
          </el-tag>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 分页 -->
    <div style="margin-top: 20px; text-align: right;">
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </div>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getGiftRedeems } from '@/api/admin'

// 定义接收的props
const props = defineProps<{
  giftId: number
  giftName: string
}>()

// 定义emit事件
const emit = defineEmits<{
  (e: 'close'): void
}>()

// 定义兑换记录接口
interface RedeemRecord {
  redeemId: number
  userId: number
  username: string
  giftId: number
  pointsUsed: number
  redeemTime: string
  status: 'redeemed' | 'cancelled' | 'pending'
}

// 列表数据
const redeemRecords = ref<RedeemRecord[]>([])
const loading = ref(false)
const total = ref(0)

// 分页数据
const currentPage = ref(1)
const pageSize = ref(10)

// 日期筛选条件
const dateFilters = reactive({
  startDate: '',
  endDate: ''
})

// 获取兑换统计数据
const fetchRedeemStats = async () => {
  loading.value = true
  try {
    const res = await getGiftRedeems(props.giftId, dateFilters)
    if (res.data.code === 200) {
      redeemRecords.value = res.data.data
      total.value = res.data.data.length
    }
  } catch (error) {
    console.error('获取兑换统计失败:', error)
    ElMessage.error('获取兑换统计失败')
  } finally {
    loading.value = false
  }
}

// 重置筛选条件
const resetFilters = () => {
  dateFilters.startDate = ''
  dateFilters.endDate = ''
  fetchRedeemStats()
}

// 分页大小变化
const handleSizeChange = (val: number) => {
  pageSize.value = val
  currentPage.value = 1
  fetchRedeemStats()
}

// 页码变化
const handleCurrentChange = (val: number) => {
  currentPage.value = val
  fetchRedeemStats()
}

// 关闭弹窗
const handleClose = () => {
  emit('close')
}

// 组件挂载时获取数据
onMounted(fetchRedeemStats)
</script>

<style scoped>
.gift-redeem-stats {
  padding: 20px;
}
</style>