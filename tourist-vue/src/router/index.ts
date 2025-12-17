import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import Login from '@/views/Login.vue'
import Dashboard from '@/views/Dashboard.vue'
import SpotList from '@/views/Spots/SpotList.vue'
import CheckPoints from '@/views/Checkpoints/CheckPoints.vue'
import PointRules from "@/views/Points/PointRules.vue";
import Register from "@/views/Register.vue";
import UserPointLogs from "@/views/Points/UserPointLogs.vue";
import GiftList from "@/views/Gifts/GiftList.vue";
import UserList from "@/views/Users/UserList.vue";
import MerchantStats from "@/views/MerchantStats.vue";
import { useUserStore } from '@/store/user';
import { createPinia } from 'pinia';
const routes: Array<RouteRecordRaw> = [
    { path: '/login', name: 'Login', component: Login },
    { path: '/register', name: 'Register', component: Register },
    {
        path: '/',
        name: 'Dashboard',
        component: Dashboard,
        meta: { requiresAuth: true },
        children: [
            { path: 'spots', name: 'Spots', component: SpotList, meta: { requiresAuth: true } },
            { path: 'checkpoints', name: 'CheckPoints', component: CheckPoints, meta: { requiresAuth: true } },
            { path: 'points', name: 'PointRules', component: PointRules, meta: { requiresAuth: true } },
            { path: 'userPointlogs', name: 'UserPointLogs', component: UserPointLogs, meta: { requiresAuth: true } },
            { path: 'gifts', name: 'Gifts', component: GiftList, meta: { requiresAuth: true } },
            { path: 'users', name: 'Users', component: UserList, meta: { requiresAuth: true } },
            { path: 'merchant-stats', name: 'MerchantStats', component: MerchantStats, meta: { requiresAuth: true } },
        ]
    },
    { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

// 创建Pinia实例用于路由守卫
const pinia = createPinia();

// 路由守卫
router.beforeEach((to, from, next) => {
    const userStore = useUserStore(pinia);
    const token = userStore.token;
    if (to.meta.requiresAuth && !token) {
        next('/login')
    } else {
        next()
    }
})

export default router
