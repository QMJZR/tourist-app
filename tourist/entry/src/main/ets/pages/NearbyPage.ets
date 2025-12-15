// entry/src/main/ets/pages/NearbyPage.ets

import { router } from '@kit.ArkUI';
import { getNearbyRecommendations, NearbyItem, NearbyApiResponse } from '../api/recommend';

// 附近景点项接口定义
interface NearbySpotItem {
  spotId: number;
  name: string;
  description: string;
  images: Array<string>;
  zoneId: number;
  zoneName: string;
  coverImage: string;
  distance: number;  // 距离（公里）
  distanceText: string; // 距离文本（如："500m"、"1.2km"）
  isRecommended: boolean;
  visitedCount: number;
  rating: number;
  category: string; // 景点类别
  openTime: string; // 开放时间
  price: string;    // 价格信息（如："免费"、"¥50"")
}

// 排序方式类型
type SortType = 'distance' | 'rating' | 'popular' | 'recommended';

// 排序选项
interface SortOption {
  label: string;
  value: SortType;
}

// 筛选选项
interface FilterOption {
  label: string;
  value: string;
}

@Entry
@Component
struct NearbyPage {
  // 附近景点列表
  @State nearbySpots: Array<NearbySpotItem> = [];

  // 当前排序方式
  @State currentSort: SortType = 'distance';

  // 当前筛选类别
  @State currentFilter: string = '全部';

  // 排序选项 - 添加明确的类型声明
  private sortOptions: Array<SortOption> = [
    { label: '距离最近', value: 'distance' },
    { label: '评分最高', value: 'rating' },
    { label: '人气最旺', value: 'popular' },
    { label: '编辑推荐', value: 'recommended' }
  ];

  // 筛选类别选项 - 添加明确的类型声明
  private filterOptions: Array<FilterOption> = [
    { label: '全部', value: '全部' },
    { label: '自然风光', value: '自然风光' },
    { label: '历史文化', value: '历史文化' },
    { label: '休闲娱乐', value: '休闲娱乐' },
    { label: '美食购物', value: '美食购物' },
    { label: '亲子家庭', value: '亲子家庭' }
  ];

  // 加载状态
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State apiFailed: boolean = false; // API调用失败标记

  // 当前位置（假数据）
  @State currentLocation: string = '当前位置';
  @State currentAddress: string = 'XX市XX区XX路123号';

  // 经纬度常量
  private latitude: number = 23.112233;
  private longitude: number = 113.332211;

  // 生命周期：页面显示时
  aboutToAppear() {
    console.log('附近推荐页面显示');
    this.loadNearbyData();
  }

  // 加载附近景点数据（优先调用接口）
  private async loadNearbyData() {
    this.isLoading = true;
    this.apiFailed = false;

    console.log('开始加载附近推荐数据...');

    try {
      // 先尝试调用接口获取数据
      const response = await getNearbyRecommendations({
        latitude: this.latitude,
        longitude: this.longitude,
        sort: this.mapSortTypeToApi(this.currentSort),
        type: 'spot'
      });

      if (response && response.code === 200 && response.data && response.data.list) {
        console.log('✅ 接口调用成功，获取到', response.data.list.length, '个推荐项');
        this.processApiData(response.data.list);
        this.isLoading = false;
        this.isRefreshing = false;
        return;
      } else {
        console.warn('接口返回数据异常，使用假数据');
        this.apiFailed = true;
      }
    } catch (error) {
      console.error('接口调用失败:', error);
      this.apiFailed = true;
    }

    // 如果接口调用失败，使用假数据
    console.log('使用假数据');
    this.useMockData();
  }

  // 处理API返回的数据
  // 处理API返回的数据
  private processApiData(apiItems: NearbyItem[]) {
    console.log('处理API数据:', apiItems);

    // 将API数据转换为页面需要的数据格式
    const convertedSpots: NearbySpotItem[] = apiItems.map((item, index) => {
      // 这里需要根据API返回的数据结构进行映射
      // 由于API返回的字段可能与页面需要的不完全一致，这里做适配转换

      // 生成一些模拟数据来填充API可能缺少的字段
      const categories = ['自然风光', '历史文化', '休闲娱乐', '美食购物', '亲子家庭'];
      const category = categories[index % categories.length];

      const isRecommended = index % 3 === 0; // 每3个有一个推荐

      // 将米转换为公里
      const distanceInKm = item.distance / 1000;

      // 明确创建符合 NearbySpotItem 接口的对象
      const spotItem: NearbySpotItem = {
        spotId: item.id || index + 1,
        name: item.name || `景点${index + 1}`,
        description: this.generateDescription(category),
        images: item.thumbnail ? [item.thumbnail] : [],
        zoneId: index + 1,
        zoneName: this.getZoneName(category),
        coverImage: item.thumbnail || this.getDefaultImage(category),
        distance: distanceInKm,
        distanceText: this.formatDistance(distanceInKm),
        isRecommended: isRecommended,
        visitedCount: Math.floor(item.popularity * 100) || 500 + index * 100,
        rating: 4.0 + (item.popularity * 0.5) || 4.0 + (index * 0.1),
        category: category,
        openTime: '09:00-17:00',
        price: index % 2 === 0 ? '免费' : '¥' + (20 + index * 10)
      };

      return spotItem;
    });

    // 根据当前排序方式排序
    const sortedSpots = this.sortSpots(convertedSpots, this.currentSort);

    // 根据当前筛选类别筛选
    if (this.currentFilter !== '全部') {
      this.nearbySpots = sortedSpots.filter(spot => spot.category === this.currentFilter);
    } else {
      this.nearbySpots = sortedSpots;
    }

    console.log('数据转换完成，共', this.nearbySpots.length, '个景点');
  }

  // 使用假数据
  private useMockData() {
    // 模拟网络请求延迟
    setTimeout(() => {
      // 生成假数据
      this.generateMockData();
      this.isLoading = false;
      this.isRefreshing = false;
      console.log('✅ 使用假数据加载成功');
    }, 800);
  }

  // 生成描述
  private generateDescription(category: string): string {
    const descriptions: Record<string, string> = {
      '自然风光': '优美的自然景观，让人心旷神怡，流连忘返。',
      '历史文化': '具有深厚历史文化底蕴的景点，值得细细品味。',
      '休闲娱乐': '适合放松身心，享受休闲时光的好去处。',
      '美食购物': '美食与购物的天堂，满足您的味蕾和购物欲。',
      '亲子家庭': '适合全家出游，让孩子在玩耍中学习成长。'
    };
    return descriptions[category] || '一个值得一游的景点。';
  }

  // 获取区域名称
  private getZoneName(category: string): string {
    const zoneNames: Record<string, string> = {
      '自然风光': '生态体验区',
      '历史文化': '历史文化区',
      '休闲娱乐': '休闲娱乐区',
      '美食购物': '美食购物区',
      '亲子家庭': '亲子乐园区'
    };
    return zoneNames[category] || '综合体验区';
  }

  // 获取默认图片
  private getDefaultImage(category: string): string {
    const defaultImages: Record<string, string> = {
      '自然风光': 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400&auto=format&fit=crop',
      '历史文化': 'https://images.unsplash.com/photo-1542728928-0013d5f8d5b5?w-400&auto=format&fit=crop',
      '休闲娱乐': 'https://images.unsplash.com/photo-1516937941344-00b4e0337589?w=400&auto=format&fit=crop',
      '美食购物': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&auto=format&fit=crop',
      '亲子家庭': 'https://images.unsplash.com/photo-1516937941344-00b4e0337589?w=400&auto=format&fit=crop'
    };
    return defaultImages[category] || 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400&auto=format&fit=crop';
  }

  // 格式化距离
  private formatDistance(distanceInKm: number): string {
    if (distanceInKm < 1) {
      return Math.round(distanceInKm * 1000) + 'm';
    } else {
      return distanceInKm.toFixed(1) + 'km';
    }
  }

  // 映射排序类型到API参数
  private mapSortTypeToApi(sortType: SortType): string {
    const mapping: Record<SortType, string> = {
      'distance': 'distance',
      'rating': 'popularity', // 假设评分对应热度
      'popular': 'popularity',
      'recommended': 'popularity' // 推荐也使用热度
    };
    return mapping[sortType] || 'popularity';
  }

  // 生成假数据（保留原有的假数据生成逻辑）
  private generateMockData() {
    // 明确声明数组类型
    const baseSpots: Array<NearbySpotItem> = [
      {
        spotId: 1,
        name: '古建筑群',
        description: '保存完好的明清时期古建筑群，展示了古代建筑艺术的精髓。',
        images: ['https://images.unsplash.com/photo-1542728928-0013d5f8d5b5?w=800&auto=format&fit=crop'],
        zoneId: 5,
        zoneName: '历史文化区',
        coverImage: 'https://images.unsplash.com/photo-1542728928-0013d5f8d5b5?w=400&auto=format&fit=crop',
        distance: 0.5,
        distanceText: '500m',
        isRecommended: true,
        visitedCount: 1250,
        rating: 4.7,
        category: '历史文化',
        openTime: '09:00-17:00',
        price: '¥40'
      },
      {
        spotId: 2,
        name: '特色美食街',
        description: '汇聚各地特色小吃和传统美食，体验地道风味。',
        images: ['https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format&fit=crop'],
        zoneId: 6,
        zoneName: '休闲娱乐区',
        coverImage: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&auto=format&fit=crop',
        distance: 0.8,
        distanceText: '800m',
        isRecommended: true,
        visitedCount: 1800,
        rating: 4.9,
        category: '美食购物',
        openTime: '10:00-22:00',
        price: '免费'
      },
      {
        spotId: 3,
        name: '生态湿地公园',
        description: '原生湿地生态系统，观鸟、徒步、自然教育的好去处。',
        images: ['https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&auto=format&fit=crop'],
        zoneId: 2,
        zoneName: '生态体验区',
        coverImage: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400&auto=format&fit=crop',
        distance: 1.2,
        distanceText: '1.2km',
        isRecommended: false,
        visitedCount: 750,
        rating: 4.5,
        category: '自然风光',
        openTime: '06:00-20:00',
        price: '免费'
      },
      {
        spotId: 4,
        name: '艺术画廊',
        description: '当代艺术展览空间，定期举办国内外艺术家作品展。',
        images: ['https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=800&auto=format&fit=crop'],
        zoneId: 3,
        zoneName: '艺术创意区',
        coverImage: 'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=400&auto=format&fit=crop',
        distance: 1.5,
        distanceText: '1.5km',
        isRecommended: true,
        visitedCount: 890,
        rating: 4.6,
        category: '历史文化',
        openTime: '10:00-18:00',
        price: '¥30'
      },
      {
        spotId: 5,
        name: '儿童游乐场',
        description: '适合家庭游玩的亲子游乐设施，安全有趣的儿童活动空间。',
        images: ['https://images.unsplash.com/photo-1516937941344-00b4e0337589?w=800&auto=format&fit=crop'],
        zoneId: 6,
        zoneName: '休闲娱乐区',
        coverImage: 'https://images.unsplash.com/photo-1516937941344-00b4e0337589?w=400&auto=format&fit=crop',
        distance: 2.0,
        distanceText: '2.0km',
        isRecommended: false,
        visitedCount: 1200,
        rating: 4.4,
        category: '亲子家庭',
        openTime: '09:00-21:00',
        price: '¥25'
      },
      {
        spotId: 6,
        name: '科技体验馆',
        description: '前沿科技展示与互动体验，VR、AR等沉浸式体验项目。',
        images: ['https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop'],
        zoneId: 4,
        zoneName: '科技探索区',
        coverImage: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400&auto=format&fit=crop',
        distance: 2.5,
        distanceText: '2.5km',
        isRecommended: true,
        visitedCount: 980,
        rating: 4.8,
        category: '休闲娱乐',
        openTime: '10:00-19:00',
        price: '¥80'
      },
      {
        spotId: 7,
        name: '城市公园',
        description: '城市中的绿色氧吧，适合散步、跑步、放松身心。',
        images: ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&auto=format&fit=crop'],
        zoneId: 2,
        zoneName: '生态体验区',
        coverImage: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&auto=format&fit=crop',
        distance: 0.3,
        distanceText: '300m',
        isRecommended: true,
        visitedCount: 2200,
        rating: 4.6,
        category: '自然风光',
        openTime: '全天开放',
        price: '免费'
      },
      {
        spotId: 8,
        name: '购物中心',
        description: '集购物、餐饮、娱乐于一体的大型商业综合体。',
        images: ['https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&auto=format&fit=crop'],
        zoneId: 6,
        zoneName: '休闲娱乐区',
        coverImage: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400&auto=format&fit=crop',
        distance: 0.9,
        distanceText: '900m',
        isRecommended: false,
        visitedCount: 1500,
        rating: 4.3,
        category: '美食购物',
        openTime: '10:00-22:00',
        price: '免费进入'
      }
    ];

    // 根据当前排序方式排序
    const sortedSpots = this.sortSpots(baseSpots, this.currentSort);

    // 根据当前筛选类别筛选
    if (this.currentFilter !== '全部') {
      this.nearbySpots = sortedSpots.filter(spot => spot.category === this.currentFilter);
    } else {
      this.nearbySpots = sortedSpots;
    }
  }

  // 排序景点
  private sortSpots(spots: Array<NearbySpotItem>, sortType: SortType): Array<NearbySpotItem> {
    const spotsCopy = [...spots];

    switch (sortType) {
      case 'distance':
        return spotsCopy.sort((a, b) => a.distance - b.distance);
      case 'rating':
        return spotsCopy.sort((a, b) => b.rating - a.rating);
      case 'popular':
        return spotsCopy.sort((a, b) => b.visitedCount - a.visitedCount);
      case 'recommended':
        return spotsCopy.sort((a, b) => {
          if (a.isRecommended && !b.isRecommended) return -1;
          if (!a.isRecommended && b.isRecommended) return 1;
          return b.rating - a.rating;
        });
      default:
        return spotsCopy;
    }
  }

  // 切换排序方式
  private async changeSortType(sortType: SortType) {
    if (this.currentSort === sortType) {
      return;
    }

    this.currentSort = sortType;
    this.isLoading = true;

    // 如果API之前失败了，直接使用假数据
    if (this.apiFailed) {
      setTimeout(() => {
        this.nearbySpots = this.sortSpots(this.nearbySpots, sortType);
        this.isLoading = false;
        console.log(`✅ 按${this.getSortLabel(sortType)}排序完成`);
      }, 500);
      return;
    }

    // 否则尝试重新调用API
    try {
      const response = await getNearbyRecommendations({
        latitude: this.latitude,
        longitude: this.longitude,
        sort: this.mapSortTypeToApi(sortType),
        type: 'spot'
      });

      if (response && response.code === 200 && response.data && response.data.list) {
        console.log('✅ 排序接口调用成功');
        this.processApiData(response.data.list);
      } else {
        console.warn('排序接口调用失败，使用本地排序');
        this.nearbySpots = this.sortSpots(this.nearbySpots, sortType);
      }
    } catch (error) {
      console.error('排序接口调用异常，使用本地排序:', error);
      this.nearbySpots = this.sortSpots(this.nearbySpots, sortType);
    } finally {
      this.isLoading = false;
    }
  }

  // 切换筛选类别
  private async changeFilterCategory(category: string) {
    if (this.currentFilter === category) {
      return;
    }

    this.currentFilter = category;
    this.isLoading = true;

    // 如果API之前失败了，直接使用假数据
    if (this.apiFailed) {
      setTimeout(() => {
        this.generateMockData(); // 重新生成数据应用筛选
        this.isLoading = false;
        console.log(`✅ 筛选类别: ${category}`);
      }, 500);
      return;
    }

    // 否则尝试重新调用API
    try {
      const response = await getNearbyRecommendations({
        latitude: this.latitude,
        longitude: this.longitude,
        sort: this.mapSortTypeToApi(this.currentSort),
        type: 'spot'
      });

      if (response && response.code === 200 && response.data && response.data.list) {
        console.log('✅ 筛选接口调用成功');
        this.processApiData(response.data.list);
      } else {
        console.warn('筛选接口调用失败，使用本地数据');
        this.generateMockData();
      }
    } catch (error) {
      console.error('筛选接口调用异常，使用本地数据:', error);
      this.generateMockData();
    } finally {
      this.isLoading = false;
    }
  }

  // 获取排序方式标签
  private getSortLabel(sortType: SortType): string {
    const option = this.sortOptions.find(opt => opt.value === sortType);
    return option ? option.label : '';
  }

  // 刷新数据
  private refreshData() {
    this.isRefreshing = true;
    this.loadNearbyData();
  }

  // 获取距离颜色（根据距离远近显示不同颜色）
  private getDistanceColor(distance: number): string {
    if (distance < 1) return '#34C759';      // 绿色：1km以内
    if (distance < 3) return '#FF9500';      // 橙色：1-3km
    return '#FF3B30';                        // 红色：3km以上
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
            this.loadNearbyData();
          })
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#FFF8E6')
      .borderRadius(8)
      .margin({ left: 16, right: 16, top: 8 })
      .shadow({ radius: 2, color: '#00000004' })
    }
  }

  // 构建顶部位置信息卡片
  @Builder
  buildLocationCard() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('📍')
          .fontSize(18)
          .fontColor('#007AFF')

        Text('附近推荐')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Row({ space: 8 }) {
        Text(this.currentLocation)
          .fontSize(14)
          .fontColor('#666666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Button('刷新位置')
          .backgroundColor('#007AFF10')
          .borderRadius(12)
          .padding({ left: 12, right: 12 })
          .height(28)
          .onClick(() => {
            console.log('点击刷新位置');
            this.refreshData();
          })
      }
      .width('100%')

      Text(this.currentAddress)
        .fontSize(12)
        .fontColor('#999999')
        .textAlign(TextAlign.Start)
        .width('100%')
    }
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
    .shadow({ radius: 4, color: '#00000008' })
  }

  // 构建筛选和排序栏
  @Builder
  buildFilterSortBar() {
    Column({ space: 12 }) {
      // 筛选标签
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.filterOptions, (option: FilterOption) => {
            Button(option.label) {
              Text(option.label)
                .fontSize(12)
                .fontColor(this.currentFilter === option.value ? Color.White : '#666666')
            }
            .backgroundColor(this.currentFilter === option.value ? '#007AFF' : '#F5F5F5')
            .borderRadius(16)
            .padding({ left: 16, right: 16 })
            .height(32)
            .onClick(() => {
              this.changeFilterCategory(option.value);
            })
          })
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      // 排序选项
      Row({ space: 8 }) {
        Text('排序：')
          .fontSize(14)
          .fontColor('#666666')

        ForEach(this.sortOptions, (option: SortOption) => {
          Button(option.label) {
            Text(option.label)
              .fontSize(12)
              .fontColor(this.currentSort === option.value ? '#007AFF' : '#666666')
          }
          .backgroundColor(this.currentSort === option.value ? '#007AFF10' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .height(28)
          .onClick(() => {
            this.changeSortType(option.value);
          })
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 4, bottom: 8 })
    }
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 12 })
    .shadow({ radius: 4, color: '#00000008' })
  }

  // 构建附近景点卡片
  @Builder
  buildSpotCard(spot: NearbySpotItem, index: number) {
    Column({ space: 0 }) {
      Row({ space: 12 }) {
        // 左侧：图片区域
        Column() {
          Stack() {
            if (spot.coverImage && spot.coverImage.trim() !== '') {
              Image(spot.coverImage)
                .width(100)
                .height(100)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
            } else {
              Column() {
                Text('🏞️')
                  .fontSize(30)
                  .fontColor('#999999')
              }
              .width(100)
              .height(100)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor('#F0F0F0')
              .borderRadius(8)
            }

            // 推荐标签
            if (spot.isRecommended) {
              Text('🔥')
                .fontSize(12)
                .fontColor(Color.White)
                .backgroundColor('#FF3B30')
                .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                .borderRadius(4)
                .position({ x: 5, y: 5 })
            }
          }
          .width(100)
          .height(100)
        }

        // 右侧：信息区域
        Column({ space: 6 }) {
          // 景点名称和距离
          Row({ space: 8 }) {
            Text(spot.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            // 距离标签
            Column() {
              Text(spot.distanceText)
                .fontSize(12)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Medium)
            }
            .backgroundColor(this.getDistanceColor(spot.distance))
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(4)
          }
          .width('100%')

          // 景点描述
          Text(spot.description)
            .fontSize(13)
            .fontColor('#666666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          // 分类和评分信息
          Row({ space: 12 }) {
            // 分类标签
            Text(spot.category)
              .fontSize(11)
              .fontColor('#007AFF')
              .backgroundColor('#007AFF10')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)

            // 评分
            Row({ space: 2 }) {
              Text('⭐')
                .fontSize(10)
              Text(spot.rating.toFixed(1))
                .fontSize(11)
                .fontColor('#FF9500')
            }

            // 打卡人数
            Row({ space: 2 }) {
              Text('👥')
                .fontSize(10)
              Text(`${spot.visitedCount}`)
                .fontSize(11)
                .fontColor('#999999')
            }
            .layoutWeight(1)

            // 价格信息
            if (spot.price && spot.price !== '免费') {
              Text(spot.price)
                .fontSize(11)
                .fontColor('#FF3B30')
                .fontWeight(FontWeight.Medium)
            }
          }
          .width('100%')
          .margin({ top: 4 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height(120)
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 分隔线
      if (index < this.nearbySpots.length - 1) {
        Divider()
          .color('#F0F0F0')
          .margin({ left: 128, right: 16 })
          .strokeWidth(0.5)
      }
    }
  }

  // 构建景点列表
  @Builder
  buildSpotsList() {
    Column() {
      // API失败提示
      this.buildApiFailNotice()

      // 列表标题
      Row({ space: 8 }) {
        Text('附近景点')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Text(`共${this.nearbySpots.length}个`)
          .fontSize(12)
          .fontColor('#666666')
          .backgroundColor('#F0F0F0')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(10)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

      // 景点列表
      if (this.nearbySpots.length > 0) {
        Column({ space: 0 }) {
          ForEach(this.nearbySpots, (spot: NearbySpotItem, index: number) => {
            this.buildSpotCard(spot, index)
          })
        }
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .shadow({ radius: 4, color: '#00000008' })
      } else {
        // 空状态
        Column({ space: 16 }) {
          Text('📍')
            .fontSize(60)
            .fontColor('#007AFF')

          Text('附近暂无推荐景点')
            .fontSize(16)
            .fontColor('#999999')

          Text('换个位置试试看？')
            .fontSize(14)
            .fontColor('#CCCCCC')

          Button('刷新位置')
            .backgroundColor('#007AFF')
            .borderRadius(8)
            .width(120)
            .height(36)
            .margin({ top: 8 })
            .onClick(() => {
              this.refreshData();
            })
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

      Text('加载附近景点数据中...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
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
        Text('附近推荐')
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
          if (this.isLoading && !this.isRefreshing) {
            this.buildLoadingView()
          } else {
            // 位置信息卡片
            this.buildLocationCard()

            // 筛选排序栏
            this.buildFilterSortBar()

            // 景点列表
            this.buildSpotsList()

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
      .onScrollEdge((side: Edge) => {
        if (side === Edge.Top) {
          this.refreshData();
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}