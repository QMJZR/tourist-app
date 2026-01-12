// entry/src/main/ets/pages/ProfilePage.ets

import router from '@ohos.router';
import { getProfile } from "../api/user";

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

interface UserInfo {
  nickname: string;
  avatar: string;
  email: string;
}

// 功能项接口
interface FunctionItem {
  id: string;
  icon: string;
  title: string;
  subtitle?: string;
  showArrow: boolean;
  route?: string;
}

// ProfileApiResponse 接口
interface ProfileApiResponse {
  code: number;
  msg: string;
  data: UserData;
}

// RouterParams 接口 - 移除索引签名
interface RouterParams {
  from?: string;
  needRefresh?: boolean;
  timestamp?: number;
}

@Entry
@Component
export default struct ProfilePage {
  // 用户信息 - 初始化为假数据
  @State userInfo: UserInfo = {
    nickname: '旅行爱好者',
    avatar: 'https://avatars.githubusercontent.com/u/1?v=4',
    email: 'traveler@example.com'
  };

  // 用户名 - 新增状态，用于显示用户名
  @State username: string = '';

  // 用户积分和打卡数据
  @State userPoints: number = 0;
  @State userCheckinCount: number = 0;
  @State userId: number = 0;

  // 数据加载状态
  @State isLoading: boolean = false;
  @State isError: boolean = false;
  @State errorMessage: string = '';

  // 退出登录确认弹窗
  @State showLogoutDialog: boolean = false;

  // 新增：上一次加载时间戳
  @State lastLoadTime: number = 0;

  // 功能列表
  @State functionList: Array<FunctionItem> = [
    { id: 'checkin', icon: '📍', title: '打卡记录', showArrow: true, route: 'checkin_detail' },
    { id: 'points', icon: '⭐', title: '积分', showArrow: true, route: 'points_detail' },
    { id: 'gifts', icon: '🎁', title: '我的礼品', showArrow: true, route: 'gifts_detail' },
    { id: 'edit', icon: '✏️', title: '修改个人信息', showArrow: true, route: 'edit_profile' }
  ];

  // 其他功能项
  @State otherFunctions: Array<FunctionItem> = [
    { id: 'help', icon: '❓', title: '帮助', showArrow: true, route: 'assistant' }
  ];

  // ==================== 构建方法 ====================

  build() {
    Column() {
      // 显示加载状态
      if (this.isLoading) {
        this.buildLoadingView()
      } else {
        // 1. 顶部用户信息卡片
        this.buildUserCard()

        // 2. 主要功能列表
        this.buildFunctionList()

        // 3. 其他功能列表
        this.buildOtherFunctions()

        // 4. 退出登录按钮
        this.buildLogoutButton()

        // 5. 底部安全区域占位
        Row()
          .height(60)
          .width('100%')
      }

      // 显示错误信息
      if (this.isError) {
        this.buildErrorView()
      }

      // 退出登录确认弹窗
      if (this.showLogoutDialog) {
        this.buildLogoutDialog()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // ==================== 新增构建器方法 ====================

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
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
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

  // 退出登录确认弹窗
  @Builder
  buildLogoutDialog() {
    Column() {
      // 半透明背景
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor('#00000060')
        .onClick(() => {
          this.showLogoutDialog = false;
        })

      // 弹窗内容
      Column({ space: 20 }) {
        // 标题
        Column() {
          Text('退出登录')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text('确定要退出当前账号吗？')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)

        // 按钮区域
        Row({ space: 12 }) {
          // 取消按钮
          Button('取消')
            .backgroundColor('#F0F0F0')
            .borderRadius(8)
            .layoutWeight(1)
            .height(42)
            .onClick(() => {
              this.showLogoutDialog = false;
            })

          // 确认按钮
          Button('确定退出')
            .backgroundColor('#FF3B30')
            .borderRadius(8)
            .layoutWeight(1)
            .height(42)
            .onClick(() => {
              this.showLogoutDialog = false;
              this.performLogout();
            })
        }
        .width('100%')
      }
      .padding(24)
      .width('80%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({ radius: 20, color: '#00000020' })
      .position({ x: '10%', y: '35%' })
    }
    .position({ x: 0, y: 0 })
    .width('100%')
    .height('100%')
  }

  // ==================== 顶部用户信息卡片 ====================

  @Builder
  buildUserCard() {
    Column() {
      // 用户信息卡片 - 简洁白色设计
      Column({ space: 20 }) {
        // 头像和用户信息行
        Row({ space: 15 }) {
          // 左侧头像
          Column() {
            // 如果服务器返回了头像URL，使用远程图片，否则使用本地图片
            if (this.userInfo.avatar && this.userInfo.avatar !== 'https://avatars.githubusercontent.com/u/1?v=4') {
              // 使用网络图片
              Image(this.userInfo.avatar)
                .width(80)
                .height(80)
                .objectFit(ImageFit.Cover)
                .borderRadius(40)
                .border({ width: 2, color: '#F0F0F0' })
                .shadow({ radius: 4, color: '#00000010' })
            } else {
              // 使用本地默认头像
              Image($r('app.media.startIcon'))
                .width(80)
                .height(80)
                .objectFit(ImageFit.Cover)
                .borderRadius(40)
                .border({ width: 2, color: '#F0F0F0' })
                .shadow({ radius: 4, color: '#00000010' })
            }
          }
          .width(80)
          .height(80)

          // 右侧用户信息
          Column({ space: 8 }) {
            // 用户昵称
            Text(this.userInfo.nickname)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .textAlign(TextAlign.Start)
              .width('100%')

            // 用户名（只在用户名和昵称不同时显示）
            if (this.username && this.username !== this.userInfo.nickname) {
              Text(`用户名: ${this.username}`)
                .fontSize(14)
                .fontColor('#999999')
                .textAlign(TextAlign.Start)
                .width('100%')
            }

            // 用户邮箱
            Text(this.userInfo.email)
              .fontSize(15)
              .fontColor('#666666')
              .textAlign(TextAlign.Start)
              .width('100%')

            // 用户ID和积分信息
            Row({ space: 12 }) {
              if (this.userId > 0) {
                Text(`ID: ${this.userId}`)
                  .fontSize(12)
                  .fontColor('#999999')
                  .backgroundColor('#F0F0F0')
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .borderRadius(4)
              }

              Text(`积分: ${this.userPoints}`)
                .fontSize(12)
                .fontColor('#FF9500')
                .backgroundColor('#FFF4E6')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(4)

              if (this.userCheckinCount > 0) {
                Text(`打卡: ${this.userCheckinCount}`)
                  .fontSize(12)
                  .fontColor('#34C759')
                  .backgroundColor('#E8F7E8')
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .borderRadius(4)
              }
            }
            .margin({ top: 4 })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 25, bottom: 25 })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({ radius: 4, color: '#00000008' })
      .margin({ left: 15, right: 15, top: 15, bottom: 20 })
    }
    .width('100%')
  }

  // ==================== 功能列表 ====================

  @Builder
  buildFunctionList() {
    Column() {
      ForEach(this.functionList, (item: FunctionItem) => {
        this.buildFunctionItem(item)
      })
    }
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 15, right: 15, bottom: 15 })
    .shadow({ radius: 4, color: '#00000008' })
  }

  @Builder
  buildOtherFunctions() {
    Column() {
      ForEach(this.otherFunctions, (item: FunctionItem) => {
        this.buildFunctionItem(item)
      })
    }
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 15, right: 15, bottom: 15 })
    .shadow({ radius: 4, color: '#00000008' })
  }

  @Builder
  buildFunctionItem(item: FunctionItem) {
    Column() {
      Row({ space: 12 }) {
        // 左侧图标
        Text(item.icon)
          .fontSize(20)
          .width(24)
          .textAlign(TextAlign.Center)

        // 标题和副标题
        Column({ space: 2 }) {
          Text(item.title)
            .fontSize(16)
            .fontColor('#333333')
            .textAlign(TextAlign.Start)
            .width('100%')

          // 动态更新副标题
          // if (item.subtitle && item.id !== 'gifts') {
          //   if (item.id === 'points') {
          //     Text(`当前积分：${this.userPoints}`)
          //       .fontSize(13)
          //       .fontColor('#666666')
          //       .textAlign(TextAlign.Start)
          //       .width('100%')
          //   } else if (item.id === 'checkin') {
          //     Text(`打卡次数：${this.userCheckinCount}`)
          //       .fontSize(13)
          //       .fontColor('#666666')
          //       .textAlign(TextAlign.Start)
          //       .width('100%')
          //   } else {
          //     Text(item.subtitle)
          //       .fontSize(13)
          //       .fontColor('#666666')
          //       .textAlign(TextAlign.Start)
          //       .width('100%')
          //   }
          // }
        }
        .layoutWeight(1)

        // 右侧箭头
        if (item.showArrow) {
          Text('›')
            .fontSize(20)
            .fontColor('#999999')
            .margin({ right: 5 })
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 12 })
      .backgroundColor(Color.White)
      .onClick(() => {
        this.onFunctionItemClick(item);
      })

      // 分隔线
      if (item.id !== this.functionList[this.functionList.length - 1]?.id &&
        item.id !== this.otherFunctions[this.otherFunctions.length - 1]?.id) {
        Divider()
          .color('#F0F0F0')
          .margin({ left: 52, right: 0 })
          .strokeWidth(0.5)
      }
    }
  }

  // ==================== 退出登录按钮 ====================

  @Builder
  buildLogoutButton() {
    Column() {
      Text('退出登录')
        .fontSize(16)
        .fontColor('#FF3B30')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height(50)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .onClick(() => {
          this.onLogoutClick();
        })
    }
    .margin({ left: 15, right: 15, top: 10, bottom: 30 })
  }

  // ==================== 事件处理方法 ====================

  // 功能项点击
  private onFunctionItemClick(item: FunctionItem) {
    console.log(`点击功能项: ${item.title} (ID: ${item.id})`);

    switch (item.id) {
      case 'checkin':
        this.onCheckinRecordClick();
        break;
      case 'points':
        this.onPointsClick();
        break;
      case 'gifts':
        this.onGiftsClick();
        break;
      case 'edit':
        this.onEditProfileClick();
        break;
      case 'help':
        this.onHelpClick();
        break;
    }
  }

  // 编辑个人信息点击
  private onEditProfileClick() {
    console.log('点击修改个人信息，跳转到编辑页面');

    const promise: Promise<void> = router.pushUrl({
      url: 'pages/EditProfilePage',
      params: {
        from: 'profile',
        timestamp: new Date().getTime()
      }
    });

    promise.then((): void => {
      console.log('成功跳转到修改个人信息页面');
    }).catch((error: Error): void => {
      console.error('跳转到修改个人信息页面失败:', error.message);
    });
  }

  // 打卡记录点击
  private onCheckinRecordClick() {
    console.log('点击打卡记录，跳转到打卡详情页面');

    const promise: Promise<void> = router.pushUrl({
      url: 'pages/CheckinDetailPage',
      params: {
        from: 'profile',
        timestamp: new Date().getTime()
      }
    });

    promise.then((): void => {
      console.log('成功跳转到打卡详情页面');
    }).catch((error: Error): void => {
      console.error('跳转到打卡详情页面失败:', error.message);
    });
  }

  // 积分点击
  private onPointsClick() {
    console.log('点击积分，跳转到积分详情页面');

    const promise: Promise<void> = router.pushUrl({
      url: 'pages/PointsDetailPage',
      params: {
        from: 'profile',
        timestamp: new Date().getTime()
      }
    });

    promise.then((): void => {
      console.log('成功跳转到积分详情页面');
    }).catch((error: Error): void => {
      console.error('跳转到积分详情页面失败:', error.message);
    });
  }

  // 我的礼品点击
  private onGiftsClick() {
    console.log('点击我的礼品，跳转到礼品详情页面');

    const promise: Promise<void> = router.pushUrl({
      url: 'pages/GiftsDetailPage',
      params: {
        from: 'profile',
        timestamp: new Date().getTime()
      }
    });

    promise.then((): void => {
      console.log('成功跳转到礼品详情页面');
    }).catch((error: Error): void => {
      console.error('跳转到礼品详情页面失败:', error.message);
    });
  }

  // 帮助点击
  private onHelpClick(): void {
    console.log('点击帮助，跳转到智能问答界面');

    const promise: Promise<void> = router.pushUrl({
      url: 'pages/AssistantPage',
      params: {
        from: 'profile',
        timestamp: new Date().getTime()
      }
    });

    promise.then((): void => {
      console.log('成功跳转到助手页面');
    }).catch((error: Error): void => {
      console.error('跳转失败:', error.message);
    });
  }

  // 退出登录点击
  private onLogoutClick() {
    console.log('点击退出登录，显示确认弹窗');
    this.showLogoutDialog = true;
  }

  // ==================== 执行退出登录操作 ====================

  private performLogout() {
    console.log('开始执行退出登录操作...');

    // 1. 清除本地存储的用户信息
    this.clearUserData();

    // 2. 显示退出成功提示
    console.log('退出登录成功');

    // 3. 延迟跳转到登录页面
    setTimeout(() => {
      this.navigateToLoginPage();
    }, 500);
  }

  // 清除用户数据
  private clearUserData() {
    try {
      // 清除用户信息
      this.userInfo = {
        nickname: '旅行爱好者',
        avatar: 'https://avatars.githubusercontent.com/u/1?v=4',
        email: 'traveler@example.com'
      };

      this.username = '';
      this.userPoints = 0;
      this.userCheckinCount = 0;
      this.userId = 0;

      console.log('用户数据已清除');
    } catch (error) {
      console.error('清除用户数据时出错:', error);
    }
  }

  // 跳转到登录页面
  private navigateToLoginPage() {
    console.log('跳转到登录页面...');

    const promise: Promise<void> = router.replaceUrl({
      url: 'pages/LoginPage',
      params: {
        from: 'logout',
        timestamp: new Date().getTime()
      }
    });

    promise.then((): void => {
      console.log('成功跳转到登录页面');
    }).catch((error: Error): void => {
      console.error('跳转到登录页面失败:', error.message);

      // 如果替换页面失败，尝试普通跳转
      const fallbackPromise = router.pushUrl({
        url: 'pages/LoginPage',
        params: {
          from: 'logout_fallback',
          timestamp: new Date().getTime()
        }
      });

      fallbackPromise.then(() => {
        console.log('备用方式跳转到登录页面成功');
      }).catch((fallbackError: Error) => {
        console.error('备用方式跳转也失败:', fallbackError.message);
      });
    });
  }

  // ==================== 生命周期方法 ====================

  aboutToAppear() {
    console.log('个人中心页面显示');

    // 获取路由参数
    const params: RouterParams = router.getParams() as RouterParams;
    console.log('路由参数:', params);

    // 检查是否需要刷新
    const needRefresh = params?.needRefresh === true;

    // 检查时间间隔，避免频繁刷新
    const currentTime = new Date().getTime();
    const timeDiff = currentTime - this.lastLoadTime;

    // 如果需要刷新或超过5秒未刷新，则加载数据
    if (needRefresh || timeDiff > 5000) {
      console.log('加载用户信息');
      this.loadUserInfo();
      this.lastLoadTime = currentTime;
    } else {
      console.log('跳过刷新，距离上次刷新时间太短:', timeDiff, 'ms');
    }
  }

  aboutToDisappear() {
    console.log('个人中心页面隐藏');
  }

  // ==================== 加载用户信息 ====================

  private loadUserInfo() {
    console.log('开始加载用户信息...');

    // 如果已经在加载中，跳过
    if (this.isLoading) {
      console.log('已经在加载中，跳过');
      return;
    }

    // 显示加载状态
    this.isLoading = true;
    this.isError = false;
    this.errorMessage = '';

    // 调用 getProfile 方法
    getProfile().then((response) => {
      console.log('获取用户资料API响应:', response);

      // 检查 response 是否存在
      if (!response) {
        console.log('❌ 获取用户资料失败: 返回空响应');
        this.isError = true;
        this.errorMessage = '服务器返回空响应';
        return;
      }

      // 现在 response 肯定不是 void，进行类型断言
      const apiResponse = response as ProfileApiResponse;

      if (apiResponse.code === 200 && apiResponse.data) {
        const userData = apiResponse.data;
        console.log('服务器返回的用户数据:', userData);

        // 保存用户名
        this.username = userData.username || '';

        // 确定显示昵称：如果昵称为空，使用用户名
        let displayNickname = userData.nickname;
        if (!displayNickname || displayNickname.trim() === '') {
          displayNickname = this.username || this.userInfo.nickname;
        }

        // 更新用户信息
        this.userInfo = {
          nickname: displayNickname || this.userInfo.nickname,
          avatar: userData.avatar || this.userInfo.avatar,
          email: userData.email || this.userInfo.email
        };

        // 更新用户ID
        this.userId = userData.userId || this.userId;

        // 更新用户积分
        this.userPoints = userData.points || 0;

        // 更新打卡次数
        this.userCheckinCount = userData.checkinCount || 0;

        // 更新功能列表的副标题
        this.updateFunctionListSubtitles();

        console.log('✅ 用户信息已更新');
        console.log('昵称:', this.userInfo.nickname);
        console.log('用户名:', this.username);
        console.log('积分:', this.userPoints);
        console.log('打卡次数:', this.userCheckinCount);
        console.log('用户ID:', this.userId);

      } else {
        console.log('❌ 获取用户资料失败:', apiResponse.msg || '未知错误');
        this.isError = true;
        this.errorMessage = apiResponse.msg || '服务器返回错误';
      }
    }).catch((error: Error) => {
      console.error('❌ 获取用户资料异常:', error);
      this.isError = true;
      this.errorMessage = error.message || '网络请求失败';
    }).finally(() => {
      // 隐藏加载状态
      this.isLoading = false;
      console.log('加载用户信息完成');
    });
  }

  // 更新功能列表副标题
  private updateFunctionListSubtitles() {
    // 使用 map 方法创建新的数组
    this.functionList = this.functionList.map((item: FunctionItem) => {
      if (item.id === 'points') {
        return {
          id: item.id,
          icon: item.icon,
          title: item.title,
          subtitle: `当前积分：${this.userPoints}`,
          showArrow: item.showArrow,
          route: item.route
        };
      } else if (item.id === 'checkin') {
        return {
          id: item.id,
          icon: item.icon,
          title: item.title,
          subtitle: `打卡次数：${this.userCheckinCount}`,
          showArrow: item.showArrow,
          route: item.route
        };
      } else if (item.id === 'gifts') {
        return {
          id: item.id,
          icon: item.icon,
          title: item.title,
          showArrow: item.showArrow,
          route: item.route
        };
      } else {
        return item;
      }
    });

    console.log('功能列表已更新:', this.functionList);
  }
}