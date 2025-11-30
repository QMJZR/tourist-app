export class Constants {
  static readonly BASE_URL: string = 'https://your-api-domain.com/api/v1';
  static readonly TOKEN_KEY: string = 'user_token';
  static readonly USER_INFO_KEY: string = 'user_info';

  // 错误码
  static readonly SUCCESS_CODE: number = 200;
  static readonly UNAUTHORIZED_CODE: number = 1201;
  static readonly TOKEN_EXPIRED_CODE: number = 1202;
}