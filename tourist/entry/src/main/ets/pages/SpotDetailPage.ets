import { getSpotDetail, SpotDetail} from '../api/zone';

// entry/src/main/ets/pages/SpotDetailPage.ets
import router from '@ohos.router';

// 假数据 - 根据你的文档字段
const mockSpotDetail : SpotDetail = {
  spotId: 101,
  name: '瀑布观景台',
  images: [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800&auto=format&fit=crop'
  ],
  video: 'https://example.com/spot101_video.mp4',
  description: '瀑布观景台是园区最壮观的自然景点之一，瀑布从百米高空倾泻而下，气势磅礴。清晨时分，阳光透过水雾形成美丽的彩虹，是摄影爱好者的绝佳取景地。观景台设有安全护栏和多处观景平台，游客可以近距离感受瀑布的震撼力。',
  zoneId: 1,
  latitude: 23.334450,
  longitude: 113.334001,
  openTime: '08:00-18:00',
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

  // 是否收藏
  @State isCollected: boolean = false;

  // 页面构建
  build() {
    Column() {
      // 1. 顶部导航栏
      this.buildNavigationBar()

      // 2. 可滚动内容区域 - 使用flexGrow占据剩余空间
      Scroll() {
        Column() {
          // 所有内容卡片
          this.buildImageCarousel()
          this.buildBasicInfoCard()
          this.buildDescriptionCard()
          this.buildPracticalInfoCard()
          this.buildLocationCard()
          this.buildTipsCard()

          // 底部间距，为固定按钮留出空间
          Row()
            .height(80) // 这个高度要大于底部按钮的高度
            .width('100%')
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1) // 关键：使用layoutWeight而不是flexGrow
      .scrollBar(BarState.Off)

      // 3. 底部操作栏 - 固定高度，不会被挤压
      //this.buildBottomActionBar()
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

      // 分享按钮
      Button('分享')
        .fontSize(14)
        .fontColor('#007AFF')
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.onShare();
        })
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
      // 图片轮播 - 使用Swiper组件
      Swiper() {
        // 直接使用多个Image作为SwiperItem
        Image(this.spotDetail.images[0] || '')
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)

        Image(this.spotDetail.images[1] || '')
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)

        Image(this.spotDetail.images[2] || '')
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
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


    }
    .width('100%')
    .height(300)
  }
  // 轮播图指示器
  @Builder
  buildCarouselIndicator() {
    // 使用默认指示器
  }

  // ==================== 基本信息卡片 ====================
  @Builder
  buildBasicInfoCard() {
    Column({ space: 12 }) {
      // 景点名称和收藏按钮
      Row() {
        Text(this.spotDetail.name)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)

        // 收藏按钮
        Button(this.isCollected ? '❤️ 已收藏' : '🤍 收藏')
          .fontSize(14)
          .fontColor(this.isCollected ? '#FF3B30' : '#666666')
          .backgroundColor(this.isCollected ? '#FF3B3010' : '#F5F7FA')
          .height(32)
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.onToggleCollect();
          })
      }
      .width('100%')

      // 评分和开放时间
      Row({ space: 15 }) {
        // 评分
        Row({ space: 5 }) {
          Text('⭐')
            .fontSize(16)
          Text('4.8')
            .fontSize(16)
            .fontColor('#1A1A1A')
            .fontWeight(FontWeight.Medium)
        }

        // 分割线
        Text('|')
          .fontSize(16)
          .fontColor('#E0E0E0')

        // 开放时间
        Row({ space: 5 }) {
          Text('🕐')
            .fontSize(16)
          Text(this.spotDetail.openTime)
            .fontSize(16)
            .fontColor('#1A1A1A')
        }

        // 分割线
        Text('|')
          .fontSize(16)
          .fontColor('#E0E0E0')


      }
      .width('100%')
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
      Row() {
        Text('景点介绍')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        if (this.spotDetail.video) {
          Button('观看视频 →')
            .fontSize(14)
            .fontColor('#007AFF')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.onPlayVideo();
            })
            .margin({ left: 10 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

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


        // 详细地址
        Row() {
          Text('📍')
            .fontSize(16)
            .margin({ right: 10 })
          Text('详细地址')
            .fontSize(15)
            .fontColor('#666666')
            .layoutWeight(1)
          Text('暂无')
            .fontSize(15)
            .fontColor('#1A1A1A')
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
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
      Row() {
        Text('地理位置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)

        Button('查看地图 →')
          .fontSize(14)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.onViewMap();
          })
      }
      .width('100%')


      // 坐标信息
      Text(`经纬度：${this.spotDetail.latitude.toFixed(6)}, ${this.spotDetail.longitude.toFixed(6)}`)
        .fontSize(14)
        .fontColor('#666666')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 8 })
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .margin({ top: 15 })
    .alignSelf(ItemAlign.Center)
    .shadow({ radius: 8, color: '#0000000D' })
  }

  // ==================== 游玩提示卡片 ====================
  @Builder
  buildTipsCard() {
    Column({ space: 12 }) {
      // 标题
      Text('游玩提示')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')


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
      // 按钮容器
      Row({ space: 10 }) {
        // 导航按钮
        Button('导航前往')
          .fontSize(16)
          .fontColor('#007AFF')
          .backgroundColor('#007AFF10')
          .height(50)
          .borderRadius(25)
          .layoutWeight(1)
          .onClick(() => {
            this.onNavigate();
          })

        // 打卡按钮
        Button('立即打卡')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#007AFF')
          .height(50)
          .borderRadius(25)
          .layoutWeight(1)
          .onClick(() => {
            this.onCheckIn();
          })
      }
      .width('100%')
      .padding({ left: 15, right: 15 })
    }
    .width('100%')
    .height(70) // 固定高度
    .backgroundColor(Color.White)
    .shadow({ radius: 10, color: '#0000001A', offsetY: -3 })
    .padding({ top: 10, bottom: 10 })
  }

  // ==================== 交互方法 ====================

  // 分享
  private onShare() {
    console.log('分享景点:', this.spotDetail.name);
    // TODO: 实现分享功能
  }

  // 切换收藏
  private onToggleCollect() {
    this.isCollected = !this.isCollected;
    console.log(this.isCollected ? '已收藏' : '取消收藏', this.spotDetail.name);
    // TODO: 调用收藏API
  }

  // 播放视频
  private onPlayVideo() {
    console.log('播放视频:', this.spotDetail.video);
    // TODO: 播放视频
  }

  // 查看地图
  private onViewMap() {
    console.log('查看地图，坐标:', this.spotDetail.latitude, this.spotDetail.longitude);
    // TODO: 跳转到地图页面
  }

  // 导航前往
  private onNavigate() {
    console.log('导航前往:', this.spotDetail.name);
    // TODO: 打开地图导航
  }

  // 立即打卡
  private onCheckIn() {
    console.log('打卡景点:', this.spotDetail.name);
    // TODO: 跳转到打卡页面
  }

  // ==================== 生命周期方法 ====================

  aboutToAppear() {
    console.log('景点详情页面显示');

    // 获取路由参数
    const params = router.getParams() as RouterParam;
    if (params?.spotId) {
      this.spotId = params.spotId;
      console.log('接收到的spotId:', this.spotId);

      // TODO: 根据spotId调用API获取景点详情
      this.loadSpotDetail();
    } else {
      console.warn('未接收到spotId参数，使用默认数据');
      // 如果没有参数，使用假数据
      this.loadMockData();
    }
  }

  // 加载景点详情数据
  private loadSpotDetail() {
    console.log('开始加载景点详情，ID:', this.spotId);

    //getSpotDetail(this.spotId)

    // 暂时使用假数据
    this.loadMockData();
  }

  // 加载假数据
  private loadMockData() {
    console.log('加载假数据');
    this.isLoading = false;
    // 假数据已经在初始化时设置了
  }

  aboutToDisappear() {
    console.log('景点详情页面即将消失');
    // 清理资源
  }
}