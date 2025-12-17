<template>
  <div class="login-container">
    <el-card class="login-card" shadow="hover">
      <h2 class="login-title">游客App - 管理员端</h2>

      <el-form :model="form" class="login-form" label-position="top">
        <el-form-item label="用户名">
          <el-input v-model="form.username" placeholder="请输入用户名" />
        </el-form-item>

        <el-form-item label="密码">
          <el-input
              type="password"
              v-model="form.password"
              placeholder="请输入密码"
              show-password
          />
        </el-form-item>

        <el-form-item class="button-group" style="display: flex; gap: 10px; justify-content: center;">
          <el-button
              type="primary"
              size="large"
              style="flex: 1"
              @click="login"
          >
            登录
          </el-button>
          <el-button
              type="success"
              size="large"
              style="flex: 1"
              @click="goRegister"
          >
            注册
          </el-button>
        </el-form-item>

      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import { useRouter } from 'vue-router'
import { login as apiLogin } from '@/api/admin'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'

interface LoginForm {
  username: string
  password: string
}

const router = useRouter()
const userStore = useUserStore()
const form = reactive<LoginForm>({ username: '', password: '' })

const login = async () => {
  if (!form.username || !form.password) {
    ElMessage.error('请输入账号和密码')
    return
  }

  try {
    const res = await apiLogin(form.username, form.password)
    // 从res.data中获取后端返回的数据
    const responseData = res.data
    if (responseData.code === 200) {
      userStore.setToken(responseData.data.token)
      ElMessage.success('登录成功')
      router.push('/')
    } else {
      ElMessage.error(responseData.msg)
    }
  } catch (e) {
    ElMessage.error('登录失败')
  }
}

const goRegister = () => {
  router.push('/register')
}

</script>

<style scoped>
html, body {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
  overflow: hidden;
}

.login-container {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  background: #f3f4f6;
  overflow: hidden;
}

.login-card {
  width: 360px;
  max-width: 90%;
  padding: 20px 30px;
  border-radius: 12px;
  margin: 0;
}

.login-title {
  text-align: center;
  margin-bottom: 25px;
  font-size: 22px;
  font-weight: 600;
}

.login-btn {
  width: 100%;
  margin-top: 10px;
}

.el-form {
  margin: 0;
}


</style>
