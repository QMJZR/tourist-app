// entry/src/main/ets/pages/CheckinDetailPage.ets

import { router } from '@kit.ArkUI';

// 打卡记录类型定义
interface CheckinRecordLocal {
  checkinId: number;
  spotId: number;
  spotName: string;
  images: Array<string>;
  pointsEarned: number;
  createdAt: string;
}

@Entry
@Component
struct CheckinDetailPage {
  @State totalCheckins: number = 0;  // 总打卡次数
  @State checkinRecords: Array<CheckinRecordLocal> = [];  // 打卡记录列表
  @State currentPage: number = 1;  // 当前页码
  @State totalPages: number = 1;  // 总页数

  // 加载状态
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State isError: boolean = false;
  @State errorMessage: string = '';

  // 生命周期：页面显示时
  aboutToAppear() {
    console.log('打卡详情页面显示');
    this.loadCheckinData();
  }

  // 加载打卡数据（使用假数据）
  private loadCheckinData() {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    this.isError = false;

    // 模拟网络请求延迟
    setTimeout(() => {
      try {
        // 生成假数据
        this.generateMockData();

        console.log(`✅ 加载打卡数据成功，共${this.totalCheckins}条记录，当前第${this.currentPage}页`);
      } catch (error) {
        this.isError = true;
        this.errorMessage = '加载打卡数据失败';
        console.error('获取打卡数据异常:', error);
      } finally {
        this.isLoading = false;
        this.isRefreshing = false;
      }
    }, 800);
  }

  // 生成假数据
  private generateMockData() {
    const mockRecords: Array<CheckinRecordLocal> = [
      {
        checkinId: 101,
        spotId: 1,
        spotName: '古建筑群',
        images: ['https://images.unsplash.com/photo-1542728928-0013d5f8d5b5?w=800&auto=format&fit=crop'],
        pointsEarned: 50,
        createdAt: '2025-12-14 14:30:25'
      },
      {
        checkinId: 102,
        spotId: 2,
        spotName: '特色美食街',
        images: ['https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format&fit=crop'],
        pointsEarned: 30,
        createdAt: '2025-12-13 11:20:15'
      },
      {
        checkinId: 103,
        spotId: 3,
        spotName: '生态湿地公园',
        images: ['https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&auto=format&fit=crop'],
        pointsEarned: 40,
        createdAt: '2025-12-12 16:45:33'
      },
      {
        checkinId: 104,
        spotId: 4,
        spotName: '艺术画廊',
        images: ['https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=800&auto=format&fit=crop'],
        pointsEarned: 35,
        createdAt: '2025-12-11 10:15:42'
      },
      {
        checkinId: 105,
        spotId: 5,
        spotName: '儿童游乐场',
        images: ['https://images.unsplash.com/photo-1516937941344-00b4e0337589?w=800&auto=format&fit=crop'],
        pointsEarned: 25,
        createdAt: '2025-12-10 15:50:18'
      },
      {
        checkinId: 106,
        spotId: 6,
        spotName: '科技体验馆',
        images: ['https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop'],
        pointsEarned: 60,
        createdAt: '2025-12-09 13:25:59'
      },
      {
        checkinId: 107,
        spotId: 7,
        spotName: '城市公园',
        images: ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&auto=format&fit=crop'],
        pointsEarned: 20,
        createdAt: '2025-12-08 09:40:12'
      },
      {
        checkinId: 108,
        spotId: 8,
        spotName: '购物中心',
        images: ['https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&auto=format&fit=crop'],
        pointsEarned: 15,
        createdAt: '2025-12-07 18:30:27'
      },
      {
        checkinId: 109,
        spotId: 1,
        spotName: '古建筑群',
        images: ['https://images.unsplash.com/photo-1542728928-0013d5f8d5b5?w=800&auto=format&fit=crop'],
        pointsEarned: 45,
        createdAt: '2025-12-06 14:20:38'
      },
      {
        checkinId: 110,
        spotId: 2,
        spotName: '特色美食街',
        images: ['https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format&fit=crop'],
        pointsEarned: 35,
        createdAt: '2025-12-05 12:15:22'
      }
    ];

    // 根据当前页码加载数据
    const pageSize = 10;  // 每页10条
    const startIndex = (this.currentPage - 1) * pageSize;

    if (this.currentPage === 1) {
      // 第一页：显示前10条数据
      this.checkinRecords = mockRecords.slice(0, Math.min(pageSize, mockRecords.length));
    } else if (this.currentPage === 2) {
      // 第二页：显示更多假数据
      const moreMockRecords: Array<CheckinRecordLocal> = [
        {
          checkinId: 111,
          spotId: 3,
          spotName: '生态湿地公园',
          images: ['https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&auto=format&fit=crop'],
          pointsEarned: 40,
          createdAt: '2025-12-04 16:10:55'
        },
        {
          checkinId: 112,
          spotId: 4,
          spotName: '艺术画廊',
          images: ['https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=800&auto=format&fit=crop'],
          pointsEarned: 35,
          createdAt: '2025-12-03 11:45:19'
        },
        {
          checkinId: 113,
          spotId: 5,
          spotName: '儿童游乐场',
          images: ['https://images.unsplash.com/photo-1516937941344-00b4e0337589?w=800&auto=format&fit=crop'],
          pointsEarned: 25,
          createdAt: '2025-12-02 14:30:44'
        },
        {
          checkinId: 114,
          spotId: 6,
          spotName: '科技体验馆',
          images: ['https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop'],
          pointsEarned: 60,
          createdAt: '2025-12-01 10:20:33'
        }
      ];
      this.checkinRecords = [...this.checkinRecords, ...moreMockRecords];
    }

    // 更新总数
    this.totalCheckins = this.currentPage === 1 ? 24 : 14; // 模拟总数据量变化

    // 计算总页数
    this.totalPages = Math.ceil(this.totalCheckins / pageSize);
  }

  // 刷新数据
  private refreshData() {
    this.currentPage = 1;
    this.isRefreshing = true;
    this.loadCheckinData();
  }

  // 加载更多
  private loadMore() {
    if (this.isLoading || this.currentPage >= this.totalPages) {
      return;
    }

    this.currentPage += 1;
    this.isLoading = true;

    // 模拟网络请求延迟
    setTimeout(() => {
      try {
        this.generateMockData();
        console.log(`✅ 加载更多成功，当前共${this.checkinRecords.length}条记录`);
      } catch (error) {
        console.error('加载更多异常:', error);
        // 回退页码
        this.currentPage -= 1;
      } finally {
        this.isLoading = false;
      }
    }, 800);
  }

  // 格式化时间（去掉秒）
  private formatTime(createdAt: string): string {
    if (!createdAt) return '';
    // 将 "2025-01-11 14:20:33" 格式化为 "2025-01-11 14:20"
    return createdAt.substring(0, 16);
  }

  // 构建打卡卡片
  @Builder
  buildCheckinCard() {
    Column({ space: 12 }) {
      // 打卡标题
      Text('我的打卡')
        .fontSize(16)
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .width('100%')

      // 打卡数值
      Row({ space: 8 }) {
        Text(this.totalCheckins.toString())
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#34C759')

        Text('次')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 20 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // 打卡说明
      Text('打卡可以赚取积分，解锁更多旅行成就')
        .fontSize(14)
        .fontColor('#999999')
        .textAlign(TextAlign.Start)
        .width('100%')
        .margin({ top: 8 })
    }
    .padding({ left: 24, right: 24, top: 28, bottom: 28 })
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#34C75910' })
  }

  // 构建打卡记录项
  @Builder
  buildCheckinRecordItem(record: CheckinRecordLocal, index: number) {
    Column() {
      Row({ space: 16 }) {
        // 左侧：打卡图标
        Column() {
          Text('📍')
            .fontSize(20)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#34C759')
        .borderRadius(20)

        // 中间：详情
        Column({ space: 4 }) {
          // 景点名称
          Text(record.spotName || '未知景点')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .width('100%')

          // 时间和积分
          Row({ space: 12 }) {
            Text(this.formatTime(record.createdAt))
              .fontSize(13)
              .fontColor('#999999')

            Text(`+${record.pointsEarned || 0}积分`)
              .fontSize(13)
              .fontColor('#FF9500')
              .backgroundColor('#FFF4E6')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
          }
          .width('100%')
        }
        .layoutWeight(1)

        // 右侧：图片预览（如果有图片）
        if (record.images && record.images.length > 0 && record.images[0]) {
          Image(record.images[0])
            .width(40)
            .height(40)
            .objectFit(ImageFit.Cover)
            .borderRadius(8)
        } else {
          // 默认图片占位
          Column() {
            Text('📷')
              .fontSize(20)
              .fontColor('#999999')
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#F0F0F0')
          .borderRadius(8)
        }
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })

      // 分隔线（不是最后一项时显示）
      if (index < this.checkinRecords.length - 1) {
        Divider()
          .color('#F0F0F0')
          .margin({ left: 72, right: 16 })
          .strokeWidth(0.5)
      }
    }
  }

  // 构建记录列表
  @Builder
  buildRecordsList() {
    Column() {
      // 列表标题
      Row({ space: 8 }) {
        Text('打卡记录')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        if (this.totalCheckins > 0) {
          Text(`共${this.totalCheckins}次`)
            .fontSize(12)
            .fontColor('#666666')
            .backgroundColor('#F0F0F0')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(10)
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 16 })

      // 记录列表
      if (this.checkinRecords.length > 0) {
        Column({ space: 0 }) {
          ForEach(this.checkinRecords, (record: CheckinRecordLocal, index: number) => {
            this.buildCheckinRecordItem(record, index)
          })
        }
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .shadow({ radius: 4, color: '#00000008' })

        // 加载更多提示
        if (this.currentPage < this.totalPages) {
          Column() {
            if (this.isLoading) {
              LoadingProgress()
                .width(24)
                .height(24)
                .color('#007AFF')
                .margin({ bottom: 8 })

              Text('加载中...')
                .fontSize(14)
                .fontColor('#666666')
            } else {
              Text('点击加载更多')
                .fontSize(14)
                .fontColor('#007AFF')
                .padding({ top: 16, bottom: 16 })
                .onClick(() => {
                  this.loadMore();
                })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 20, bottom: 20 })
        }
      } else {
        // 空状态
        Column({ space: 16 }) {
          Text('📍')
            .fontSize(60)
            .fontColor('#34C759')

          Text('暂无打卡记录')
            .fontSize(16)
            .fontColor('#999999')

          Text('快去探索景点并打卡吧！')
            .fontSize(14)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .padding(40)
        .alignItems(HorizontalAlign.Center)
      }
    }
  }

  // 构建加载状态
  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#007AFF')

      Text('加载打卡数据中...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 构建错误状态
  @Builder
  buildErrorView() {
    Column({ space: 16 }) {
      Text('加载失败')
        .fontSize(18)
        .fontColor('#FF3B30')
        .fontWeight(FontWeight.Medium)

      Text(this.errorMessage)
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .width('80%')

      Button('重新加载')
        .backgroundColor('#007AFF')
        .fontColor(Color.White)
        .fontSize(14)
        .width(120)
        .height(36)
        .onClick(() => {
          this.refreshData();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 返回上一页
  private goBack(): void {
    router.back();
  }

  build() {
    Column() {
      // 顶部导航栏
      Row({ space: 10 }) {
        // 返回按钮
        Button('←')
          .fontSize(20)
          .backgroundColor(Color.Transparent)
          .fontColor('#333333')
          .onClick(() => this.goBack())

        // 标题
        Text('打卡详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 刷新按钮
        Button('刷新')
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .fontColor('#007AFF')
          .onClick(() => {
            this.refreshData();
          })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .width('100%')
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // 内容区域
      Scroll() {
        Column({ space: 0 }) {
          // 显示加载状态
          if (this.isLoading && !this.isRefreshing && this.checkinRecords.length === 0) {
            this.buildLoadingView()
          }
          // 显示错误状态
          else if (this.isError && this.checkinRecords.length === 0) {
            this.buildErrorView()
          }
          // 显示正常内容
          else {
            // 打卡卡片
            Column() {
              this.buildCheckinCard()
            }
            .padding({ left: 16, right: 16, top: 20, bottom: 16 })

            // 打卡记录列表
            this.buildRecordsList()

            // 底部安全区域占位
            Row()
              .height(40)
              .width('100%')
          }
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}