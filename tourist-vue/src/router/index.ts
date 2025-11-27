import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import Login from '@/views/Login.vue'
import Dashboard from '@/views/Dashboard.vue'
import SpotList from '@/views/Spots/SpotList.vue'
import CheckPoints from '@/views/Checkpoints/CheckPoints.vue'
import PointRules from "@/views/Points/PointRules.vue";
import Register from "@/views/Register.vue";
import UserPointLogs from "@/views/Points/UserPointLogs.vue";
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
        ]
    },
    { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
    const token = sessionStorage.getItem('token')
    if (to.meta.requiresAuth && !token) {
        next('/login')
    } else {
        next()
    }
})

export default router
