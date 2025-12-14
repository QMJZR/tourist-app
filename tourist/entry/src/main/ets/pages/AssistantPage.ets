import { router } from '@kit.ArkUI';

// entry/src/main/ets/pages/AssistantPage.ets
@Entry
@Component
struct AssistantPage {

  // 生命周期：页面显示时
  aboutToAppear() {
    console.log('智能问答页面显示');
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
        Text('智能问答')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })
      .width('100%')
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // 主要内容区域
      Column() {
        Text('智能问答界面')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1890FF')
          .margin({ bottom: 20 })

        Text('这是智能问答功能页面')
          .fontSize(18)
          .fontColor('#666666')
          .margin({ bottom: 10 })

        Text('功能开发中...')
          .fontSize(16)
          .fontColor('#999999')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}