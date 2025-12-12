import router from '@ohos.router';
import { prompt } from '@kit.ArkUI';
import {register, RegisterRequest} from "../api/user"
@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State email: string = '';
  @State isPasswordMatch: boolean = true;

  build() {
    Column({ space: 15 }) {
      // 顶部标题
      Text('注册账号')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#007DFF')
        .margin({ top: 60, bottom: 30 })

      // 用户名输入框
      Column({ space: 3 }) {
        Text('用户名')
          .fontSize(14)
          .fontColor('#666')
          .alignSelf(ItemAlign.Start)
          .margin({ left: '10%' })

        TextInput({ placeholder: '请输入用户名' })
          .width('80%')
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(24)
          .padding({ left: 20, right: 20 })
          .onChange((value: string) => {
            this.username = value;
          })
      }

      // 邮箱输入框
      Column({ space: 5 }) {
        Text('邮箱')
          .fontSize(14)
          .fontColor('#666')
          .alignSelf(ItemAlign.Start)
          .margin({ left: '10%' })

        TextInput({ placeholder: '请输入邮箱地址' })
          .width('80%')
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(24)
          .padding({ left: 20, right: 20 })
          .onChange((value: string) => {
            this.email = value;
          })
      }

      // 密码输入框
      Column({ space: 5 }) {
        Text('密码')
          .fontSize(14)
          .fontColor('#666')
          .alignSelf(ItemAlign.Start)
          .margin({ left: '10%' })

        TextInput({ placeholder: '请输入密码（至少6位）' })
          .width('80%')
          .height(48)
          .type(InputType.Password)
          .backgroundColor(Color.White)
          .borderRadius(24)
          .padding({ left: 20, right: 20 })
          .onChange((value: string) => {
            this.password = value;
            this.checkPasswordMatch();
          })
      }

      // 确认密码输入框
      Column({ space: 5 }) {
        Text('确认密码')
          .fontSize(14)
          .fontColor('#666')
          .alignSelf(ItemAlign.Start)
          .margin({ left: '10%' })

        TextInput({ placeholder: '请再次输入密码' })
          .width('80%')
          .height(48)
          .type(InputType.Password)
          .backgroundColor(Color.White)
          .borderRadius(24)
          .padding({ left: 20, right: 20 })
          .onChange((value: string) => {
            this.confirmPassword = value;
            this.checkPasswordMatch();
          })
      }

      // 密码匹配提示
      if (!this.isPasswordMatch && this.confirmPassword) {
        Text('两次输入的密码不一致')
          .fontSize(12)
          .fontColor('#FF3B30')
          .margin({ top: 5 })
      }

      // 注册按钮
      Button('注册')
        .width('80%')
        .height(50)
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor('#007DFF')
        .borderRadius(25)
        .enabled(this.isFormValid())
        .opacity(this.isFormValid() ? 1 : 0.5)
        .onClick(() => {
          this.handleRegister();
        })
        .margin({ top: 30 })

      // 用户协议
      Row() {
        Text('注册即表示同意')
          .fontSize(12)
          .fontColor('#666')

        Text('《用户协议》')
          .fontSize(12)
          .fontColor('#007DFF')
          .onClick(() => {
            // 跳转到用户协议页面
            console.log('查看用户协议');
          })

        Text('和')
          .fontSize(12)
          .fontColor('#666')

        Text('《隐私政策》')
          .fontSize(12)
          .fontColor('#007DFF')
          .onClick(() => {
            // 跳转到隐私政策页面
            console.log('查看隐私政策');
          })
      }
      .margin({ top: 15 })

      // 已有账号，返回登录
      Row() {
        Text('已有账号？')
          .fontSize(14)
          .fontColor('#666')

        Text('立即登录')
          .fontSize(14)
          .fontColor('#007DFF')
          .onClick(() => {
            router.back();
          })
      }
      .margin({ top: 25 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  // 检查密码是否匹配
  private checkPasswordMatch() {
    this.isPasswordMatch = this.password === this.confirmPassword;
  }

  // 检查表单是否有效
  private isFormValid(): boolean {
    return !!this.username &&
      !!this.email &&
      !!this.password &&
      !!this.confirmPassword &&
    this.isPasswordMatch &&
      this.password.length >= 6;
  }

  private handleRegister() {

    const data = new RegisterRequest();
    data.username = this.username;
    data.password = this.password;
    data.email = this.email;
    register(data);

    console.log('注册信息:');
    console.log('用户名:', this.username);
    console.log('邮箱:', this.email);
    console.log('密码:', this.password);

    // 模拟注册成功，跳转到登录页面
    prompt.showToast({
      message: '注册成功，请登录',
      duration: 2000
    });

    // 延迟后返回登录页
    setTimeout(() => {
      router.replaceUrl({
        url: 'pages/LoginPage',
        params: {
          username: this.username,
          registered: true
        }
      });
    }, 2000);
  }
}