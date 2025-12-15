import { http } from "@kit.NetworkKit"
import StorageUtil from "../utils/Storage"

// ==================== 获取动态列表 ====================

// 请求参数接口
export interface FeedsParams {
  page?: number;
  pageSize?: number;
  sort?: string;
  userId?: number;
  keyword?: string;
}

// 动态项接口 - 根据后端 FeedResponseDTO
export interface FeedItem {
  feedId: number;
  userId: number;
  username: string;
  avatar: string;
  spotId: number;
  spotName: string;
  content: string;
  likes: number;
  liked: boolean;
  createdAt: string;
}

// 分页响应接口
export interface PageResponse<T> {
  list: T[];
  page: number;
  pageSize: number;
  total: number;
}

// 动态列表响应接口
interface FeedsResponse {
  code: number;
  message: string;
  data: PageResponse<FeedItem>;
}

// 获取动态列表
export async function getFeeds(params?: FeedsParams): Promise<PageResponse<FeedItem> | void> {
  let request = http.createHttp();
  try {
    const token = await StorageUtil.getToken();
    if(!token) {
      console.log("无token，动态列表需要登录");
      return;
    }
    console.log('[DEBUG] Token:', token); // 查看token是否正常

    // 修正路径：根据后端是 /feeds
    let url = "http://10.54.35.223:8080/api/V1/feeds";

    if (params) {
      const queryParts: string[] = [];

      if (params.page !== undefined) queryParts.push(`page=${params.page}`);
      if (params.pageSize !== undefined) queryParts.push(`pageSize=${params.pageSize}`);
      if (params.sort) queryParts.push(`sort=${encodeURIComponent(params.sort)}`);
      if (params.userId !== undefined) queryParts.push(`userId=${params.userId}`);
      if (params.keyword) queryParts.push(`keyword=${encodeURIComponent(params.keyword)}`);

      if (queryParts.length > 0) {
        url += `?${queryParts.join('&')}`;
      }
    }

    console.log("[DEBUG] getFeeds 请求URL:", url);

    const response = await request.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`, // 只需要 Authorization
          'token':token
        }
      }
    );

    console.log("[DEBUG] getFeeds 响应状态码:", response.responseCode);

    if (response.responseCode === 200) {
      console.log("getFeeds请求成功");
      if (response.result) {
        const str = String(response.result);
        console.log("[DEBUG] getFeeds 原始响应:", str.substring(0, 300));
        const responseData: FeedsResponse = JSON.parse(str);
        return responseData.data;
      } else {
        console.warn('getFeeds响应结果为空');
        return;
      }
    } else {
      console.log("getFeeds请求失败，状态码:", response.responseCode);
      if (response.result) {
        console.log("错误响应:", String(response.result));
      }
      return;
    }
  } catch (error) {
    console.error('getFeeds请求异常:', error);
    return;
  } finally {
    request.destroy();
  }
}

// ==================== 点赞动态 ====================

// 点赞响应接口
export interface LikeResponseData {
  feedId: number;
  likes: number;
  liked: boolean;
}

interface LikeResponse {
  code: number;
  message: string;
  data: LikeResponseData;
}

export async function likeFeed(feedId: number): Promise<LikeResponseData | void> {
  let request = http.createHttp();
  try {
    const token = await StorageUtil.getToken();
    if(!token) {
      console.warn('点赞需要登录，未找到token');
      return;
    }

    // 修正路径：根据后端是 /feeds/{id}/like
    const url = `http://10.54.35.223:8080/api/V1/feeds/${feedId}/like`;

    console.log("[DEBUG] likeFeed 请求URL:", url);

    const response = await request.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'token':token
        }
      }
    );

    console.log("[DEBUG] likeFeed 响应状态码:", response.responseCode);

    if (response.responseCode === 200) {
      console.log("likeFeed请求成功");
      if (response.result) {
        const str = String(response.result);
        const responseData: LikeResponse = JSON.parse(str);
        return responseData.data;
      } else {
        console.warn('likeFeed响应结果为空');
        return;
      }
    } else {
      console.log("likeFeed请求失败，状态码:", response.responseCode);
      if (response.result) {
        console.log("错误响应:", String(response.result));
      }
      return;
    }
  } catch (error) {
    console.error('likeFeed请求异常:', error);
    return;
  } finally {
    request.destroy();
  }
}

// ==================== 取消点赞 ====================

export async function unlikeFeed(feedId: number): Promise<LikeResponseData | void> {
  let request = http.createHttp();
  try {
    const token = await StorageUtil.getToken();
    if(!token) {
      console.warn('取消点赞需要登录，未找到token');
      return;
    }

    // 修正路径：根据后端是 /feeds/{id}/like
    const url = `http://10.54.35.223:8080/api/V1/feeds/${feedId}/like`;

    console.log("[DEBUG] unlikeFeed 请求URL:", url);

    const response = await request.request(
      url,
      {
        method: http.RequestMethod.DELETE,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'token':token
        }
      }
    );

    console.log("[DEBUG] unlikeFeed 响应状态码:", response.responseCode);

    if (response.responseCode === 200) {
      console.log("unlikeFeed请求成功");
      if (response.result) {
        const str = String(response.result);
        const responseData: LikeResponse = JSON.parse(str);
        return responseData.data;
      } else {
        console.warn('unlikeFeed响应结果为空');
        return;
      }
    } else {
      console.log("unlikeFeed请求失败，状态码:", response.responseCode);
      if (response.result) {
        console.log("错误响应:", String(response.result));
      }
      return;
    }
  } catch (error) {
    console.error('unlikeFeed请求异常:', error);
    return;
  } finally {
    request.destroy();
  }
}