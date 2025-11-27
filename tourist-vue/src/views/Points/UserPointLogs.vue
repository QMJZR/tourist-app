<template>
  <div class="user-point-logs">
    <h3>用户积分流水</h3>

    <!-- 查询表单 -->
    <el-form :inline="true" :model="filters" class="filter-form">
      <el-form-item label="用户ID">
        <el-input v-model="filters.userId" placeholder="请输入用户ID"></el-input>
      </el-form-item>

      <el-form-item label="开始日期">
        <el-date-picker
            v-model="filters.startDate"
            type="date"
            placeholder="开始日期"
            format="YYYY-MM-DD"
        />
      </el-form-item>

      <el-form-item label="结束日期">
        <el-date-picker
            v-model="filters.endDate"
            type="date"
            placeholder="结束日期"
            format="YYYY-MM-DD"
        />
      </el-form-item>

      <el-form-item label="类型">
        <el-select v-model="filters.type" placeholder="选择类型" clearable>
          <el-option label="打卡" value="checkin"></el-option>
          <el-option label="兑换" value="redeem"></el-option>
          <el-option label="其他" value="other"></el-option>
        </el-select>
      </el-form-item>

      <el-form-item>
        <el-button type="primary" @click="fetchLogs">查询</el-button>
        <el-button @click="resetFilters">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 积分流水表格 -->
    <el-table :data="logs" style="width: 100%" v-loading="loading">
      <el-table-column prop="logId" label="流水ID" width="100" />
      <el-table-column prop="userId" label="用户ID" width="100" />
      <el-table-column prop="type" label="类型" width="120" />
      <el-table-column prop="points" label="积分" width="100" />
      <el-table-column prop="description" label="描述" />
      <el-table-column prop="timestamp" label="时间" width="180" />
    </el-table>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref } from 'vue'
import { getUserPointLogs } from '@/api/admin'

interface Filters {
  userId?: number
  startDate?: string
  endDate?: string
  type?: string
}
interface Log {
  logId: number
  userId: number
  type: string
  points: number
  description: string
  timestamp: string
}

const logs = ref<Log[]>([])
const loading = ref(false)

const filters = reactive<Filters>({
  userId: undefined,
  startDate: undefined,
  endDate: undefined,
  type: undefined
})

const fetchLogs = async () => {
  if (!filters.userId) {
    alert('请输入用户ID')
    return
  }
  loading.value = true
  try {
    const res = await getUserPointLogs(filters.userId, {
      startDate: filters.startDate,
      endDate: filters.endDate,
      type: filters.type
    })
    if (res.data.code === 200) {
      logs.value = res.data.data
    } else {
      alert(res.data.message)
    }
  } catch (err) {
    console.error(err)
    alert('获取积分流水失败')
  } finally {
    loading.value = false
  }
}

const resetFilters = () => {
  filters.userId = undefined
  filters.startDate = undefined
  filters.endDate = undefined
  filters.type = undefined
  logs.value = []
}
</script>

<style scoped>
.user-point-logs {
  padding: 20px;
}

.filter-form {
  margin-bottom: 20px;
}
</style>
