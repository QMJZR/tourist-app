import {http} from "@kit.NetworkKit"
interface ZoneItem {
  zoneId:number;
  name:string;
  description:string;
  banner:string[];
}
interface ZonesResponse {
  code:number;
  msg:string;
  data:ZoneItem[];
}

export async function getZones(): Promise<ZoneItem[] | void> {
  let request = http.createHttp();
  try {
    const response = await request.request(
      "http://10.54.35.223:8080/api/v1/zones",  // 注意：http:// 不是 https://
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      }
    );
    if (response.responseCode === 200) {
      console.log("getZones请求成功");
      console.log(String(response.result));
      // 安全地获取结果
      if (response.result) {
        const str = String(response.result);
        const responseData: ZonesResponse = JSON.parse(str);
        return responseData.data;// 返回
      } else {
        console.warn('响应结果为空');
        return ;  // 返回空JSON对象字符串
      }
    } else {
      console.log("请求失败，状态码:", response.responseCode);
      return;
    }
  } catch (error) {
    console.error('注册请求异常:', error);
    return ;
  } finally {
    // 确保销毁请求对象
    request.destroy();
  }
}

export interface SpotRequest {
  zoneId?:number;
  type?:string;
  keyword?:string;
  page?:number;
  pageSize?:number;
}

export interface SpotResponse {
  spotId:number;
  name:string;
  thumbnail:string;
  summary:string;
  zoneId:number;
  distance:number;
  total:number;
}

export async function getSpots(params:SpotRequest): Promise<SpotResponse | void> {
  let request = http.createHttp();
  try {
    let url = "http://10.54.35.223:8080/api/v1/spots";
    if (params) {
      const queryParts: string[] = [];

      if (params.zoneId !== undefined) queryParts.push(`zoneId=${params.zoneId}`);
      if (params.type) queryParts.push(`type=${encodeURIComponent(params.type)}`);
      if (params.keyword) queryParts.push(`keyword=${encodeURIComponent(params.keyword)}`);
      if (params.page !== undefined) queryParts.push(`page=${params.page}`);
      if (params.pageSize !== undefined) queryParts.push(`pageSize=${params.pageSize}`);

      if (queryParts.length > 0) {
        url += `?${queryParts.join('&')}`;
      }
    }
    const response = await request.request(
      url,  // 注意：http:// 不是 https://
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        }
      }
    );
    if (response.responseCode === 200) {
      console.log("getSpots请求成功");
      if (response.result) {
        const str = String(response.result);
        const responseData: SpotResponse = JSON.parse(str);
        return responseData;
      } else {
        console.warn('getSpots响应结果为空');
        return;
      }
    } else {
      console.log("getSpots请求失败，状态码:", response.responseCode);
      return;
    }
  } catch (error) {
    console.error('getSpots请求异常:', error);
    return;
  } finally {
    request.destroy();
  }
}

export interface SpotDetail {
  spotId:number;
  name:string;
  images:string[];
  video:string;
  description:string;
  zoneId:number;
  latitude:number; // float
  longitude:number; // float
  openTime:string;
}

export async function getSpotDetail(id:number): Promise<void> {
  let request = http.createHttp();
  try {
    const response = await request.request(
      `http://10.54.35.223:8080/api/v1/spots/${id} `,  // 注意：http:// 不是 https://
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
      }
    );
    if (response.responseCode === 200) {
      console.log("getZoneDetail请求成功");
      console.log(String(response.result));
      // 安全地获取结果
      if (response.result) {
        const str = String(response.result);
        const responseData: ZonesResponse = JSON.parse(str);
        //return responseData.data;// 返回
      } else {
        console.warn('响应结果为空');
        return ;  // 返回空JSON对象字符串
      }
    } else {
      console.log("getZoneDetail请求失败，状态码:", response.responseCode);
      return;
    }
  } catch (error) {
    console.error('getZoneDetail请求异常:', error);
    return ;
  } finally {
    // 确保销毁请求对象
    request.destroy();
  }
}

// useless
export interface SpotItem {
  spotId: number;
  name: string;
  description: string;
  images: string[]; // 景点图片
  zoneId?: number; // 所属引领区ID
  zoneName?: string; // 所属引领区名称
  latitude?: number; // 纬度
  longitude?: number; // 经度
  address?: string; // 详细地址
  openingHours?: string; // 开放时间
  ticketPrice?: number; // 门票价格
}

// 景点卡片数据接口（用于界面展示）
export interface SpotCard extends SpotItem {
  coverImage?: string; // 封面图
  distance?: number; // 距离（单位：公里）
  isRecommended?: boolean; // 是否推荐
  visitedCount?: number; // 打卡人数
  rating?: number; // 评分
}