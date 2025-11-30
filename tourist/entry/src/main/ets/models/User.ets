export class User {
  userId: number = 0;
  username: string = '';
  nickname: string = '';
  avatar: string = '';
  email: string = '';
  points: number = 0;
  checkinCount: number = 0;
  isMerchant: string = 'N';
  checkinSpotIds: number[] = [];
}

export class LoginRequest {
  username: string = '';
  password: string = '';
}

export class RegisterRequest {
  username: string = '';
  password: string = '';
  email: string = '';
}

export class LoginData {
  userId: number = 0;
  token: string = '';
  expiresIn: number = 0;
}

export class LoginResponse {
  code: number = 0;
  message: string = '';
  data?: LoginData;
}

export class ProfileResponse {
  code: number = 0;
  message: string = '';
  data?: User;
}