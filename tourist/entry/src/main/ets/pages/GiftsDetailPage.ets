// entry/src/main/ets/pages/GiftsDetailPage.ets

import { router } from '@kit.ArkUI';
import { getGifts, getAvailableGifts, getRedeemedGifts, GiftsApiResponse } from '../api/profile';

// 礼品记录类型定义
interface GiftRecordLocal {
  giftId: number;
  name: string;
  pointsRequired: number;
  status: string;  // "available" | "redeemed" | "expired"
  redeemedAt: string | null;
}

// 礼品类型定义
type GiftStatus = 'all' | 'available' | 'redeemed' | 'expired';

// 筛选按钮类型
interface FilterButton {
  label: string;
  value: GiftStatus;
}

@Entry
@Component
struct GiftsDetailPage {
  @State totalGifts: number = 0;  // 礼品总数
  @State totalAvailable: number = 0;  // 可兑换礼品数
  @State totalRedeemed: number = 0;  // 已兑换礼品数
  @State giftsRecords: Array<GiftRecordLocal> = [];  // 礼品记录列表
  @State currentPage: number = 1;  // 当前页码
  @State totalPages: number = 1;  // 总页数

  // 礼品筛选状态
  @State currentFilter: GiftStatus = 'all';  // 当前筛选状态

  // 使用明确的类型声明筛选按钮数组
  private filterButtons: Array<FilterButton> = [
    {label: '全部', value: 'all'},
    {label: '可兑换', value: 'available'},
    {label: '已兑换', value: 'redeemed'}
  ];

  // 加载状态
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State isError: boolean = false;
  @State errorMessage: string = '';

  // 生命周期：页面显示时
  aboutToAppear() {
    console.log('礼品详情页面显示');
    this.loadGiftsData();
  }

  // 加载礼品数据
  private async loadGiftsData() {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    this.isError = false;

    try {
      // 使用显式类型声明apiResult变量
      let apiResult: GiftsApiResponse | void | undefined;

      // 根据筛选状态调用不同的API函数
      if (this.currentFilter === 'available') {
        apiResult = await getAvailableGifts(this.currentPage);
      } else if (this.currentFilter === 'redeemed') {
        apiResult = await getRedeemedGifts(this.currentPage);
      } else {
        apiResult = await getGifts(this.currentPage, this.currentFilter);
      }

      // 简化类型检查：先判断是否有结果
      if (!apiResult) {
        this.isError = true;
        this.errorMessage = '获取礼品数据失败：无返回结果';
        console.log('❌ 获取礼品数据失败：无返回结果');
        return;
      }

      // 现在apiResult肯定不是void类型，进行类型断言
      const result = apiResult as GiftsApiResponse;

      if (result.code === 200 && result.data) {
        // 确保获取到的是数组类型
        const list: Array<GiftRecordLocal> = (result.data.list || []) as Array<GiftRecordLocal>;
        const total: number = result.data.total || 0;

        // 使用 concat 代替展开运算符
        if (this.currentPage === 1) {
          this.giftsRecords = list;
        } else {
          this.giftsRecords = this.giftsRecords.concat(list);
        }

        this.totalGifts = total;

        // 计算总页数
        const pageSize = 10;  // 默认每页10条
        this.totalPages = Math.ceil(total / pageSize);

        // 统计不同状态的礼品数量
        this.updateGiftCounts();

        console.log(`✅ 加载礼品数据成功，共${this.totalGifts}条记录，当前第${this.currentPage}页`);
      } else {
        this.isError = true;
        // 使用安全的方式访问msg属性
        const errorMsg = result.msg || '获取礼品数据失败';
        this.errorMessage = `错误：${errorMsg}`;
        console.log('❌ 获取礼品数据失败:', errorMsg);
      }
    } catch (error) {
      this.isError = true;
      this.errorMessage = '网络请求失败，请检查网络连接';
      console.error('获取礼品数据异常:', error);
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  // 更新礼品数量统计
  private updateGiftCounts() {
    // 使用显式类型转换和过滤
    const availableCount = this.giftsRecords.filter((gift: GiftRecordLocal) =>
    gift.status === 'available'
    ).length;

    const redeemedCount = this.giftsRecords.filter((gift: GiftRecordLocal) =>
    gift.status === 'redeemed'
    ).length;

    this.totalAvailable = availableCount;
    this.totalRedeemed = redeemedCount;
  }

  // 刷新数据
  private async refreshData() {
    this.currentPage = 1;
    this.isRefreshing = true;
    await this.loadGiftsData();
  }

  // 加载更多
  private async loadMore() {
    if (this.isLoading || this.currentPage >= this.totalPages) {
      return;
    }

    this.currentPage += 1;
    this.isLoading = true;

    try {
      // 使用显式类型声明apiResult变量
      let apiResult: GiftsApiResponse | void | undefined;

      if (this.currentFilter === 'available') {
        apiResult = await getAvailableGifts(this.currentPage);
      } else if (this.currentFilter === 'redeemed') {
        apiResult = await getRedeemedGifts(this.currentPage);
      } else {
        apiResult = await getGifts(this.currentPage, this.currentFilter);
      }

      // 简化类型检查
      if (!apiResult) {
        console.log('加载更多失败：无返回结果');
        this.currentPage -= 1;
        return;
      }

      const result = apiResult as GiftsApiResponse;

      if (result.code === 200 && result.data) {
        // 追加数据 - 使用 concat 代替展开运算符
        const newRecords: Array<GiftRecordLocal> = (result.data.list || []) as Array<GiftRecordLocal>;
        this.giftsRecords = this.giftsRecords.concat(newRecords);

        // 更新统计
        this.updateGiftCounts();

        console.log(`✅ 加载更多成功，当前共${this.giftsRecords.length}条记录`);
      }
    } catch (error) {
      console.error('加载更多异常:', error);
      // 回退页码
      this.currentPage -= 1;
    } finally {
      this.isLoading = false;
    }
  }

  // 切换筛选状态
  private changeFilter(filter: GiftStatus) {
    if (this.currentFilter === filter || this.isLoading) {
      return;
    }

    this.currentFilter = filter;
    this.currentPage = 1;
    this.giftsRecords = [];
    this.loadGiftsData();
  }

  // 格式化时间（去掉秒）
  private formatTime(timeString: string | null): string {
    if (!timeString) return '';
    // 将 "2025-01-11 14:20:33" 格式化为 "2025-01-11 14:20"
    return timeString.substring(0, 16);
  }

  // 获取礼品状态显示文本
  private getStatusText(status: string): string {
    switch (status) {
      case 'available':
        return '可兑换';
      case 'redeemed':
        return '已兑换';
      case 'expired':
        return '已过期';
      default:
        return status;
    }
  }

  // 获取礼品状态颜色
  private getStatusColor(status: string): ResourceColor {
    switch (status) {
      case 'available':
        return '#34C759';  // 绿色
      case 'redeemed':
        return '#007AFF';  // 蓝色
      case 'expired':
        return '#999999';  // 灰色
      default:
        return '#666666';
    }
  }

  // 获取状态背景色
  private getStatusBgColor(status: string): ResourceColor {
    switch (status) {
      case 'available':
        return '#E8F5E9';  // 浅绿色
      case 'redeemed':
        return '#E3F2FD';  // 浅蓝色
      case 'expired':
        return '#F5F5F5';  // 浅灰色
      default:
        return '#F5F5F5';
    }
  }

  // 构建礼品卡片
  @Builder
  buildGiftsCard() {
    Column({ space: 16 }) {
      // 礼品标题
      Text('我的礼品')
        .fontSize(16)
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .width('100%')

      // 礼品统计
      Row({ space: 12 }) {
        // 可兑换礼品
        Column({ space: 4 }) {
          Text(this.totalAvailable.toString())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#34C759')

          Text('可兑换')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        // 分隔线
        Divider()
          .vertical(true)
          .height(40)
          .color('#F0F0F0')

        // 已兑换礼品
        Column({ space: 4 }) {
          Text(this.totalRedeemed.toString())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')

          Text('已兑换')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        // 分隔线
        Divider()
          .vertical(true)
          .height(40)
          .color('#F0F0F0')

        // 礼品总数
        Column({ space: 4 }) {
          Text(this.totalGifts.toString())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9500')

          Text('总计')
            .fontSize(12)
            .fontColor('#999999')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })

      // 礼品说明
      Text('使用积分兑换心仪礼品，让旅行更有趣')
        .fontSize(14)
        .fontColor('#999999')
        .textAlign(TextAlign.Start)
        .width('100%')
        .margin({ top: 4 })
    }
    .padding({ left: 24, right: 24, top: 24, bottom: 24 })
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 8, color: '#FF950010' })
  }

  // 构建筛选栏
  @Builder
  buildFilterBar() {
    Row({ space: 12 }) {
      // 使用显式类型遍历数组
      ForEach(this.filterButtons, (button: FilterButton) => {
        Button(button.label) {
          Text(button.label)
            .fontSize(14)
            .fontColor(this.currentFilter === button.value ? Color.White : '#666666')
        }
        .backgroundColor(this.currentFilter === button.value ? '#007AFF' : '#F5F5F5')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .height(36)
        .onClick(() => {
          this.changeFilter(button.value);
        })
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 12 })
    .justifyContent(FlexAlign.Start)
  }

  // 构建礼品记录项
  @Builder
  buildGiftRecordItem(record: GiftRecordLocal, index: number) {
    Column() {
      Row({ space: 16 }) {
        // 左侧：礼品图标
        Column() {
          Text('🎁')
            .fontSize(20)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(this.getStatusColor(record.status))
        .borderRadius(20)

        // 中间：详情
        Column({ space: 4 }) {
          // 礼品名称
          Row({ space: 8 }) {
            Text(record.name)
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)

            // 状态标签
            Text(this.getStatusText(record.status))
              .fontSize(11)
              .fontColor(this.getStatusColor(record.status))
              .backgroundColor(this.getStatusBgColor(record.status))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
          }
          .width('100%')

          // 积分和兑换时间
          Row({ space: 12 }) {
            Text(`${record.pointsRequired}积分`)
              .fontSize(13)
              .fontColor('#FF9500')
              .backgroundColor('#FFF4E6')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)

            if (record.status === 'redeemed' && record.redeemedAt) {
              Text(`兑换时间: ${this.formatTime(record.redeemedAt)}`)
                .fontSize(11)
                .fontColor('#999999')
            }
          }
          .width('100%')
          .margin({ top: 4 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height(68)
      .padding({ left: 16, right: 16 })

      // 分隔线（不是最后一项时显示）
      if (index < this.giftsRecords.length - 1) {
        Divider()
          .color('#F0F0F0')
          .margin({ left: 72, right: 16 })
          .strokeWidth(0.5)
      }
    }
  }

  // 构建兑换按钮
  @Builder
  buildRedeemButton(gift: GiftRecordLocal) {
    Button('立即兑换')
      .backgroundColor('#FF9500')
    .borderRadius(8)
    .height(32)
    .padding({ left: 12, right: 12 })
    .enabled(gift.status === 'available')
    .onClick(() => {
      console.log('兑换礼品:', gift.name);
      // 这里可以添加兑换逻辑
    })
  }

  // 构建记录列表
  @Builder
  buildRecordsList() {
    Column() {
      // 列表标题
      Row({ space: 8 }) {
        Text('礼品列表')
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        if (this.totalGifts > 0) {
          Text(`共${this.totalGifts}个`)
            .fontSize(12)
            .fontColor('#666666')
            .backgroundColor('#F0F0F0')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(10)
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })

      // 筛选栏
      this.buildFilterBar()

      // 礼品列表
      if (this.giftsRecords.length > 0) {
        Column({ space: 0 }) {
          ForEach(this.giftsRecords, (record: GiftRecordLocal, index: number) => {
            Column() {
              this.buildGiftRecordItem(record, index)

              // 可兑换礼品显示兑换按钮
              if (record.status === 'available') {
                Row() {
                  Row()
                    .width(56)  // 左侧占位，对齐图标区域

                  this.buildRedeemButton(record)
                }
                .width('100%')
                .padding({ left: 16, right: 16, bottom: 12 })
              }
            }
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
          Text('🎁')
            .fontSize(60)
            .fontColor('#FF9500')

          Text('暂无礼品记录')
            .fontSize(16)
            .fontColor('#999999')

          if (this.currentFilter === 'available') {
            Text('快去赚取积分兑换礼品吧！')
              .fontSize(14)
              .fontColor('#CCCCCC')
          } else if (this.currentFilter === 'redeemed') {
            Text('还没有兑换过礼品哦')
              .fontSize(14)
              .fontColor('#CCCCCC')
          } else {
            Text('暂无礼品')
              .fontSize(14)
              .fontColor('#CCCCCC')
          }
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

      Text('加载礼品数据中...')
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
        Text('礼品详情')
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
          if (this.isLoading && !this.isRefreshing && this.giftsRecords.length === 0) {
            this.buildLoadingView()
          }
          // 显示错误状态
          else if (this.isError && this.giftsRecords.length === 0) {
            this.buildErrorView()
          }
          // 显示正常内容
          else {
            // 礼品卡片
            Column() {
              this.buildGiftsCard()
            }
            .padding({ left: 16, right: 16, top: 20, bottom: 16 })

            // 礼品记录列表
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