// entry/src/main/ets/pages/EditProfilePage.ets

import router from '@ohos.router';
// 导入用户信息接口
import { getProfile, updateProfile, UpdateProfileRequest } from "../api/user";

// 用户信息接口（与ProfilePage保持一致）
interface UserData {
  userId: number;
  username: string;
  nickname: string;
  avatar: string;
  points: number;
  checkinCount: number;
  isMerchant: string;
  checkinSpotIds: number[];
  email: string;
}

// ProfileApiResponse 接口
interface ProfileApiResponse {
  code: number;
  msg: string;
  data: UserData;
}

interface GeneratedObjectLiteralInterface_2 {
  nickname: string;
  avatar: string;
  email: string;
}

interface GeneratedObjectLiteralInterface_1 {
  nickname: string;
  avatar: string;
  email: string;
}

@Entry
@Component
export default struct EditProfilePage {
  // 页面标题
  private pageTitle: string = '修改个人信息';

  // 用户原始信息
  @State originalUserInfo: UserData = {
    userId: 0,
    username: '',
    nickname: '',
    avatar: '',
    points: 0,
    checkinCount: 0,
    isMerchant: '0',
    checkinSpotIds: [],
    email: ''
  };

  // 修改后的用户信息
  @State nickname: string = '';
  @State email: string = '';
  @State avatarUrl: string = '';

  // 用户名（只读）
  @State username: string = '';

  // 表单验证状态
  @State nicknameValid: boolean = true;
  @State emailValid: boolean = true;
  @State nicknameError: string = '';
  @State emailError: string = '';

  // 数据加载状态
  @State isLoading: boolean = false;
  @State isError: boolean = false;
  @State errorMessage: string = '';

  // 保存状态
  @State isSaving: boolean = false;

  // 表单是否被修改
  @State isFormModified: boolean = false;

  // ==================== 构建方法 ====================

  build() {
    Column() {
      // 1. 顶部导航栏
      this.buildNavigationBar()

      // 2. 显示加载状态
      if (this.isLoading) {
        this.buildLoadingView()
      } else {
        // 3. 滚动内容区域
        Scroll() {
          Column() {
            // 4. 头像修改区域
            this.buildAvatarSection()

            // 5. 个人信息表单
            this.buildProfileForm()

            // 6. 保存按钮
            this.buildSaveButton()

            // 7. 底部安全区域占位
            Row()
              .height(80)
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .width('100%')
        .layoutWeight(1)
      }

      // 显示错误信息
      if (this.isError) {
        this.buildErrorView()
      }

      // 保存中遮罩层
      if (this.isSaving) {
        this.buildSavingOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // ==================== 构建器方法 ====================

  // 顶部导航栏 - 修复返回按钮点击区域
  @Builder
  buildNavigationBar() {
    Column() {
      Row({ space: 12 }) {
        // 返回按钮 - 增大点击区域
        Column() {
          Text('←')
            .fontSize(24)
            .fontColor('#007AFF')
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ left: 8 })
        .onClick(() => {
          console.log('点击返回按钮');
          this.onBackClick();
        })

        // 标题
        Text(this.pageTitle)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，使标题居中
        Column() {
          Text('←')
            .fontSize(24)
            .fontColor('#007AFF')
            .opacity(0)
        }
        .width(40)
        .height(40)
        .margin({ right: 8 })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)

      // 导航栏底部阴影
      Divider()
        .strokeWidth(0.5)
        .color('#E0E0E0')
    }
  }

  // 加载视图
  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#007AFF')

      Text('正在加载用户信息...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 错误视图
  @Builder
  buildErrorView() {
    Column() {
      Text('加载失败')
        .fontSize(16)
        .fontColor('#FF3B30')
        .margin({ bottom: 8 })

      Text(this.errorMessage)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ bottom: 16 })

      Button('重试')
        .backgroundColor('#007AFF')
        .fontColor(Color.White)
        .fontSize(14)
        .width(120)
        .height(36)
        .onClick(() => {
          this.loadUserInfo();
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFF3F3')
    .borderRadius(12)
    .margin({ top: 10, bottom: 10, left: 15, right: 15 })
  }

  // 保存中遮罩层
  @Builder
  buildSavingOverlay() {
    Column() {
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#FFFFFF')

        Text('正在保存...')
          .fontSize(14)
          .fontColor(Color.White)
          .margin({ top: 12 })
      }
      .padding(30)
      .backgroundColor('#00000080')
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .position({ x: 0, y: 0 })
  }

  // 头像修改区域
  @Builder
  buildAvatarSection() {
    Column() {
      Text('头像')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .margin({ left: 20, top: 20, bottom: 15 })
        .alignSelf(ItemAlign.Start)

      Column() {
        // 头像容器
        Column() {
          if (this.avatarUrl && this.avatarUrl !== '') {
            // 如果有头像URL，显示头像
            Image(this.avatarUrl)
              .width(100)
              .height(100)
              .objectFit(ImageFit.Cover)
              .borderRadius(50)
              .border({ width: 3, color: '#FFFFFF' })
          } else {
            // 使用与个人信息界面相同的默认头像
            Image($r('app.media.startIcon'))
              .width(100)
              .height(100)
              .objectFit(ImageFit.Cover)
              .borderRadius(50)
              .border({ width: 3, color: '#FFFFFF' })
          }

          // 更换头像按钮
          Column() {
            Text('📷')
              .fontSize(18)
          }
          .width(36)
          .height(36)
          .backgroundColor('#007AFF')
          .borderRadius(18)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .position({ x: 70, y: 70 })
          .onClick(() => {
            this.onChangeAvatarClick();
          })
        }
        .width(100)
        .height(100)

        // 提示文字
        Text('点击更换头像')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 12 })
      }
      .width('100%')
      .padding({ top: 30, bottom: 30 })
      .backgroundColor(Color.White)
      .borderRadius(12)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ left: 20, right: 20 })
    }
  }

  // 个人信息表单
  @Builder
  buildProfileForm() {
    Column() {
      // 表单标题
      Text('基本信息')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .margin({ left: 20, top: 25, bottom: 15 })
        .alignSelf(ItemAlign.Start)

      // 表单容器
      Column() {
        // 1. 昵称输入
        this.buildNicknameInput()

        Divider()
          .strokeWidth(0.5)
          .color('#F0F0F0')
          .margin({ left: 20, right: 20 })

        // 2. 邮箱输入
        this.buildEmailInput()

        Divider()
          .strokeWidth(0.5)
          .color('#F0F0F0')
          .margin({ left: 20, right: 20 })

        // 3. 用户名显示（不可修改）
        this.buildUsernameDisplay()
      }
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ left: 20, right: 20 })
      .shadow({ radius: 2, color: '#00000008' })
    }
  }

  // 昵称输入框
  @Builder
  buildNicknameInput() {
    Column() {
      Row({ space: 12 }) {
        Text('昵称')
          .fontSize(16)
          .fontColor('#333333')
          .width(70)

        TextInput({
          text: this.nickname,
          placeholder: '请输入昵称'
        })
          .layoutWeight(1)
          .height(50)
          .fontSize(16)
          .fontColor('#333333')
          .caretColor('#007AFF')
          .maxLength(20)
          .onChange((value: string) => {
            this.onNicknameChange(value);
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })

      // 昵称错误提示
      if (!this.nicknameValid && this.nicknameError) {
        Text(this.nicknameError)
          .fontSize(12)
          .fontColor('#FF3B30')
          .margin({ left: 20, top: 4, bottom: 8 })
          .alignSelf(ItemAlign.Start)
      }
    }
  }

  // 邮箱输入框
  @Builder
  buildEmailInput() {
    Column() {
      Row({ space: 12 }) {
        Text('邮箱')
          .fontSize(16)
          .fontColor('#333333')
          .width(70)

        TextInput({
          text: this.email,
          placeholder: '请输入邮箱地址'
        })
          .layoutWeight(1)
          .height(50)
          .fontSize(16)
          .fontColor('#333333')
          .caretColor('#007AFF')
          .type(InputType.Normal)
          .onChange((value: string) => {
            this.onEmailChange(value);
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })

      // 邮箱错误提示
      if (!this.emailValid && this.emailError) {
        Text(this.emailError)
          .fontSize(12)
          .fontColor('#FF3B30')
          .margin({ left: 20, top: 4, bottom: 8 })
          .alignSelf(ItemAlign.Start)
      }
    }
  }

  // 用户名显示（不可修改）
  @Builder
  buildUsernameDisplay() {
    Row({ space: 12 }) {
      Text('用户名')
        .fontSize(16)
        .fontColor('#333333')
        .width(70)

      Text(this.username || '未设置')
        .layoutWeight(1)
        .height(50)
        .fontSize(16)
        .fontColor('#666666')
        .textAlign(TextAlign.Start)
        .align(Alignment.Start)
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
  }

  // 保存按钮 - 修复按钮结构
  @Builder
  buildSaveButton() {
    Column() {
      Button() {
        Text('保存修改')
          .fontSize(16)
          .fontColor(Color.White)
      }
      .width('90%')
      .height(50)
      .backgroundColor(this.isFormModified && this.isFormValid() ? '#007AFF' : '#CCCCCC')
      .enabled(this.isFormModified && this.isFormValid() && !this.isSaving)
      .onClick(() => {
        this.onSaveClick();
      })
      .margin({ top: 30, bottom: 10 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // ==================== 事件处理方法 ====================

  // 返回按钮点击
  private onBackClick() {
    console.log('点击返回按钮');

    // 如果表单有修改，可以添加确认提示
    if (this.isFormModified && !this.isSaving) {
      console.log('表单有未保存的修改，点击返回将丢失修改');
    }

    // 使用router返回
    router.back();
  }

  // 更换头像点击
  private onChangeAvatarClick() {
    console.log('点击更换头像');

    // 模拟头像选择
    const testAvatarUrl = 'https://avatars.githubusercontent.com/u/1?v=4';
    this.avatarUrl = testAvatarUrl;
    this.checkFormModified();
    console.log('头像已更新:', testAvatarUrl);
  }

  // 昵称变更
  private onNicknameChange(value: string) {
    console.log('昵称变更:', value);
    this.nickname = value;
    this.validateNickname(value);
    this.checkFormModified();
  }

  // 邮箱变更
  private onEmailChange(value: string) {
    console.log('邮箱变更:', value);
    this.email = value;
    this.validateEmail(value);
    this.checkFormModified();
  }

  /// 保存按钮点击
  private async onSaveClick() {
    console.log('点击保存按钮');

    // 验证表单
    if (!this.isFormValid()) {
      console.log('表单验证失败');
      return;
    }

    // 如果没有修改，直接返回
    if (!this.isFormModified) {
      console.log('没有修改任何信息');
      router.back();
      return;
    }

    // 设置保存状态
    this.isSaving = true;

    try {
      // 构建更新数据
      const updateData = new UpdateProfileRequest();
      updateData.nickname = this.nickname;
      updateData.email = this.email;
      updateData.avatar = this.avatarUrl;

      console.log('提交的用户信息:', updateData);

      // 调用更新接口
      const result = await updateProfile(updateData);

      // 首先检查 result 是否存在
      if (!result) {
        console.log('修改个人信息失败: 返回空响应');
        this.isSaving = false;
        return;
      }

      // 现在我们知道 result 是 UpdateProfileApiResponse 类型
      if (result.code === 200) {
        console.log('修改个人信息成功:', result.msg);
        console.log('更新后的用户数据:', result.data);

        // 延迟后返回
        setTimeout(() => {
          this.isSaving = false;
          router.back();
        }, 500);
      } else {
        console.log('修改个人信息失败:', result.msg || '未知错误');
        this.isSaving = false;
        // 这里可以添加错误提示
      }
    } catch (error) {
      console.error('保存用户信息异常:', error);
      this.isSaving = false;
    }
  }

  // ==================== 表单验证方法 ====================

  // 验证昵称
  private validateNickname(nickname: string) {
    if (!nickname || nickname.trim() === '') {
      this.nicknameValid = false;
      this.nicknameError = '昵称不能为空';
      return;
    }

    if (nickname.length < 2) {
      this.nicknameValid = false;
      this.nicknameError = '昵称至少2个字符';
      return;
    }

    if (nickname.length > 20) {
      this.nicknameValid = false;
      this.nicknameError = '昵称不能超过20个字符';
      return;
    }

    this.nicknameValid = true;
    this.nicknameError = '';
  }

  // 验证邮箱
  private validateEmail(email: string) {
    if (!email || email.trim() === '') {
      this.emailValid = false;
      this.emailError = '邮箱不能为空';
      return;
    }

    // 简单的邮箱格式验证
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      this.emailValid = false;
      this.emailError = '邮箱格式不正确';
      return;
    }

    this.emailValid = true;
    this.emailError = '';
  }

  // 检查表单是否有效
  private isFormValid(): boolean {
    return this.nicknameValid && this.emailValid;
  }

  // 检查表单是否被修改
  private checkFormModified() {
    const original: GeneratedObjectLiteralInterface_1 = {
      nickname: this.originalUserInfo.nickname,
      avatar: this.originalUserInfo.avatar,
      email: this.originalUserInfo.email
    };

    const current: GeneratedObjectLiteralInterface_2 = {
      nickname: this.nickname,
      avatar: this.avatarUrl,
      email: this.email
    };

    this.isFormModified =
      original.nickname !== current.nickname ||
        original.avatar !== current.avatar ||
        original.email !== current.email;

    console.log('表单修改状态:', this.isFormModified);
  }

  // ==================== 数据加载方法 ====================

  // 加载用户信息
  private loadUserInfo() {
    console.log('开始加载用户信息...');

    // 显示加载状态
    this.isLoading = true;
    this.isError = false;
    this.errorMessage = '';

    // 调用 getProfile 方法
    getProfile().then((response) => {
      console.log('获取用户资料API响应:', response);

      if (response) {
        // 如果获取成功，更新用户信息显示
        if (response.code === 200 && response.data) {
          const userData = response.data;

          console.log('服务器返回的用户数据:', userData);

          // 保存用户名
          this.username = userData.username || '';

          // 确定显示昵称：如果昵称为空，使用用户名
          let displayNickname = userData.nickname;
          if (!displayNickname || displayNickname.trim() === '') {
            displayNickname = this.username || '旅行爱好者';
          }

          // 保存原始用户信息
          this.originalUserInfo = {
            userId: userData.userId || 0,
            username: userData.username || '',
            nickname: displayNickname,
            avatar: userData.avatar || '',
            points: userData.points || 0,
            checkinCount: userData.checkinCount || 0,
            isMerchant: userData.isMerchant || '0',
            checkinSpotIds: userData.checkinSpotIds || [],
            email: userData.email || ''
          };

          // 设置当前表单数据
          this.nickname = displayNickname;
          this.email = userData.email || '';
          this.avatarUrl = userData.avatar || '';

          // 验证初始数据
          this.validateNickname(this.nickname);
          this.validateEmail(this.email);

          console.log('用户信息加载完成');
          console.log('原始信息:', this.originalUserInfo);
          console.log('表单数据:', {
            nickname: this.nickname,
            email: this.email,
            avatarUrl: this.avatarUrl
          });
        } else {
          console.log('获取用户资料失败，服务器返回错误:', response.msg || '未知错误');
          this.isError = true;
          this.errorMessage = response.msg || '服务器返回错误';
        }
      } else {
        console.log('获取用户资料失败: 返回空响应');
        this.isError = true;
        this.errorMessage = '服务器返回空响应';
      }
    }).catch((error: Error) => {
      console.error('获取用户资料异常:', error);
      this.isError = true;
      this.errorMessage = error.message || '网络请求失败';
    }).finally(() => {
      // 隐藏加载状态
      this.isLoading = false;
      console.log('加载用户信息完成');
    });
  }

  // ==================== 生命周期方法 ====================

  aboutToAppear() {
    console.log('修改个人信息页面显示');
    this.loadUserInfo();
  }

  aboutToDisappear() {
    console.log('修改个人信息页面隐藏');
  }
}