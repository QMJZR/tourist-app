<script lang="ts" setup>
import { ref, onMounted } from 'vue'
import { getMerchantStats } from '@/api/merchant'
import { ElMessage } from 'element-plus'

// 筛选条件
const filterForm = ref({
  startDate: '',
  endDate: '',
  giftId: undefined as number | undefined
})

// 统计数据
const totalVerified = ref(0)
const dailyStats = ref<{ date: string; verifiedCount: number }[]>([])
const details = ref<{
  redeemId: number
  userId: number
  username: string
  giftId: number
  giftName: string
  redeemTime: string
  status: string
}[]>([])

// 礼品列表（模拟数据，实际应该从API获取）
const gifts = ref([
  { giftId: 101, name: '限量钥匙扣' },
  { giftId: 102, name: '景区明信片套装' },
  { giftId: 103, name: '纪念T恤' }
])

// 加载状态
const loading = ref(false)

// 获取统计数据
const fetchStats = async () => {
  loading.value = true
  try {
    const response = await getMerchantStats({
      startDate: filterForm.value.startDate,
      endDate: filterForm.value.endDate,
      giftId: filterForm.value.giftId
    })
    if (response.data.code === 200) {
      totalVerified.value = response.data.data.totalVerified
      dailyStats.value = response.data.data.dailyStats
      details.value = response.data.data.details
      ElMessage.success('获取统计数据成功')
    } else {
      ElMessage.error(response.data.message || '获取统计数据失败')
    }
  } catch (error) {
    ElMessage.error('获取统计数据失败')
    console.error('获取统计数据失败:', error)
  } finally {
    loading.value = false
  }
}

// 初始化数据
onMounted(() => {
  fetchStats()
})

// 重置筛选条件
const resetFilter = () => {
  filterForm.value = {
    startDate: '',
    endDate: '',
    giftId: undefined
  }
  fetchStats()
}
</script>

<template>
  <div class="merchant-stats">
    <h2>商家核销统计</h2>
    
    <!-- 筛选区域 -->
    <el-card class="filter-card">
      <el-form :inline="true" class="demo-form-inline">
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="filterForm.startDate"
            type="date"
            placeholder="开始日期"
            value-format="YYYY-MM-DD"
          />
          <span style="margin: 0 10px;">至</span>
          <el-date-picker
            v-model="filterForm.endDate"
            type="date"
            placeholder="结束日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        
        <el-form-item label="礼品">
          <el-select v-model="filterForm.giftId" placeholder="选择礼品">
            <el-option
              v-for="gift in gifts"
              :key="gift.giftId"
              :label="gift.name"
              :value="gift.giftId"
            />
          </el-select>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="fetchStats" :loading="loading">查询</el-button>
          <el-button @click="resetFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    
    <!-- 统计概览 -->
    <el-card class="overview-card">
      <div class="overview-item">
        <h3>总核销数量</h3>
        <div class="overview-value">{{ totalVerified }}</div>
      </div>
    </el-card>
    
    <!-- 每日趋势 -->
    <el-card class="trend-card">
      <template #header>
        <div class="card-header">
          <span>每日核销趋势</span>
        </div>
      </template>
      <div class="trend-content">
        <div v-if="dailyStats.length === 0" class="empty-data">暂无数据</div>
        <div v-else class="trend-chart">
          <div 
            v-for="(item, index) in dailyStats" 
            :key="index"
            class="trend-item"
          >
            <div class="trend-date">{{ item.date }}</div>
            <div class="trend-bar-container">
              <div 
                class="trend-bar" 
                :style="{ height: `${(item.verifiedCount / Math.max(...dailyStats.map(s => s.verifiedCount))) * 100}%` }"
              ></div>
            </div>
            <div class="trend-count">{{ item.verifiedCount }}</div>
          </div>
        </div>
      </div>
    </el-card>
    
    <!-- 核销明细 -->
    <el-card class="details-card">
      <template #header>
        <div class="card-header">
          <span>核销明细</span>
        </div>
      </template>
      <el-table :data="details" style="width: 100%">
        <el-table-column prop="redeemId" label="兑换ID" width="100" />
        <el-table-column prop="userId" label="用户ID" width="100" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="giftId" label="礼品ID" width="100" />
        <el-table-column prop="giftName" label="礼品名称" width="150" />
        <el-table-column prop="redeemTime" label="兑换时间" width="200" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag type="success" v-if="scope.row.status === 'verified'">已核销</el-tag>
            <el-tag type="warning" v-else-if="scope.row.status === 'redeemed'">已兑换</el-tag>
            <el-tag type="info" v-else-if="scope.row.status === 'pending'">待处理</el-tag>
            <el-tag type="danger" v-else-if="scope.row.status === 'cancelled'">已取消</el-tag>
            <el-tag>{{ scope.row.status }}</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<style scoped>
.merchant-stats {
  padding: 20px;
}

.filter-card {
  margin-bottom: 20px;
}

.overview-card {
  margin-bottom: 20px;
}

.overview-item {
  text-align: center;
  padding: 20px 0;
}

.overview-item h3 {
  margin: 0 0 10px 0;
  font-size: 16px;
  color: #606266;
}

.overview-value {
  font-size: 32px;
  font-weight: bold;
  color: #409eff;
}

.trend-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.trend-content {
  padding: 20px 0;
}

.empty-data {
  text-align: center;
  color: #909399;
  padding: 40px 0;
}

.trend-chart {
  display: flex;
  align-items: flex-end;
  height: 200px;
  padding: 20px 0;
  gap: 20px;
}

.trend-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.trend-date {
  font-size: 12px;
  color: #606266;
}

.trend-bar-container {
  flex: 1;
  width: 100%;
  display: flex;
  align-items: flex-end;
  gap: 2px;
}

.trend-bar {
  width: 100%;
  background-color: #409eff;
  border-radius: 4px 4px 0 0;
  transition: height 0.3s ease;
}

.trend-count {
  font-size: 14px;
  font-weight: bold;
  color: #303133;
}

.details-card {
  margin-bottom: 20px;
}
</style>