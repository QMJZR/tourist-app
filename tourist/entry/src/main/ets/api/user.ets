import { http } from "@kit.NetworkKit"
import StorageUtil from "../utils/Storage"
export class RegisterRequest {
  username: string = '';
  password: string = '';
  email: string = '';
}

export async function register(RegisterData: RegisterRequest): Promise<string> {
  let request = http.createHttp();

  try {
    const response = await request.request(
      "http://10.54.35.223:8080/api/v1/auth/register",  // 注意：http:// 不是 https://
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(RegisterData)  // 必须序列化
      }
    );
    if (response.responseCode === 200 || response.responseCode === 201) {
      console.log("注册请求成功");

      // 安全地获取结果
      if (response.result) {
        return String(response.result);
      } else {
        console.warn('响应结果为空');
        return '{}';  // 返回空JSON对象字符串
      }
    } else {
      console.log("注册请求失败，状态码:", response.responseCode);
      // 尝试获取错误信息
      if (response.result) {
        return String(response.result);
      }
      return '';
    }
  } catch (error) {
    console.error('注册请求异常:', error);
    return '';
  } finally {
    // 确保销毁请求对象
    request.destroy();
  }
}

// 使用示例：
// const data = new RegisterRequest();
// data.username = 'test';
// data.password = '123456';
// data.email = 'test@example.com';
// const result = await register(data);
// console.log('注册结果:', result);

export class LoginRequest {
  username:string = "";
  password:string = "";
}

interface GeneratedTypeLiteralInterface_1 {
  userId: number;
  token: string;
  expiresIn?: number;
}

interface LoginApiResponse {
  code: number;
  msg: string;
  data: GeneratedTypeLiteralInterface_1;
}

export async function login(loginData: LoginRequest): Promise<string> {
  let request = http.createHttp();

  try {
    const response = await request.request(
      "http://10.54.35.223:8080/api/v1/auth/login",
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(loginData)
      }
    );

    if (response.responseCode === 200) {
      console.log("登录请求成功");

      if (response.result) {
        const result = String(response.result);
        // 通常登录成功会返回 token，你可以在这里处理

        console.log('登录响应:', result);
        const res : LoginApiResponse = JSON.parse(result);
        console.log("before save loginInfo, userId is" ,res.data.userId);
        StorageUtil.saveLoginInfo(res.data.token, res.data.userId);
        return result;
      } else {
        console.warn('响应结果为空');
        return '{}';
      }
    } else {
      console.log("登录请求失败，状态码:", response.responseCode);
      if (response.result) {
        return String(response.result);
      }
      return '';
    }
  } catch (error) {
    console.error('登录请求异常:', error);
    return '';
  } finally {
    request.destroy();
  }
}

// get profile by Id
// 先定义接口类型
interface GeneratedTypeLiteralInterface_2 {
  userId: number;
  username: string;
  nickname: string;
  avatar: string;
  points: number;
  checkinCount: number;
  isMerchant: string;
  checkinSpotIds: number[];
  email: string;
}

interface ProfileApiResponse {
  code: number;
  msg: string;
  data: GeneratedTypeLiteralInterface_2;
}

// 获取用户资料
export async function getProfile(): Promise<ProfileApiResponse | void> {
  let request = http.createHttp();

  try {
    // 需要先从存储获取token
    const token = await StorageUtil.getToken();
    if (!token) {
      console.warn('未找到token，请先登录');
      return;
    }
    const userId = await StorageUtil.getUserId();
    console.log("when getProfile, i got userId:", userId);
    const response = await request.request(
      `http://10.54.35.223:8080/api/v1/auth/profile?userId=${userId}`,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`  // 添加认证头
        }
      }
    );

    console.log('获取资料响应状态:', response.responseCode);

    if (response.responseCode === 200) {
      if (response.result) {
        const resultStr = String(response.result);
        console.log('用户资料响应:', resultStr);

        try {
          const res: ProfileApiResponse = JSON.parse(resultStr);

          // 如果获取成功，更新本地存储
          if (res.code === 200 && res.data) {
            console.log('获取用户资料成功');

            // 更新用户信息到本地存储
            //await StorageUtil.saveUserInfo(res.data);

            return res;
          } else {
            //console.log('获取用户资料失败:', res.message || res.msg);
            return res;
          }
        } catch (parseError) {
          console.error('解析用户资料响应失败:', parseError);
          // return {
          //   code: 500,
          //   //message: '响应数据格式错误'
          // };
        }
      } else {
        console.warn('响应结果为空');
        // return {
        //   code: 500,
        //   message: '服务器返回空响应'
        // };
      }
    } else {
      console.log("获取用户资料失败，状态码:", response.responseCode);

    }
  } catch (error) {
    console.error('获取用户资料异常:', error);
  } finally {
    request.destroy();
  }
}