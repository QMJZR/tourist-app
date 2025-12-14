// entry/src/main/ets/pages/RankingPage.ets

import { router } from '@kit.ArkUI';

// 排行榜项接口定义
interface RankingItem {
  rank: number;          // 排名
  userId: number;       // 用户ID
  username: string;     // 用户名
  nickname: string;     // 用户昵称
  avatar: string;       // 用户头像
  score: number;       // 综合得分
  checkinCount: number; // 打卡次数
  likeCount: number;    // 点赞数量
  points: number;       // 积分
  trend: 'up' | 'down' | 'stable' | 'new'; // 排名趋势
}

// 时间维度类型
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
  @State rankingList: Array<RankingItem> = [];

  // 当前时间维度
  @State currentTimeDimension: TimeDimension = 'daily';

  // 时间维度选项
  private timeOptions: Array<TimeOption> = [
    { label: '今日', value: 'daily' },
    { label: '本周', value: 'weekly' },
    { label: '本月', value: 'monthly' }
  ];

  // 加载状态
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;

  // 用户自己的排名信息 - 初始化为 null
  @State myRanking: RankingItem | null = null;
  @State showMyRanking: boolean = true;

  // 生命周期：页面显示时
  aboutToAppear() {
    console.log('排行榜页面显示');
    this.loadRankingData();
  }

  // 加载排行榜数据（使用假数据）
  private loadRankingData() {
    this.isLoading = true;

    // 模拟网络请求延迟
    setTimeout(() => {
      // 生成假数据
      this.generateMockData();
      this.isLoading = false;
      this.isRefreshing = false;
      console.log(`✅ 加载${this.getTimeDimensionText()}排行榜数据成功`);
    }, 800);
  }

  // 生成假数据
  private generateMockData() {
    const mockData: Array<RankingItem> = [];
    const baseCheckinCount = [45, 38, 32, 28, 25, 22, 20, 18, 16, 15];
    const baseLikeCount = [1200, 950, 780, 620, 520, 450, 380, 320, 280, 240];

    // 根据时间维度调整数据
    let timeMultiplier = 1;
    if (this.currentTimeDimension === 'weekly') {
      timeMultiplier = 7;
    } else if (this.currentTimeDimension === 'monthly') {
      timeMultiplier = 30;
    }

    // 生成10个假数据
    for (let i = 0; i < 10; i++) {
      const checkinCount = baseCheckinCount[i] * timeMultiplier;
      const likeCount = baseLikeCount[i] * timeMultiplier;
      const score = Math.round((checkinCount * 3 + likeCount * 0.1) * 10) / 10; // 综合得分公式

      // 随机趋势
      const trends: Array<'up' | 'down' | 'stable' | 'new'> = ['up', 'down', 'stable'];
      const trend = i < 3 ? 'up' : (i > 7 ? 'new' : trends[Math.floor(Math.random() * trends.length)]);

      mockData.push({
        rank: i + 1,
        userId: 1000 + i,
        username: `user${1000 + i}`,
        nickname: ['旅行达人', '探险家', '摄影大师', '美食猎人', '文化使者', '徒步爱好者', '骑行侠', '背包客', '风景收藏家', '记录者'][i],
        avatar: `https://avatars.githubusercontent.com/u/${1000 + i}?v=4`,
        score: score,
        checkinCount: checkinCount,
        likeCount: likeCount,
        points: Math.floor(score * 10),
        trend: trend
      });
    }

    this.rankingList = mockData;

    // 生成用户自己的假数据（模拟当前用户）
    this.myRanking = {
      rank: Math.floor(Math.random() * 50) + 25, // 25-75名之间
      userId: 9999,
      username: 'currentUser',
      nickname: '我',
      avatar: 'https://avatars.githubusercontent.com/u/9999?v=4',
      score: Math.round((baseCheckinCount[5] * timeMultiplier * 3 + baseLikeCount[5] * timeMultiplier * 0.1) * 10) / 10,
      checkinCount: baseCheckinCount[5] * timeMultiplier,
      likeCount: baseLikeCount[5] * timeMultiplier,
      points: Math.floor(baseCheckinCount[5] * timeMultiplier * 10),
      trend: Math.random() > 0.5 ? 'up' : 'stable'
    };
  }

  // 切换时间维度
  private changeTimeDimension(dimension: TimeDimension) {
    if (this.currentTimeDimension === dimension) {
      return;
    }

    this.currentTimeDimension = dimension;
    this.isLoading = true;
    this.loadRankingData();
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

  // 获取排名趋势图标
  private getTrendIcon(trend: 'up' | 'down' | 'stable' | 'new'): string {
    switch (trend) {
      case 'up':
        return '↑';
      case 'down':
        return '↓';
      case 'stable':
        return '→';
      case 'new':
        return '✨';
      default:
        return '';
    }
  }

  // 获取排名趋势颜色
  private getTrendColor(trend: 'up' | 'down' | 'stable' | 'new'): ResourceColor {
    switch (trend) {
      case 'up':
        return '#FF3B30';
      case 'down':
        return '#007AFF';
      case 'stable':
        return '#666666';
      case 'new':
        return '#FF9500';
      default:
        return '#666666';
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

      // 排行榜规则说明
      Row({ space: 8 }) {
        Text('📊')
          .fontSize(14)
          .fontColor('#666666')

        Text('综合得分 = 打卡次数×3 + 点赞数×0.1')
          .fontSize(12)
          .fontColor('#999999')
          .lineHeight(16)
      }
      .width('100%')
      .padding({ top: 4, bottom: 4 })
    }
    .padding({ left: 16, right: 16, top: 16, bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
    .shadow({ radius: 4, color: '#00000008' })
  }

  // 构建用户自己的排名卡片
  @Builder
  buildMyRankingCard() {
    // 检查 myRanking 是否为 null
    if (!this.myRanking || !this.showMyRanking) {

    }

    // 使用 myRanking! 表示我们知道它不为 null
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('我的排名')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        // 切换显示/隐藏按钮
        Button(this.showMyRanking ? '隐藏' : '显示') {
          Text(this.showMyRanking ? '隐藏' : '显示')
            .fontSize(12)
            .fontColor('#007AFF')
        }
        .backgroundColor(Color.Transparent)
        .borderRadius(12)
        .padding({ left: 8, right: 8 })
        .height(24)
        .onClick(() => {
          this.showMyRanking = !this.showMyRanking;
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 我的排名信息
      Column({ space: 0 }) {
        Row({ space: 16 }) {
          // 排名
          Column({ space: 2 }) {
            Text(`#${this.myRanking!.rank}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF9500')

            // 趋势
            Row({ space: 2 }) {
              Text(this.getTrendIcon(this.myRanking!.trend))
                .fontSize(12)
                .fontColor(this.getTrendColor(this.myRanking!.trend))

              Text(this.myRanking!.trend === 'up' ? '上升' : this.myRanking!.trend === 'down' ? '下降' : '稳定')
                .fontSize(10)
                .fontColor('#999999')
            }
          }
          .alignItems(HorizontalAlign.Center)
          .width(60)

          // 用户信息
          Row({ space: 12 }) {
            // 头像 - 确保 avatar 不为空
            if (this.myRanking!.avatar && this.myRanking!.avatar.trim() !== '') {
              Image(this.myRanking!.avatar)
                .width(48)
                .height(48)
                .objectFit(ImageFit.Cover)
                .borderRadius(24)
            } else {
              // 默认头像
              Column() {
                Text('👤')
                  .fontSize(24)
                  .fontColor('#666666')
              }
              .width(48)
              .height(48)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor('#F0F0F0')
              .borderRadius(24)
            }

            // 用户详情
            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(this.myRanking!.nickname || '未知用户')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')

                // 趋势图标
                if (this.myRanking!.trend === 'new') {
                  Text('✨')
                    .fontSize(12)
                    .fontColor('#FF9500')
                }
              }

              Text(`@${this.myRanking!.username || 'unknown'}`)
                .fontSize(12)
                .fontColor('#999999')
            }
          }
          .layoutWeight(1)

          // 综合得分
          Column({ space: 2 }) {
            Text(`${this.myRanking!.score}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF3B30')

            Text('综合得分')
              .fontSize(10)
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

        // 统计数据
        Row({ space: 16 }) {
          Column({ space: 2 }) {
            Text(this.myRanking!.checkinCount.toString())
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#34C759')

            Text('打卡')
              .fontSize(10)
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)

          Column({ space: 2 }) {
            Text(this.myRanking!.likeCount.toString())
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#007AFF')

            Text('点赞')
              .fontSize(10)
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)

          Column({ space: 2 }) {
            Text(this.myRanking!.points.toString())
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FF9500')

            Text('积分')
              .fontSize(10)
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      }
      .backgroundColor('#F8F9FF')
      .borderRadius(12)
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 12 })
    .shadow({ radius: 4, color: '#00000008' })
  }

  // 构建排行榜项
  @Builder
  buildRankingItem(item: RankingItem, index: number) {
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
            Row({ space: 8 }) {
              Text(item.nickname || '未知用户')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)

              // 趋势图标
              if (item.trend !== 'stable') {
                Text(this.getTrendIcon(item.trend))
                  .fontSize(12)
                  .fontColor(this.getTrendColor(item.trend))
              }
            }

            Text(`@${item.username || 'unknown'}`)
              .fontSize(11)
              .fontColor('#999999')
          }
          .layoutWeight(1)
        }
        .layoutWeight(1)

        // 综合得分
        Column({ space: 2 }) {
          Text(item.score.toString())
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF3B30')

          Text('得分')
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
          ForEach(this.rankingList, (item: RankingItem, index: number) => {
            this.buildRankingItem(item, index)
          })
        }
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ left: 16, right: 16 })
        .shadow({ radius: 4, color: '#00000008' })
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

            // 我的排名卡片
            this.buildMyRankingCard()

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