// entry/src/main/ets/pages/SpotsPage.ets
import { SpotCard, SpotRequest, SpotResponse, SpotDetail, getSpots, getSpotDetail } from '../api/zone';
import { SpotListResponse } from '../models/Spot';
import router from "@ohos.router"

@Entry
@Component
export default struct SpotsPage {
  // 景点列表数据
  @State spots: SpotCard[] = [
  // 临时假数据，API实现后移除
    {
      spotId: 1,
      name: '古建筑群',
      description: '保存完好的明清时期古建筑群，展示了古代建筑艺术的精髓。',
      images: [
        'https://images.unsplash.com/photo-1542728928-0013d5f8d5b5?w=800&auto=format&fit=crop'
      ],
      zoneId: 5,
      zoneName: '历史文化区',
      coverImage: 'https://images.unsplash.com/photo-1542728928-0013d5f8d5b5?w=400&auto=format&fit=crop',
      distance: 1.2,
      isRecommended: true,
      visitedCount: 1250,
      rating: 4.7
    },
    {
      spotId: 2,
      name: '科技体验馆',
      description: '前沿科技展示与互动体验，VR、AR等沉浸式体验项目。',
      images: [
        'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop'
      ],
      zoneId: 4,
      zoneName: '科技探索区',
      coverImage: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400&auto=format&fit=crop',
      distance: 2.5,
      isRecommended: true,
      visitedCount: 980,
      rating: 4.8
    },
    {
      spotId: 3,
      name: '生态湿地公园',
      description: '原生湿地生态系统，观鸟、徒步、自然教育的好去处。',
      images: [
        'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&auto=format&fit=crop'
      ],
      zoneId: 2,
      zoneName: '生态体验区',
      coverImage: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400&auto=format&fit=crop',
      distance: 3.8,
      isRecommended: false,
      visitedCount: 750,
      rating: 4.5
    },
    {
      spotId: 4,
      name: '艺术画廊',
      description: '当代艺术展览空间，定期举办国内外艺术家作品展。',
      images: [
        'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=800&auto=format&fit=crop'
      ],
      zoneId: 3,
      zoneName: '艺术创意区',
      coverImage: 'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=400&auto=format&fit=crop',
      distance: 0.8,
      isRecommended: true,
      visitedCount: 890,
      rating: 4.6
    },
    {
      spotId: 5,
      name: '儿童游乐场',
      description: '适合家庭游玩的亲子游乐设施，安全有趣的儿童活动空间。',
      images: [
        'https://images.unsplash.com/photo-1516937941344-00b4e0337589?w=800&auto=format&fit=crop'
      ],
      zoneId: 6,
      zoneName: '休闲娱乐区',
      coverImage: 'https://images.unsplash.com/photo-1516937941344-00b4e0337589?w=400&auto=format&fit=crop',
      distance: 1.5,
      isRecommended: false,
      visitedCount: 1200,
      rating: 4.4
    },
    {
      spotId: 6,
      name: '特色美食街',
      description: '汇聚各地特色小吃和传统美食，体验地道风味。',
      images: [
        'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format&fit=crop'
      ],
      zoneId: 6,
      zoneName: '休闲娱乐区',
      coverImage: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&auto=format&fit=crop',
      distance: 1.0,
      isRecommended: true,
      visitedCount: 1800,
      rating: 4.9
    }
  ];

  // 加载状态
  @State isLoading: boolean = false;

  // 错误信息
  @State errorMessage: string = '';

  // 搜索关键词
  @State searchText: string = '';

  // 当前选中的筛选标签
  @State selectedTag: string = '全部';

  // 筛选标签列表
  @State tags: string[] = ['全部', '推荐', '附近', '热门', '免费', '亲子', '拍照'];

  // 排序方式
  @State sortBy: string = '推荐';

  build() {
    Column() {
      // 1. 顶部标题和搜索栏
      this.buildHeader()

      // 2. 筛选和排序栏
      this.buildFilterSortBar()

      // 3. 内容区域
      Column() {
        this.buildSpotsList()
      }
      .width('100%')
      .flexGrow(1)
      .margin({ bottom: 60 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }

  // ==================== 顶部标题和搜索栏 ====================

  @Builder
  buildHeader() {
    Column({ space: 15 }) {
      // 标题
      Row() {
        Text('景点探索')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)

        // 筛选按钮
        Button('筛选', { type: ButtonType.Normal })
          .fontSize(14)
          .fontColor('#007AFF')
          .backgroundColor('#007AFF10')
          .height(36)
          .borderRadius(18)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            console.log('点击筛选按钮');
            // TODO: 打开筛选面板
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 15 })

      // 搜索框
      Row({ space: 10 }) {
        // 搜索图标
        Text('🔍')
          .fontSize(18)
          .margin({ left: 15 })

        // 搜索输入框
        TextInput({ placeholder: '搜索景点、关键词...' })
          .placeholderColor('#999999')
          .fontSize(16)
          .width('100%')
          .height(48)
          .backgroundColor(Color.White)
          .caretColor('#007AFF')
          .onChange((value: string) => {
            this.searchText = value;
            console.log('搜索关键词:', value);
          })

        // 清除按钮
        if (this.searchText.length > 0) {
          Button('取消')
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor(Color.Transparent)
            .height(36)
            .margin({ right: 10 })
            .onClick(() => {
              this.searchText = '';
            })
        }
      }
      .width('90%')
      .height(52)
      .backgroundColor(Color.White)
      .borderRadius(26)
      .shadow({ radius: 6, color: '#00000010' })
      .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding({ bottom: 15 })
    .shadow({ radius: 2, color: '#00000008' })
  }

  // ==================== 筛选和排序栏 ====================

  @Builder
  buildFilterSortBar() {
    Column() {
      // 筛选标签
      Scroll() {
        Row({ space: 10 }) {
          ForEach(this.tags, (tag: string) => {
            this.buildTagItem(tag)
          })
        }
        .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .backgroundColor(Color.White)
      .width('100%')
      .height(50)

      // 排序栏
      Row({ space: 15 }) {
        Text('排序：')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 20 })

        ForEach(['推荐', '距离', '热度', '评分'], (sortOption: string) => {
          Button(sortOption)
            .fontSize(14)
            .fontColor(this.sortBy === sortOption ? '#007AFF' : '#666666')
            .backgroundColor(this.sortBy === sortOption ? '#007AFF10' : '#F5F7FA')
            .height(32)
            .borderRadius(16)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.sortBy = sortOption;
              console.log('选择排序方式:', sortOption);
              this.sortSpots();
            })
        })
          //.layoutWeight(1)
      }
      .width('100%')
      .height(44)
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor(Color.White)
  }

  // 构建标签项目
  @Builder
  buildTagItem(tag: string) {
    Button(tag)
      .fontSize(14)
      .fontColor(this.selectedTag === tag ? Color.White : '#666666')
      .backgroundColor(this.selectedTag === tag ? '#007AFF' : '#F5F7FA')
      .height(32)
      .borderRadius(16)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.selectedTag = tag;
        console.log('选择标签:', tag);
        this.filterSpots();
      })
  }

  // ==================== 景点列表 ====================

  @Builder
  buildSpotsList() {
    Scroll() {
      Column({ space: 15 }) {
        ForEach(this.spots, (spot: SpotCard) => {
          this.buildSpotCard(spot)
        })
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 15, bottom: 180 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  buildSpotCard(spot: SpotCard) {
    Column({ space: 0 }) {
      // 卡片顶部 - 图片区域
      Stack() {
        // 背景图片
        Image(spot.coverImage || spot.images[0] || '')
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 图片遮罩渐变
        Column()
          .width('100%')
          .height(60)
          //.backgroundImage($r('app.media.image_gradient'), ImageRepeat.NoRepeat)
          .backgroundImageSize(ImageSize.Cover)
          .position({ x: 0, y: 120 })

        // 推荐标签
        if (spot.isRecommended) {
          Row({ space: 3 }) {
            Text('🔥')
              .fontSize(12)
            Text('推荐')
              .fontSize(12)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
          }
          .padding({ left: 8, right: 8 })
          .height(24)
          .backgroundColor('#FF3B30')
          .borderRadius(12)
          .position({ x: 15, y: 15 })
        }

        // 所属区域标签
        Row({ space: 3 }) {
          Text('📍')
            .fontSize(12)
          Text(spot.zoneName || '未分类')
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: 8, right: 8 })
        .height(24)
        .backgroundColor('#00000080')
        .borderRadius(12)
        .position({ x: 15, y: 145 })

        // 右上角评分
        Row({ space: 3 }) {
          Text('⭐')
            .fontSize(12)
          Text(spot.rating?.toFixed(1) || '4.5')
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: 8, right: 8 })
        .height(24)
        .backgroundColor('#00000080')
        .borderRadius(12)
        .position({ x: '85%', y: 15 })
      }
      .width('100%')
      .height(180)

      // 卡片内容区域
      Column({ space: 8 }) {
        // 景点名称和距离
        Row() {
          Text(spot.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (spot.distance) {
            Row({ space: 2 }) {
              Text('📏')
                .fontSize(12)
              Text(`${spot.distance}km`)
                .fontSize(12)
                .fontColor('#666666')
            }
            .padding({ left: 8, right: 8 })
            .height(24)
            .backgroundColor('#F5F7FA')
            .borderRadius(12)
          }
        }
        .width('100%')

        // 景点描述
        Text(spot.description)
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        // 底部信息栏
        Row() {
          // 打卡人数
          Row({ space: 3 }) {
            Text('👥')
              .fontSize(12)
            Text(`${spot.visitedCount || 0}人打卡`)
              .fontSize(12)
              .fontColor('#666666')
          }
          .layoutWeight(1)

          // 操作按钮组
          Row({ space: 10 }) {
            // 收藏按钮
            Button('❤️ 收藏')
              .fontSize(12)
              .fontColor('#FF3B30')
              .backgroundColor('#FF3B3010')
              .height(28)
              .borderRadius(14)
              .padding({ left: 10, right: 10 })
              .onClick(() => {
                this.onCollectSpot(spot);
              })

            // 打卡按钮
            Button('📍 打卡')
              .fontSize(12)
              .fontColor(Color.White)
              .backgroundColor('#007AFF')
              .height(28)
              .borderRadius(14)
              .padding({ left: 10, right: 10 })
              .onClick(() => {
                this.onCheckInSpot(spot);
              })
          }
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .padding({ left: 15, right: 15, top: 15, bottom: 15 })
      .backgroundColor(Color.White)
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 6, color: '#0000000D' })
    .onClick(() => {
      this.onSpotCardClick(spot);
    })
  }

  // ==================== 交互方法 ====================

  // 点击景点卡片
  private onSpotCardClick(spot: SpotCard) {
    console.log('点击景点:', spot.name);
    // TODO: 跳转到景点详情页
    router.pushUrl({
      url: 'pages/SpotDetailPage',
      params: { spotId: spot.spotId }
    }).then(() => {
      console.log('跳转成功');
    }).catch(() => {
      console.error('跳转失败');
    });
  }

  // 收藏景点
  private onCollectSpot(spot: SpotCard) {
    console.log('收藏景点:', spot.spotId, spot.name);
    // TODO: 调用收藏API
  }

  // 打卡景点
  private onCheckInSpot(spot: SpotCard) {
    console.log('打卡景点:', spot.spotId, spot.name);
    // TODO: 跳转到打卡页面或调用打卡API
  }

  // 筛选景点
  private filterSpots() {
    console.log('筛选景点，标签:', this.selectedTag);
    // TODO: 根据标签筛选景点
  }

  // 排序景点
  private sortSpots() {
    console.log('排序景点，方式:', this.sortBy);
    // TODO: 根据排序方式排序景点
  }

  // ==================== 生命周期方法 ====================

  // 相当于Vue的onMounted
  aboutToAppear() {
    console.log('景点页面显示，开始加载数据...');

    // 这里调用API获取景点数据
    this.loadSpotsData();
  }

  // 加载景点数据
  private loadSpotsData() {
    console.log('开始加载景点数据...');

    // TODO: 调用API获取景点数据
    // 示例代码：
    // try {
    //   this.isLoading = true;
    //   const spots = await fetchSpots(); // 你的API方法
    //   this.spots = spots;
    // } catch (error) {
    //   console.error('加载景点数据失败:', error);
    //   this.errorMessage = '加载数据失败';
    // } finally {
    //   this.isLoading = false;
    // }
    const data:SpotRequest = {

    }
    getSpots(data);
    // 暂时使用假数据
    this.isLoading = false;
  }

  // ==================== 状态视图 ====================

  // 如果需要，可以添加加载中、错误、空状态视图
  // 参考ZonesPage的实现
}