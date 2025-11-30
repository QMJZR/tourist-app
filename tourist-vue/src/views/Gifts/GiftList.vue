<template>
  <div class="gift-list-page">
    <h3>礼品列表</h3>
    
    <!-- 搜索和过滤区域 -->
    <el-form :inline="true" :model="filters" class="filter-form" style="margin-bottom: 20px;">
      <el-form-item label="状态">
        <el-select v-model="filters.status" placeholder="选择状态" clearable>
          <el-option label="可兑换" value="available"></el-option>
          <el-option label="已售罄" value="soldOut"></el-option>
          <el-option label="已禁用" value="disabled"></el-option>
        </el-select>
      </el-form-item>
      
      <el-form-item label="关键字">
        <el-input v-model="filters.keyword" placeholder="礼品名称或描述" clearable>
          <template #append>
            <el-button @click="fetchGifts"><el-icon><Search /></el-icon></el-button>
          </template>
        </el-input>
      </el-form-item>
      
      <el-form-item>
        <el-button type="primary" @click="openDialog()">新增礼品</el-button>
      </el-form-item>
    </el-form>
    
    <!-- 礼品列表表格 -->
    <el-table :data="gifts" style="width: 100%" v-loading="loading">
      <el-table-column prop="giftId" label="ID" width="80" />
      <el-table-column prop="name" label="名称" />
      <el-table-column prop="description" label="描述" width="200" />
      <el-table-column prop="pointsRequired" label="所需积分" width="120" />
      <el-table-column prop="stock" label="库存" width="80" />
      <el-table-column label="状态" width="120">
        <template #default="{ row }">
          <el-tag
            :type="row.status === 'available' ? 'success' : row.status === 'soldOut' ? 'info' : 'danger'"
          >
            {{ row.status === 'available' ? '可兑换' : row.status === 'soldOut' ? '已售罄' : '已禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="supplier" label="供应商" width="150" />
      <el-table-column prop="validity" label="有效期" width="150" />
      <el-table-column label="操作" width="280">
        <template #default="{ row }">
          <el-button type="primary" size="small" @click="openDialog(row)">编辑</el-button>
          <el-button type="danger" size="small" @click="handleDeleteGift(row.giftId)">删除</el-button>
          <el-button type="info" size="small" @click="viewRedeemStats(row)">查看兑换统计</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="editGift?.giftId ? '编辑礼品' : '新增礼品'"
      width="500px"
    >
      <el-form :model="form" label-width="100px" style="margin-top: 20px;">
        <el-form-item label="名称">
          <el-input v-model="form.name" placeholder="请输入礼品名称" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input type="textarea" v-model="form.description" placeholder="请输入礼品描述" />
        </el-form-item>
        <el-form-item label="所需积分">
          <el-input-number v-model="form.pointsRequired" :min="1" :step="10" />
        </el-form-item>
        <el-form-item label="库存">
          <el-input-number v-model="form.stock" :min="0" :step="10" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="form.status">
            <el-option label="可兑换" value="available"></el-option>
            <el-option label="已禁用" value="disabled"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="供应商">
          <el-input v-model="form.supplier" placeholder="请输入供应商名称" />
        </el-form-item>
        <el-form-item label="有效期">
          <el-date-picker
            v-model="form.validity"
            type="date"
            placeholder="选择有效期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="图片">
          <el-input v-model="form.images[0]" placeholder="请输入图片URL" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveGift">保存</el-button>
      </template>
    </el-dialog>
    
    <!-- 兑换统计弹窗 -->
    <el-dialog
      v-model="redeemStatsVisible"
      :title="selectedGift?.name + ' 兑换统计'"
      width="800px"
    >
      <gift-redeem-stats
        v-if="selectedGift"
        :gift-id="selectedGift?.giftId ?? 0"
        :gift-name="selectedGift.name"
        @close="redeemStatsVisible = false"
      />
    </el-dialog>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import { getGifts, createGift, updateGift, deleteGift } from '@/api/admin'
import GiftRedeemStats from './GiftRedeemStats.vue'

// 定义礼品接口
interface Gift {
  giftId?: number
  name: string
  description: string
  images: string[]
  pointsRequired: number
  stock: number
  status: 'available' | 'soldOut' | 'disabled'
  supplier: string
  validity: string
}

// 列表数据
const gifts = ref<Gift[]>([])
const loading = ref(false)

// 搜索和过滤条件
const filters = reactive({
  status: '',
  keyword: ''
})

// 弹窗相关
const dialogVisible = ref(false)
const redeemStatsVisible = ref(false)
const editGift = ref<Gift | null>(null)
const selectedGift = ref<Gift | null>(null)
const form = reactive<Gift>({
  name: '',
  description: '',
  images: [''],
  pointsRequired: 100,
  stock: 0,
  status: 'available',
  supplier: '',
  validity: ''
})

// 获取礼品列表
const fetchGifts = async () => {
  loading.value = true
  try {
    const res = await getGifts(filters)
    if (res.data.code === 200) {
      gifts.value = res.data.data
    }
  } catch (error) {
    console.error('获取礼品列表失败:', error)
    ElMessage.error('获取礼品列表失败')
  } finally {
    loading.value = false
  }
}

// 打开弹窗
const openDialog = (gift?: Gift) => {
  if (gift) {
    editGift.value = gift
    Object.assign(form, { ...gift, images: [...gift.images] })
  } else {
    editGift.value = null
    Object.assign(form, {
      name: '',
      description: '',
      images: [''],
      pointsRequired: 100,
      stock: 0,
      status: 'available',
      supplier: '',
      validity: ''
    })
  }
  dialogVisible.value = true
}

// 保存礼品
const saveGift = async () => {
  // 简单验证
  if (!form.name || !form.description || !form.pointsRequired || !form.stock || !form.status) {
    ElMessage.warning('请填写必填字段')
    return
  }
  
  try {
    let res
    if (editGift.value?.giftId) {
      // 更新礼品
      res = await updateGift(editGift.value.giftId, form)
    } else {
      // 新增礼品
      res = await createGift(form)
    }
    
    if (res.data.code === 200) {
      ElMessage.success(editGift.value?.giftId ? '更新成功' : '新增成功')
      fetchGifts()
      dialogVisible.value = false
    }
  } catch (error) {
    console.error('保存礼品失败:', error)
    ElMessage.error('保存礼品失败')
  }
}

// 删除礼品
const handleDeleteGift = async (giftId: number) => {
  if (confirm('确定要删除这个礼品吗？')) {
    try {
      const res = await deleteGift(giftId)
      if (res.data.code === 200) {
        ElMessage.success('删除成功')
        fetchGifts()
      }
    } catch (error) {
      console.error('删除礼品失败:', error)
      ElMessage.error('删除礼品失败')
    }
  }
}

// 查看兑换统计
const viewRedeemStats = (gift: Gift) => {
  selectedGift.value = gift
  redeemStatsVisible.value = true
}

// 组件挂载时获取礼品列表
onMounted(fetchGifts)
</script>

<style scoped>
.gift-list-page {
  padding: 20px;
}
</style>