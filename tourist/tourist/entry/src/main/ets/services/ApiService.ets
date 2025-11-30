import { HttpUtils } from '../utils/HttpUtils';
import { Zone, ZoneListResponse } from '../models/Zone';
import { Spot, SpotDetail, SpotListResponse, SpotDetailResponse, SpotListData } from '../models/Spot';
import { BaseResponse, ListResponse, EmptyData } from '../models/Common';

// 定义其他数据模型
export class CheckInSpot {
  spotId: number = 0;
  name: string = '';
  latitude: number = 0;
  longitude: number = 0;
  radius: number = 0;
  thumbnail: string = '';
  distance: number = 0;
}

export class Feed {
  feedId: number = 0;
  userId: number = 0;
  username: string = '';
  avatar: string = '';
  spotId: number = 0;
  spotName: string = '';
  content: string = '';
  likes: number = 0;
  liked: boolean = false;
  createdAt: string = '';
}

export class CheckInResponse {
  checkinId: number = 0;
  points: number = 0;
  spotId: number = 0;
  checkinTime: string = '';
  message: string = '';
}

export class AssistantResponse {
  answer: string = '';
  recommendations: Recommendation[] = [];
}

export class Recommendation {
  type: string = '';
  id: number = 0;
  name: string = '';
  latitude: number = 0;
  longitude: number = 0;
  distance: number = 0;
}

export class RankingItem {
  rank: number = 0;
  userId: number = 0;
  username: string = '';
  avatar: string = '';
  totalCheckins: number = 0;
  totalLikes: number = 0;
  score: number = 0;
}

export class NearbyItem {
  id: number = 0;
  type: string = '';
  name: string = '';
  latitude: number = 0;
  longitude: number = 0;
  distance: number = 0;
  thumbnail: string = '';
  popularity: number = 0;
}

export class CheckInRecord {
  checkinId: number = 0;
  spotId: number = 0;
  spotName: string = '';
  images: string[] = [];
  pointsEarned: number = 0;
  createdAt: string = '';
}

export class PointsRecord {
  recordId: number = 0;
  type: string = '';
  source: string = '';
  points: number = 0;
  createdAt: string = '';
}

export class PointsSummary {
  list: PointsRecord[] = [];
  totalPoints: number = 0;
  total: number = 0;
}

export class GiftItem {
  giftId: number = 0;
  name: string = '';
  pointsRequired: number = 0;
  status: string = '';
  redeemedAt: string | null = null;
}

export class LikeResponse {
  feedId: number = 0;
  likes: number = 0;
  liked: boolean = false;
}

// 添加空请求体类
export class EmptyRequest {}

export class ApiService {
  // 景区相关
  static async getZones(): Promise<ZoneListResponse> {
    const response = await HttpUtils.get<Zone[]>('/zones');
    return {
      code: response.code,
      message: response.message,
      data: response.data || []
    } as ZoneListResponse;
  }

  static async getSpots(zoneId?: number, type?: string, keyword?: string, page?: number): Promise<SpotListResponse> {
    let url = '/spots?';
    const params: string[] = [];

    if (zoneId) params.push(`zoneId=${zoneId}`);
    if (type) params.push(`type=${type}`);
    if (keyword) params.push(`keyword=${encodeURIComponent(keyword)}`);
    if (page) params.push(`page=${page}`);

    url += params.join('&');
    const response = await HttpUtils.get<SpotListData>(url);
    return {
      code: response.code,
      message: response.message,
      data: response.data
    } as SpotListResponse;
  }

  static async getSpotDetail(spotId: number): Promise<SpotDetailResponse> {
    const response = await HttpUtils.get<SpotDetail>(`/spots/${spotId}`);
    return {
      code: response.code,
      message: response.message,
      data: response.data
    } as SpotDetailResponse;
  }

  // 打卡相关
  static async getCheckinSpots(lat?: number, lng?: number, sort?: string): Promise<BaseResponse<CheckInSpot[]>> {
    let url = '/checkin/spots?';
    const params: string[] = [];

    if (lat) params.push(`lat=${lat}`);
    if (lng) params.push(`lng=${lng}`);
    if (sort) params.push(`sort=${sort}`);

    url += params.join('&');
    return await HttpUtils.get<CheckInSpot[]>(url);
  }

  static async submitCheckin(checkinData: object): Promise<BaseResponse<CheckInResponse>> {
    return await HttpUtils.post<CheckInResponse>('/checkin/submit', checkinData);
  }

  // 动态相关
  static async getFeeds(page?: number, pageSize?: number, sort?: string, userId?: number, keyword?: string): Promise<BaseResponse<ListResponse<Feed>>> {
    let url = '/feeds?';
    const params: string[] = [];

    if (page) params.push(`page=${page}`);
    if (pageSize) params.push(`pageSize=${pageSize}`);
    if (sort) params.push(`sort=${sort}`);
    if (userId) params.push(`userId=${userId}`);
    if (keyword) params.push(`keyword=${encodeURIComponent(keyword)}`);

    url += params.join('&');
    return await HttpUtils.get<ListResponse<Feed>>(url);
  }

  static async likeFeed(feedId: number): Promise<BaseResponse<LikeResponse>> {
    const emptyRequest: EmptyRequest = new EmptyRequest();
    return await HttpUtils.post<LikeResponse>(`/feeds/${feedId}/like`, emptyRequest);
  }

  static async unlikeFeed(feedId: number): Promise<BaseResponse<LikeResponse>> {
    const emptyRequest: EmptyRequest = new EmptyRequest();
    return await HttpUtils.delete<LikeResponse>(`/feeds/${feedId}/like`);
  }

  // 智能问答
  static async askAssistant(questionData: object): Promise<BaseResponse<AssistantResponse>> {
    return await HttpUtils.post<AssistantResponse>('/assistant/ask', questionData);
  }

  // 排行榜
  static async getRankings(period?: string, page?: number, sort?: string): Promise<BaseResponse<ListResponse<RankingItem>>> {
    let url = '/rankings?';
    const params: string[] = [];

    if (period) params.push(`period=${period}`);
    if (page) params.push(`page=${page}`);
    if (sort) params.push(`sort=${sort}`);

    url += params.join('&');
    return await HttpUtils.get<ListResponse<RankingItem>>(url);
  }

  // 附近推荐
  static async getNearbyRecommendations(latitude: number, longitude: number, sort?: string, type?: string, page?: number): Promise<BaseResponse<ListResponse<NearbyItem>>> {
    let url = `/recommend/nearby?latitude=${latitude}&longitude=${longitude}`;

    if (sort) url += `&sort=${sort}`;
    if (type) url += `&type=${type}`;
    if (page) url += `&page=${page}`;

    return await HttpUtils.get<ListResponse<NearbyItem>>(url);
  }

  // 个人中心
  static async getUserCheckins(page?: number): Promise<BaseResponse<ListResponse<CheckInRecord>>> {
    const url = page ? `/user/checkins?page=${page}` : '/user/checkins';
    return await HttpUtils.get<ListResponse<CheckInRecord>>(url);
  }

  static async getUserPoints(): Promise<BaseResponse<PointsSummary>> {
    return await HttpUtils.get<PointsSummary>('/user/points');
  }

  static async getUserGifts(status?: string): Promise<BaseResponse<ListResponse<GiftItem>>> {
    const url = status ? `/user/gifts?status=${status}` : '/user/gifts';
    return await HttpUtils.get<ListResponse<GiftItem>>(url);
  }
}