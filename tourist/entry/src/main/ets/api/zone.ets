import {http} from "@kit.NetworkKit"
export interface ZoneItem {
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
      console.log("getZones请求失败，状态码:", response.responseCode);
      return;
    }
  } catch (error) {
    console.error('getZones请求异常:', error);
    return ;
  } finally {
    // 确保销毁请求对象
    request.destroy();
  }
}

// export interface SpotRequest {
//   zoneId?:number;
//   type?:string;
//   keyword?:string;
//   page?:number;
//   pageSize?:number;
// }
//
// export interface SpotResponse {
//   spotId:number;
//   name:string;
//   thumbnail:string;
//   summary:string;
//   zoneId:number;
//   distance:number;
//   total:number;
// }
//
// export async function getSpots(params: SpotRequest): Promise<SpotResponse | void> {
//   let request = http.createHttp();
//   try {
//     let url = "http://10.54.35.223:8080/api/v1/spots";
//     if (params) {
//       const queryParts: string[] = [];
//
//       if (params.zoneId !== undefined) queryParts.push(`zoneId=${params.zoneId}`);
//       if (params.type) queryParts.push(`type=${encodeURIComponent(params.type)}`);
//       if (params.keyword) queryParts.push(`keyword=${encodeURIComponent(params.keyword)}`);
//       if (params.page !== undefined) queryParts.push(`page=${params.page}`);
//       if (params.pageSize !== undefined) queryParts.push(`pageSize=${params.pageSize}`);
//
//       if (queryParts.length > 0) {
//         url += `?${queryParts.join('&')}`;
//       }
//     }
//
//     console.log("[DEBUG] getSpots 请求URL:", url);
//     console.log("[DEBUG] getSpots 请求参数:", params);
//
//     const response = await request.request(
//       url,
//       {
//         method: http.RequestMethod.GET,
//         header: {
//           'Content-Type': 'application/json'
//         },
//         connectTimeout: 10000, // 添加超时设置
//         readTimeout: 10000
//       }
//     );
//
//     console.log("[DEBUG] getSpots 响应状态码:", response.responseCode);
//     console.log("[DEBUG] getSpots 响应头:", response.header);
//
//     if (response.responseCode === 200) {
//       console.log("getSpots请求成功");
//       if (response.result) {
//         const str = String(response.result);
//         console.log("[DEBUG] getSpots 原始响应:", str.substring(0, 200)); // 只打印前200字符
//         const responseData: SpotResponse = JSON.parse(str);
//         return responseData;
//       } else {
//         console.warn('getSpots响应结果为空');
//         return;
//       }
//     } else {
//       console.log("getSpots请求失败，状态码:", response.responseCode);
//       // 打印错误详情
//       if (response.result) {
//         console.log("错误响应:", String(response.result));
//       }
//       return;
//     }
//   } catch (error) {
//     console.error('getSpots请求异常:', error);
//     console.error('异常详情:', error.message);
//     console.error('异常堆栈:', error.stack);
//     return;
//   } finally {
//     request.destroy();
//   }
// }


export interface SpotListItem {
  spotId: number;
  name: string;
  thumbnail: string;
  summary: string;
  zoneId: number;
  distance: number;
  // total 字段不在列表项中，是在分页数据里
}

// 分页响应接口
export interface PageResponse<T> {
  list: T[];
  page: number;
  pageSize: number;
  total: number;
}

// 景点列表响应接口
export interface SpotListResponse {
  code: number;
  message: string;
  data: PageResponse<SpotListItem>;
}

// 请求参数接口（保持不变）
export interface SpotRequest {
  zoneId?: number;
  type?: string;
  keyword?: string;
  page?: number;
  pageSize?: number;
}

// 修改 getSpots 函数
export async function getSpots(params?: SpotRequest): Promise<PageResponse<SpotListItem> | void> {
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

    console.log("[DEBUG] getSpots 请求URL:", url);
    console.log("[DEBUG] getSpots 请求参数:", params);

    const response = await request.request(
      url,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        connectTimeout: 10000,
        readTimeout: 10000
      }
    );

    console.log("[DEBUG] getSpots 响应状态码:", response.responseCode);

    if (response.responseCode === 200) {
      console.log("getSpots请求成功");
      if (response.result) {
        const str = String(response.result);
        console.log("[DEBUG] getSpots 原始响应:", str.substring(0, 300));
        const responseData: SpotListResponse = JSON.parse(str);
        return responseData.data; // 返回 data 字段，即 PageResponse<SpotListItem>
      } else {
        console.warn('getSpots响应结果为空');
        return;
      }
    } else {
      console.log("getSpots请求失败，状态码:", response.responseCode);
      if (response.result) {
        console.log("错误响应:", String(response.result));
      }
      return;
    }
  } catch (error) {
    console.error('getSpots请求异常:', error);
    console.error('异常详情:', error.message);
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

export async function getSpotDetail(id:number): Promise<SpotDetail | void> {
  let request = http.createHttp();
  try {
    const response = await request.request(
      `http://10.54.35.223:8080/api/v1/spots/${id}`,  // 注意：http:// 不是 https://
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
      }
    );
    if (response.responseCode === 200) {
      console.log("getSpotDetail请求成功");
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
      console.log("getSpotDetail请求失败，状态码:", response.responseCode);
      return;
    }
  } catch (error) {
    console.error('getSpotDetail请求异常:', error);
    return ;
  } finally {
    // 确保销毁请求对象
    request.destroy();
  }
}