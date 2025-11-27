// src/mock/checkpoints.ts
import { MockMethod } from 'vite-plugin-mock'

interface Checkpoint {
    checkpointId: number
    name: string
    spotId: number
    description?: string
    latitude: number
    longitude: number
    openTime?: string
}

let checkpoints: Checkpoint[] = [
    {
        checkpointId: 201,
        name: '打卡点A',
        spotId: 101,
        description: '101景点的第一个打卡点',
        latitude: 11.111,
        longitude: 111.111,
        openTime: '08:00-18:00'
    },
    {
        checkpointId: 202,
        name: '打卡点B',
        spotId: 102,
        description: '102景点的打卡点',
        latitude: 22.222,
        longitude: 222.222,
        openTime: '09:00-17:00'
    }
]

export default [
    // 获取打卡点列表
    {
        url: '/api/admin/checkpoints',
        method: 'get',
        response: () => {
            return {
                code: 200,
                message: 'success',
                data: checkpoints
            }
        }
    },
    // 根据 checkpointId 获取单个打卡点
    {
        url: '/api/admin/checkpoints/:checkpointId',
        method: 'get',
        response: ({ query }: { query: { checkpointId: string } }) => {
            const checkpoint = checkpoints.find(c => c.checkpointId === Number(query.checkpointId))
            return {
                code: 200,
                message: 'success',
                data: checkpoint || null
            }
        }
    },
    // 创建打卡点
    {
        url: '/api/admin/checkpoints',
        method: 'post',
        response: ({ body }: { body: Checkpoint }) => {
            const newCheckpoint = { ...body, checkpointId: Date.now() } // mock 生成 id
            checkpoints.push(newCheckpoint)
            return {
                code: 200,
                message: 'success',
                data: newCheckpoint
            }
        }
    },
    // 更新打卡点
    {
        url: '/api/admin/checkpoints/:checkpointId',
        method: 'put',
        response: ({ body, query }: { body: Partial<Checkpoint>; query: { checkpointId: string } }) => {
            const index = checkpoints.findIndex(c => c.checkpointId === Number(query.checkpointId))
            if (index !== -1) {
                checkpoints[index] = { ...checkpoints[index], ...body }
                return { code: 200, message: 'success', data: checkpoints[index] }
            }
            return { code: 404, message: 'Checkpoint not found', data: null }
        }
    },
    // 删除打卡点
    {
        url: '/api/admin/checkpoints/:checkpointId',
        method: 'delete',
        response: ({ query }: { query: { checkpointId: string } }) => {
            checkpoints = checkpoints.filter(c => c.checkpointId !== Number(query.checkpointId))
            return { code: 200, message: 'success', data: null }
        }
    }
] as MockMethod[]
