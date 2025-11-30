import { AuthService } from '../services/AuthService';
import { LoginRequest } from '../models/User';
import { Constants } from '../utils/Constants';
import router from '@ohos.router';
import prompt from '@ohos.promptAction';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;

  build() {
    Column() {
      // Header
      Text('登录')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60, bottom: 40 })

      // Username Input
      TextInput({ placeholder: '请输入用户名' })
        .width('90%')
        .height(50)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding(10)
        .onChange((value: string) => {
          this.username = value;
        })
        .margin({ bottom: 20 })

      // Password Input
      TextInput({ placeholder: '请输入密码' })
        .width('90%')
        .height(50)
        .type(InputType.Password)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding(10)
        .onChange((value: string) => {
          this.password = value;
        })
        .margin({ bottom: 30 })

      // Login Button
      Button('登录', { type: ButtonType.Capsule })
        .width('90%')
        .height(50)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .enabled(!this.isLoading && !!this.username && !!this.password)
        .onClick(() => {
          this.handleLogin();
        })
        .margin({ bottom: 20 })

      // Register Link
      Row() {
        Text('还没有账号？')
          .fontSize(14)
          .fontColor('#666')

        Text('立即注册')
          .fontSize(14)
          .fontColor('#007DFF')
          .onClick(() => {
            router.pushUrl({ url: 'pages/RegisterPage' });
          })
      }
      .margin({ top: 20 })

      // Loading
      if (this.isLoading) {
        LoadingProgress()
          .color('#007DFF')
          .margin({ top: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .padding(20)
  }

  private async handleLogin() {
    this.isLoading = true;

    const loginData: LoginRequest = {
      username: this.username,
      password: this.password
    };

    try {
      const response = await AuthService.login(loginData);

      if (response.code === Constants.SUCCESS_CODE) {
        // 登录成功，跳转到主页
        router.replaceUrl({ url: 'pages/MainPage' });
      } else {
        // 显示错误信息
        this.showToast(response.message);
      }
    } catch (error) {
      this.showToast('登录失败，请重试');
    } finally {
      this.isLoading = false;
    }
  }

  private showToast(message: string): void {
    prompt.showToast({
      message: message,
      duration: 3000
    });
  }
}