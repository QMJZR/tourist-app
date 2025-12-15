// entry/src/main/ets/pages/PointsDetailPage.ets

import { router } from '@kit.ArkUI';
import { getPoints } from '../api/profile';

// 积分记录类型定义
interface PointsRecordLocal {
  recordId: number;
  type: string;  // "earn" | "spend"
  source: string;
  points: number;
  createdAt: string;
}

@Entry
@Component
struct PointsDetailPage {
  @State totalPoints: number = 0;  // 总积分
  @State pointsRecords: PointsRecordLocal[] = [];  // 积分记录列表
  @State currentPage: number = 1;  // 当前页码
  @State totalPages: number = 1;  // 总页数

  // 加载状态
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State isError: boolean = false;
  @State errorMessage: string = '';

  // 生命周期：页面显示时
  aboutToAppear() {
    console.log('积分详情页面显示');
    this.loadPointsData();
  }

  // 加载积分数据
  private async loadPointsData() {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    this.isError = false;

    try {
      const result = await getPoints(this.currentPage);

      if (result && result.code === 200 && result.data) {
        this.totalPoints = result.data.totalPoints || 0;
        this.pointsRecords = result.data.list || [];

        // 计算总页数
        const pageSize = result.data.pageSize || 10;
        const total = result.data.total || 0;
        this.totalPages = Math.ceil(total / pageSize);

        console.log(`✅ 加载积分数据成功，共${total}条记录，当前第${this.currentPage}页`);
      } else {
        this.isError = true;
        // 简化错误处理
        this.errorMessage = '获取积分数据失败';
        console.log('❌ 获取积分数据失败');
      }
    } catch (error) {
      this.isError = true;
      this.errorMessage = '网络请求失败，请检查网络连接';
      console.error('获取积分数据异常:', error);
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  // 刷新数据
  private async refreshData() {
    this.currentPage = 1;
    this.isRefreshing = true;
    await this.loadPointsData();
  }

  // 加载更多
  private async loadMore() {
    if (this.isLoading || this.currentPage >= this.totalPages) {
      return;
    }

    this.currentPage += 1;
    this.isLoading = true;

    try {
      const result = await getPoints(this.currentPage);

      if (result && result.code === 200 && result.data) {
        // 追加数据
        const newRecords = result.data.list || [];
        this.pointsRecords = [...this.pointsRecords, ...newRecords];

        console.log(`✅ 加载更多成功，当前共${this.pointsRecords.length}条记录`);
      }
    } catch (error) {
      console.error('加载更多异常:', error);
      // 回退页码
      this.currentPage -= 1;
    } finally {
      this.isLoading = false;
    }
  }

  // 格式化时间（去掉秒）
  private formatTime(createdAt: string): string {
    if (!createdAt) return '';
    // 将 "2025-01-11 14:20:33" 格式化为 "2025-01-11 14:20"
    return createdAt.substring(0, 16);
  }

  // 获取积分类型显示文本
  private getTypeText(type: string): string {
    switch (type) {
      case 'earn':
        return '获得';
      case 'spend':
        return '消耗';
      default:
        return type;
    }
  }

  // 获取积分类型颜色
  private getTypeColor(type: string): ResourceColor {
    switch (type) {
      case 'earn':
        return '#34C759';  // 绿色
      case 'spend':
        return '#FF3B30';  // 红色
      default:
        return '#666666';
    }
  }

  // 构建积分卡片
  @Builder
  buildPointsCard() {
    Column({ space: 12 }) {
      // 积分标题
      Text('我的积分')
        .fontSize(16)
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .width('100%')

      // 积分数值
      Row({ space: 8 }) {
        Text(this.totalPoints.toString())
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF9500')

        Text('分')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 20 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // 积分说明
      Text('积分可用于兑换礼品、参与活动等')
        .fontSize(14)
        .fontColor('#999999')
        .textAlign(TextAlign.Start)
        .width('100%')
        .margin({ top: 8 })
    }
    .padding({ left: 24, right: 24, top: 28, bottom: 28 })
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#FF950010' })
  }

  // 构建积分记录项
  @Builder
  buildPointsRecordItem(record: PointsRecordLocal, index: number) {
    Column() {
      Row({ space: 16 }) {
        // 左侧：类型图标
        Column() {
          if (record.type === 'earn') {
            Text('+')
              .fontSize(20)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          } else {
            Text('-')
              .fontSize(20)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(this.getTypeColor(record.type))
        .borderRadius(20)

        // 中间：详情
        Column({ space: 4 }) {
          // 来源
          Text(record.source)
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .width('100%')

          // 时间和类型
          Row({ space: 12 }) {
            Text(this.formatTime(record.createdAt))
              .fontSize(13)
              .fontColor('#999999')

            Text(this.getTypeText(record.type))
              .fontSize(13)
              .fontColor('#999999')
          }
          .width('100%')
        }
        .layoutWeight(1)

        // 右侧：积分值
        Text(record.type === 'earn' ? `+${record.points}` : `-${record.points}`)
          .fontSize(18)
          .fontColor(this.getTypeColor(record.type))
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })

      // 分隔线（不是最后一项时显示）
      if (index < this.pointsRecords.length - 1) {
        Divider()
          .color('#F0F0F0')
          .margin({ left: 72, right: 16 })
          .strokeWidth(0.5)
      }
    }
  }

  // 构建记录列表
  @Builder
  buildRecordsList() {
    Column() {
      // 列表标题
      Row({ space: 8 }) {
        Text('积分记录')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        if (this.totalPoints > 0) {
          Text(`共${this.pointsRecords.length}条`)
            .fontSize(12)
            .fontColor('#666666')
            .backgroundColor('#F0F0F0')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(10)
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 16 })

      // 记录列表
      if (this.pointsRecords.length > 0) {
        Column({ space: 0 }) {
          ForEach(this.pointsRecords, (record: PointsRecordLocal, index: number) => {
            this.buildPointsRecordItem(record, index)
          })
        }
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .shadow({ radius: 4, color: '#00000008' })

        // 加载更多提示
        if (this.currentPage < this.totalPages) {
          Column() {
            if (this.isLoading) {
              LoadingProgress()
                .width(24)
                .height(24)
                .color('#007AFF')
                .margin({ bottom: 8 })

              Text('加载中...')
                .fontSize(14)
                .fontColor('#666666')
            } else {
              Text('点击加载更多')
                .fontSize(14)
                .fontColor('#007AFF')
                .padding({ top: 16, bottom: 16 })
                .onClick(() => {
                  this.loadMore();
                })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ top: 20, bottom: 20 })
        }
      } else {
        // 空状态
        Column({ space: 16 }) {
          Text('⭐')
            .fontSize(60)
            .fontColor('#FFD700')

          Text('暂无积分记录')
            .fontSize(16)
            .fontColor('#999999')

          Text('快去打卡赚取积分吧！')
            .fontSize(14)
            .fontColor('#CCCCCC')
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

      Text('加载积分数据中...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 构建错误状态
  @Builder
  buildErrorView() {
    Column({ space: 16 }) {
      Text('加载失败')
        .fontSize(18)
        .fontColor('#FF3B30')
        .fontWeight(FontWeight.Medium)

      Text(this.errorMessage)
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .width('80%')

      Button('重新加载')
        .backgroundColor('#007AFF')
        .fontColor(Color.White)
        .fontSize(14)
        .width(120)
        .height(36)
        .onClick(() => {
          this.refreshData();
        })
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
        Text('积分详情')
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
          if (this.isLoading && !this.isRefreshing && this.pointsRecords.length === 0) {
            this.buildLoadingView()
          }
          // 显示错误状态
          else if (this.isError && this.pointsRecords.length === 0) {
            this.buildErrorView()
          }
          // 显示正常内容
          else {
            // 积分卡片
            Column() {
              this.buildPointsCard()
            }
            .padding({ left: 16, right: 16, top: 20, bottom: 16 })

            // 积分记录列表
            this.buildRecordsList()

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
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}