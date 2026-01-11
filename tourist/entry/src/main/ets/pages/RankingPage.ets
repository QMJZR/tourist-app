// entry/src/main/ets/pages/RankingPage.ets

import { router } from '@kit.ArkUI';
import { getRankings, RankingsApiResponse, getDailyRankings, getWeeklyRankings, getMonthlyRankings } from '../api/ranking';

// 排行榜项接口定义（与API接口完全一致）
interface RankingItemLocal {
  rank: number;          // 排名
  userId: number;       // 用户ID
  username: string;     // 用户名
  avatar: string;       // 用户头像
  score: number;       // 综合评分
  checkinCount: number; // 打卡次数
  likeCount: number;    // 点赞数量
}

// 时间维度类型（与API一致）
type TimeDimension = 'daily' | 'weekly' | 'monthly';

// 时间维度选项
interface TimeOption {
  label: string;
  value: TimeDimension;
}

@Entry
@Component
struct RankingPage {
  // 排行榜数据
  @State rankingList: Array<RankingItemLocal> = [];

  // 当前时间维度
  @State currentTimeDimension: TimeDimension = 'weekly';

  // 时间维度选项
  private timeOptions: Array<TimeOption> = [
    { label: '今日', value: 'daily' },
    { label: '本周', value: 'weekly' },
    { label: '本月', value: 'monthly' }
  ];

  // 加载状态
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State apiFailed: boolean = false; // API调用失败标记

  // 生命周期：页面显示时
  aboutToAppear() {
    console.log('排行榜页面显示');
    this.loadRankingData();
  }

  // 加载排行榜数据（优先调用接口）
  private async loadRankingData() {
    this.isLoading = true;
    this.apiFailed = false;

    console.log('开始加载排行榜数据...');

    try {
      let response: RankingsApiResponse | void;

      // 根据时间维度调用不同的接口
      switch (this.currentTimeDimension) {
        case 'daily':
          response = await getDailyRankings();
          break;
        case 'weekly':
          response = await getWeeklyRankings();
          break;
        case 'monthly':
          response = await getMonthlyRankings();
          break;
        default:
          response = await getWeeklyRankings();
      }

      // 使用类型断言
      const typedResponse = response as RankingsApiResponse;

      if (typedResponse && typedResponse.code === 200 && typedResponse.data) {
        console.log('✅ 排行榜接口调用成功，获取到', typedResponse.data.list.length, '条记录');
        this.processApiData(typedResponse);
        this.isLoading = false;
        this.isRefreshing = false;
        return;
      } else {
        console.warn('排行榜接口返回数据异常，使用假数据');
        this.apiFailed = true;
      }
    } catch (error) {
      console.error('排行榜接口调用失败:', error);
      this.apiFailed = true;
    }

    // 如果接口调用失败，使用假数据
    console.log('使用假数据');
    this.useMockData();
  }

  // 处理API返回的数据
  private processApiData(response: RankingsApiResponse) {
    if (!response.data) {
      console.warn('API返回数据为空');
      return;
    }

    console.log('处理API排行榜数据:', response.data);

    // 转换排行榜列表数据
    const convertedList: RankingItemLocal[] = response.data.list.map((apiItem, index: number) => {
      const item: RankingItemLocal = {
        rank: apiItem.rank || index + 1,
        userId: apiItem.userId,
        username: apiItem.username || `用户${apiItem.userId}`,
        avatar: apiItem.avatar || this.getDefaultAvatar(apiItem.userId),
        score: apiItem.score || 0,
        checkinCount: apiItem.totalCheckins || 0,
        likeCount: apiItem.totalLikes || 0
      };
      return item;
    });

    this.rankingList = convertedList;

    console.log('数据转换完成，共', this.rankingList.length, '条记录');
  }

  // 获取默认头像
  private getDefaultAvatar(userId: number): string {
    return `https://avatars.githubusercontent.com/u/${userId % 1000}?v=4`;
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

  // 生成假数据（适配API数据结构）
  private generateMockData() {
    const mockData: Array<RankingItemLocal> = [];
    const baseCheckinCount = [45, 38, 32, 28, 25, 22, 20, 18, 16, 15];
    const baseLikeCount = [1200, 950, 780, 620, 520, 450, 380, 320, 280, 240];

    // 根据时间维度调整数据
    let timeMultiplier = 1;
    if (this.currentTimeDimension === 'daily') {
      timeMultiplier = 1;
    } else if (this.currentTimeDimension === 'weekly') {
      timeMultiplier = 7;
    } else if (this.currentTimeDimension === 'monthly') {
      timeMultiplier = 30;
    }

    // 生成10个假数据
    for (let i = 0; i < 10; i++) {
      const checkinCount = baseCheckinCount[i] * timeMultiplier;
      const likeCount = baseLikeCount[i] * timeMultiplier;
      const score = Math.round((checkinCount * 3 + likeCount * 0.1) * 10) / 10;

      mockData.push({
        rank: i + 1,
        userId: 1000 + i,
        username: `user${1000 + i}`,
        avatar: `https://avatars.githubusercontent.com/u/${1000 + i}?v=4`,
        score: score,
        checkinCount: checkinCount,
        likeCount: likeCount
      });
    }

    this.rankingList = mockData;
  }

  // 切换时间维度
  private async changeTimeDimension(dimension: TimeDimension) {
    if (this.currentTimeDimension === dimension) {
      return;
    }

    this.currentTimeDimension = dimension;
    this.isLoading = true;

    // 如果API之前失败了，直接使用假数据
    if (this.apiFailed) {
      setTimeout(() => {
        this.generateMockData();
        this.isLoading = false;
        console.log(`✅ 切换${this.getTimeDimensionText()}维度，使用假数据`);
      }, 500);
      return;
    }

    // 否则尝试重新调用API
    try {
      let response: RankingsApiResponse | void;

      // 根据时间维度调用不同的接口
      switch (dimension) {
        case 'daily':
          response = await getDailyRankings();
          break;
        case 'weekly':
          response = await getWeeklyRankings();
          break;
        case 'monthly':
          response = await getMonthlyRankings();
          break;
        default:
          response = await getWeeklyRankings();
      }

      const typedResponse = response as RankingsApiResponse;

      if (typedResponse && typedResponse.code === 200 && typedResponse.data) {
        console.log('✅ 切换维度接口调用成功');
        this.processApiData(typedResponse);
      } else {
        console.warn('切换维度接口调用失败，使用本地数据');
        this.generateMockData();
      }
    } catch (error) {
      console.error('切换维度接口调用异常，使用本地数据:', error);
      this.generateMockData();
    } finally {
      this.isLoading = false;
    }
  }

  // 获取时间维度文本
  private getTimeDimensionText(): string {
    switch (this.currentTimeDimension) {
      case 'daily':
        return '今日';
      case 'weekly':
        return '本周';
      case 'monthly':
        return '本月';
      default:
        return '';
    }
  }

  // 刷新数据
  private refreshData() {
    this.isRefreshing = true;
    this.loadRankingData();
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
            this.refreshData();
          })
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#FFF8E6')
      .borderRadius(8)
      .margin({ left: 16, right: 16, top: 8 })
      .shadow({ radius: 2, color: '#00000004' })
    }
  }

  // 获取排名徽章颜色
  private getRankBadgeColor(rank: number): string {
    switch (rank) {
      case 1:
        return '#FFD700'; // 金色
      case 2:
        return '#C0C0C0'; // 银色
      case 3:
        return '#CD7F32'; // 铜色
      default:
        return '#34C759'; // 绿色
    }
  }

  // 构建时间筛选器
  @Builder
  buildTimeFilter() {
    Column({ space: 12 }) {
      Text('排行榜')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .textAlign(TextAlign.Start)
        .width('100%')

      Row({ space: 8 }) {
        ForEach(this.timeOptions, (option: TimeOption) => {
          Button(option.label) {
            Text(option.label)
              .fontSize(14)
              .fontColor(this.currentTimeDimension === option.value ? Color.White : '#666666')
          }
          .backgroundColor(this.currentTimeDimension === option.value ? '#007AFF' : '#F5F5F5')
          .borderRadius(20)
          .padding({ left: 20, right: 20 })
          .height(36)
          .onClick(() => {
            this.changeTimeDimension(option.value);
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .padding({ left: 16, right: 16, top: 16, bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
    .shadow({ radius: 4, color: '#00000008' })
  }

  // 构建排行榜项
  @Builder
  buildRankingItem(item: RankingItemLocal, index: number) {
    Column() {
      Row({ space: 16 }) {
        // 排名徽章
        Column({ space: 2 }) {
          Text(item.rank.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.rank <= 3 ? Color.White : '#333333')
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(this.getRankBadgeColor(item.rank))
        .borderRadius(18)

        // 用户信息
        Row({ space: 12 }) {
          // 头像 - 确保 avatar 不为空
          if (item.avatar && item.avatar.trim() !== '') {
            Image(item.avatar)
              .width(40)
              .height(40)
              .objectFit(ImageFit.Cover)
              .borderRadius(20)
          } else {
            // 默认头像
            Column() {
              Text('👤')
                .fontSize(20)
                .fontColor('#666666')
            }
            .width(40)
            .height(40)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#F0F0F0')
            .borderRadius(20)
          }

          // 用户详情
          Column({ space: 4 }) {
            Text(item.username || '未知用户')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
        }
        .layoutWeight(1)

        // 综合评分
        Column({ space: 2 }) {
          Text(item.score.toFixed(1))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF3B30')

          Text('评分')
            .fontSize(10)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })

      // 分隔线（不是最后一项时显示）
      if (index < this.rankingList.length - 1) {
        Divider()
          .color('#F0F0F0')
          .margin({ left: 68, right: 16 })
          .strokeWidth(0.5)
      }
    }
  }

  // 构建排行榜列表
  @Builder
  buildRankingList() {
    Column() {
      // API失败提示
      this.buildApiFailNotice()

      // 列表标题
      Row({ space: 8 }) {
        Text(`${this.getTimeDimensionText()}排行榜`)
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Text(`共${this.rankingList.length}人`)
          .fontSize(12)
          .fontColor('#666666')
          .backgroundColor('#F0F0F0')
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(10)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 16 })

      // 排行榜列表
      if (this.rankingList.length > 0) {
        Column({ space: 0 }) {
          ForEach(this.rankingList, (item: RankingItemLocal, index: number) => {
            this.buildRankingItem(item, index)
          })
        }
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .shadow({ radius: 4, color: '#00000008' })

        // 详细数据展示
        if (this.rankingList.length > 0) {
          Column({ space: 8 }) {
            Row({ space: 12 }) {
              Column({ space: 2 }) {
                Text(this.rankingList[0].checkinCount.toString())
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#34C759')

                Text('最高打卡')
                  .fontSize(10)
                  .fontColor('#999999')
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)

              Column({ space: 2 }) {
                Text(this.rankingList[0].likeCount.toString())
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#007AFF')

                Text('最高点赞')
                  .fontSize(10)
                  .fontColor('#999999')
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)

              Column({ space: 2 }) {
                Text(this.rankingList[0].score.toFixed(1))
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FF9500')

                Text('最高评分')
                  .fontSize(10)
                  .fontColor('#999999')
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          }
          .backgroundColor('#F8F9FF')
          .borderRadius(12)
          .margin({ left: 16, right: 16, top: 12 })
          .shadow({ radius: 2, color: '#00000004' })
        }
      } else {
        // 空状态
        Column({ space: 16 }) {
          Text('🏆')
            .fontSize(60)
            .fontColor('#FFD700')

          Text('暂无排行榜数据')
            .fontSize(16)
            .fontColor('#999999')

          Text('快来打卡获取积分，冲上排行榜吧！')
            .fontSize(14)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .padding(40)
        .alignItems(HorizontalAlign.Center)
      }

      // 底部说明
      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Text('📈')
            .fontSize(12)
            .fontColor('#666666')

          Text('榜单每15分钟更新一次')
            .fontSize(12)
            .fontColor('#999999')
        }

        Row({ space: 8 }) {
          Text('💡')
            .fontSize(12)
            .fontColor('#666666')

          Text('多发优质内容可以获得更多点赞哦！')
            .fontSize(12)
            .fontColor('#999999')
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .alignItems(HorizontalAlign.Start)
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

      Text('加载排行榜数据中...')
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
        Text('旅行排行榜')
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
            // 时间筛选器
            this.buildTimeFilter()

            // 排行榜列表
            this.buildRankingList()

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