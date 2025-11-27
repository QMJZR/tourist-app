import { defineStore } from 'pinia'

interface UserInfo {
    userId?: number
    username?: string
    avatar?: string
}

interface UserState {
    token: string
    userInfo: UserInfo | null
}

export const useUserStore = defineStore('user', {
    state: (): UserState => ({
        token: localStorage.getItem('token') || '',
        userInfo: null
    }),
    actions: {
        setToken(token: string) {
            this.token = token
            localStorage.setItem('token', token)
        },
        setUserInfo(info: UserInfo) {
            this.userInfo = info
        },
        logout() {
            this.token = ''
            this.userInfo = null
            localStorage.removeItem('token')
        }
    }
})
