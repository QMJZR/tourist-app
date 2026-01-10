// entry/src/main/ets/api/profile.ets

import { http } from "@kit.NetworkKit"
import StorageUtil from "../utils/Storage"
import { BASE_URL } from '../api/baseurl';
// ==================== 打卡记录接口定义 ====================

/**
 * 打卡记录项接口
 */
interface CheckinItem {
  checkinId: number;
  spotId: number;
  spotName: string;
  images: string[];
  pointsEarned: number;
  createdAt: string;
}

/**
 * 打卡记录响应数据接口
 */
interface CheckinsData {
  list: CheckinItem[];
  page: number;
  total: number;
}

/**
 * 打卡记录API响应接口
 */
export interface CheckinsApiResponse {
  code: number;
  msg: string;
  data: CheckinsData | null;
}

// ==================== 积分记录接口定义 ====================

/**
 * 积分记录项接口
 */
interface PointsRecord {
  recordId: number;
  type: string;  // "earn" | "spend"
  source: string;
  points: number;
  createdAt: string;
}

/**
 * 积分记录响应数据接口
 */
interface PointsData {
  list: PointsRecord[];
  totalPoints: number;
  page: number;
  pageSize: number;
  total: number;
}

/**
 * 积分记录API响应接口
 */
export interface PointsApiResponse {
  code: number;
  msg: string;
  data: PointsData | null;
}

// ==================== 礼品列表接口定义 ====================

/**
 * 礼品项接口
 */
interface GiftItem {
  giftId: number;
  name: string;
  pointsRequired: number;
  status: string;  // "available" | "redeemed" | "expired"
  redeemedAt: string | null;
}

/**
 * 礼品列表响应数据接口
 */
interface GiftsData {
  list: GiftItem[];
  page: number;
  total: number;
}

/**
 * 礼品列表API响应接口
 */
export interface GiftsApiResponse {
  code: number;
  msg: string;
  data: GiftsData | null;
}

// ==================== API函数 ====================

/**
 * 获取用户打卡记录
 * @param page 页码，默认1
 * @returns Promise<CheckinsApiResponse> 响应结果
 */
export async function getCheckins(page: number = 1): Promise<CheckinsApiResponse | void> {
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

    const url = `${BASE_URL}/api/user/checkins?page=${page}`;
    console.log('🔍 DEBUG: 请求URL =', url);

    const response = await request.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,  // 添加 Authorization 头
          'token': token  // 保留原有的 token 头
        }
      }
    );

    console.log('🔍 DEBUG: 打卡记录响应状态 =', response.responseCode);

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
        console.log('打卡记录响应:', resultStr);

        try {
          const res: CheckinsApiResponse = JSON.parse(resultStr);

          if (res.code === 200 && res.data) {
            console.log('获取打卡记录成功');
            return res;
          } else {
            console.log('获取打卡记录失败:', res.msg);
            return res;
          }
        } catch (parseError) {
          console.error('解析打卡记录响应失败:', parseError);
        }
      } else {
        console.warn('响应结果为空');
      }
    } else if (response.responseCode === 401 || response.responseCode === 403) {
      // 处理认证失败的情况
      console.log("Token验证失败或用户不存在");

      return {
        code: response.responseCode,
        msg: "登录已过期，请重新登录",
        data: null
      } as CheckinsApiResponse;
    } else if (response.responseCode === 500) {
      // 处理服务器内部错误
      console.log("服务器内部错误（500）");

      if (response.result) {
        const errorResult = String(response.result);
        console.log("错误响应内容:", errorResult);
      }

      return {
        code: 500,
        msg: "服务器内部错误，请稍后重试",
        data: null
      } as CheckinsApiResponse;
    } else {
      console.log("获取打卡记录失败，状态码:", response.responseCode);

      // 添加详细错误信息
      if (response.result) {
        const errorResult = String(response.result);
        console.log("错误响应内容:", errorResult);
        try {
          const errorJson: CheckinsApiResponse = JSON.parse(errorResult);
          console.log("错误JSON:", errorJson);
          return errorJson;
        } catch (e) {
          console.log("错误内容不是JSON格式");
        }
      }

      // 返回通用的错误响应
      return {
        code: response.responseCode,
        msg: `请求失败，状态码: ${response.responseCode}`,
        data: null
      } as CheckinsApiResponse;
    }
  } catch (error) {
    console.error('获取打卡记录异常:', error);
    // 返回网络异常的错误响应
    return {
      code: -1,
      msg: '网络请求异常',
      data: null
    } as CheckinsApiResponse;
  } finally {
    request.destroy();
  }
}

/**
 * 获取用户积分记录
 * @param page 页码，默认1
 * @returns Promise<PointsApiResponse> 响应结果
 */
export async function getPoints(page: number = 1): Promise<PointsApiResponse | void> {
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

    const url = `${BASE_URL}/api/user/points?page=${page}`;
    console.log('🔍 DEBUG: 请求URL =', url);

    const response = await request.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'token': token  // 双token头
        }
      }
    );

    console.log('🔍 DEBUG: 积分记录响应状态 =', response.responseCode);

    if (response.result) {
      const resultStr = String(response.result);
      console.log('🔍 DEBUG: 响应Body =', resultStr);
    }

    if (response.responseCode === 200) {
      if (response.result) {
        const resultStr = String(response.result);
        console.log('积分记录响应:', resultStr);

        try {
          const res: PointsApiResponse = JSON.parse(resultStr);

          if (res.code === 200 && res.data) {
            console.log('获取积分记录成功');
            return res;
          } else {
            console.log('获取积分记录失败:', res.msg);
            return res;
          }
        } catch (parseError) {
          console.error('解析积分记录响应失败:', parseError);
        }
      } else {
        console.warn('响应结果为空');
      }
    } else {
      console.log("获取积分记录失败，状态码:", response.responseCode);

      if (response.result) {
        const errorResult = String(response.result);
        console.log("错误响应内容:", errorResult);
        try {
          const errorJson: PointsApiResponse = JSON.parse(errorResult);
          console.log("错误JSON:", errorJson);
        } catch (e) {
          console.log("错误内容不是JSON格式");
        }
      }
    }
  } catch (error) {
    console.error('获取积分记录异常:', error);
  } finally {
    request.destroy();
  }
}

/**
 * 获取用户礼品列表
 * @param page 页码，默认1
 * @param status 礼品状态："available" | "redeemed" | "expired" | "all"，默认"all"
 * @returns Promise<GiftsApiResponse> 响应结果
 */
export async function getGifts(page: number = 1, status: string = "all"): Promise<GiftsApiResponse | void> {
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

    const url = `${BASE_URL}/api/user/gifts?page=${page}&status=${status}`;
    console.log('🔍 DEBUG: 请求URL =', url);

    const response = await request.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'token': token  // 双token头
        }
      }
    );

    console.log('🔍 DEBUG: 礼品列表响应状态 =', response.responseCode);

    if (response.result) {
      const resultStr = String(response.result);
      console.log('🔍 DEBUG: 响应Body =', resultStr);
    }

    if (response.responseCode === 200) {
      if (response.result) {
        const resultStr = String(response.result);
        console.log('礼品列表响应:', resultStr);

        try {
          const res: GiftsApiResponse = JSON.parse(resultStr);

          if (res.code === 200 && res.data) {
            console.log('获取礼品列表成功');
            return res;
          } else {
            console.log('获取礼品列表失败:', res.msg);
            return res;
          }
        } catch (parseError) {
          console.error('解析礼品列表响应失败:', parseError);
        }
      } else {
        console.warn('响应结果为空');
      }
    } else {
      console.log("获取礼品列表失败，状态码:", response.responseCode);

      if (response.result) {
        const errorResult = String(response.result);
        console.log("错误响应内容:", errorResult);
        try {
          const errorJson: GiftsApiResponse = JSON.parse(errorResult);
          console.log("错误JSON:", errorJson);
        } catch (e) {
          console.log("错误内容不是JSON格式");
        }
      }
    }
  } catch (error) {
    console.error('获取礼品列表异常:', error);
  } finally {
    request.destroy();
  }
}

/**
 * 获取可兑换礼品（状态为available）
 * @param page 页码，默认1
 * @returns Promise<GiftsApiResponse> 响应结果
 */
export async function getAvailableGifts(page: number = 1): Promise<GiftsApiResponse | void> {
  return await getGifts(page, "available");
}

/**
 * 获取已兑换礼品（状态为redeemed）
 * @param page 页码，默认1
 * @returns Promise<GiftsApiResponse> 响应结果
 */
export async function getRedeemedGifts(page: number = 1): Promise<GiftsApiResponse | void> {
  return await getGifts(page, "redeemed");
}