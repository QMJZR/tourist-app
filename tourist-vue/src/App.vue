<template>
  <div id="app" class="app-container">
    <!-- 顶部导航栏，仅在非登录/注册页面显示 -->
    <header class="app-header" v-if="!isAuthPage">
      <div class="logo">
        <img src="./assets/logo.svg" alt="Logo" width="50" height="50" />
        <span class="title">管理员后台</span>
      </div>
      <div class="header-right">
        <span>{{ userStore.userInfo?.username || '管理员' }}</span>
        <el-button type="text" @click="logout" style="color: #ffffff;">
          退出
        </el-button>
      </div>
    </header>

    <div class="app-body">
      <!-- 左侧菜单，仅在非登录/注册页面显示 -->
      <aside class="app-sidebar" v-if="!isAuthPage">
        <el-menu
            default-active="$route.path"
            class="el-menu-vertical-demo"
            @select="onMenuSelect"
            router
        >
          <el-menu-item index="/">仪表盘</el-menu-item>
          <el-sub-menu index="/spots">
            <template #title>景点管理</template>
            <el-menu-item index="/spots">景点列表</el-menu-item>
          </el-sub-menu>
          <el-sub-menu index="/checkpoints">
            <template #title>打卡点管理</template>
            <el-menu-item index="/checkpoints">打卡点列表</el-menu-item>
          </el-sub-menu>
          <el-sub-menu index="/points">
            <template #title>积分管理</template>
            <el-menu-item index="/points">积分规则</el-menu-item>
            <el-menu-item index="/userPointlogs">用户积分流水</el-menu-item>
          </el-sub-menu>
          <el-sub-menu index="/gifts">
            <template #title>礼品管理</template>
            <el-menu-item index="/gifts">礼品列表</el-menu-item>
            <el-menu-item index="/merchant-stats">核销统计</el-menu-item>
          </el-sub-menu>
          <el-sub-menu index="/users">
            <template #title>用户管理</template>
            <el-menu-item index="/users">用户列表</el-menu-item>
          </el-sub-menu>
        </el-menu>
      </aside>

      <!-- 主内容区域 -->
      <main class="app-content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from './store/user'
import { ElButton } from 'element-plus'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const logout = () => {
  userStore.logout()
  router.push('/login')
}

const onMenuSelect = (index: string) => {
  router.push(index)
}
// 判断当前页面是否是登录/注册页
const isAuthPage = computed(() => {
  return route.path.startsWith('/login') || route.path.startsWith('/register')
})

</script>



<style scoped>
.app-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

/* 顶部 */
.app-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #409eff;
  color: white;
  padding: 0 20px;
  height: 60px;
}

.logo {
  display: flex;
  align-items: center;
}

.logo .title {
  margin-left: 10px;
  font-weight: bold;
  font-size: 18px;
}

.header-right {
  display: flex;
  align-items: center;
}

.header-right span {
  margin-right: 10px;
}

/* 主体 */
.app-body {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.app-sidebar {
  width: 200px;
  background-color: #f5f7fa;
  overflow-y: auto;
}

.app-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}
</style>
