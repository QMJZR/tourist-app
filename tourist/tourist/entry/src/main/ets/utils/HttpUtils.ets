import { Constants } from './Constants';
import { BaseResponse } from '../models/Common';
import http from '@ohos.net.http';

export class HttpUtils {
  static async request<T>(
    url: string,
    method: number = http.RequestMethod.GET,
    data?: object
  ): Promise<BaseResponse<T>> {
    let httpRequest: http.HttpRequest | null = null;

    try {
      const token = AppStorage.get<string>(Constants.TOKEN_KEY);

      // 创建 HTTP 请求
      httpRequest = http.createHttp();

      // 创建请求头 - 单独定义确保不为 undefined
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };

      // 添加认证头
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }

      // 创建请求选项
      const requestOptions: http.HttpRequestOptions = {
        method: method,
        header: headers,  // 使用已定义的 headers
        readTimeout: 30000,
        connectTimeout: 30000
      };

      // 设置请求体
      if (data && (method === http.RequestMethod.POST || method === http.RequestMethod.PUT)) {
        requestOptions.extraData = JSON.stringify(data);
      }

      console.log(`HTTP Request: ${HttpUtils.getMethodName(method)} ${Constants.BASE_URL}${url}`);

      // 发送请求
      const response = await httpRequest.request(
        `${Constants.BASE_URL}${url}`,
        requestOptions
      );

      console.log(`HTTP Response: ${response.responseCode}`);

      if (response.responseCode === 200) {
        // 解析响应数据
        let result: BaseResponse<T>;

        if (typeof response.result === 'string') {
          result = JSON.parse(response.result);
        } else {
          result = response.result as BaseResponse<T>;
        }

        return result;
      } else {
        // HTTP 状态码错误
        const errorResponse: BaseResponse<T> = new BaseResponse<T>();
        errorResponse.code = response.responseCode;
        errorResponse.message = `HTTP Error: ${response.responseCode}`;
        errorResponse.data = undefined;
        return errorResponse;
      }
    } catch (error) {
      console.error('HTTP request failed:', error);

      const errorResponse: BaseResponse<T> = new BaseResponse<T>();
      errorResponse.code = 9999;
      errorResponse.message = '网络请求失败，请检查网络连接';
      errorResponse.data = undefined;
      return errorResponse;
    } finally {
      // 释放资源
      if (httpRequest) {
        httpRequest.destroy();
      }
    }
  }

  // 获取方法名称
  private static getMethodName(method: number): string {
    switch (method) {
      case http.RequestMethod.GET: return 'GET';
      case http.RequestMethod.POST: return 'POST';
      case http.RequestMethod.PUT: return 'PUT';
      case http.RequestMethod.DELETE: return 'DELETE';
      default: return 'UNKNOWN';
    }
  }

  static async get<T>(url: string): Promise<BaseResponse<T>> {
    return HttpUtils.request<T>(url, http.RequestMethod.GET);
  }

  static async post<T>(url: string, data: object): Promise<BaseResponse<T>> {
    return HttpUtils.request<T>(url, http.RequestMethod.POST, data);
  }

  static async put<T>(url: string, data: object): Promise<BaseResponse<T>> {
    return HttpUtils.request<T>(url, http.RequestMethod.PUT, data);
  }

  static async delete<T>(url: string): Promise<BaseResponse<T>> {
    return HttpUtils.request<T>(url, http.RequestMethod.DELETE);
  }
}