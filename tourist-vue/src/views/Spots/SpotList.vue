<template>
  <div>
    <h3>景点列表</h3>
    <el-button type="primary" @click="openDialog()">新增景点</el-button>

    <el-table :data="spots" style="width: 100%; margin-top: 20px;">
      <el-table-column prop="spotId" label="ID" width="80" />
      <el-table-column prop="name" label="名称" />
      <el-table-column prop="zoneId" label="引领区ID" width="120" />
      <el-table-column prop="latitude" label="纬度" width="120" />
      <el-table-column prop="longitude" label="经度" width="120" />
      <el-table-column prop="openTime" label="开放时间" width="120" />
      <el-table-column label="操作" width="180">
        <template #default="scope">
          <el-button type="primary" size="small" @click="openDialog(scope.row)">编辑</el-button>
          <el-button type="danger" size="small" @click="handleDeleteSpot(scope.row.spotId)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 弹窗表单 -->
    <el-dialog
        v-model="dialogVisible"
        :title="editSpot?.spotId ? '编辑景点' : '新增景点'"
    >
      <el-form :model="form" label-width="100px">
        <el-form-item label="名称">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="引领区ID">
          <el-input v-model.number="form.zoneId" />
        </el-form-item>
        <el-form-item label="纬度">
          <el-input v-model.number="form.latitude" />
        </el-form-item>
        <el-form-item label="经度">
          <el-input v-model.number="form.longitude" />
        </el-form-item>
        <el-form-item label="开放时间">
          <el-input v-model="form.openTime" placeholder="08:00-18:00" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input type="textarea" v-model="form.description" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveSpot">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref, onMounted } from 'vue'
import { getSpotList, createSpot, updateSpot, deleteSpot } from '@/api/admin'

const dialogVisible = ref(false)

interface Spot {
  spotId?: number
  name: string
  zoneId: number
  latitude: number
  longitude: number
  openTime?: string
  description: string
}

const spots = ref<Spot[]>([])
const editSpot = ref<Spot | null>(null)

const form = reactive<Spot>({
  name: '',
  zoneId: 0,
  latitude: 0,
  longitude: 0,
  openTime: '',
  description: ''
})

const fetchSpots = async () => {
  const res = await getSpotList()
  if (res.data.code === 200) {
    spots.value = res.data.data
  }
}

const openDialog = (spot?: Spot) => {
  console.log('openDialog', spot)

  if (spot) {
    Object.assign(form, spot)
    editSpot.value = spot
  } else {
    Object.assign(form, { name: '', zoneId: 0, latitude: 0, longitude: 0, openTime: '', description: '' })
    editSpot.value = null
  }
  dialogVisible.value = true
}

const saveSpot = async () => {
  if (editSpot.value && editSpot.value.spotId) {
    // 更新
    const res = await updateSpot(editSpot.value.spotId, form)
    if (res.data.code === 200) {
      fetchSpots()
      dialogVisible.value = false
    }
  } else {
    // 创建
    const res = await createSpot(form)
    if (res.data.code === 200) {
      fetchSpots()
      dialogVisible.value = false
    }
  }
}

const handleDeleteSpot = async (spotId: number) => {
  if (confirm('确定删除吗？')) {
    const res = await deleteSpot(spotId)
    if (res.data.code === 200) {
      fetchSpots()
    }
  }
}

onMounted(fetchSpots)
</script>
