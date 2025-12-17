import axios from '../utils/axiosConfig' 

// ----------------------
// 商家核销礼品
// ----------------------
/**
 * 核销礼品
 * @param data 核销数据
 * @returns 核销结果
 */
export const verifyGift = (data: {
    redeemId: number
    giftCode: string
}) => {
    return axios.post('/merchant/verify', data)
}

// ----------------------
// 商家核销统计
// ----------------------
/**
 * 获取核销统计
 * @param params 查询参数
 * @returns 核销统计数据
 */
export const getMerchantStats = (params?: {
    startDate?: string
    endDate?: string
    giftId?: number
}) => {
    return axios.get('/merchant/stats', { params })
}
