// entry/src/main/ets/pages/SpotDetailPage.ets
import router from '@ohos.router';
import { getSpotDetail, SpotDetail } from '../api/zone';

// 正确的假数据 - 基于 SpotDetail 接口
const mockSpotDetail: SpotDetail = {
  spotId: 101,
  name: '瀑布观景台',
  images: [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800&auto=format&fit=crop'
  ],
  video: 'https://example.com/spot101_video.mp4',
  description: '瀑布观景台是园区最壮观的自然景点之一，瀑布从百米高空倾泻而下，气势磅礴。清晨时分，阳光透过水雾形成美丽的彩虹，是摄影爱好者的绝佳取景地。观景台设有安全护栏和多处观景平台，游客可以近距离感受瀑布的震撼力。\n\n建议游玩时间：1-2小时\n最佳观赏时间：早晨或傍晚\n注意事项：瀑布区域湿滑，请注意安全',
  zoneId: 1,
  latitude: 23.334450,
  longitude: 113.334001,
  openTime: '08:00-18:00（夏季延时至19:00）'
};

interface RouterParam {
  spotId: number;
}

@Entry
@Component
export default struct SpotDetailPage {
  // 路由参数
  @State spotId: number = 0;

  // 景点详情数据
  @State spotDetail: SpotDetail = mockSpotDetail;

  // 加载状态
  @State isLoading: boolean = false;

  // 轮播图当前索引
  @State currentImageIndex: number = 0;

  // 是否展开详情
  @State isDescriptionExpanded: boolean = false;

  // 页面构建
  build() {
    Column() {
      // 1. 顶部导航栏
      this.buildNavigationBar()

      // 2. 可滚动内容区域
      Scroll() {
        Column() {
          // 所有内容卡片
          this.buildImageCarousel()
          this.buildBasicInfoCard()
          this.buildDescriptionCard()
          this.buildPracticalInfoCard()
          this.buildLocationCard()

          // 底部间距
          Row()
            .height(80)
            .width('100%')
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 3. 底部操作栏
      this.buildBottomActionBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  // ==================== 顶部导航栏 ====================
  @Builder
  buildNavigationBar() {
    Row({ space: 10 }) {
      // 返回按钮
      Button('←')
        .fontSize(20)
        .fontColor('#1A1A1A')
        .backgroundColor(Color.Transparent)
        .width(40)
        .height(40)
        .onClick(() => {
          router.back();
        })

      // 标题
      Text('景点详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .layoutWeight(1)
    }
    .width('100%')
    .height(60)
    .backgroundColor(Color.White)
    .padding({ left: 15, right: 15 })
    .shadow({ radius: 2, color: '#00000008' })
  }

  // ==================== 轮播图 ====================
  @Builder
  buildImageCarousel() {
    Stack() {
      // 图片轮播
      Swiper() {
        ForEach(this.spotDetail.images, (image: string, index: number) => {
          Image(image)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
        })
      }
      .loop(true)
      .autoPlay(true)
      .interval(3000)
      .duration(500)
      .width('100%')
      .height(300)
      .onChange((index: number) => {
        this.currentImageIndex = index;
      })

      // 图片指示器
      Row({ space: 6 }) {
        ForEach(this.spotDetail.images, (_: string, index: number) => {
          Column()
            .width(8)
            .height(8)
            .backgroundColor(index === this.currentImageIndex ? Color.White : '#FFFFFF80')
            .borderRadius(4)
        })
      }
      .margin({ bottom: 15 })
      .align(Alignment.Bottom)

      // 图片计数器
      Text(`${this.currentImageIndex + 1}/${this.spotDetail.images.length}`)
        .fontSize(12)
        .fontColor(Color.White)
        .backgroundColor('#00000080')
        .borderRadius(10)
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .margin({ right: 15, bottom: 15 })
        .align(Alignment.BottomEnd)
    }
    .width('100%')
    .height(300)
  }

  // ==================== 基本信息卡片 ====================
  @Builder
  buildBasicInfoCard() {
    Column({ space: 12 }) {
      // 景点名称
      Text(this.spotDetail.name)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')

      // 所属区域
      Row({ space: 5 }) {
        Text(`区域 ${this.spotDetail.zoneId}`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // 开放时间
      Row({ space: 5 }) {
        Text(this.spotDetail.openTime)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .margin({ top: -20 })
    .alignSelf(ItemAlign.Center)
    .shadow({ radius: 8, color: '#0000000D' })
  }

  // ==================== 详情描述卡片 ====================
  @Builder
  buildDescriptionCard() {
    Column({ space: 15 }) {
      // 标题
      Text('景点介绍')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')

      // 描述内容
      Text(this.spotDetail.description)
        .fontSize(15)
        .fontColor('#666666')
        .lineHeight(22)
        .textAlign(TextAlign.Start)
        .maxLines(this.isDescriptionExpanded ? undefined : 4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      // 展开/收起按钮
      if (this.spotDetail.description.length > 200) {
        Button(this.isDescriptionExpanded ? '收起' : '展开更多')
          .fontSize(14)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.isDescriptionExpanded = !this.isDescriptionExpanded;
          })
          .alignSelf(ItemAlign.Start)
      }
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .margin({ top: 15 })
    .alignSelf(ItemAlign.Center)
    .shadow({ radius: 8, color: '#0000000D' })
  }

  // ==================== 实用信息卡片 ====================
  @Builder
  buildPracticalInfoCard() {
    Column({ space: 12 }) {
      // 标题
      Text('实用信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')

      // 信息列表
      Column({ space: 10 }) {
        // 图片数量
        Row() {
          Text('图片数量')
            .fontSize(15)
            .fontColor('#666666')
            .layoutWeight(1)
          Text(`${this.spotDetail.images.length}张`)
            .fontSize(15)
            .fontColor('#1A1A1A')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        // 视频资源
        Row() {
          Text('视频资源')
            .fontSize(15)
            .fontColor('#666666')
            .layoutWeight(1)
          Text(this.spotDetail.video ? '有' : '无')
            .fontSize(15)
            .fontColor(this.spotDetail.video ? '#34C759' : '#666666')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
      }
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .margin({ top: 15 })
    .alignSelf(ItemAlign.Center)
    .shadow({ radius: 8, color: '#0000000D' })
  }

  // ==================== 位置信息卡片 ====================
  @Builder
  buildLocationCard() {
    Column({ space: 12 }) {
      // 标题
      Text('地理位置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')

      // 坐标信息
      Column({ space: 8 }) {
        Row() {
          Text('纬度')
            .fontSize(14)
            .fontColor('#666666')
            .layoutWeight(1)
          Text(this.spotDetail.latitude.toFixed(6))
            .fontSize(14)
            .fontColor('#1A1A1A')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        Row() {
          Text('经度')
            .fontSize(14)
            .fontColor('#666666')
            .layoutWeight(1)
          Text(this.spotDetail.longitude.toFixed(6))
            .fontSize(14)
            .fontColor('#1A1A1A')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
      }
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .margin({ top: 15 })
    .alignSelf(ItemAlign.Center)
    .shadow({ radius: 8, color: '#0000000D' })
  }

  // ==================== 底部操作栏 ====================
  @Builder
  buildBottomActionBar() {
    Column() {
      // 打卡按钮
      Button('立即打卡')
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor('#007AFF')
        .height(56)
        .borderRadius(28)
        .width('90%')
        .onClick(() => {
          this.onCheckIn();
        })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .shadow({ radius: 10, color: '#0000001A', offsetY: -3 })
    .padding({ top: 15, bottom: 30 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // ==================== 交互方法 ====================

  // 立即打卡
  private onCheckIn() {
    console.log('打卡景点:', this.spotDetail.name);
    // 跳转到打卡页面，传递景点ID
    router.pushUrl({
      url: "pages/CheckInSpotsPage",
      params: {
        spotId: this.spotDetail.spotId,
        spotName: this.spotDetail.name
      }
    });
  }

  // ==================== 生命周期方法 ====================

  aboutToAppear() {
    console.log('景点详情页面显示');

    // 获取路由参数
    const params = router.getParams() as RouterParam;
    if (params?.spotId) {
      this.spotId = params.spotId;
      console.log('接收到的spotId:', this.spotId);

      // 加载景点详情数据
      this.loadSpotDetail();
    } else {
      console.warn('未接收到spotId参数，使用默认数据');
      // 如果没有参数，使用假数据
      this.loadMockData();
    }
  }

  // 加载景点详情数据
  private async loadSpotDetail() {
    console.log('开始加载景点详情，ID:', this.spotId);
    this.isLoading = true;

    try {
      const result = await getSpotDetail(this.spotId);
      if (result) {
        this.spotDetail = result;
        console.log('景点详情加载成功:', result.name);
      } else {
        // 如果API返回空，使用假数据
        console.log('API返回空数据，使用假数据');
        this.loadMockData();
      }
    } catch (error) {
      console.error('加载景点详情失败:', error);
      // 使用假数据
      this.loadMockData();
    } finally {
      this.isLoading = false;
    }
  }

  // 加载假数据
  private loadMockData() {
    console.log('加载假数据');
    this.spotDetail = {
      spotId: this.spotId || 101,
      name: mockSpotDetail.name,
      images: [...mockSpotDetail.images], // 复制数组
      video: mockSpotDetail.video,
      description: mockSpotDetail.description,
      zoneId: mockSpotDetail.zoneId,
      latitude: mockSpotDetail.latitude,
      longitude: mockSpotDetail.longitude,
      openTime: mockSpotDetail.openTime
    };
    this.isLoading = false;
  }

  aboutToDisappear() {
    console.log('景点详情页面即将消失');
    // 清理资源
  }
}