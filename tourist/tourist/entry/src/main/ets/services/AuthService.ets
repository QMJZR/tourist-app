import { HttpUtils } from '../utils/HttpUtils';
import { LoginRequest, RegisterRequest, LoginResponse, User, ProfileResponse, LoginData } from '../models/User';
import { Constants } from '../utils/Constants';
import { BaseResponse, EmptyData } from '../models/Common';

export class AuthService {
  static async login(loginData: LoginRequest): Promise<LoginResponse> {
    const response = await HttpUtils.post<LoginData>('/auth/login', loginData);

    if (response.code === Constants.SUCCESS_CODE && response.data) {
      AppStorage.setOrCreate(Constants.TOKEN_KEY, response.data.token);
    }

    return {
      code: response.code,
      message: response.message,
      data: response.data
    } as LoginResponse;
  }

  static async register(registerData: RegisterRequest): Promise<LoginResponse> {
    const response = await HttpUtils.post<LoginData>('/auth/register', registerData);

    if (response.code === Constants.SUCCESS_CODE && response.data) {
      AppStorage.setOrCreate(Constants.TOKEN_KEY, response.data.token);
    }

    return {
      code: response.code,
      message: response.message,
      data: response.data
    } as LoginResponse;
  }

  static async getProfile(): Promise<ProfileResponse> {
    const response = await HttpUtils.get<User>('/auth/profile');
    return {
      code: response.code,
      message: response.message,
      data: response.data
    } as ProfileResponse;
  }

  static async updateProfile(profileData: object): Promise<BaseResponse<User>> {
    return await HttpUtils.put<User>('/user/profile', profileData);
  }

  static logout(): void {
    AppStorage.setOrCreate(Constants.TOKEN_KEY, '');
    AppStorage.setOrCreate(Constants.USER_INFO_KEY, '');
  }

  static isLoggedIn(): boolean {
    const token = AppStorage.get<string>(Constants.TOKEN_KEY);
    return !!token;
  }
}