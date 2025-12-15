import {http} from "@kit.NetworkKit"
import StorageUtil from '../utils/Storage'

export interface GetReq {
  lat:number;
  lng:number;
  sort:string;
}

export interface GetCheckInData {
  spotId:number;
  name:string;
  lat:number;
  lng:number;
  radius:number;
  thumbnail:string;
  distance:number;
}

interface GetRes {
  code:number;
  msg:string;
  data:GetCheckInData[];
}

export async function getCheckInSpots(data:GetReq): Promise<GetCheckInData[] | void> {
  let request = http.createHttp();
  try {
    const response = await request.request(
      "http://10.54.35.223:8080/checkin/spots",  // 注意：http:// 不是 https://
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        extraData:data
      }
    );
    if (response.responseCode === 200) {
      console.log("getCheckInSpots请求成功");
      console.log(String(response.result));
      // 安全地获取结果
      if (response.result) {
        const str = String(response.result);
        const responseData: GetRes = JSON.parse(str);
        return responseData.data;// 返回
      } else {
        console.warn('响应结果为空');
        return ;  // 返回空JSON对象字符串
      }
    } else {
      console.log("getCheckInSpots请求失败，状态码:", response.responseCode);
      return;
    }
  } catch (error) {
    console.error('getCheckInSpots请求异常:', error);
    return ;
  } finally {
    // 确保销毁请求对象
    request.destroy();
  }
}

export interface SubmitReq {
  spotId:number;
  latitude:number;
  longitude:number;
  image:string;
}

export interface SubmitResData {
  checkInId:number;
  points:number;
  spotId:number;
  checkInTime:string;
  msg:string;
}
export interface SubmitRes{
  code:number;
  msg:string;
  data:SubmitResData;
}

// export async function Submit(data:SubmitReq): Promise<void> {
//   let request = http.createHttp();
//   try {
//     const token = await StorageUtil.getToken();
//     if (!token) {
//       console.warn('未找到token，请先登录');
//       return;
//     }
//     const response = await request.request(
//       "http://10.54.35.223:8080/checkin/submit",  // 注意：http:// 不是 https://
//       {
//         method: http.RequestMethod.GET,
//         header: {
//           'Content-Type': 'application/json',
//           'Authorization': `Bearer ${token}`
//         },
//         extraData:data
//       }
//     );
//     if (response.responseCode === 200) {
//       console.log("Submit请求成功");
//       console.log(String(response.result));
//       // 安全地获取结果
//       if (response.result) {
//         const str = String(response.result);
//         const responseData: SubmitRes = JSON.parse(str);
//         //return responseData.data;// 返回
//       } else {
//         console.warn('响应结果为空');
//         return ;  // 返回空JSON对象字符串
//       }
//     } else {
//       console.log("submit请求失败，状态码:", response.responseCode);
//       return;
//     }
//   } catch (error) {
//     console.error('submit请求异常:', error);
//     return ;
//   } finally {
//     // 确保销毁请求对象
//     request.destroy();
//   }
// }

export async function Submit(data:SubmitReq): Promise<SubmitResData | void> {
  let request = http.createHttp();
  try {
    const token = await StorageUtil.getToken();
    if (!token) {
      console.warn('未找到token，请先登录');
      return;
    }
    console.log("[DEBUG] 获取到的Token:", token);

    console.log("[DEBUG] Submit 请求数据:", data);
    console.log("[DEBUG] Submit 请求URL:", "http://10.54.35.223:8080/checkin/submit");

    const response = await request.request(
      "http://10.54.35.223:8080/checkin/submit",
      {
        method: http.RequestMethod.POST,  // 关键修改
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'token': token  // 同时发送 token 头
        },
        extraData: JSON.stringify(data)  // POST 请求体数据
      }
    );

    console.log("[DEBUG] Submit 响应状态码:", response.responseCode);
    console.log("[DEBUG] Submit 响应头:", response.header);

    if (response.responseCode === 200) {
      console.log("Submit请求成功");
      if (response.result) {
        const str = String(response.result);
        console.log("[DEBUG] Submit 原始响应:", str.substring(0, 300));
        const responseData: SubmitRes = JSON.parse(str);
        return responseData.data;  // 返回数据
      } else {
        console.warn('响应结果为空');
        return;
      }
    } else {
      console.log("submit请求失败，状态码:", response.responseCode);
      if (response.result) {
        console.log("错误响应:", String(response.result));
      }
      return;
    }
  } catch (error) {
    console.error('submit请求异常:', error);
    console.error('异常详情:', error.message);
    return;
  } finally {
    request.destroy();
  }
}


