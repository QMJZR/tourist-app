import { MockMethod } from 'vite-plugin-mock'

interface Gift {
    giftId: number
    name: string
    description: string
    images: string[]
    pointsRequired: number
    stock: number
    status: 'available' | 'soldOut' | 'disabled'
    supplier: string
    validity: string
}

interface RedeemRecord {
    redeemId: number
    userId: number
    username: string
    giftId: number
    pointsUsed: number
    redeemTime: string
    status: 'redeemed' | 'cancelled' | 'pending' | 'verified'
}

let gifts: Gift[] = [
    {
        giftId: 101,
        name: '限量钥匙扣',
        description: '纪念景区限量钥匙扣',
        images: ['https://example.com/gift1.jpg'],
        pointsRequired: 500,
        stock: 100,
        status: 'available',
        supplier: '景区纪念品厂商',
        validity: '2025-12-31'
    },
    {
        giftId: 102,
        name: '景区明信片套装',
        description: '精美的景区明信片套装',
        images: ['https://example.com/gift2.jpg'],
        pointsRequired: 300,
        stock: 50,
        status: 'available',
        supplier: '文化用品公司',
        validity: '2025-12-31'
    },
    {
        giftId: 103,
        name: '纪念T恤',
        description: '景区纪念T恤',
        images: ['https://example.com/gift3.jpg'],
        pointsRequired: 800,
        stock: 0,
        status: 'soldOut',
        supplier: '服装厂商',
        validity: '2025-12-31'
    },
    {
        giftId: 104,
        name: '特色书签',
        description: '精美的特色书签',
        images: ['https://example.com/gift4.jpg'],
        pointsRequired: 200,
        stock: 200,
        status: 'available',
        supplier: '文化用品公司',
        validity: '2025-12-31'
    }
]

let redeemRecords: RedeemRecord[] = [
    {
        redeemId: 1001,
        userId: 1001,
        username: "test123",
        giftId: 101,
        pointsUsed: 500,
        redeemTime: "2025-11-17T09:23:45Z",
        status: "verified"
    },
    {
        redeemId: 1002,
        userId: 1002,
        username: "user456",
        giftId: 101,
        pointsUsed: 500,
        redeemTime: "2025-11-17T14:30:00Z",
        status: "verified"
    },
    {
        redeemId: 1003,
        userId: 1001,
        username: "test123",
        giftId: 102,
        pointsUsed: 300,
        redeemTime: "2025-11-18T10:15:00Z",
        status: "verified"
    },
    {
        redeemId: 1004,
        userId: 1003,
        username: "visitor789",
        giftId: 101,
        pointsUsed: 500,
        redeemTime: "2025-11-18T16:45:00Z",
        status: "verified"
    },
    {
        redeemId: 1005,
        userId: 1004,
        username: "tourist123",
        giftId: 102,
        pointsUsed: 300,
        redeemTime: "2025-11-18T11:30:00Z",
        status: "verified"
    },
    {
        redeemId: 1006,
        userId: 1005,
        username: "local456",
        giftId: 101,
        pointsUsed: 500,
        redeemTime: "2025-11-19T09:00:00Z",
        status: "verified"
    },
    {
        redeemId: 1007,
        userId: 1006,
        username: "traveler789",
        giftId: 102,
        pointsUsed: 300,
        redeemTime: "2025-11-19T13:15:00Z",
        status: "verified"
    },
    {
        redeemId: 1008,
        userId: 1007,
        username: "guest101",
        giftId: 103,
        pointsUsed: 800,
        redeemTime: "2025-11-19T15:20:00Z",
        status: "redeemed"
    }
]

export default [
    // 商家核销礼品
    {
        url: '/merchant/verify',
        method: 'post',
        response: ({ body }: { body: { redeemId: number; giftCode: string } }) => {
            const { redeemId, giftCode } = body

            // 查找兑换记录
            const recordIndex = redeemRecords.findIndex(r => r.redeemId === redeemId)
            if (recordIndex === -1) {
                return {
                    code: 404,
                    message: '兑换记录不存在',
                    data: null
                }
            }

            const record = redeemRecords[recordIndex]

            // 检查兑换记录状态
            if (record.status === 'verified' || record.status === 'cancelled') {
                return {
                    code: 400,
                    message: '兑换记录状态异常（已核销或已过期）',
                    data: null
                }
            }

            // 验证giftCode（简化处理，实际项目中应根据生成规则验证）
            // 这里假设giftCode格式为GIFT+redeemId后四位
            const expectedGiftCode = `GIFT${record.redeemId.toString().slice(-4)}`
            if (giftCode !== expectedGiftCode) {
                return {
                    code: 403,
                    message: '礼品码无效',
                    data: null
                }
            }

            // 查找对应的礼品
            const gift = gifts.find(g => g.giftId === record.giftId)
            if (!gift) {
                return {
                    code: 404,
                    message: '兑换记录对应的礼品不存在',
                    data: null
                }
            }

            // 这里简化处理，假设所有礼品都属于当前商家
            // 实际项目中需要根据merchantId进行验证
            // if (gift.merchantId !== currentMerchantId) {
            //     return {
            //         code: 403,
            //         message: '该礼品不属于当前商家',
            //         data: null
            //     }
            // }

            // 更新兑换记录状态为已核销
            redeemRecords[recordIndex] = {
                ...record,
                status: 'verified' as const
            }

            // 返回核销成功的响应
            return {
                code: 200,
                message: '核销成功',
                data: {
                    redeemId: record.redeemId,
                    userId: record.userId,
                    username: record.username,
                    giftId: record.giftId,
                    giftName: gift.name,
                    merchantId: 501, // 模拟商家ID
                    redeemTime: record.redeemTime,
                    status: 'verified'
                }
            }
        }
    },
    // 获取礼品列表
    {
        url: '/api/admin/gifts',
        method: 'get',
        response: ({ query }: { query: { status?: string; keyword?: string } }) => {
            let filteredGifts = [...gifts]

            // 状态过滤
            if (query.status) {
                filteredGifts = filteredGifts.filter(gift => gift.status === query.status)
            }

            // 关键字搜索
            if (query.keyword) {
                const keyword = query.keyword.toLowerCase()
                filteredGifts = filteredGifts.filter(gift =>
                    gift.name.toLowerCase().includes(keyword) ||
                    gift.description.toLowerCase().includes(keyword)
                )
            }

            return {
                code: 200,
                message: 'success',
                data: filteredGifts
            }
        }
    },
    // 根据 giftId 获取单个礼品
    {
        url: '/api/admin/gifts/:giftId',
        method: 'get',
        response: ({ query }: { query: { giftId: string } }) => {
            const gift = gifts.find(g => g.giftId === Number(query.giftId))
            return {
                code: 200,
                message: 'success',
                data: gift || null
            }
        }
    },
    // 创建礼品
    {
        url: '/api/admin/gifts',
        method: 'post',
        response: ({ body }: { body: Gift }) => {
            const newGift = { ...body, giftId: Date.now() }
            gifts.push(newGift)
            return {
                code: 200,
                message: '新增成功',
                data: null
            }
        }
    },
    // 更新礼品
    {
        url: '/api/admin/gifts/:giftId',
        method: 'put',
        response: ({ body, query }: { body: Partial<Gift>; query: { giftId: string } }) => {
            const index = gifts.findIndex(g => g.giftId === Number(query.giftId))
            if (index !== -1) {
                gifts[index] = { ...gifts[index], ...body }
                // 根据库存更新状态
                if ('stock' in body) {
                    if (body.stock !== undefined && body.stock <= 0) {
                        gifts[index].status = 'soldOut'
                    } else if (gifts[index].status === 'soldOut') {
                        gifts[index].status = 'available'
                    }
                }
                return { code: 200, message: '更新成功', data: null }
            }
            return { code: 404, message: '礼品不存在', data: null }
        }
    },
    // 删除礼品
    {
        url: '/api/admin/gifts/:giftId',
        method: 'delete',
        response: ({ query }: { query: { giftId: string } }) => {
            const giftId = Number(query.giftId)
            const giftIndex = gifts.findIndex(g => g.giftId === giftId)
            if (giftIndex === -1) {
                return { code: 404, message: '礼品不存在', data: null }
            }
            gifts = gifts.filter(g => g.giftId !== giftId)
            return { code: 200, message: '删除成功', data: null }
        }
    },
    // 调整礼品库存
    {
        url: '/api/admin/gifts/:giftId/stock',
        method: 'patch',
        response: ({ body, query }: { body: { stock: number }; query: { giftId: string } }) => {
            const giftId = Number(query.giftId)
            const giftIndex = gifts.findIndex(g => g.giftId === giftId)
            if (giftIndex === -1) {
                return { code: 404, message: '礼品不存在', data: null }
            }
            gifts[giftIndex].stock = body.stock
            // 根据库存更新状态
            if (body.stock <= 0) {
                gifts[giftIndex].status = 'soldOut'
            } else if (gifts[giftIndex].status === 'soldOut') {
                gifts[giftIndex].status = 'available'
            }
            return { code: 200, message: '库存更新成功', data: null }
        }
    },
    // 获取礼品兑换记录
    {
        url: '/api/admin/gifts/:giftId/redeems',
        method: 'get',
        response: ({ query }: { query: { giftId: string; startDate?: string; endDate?: string } }) => {
            const giftId = Number(query.giftId)

            // 检查礼品是否存在
            const gift = gifts.find(g => g.giftId === giftId)
            if (!gift) {
                return { code: 404, message: '礼品不存在', data: null }
            }

            // 过滤该礼品的兑换记录
            let filteredRedeems = redeemRecords.filter(record => record.giftId === giftId)

            // 按开始时间过滤
            if (query.startDate) {
                filteredRedeems = filteredRedeems.filter(record => {
                    const recordDate = new Date(record.redeemTime).toISOString().split('T')[0]
                    return recordDate >= query.startDate!
                })
            }

            // 按结束时间过滤
            if (query.endDate) {
                filteredRedeems = filteredRedeems.filter(record => {
                    const recordDate = new Date(record.redeemTime).toISOString().split('T')[0]
                    return recordDate <= query.endDate!
                })
            }

            return {
                code: 200,
                message: 'success',
                data: filteredRedeems
            }
        }
    },
    // 获取商家核销统计
    {
        url: '/merchant/stats',
        method: 'get',
        response: ({ query }: { query: { startDate?: string; endDate?: string; giftId?: string } }) => {
            const { startDate, endDate, giftId } = query

            // 过滤已核销的记录
            let filteredRecords = redeemRecords.filter(record => record.status === 'verified')

            // 按礼品ID过滤
            if (giftId) {
                const giftIdNum = Number(giftId)
                filteredRecords = filteredRecords.filter(record => record.giftId === giftIdNum)
            }

            // 按开始时间过滤
            if (startDate) {
                filteredRecords = filteredRecords.filter(record => {
                    const recordDate = new Date(record.redeemTime).toISOString().split('T')[0]
                    return recordDate >= startDate
                })
            }

            // 按结束时间过滤
            if (endDate) {
                filteredRecords = filteredRecords.filter(record => {
                    const recordDate = new Date(record.redeemTime).toISOString().split('T')[0]
                    return recordDate <= endDate
                })
            }

            // 计算总核销数量
            const totalVerified = filteredRecords.length

            // 生成每日统计
            const dailyStatsMap: Map<string, number> = new Map()
            filteredRecords.forEach(record => {
                const date = new Date(record.redeemTime).toISOString().split('T')[0]
                dailyStatsMap.set(date, (dailyStatsMap.get(date) || 0) + 1)
            })

            const dailyStats = Array.from(dailyStatsMap.entries())
                .map(([date, count]) => ({ date, verifiedCount: count }))
                .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())

            // 生成明细数据
            const details = filteredRecords.map(record => {
                const gift = gifts.find(g => g.giftId === record.giftId)
                return {
                    redeemId: record.redeemId,
                    userId: record.userId,
                    username: record.username,
                    giftId: record.giftId,
                    giftName: gift?.name || '未知礼品',
                    redeemTime: record.redeemTime,
                    status: record.status
                }
            })

            return {
                code: 200,
                message: 'success',
                data: {
                    totalVerified,
                    dailyStats,
                    details
                }
            }
        }
    }
] as MockMethod[]