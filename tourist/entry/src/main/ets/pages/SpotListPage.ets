import { ApiService } from '../services/ApiService';
import { Spot, SpotListResponse } from '../models/Spot';
import router from '@ohos.router';

@Component
struct SpotListPage {
  @State spots: Spot[] = [];
  @State isLoading: boolean = true;
  @State zoneId: number = 0;
  @State searchKeyword: string = '';
  private params: Record<string, string> = router.getParams() as Record<string, string>;

  aboutToAppear() {
    if (this.params && this.params.zoneId) {
      this.zoneId = parseInt(this.params.zoneId);
    }
    this.loadSpots();
  }

  build() {
    Column() {
      // 搜索栏 - 使用自定义搜索组件
      this.buildSearchBar()

      if (this.isLoading) {
        LoadingProgress()
          .color('#007DFF')
          .layoutWeight(1)
      } else {
        List({ space: 10 }) {
          ForEach(this.spots, (spot: Spot) => {
            ListItem() {
              SpotItem({ spot: spot })
            }
          }, (spot: Spot) => spot.spotId.toString())
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 构建搜索栏
  @Builder
  buildSearchBar() {
    Row() {
      TextInput({ placeholder: '搜索景点名称...', text: this.searchKeyword })
        .layoutWeight(1)
        .height(44)
        .backgroundColor(Color.White)
        .placeholderColor('#999')
        .caretColor('#007DFF')
        .margin({ left: 10, right: 10 })
        .onChange((value: string) => {
          this.searchKeyword = value;
        })
        .onSubmit(() => {
          // 忽略参数，直接使用 this.searchKeyword
          this.searchSpots(this.searchKeyword);
        })

      // 搜索按钮
      Button('搜索')
        .height(40)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .borderRadius(20)
        .margin({ left: 10 })
        .padding({ left: 15, right: 15 })
        .onClick(() => {
          this.searchSpots(this.searchKeyword);
        })
    }
    .width('90%')
    .margin(10)
  }

  private async loadSpots() {
    try {
      const response: SpotListResponse = await ApiService.getSpots(this.zoneId);
      if (response.code === 200 && response.data) {
        this.spots = response.data.list || [];
      }
    } catch (error) {
      console.error('加载景点列表失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  private async searchSpots(keyword: string) {
    this.isLoading = true;
    try {
      const response: SpotListResponse = await ApiService.getSpots(this.zoneId, undefined, keyword);
      if (response.code === 200 && response.data) {
        this.spots = response.data.list || [];
      }
    } catch (error) {
      console.error('搜索景点失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
}

@Component
struct SpotItem {
  @Prop spot: Spot;

  build() {
    Row() {
      // 景点图片 - 使用网络图片或默认颜色
      this.buildSpotImage()

      // 景点信息
      Column() {
        Text(this.spot.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)

        Text(this.spot.summary)
          .fontSize(14)
          .fontColor('#666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.spot.distance > 0) {
          Text(`距离 ${this.spot.distance}米`)
            .fontSize(12)
            .fontColor('#007DFF')
            .margin({ top: 5 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(10)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ left: 10, right: 10, top: 5, bottom: 5 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/SpotDetailPage',
        params: { spotId: this.spot.spotId.toString() }
      });
    })
  }

  // 构建景点图片
  @Builder
  buildSpotImage() {
    if (this.spot.thumbnail) {
      // 如果有缩略图，使用网络图片
      Image(this.spot.thumbnail)
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .margin({ right: 10 })
    } else {
      // 如果没有缩略图，使用默认背景
      Column() {
        Image($r('app.media.ic_public_picture_filled')) // 使用系统图标
          .width(30)
          .height(30)
          .fillColor('#999')
      }
      .width(80)
      .height(80)
      .backgroundColor('#F0F0F0')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .margin({ right: 10 })
    }
  }
}