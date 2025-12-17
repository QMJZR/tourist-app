// entry/src/main/ets/pages/ZoneListPage.ets
import router from '@ohos.router';
import { getZones, ZoneItem } from '../api/zone'; // 注意：这里应该是正确的接口

// 正确的假数据 - 基于 ZoneItem 接口
const mockZones: ZoneItem[] = [
  {
    zoneId: 1,
    name: '自然风光区',
    description: '集中展示了园区最壮丽的自然景观，包括瀑布、湖泊、山脉等多种地貌。',
    banner: [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=800&auto=format&fit=crop'
    ]
  },
  {
    zoneId: 2,
    name: '文化体验区',
    description: '融合了传统与现代文化元素，提供丰富的文化展示和互动体验项目。',
    banner: [
      'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&auto=format&fit=crop'
    ]
  },
  {
    zoneId: 3,
    name: '休闲娱乐区',
    description: '适合家庭和朋友聚会的休闲区域，提供各种娱乐设施和放松空间。',
    banner: [
      'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=800&auto=format&fit=crop'
    ]
  },
  {
    zoneId: 4,
    name: '生态保护区',
    description: '保护区内有多种珍稀动植物，是生态观察和自然教育的理想场所。',
    banner: [
      'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1476820865390-c52aeebb9891?w=800&auto=format&fit=crop'
    ]
  }
];

@Entry
@Component
export default struct ZoneListPage {
  // 引领区列表数据
  @State zones: ZoneItem[] = [];

  // 加载状态
  @State isLoading: boolean = true;

  // 页面构建
  build() {
    Column() {
      // 顶部导航栏
      this.buildNavigationBar()

      // 内容区域
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.zones.length === 0) {
        this.buildEmptyView()
      } else {
        this.buildZonesList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .padding({bottom: 60})
  }

  // ==================== 顶部导航栏 ====================
  @Builder
  buildNavigationBar() {
    Column() {
      Row({ space: 10 }) {
        // 返回按钮（如果是从其他页面跳转过来的）
        // Button('←')
        //   .fontSize(20)
        //   .fontColor('#1A1A1A')
        //   .backgroundColor(Color.Transparent)
        //   .width(40)
        //   .height(40)
        //   .onClick(() => {
        //     router.back();
        //   })

        // 标题
        Text('引领区列表')
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
            this.loadZones();
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

  // ==================== 加载中视图 ====================
  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .color('#007AFF')
        .width(40)
        .height(40)
      Text('正在加载引领区...')
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
      Text('暂无引领区数据')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 10 })
      Text('管理员正在努力添加中...')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // ==================== 引领区列表 ====================
  @Builder
  buildZonesList() {
    List({ space: 15 }) {
      ForEach(this.zones, (zone: ZoneItem) => {
        ListItem() {
          this.buildZoneCard(zone)
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .padding({ left: 15, right: 15, top: 15, bottom: 15 })
  }

  // ==================== 引领区卡片 ====================
  @Builder
  buildZoneCard(zone: ZoneItem) {
    Column({ space: 0 }) {
      // 背景图 - 使用banner数组的第一张图片
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(zone.banner && zone.banner.length > 0 ? zone.banner[0] : '')
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 图片遮罩渐变
        Column()
          .width('100%')
          .height(60)
          .backgroundImage(
            'linear-gradient(180deg, rgba(0,0,0,0) 0%, rgba(0,0,0,0.7) 100%)'
          )
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 引领区名称（在图片上）
        Column() {
          Text(zone.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .padding({ left: 15, right: 15, bottom: 10 })
      }

      // 内容区域
      Column({ space: 10 }) {
        // 描述信息
        Text(zone.description)
          .fontSize(14)
          .fontColor('#666666')
          .lineHeight(20)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        // 底部信息栏
        Row() {
          // banner数量
          Row({ space: 5 }) {
            // Image($r('app.media.ic_image')) // 如果没有图标，可以用文字
            //   .width(16)
            //   .height(16)
            Text(`${zone.banner?.length || 0}张图片`)
              .fontSize(12)
              .fontColor('#999999')
          }

          // 查看详情按钮
          // Button('查看详情 →')
          //   .fontSize(14)
          //   .fontColor('#007AFF')
          //   .backgroundColor(Color.Transparent)
          //   .layoutWeight(1)
          //   .onClick(() => {
          //     this.viewZoneDetail(zone.zoneId);
          //   })
        }
        .width('100%')
        .padding({ top: 8 })
      }
      .padding({ left: 15, right: 15, top: 15, bottom: 15 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 6, color: '#0000000F' })
    .onClick(() => {
      this.viewZoneDetail(zone.zoneId);
    })
  }

  // ==================== 交互方法 ====================

  // 查看引领区详情
  private viewZoneDetail(zoneId: number) {
    console.log('查看引领区详情:', zoneId);
    // TODO: 跳转到引领区详情页面或该引领区下的景点列表页面
    // router.push({
    //   url: 'pages/ZoneDetailPage',
    //   params: { zoneId }
    // });
  }

  // ==================== 生命周期方法 ====================

  aboutToAppear() {
    console.log('引领区列表页面显示');
    this.loadZones();
  }

  // 加载引领区数据
  private async loadZones() {
    console.log('开始加载引领区数据...');
    this.isLoading = true;

    try {
      const result = await getZones();
      if (result && result.length > 0) {
        this.zones = result;
        console.log('引领区数据加载成功，共', result.length, '个引领区');
      } else {
        // 如果API返回空，使用假数据
        console.log('API返回空数据，使用假数据');
        this.zones = [...mockZones];
      }
    } catch (error) {
      console.error('加载引领区数据失败:', error);
      // 使用假数据
      this.zones = [...mockZones];
    } finally {
      this.isLoading = false;
    }
  }

  aboutToDisappear() {
    console.log('引领区列表页面即将消失');
  }
}