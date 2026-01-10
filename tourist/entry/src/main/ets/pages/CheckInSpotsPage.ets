// entry/src/main/ets/pages/CheckinSpotsPage.ets
import router from '@ohos.router';
import {getCheckInSpots, GetReq} from '../api/checkIn'
// 假数据 - 根据文档中的返回格式
const mockCheckinSpots: CheckinSpot[] =  [
  {
    spotId: 301,
    name: '山顶观景台',
    latitude: 23.112233,
    longitude: 113.332211,
    radius: 100,
    thumbnail: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&auto=format&fit=crop',
    distance: 85
  },
  {
    spotId: 302,
    name: '湖畔栈道',
    latitude: 23.115566,
    longitude: 113.334455,
    radius: 120,
    thumbnail: 'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=300&auto=format&fit=crop',
    distance: 320
  },
  {
    spotId: 303,
    name: '瀑布观景台',
    latitude: 23.118899,
    longitude: 113.336677,
    radius: 80,
    thumbnail: 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=300&auto=format&fit=crop',
    distance: 560
  },
  {
    spotId: 304,
    name: '花园广场',
    latitude: 23.122233,
    longitude: 113.338899,
    radius: 150,
    thumbnail: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=300&auto=format&fit=crop',
    distance: 1200
  },
  {
    spotId: 305,
    name: '山间步道',
    latitude: 23.125566,
    longitude: 113.341122,
    radius: 90,
    thumbnail: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300&auto=format&fit=crop',
    distance: 1850
  }
];

// 打卡点接口
interface CheckinSpot {
  spotId: number;
  name: string;
  latitude: number;
  longitude: number;
  radius: number;
  thumbnail: string;
  distance: number;
}

// 请求参数接口
interface CheckinSpotsParams {
  lat?: number;
  lng?: number;
  sort?: string;
}

interface UserLocation {
  lat?:number;
  lng?:number;
}
@Entry
@Component
export default struct CheckinSpotsPage {
  // 打卡点列表数据
  @State checkinSpots: CheckinSpot[] = [];

  // 加载状态
  @State isLoading: boolean = true;

  // 是否按距离排序
  @State sortByDistance: boolean = false;

  // 当前用户位置
  @State userLocation: UserLocation = {};

  // 页面构建
  build() {
    Column() {
      // 顶部导航栏
      this.buildNavigationBar()

      // 筛选工具栏
      this.buildFilterToolbar()

      // 打卡点列表
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.checkinSpots.length === 0) {
        this.buildEmptyView()
      } else {
        this.buildSpotsList()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .padding({ bottom: 120 }) // ← 关键修改：为底部Tabs预留空间
  }

  // ==================== 顶部导航栏 ====================
  @Builder
  buildNavigationBar() {
    Column() {
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
        Text('打卡点位')
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
            this.loadCheckinSpots();
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

  // ==================== 筛选工具栏 ====================
  @Builder
  buildFilterToolbar() {
    Column() {
      // 排序选项
      Row({ space: 15 }) {
        // 排序按钮
        Button(this.sortByDistance ? '按距离排序 ✓' : '按距离排序')
          .fontSize(14)
          .fontColor(this.sortByDistance ? '#007AFF' : '#666666')
          .backgroundColor(this.sortByDistance ? '#007AFF10' : '#F0F0F0')
          .height(32)
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.toggleSortByDistance();
          })

        // 状态显示
        Text(`共 ${this.checkinSpots.length} 个打卡点`)
          .fontSize(14)
          .fontColor('#666666')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .padding({ left: 15, right: 15 })

      // 附近打卡点提示
      if (this.userLocation.lat && this.userLocation.lng) {
        Row() {
          // Image($r('app.media.ic_location'))
          //   .width(16)
          //   .height(16)
          //   .margin({ right: 5 })
          Text(`当前位置附近 ${this.getNearbySpotsCount()} 个打卡点`)
            .fontSize(12)
            .fontColor('#007AFF')
        }
        .width('100%')
        .padding({ left: 15, right: 15, top: 5 })
        .justifyContent(FlexAlign.Start)
      }
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
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
      Text('正在加载打卡点位...')
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
      // Image($r('app.media.ic_empty'))
      //   .width(100)
      //   .height(100)
      //   .margin({ bottom: 20 })
      Text('暂无打卡点位')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 10 })
      Text('该区域暂时没有可打卡的点位')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // ==================== 打卡点列表 ====================
  @Builder
  buildSpotsList() {
    List({ space: 10 }) {
      ForEach(this.checkinSpots, (spot: CheckinSpot) => {
        ListItem() {
          this.buildSpotItem(spot)
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .padding({ left: 15, right: 15, top: 10 })
  }

  // ==================== 打卡点项目 ====================
  @Builder
  buildSpotItem(spot: CheckinSpot) {
    Column({ space: 0 }) {
      // 主信息行
      Row({ space: 12 }) {
        // 缩略图
        Column() {
          if (spot.thumbnail) {
            Image(spot.thumbnail)
              .width(60)
              .height(60)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)
          } else {
            Column()
              .width(60)
              .height(60)
              .backgroundColor('#E0E0E0')
              .borderRadius(8)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            // Image($r('app.media.ic_spot'))
            //   .width(24)
            //   .height(24)
          }
        }

        // 信息区域
        Column({ space: 6 }) {
          // 名称和距离
          Row() {
            Text(spot.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
              .layoutWeight(1)

            if (spot.distance !== undefined) {
              Text(this.formatDistance(spot.distance))
                .fontSize(14)
                .fontColor(spot.distance <= spot.radius ? '#34C759' : '#666666')
            }
          }
          .width('100%')

          // 坐标信息
          Row() {
            Text(`📍 ${spot.latitude.toFixed(6)}, ${spot.longitude.toFixed(6)}`)
              .fontSize(12)
              .fontColor('#999999')
          }
          .width('100%')

          // 打卡范围和状态
          Row() {
            // 打卡范围
            Text(`打卡范围: ${spot.radius}米`)
              .fontSize(12)
              .fontColor('#666666')

            // 状态指示器
            if (spot.distance !== undefined) {
              Row({ space: 5 }) {
                // 距离圆点
                Column()
                  .width(8)
                  .height(8)
                  .backgroundColor(spot.distance <= spot.radius ? '#34C759' : '#FF9500')
                  .borderRadius(4)

                // 状态文本
                Text(spot.distance <= spot.radius ? '可打卡' : '距离过远')
                  .fontSize(12)
                  .fontColor(spot.distance <= spot.radius ? '#34C759' : '#FF9500')
              }
              .margin({ left: 10 })
            }
          }
          .width('100%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: 12, bottom: 12, left: 12, right: 12 })

      // 操作按钮
      Row() {
        // 查看详情按钮
        Button('查看详情')
          .fontSize(14)
          .fontColor('#007AFF')
          .backgroundColor('#007AFF10')
          .height(36)
          .borderRadius(18)
          .layoutWeight(1)
          .onClick(() => {
            this.viewSpotDetail(spot.spotId);
          })

        // 打卡按钮
        Button(spot.distance && spot.distance <= spot.radius ? '立即打卡' : '查看位置')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(spot.distance && spot.distance <= spot.radius ? '#007AFF' : '#666666')
          .height(36)
          .borderRadius(18)
          .layoutWeight(1)
          .margin({ left: 10 })
          .onClick(() => {
            // if (spot.distance && spot.distance <= spot.radius) {
            //   this.checkIn(spot.spotId);
            // } else {
            //   this.viewOnMap(spot);
            // }
            this.checkIn(spot.spotId);
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, bottom: 12 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 10 })
    .shadow({ radius: 4, color: '#0000000A' })
  }

  // ==================== 交互方法 ====================

  // 切换按距离排序
  private toggleSortByDistance() {
    this.sortByDistance = !this.sortByDistance;

    if (this.sortByDistance) {
      // 按距离升序排序
      this.checkinSpots = [...this.checkinSpots].sort((a, b) => {
        const distA = a.distance || Infinity;
        const distB = b.distance || Infinity;
        return distA - distB;
      });
    } else {
      // 恢复原始顺序
      this.loadCheckinSpots();
    }
  }

  // 获取附近打卡点数量
  private getNearbySpotsCount(): number {
    return this.checkinSpots.filter(spot =>
    spot.distance !== undefined && spot.distance <= spot.radius
    ).length;
  }

  // 格式化距离显示
  private formatDistance(meters: number): string {
    if (meters < 1000) {
      return `${meters}米`;
    } else {
      return `${(meters / 1000).toFixed(1)}公里`;
    }
  }

  // 查看点位详情
  private viewSpotDetail(spotId: number) {

    //spotId = spotId // for test
    console.log('查看点位详情:', spotId);
    // TODO: 跳转到点位详情页面
    router.pushUrl({
      url:"pages/SpotDetailPage",
      params:{spotId}
    })
  }

  // 打卡
  private checkIn(spotId: number) {
    console.log('打卡:', spotId);
    // TODO: 跳转到打卡页面
    router.push({
      url: 'pages/SubmitCheckInPage',
      params: {
        spotId: spotId,
        spotName: '打卡点名称', // 可以从spot对象获取
        latitude: 1, // for test
        longitude: 1
      }
    });

  }

  // 在地图上查看
  private viewOnMap(spot: CheckinSpot) {
    console.log('在地图上查看点位:', spot.name, spot.latitude, spot.longitude);
    // TODO: 跳转到地图页面
  }

  // ==================== 生命周期方法 ====================

  aboutToAppear() {
    console.log('打卡点位页面显示');

    // 获取用户当前位置（模拟）
    this.getUserLocation();

    // 加载打卡点位数据
    this.loadCheckinSpots();
  }

  // 获取用户位置
  private getUserLocation() {
    // TODO: 调用鸿蒙定位API获取当前位置
    console.log('获取用户位置...');

    // 模拟位置
    setTimeout(() => {
      this.userLocation = {
        lat: 23.11,
        lng: 113.33
      };
      console.log('用户位置已设置:', this.userLocation);
    }, 100);
  }

  // 加载打卡点位
  private async loadCheckinSpots() {
    console.log('开始加载打卡点位...');
    this.isLoading = true;

    const data:GetReq = {
      lat:1,
      lng:1,
      sort:"distance"
    }

    const result = await getCheckInSpots(data)
    if(result && result.length > 0){
      this.checkinSpots = result
      console.log('加载打卡点位完成');
      this.isLoading = false;
    }

    // // 暂时使用假数据
    // setTimeout(() => {
    //   console.log('加载打卡点位完成');
    //   this.checkinSpots = [...mockCheckinSpots];
    //   this.isLoading = false;
    // }, 1000);
  }

  aboutToDisappear() {
    console.log('打卡点位页面即将消失');
    // 清理资源
  }
}