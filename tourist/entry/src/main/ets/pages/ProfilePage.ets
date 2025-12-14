// entry/src/main/ets/pages/ProfilePage.ets

import router from '@ohos.router';
// 用户信息接口
import {getProfile} from "../api/user";

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
  @State userPoints: number = 0;  // 修改：默认积分设为0
  @State userCheckinCount: number = 0;
  @State userId: number = 0;

  // 数据加载状态
  @State isLoading: boolean = false;
  @State isError: boolean = false;
  @State errorMessage: string = '';

  // 功能列表 - 修改：我的礼品去掉副标题
  @State functionList: FunctionItem[] = [
    { id: 'checkin', icon: '📍', title: '打卡记录', subtitle: '查看您的打卡历史', showArrow: true, route: 'checkin_history' },
    { id: 'points', icon: '⭐', title: '积分', subtitle: '当前积分：0', showArrow: true, route: 'points' },  // 修改：积分从0开始
    { id: 'gifts', icon: '🎁', title: '我的礼品', showArrow: true, route: 'gifts' },  // 修改：移除副标题
    { id: 'edit', icon: '✏️', title: '修改个人信息', showArrow: true, route: 'edit_profile' }
  ];

  // 其他功能项
  @State otherFunctions: FunctionItem[] = [
    { id: 'settings', icon: '⚙️', title: '设置', showArrow: true, route: 'settings' },
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
          .layoutWeight(1) // 占据剩余空间
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

          // 动态更新副标题（我的礼品不显示副标题）
          if (item.subtitle && item.id !== 'gifts') {
            if (item.id === 'points') {
              // 积分功能项显示真实积分
              Text(`当前积分：${this.userPoints}`)
                .fontSize(13)
                .fontColor('#666666')
                .textAlign(TextAlign.Start)
                .width('100%')
            } else if (item.id === 'checkin') {
              // 打卡记录功能项显示真实打卡次数
              Text(`打卡次数：${this.userCheckinCount}`)
                .fontSize(13)
                .fontColor('#666666')
                .textAlign(TextAlign.Start)
                .width('100%')
            } else {
              Text(item.subtitle)
                .fontSize(13)
                .fontColor('#666666')
                .textAlign(TextAlign.Start)
                .width('100%')
            }
          }
        }
        .layoutWeight(1) // 占据剩余空间

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

      // 分隔线（不是最后一项时显示）
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
        this.onEditProfileClick();  // 修改：跳转到修改个人信息页面
        break;
      case 'settings':
        this.onSettingsClick();
        break;
      case 'help':
        this.onHelpClick();
        break;
    }
  }

  // 编辑个人信息点击
  private onEditProfileClick() {
    console.log('点击修改个人信息，跳转到编辑页面');

    // 使用router跳转到修改个人信息页面
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
    console.log('点击打卡记录');
  }

  // 积分点击
  private onPointsClick() {
    console.log('点击积分');
  }

  // 我的礼品点击
  private onGiftsClick() {
    console.log('点击我的礼品');
  }

  // 设置点击
  private onSettingsClick() {
    console.log('点击设置');
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
    console.log('点击退出登录');
    setTimeout(() => {
      console.log('退出登录成功');
    }, 1000);
  }

  // ==================== 生命周期方法 ====================

  aboutToAppear() {
    console.log('个人中心页面显示');
    this.loadUserInfo();
  }

  aboutToDisappear() {
    console.log('个人中心页面隐藏');
  }

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
            displayNickname = this.username || this.userInfo.nickname;
          }

          // 更新用户信息，如果数据为空则保留原有数据
          this.userInfo = {
            nickname: displayNickname || this.userInfo.nickname,
            avatar: userData.avatar || this.userInfo.avatar,
            email: userData.email || this.userInfo.email
          };

          // 更新用户ID
          this.userId = userData.userId || this.userId;

          // 更新用户积分
          this.userPoints = userData.points || 0;  // 修改：如果返回为空，设为0

          // 更新打卡次数
          this.userCheckinCount = userData.checkinCount || 0;

          // 更新功能列表的副标题
          this.updateFunctionListSubtitles();

          console.log('用户信息已更新:', this.userInfo);
          console.log('用户名:', this.username);
          console.log('用户积分:', this.userPoints);
          console.log('打卡次数:', this.userCheckinCount);
          console.log('用户ID:', this.userId);
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
        // 我的礼品项：去掉副标题
        return {
          id: item.id,
          icon: item.icon,
          title: item.title,
          showArrow: item.showArrow,  // 这里不设置 subtitle
          route: item.route
        };
      } else {
        return item;
      }
    });

    console.log('功能列表已更新:', this.functionList);
  }
}