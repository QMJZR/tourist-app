<template>
  <div class="user-list">
    <h3>用户列表</h3>
    
    <!-- 查询表单 -->
    <el-form :inline="true" :model="filters" class="filter-form">
      <el-form-item label="用户ID">
        <el-input v-model="filters.userId" type="number" placeholder="用户ID" clearable></el-input>
      </el-form-item>
      
      <el-form-item label="关键字">
        <el-input v-model="filters.keyword" placeholder="用户名/昵称" clearable></el-input>
      </el-form-item>
      
      <el-form-item label="是否为商家">
        <el-select v-model="filters.isMerchant" placeholder="选择" clearable>
          <el-option label="是" value="Y"></el-option>
          <el-option label="否" value="N"></el-option>
        </el-select>
      </el-form-item>
      
      <el-form-item>
        <el-button type="primary" @click="fetchUserList">查询</el-button>
        <el-button @click="resetFilters">重置</el-button>
      </el-form-item>
    </el-form>
    
    <!-- 用户列表表格 -->
    <el-table :data="users" style="width: 100%" v-loading="loading">
      <el-table-column prop="userId" label="用户ID" width="80"></el-table-column>
      <el-table-column prop="username" label="用户名"></el-table-column>
      <el-table-column prop="nickname" label="昵称"></el-table-column>
      <el-table-column label="头像" width="100">
        <template #default="scope">
          <el-avatar :src="scope.row.avatar" size="small"></el-avatar>
        </template>
      </el-table-column>
      <el-table-column prop="email" label="邮箱"></el-table-column>
      <el-table-column prop="points" label="积分"></el-table-column>
      <el-table-column prop="checkinCount" label="打卡次数"></el-table-column>
      <el-table-column label="打卡景点数量" width="120">
        <template #default="scope">
          {{ scope.row.checkinSpotIds.length }}
        </template>
      </el-table-column>
      <el-table-column prop="isMerchant" label="是否商家" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.isMerchant === 'Y' ? 'success' : 'info'">
            {{ scope.row.isMerchant === 'Y' ? '是' : '否' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="120" fixed="right">
        <template #default="scope">
          <el-button type="primary" size="small" @click="handleEdit(scope.row)">
            编辑
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 分页组件 -->
    <div class="pagination-container">
      <el-pagination
        v-model:current-page="filters.page"
        v-model:page-size="filters.pageSize"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      ></el-pagination>
    </div>
    
    <!-- 编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      title="编辑用户"
      width="500px"
      :before-close="handleClose"
    >
      <el-form
        :model="editForm"
        label-width="100px"
        :rules="formRules"
        ref="editFormRef"
      >
        <el-form-item label="用户名" prop="username">
          <el-input v-model="editForm.username" readonly placeholder="用户名不可修改"></el-input>
        </el-form-item>
        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="editForm.nickname" placeholder="请输入昵称"></el-input>
        </el-form-item>
        <el-form-item label="头像" prop="avatar">
          <el-input v-model="editForm.avatar" placeholder="请输入头像URL"></el-input>
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="editForm.email" readonly placeholder="邮箱不可修改"></el-input>
        </el-form-item>
        <el-form-item label="积分" prop="points">
          <el-input-number
            v-model="editForm.points"
            :min="0"
            placeholder="请输入积分"
          ></el-input-number>
        </el-form-item>
        <el-form-item label="是否商家" prop="isMerchant">
          <el-select v-model="editForm.isMerchant" placeholder="请选择">
            <el-option label="是" value="Y"></el-option>
            <el-option label="否" value="N"></el-option>
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleUpdate">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getUserList, updateUser } from '@/api/admin'
import { ElMessage, ElForm } from 'element-plus'

// 加载状态
const loading = ref(false)

// 用户列表数据
const users = ref<any[]>([])
const total = ref(0)

// 查询条件
const filters = ref({
  userId: '',
  keyword: '',
  isMerchant: '',
  page: 1,
  pageSize: 20
})

// 编辑弹窗相关
const dialogVisible = ref(false)
const editFormRef = ref<InstanceType<typeof ElForm>>()
const editForm = ref({
  userId: 0,
  username: '',
  nickname: '',
  avatar: '',
  email: '',
  points: 0,
  isMerchant: 'N'
})

// 表单验证规则
const formRules = {
  nickname: [
    { required: true, message: '请输入昵称', trigger: 'blur' },
    { min: 2, max: 20, message: '昵称长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  avatar: [
    { required: true, message: '请输入头像URL', trigger: 'blur' }
  ],
  points: [
    { required: true, message: '请输入积分', trigger: 'blur' }
  ],
  isMerchant: [
    { required: true, message: '请选择是否商家', trigger: 'change' }
  ]
}

// 获取用户列表
const fetchUserList = async () => {
  loading.value = true
  try {
    // 如果输入了用户ID，直接调用获取单个用户接口
    if (filters.value.userId) {
      const userId = parseInt(filters.value.userId)
      if (!isNaN(userId)) {
        try {
          // 尝试获取单个用户
          const userRes = await import('@/api/admin').then(m => m.getUserById(userId))
          if (userRes.data.code === 200) {
            users.value = [userRes.data.data]
            total.value = 1
          } else {
            // 未找到用户，清空列表
            users.value = []
            total.value = 0
            ElMessage.info('未找到该用户')
          }
        } catch (error) {
          ElMessage.error('获取用户信息失败')
          users.value = []
          total.value = 0
        }
        loading.value = false
        return
      }
    }
    
    // 否则调用列表接口
    const res = await getUserList(filters.value)
    if (res.data.code === 200) {
      users.value = res.data.data.users
      total.value = res.data.data.total
    } else {
      ElMessage.error(res.data.message)
    }
  } catch (error) {
    ElMessage.error('获取用户列表失败')
  } finally {
    loading.value = false
  }
}

// 重置查询条件
const resetFilters = () => {
  filters.value = {
    userId: '',
    keyword: '',
    isMerchant: '',
    page: 1,
    pageSize: 20
  }
  fetchUserList()
}

// 页码变化
const handleCurrentChange = () => {
  fetchUserList()
}

// 每页条数变化
const handleSizeChange = () => {
  fetchUserList()
}

// 组件挂载时获取数据
onMounted(() => {
  fetchUserList()
})

// 处理编辑按钮点击
const handleEdit = (row: any) => {
  // 深拷贝用户数据到编辑表单
  editForm.value = JSON.parse(JSON.stringify(row))
  dialogVisible.value = true
}

// 处理弹窗关闭
const handleClose = () => {
  // 重置表单
  if (editFormRef.value) {
    editFormRef.value.resetFields()
  }
  dialogVisible.value = false
}

// 处理更新用户信息
const handleUpdate = async () => {
  if (!editFormRef.value) return
  
  // 表单验证
  await editFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        // 调用更新API
        const res = await updateUser(editForm.value.userId, {
          nickname: editForm.value.nickname,
          avatar: editForm.value.avatar,
          points: editForm.value.points,
          isMerchant: editForm.value.isMerchant
        })
        
        if (res.data.code === 200) {
          ElMessage.success('更新成功')
          dialogVisible.value = false
          // 刷新用户列表
          fetchUserList()
        } else {
          ElMessage.error(res.data.message)
        }
      } catch (error) {
        ElMessage.error('更新失败')
      }
    }
  })
}
</script>

<style scoped>
.user-list {
  padding: 20px;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.filter-form {
  margin-bottom: 20px;
  padding: 15px;
  background-color: #f5f7fa;
  border-radius: 8px;
}

.pagination-container {
  margin-top: 20px;
  text-align: right;
}
</style>