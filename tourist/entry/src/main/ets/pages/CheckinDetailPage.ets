// entry/src/main/ets/pages/CheckinDetailPage.ets

import { router } from '@kit.ArkUI';
import { getCheckins, CheckinsApiResponse } from '../api/profile';

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
  @State apiFailed: boolean = false; // API调用失败标记

  // 生命周期：页面显示时
  aboutToAppear() {
    console.log('打卡详情页面显示');
    this.loadCheckinData();
  }

  // 加载打卡数据（优先调用接口）
  private async loadCheckinData() {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    this.isError = false;
    this.apiFailed = false;

    console.log('开始加载打卡数据...');

    try {
      // 先尝试调用接口获取数据
      const response = await getCheckins(this.currentPage);

      // 先进行类型断言，确保response是CheckinsApiResponse类型
      const typedResponse = response as CheckinsApiResponse;

      // 检查响应是否有效
      if (typedResponse && typedResponse.code === 200 && typedResponse.data) {
        console.log('✅ 打卡接口调用成功，获取到', typedResponse.data.list.length, '条记录');
        this.processApiData(typedResponse);
        this.isLoading = false;
        this.isRefreshing = false;
        return;
      }

      // 接口调用失败的情况
      console.warn('打卡接口返回数据异常，使用假数据');
      this.apiFailed = true;

      // 检查是否有错误消息
      if (typedResponse && typedResponse.msg) {
        this.errorMessage = typedResponse.msg;
      } else {
        this.errorMessage = '接口返回数据异常';
      }

    } catch (error) {
      console.error('打卡接口调用失败:', error);
      this.apiFailed = true;
      this.errorMessage = '网络请求失败，请检查网络连接';
    }

    // 如果接口调用失败，使用假数据
    console.log('使用假数据');
    this.useMockData();
  }

  // 处理API返回的数据
  private processApiData(response: CheckinsApiResponse) {
    if (!response.data || !response.data.list) {
      console.warn('API返回数据为空');
      return;
    }

    const apiItems = response.data.list;
    console.log('处理API打卡数据:', apiItems);

    // 将API数据转换为页面需要的数据格式
    const convertedRecords: CheckinRecordLocal[] = apiItems.map((item, index) => {
      // 明确创建符合 CheckinRecordLocal 接口的对象
      const record: CheckinRecordLocal = {
        checkinId: item.checkinId || (index + 101),
        spotId: item.spotId || index + 1,
        spotName: item.spotName || `景点${index + 1}`,
        images: item.images || [],
        pointsEarned: item.pointsEarned || Math.floor(Math.random() * 50) + 10,
        createdAt: item.createdAt || this.generateMockTime(index)
      };

      return record;
    });

    // 如果是第一页，直接设置数据
    if (this.currentPage === 1) {
      this.checkinRecords = convertedRecords;
    } else {
      // 否则追加数据
      this.checkinRecords = [...this.checkinRecords, ...convertedRecords];
    }

    // 更新总数和页数
    this.totalCheckins = response.data.total || convertedRecords.length;
    const pageSize = 10; // 每页10条
    this.totalPages = Math.ceil(this.totalCheckins / pageSize);

    console.log('数据转换完成，共', this.checkinRecords.length, '条记录，总', this.totalCheckins, '次');
  }

  // 生成模拟时间
  private generateMockTime(index: number): string {
    const now = new Date();
    const daysAgo = Math.floor(index / 2); // 每两条记录间隔一天
    const date = new Date(now.getTime() - daysAgo * 24 * 60 * 60 * 1000);

    const hours = 9 + (index % 8); // 9点到17点之间
    const minutes = (index * 7) % 60;
    const seconds = (index * 11) % 60;

    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  // 使用假数据
  private useMockData() {
    // 模拟网络请求延迟
    setTimeout(() => {
      try {
        // 生成假数据
        this.generateMockData();
        console.log(`✅ 使用假数据加载成功，共${this.totalCheckins}条记录，当前第${this.currentPage}页`);
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

  // 生成假数据（保留原有的假数据生成逻辑）
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
  private async loadMore() {
    if (this.isLoading || this.currentPage >= this.totalPages) {
      return;
    }

    this.currentPage += 1;
    this.isLoading = true;

    // 如果API之前失败了，直接使用假数据
    if (this.apiFailed) {
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
      return;
    }

    // 否则尝试调用API
    try {
      const response = await getCheckins(this.currentPage);

      // 使用类型断言
      const typedResponse = response as CheckinsApiResponse;

      // 使用类型检查
      if (typedResponse && typedResponse.code === 200 && typedResponse.data) {
        console.log('✅ 加载更多接口调用成功');
        this.processApiData(typedResponse);
      } else {
        console.warn('加载更多接口调用失败，使用本地数据');
        this.generateMockData();
      }
    } catch (error) {
      console.error('加载更多接口调用异常:', error);
      // 回退页码
      this.currentPage -= 1;
    } finally {
      this.isLoading = false;
    }
  }

  // 构建API失败提示
  @Builder
  buildApiFailNotice() {
    if (this.apiFailed && !this.isLoading) {
      Row({ space: 8 }) {
        Text('⚠️')
          .fontSize(14)
          .fontColor('#FF9500')

        Text('接口调用失败，已显示模拟数据')
          .fontSize(12)
          .fontColor('#666666')
          .layoutWeight(1)

        Button('重试')
          .fontSize(12)
          .backgroundColor('#007AFF10')
          .borderRadius(8)
          .padding({ left: 8, right: 8 })
          .height(24)
          .onClick(() => {
            console.log('点击重试接口');
            this.refreshData();
          })
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#FFF8E6')
      .borderRadius(8)
      .margin({ left: 16, right: 16, top: 8 })
      .shadow({ radius: 2, color: '#00000004' })
    }
  }

  // 格式化时间（去掉秒）
  private formatTime(createdAt: string): string {
    if (!createdAt) return '';
    // 将 "2025-01-11 14:20:33" 格式化为 "2025-01-11 14:20"
    if (createdAt.length >= 16) {
      return createdAt.substring(0, 16);
    }
    return createdAt;
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
      // API失败提示
      this.buildApiFailNotice()

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