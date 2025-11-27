<template>
  <div>
    <h3>打卡点管理</h3>
    <el-button type="primary" @click="openDialog()">新增打卡点</el-button>

    <el-table :data="checkpoints" style="width: 100%; margin-top: 20px;">
      <el-table-column prop="checkpointId" label="ID" width="80" />
      <el-table-column prop="name" label="名称" />
      <el-table-column prop="spotId" label="景点ID" width="120" />
      <el-table-column prop="latitude" label="纬度" width="120" />
      <el-table-column prop="longitude" label="经度" width="120" />
      <el-table-column prop="openTime" label="开放时间" width="120" />
      <el-table-column label="操作" width="180">
        <template #default="scope">
          <el-button type="primary" size="small" @click="openDialog(scope.row)">编辑</el-button>
          <el-button type="danger" size="small" @click="hanldedeleteCheckpoint(scope.row.checkpointId)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog
        v-model="dialogVisible"
        :title="editCheckpoint?.checkpointId ? '编辑打卡点' : '新增打卡点'"
    >
      <el-form :model="form" label-width="100px">
        <el-form-item label="名称"><el-input v-model="form.name" /></el-form-item>
        <el-form-item label="景点ID"><el-input v-model.number="form.spotId" /></el-form-item>
        <el-form-item label="纬度"><el-input v-model.number="form.latitude" /></el-form-item>
        <el-form-item label="经度"><el-input v-model.number="form.longitude" /></el-form-item>
        <el-form-item label="开放时间"><el-input v-model="form.openTime" /></el-form-item>
        <el-form-item label="描述"><el-input type="textarea" v-model="form.description" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveCheckpoint">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref, onMounted } from 'vue'
import { getCheckpoints, createCheckpoint, updateCheckpoint, deleteCheckpoint } from '@/api/admin'

interface Checkpoint {
  checkpointId?: number
  name: string
  spotId: number
  latitude: number
  longitude: number
  openTime?: string
  description?: string
}

const checkpoints = ref<Checkpoint[]>([])
const dialogVisible = ref(false)
const editCheckpoint = ref<Checkpoint | null>(null)

const form = reactive<Checkpoint>({
  name: '',
  spotId: 0,
  latitude: 0,
  longitude: 0,
  openTime: '',
  description: ''
})

const fetchCheckpoints = async () => {
  const res = await getCheckpoints()
  if (res.data.code === 200) checkpoints.value = res.data.data
}

const openDialog = (checkpoint?: Checkpoint) => {
  if (checkpoint) Object.assign(form, checkpoint), editCheckpoint.value = checkpoint
  else Object.assign(form, { name: '', spotId: 0, latitude: 0, longitude: 0, openTime: '', description: '' }), editCheckpoint.value = null
  dialogVisible.value = true
}

const saveCheckpoint = async () => {
  if (editCheckpoint.value?.checkpointId) {
    const res = await updateCheckpoint(editCheckpoint.value.checkpointId, form)
    if (res.data.code === 200) fetchCheckpoints(), dialogVisible.value = false
  } else {
    const res = await createCheckpoint(form)
    if (res.data.code === 200) fetchCheckpoints(), dialogVisible.value = false
  }
}

const hanldedeleteCheckpoint = async (id: number) => {
  if (confirm('确定删除吗？')) {
    const res = await deleteCheckpoint(id)
    if (res.data.code === 200) fetchCheckpoints()
  }
}

onMounted(fetchCheckpoints)
</script>
