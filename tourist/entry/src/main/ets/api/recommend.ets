// entry/src/main/ets/api/recommend.ets

import { http } from "@kit.NetworkKit";
import StorageUtil from "../utils/Storage";

// ==================== 附近推荐相关接口定义 ====================

/**
 * 附近推荐项接口
 */
export interface NearbyItem {
  id: number;                // 资源ID
  type: string;             // 资源类型："spot" | "merchant"
  name: string;             // 名称
  latitude: number;         // 纬度
  longitude: number;        // 经度
  distance: number;         // 与用户当前位置距离（米）
  thumbnail: string;        // 缩略图
  popularity: number;       // 热度评分
}

/**
 * 附近推荐列表响应数据接口
 */
export interface NearbyData {
  list: NearbyItem[];
  page: number;
  pageSize: number;
  total: number;
}

/**
 * 附近推荐API响应接口
 */
export interface NearbyApiResponse {
  code: number;
  message: string;
  data: NearbyData | null;
}

/**
 * 获取附近推荐的请求参数
 */
export interface GetNearbyParams {
  latitude: number;         // 用户当前纬度（必需）
  longitude: number;        // 用户当前经度（必需）
  sort?: string;           // 排序方式："distance" | "popularity"，默认"popularity"
  type?: string;           // 推荐类型："spot" | "merchant" | "all"，默认"all"
  page?: number;           // 页码，默认1
}

// ==================== API函数 ====================

/**
 * 获取附近推荐数据
 * @param params 请求参数，包含经纬度、排序、类型、页码
 * @returns Promise<NearbyApiResponse | void> 响应结果
 */
export async function getNearbyRecommendations(params: GetNearbyParams): Promise<NearbyApiResponse | void> {
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
    const latitude = params.latitude;
    const longitude = params.longitude;
    const sort = params.sort || 'popularity';
    const type = params.type || 'all';
    const page = params.page || 1;

    const url = `http://10.54.37.27:8080/recommend/nearby?latitude=${latitude}&longitude=${longitude}&sort=${sort}&type=${type}&page=${page}`;
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

    console.log('🔍 DEBUG: 附近推荐响应状态 =', response.responseCode);

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
        console.log('附近推荐响应:', resultStr);

        try {
          const res: NearbyApiResponse = JSON.parse(resultStr);

          if (res.code === 200 && res.data) {
            console.log('获取附近推荐成功');
            return res;
          } else {
            console.log('获取附近推荐失败:', res.message);
            return res;
          }
        } catch (parseError) {
          console.error('解析附近推荐响应失败:', parseError);
        }
      } else {
        console.warn('响应结果为空');
      }
    } else {
      console.log("获取附近推荐失败，状态码:", response.responseCode);

      // 添加详细错误信息
      if (response.result) {
        const errorResult = String(response.result);
        console.log("错误响应内容:", errorResult);
        try {
          const errorJson: NearbyApiResponse = JSON.parse(errorResult);
          console.log("错误JSON:", errorJson);
        } catch (e) {
          console.log("错误内容不是JSON格式");
        }
      }
    }
  } catch (error) {
    console.error('获取附近推荐异常:', error);
  } finally {
    request.destroy();
  }
}

/**
 * 获取距离最近的附近推荐
 * @param latitude 纬度
 * @param longitude 经度
 * @param type 推荐类型，默认"all"
 * @param page 页码，默认1
 * @returns Promise<NearbyApiResponse | void> 响应结果
 */
export async function getNearbyByDistance(latitude: number, longitude: number, type: string = 'all', page: number = 1): Promise<NearbyApiResponse | void> {
  return await getNearbyRecommendations({
    latitude,
    longitude,
    sort: 'distance',
    type,
    page
  });
}

/**
 * 获取热度最高的附近推荐
 * @param latitude 纬度
 * @param longitude 经度
 * @param type 推荐类型，默认"all"
 * @param page 页码，默认1
 * @returns Promise<NearbyApiResponse | void> 响应结果
 */
export async function getNearbyByPopularity(latitude: number, longitude: number, type: string = 'all', page: number = 1): Promise<NearbyApiResponse | void> {
  return await getNearbyRecommendations({
    latitude,
    longitude,
    sort: 'popularity',
    type,
    page
  });
}

/**
 * 获取附近景点推荐
 * @param latitude 纬度
 * @param longitude 经度
 * @param sort 排序方式，默认"popularity"
 * @param page 页码，默认1
 * @returns Promise<NearbyApiResponse | void> 响应结果
 */
export async function getNearbySpots(latitude: number, longitude: number, sort: string = 'popularity', page: number = 1): Promise<NearbyApiResponse | void> {
  return await getNearbyRecommendations({
    latitude,
    longitude,
    sort,
    type: 'spot',
    page
  });
}

/**
 * 获取附近商家推荐
 * @param latitude 纬度
 * @param longitude 经度
 * @param sort 排序方式，默认"popularity"
 * @param page 页码，默认1
 * @returns Promise<NearbyApiResponse | void> 响应结果
 */
export async function getNearbyMerchants(latitude: number, longitude: number, sort: string = 'popularity', page: number = 1): Promise<NearbyApiResponse | void> {
  return await getNearbyRecommendations({
    latitude,
    longitude,
    sort,
    type: 'merchant',
    page
  });
}

/**
 * 获取当前位置附近的推荐（简化版，使用默认位置）
 * @param page 页码，默认1
 * @param sort 排序方式，默认"popularity"
 * @param type 推荐类型，默认"all"
 * @returns Promise<NearbyApiResponse | void> 响应结果
 */
export async function getNearbyRecommendationsSimple(page: number = 1, sort: string = 'popularity', type: string = 'all'): Promise<NearbyApiResponse | void> {
  // 这里可以使用默认位置或从设备获取位置
  // 实际应用中应该从设备GPS获取
  const defaultLatitude = 23.112233;  // 默认纬度
  const defaultLongitude = 113.332211; // 默认经度

  return await getNearbyRecommendations({
    latitude: defaultLatitude,
    longitude: defaultLongitude,
    sort,
    type,
    page
  });
}