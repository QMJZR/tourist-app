// entry/src/main/ets/pages/SpotListPage.ets
import router from '@ohos.router';
import { getSpots, SpotListItem, PageResponse, SpotRequest } from '../api/zone';

// 正确的假数据 - 基于 SpotListItem 接口（注意：total 不在列表项中）
const mockSpotItems: SpotListItem[] = [
  {
    spotId: 101,
    name: '瀑布观景台',
    thumbnail: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&auto=format&fit=crop',
    summary: '园区最壮观的自然景点之一，瀑布从百米高空倾泻而下，气势磅礴。',
    zoneId: 1,
    distance: 85
  },
  {
    spotId: 102,
    name: '湖畔栈道',
    thumbnail: 'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=300&auto=format&fit=crop',
    summary: '沿着湖岸修建的木栈道，清晨和傍晚是最佳观赏时间。',
    zoneId: 1,
    distance: 320
  },
  {
    spotId: 103,
    name: '文化展览馆',
    thumbnail: 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=300&auto=format&fit=crop',
    summary: '展示本地历史文化和传统工艺，体验传统文化的魅力。',
    zoneId: 2,
    distance: 560
  },
  {
    spotId: 104,
    name: '花园广场',
    thumbnail: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=300&auto=format&fit=crop',
    summary: '四季花开的花园广场，适合拍照和放松心情。',
    zoneId: 3,
    distance: 1200
  },
  {
    spotId: 105,
    name: '山间步道',
    thumbnail: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300&auto=format&fit=crop',
    summary: '穿越森林的登山步道，沿途有多种珍稀植物。',
    zoneId: 4,
    distance: 1850
  }
];

// 分页假数据
const mockSpotPageResponse: PageResponse<SpotListItem> = {
  list: mockSpotItems,
  page: 1,
  pageSize: 10,
  total: 156
};

@Entry
@Component
export default struct SpotListPage {
  // 景点列表数据
  @State spotItems: SpotListItem[] = [];

  // 分页信息
  @State pageInfo: PageResponse<SpotListItem> | null = null;

  // 加载状态
  @State isLoading: boolean = true;

  // 筛选条件
  @State selectedZoneId?: number = undefined;
  @State searchKeyword: string = '';

  // 当前页码
  @State currentPage: number = 1;

  get totalPages(): number {
    if (this.pageInfo) {
      return Math.ceil(this.pageInfo.total / this.pageInfo.pageSize);
    }
    return 1;
  }

  // 页面构建
  build() {
    Column() {
      // 顶部导航栏
      this.buildNavigationBar()

      // 搜索和筛选栏
      this.buildFilterBar()

      // 内容区域
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.spotItems.length === 0) {
        this.buildEmptyView()
      } else {
        this.buildSpotsList()
      }

      // 分页控件
      if (this.pageInfo && this.pageInfo.total > this.pageInfo.pageSize) {
        this.buildPagination()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .padding({ bottom: 100 })
  }

  // ==================== 顶部导航栏 ====================
  @Builder
  buildNavigationBar() {
    Column() {
      Row({ space: 10 }) {
        // 标题
        Text('景点列表')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .layoutWeight(1)

        // 刷新按钮
        Button('刷新')
          .fontSize(14)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.loadSpots();
          })
      }
      .width('100%')
      .height(60)
      .padding({ left: 15, right: 15 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .shadow({ radius: 2, color: '#00000008' })
  }

  // ==================== 筛选栏 ====================
  @Builder
  buildFilterBar() {
    Column() {
      // 搜索框
      Row({ space: 10 }) {
        TextInput({ text: this.searchKeyword, placeholder: '搜索景点名称或描述' })
          .placeholderColor('#999999')
          .caretColor('#007AFF')
          .fontColor('#333333')
          .fontSize(14)
          .height(40)
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#E0E0E0' })
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchKeyword = value;
          })

        Button('搜索')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#007AFF')
          .height(40)
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.currentPage = 1; // 搜索时重置到第一页
            this.loadSpots();
          })
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })

      // 统计信息
      if (this.pageInfo) {
        Row() {
          Text(`共 ${this.pageInfo.total} 个景点，第 ${this.pageInfo.page}/${Math.ceil(this.pageInfo.total / this.pageInfo.pageSize)} 页`)
            .fontSize(12)
            .fontColor('#666666')
            .layoutWeight(1)

          if (this.selectedZoneId) {
            Text('已筛选')
              .fontSize(12)
              .fontColor('#007AFF')
          }
        }
        .width('100%')
        .padding({ left: 15, right: 15, bottom: 5 })
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ top: 2 })
  }

  // ==================== 加载中视图 ====================
  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .color('#007AFF')
        .width(40)
        .height(40)
      Text('正在加载景点...')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // ==================== 空状态视图 ====================
  @Builder
  buildEmptyView() {
    Column() {
      Text('暂无景点数据')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 10 })
      Text('请尝试其他搜索条件或稍后再试')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // ==================== 景点列表 ====================
  @Builder
  buildSpotsList() {
    List({ space: 10 }) {
      ForEach(this.spotItems, (spot: SpotListItem) => {
        ListItem() {
          this.buildSpotCard(spot)
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
  }

  // ==================== 景点卡片 ====================
  @Builder
  buildSpotCard(spot: SpotListItem) {
    Column({ space: 0 }) {
      // 图片和信息行
      Row({ space: 12 }) {
        // 缩略图
        Column() {
          Image(spot.thumbnail || '')
            .width(80)
            .height(80)
            .objectFit(ImageFit.Cover)
            .borderRadius(8)
        }

        // 信息区域
        Column({ space: 8 }) {
          // 名称和距离
          Row() {
            Text(spot.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
              .layoutWeight(1)

            Text(this.formatDistance(spot.distance))
              .fontSize(14)
              .fontColor('#007AFF')
          }
          .width('100%')

          // 简介
          Text(spot.summary)
            .fontSize(13)
            .fontColor('#666666')
            .lineHeight(18)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          // 底部信息
          Row() {
            // 所属区域
            Row({ space: 5 }) {
              Text(`区域 ${spot.zoneId}`)
                .fontSize(12)
                .fontColor('#999999')
            }
          }
          .width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: 12, bottom: 12, left: 12, right: 12 })

      // 分隔线
      Row()
        .width('100%')
        .height(1)
        .backgroundColor('#F0F0F0')

      // 操作按钮
      Row() {
        Button('查看详情 →')
          .fontSize(14)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onClick(() => {
            this.viewSpotDetail(spot.spotId);
          })
      }
      .width('100%')
      .padding({ top: 8, bottom: 8, left: 12, right: 12 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 10 })
    .shadow({ radius: 4, color: '#0000000A' })
  }

  // ==================== 分页控件 ====================
  @Builder
  buildPagination() {
    Column() {
      Row({ space: 10 }) {
        // 上一页按钮
        Button('上一页')
          .fontSize(14)
          .fontColor(this.currentPage > 1 ? '#007AFF' : '#999999')
          .backgroundColor(Color.Transparent)
          .enabled(this.currentPage > 1)
          .onClick(() => {
            if (this.currentPage > 1) {
              this.currentPage--;
              this.loadSpots();
            }
          })

        // 页码显示
        if (this.pageInfo) {
          Text(`${this.currentPage} / ${this.totalPages}`)
            .fontSize(14)
            .fontColor('#666666')
        }

        // 下一页按钮
        Button('下一页')
          .fontSize(14)
          .fontColor(this.pageInfo && this.currentPage < this.totalPages ? '#007AFF' : '#999999')
          .backgroundColor(Color.Transparent)
          .enabled(this.pageInfo && this.currentPage < this.totalPages)
          .onClick(() => {
            if (this.pageInfo && this.currentPage < this.totalPages) {
              this.currentPage++;
              this.loadSpots();
            }
          })
      }
      .width('100%')
      .padding({ left: 15, right: 15 })
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(Color.White)
    .margin({ top: 2 })
  }


  // ==================== 交互方法 ====================

  // 查看景点详情
  private viewSpotDetail(spotId: number) {
    console.log('查看景点详情:', spotId);
    router.push({
      url: 'pages/SpotDetailPage',
      params: { spotId }
    });
  }

  // 格式化距离
  private formatDistance(meters: number): string {
    if (meters < 1000) {
      return `${meters}米`;
    } else {
      return `${(meters / 1000).toFixed(1)}公里`;
    }
  }

  // ==================== 生命周期方法 ====================

  aboutToAppear() {
    console.log('景点列表页面显示');
    this.loadSpots();
  }

  // 加载景点数据
  private async loadSpots() {
    console.log('开始加载景点数据，页码:', this.currentPage);
    this.isLoading = true;

    try {
      const params : SpotRequest = {
        keyword: this.searchKeyword || undefined,
        zoneId: this.selectedZoneId,
        page: this.currentPage,
        pageSize: 10
      };

      const result = await getSpots(params);
      if (result) {
        this.pageInfo = result;
        this.spotItems = result.list;
        console.log('景点数据加载成功，共', result.total, '个景点，当前页', result.list.length, '个');
        this.pageInfo = mockSpotPageResponse;
        this.spotItems = mockSpotItems;
      } else {
        // 如果API返回空，使用假数据
        console.log('API返回空数据，使用假数据');
        this.pageInfo = mockSpotPageResponse;
        this.spotItems = mockSpotItems;
      }
    } catch (error) {
      console.error('加载景点数据失败:', error);
      // 使用假数据
      this.pageInfo = mockSpotPageResponse;
      this.spotItems = mockSpotItems;
    } finally {
      this.isLoading = false;
    }
  }

  aboutToDisappear() {
    console.log('景点列表页面即将消失');
  }
}