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
  nickname:string;
  avatar:string;
  email:string;
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
  // 用户信息（写死假数据）
  @State userInfo: UserInfo = {
    nickname: '旅行爱好者',
    avatar: 'https://avatars.githubusercontent.com/u/1?v=4',
    email: 'traveler@example.com'
  };

  // 功能列表（写死假数据）
  @State functionList: FunctionItem[] = [
    { id: 'checkin', icon: '📍', title: '打卡记录', subtitle: '查看您的打卡历史', showArrow: true, route: 'checkin_history' },
    { id: 'points', icon: '⭐', title: '积分', subtitle: '当前积分：2560', showArrow: true, route: 'points' },
    { id: 'gifts', icon: '🎁', title: '我的礼品', subtitle: '已兑换3个礼品', showArrow: true, route: 'gifts' },
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
      // 1. 顶部用户信息卡片
      this.buildUserCard()

      // 2. 主要功能列表
      this.buildFunctionList()

      // 3. 其他功能列表
      this.buildOtherFunctions()

      // 4. 退出登录按钮
      this.buildLogoutButton()

      // ======== 新增的测试按钮 ========
      // 4. 测试获取用户资料按钮
      this.buildTestProfileButton()
      // ==============================

      // 5. 底部安全区域占位
      Row()
        .height(60)
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // ==================== 新增的构建器方法 ====================

  @Builder
  buildTestProfileButton() {
    Column() {
      Text('测试获取用户资料')
        .fontSize(16)
        .fontColor('#007AFF')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height(50)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .onClick(() => {
          this.onTestProfileClick();
        })
    }
    .margin({ left: 15, right: 15, top: 10, bottom: 10 })
  }

  // ==================== 新增的事件处理方法 ====================

  // 测试获取用户资料点击
  private onTestProfileClick() {
    console.log('点击测试获取用户资料按钮');

    // 调用 getProfile 方法
    getProfile().then((response) => {
      console.log("you clicked getProfile btn!");
      console.log('获取用户资料成功:', response);
      //   if (response) {
      //
      //
      //     // 如果获取成功，更新用户信息显示
      //     if (response.code === 200 && response.data) {
      //       this.userInfo = {
      //         nickname: response.data.nickname || this.userInfo.nickname,
      //         avatar: response.data.avatar || this.userInfo.avatar,
      //         email: response.data.email || this.userInfo.email
      //       };
      //       console.log('用户信息已更新');
      //     } else {
      //       console.log('获取用户资料失败:', response.message);
      //     }
      //   } else {
      //     console.log('获取用户资料失败: 返回空响应');
      //   }
      // }).catch((error) => {
      //   console.error('获取用户资料异常:', error);
      // });
    });
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
            // 头像图片
            Image($r('app.media.startIcon'))
              .width(80)
              .height(80)
              .objectFit(ImageFit.Cover)
              .borderRadius(40)
              .border({ width: 2, color: '#F0F0F0' })
              .shadow({ radius: 4, color: '#00000010' })
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

            // 用户邮箱
            Text(this.userInfo.email)
              .fontSize(15)
              .fontColor('#666666')
              .textAlign(TextAlign.Start)
              .width('100%')
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

          if (item.subtitle) {
            Text(item.subtitle)
              .fontSize(13)
              .fontColor('#666666')
              .textAlign(TextAlign.Start)
              .width('100%')
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

  // ==================== 点击事件处理 ====================

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
      case 'settings':
        this.onSettingsClick();
        break;
      case 'help':  // 新增case
        this.onHelpClick();
        break;
    }
  }


  // 编辑个人信息点击 - 点击"修改个人信息"功能项时调用
  private onEditProfileClick() {
    console.log('点击修改个人信息，跳转到编辑页面');
    // 这里可以跳转到修改个人信息页面
    // 所有编辑操作（头像、昵称、邮箱）都在那个页面完成
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

    // 明确指定类型
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
    console.log('加载用户信息...');
    setTimeout(() => {
      console.log('用户信息加载完成');
    }, 500);
  }
}