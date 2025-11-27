import { MockMethod } from 'vite-plugin-mock'

interface User {
    userId: number
    username: string
    password: string
    nickname?: string
    avatar: string
    points: number
    checkinCount: number
    isMerchant: string
    checkinSpotIds: number[]
    email: string
}

// 初始用户列表
let users: User[] = [
    {
        userId: 1,
        username: 'admin',
        password: '123456',
        nickname: 'admin',
        avatar: 'https://i.pravatar.cc/150?img=3',
        points: 1000,
        checkinCount: 5,
        isMerchant: 'N',
        checkinSpotIds: [101, 102],
        email: 'admin@example.com'
    }
]

// 登录接口
const login: MockMethod = {
    url: '/api/admin/login',
    method: 'post',
    response: ({ body }: { body: { username: string; password: string } }) => {
        const { username, password } = body
        const user = users.find(u => u.username === username && u.password === password)
        if (user) {
            return {
                code: 200,
                message: 'success',
                data: {
                    token: 'mock-token',
                    user: {
                        userId: user.userId,
                        username: user.username,
                        nickname: user.nickname || user.username,
                        avatar: user.avatar,
                        points: user.points,
                        checkinCount: user.checkinCount,
                        isMerchant: user.isMerchant,
                        checkinSpotIds: user.checkinSpotIds,
                        email: user.email
                    }
                }
            }
        } else {
            return { code: 401, message: '用户名或密码错误' }
        }
    }
}

// 注册接口（临时存储在内存中）
const register: MockMethod = {
    url: '/api/admin/register',
    method: 'post',
    response: ({ body }: { body: { username: string; password: string; email: string } }) => {
        const { username, password, email } = body
        if (users.some(u => u.username === username)) {
            return { code: 400, message: '用户名已存在' }
        }

        const newUser: User = {
            userId: users.length + 1,
            username,
            password,
            nickname: username,
            avatar: 'https://i.pravatar.cc/150?img=4',
            points: 0,
            checkinCount: 0,
            isMerchant: 'N',
            checkinSpotIds: [],
            email
        }

        users.push(newUser)

        return { code: 200, message: '注册成功', data: newUser }
    }
}

export default [login, register] as MockMethod[]
