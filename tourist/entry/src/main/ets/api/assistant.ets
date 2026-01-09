// entry/src/main/ets/api/assistant.ets

import { http } from "@kit.NetworkKit"
import StorageUtil from "../utils/Storage"
import { BASE_URL } from '../api/baseurl';
// ==================== 请求接口定义 ====================

/**
 * 提问智能助手请求接口
 */
interface GeneratedTypeLiteralInterface_1 {
  latitude?: number;
  longitude?: number;
  history?: string[];
}

export class AskAssistantRequest {
  question: string = '';
  context?: GeneratedTypeLiteralInterface_1;
}

// ==================== 响应接口定义 ====================

/**
 * 推荐资源接口
 */
interface GeneratedTypeLiteralInterface_2 {
  type: string;
  id: number;
  name: string;
  latitude: number;
  longitude: number;
  distance: number;
}

/**
 * 智能问答响应数据接口
 */
interface GeneratedTypeLiteralInterface_3 {
  answer: string;
  recommendations: GeneratedTypeLiteralInterface_2[];
}

/**
 * 智能问答API响应接口 - 与用户接口保持一致，使用msg字段
 */
export interface AskAssistantApiResponse {
  code: number;
  msg: string;  // 使用msg，与您的其他接口一致
  data: GeneratedTypeLiteralInterface_3 | null;
}

// ==================== API函数 ====================

/**
 * 向智能助手提问
 * @param askData 提问请求数据
 * @returns Promise<AskAssistantApiResponse> 响应结果
 */
export async function askAssistant(askData: AskAssistantRequest): Promise<AskAssistantApiResponse | void> {
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

    const response = await request.request(
      `${BASE_URL}/assistant/ask`,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,  // 保持 Authorization
          'token': token  // 同时发送 token 头
        },
        extraData: JSON.stringify(askData)
      }
    );

    console.log('🔍 DEBUG: Response Status =', response.responseCode);

    // 安全的header访问
    if (response.header) {
      console.log('🔍 DEBUG: Response Headers =', response.header);
    }

    if (response.result) {
      const resultStr = String(response.result);
      console.log('🔍 DEBUG: Response Body =', resultStr);
    }

    if (response.responseCode === 200) {
      if (response.result) {
        const resultStr = String(response.result);
        console.log('提问智能助手响应:', resultStr);

        try {
          const res: AskAssistantApiResponse = JSON.parse(resultStr);

          if (res.code === 200 && res.data) {
            console.log('智能助手回答成功');
            return res;
          } else {
            console.log('智能助手返回错误:', res.msg);
            return res;
          }
        } catch (parseError) {
          console.error('解析智能助手响应失败:', parseError);
        }
      } else {
        console.warn('响应结果为空');
      }
    } else {
      console.log("提问智能助手失败，状态码:", response.responseCode);
      // 添加详细错误信息
      if (response.result) {
        const errorResult = String(response.result);
        console.log("错误响应内容:", errorResult);
        try {
          const errorJson: AskAssistantApiResponse = JSON.parse(errorResult);
          console.log("错误JSON:", errorJson);
        } catch (e) {
          console.log("错误内容不是JSON格式");
        }
      }
    }
  } catch (error) {
    console.error('提问智能助手异常:', error);
  } finally {
    request.destroy();
  }
}

/**
 * 简化版提问函数（无上下文）
 * @param question 用户问题
 * @returns Promise<AskAssistantApiResponse> 响应结果
 */
export async function askSimple(question: string): Promise<AskAssistantApiResponse | void> {
  const askData: AskAssistantRequest = {
    question: question
  };

  return await askAssistant(askData);
}