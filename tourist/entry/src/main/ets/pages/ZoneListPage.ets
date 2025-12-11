import { ApiService } from '../services/ApiService';
import { Zone, ZoneListResponse } from '../models/Zone';
import router from '@ohos.router';

@Component
struct ZoneListPage {
  @State zones: Zone[] = [];
  @State isLoading: boolean = true;

  aboutToAppear() {
    this.loadZones();
  }

  build() {
    Column() {
      if (this.isLoading) {
        LoadingProgress()
          .color('#007DFF')
          .layoutWeight(1)
      } else {
        List({ space: 10 }) {
          ForEach(this.zones, (zone: Zone) => {
            ListItem() {
              ZoneItem({ zone: zone })
            }
          }, (zone: Zone) => zone.zoneId.toString())
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  private async loadZones() {
    try {
      const response: ZoneListResponse = await ApiService.getZones();
      if (response.code === 200) {
        this.zones = response.data || [];
      }
    } catch (error) {
      console.error('加载景区列表失败:', error);
    } finally {
      this.isLoading = false;
    }
  }
}

@Component
struct ZoneItem {
  @Prop zone: Zone;

  build() {
    Column() {
      // Banner图片
      if (this.zone.banner && this.zone.banner.length > 0) {
        Image(this.zone.banner[0])
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
      } else {
        // 默认图片 - 需要先在resources中定义
        // Image($r('app.media.default_banner'))
        //   .width('100%')
        //   .height(200)
        //   .objectFit(ImageFit.Cover)
        //   .borderRadius(8)
      }

      // 景区信息
      Row() {
        Column() {
          Text(this.zone.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Start)

          Text(this.zone.description)
            .fontSize(14)
            .fontColor('#666')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .padding(10)
      .width('100%')
    }
    .backgroundColor(Color.White)
    .borderRadius(8)
    .padding(10)
    .margin({ left: 10, right: 10, top: 5, bottom: 5 })
    .onClick(() => {
      // 跳转到景点列表页
      router.pushUrl({
        url: 'pages/SpotListPage',
        params: { zoneId: this.zone.zoneId.toString() }
      });
    })
  }
}