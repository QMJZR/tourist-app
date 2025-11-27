<template>
  <div class="point-rules-page">
    <h2>积分规则管理</h2>

    <!-- 新增规则按钮 -->
    <el-button type="primary" @click="openDialog()">新增规则</el-button>

    <!-- 积分规则表格 -->
    <el-table :data="rules" style="width: 100%; margin-top: 20px">
      <el-table-column prop="ruleId" label="规则ID" width="100" />
      <el-table-column prop="type" label="类型" width="120" />
      <el-table-column prop="description" label="描述" />
      <el-table-column prop="points" label="积分" width="100" />
      <el-table-column label="状态" width="120">
        <template #default="{ row }">
          <el-switch
              v-model="row.status"
              active-value="enabled"
              inactive-value="disabled"
              @change="updateStatus(row)"
          />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="180">
        <template #default="{ row }">
          <el-button size="small" @click="openDialog(row)">编辑</el-button>
          <el-button size="small" type="danger" @click="deleteRule(row.ruleId)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible"
               :title="currentRule ? '编辑规则' : '新增规则'"
    >
      <el-form :model="form" label-width="100px">
        <el-form-item label="类型">
          <el-input v-model="form.type" placeholder="checkin / redeem / other" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" />
        </el-form-item>
        <el-form-item label="积分">
          <el-input-number v-model="form.points" :min="-999999" :max="999999" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.status" active-value="enabled" inactive-value="disabled" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveRule">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  getPointRules,
  createPointRule,
  updatePointRule,
  deletePointRule,
} from '@/api/admin' // 你的积分 API

interface PointRule {
  ruleId: number
  type: string
  description: string
  points: number
  status: 'enabled' | 'disabled'
}

// 表格数据
const rules = ref<PointRule[]>([])

// 弹窗控制
const dialogVisible = ref(false)
const currentRule = ref<PointRule | null>(null)

// 表单数据
interface RuleForm {
  type: string
  description: string
  points: number
  status: 'enabled' | 'disabled'
}

const form = reactive<RuleForm>({
  type: '',
  description: '',
  points: 0,
  status: 'enabled'
})


// 获取规则列表
const fetchRules = async () => {
  try {
    const res = await getPointRules()
    if (res.data.code === 200) {
      rules.value = res.data.data
    }
  } catch (error) {
    console.error(error)
  }
}

// 打开弹窗（新增/编辑）
const openDialog = (rule?: PointRule) => {
  if (rule) {
    currentRule.value = rule
    Object.assign(form, rule)
  } else {
    currentRule.value = null
    Object.assign(form, { type: '', description: '', points: 0, status: 'enabled' })
  }
  dialogVisible.value = true
}

// 保存规则
const saveRule = async () => {
  try {
    if (currentRule.value) {
      // 编辑
      const res = await updatePointRule(currentRule.value.ruleId, form)
      if (res.data.code === 200) {
        ElMessage.success('更新成功')
        fetchRules()
        dialogVisible.value = false
      }
    } else {
      // 新增
      const res = await createPointRule(form)
      if (res.data.code === 200) {
        ElMessage.success('新增成功')
        fetchRules()
        dialogVisible.value = false
      }
    }
  } catch (error) {
    console.error(error)
  }
}

// 删除规则
const deleteRule = async (ruleId: number) => {
  if (!confirm('确定要删除该规则吗？')) return
  try {
    const res = await deletePointRule(ruleId)
    if (res.data.code === 200) {
      ElMessage.success('删除成功')
      fetchRules()
    }
  } catch (error) {
    console.error(error)
  }
}

// 状态开关
const updateStatus = async (row: PointRule) => {
  await updatePointRule(row.ruleId, { status: row.status })
}

onMounted(() => {
  fetchRules()
})
</script>

<style scoped>
.point-rules-page {
  padding: 20px;
}
</style>
