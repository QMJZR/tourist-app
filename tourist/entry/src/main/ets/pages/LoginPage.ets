import router from '@ohos.router';
import {login, LoginRequest, LoginApiResponse} from "../api/user";
import {Prompt} from '@kit.ArkUI'
@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';

  build() {
    Column({ space: 20 }) {
      // 应用标题
      Text('欢迎使用')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#007DFF')
        .margin({ top: 80, bottom: 40 })

      // 用户名输入框
      TextInput({ placeholder: '用户名' })
        .width('80%')
        .height(50)
        .backgroundColor(Color.White)
        .borderRadius(25)
        .padding({ left: 20, right: 20 })
        .onChange((value: string) => {
          this.username = value;
        })

      // 密码输入框
      TextInput({ placeholder: '密码' })
        .width('80%')
        .height(50)
        .type(InputType.Password)
        .backgroundColor(Color.White)
        .borderRadius(25)
        .padding({ left: 20, right: 20 })
        .onChange((value: string) => {
          this.password = value;
        })

      // 登录按钮
      Button('登录')
        .width('80%')
        .height(50)
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor('#007DFF')
        .borderRadius(25)
        .enabled(!!this.username && !!this.password)
        .onClick(() => {
          this.handleLogin();
        })
        .margin({ top: 20 })

      // 注册按钮
      Button('注册账号')
        .width('80%')
        .height(50)
        .fontSize(18)
        .fontColor('#007DFF')
        .backgroundColor(Color.White)
        .borderRadius(25)
        .border({
          width: 1,
          color: '#007DFF'
        })
        .onClick(() => {
          router.pushUrl({ url: 'pages/RegisterPage' });
        })

      // 忘记密码（可选）
      Text('忘记密码？')
        .fontSize(14)
        .fontColor('#666')
        .margin({ top: 30 })
        .onClick(() => {
          // 可以添加忘记密码页面跳转
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  private async handleLogin() {

    const data = new LoginRequest();
    data.username = this.username;
    data.password = this.password;
    const res : LoginApiResponse  = await login(data) as LoginApiResponse;
    if(res.code == 200){
    // 跳转到主页面
    router.replaceUrl({
      url: 'pages/MainPage',
      params: {
        username: this.username,
        loginTime: new Date().toLocaleString()
      }
    });
    } else {
      Prompt.showToast({
        message:"账号或密码错误，请重试",
        duration: 2000
      })
    }

  }
}