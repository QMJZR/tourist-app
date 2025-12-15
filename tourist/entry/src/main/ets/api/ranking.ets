// entry/src/main/ets/api/ranking.ets

import { http } from "@kit.NetworkKit";
import StorageUtil from "../utils/Storage";

// ==================== 排行榜相关接口定义 ====================

/**
 * 排行榜项接口
 */
export interface RankingItem {
  rank: number;          // 排名
  userId: number;       // 用户ID
  username: string;     // 用户名
  avatar: string;       // 用户头像
  totalCheckins: number; // 总打卡数
  totalLikes: number;   // 总点赞数
  score: number;        // 综合评分
}

/**
 * 排行榜列表响应数据接口
 */
export interface RankingsData {
  list: RankingItem[];
  page: number;
  pageSize: number;
  total: number;
}

/**
 * 排行榜API响应接口
 */
export interface RankingsApiResponse {
  code: number;
  message: string;  // 注意：排行榜接口使用的是message，不是msg
  data: RankingsData | null;
}

/**
 * 获取排行榜的请求参数
 */
export interface GetRankingsParams {
  period?: string;  // 时间周期："daily" | "weekly" | "monthly"，默认"weekly"
  page?: number;    // 页码，默认1
  sort?: string;    // 排序方式："points" | "checkins"，默认"points"
}

// ==================== API函数 ====================

/**
 * 获取排行榜数据
 * @param params 请求参数，包含period、page、sort
 * @returns Promise<RankingsApiResponse | void> 响应结果
 */
export async function getRankings(params: GetRankingsParams = {}): Promise<RankingsApiResponse | void> {
  let request = http.createHttp();

  try {
    // 需要先从存储获取token
    const token = await StorageUtil.getToken();
    if (!token) {
      console.warn('未找到token，请先登录');
      return;
    }

    console.log('🔍 DEBUG: Token from storage =', token);
    console.log('🔍 DEBUG: Token length =', token.length);

    // 构建查询参数
    const period = params.period || 'weekly';
    const page = params.page || 1;
    const sort = params.sort || 'points';

    const url = `http://10.54.37.27:8080/rankings?period=${period}&page=${page}&sort=${sort}`;
    console.log('🔍 DEBUG: 请求URL =', url);

    const response = await request.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'token': token  // 双token头，保持与现有接口一致
        }
      }
    );

    console.log('🔍 DEBUG: 排行榜响应状态 =', response.responseCode);

    // 安全的header访问
    if (response.header) {
      console.log('🔍 DEBUG: 响应Headers =', response.header);
    }

    if (response.result) {
      const resultStr = String(response.result);
      console.log('🔍 DEBUG: 响应Body =', resultStr);
    }

    if (response.responseCode === 200) {
      if (response.result) {
        const resultStr = String(response.result);
        console.log('排行榜响应:', resultStr);

        try {
          const res: RankingsApiResponse = JSON.parse(resultStr);

          if (res.code === 200 && res.data) {
            console.log('获取排行榜成功');
            return res;
          } else {
            console.log('获取排行榜失败:', res.message);
            return res;
          }
        } catch (parseError) {
          console.error('解析排行榜响应失败:', parseError);
        }
      } else {
        console.warn('响应结果为空');
      }
    } else {
      console.log("获取排行榜失败，状态码:", response.responseCode);

      // 添加详细错误信息
      if (response.result) {
        const errorResult = String(response.result);
        console.log("错误响应内容:", errorResult);
        try {
          const errorJson: RankingsApiResponse = JSON.parse(errorResult);
          console.log("错误JSON:", errorJson);
        } catch (e) {
          console.log("错误内容不是JSON格式");
        }
      }
    }
  } catch (error) {
    console.error('获取排行榜异常:', error);
  } finally {
    request.destroy();
  }
}

/**
 * 获取今日排行榜
 * @param page 页码，默认1
 * @param sort 排序方式，默认"points"
 * @returns Promise<RankingsApiResponse | void> 响应结果
 */
export async function getDailyRankings(page: number = 1, sort: string = 'points'): Promise<RankingsApiResponse | void> {
  return await getRankings({ period: 'daily', page, sort });
}

/**
 * 获取本周排行榜
 * @param page 页码，默认1
 * @param sort 排序方式，默认"points"
 * @returns Promise<RankingsApiResponse | void> 响应结果
 */
export async function getWeeklyRankings(page: number = 1, sort: string = 'points'): Promise<RankingsApiResponse | void> {
  return await getRankings({ period: 'weekly', page, sort });
}

/**
 * 获取本月排行榜
 * @param page 页码，默认1
 * @param sort 排序方式，默认"points"
 * @returns Promise<RankingsApiResponse | void> 响应结果
 */
export async function getMonthlyRankings(page: number = 1, sort: string = 'points'): Promise<RankingsApiResponse | void> {
  return await getRankings({ period: 'monthly', page, sort });
}

/**
 * 按打卡数排序的排行榜
 * @param period 时间周期，默认"weekly"
 * @param page 页码，默认1
 * @returns Promise<RankingsApiResponse | void> 响应结果
 */
export async function getRankingsByCheckins(period: string = 'weekly', page: number = 1): Promise<RankingsApiResponse | void> {
  return await getRankings({ period, page, sort: 'checkins' });
}

/**
 * 按综合评分排序的排行榜
 * @param period 时间周期，默认"weekly"
 * @param page 页码，默认1
 * @returns Promise<RankingsApiResponse | void> 响应结果
 */
export async function getRankingsByPoints(period: string = 'weekly', page: number = 1): Promise<RankingsApiResponse | void> {
  return await getRankings({ period, page, sort: 'points' });
}