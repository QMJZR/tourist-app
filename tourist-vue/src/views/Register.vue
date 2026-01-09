<template>
  <div class="login-container">
    <el-card class="login-card" shadow="hover">
      <h2 class="login-title">管理员注册</h2>

      <el-form :model="form" class="login-form" label-position="top">
        <el-form-item label="用户名" :rules="[{ required: true, message: '请输入用户名', trigger: 'blur' }]">
          <el-input v-model="form.username" placeholder="请输入用户名" />
        </el-form-item>

        <el-form-item label="密码" :rules="[{ required: true, message: '请输入密码', trigger: 'blur' }]">
          <el-input
              type="password"
              v-model="form.password"
              placeholder="请输入密码"
              show-password
          />
        </el-form-item>

        <el-form-item label="邮箱" :rules="[{ required: true, message: '请输入邮箱', trigger: 'blur' }, { type: 'email', message: '邮箱格式不正确', trigger: 'blur' }]">
          <el-input v-model="form.email" placeholder="请输入邮箱" />
        </el-form-item>

        <div class="btn-group">
          <el-button type="primary" @click="register" size="large">注册</el-button>
          <el-button type="success" @click="goLogin" size="large">返回登录</el-button>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { register as apiRegister } from '@/api/admin'

interface RegisterForm {
  username: string
  password: string
  email: string
}

const router = useRouter()
const form = reactive<RegisterForm>({
  username: '',
  password: '',
  email: ''
})

const register = async () => {
  if (!form.username || !form.password || !form.email) {
    ElMessage.error('请完整填写表单')
    return
  }

  try {
    const res = await apiRegister(form.username, form.password, form.email)
    if (res.data.code === 200) {
      ElMessage.success('注册成功，跳转登录页')
      router.push('/login')
    } else {
      ElMessage.error(res.data.msg)
    }
  } catch (e) {
    ElMessage.error('注册失败')
  }
}

const goLogin = () => {
  router.push('/login')
}
</script>

<style scoped>
.login-container {
  width: 100vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: #f3f4f6;
}

.login-card {
  width: 360px;
  padding: 20px 30px;
  border-radius: 12px;
}

.login-title {
  text-align: center;
  margin-bottom: 25px;
  font-size: 22px;
  font-weight: 600;
}

.btn-group {
  display: flex;
  justify-content: space-between;
  margin-top: 10px;
}
</style>
