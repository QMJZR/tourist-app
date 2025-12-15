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

// 动态项接口
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

// 动态列表响应接口
interface FeedsResponseData {
  list: FeedItem[];
  page: number;
  pageSize: number;
  total: number;
}

interface FeedsResponse {
  code: number;
  message: string;
  data: FeedsResponseData;
}

export async function getFeeds(params?: FeedsParams): Promise<FeedItem[] | void> {
  let request = http.createHttp();
  try {
    // 构建查询参数
    const token = await StorageUtil.getToken();
    if(!token) {
      console.log("无token")
      return;
    }
    let url = "http://10.54.35.223:8080/api/v1/feeds";
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

    const response = await request.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        }
      }
    );

    if (response.responseCode === 200) {
      console.log("getFeeds请求成功");
      if (response.result) {
        const str = String(response.result);
        const responseData: FeedsResponse = JSON.parse(str);
        return responseData.data.list;
      } else {
        console.warn('getFeeds响应结果为空');
        return;
      }
    } else {
      console.log("getFeeds请求失败，状态码:", response.responseCode);
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
interface LikeResponseData {
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
    const url = `http://10.54.35.223:8080/api/v1/feeds/${feedId}/like`;

    const response = await request.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        }
      }
    );

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
    const url = `http://10.54.35.223:8080/api/v1/feeds/${feedId}/like`;

    const response = await request.request(
      url,
      {
        method: http.RequestMethod.DELETE,
        header: {
          'Content-Type': 'application/json'
        }
      }
    );

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
      return;
    }
  } catch (error) {
    console.error('unlikeFeed请求异常:', error);
    return;
  } finally {
    request.destroy();
  }
}