import axios from 'axios'

// ----------------------
// 登录 / 登出 /注册
// ----------------------
export const login = (username: string, password: string) => {
    return axios.post('/api/admin/login', { username, password })
}

export const register = (username: string, password: string, email: string) => {
    return axios.post('/api/admin/register', { username, password, email })
}

export const logout = () => {
    return axios.post('/api/admin/logout')
}

// ----------------------
// 用户管理
// ----------------------
export const getUserList = () => {
    return axios.get('/api/admin/users')
}

export const updateUser = (userId: number, data: any) => {
    return axios.put(`/api/admin/users/${userId}`, data)
}

// ----------------------
// 景点 / 景区管理
// ----------------------
export const getSpotList = () => {
    return axios.get('/api/admin/spots')
}

export const createSpot = (data: any) => {
    return axios.post('/api/admin/spots', data)
}

export const updateSpot = (spotId: number, data: any) => {
    return axios.put(`/api/admin/spots/${spotId}`, data)
}

export const deleteSpot = (spotId: number) => {
    return axios.delete(`/api/admin/spots/${spotId}`)
}

// ----------------------
// 打卡点管理
// ----------------------
export const getCheckpoints = () => {
    return axios.get('/api/admin/checkpoints')
}

export const createCheckpoint = (data: any) => {
    return axios.post('/api/admin/checkpoints', data)
}

export const updateCheckpoint = (id: number, data: any) => {
    return axios.put(`/api/admin/checkpoints/${id}`, data)
}

export const deleteCheckpoint = (id: number) => {
    return axios.delete(`/api/admin/checkpoints/${id}`)
}

// ----------------------
// 获取积分规则列表
// ----------------------
export const getPointRules = () => {
    return axios.get('/api/admin/points/rules')
}

// ----------------------
// 新增积分规则
// ----------------------
export const createPointRule = (data: {
    type: string
    description: string
    points: number
    status: string
}) => {
    return axios.post('/api/admin/points/rules', data)
}

// ----------------------
// 修改积分规则
// ----------------------
export const updatePointRule = (ruleId: number, data: {
    description?: string
    points?: number
    status?: string
}) => {
    return axios.put(`/api/admin/points/rules/${ruleId}`, data)
}

// ----------------------
// 删除积分规则
// ----------------------
export const deletePointRule = (ruleId: number) => {
    return axios.delete(`/api/admin/points/rules/${ruleId}`)
}

// 获取用户积分流水
export const getUserPointLogs = (userId: number, params?: {
    startDate?: string
    endDate?: string
    type?: string
}) => {
    return axios.get(`/api/admin/points/users/${userId}/logs`, { params })
}



// ----------------------
// 礼品管理
// ----------------------
export const getGifts = () => {
    return axios.get('/api/admin/gifts')
}

export const createGift = (data: any) => {
    return axios.post('/api/admin/gifts', data)
}

export const updateGift = (giftId: number, data: any) => {
    return axios.put(`/api/admin/gifts/${giftId}`, data)
}

export const deleteGift = (giftId: number) => {
    return axios.delete(`/api/admin/gifts/${giftId}`)
}
