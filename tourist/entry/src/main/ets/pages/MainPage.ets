// pages/MainPage.ets
import ProfilePage from './ProfilePage';
import ZonesPage from "./ZoneListPage";
import SpotsPage from './SpotListPage';

@Entry
@Component
struct MainPage {
  @State currentTab: number = 0;

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        // 首页 - 景区列表
        //this.buildZoneListPage()
        ZonesPage();
      }
      .tabBar('景区')

      TabContent() {
        // 首页 - 景区列表
        //this.buildZoneListPage()
        SpotsPage();
      }
      .tabBar('景点')

      TabContent() {
        // 地图打卡
        this.buildMapCheckInPage()
      }
      .tabBar('打卡')

      TabContent() {
        // 动态
        this.buildFeedListPage()
      }
      .tabBar('发现')

      TabContent() {
        // 个人中心
        ProfilePage()
      }
      .tabBar('我的')
    }
    .barMode(BarMode.Fixed)
    .backgroundColor(Color.White)
  }

  // 构建景区列表页面
  @Builder buildZoneListPage() {
    Column() {
      Text('景区列表页面')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('这里将显示景区列表')
        .fontSize(16)
        .fontColor('#666')
        .margin({ top: 10 })

      Button('查看景区')
        .margin({ top: 20 })
        .onClick(() => {
          // 这里可以添加跳转到详细页面的逻辑
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 构建地图打卡页面
  @Builder buildMapCheckInPage() {
    Column() {
      Text('地图打卡页面')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('这里将显示地图和打卡点')
        .fontSize(16)
        .fontColor('#666')
        .margin({ top: 10 })

      Button('开始打卡')
        .margin({ top: 20 })
        .onClick(() => {
          // 这里可以添加打卡逻辑
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 构建动态页面
  @Builder buildFeedListPage() {
    Column() {
      Text('动态页面')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('这里将显示用户动态')
        .fontSize(16)
        .fontColor('#666')
        .margin({ top: 10 })

      Button('刷新动态')
        .margin({ top: 20 })
        .onClick(() => {
          // 这里可以添加刷新动态的逻辑
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 构建个人中心页面
  @Builder buildProfilePage() {
    Column() {
      Text('个人中心')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      Text('这里将显示用户信息和设置')
        .fontSize(16)
        .fontColor('#666')
        .margin({ top: 10 })

      Button('退出登录')
        .margin({ top: 20 })
        .onClick(() => {
          // 这里可以添加退出登录逻辑
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}