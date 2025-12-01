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

// 获取用户列表接口
const getUserList: MockMethod = {
    url: '/api/admin/users',
    method: 'get',
    response: ({ query }: {
        query: {
            keyword?: string
            isMerchant?: string
            page?: string
            pageSize?: string
        }
    }) => {
        const { keyword, isMerchant, page = '1', pageSize = '20' } = query

        // 初始用户数据，添加更多测试数据
        if (users.length === 1) {
            // 添加更多测试用户
            const testUsers = [
                {
                    userId: 2,
                    username: 'user1',
                    password: '123456',
                    nickname: '用户1',
                    avatar: 'https://i.pravatar.cc/150?img=5',
                    points: 1500,
                    checkinCount: 8,
                    isMerchant: 'Y',
                    checkinSpotIds: [101, 102, 103],
                    email: 'user1@example.com'
                },
                {
                    userId: 3,
                    username: 'user2',
                    password: '123456',
                    nickname: '用户2',
                    avatar: 'https://i.pravatar.cc/150?img=6',
                    points: 2000,
                    checkinCount: 12,
                    isMerchant: 'N',
                    checkinSpotIds: [101, 104],
                    email: 'user2@example.com'
                },
                {
                    userId: 4,
                    username: 'merchant1',
                    password: '123456',
                    nickname: '商家1',
                    avatar: 'https://i.pravatar.cc/150?img=7',
                    points: 5000,
                    checkinCount: 20,
                    isMerchant: 'Y',
                    checkinSpotIds: [101, 102, 103, 104, 105],
                    email: 'merchant1@example.com'
                },
                {
                    userId: 5,
                    username: 'user3',
                    password: '123456',
                    nickname: '用户3',
                    avatar: 'https://i.pravatar.cc/150?img=8',
                    points: 800,
                    checkinCount: 5,
                    isMerchant: 'N',
                    checkinSpotIds: [103, 104],
                    email: 'user3@example.com'
                },
                {
                    userId: 6,
                    username: 'user4',
                    password: '123456',
                    nickname: '用户4',
                    avatar: 'https://i.pravatar.cc/150?img=9',
                    points: 3200,
                    checkinCount: 15,
                    isMerchant: 'N',
                    checkinSpotIds: [101, 102, 103],
                    email: 'user4@example.com'
                }
            ]
            users.push(...testUsers)
        }

        // 过滤数据
        let filteredUsers = [...users]

        // 关键字过滤
        if (keyword) {
            const lowerKeyword = keyword.toLowerCase()
            filteredUsers = filteredUsers.filter(user =>
                user.username.toLowerCase().includes(lowerKeyword) ||
                (user.nickname && user.nickname.toLowerCase().includes(lowerKeyword))
            )
        }

        // 商家状态过滤
        if (isMerchant) {
            filteredUsers = filteredUsers.filter(user => user.isMerchant === isMerchant)
        }

        // 分页
        const pageNum = parseInt(page, 10)
        const pageSizeNum = parseInt(pageSize, 10)
        const total = filteredUsers.length
        const startIndex = (pageNum - 1) * pageSizeNum
        const paginatedUsers = filteredUsers.slice(startIndex, startIndex + pageSizeNum)

        return {
            code: 200,
            message: 'success',
            data: {
                total,
                users: paginatedUsers
            }
        }
    }
}

// 获取单个用户信息接口
const getUserById: MockMethod = {
    url: '/api/admin/users/:id',
    method: 'get',
    response: ({ url }: { url: string }) => {
        // 从URL中提取userId
        const userIdMatch = url.match(/\/api\/admin\/users\/(\d+)/)
        if (!userIdMatch) {
            return {
                code: 400,
                message: '无效的用户ID',
                data: null
            }
        }
        const userId = parseInt(userIdMatch[1], 10)
        const user = users.find(u => u.userId === userId)

        if (user) {
            return {
                code: 200,
                message: 'success',
                data: {
                    userId: user.userId,
                    username: user.username,
                    nickname: user.nickname || user.username,
                    avatar: user.avatar,
                    email: user.email,
                    points: user.points,
                    checkinCount: user.checkinCount,
                    checkinSpotIds: user.checkinSpotIds,
                    isMerchant: user.isMerchant
                }
            }
        } else {
            return {
                code: 404,
                message: '用户不存在',
                data: null
            }
        }
    }
}

// 修改用户信息接口
const updateUser: MockMethod = {
    url: '/api/admin/users/:id',
    method: 'put',
    response: ({ url, body }: { url: string; body: { nickname?: string; avatar?: string; points?: number; isMerchant?: string } }) => {
        // 从URL中提取userId
        const userIdMatch = url.match(/\/api\/admin\/users\/(\d+)/)
        if (!userIdMatch) {
            return {
                code: 400,
                message: '无效的用户ID',
                data: null
            }
        }
        const userId = parseInt(userIdMatch[1], 10)
        const userIndex = users.findIndex(u => u.userId === userId)

        if (userIndex === -1) {
            return {
                code: 404,
                message: '用户不存在',
                data: null
            }
        }

        // 更新用户信息
        const updatedUser = { ...users[userIndex] }
        if (body.nickname !== undefined) {
            updatedUser.nickname = body.nickname
        }
        if (body.avatar !== undefined) {
            updatedUser.avatar = body.avatar
        }
        if (body.points !== undefined) {
            updatedUser.points = body.points
        }
        if (body.isMerchant !== undefined) {
            updatedUser.isMerchant = body.isMerchant
        }

        users[userIndex] = updatedUser

        return {
            code: 200,
            message: '更新成功',
            data: null
        }
    }
}

export default [login, register, getUserList, getUserById, updateUser] as MockMethod[]
