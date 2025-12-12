import { http } from "@kit.NetworkKit"

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
    console.log('origin response :', response);
    console.log('请求状态码:', response.responseCode);
    console.log('响应头部:', JSON.stringify(response.header));
    console.log('响应结果类型:', typeof response.result);

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