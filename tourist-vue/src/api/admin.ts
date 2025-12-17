import axios from '../utils/axiosConfig' 

// ----------------------
// 登录 / 登出 /注册
// ----------------------
export const login = (username: string, password: string) => {
    return axios.post('/v1/admin/auth/login', { username, password })
}

export const register = (username: string, password: string, email: string) => {
    return axios.post('/v1/admin/auth/register', { username, password, email })
}


// ----------------------
// 用户管理
// ----------------------
export const getUserList = (params?: {
    keyword?: string
    isMerchant?: string
    page?: number
    pageSize?: number
}) => {
    return axios.get('/admin/users', { params })
}

export const getUserById = (userId: number) => {
    return axios.get(`/admin/users/${userId}`)
}

export const updateUser = (userId: number, data: {
    nickname?: string
    avatar?: string
    points?: number
    isMerchant?: string
}) => {
    return axios.put(`/admin/users/${userId}`, data)
}

// ----------------------
// 景点 / 景区管理
// ----------------------
export const getSpotList = () => {
    return axios.get('/admin/spots')
}

export const createSpot = (data: any) => {
    return axios.post('/admin/spots', data)
}

export const updateSpot = (spotId: number, data: any) => {
    return axios.put(`/admin/spots/${spotId}`, data)
}

export const deleteSpot = (spotId: number) => {
    return axios.delete(`/admin/spots/${spotId}`)
}

// ----------------------
// 打卡点管理
// ----------------------
export const getCheckpoints = () => {
    return axios.get('/admin/checkpoints')
}

export const createCheckpoint = (data: any) => {
    return axios.post('/admin/checkpoints', data)
}

export const updateCheckpoint = (id: number, data: any) => {
    return axios.put(`/admin/checkpoints/${id}`, data)
}

export const deleteCheckpoint = (id: number) => {
    return axios.delete(`/admin/checkpoints/${id}`)
}

// ----------------------
// 获取积分规则列表
// ----------------------
export const getPointRules = () => {
    return axios.get('/admin/points/rules')
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
    return axios.post('/admin/points/rules', data)
}

// ----------------------
// 修改积分规则
// ----------------------
export const updatePointRule = (ruleId: number, data: {
    description?: string
    points?: number
    status?: string
}) => {
    return axios.put(`/admin/points/rules/${ruleId}`, data)
}

// ----------------------
// 删除积分规则
// ----------------------
export const deletePointRule = (ruleId: number) => {
    return axios.delete(`/admin/points/rules/${ruleId}`)
}

// 获取用户积分流水
export const getUserPointLogs = (userId: number, params?: {
    startDate?: string
    endDate?: string
    type?: string
}) => {
    return axios.get(`/admin/points/users/${userId}/logs`, { params })
}



// ----------------------
// 礼品管理
// ----------------------
export const getGifts = (params?: {
    status?: string
    keyword?: string
}) => {
    return axios.get('/admin/gifts', { params })
}

export const createGift = (data: any) => {
    return axios.post('/admin/gifts', data)
}

export const updateGift = (giftId: number, data: any) => {
    return axios.put(`/admin/gifts/${giftId}`, data)
}

export const deleteGift = (giftId: number) => {
    return axios.delete(`/admin/gifts/${giftId}`)
}

// 调整礼品库存
export const updateGiftStock = (giftId: number, stock: number) => {
    return axios.patch(`/admin/gifts/${giftId}/stock`, { stock })
}

// 获取礼品兑换记录
export const getGiftRedeems = (giftId: number, params?: {
    startDate?: string
    endDate?: string
}) => {
    return axios.get(`/admin/gifts/${giftId}/redeems`, { params })
}
