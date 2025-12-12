// entry/src/main/ets/utils/RouterManager.ets
import router from '@ohos.router';

// ==================== 1. 类型定义 ====================
// 修复：定义路由参数类型，避免使用any和untyped对象

// 基础JSON值类型
type JsonPrimitive = string | number | boolean | null;
interface JsonArray extends Array<JsonValue> {}
type JsonObject = object;
type JsonValue = JsonPrimitive | JsonArray | JsonObject;

// 路由参数基础接口
interface RouteParams extends JsonObject {}

// Router.back()方法的参数类型
interface RouterBackOptions {
  length?: number;
  params?: RouteParams;
}

// Router.pushUrl()的参数类型
interface RouterPushOptions {
  url: string;
  params?: RouteParams;
}

// 路由配置接口
interface RouteConfig {
  INDEX: string;
  LOGIN: string;
  REGISTER: string;
  MAIN: string;
  HOME: string;
  MAP: string;
  DISCOVER: string;
  PROFILE: string;
  SPOT_DETAIL: string;
  FEED_LIST: string;
  NEARBY: string;
  RANKING: string;
  SPOT_LIST: string;
  ZONE_LIST: string;
  ASSISTANT: string;
  MAP_CHECKIN: string;
}

/**
 * 路由管理器 - ArkTS兼容版本
 * 类似Vue Router的核心功能
 */
export class RouterManager {
  // ==================== 1. 路由常量定义 ====================
  // 修复：去掉as const，使用接口类型
  static readonly Routes: RouteConfig = {
    // 启动页
    INDEX: 'pages/Index',

    // 认证相关
    LOGIN: 'pages/LoginPage',
    REGISTER: 'pages/RegisterPage',

    // 主框架页（Tab容器）
    MAIN: 'pages/MainPage',

    // 主Tab页面（在MainPage中作为Tab显示）
    HOME: 'pages/HomePage',
    MAP: 'pages/MapPage',
    DISCOVER: 'pages/DiscoverPage',
    PROFILE: 'pages/ProfilePage',

    // 二级页面（从Tab页跳转）
    SPOT_DETAIL: 'pages/SpotDetailPage',
    FEED_LIST: 'pages/FeedListPage',
    NEARBY: 'pages/NearbyPage',
    RANKING: 'pages/RankingPage',
    SPOT_LIST: 'pages/SpotListPage',
    ZONE_LIST: 'pages/ZoneListPage',
    ASSISTANT: 'pages/AssistantPage',
    MAP_CHECKIN: 'pages/MapCheckInPage'
  };

  // ==================== 2. 核心路由方法 ====================

  /**
   * 跳转到指定页面（类似Vue的this.$router.push）
   * 修复：使用RouteParams类型替代Record<string, any>
   */
  static push(route: string, params?: RouteParams): Promise<void> {
    console.log(`[路由] 跳转到: ${route}`, params || '');

    const options: RouterPushOptions = {
      url: route,
      params: params || {}
    };

    return router.pushUrl(options);
  }

  /**
   * 返回上一页（类似Vue的this.$router.back()）
   * 修复：router.back()不支持result参数，使用params替代
   */
  static back(options?: RouterBackOptions): void {
    console.log('[路由] 返回上一页');

    if (options) {
      if (options.length !== undefined) {
        // 创建有类型的空对象
        const emptyParams: RouteParams = {};
        // 返回指定层数
        router.back(options.length, options.params || emptyParams);
      } else if (options.params) {
        // 返回时传递参数
        router.back(1, options.params);
      } else {
        // 普通返回
        router.back();
      }
    } else {
      router.back();
    }
  }

  /**
   * 获取当前路由路径（类似Vue的this.$route.path）
   */
  static getCurrentRoute(): string {
    const state = router.getState();
    return state ? (state.name || '') : '';
  }

  /**
   * 清空路由栈并跳转
   * 修复：使用RouteParams类型
   */
  static clearAndPush(route: string, params?: RouteParams): Promise<void> {
    console.log(`[路由] 清空栈并跳转到: ${route}`);

    router.clear(); // 清空历史记录
    return RouterManager.push(route, params);
  }

  /**
   * 检查当前是否在指定页面
   */
  static isCurrentRoute(route: string): boolean {
    return RouterManager.getCurrentRoute() === route;
  }
}