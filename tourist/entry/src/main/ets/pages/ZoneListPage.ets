// entry/src/main/ets/pages/ZonesPage.ets
import { getZones } from '../api/zone'; // 稍后创建这个类型文件

// 引领区卡片数据接口
interface ZoneCard {
  zoneId: number;
  name: string;
  description: string;
  banner: string[];
  coverImage?: string; // 封面图
  spotCount?: number; // 景点数量
  rating?: number; // 评分
}

@Entry
@Component
export default struct ZonesPage {
  // 引领区列表数据
  @State zones: ZoneCard[] = [
    {
      zoneId: 1,
      name: '主题引领区',
      description: '展示园区历史与文化特色，融合传统与现代元素，体验独特的主题之旅。',
      banner: [
        'https://images.unsplash.com/photo-1528164344705-47542687000d?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w-800&auto=format&fit=crop'
      ],
      coverImage: 'https://images.unsplash.com/photo-1528164344705-47542687000d?w=400&auto=format&fit=crop',
      spotCount: 12,
      rating: 4.8
    },
    {
      zoneId: 2,
      name: '生态体验区',
      description: '以自然风光与生态科普为主，亲近大自然，体验生态之美。',
      banner: [
        'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&auto=format&fit=crop'
      ],
      coverImage: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400&auto=format&fit=crop',
      spotCount: 8,
      rating: 4.6
    },
    {
      zoneId: 3,
      name: '艺术创意区',
      description: '汇聚当代艺术与创意设计，感受艺术的无限可能。',
      banner: [
        'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w-800&auto=format&fit=crop'
      ],
      coverImage: 'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=400&auto=format&fit=crop',
      spotCount: 15,
      rating: 4.9
    },
    {
      zoneId: 4,
      name: '科技探索区',
      description: '前沿科技体验与互动，探索未来的无限可能。',
      banner: [
        'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop'
      ],
      coverImage: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400&auto=format&fit=crop',
      spotCount: 10,
      rating: 4.7
    },
    {
      zoneId: 5,
      name: '历史文化区',
      description: '追溯历史脉络，感受文化传承的深厚底蕴。',
      banner: [
        'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1529408632839-a54952c491e5?w-800&auto=format&fit=crop'
      ],
      coverImage: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=400&auto=format&fit=crop',
      spotCount: 20,
      rating: 4.5
    },
    {
      zoneId: 6,
      name: '休闲娱乐区',
      description: '放松身心，享受休闲时光，体验多样娱乐项目。',
      banner: [
        'https://images.unsplash.com/photo-1516937941344-00b4e0337589?w=800&auto=format&fit=crop'
      ],
      coverImage: 'https://images.unsplash.com/photo-1516937941344-00b4e0337589?w=400&auto=format&fit=crop',
      spotCount: 18,
      rating: 4.4
    }
  ];

  // 搜索关键词
  @State searchText: string = '';

  // 当前选中的筛选标签
  @State selectedTag: string = '全部';

  // 筛选标签列表
  @State tags: string[] = ['全部', '热门', '附近', '历史', '生态', '艺术', '科技'];

  build() {
    Column() {
      // 1. 顶部标题和搜索栏
      this.buildHeader()

      // // 2. 筛选标签栏
      this.buildFilterTags()

      //3. 引领区卡片网格 - 使用flex:1占据剩余空间
      Column() {
        this.buildZonesGrid()
      }
      .width('100%')
      .flexGrow(1) // 关键：占据剩余空间

      // 4. 底部安全区域
      Row()
        .height(60)
        .width('100%')
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
        Text('引领区探索')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)

        // 地图按钮
        Button('🗺️', { type: ButtonType.Circle })
          .width(40)
          .height(40)
          .backgroundColor(Color.White)
          .shadow({ radius: 2, color: '#00000010' })
          .onClick(() => {
            console.log('点击地图按钮');
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
        TextInput({ placeholder: '搜索引领区、景点...' })
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

        // 搜索按钮
        Button('搜索')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#007AFF')
          .height(36)
          .borderRadius(18)
          .margin({ right: 10 })
          .onClick(() => {
            this.onSearch();
          })
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

  // ==================== 筛选标签栏 ====================

  @Builder
  buildFilterTags() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.tags, (tag: string) => {
          this.buildTagItem(tag)
        })
      }
      .padding({ left: 20, right: 20, top: 15, bottom: 15 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .backgroundColor(Color.White)
    .width('100%')
    .height(60)
  }

  // 辅助方法：获取标签文字颜色
  private getTagColor(tag: string): ResourceColor {
    return this.selectedTag === tag ? Color.White : '#666666';
  }

  // 辅助方法：获取标签背景色
  private getTagBackground(tag: string): ResourceColor {
    return this.selectedTag === tag ? '#007AFF' : '#F5F7FA';
  }

  @Builder
  buildTagItem(tag: string) {
    // 在 @Builder 方法中不能直接使用 this，需要通过参数传递状态
    Button(tag)
      .fontSize(14)
      .fontColor(this.getTagColor(tag))  // 使用辅助方法获取颜色
      .backgroundColor(this.getTagBackground(tag))  // 使用辅助方法获取背景色
      .height(32)
      .borderRadius(16)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.selectedTag = tag;
        console.log('选择标签:', tag);
      })
  }

  // ==================== 引领区卡片网格 ====================

  @Builder
  buildZonesGrid() {
    Scroll() {
      Grid() {
        ForEach(this.zones, (zone: ZoneCard) => {
          GridItem() {
            this.buildZoneCard(zone)
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .backgroundColor('transparent') // 背景色改为透明
      .width('100%')
      .height('auto') // 关键：改为auto，自适应内容高度
      .padding({ left: 15, right: 15, top: 0, bottom: 200 }) // 去掉top padding
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  buildZoneCard(zone: ZoneCard) {
    Column({ space: 0 }) {
      // 卡片顶部 - 图片区域
      Stack() {
        // 背景图片
        Image(zone.coverImage || zone.banner[0] || '')
          .width('100%')
          .height(140)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 图片渐变遮罩
        Column()
          .width('100%')
          .height(140)
          //.backgroundImage($r('app'), ImageRepeat.NoRepeat)
          .backgroundImageSize(ImageSize.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 右上角评分标签
        Row({ space: 3 }) {
          Text('⭐')
            .fontSize(12)

          Text(zone.rating?.toFixed(1) || '4.5')
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: 8, right: 8 })
        .height(24)
        .backgroundColor('#00000080')
        .borderRadius(12)
        .position({ x: '85%', y: 10 })

        // 左下角景点数量
        Row({ space: 3 }) {
          Text('📍')
            .fontSize(12)

          Text(`${zone.spotCount || 0}个景点`)
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .padding({ left: 8, right: 8 })
        .height(24)
        .backgroundColor('#00000080')
        .borderRadius(12)
        .position({ x: 10, y: 110 })
      }
      .width('100%')
      .height(140)

      // 卡片内容区域
      Column({ space: 6 }) {
        // 区域名称
        Text(zone.name)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        // 区域描述
        Text(zone.description)
          .fontSize(13)
          .fontColor('#666666')
          .textAlign(TextAlign.Start)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        // 底部操作栏
        Row() {
          // 查看详情按钮
          Button('查看详情')
            .fontSize(14)
            .fontColor('#007AFF')
            .backgroundColor('#007AFF10')
            .height(32)
            .borderRadius(16)
            .padding({ left: 15, right: 15 })
            .onClick(() => {
              this.onViewZoneDetails(zone);
            })
            .margin({ top: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .padding({ left: 12, right: 12, top: 12, bottom: 12 })
      .backgroundColor(Color.White)
      .borderRadius({ bottomLeft: 12, bottomRight: 12 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 6, color: '#0000000D' })
    .onClick(() => {
      this.onZoneCardClick(zone);
    })
  }

  // ==================== 交互方法 ====================

  // 搜索
  private onSearch() {
    console.log('执行搜索:', this.searchText);
    // 这里可以添加搜索逻辑
  }

  // 点击引领区卡片
  private onZoneCardClick(zone: ZoneCard) {
    console.log('点击引领区:', zone.name);
    // 可以跳转到引领区详情页
  }

  // 查看详情按钮点击
  private onViewZoneDetails(zone: ZoneCard) {
    console.log('查看引领区详情:', zone.zoneId, zone.name);
    // 这里可以跳转到详情页面，显示轮播图等
  }

  // ==================== 生命周期方法 ====================

  aboutToAppear() {
    console.log('引领区页面显示');
    //
    this.loadZonesData();
  }

  // 加载引领区数据
  private loadZonesData() {
    console.log('加载引领区数据...');
    // 这里后续会调用API
    getZones();
    setTimeout(() => {
      console.log('引领区数据加载完成');
    }, 500);
  }
}