// entry/src/main/ets/pages/DiscoverPage.ets
import router from '@ohos.router';

// 功能项接口（与ProfilePage保持一致）
interface DiscoverFunctionItem {
  id: string;
  icon: string;
  title: string;
  subtitle?: string;
  showArrow: boolean;
  route?: string;
}

@Entry
@Component
export default struct DiscoverPage {
  // 发现功能列表（两条功能，结构与ProfilePage保持一致）
  @State functionList: DiscoverFunctionItem[] = [
    {
      id: 'ranking',
      icon: '🏆',
      title: '排行榜',
      subtitle: '查看热门景点与打卡达人',
      showArrow: true,
      route: 'pages/RankPage'
    },
    // {
    //   id: 'feeds',
    //   icon: '📝',
    //   title: '动态',
    //   subtitle: '浏览与分享旅行时刻',
    //   showArrow: true,
    //   route: 'pages/FeedListPage'
    // }
  ];

  // 其他发现功能（可后续扩展）
  @State otherFunctions: Array<DiscoverFunctionItem> = [
    {
      id: 'nearby',
      icon: '📍',
      title: '附近推荐',
      subtitle: '发现周围的精彩景点',
      showArrow: true,
      route: 'pages/NearbyPage'
    }
  ];

  // ==================== 构建方法 ====================
  build() {
    Column() {
      // 1. 顶部标题卡片
      this.buildTitleCard()

      // 2. 主要功能列表（两条功能）
      this.buildFunctionList()

      // 3. 其他功能列表
      this.buildOtherFunctions()

      // 4. 底部安全区域占位
      Row()
        .height(60)
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // ==================== 顶部标题卡片（类似个人信息卡片） ====================
  @Builder
  buildTitleCard() {
    Column() {
      // 标题卡片 - 白色设计
      Column({ space: 20 }) {
        // 图标和标题行
        Row({ space: 15 }) {
          // 左侧发现图标
          Column() {
            Text('🔍')
              .fontSize(40)
              .width(80)
              .height(80)
              .textAlign(TextAlign.Center)
              .backgroundColor('#F0F7FF')
              .borderRadius(40)
          }
          .width(80)
          .height(80)

          // 右侧标题信息
          Column({ space: 8 }) {
            // 主标题
            Text('发现')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .textAlign(TextAlign.Start)
              .width('100%')

            // 副标题
            Text('探索更多精彩内容')
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

  // ==================== 功能列表（与ProfilePage完全相同） ====================
  @Builder
  buildFunctionList() {
    Column() {
      ForEach(this.functionList, (item: DiscoverFunctionItem) => {
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
      ForEach(this.otherFunctions, (item: DiscoverFunctionItem) => {
        this.buildFunctionItem(item)
      })
    }
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 15, right: 15, bottom: 15 })
    .shadow({ radius: 4, color: '#00000008' })
  }

  @Builder
  buildFunctionItem(item: DiscoverFunctionItem) {
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

      // 分隔线（与ProfilePage相同的逻辑）
      if (item.id !== this.functionList[this.functionList.length - 1]?.id &&
        item.id !== this.otherFunctions[this.otherFunctions.length - 1]?.id) {
        Divider()
          .color('#F0F0F0')
          .margin({ left: 52, right: 0 })
          .strokeWidth(0.5)
      }
    }
  }

  // ==================== 点击事件处理（与ProfilePage结构相同） ====================
  private onFunctionItemClick(item: DiscoverFunctionItem): void {
    console.log(`点击发现功能项: ${item.title} (ID: ${item.id})`);

    switch (item.id) {
      case 'ranking':
        this.onRankingClick();
        break;
      case 'feeds':
        this.onFeedsClick();
        break;
      case 'nearby':
        this.onNearbyClick();  // 调用附近推荐点击方法
        break;
    }

    // 如果有路由配置，则执行跳转
    if (item.route) {
      console.log(`准备跳转到: ${item.route}`);
      const jumpPromise: Promise<void> = router.pushUrl({
        url: item.route
      });
      jumpPromise.then((): void => {
        console.log(`成功跳转到${item.title}页面`);
      }).catch((error: Error): void => {
        console.error(`跳转失败: ${error.message}`);
      });
    }
  }

  // 排行榜点击
  private onRankingClick(): void {
    console.log('点击排行榜');
    router.pushUrl({
      url:"pages/RankingPage"
    })
  }

  // 动态点击
  private onFeedsClick(): void {
    console.log('点击动态');
    // router.pushUrl({
    //   url:"pages/FeedListPage"
    // })
  }

  // 附近推荐点击
  private onNearbyClick(): void {
    console.log('点击附近推荐，跳转到附近推荐页面');
  }

  // ==================== 生命周期方法 ====================
  aboutToAppear() {
    console.log('发现页面显示');
  }

  aboutToDisappear() {
    console.log('发现页面隐藏');
  }
}