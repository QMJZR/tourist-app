import { MockMethod } from 'vite-plugin-mock'

interface PointRule {
    ruleId: number
    type: string
    description: string
    points: number
    status: string
}

interface PointLog {
    logId: number
    userId: number
    type: string
    points: number
    description: string
    timestamp: string
}

interface PointLog {
    logId: number
    userId: number
    type: string
    points: number
    description: string
    timestamp: string
}

let pointLogs: PointLog[] = [
    {
        logId: 1001,
        userId: 1,
        type: 'checkin',
        points: 100,
        description: '首次打卡新点位奖励',
        timestamp: '2025-11-17T09:23:45Z'
    },
    {
        logId: 1002,
        userId: 1,
        type: 'redeem',
        points: -500,
        description: '兑换礼品消耗积分',
        timestamp: '2025-11-17T11:10:23Z'
    },
    {
        logId: 1003,
        userId: 2,
        type: 'checkin',
        points: 50,
        description: '每日打卡奖励',
        timestamp: '2025-11-18T08:00:00Z'
    }
]
let rules: PointRule[] = [
    { ruleId: 1, type: 'checkin', description: '首次打卡奖励', points: 100, status: 'enabled' },
    { ruleId: 2, type: 'redeem', description: '兑换礼品消耗积分', points: -500, status: 'enabled' },
]


export default [
    // 获取积分规则
    {
        url: '/api/admin/points/rules',
        method: 'get',
        response: () => ({ code: 200, message: 'success', data: rules })
    },
    // 新增积分规则
    {
        url: '/api/admin/points/rules',
        method: 'post',
        response: ({ body }: { body: PointRule }) => {
            const newRule = { ...body, ruleId: Date.now() }
            rules.push(newRule)
            return { code: 200, message: '新增成功', data: { ruleId: newRule.ruleId } }
        }
    },
    // 修改积分规则
    {
        url: '/api/admin/points/rules/:ruleId',
        method: 'put',
        response: ({ body, query }: { body: Partial<PointRule>, query: { ruleId: string } }) => {
            const index = rules.findIndex(r => r.ruleId === Number(query.ruleId))
            if (index !== -1) {
                rules[index] = { ...rules[index], ...body }
                return { code: 200, message: '更新成功', data: null }
            }
            return { code: 404, message: '规则不存在', data: null }
        }
    },
    // 删除积分规则
    {
        url: '/api/admin/points/rules/:ruleId',
        method: 'delete',
        response: ({ query }: { query: { ruleId: string } }) => {
            rules = rules.filter(r => r.ruleId !== Number(query.ruleId))
            return { code: 200, message: '删除成功', data: null }
        }
    },
    // 获取用户积分流水
    {
        url: '/api/admin/points/users/:userId/logs',
        method: 'get',
        response: ({ query, query: { startDate, endDate, type }, query: { userId } }: any) => {
            // 过滤用户
            let logs = pointLogs.filter(log => log.userId === Number(userId))

            // 过滤时间
            if (startDate) {
                console.log(startDate)
                logs = logs.filter(log => log.timestamp >= startDate)
            }
            if (endDate) {
                logs = logs.filter(log => log.timestamp <= endDate)
            }
            // 过滤类型
            if (type) {
                console.log(type)
                logs = logs.filter(log => log.type === type)
            }

            return {
                code: 200,
                message: 'success',
                data: logs
            }
        }
    }
] as MockMethod[]


