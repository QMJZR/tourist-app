import preferences from '@ohos.data.preferences';

// 定义存储文件名和键名
const PREF_NAME = 'user_preferences';
const KEY_TOKEN = 'auth_token';
const KEY_USER_INFO = 'user_info';
const KEY_USER_ID = 'user_id';

interface UserData {
  userId: number;
  username: string;
  nickname: string;
  avatar: string;
  points: number;
  checkinCount: number;
  isMerchant: string;
  checkinSpotIds: number[];  // 数组类型
  email: string;
}
class StorageUtil {
  private static prefs: preferences.Preferences;

  // 初始化 Preferences
  static async initPreferences(): Promise<void> {
    try {
      StorageUtil.prefs = await preferences.getPreferences(
        getContext(),
        PREF_NAME
      );
      console.log('Preferences 初始化成功');
    } catch (error) {
      console.error('Preferences 初始化失败:', error);
    }
  }

  // 存储登录信息
  static async saveLoginInfo(token: string, userId: number): Promise<void> {
    if (!StorageUtil.prefs) await StorageUtil.initPreferences();
    console.log("i will save userId  :", userId);
    try {
      // 存储 token
      await StorageUtil.prefs.put(KEY_TOKEN, token);
      // 存储用户信息
      await StorageUtil.prefs.put(KEY_USER_ID, userId);
      // 提交更改
      await StorageUtil.prefs.flush();

      console.log('登录信息保存成功');

    } catch (error) {
      console.error('保存登录信息失败:', error);
    }
  }

  // 存储个人信息
  static async saveUserInfo(userData: UserData): Promise<void> {
    if (!StorageUtil.prefs) await StorageUtil.initPreferences();

    try {
      // // 存储 token
      // await StorageUtil.prefs.put(KEY_TOKEN, token);
      // 存储用户信息
      await StorageUtil.prefs.put(KEY_USER_INFO, JSON.stringify(userData));
      // 提交更改
      await StorageUtil.prefs.flush();

      console.log('个人信息保存成功');

    } catch (error) {
      console.error('保存个人信息失败:', error);
    }
  }

  // 获取 token
  static async getToken(): Promise<string | null> {
    if (!StorageUtil.prefs) await StorageUtil.initPreferences();

    try {
      const token = await StorageUtil.prefs.get(KEY_TOKEN, '');
      return token as string || null;
    } catch (error) {
      console.error('获取 token 失败:', error);
      return null;
    }
  }
  // get Id
  static async getUserId(): Promise<number> {
    if (!StorageUtil.prefs) await StorageUtil.initPreferences();
    try {
      const userId = await StorageUtil.prefs.get(KEY_USER_ID, '');
      return userId as number;
    } catch (error) {
      console.error('获取 token 失败:', error);
      return 0x666;
    }
  }
  // 获取用户信息
  static async getUserInfo(): Promise<UserData | null> {
    if (!StorageUtil.prefs) await StorageUtil.initPreferences();

    try {
      const userJson = await StorageUtil.prefs.get(KEY_USER_INFO, '');
      if (userJson && typeof userJson === 'string') {
        return JSON.parse(userJson);
      }

      return null;
    } catch (error) {
      console.error('获取用户信息失败:', error);
      return null;
    }
  }

  // 清除登录信息（退出登录）
  static async clearLoginInfo(): Promise<void> {
    if (!StorageUtil.prefs) await StorageUtil.initPreferences();

    try {
      await StorageUtil.prefs.delete(KEY_TOKEN);
      await StorageUtil.prefs.delete(KEY_USER_INFO);
      await StorageUtil.prefs.flush();
      console.log('登录信息已清除');
    } catch (error) {
      console.error('清除登录信息失败:', error);
    }
  }

  // 检查是否已登录
  static async isLoggedIn(): Promise<boolean> {
    const token = await StorageUtil.getToken();
    return !!token;
  }
}

export default StorageUtil;