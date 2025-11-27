// src/mock/spots.ts
import { MockMethod } from 'vite-plugin-mock'

interface Spot {
    spotId: number
    name: string
    images?: string[]
    video?: string
    description: string
    zoneId: number
    latitude: number
    longitude: number
    openTime?: string
}

let spots: Spot[] = [
    {
        spotId: 101,
        name: '101景点',
        images: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
        video: 'https://example.com/video.mp4',
        description: '景点详细介绍',
        zoneId: 10,
        latitude: 11.11,
        longitude: 111.11,
        openTime: '08:00-18:00'
    },
    {
        spotId: 102,
        name: '102景点',
        images: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
        video: 'https://example.com/video.mp4',
        description: '景点详细介绍',
        zoneId: 11,
        latitude: 22.22,
        longitude: 222.22,
        openTime: '06:00-12:00'
    }
]

export default [
    // 获取景点列表
    {
        url: '/api/admin/spots',
        method: 'get',
        response: () => {
            return {
                code: 200,
                message: 'success',
                data: spots
            }
        }
    },
    // 根据 spotId 获取单个景点
    {
        url: '/api/admin/spots/:spotId',
        method: 'get',
        response: ({ query }: { query: { spotId: string } }) => {
            const spot = spots.find(s => s.spotId === Number(query.spotId))
            return {
                code: 200,
                message: 'success',
                data: spot || null
            }
        }
    },
    // 创建景点
    {
        url: '/api/admin/spots',
        method: 'post',
        response: ({ body }: { body: Spot }) => {
            const newSpot = { ...body, spotId: Date.now() } // mock 生成 id
            spots.push(newSpot)
            return {
                code: 200,
                message: 'success',
                data: newSpot
            }
        }
    },
    // 更新景点
    {
        url: '/api/admin/spots/:spotId',
        method: 'put',
        response: ({ body, query }: { body: Partial<Spot>; query: { spotId: string } }) => {
            const index = spots.findIndex(s => s.spotId === Number(query.spotId))
            if (index !== -1) {
                spots[index] = { ...spots[index], ...body }
                return { code: 200, message: 'success', data: spots[index] }
            }
            return { code: 404, message: 'Spot not found', data: null }
        }
    },
    // 删除景点
    {
        url: '/api/admin/spots/:spotId',
        method: 'delete',
        response: ({ query }: { query: { spotId: string } }) => {
            spots = spots.filter(s => s.spotId !== Number(query.spotId))
            return { code: 200, message: 'success', data: null }
        }
    }
] as MockMethod[]
