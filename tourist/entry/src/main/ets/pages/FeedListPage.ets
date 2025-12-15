// entry/src/main/ets/pages/FeedsListPage.ets
import router from '@ohos.router';
import { getFeeds, likeFeed, unlikeFeed, FeedItem, PageResponse, FeedsParams } from '../api/feeds';

// 正确的假数据 - 基于 FeedItem 接口
const mockFeedItems: FeedItem[] = [
  {
    feedId: 1001,
    userId: 2001,
    username: '游客小明',
    avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&auto=format&fit=crop',
    spotId: 301,
    spotName: '山顶观景台',
    content: '今天打卡了山顶观景台，风景太美了！站在山顶俯瞰整个园区，心旷神怡。下次还要带家人一起来！',
    likes: 12,
    liked: false,
    createdAt: '2025-01-11 14:20:33'
  },
  {
    feedId: 1002,
    userId: 2002,
    username: '旅行达人',
    avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&auto=format&fit=crop',
    spotId: 302,
    spotName: '湖畔栈道',
    content: '湖畔栈道的傍晚太美了，夕阳洒在湖面上，金色的波光粼粼。拍了超多美照，分享给大家！',
    likes: 25,
    liked: true,
    createdAt: '2025-01-10 18:15:22'
  },
  {
    feedId: 1003,
    userId: 2003,
    username: '摄影爱好者',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop',
    spotId: 303,
    spotName: '瀑布观景台',
    content: '瀑布的水雾中看到了彩虹！太幸运了，分享几张照片给大家看看。摄影小贴士：早晨光线最佳。',
    likes: 42,
    liked: false,
    createdAt: '2025-01-09 10:05:18'
  },
  {
    feedId: 1004,
    userId: 2004,
    username: '户外爱好者',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop',
    spotId: 304,
    spotName: '花园广场',
    content: '花园广场的花都开了，香气扑鼻，很适合放松心情。周末来这里野餐是个不错的选择。',
    likes: 8,
    liked: false,
    createdAt: '2025-01-08 16:30:45'
  },
  {
    feedId: 1005,
    userId: 2005,
    username: '背包客',
    avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop',
    spotId: 305,
    spotName: '山间步道',
    content: '走了三小时的山间步道，虽然累但是值得！沿途风景如画，空气清新，强烈推荐给喜欢徒步的朋友。',
    likes: 18,
    liked: true,
    createdAt: '2025-01-07 09:45:12'
  }
];

// 分页假数据
const mockFeedsPageResponse: PageResponse<FeedItem> = {
  list: mockFeedItems,
  page: 1,
  pageSize: 10,
  total: 156
};

@Entry
@Component
export default struct FeedsListPage {
  // 动态列表数据
  @State feedItems: FeedItem[] = [];

  // 分页信息
  @State pageInfo: PageResponse<FeedItem> | null = null;

  // 加载状态
  @State isLoading: boolean = true;

  // 排序方式
  @State sortBy: string = 'latest';

  // 当前页码
  @State currentPage: number = 1;

  // 搜索关键词
  @State searchKeyword: string = '';

  // 页面构建
  build() {
    Column() {
      // 顶部导航栏
      this.buildNavigationBar()

      // 筛选工具栏
      this.buildFilterToolbar()

      // 内容区域
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (this.feedItems.length === 0) {
        this.buildEmptyView()
      } else {
        this.buildFeedsList()
      }

      // 分页控件
      if (this.pageInfo && this.pageInfo.total > this.pageInfo.pageSize) {
        this.buildPagination()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .padding({ bottom: 60 })
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
        Text('动态广场')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .layoutWeight(1)

        // 发布按钮
        Button('发布')
          .fontSize(14)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.onPublish();
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
      // 搜索框
      Row({ space: 10 }) {
        TextInput({ text: this.searchKeyword, placeholder: '搜索动态内容' })
          .placeholderColor('#999999')
          .caretColor('#007AFF')
          .fontColor('#333333')
          .fontSize(14)
          .height(40)
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#E0E0E0' })
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchKeyword = value;
          })

        Button('搜索')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#007AFF')
          .height(40)
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.currentPage = 1;
            this.loadFeeds();
          })
      }
      .width('100%')
      .padding({ left: 15, right: 15, top: 10, bottom: 10 })

      // 排序选项和统计信息
      Row({ space: 10 }) {
        Button(this.sortBy === 'latest' ? '最新 ✓' : '最新')
          .fontSize(14)
          .fontColor(this.sortBy === 'latest' ? '#007AFF' : '#666666')
          .backgroundColor(this.sortBy === 'latest' ? '#007AFF10' : '#F0F0F0')
          .height(32)
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.changeSort('latest');
          })

        Button(this.sortBy === 'popular' ? '热门 ✓' : '热门')
          .fontSize(14)
          .fontColor(this.sortBy === 'popular' ? '#007AFF' : '#666666')
          .backgroundColor(this.sortBy === 'popular' ? '#007AFF10' : '#F0F0F0')
          .height(32)
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.changeSort('popular');
          })

        // 统计信息
        if (this.pageInfo) {
          Text(`共 ${this.pageInfo.total} 条动态`)
            .fontSize(14)
            .fontColor('#666666')
            .layoutWeight(1)
            .textAlign(TextAlign.End)
        }
      }
      .width('100%')
      .padding({ left: 15, right: 15 })
    }
    .width('100%')
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
      Text('正在加载动态...')
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
      Text('暂无动态')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 10 })
      Text('快来发布第一条动态吧！')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // ==================== 动态列表 ====================
  @Builder
  buildFeedsList() {
    List({ space: 10 }) {
      ForEach(this.feedItems, (feed: FeedItem) => {
        ListItem() {
          this.buildFeedCard(feed)
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .padding({ left: 15, right: 15, top: 10 })
  }

  // ==================== 动态卡片 ====================
  @Builder
  buildFeedCard(feed: FeedItem) {
    Column({ space: 0 }) {
      // 用户信息行
      Row({ space: 10 }) {
        // 用户头像
        Image(feed.avatar)
          .width(40)
          .height(40)
          .borderRadius(20)
          .objectFit(ImageFit.Cover)

        // 用户信息
        Column({ space: 4 }) {
          Text(feed.username)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')

          Row({ space: 8 }) {
            Text(feed.spotName)
              .fontSize(12)
              .fontColor('#007AFF')

            Text('•')
              .fontSize(12)
              .fontColor('#999999')

            Text(this.formatTime(feed.createdAt))
              .fontSize(12)
              .fontColor('#999999')
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ top: 12, left: 12, right: 12 })

      // 动态内容
      Column() {
        Text(feed.content)
          .fontSize(15)
          .fontColor('#333333')
          .lineHeight(22)
          .textAlign(TextAlign.Start)
          .width('100%')
      }
      .width('100%')
      .padding({ top: 12, left: 12, right: 12 })

      // 互动操作栏
      Row() {
        // 点赞按钮
        Row({ space: 5 }) {
          Button(feed.liked ? '已赞' : '点赞')
            .fontSize(14)
            .fontColor(feed.liked ? '#FF3B30' : '#666666')
            .backgroundColor(Color.Transparent)
            .height(36)
            .borderRadius(18)
            .padding({ left: 12, right: 12 })
            .onClick(() => {
              this.toggleLike(feed);
            })

          Text(feed.likes.toString())
            .fontSize(14)
            .fontColor(feed.liked ? '#FF3B30' : '#666666')
        }

        // 查看详情按钮
        Button('查看详情 →')
          .fontSize(14)
          .fontColor('#007AFF')
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onClick(() => {
            this.viewFeedDetail(feed.feedId);
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12, left: 12, right: 12 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 10 })
    .shadow({ radius: 4, color: '#0000000A' })
  }

  // ==================== 分页控件 ====================
  @Builder
  buildPagination() {
    Column() {
      Row({ space: 10 }) {
        // 上一页按钮
        Button('上一页')
          .fontSize(14)
          .fontColor(this.currentPage > 1 ? '#007AFF' : '#999999')
          .backgroundColor(Color.Transparent)
          .enabled(this.currentPage > 1)
          .onClick(() => {
            if (this.currentPage > 1) {
              this.currentPage--;
              this.loadFeeds();
            }
          })

        // 页码显示
        if (this.pageInfo) {
          Text(`${this.currentPage} / ${this.calculateTotalPages()}`)
            .fontSize(14)
            .fontColor('#666666')
        }

        // 下一页按钮
        Button('下一页')
          .fontSize(14)
          .fontColor(this.pageInfo && this.currentPage < this.calculateTotalPages() ? '#007AFF' : '#999999')
          .backgroundColor(Color.Transparent)
          .enabled(this.pageInfo && this.currentPage < this.calculateTotalPages())
          .onClick(() => {
            if (this.pageInfo && this.currentPage < this.calculateTotalPages()) {
              this.currentPage++;
              this.loadFeeds();
            }
          })
      }
      .width('100%')
      .padding({ left: 15, right: 15 })
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(Color.White)
    .margin({ top: 2 })
  }

  // ==================== 交互方法 ====================

  // 计算总页数的方法
  private calculateTotalPages(): number {
    if (this.pageInfo) {
      return Math.ceil(this.pageInfo.total / this.pageInfo.pageSize);
    }
    return 1;
  }

  // 切换排序方式
  private changeSort(sortType: string) {
    this.sortBy = sortType;
    this.currentPage = 1;
    this.loadFeeds();
  }

  // 格式化时间显示
  private formatTime(dateString: string): string {
    try {
      const date = new Date(dateString);
      const now = new Date();
      const diffMs = now.getTime() - date.getTime();
      const diffMins = Math.floor(diffMs / 60000);
      const diffHours = Math.floor(diffMs / 3600000);
      const diffDays = Math.floor(diffMs / 86400000);

      if (diffMins < 1) return '刚刚';
      if (diffMins < 60) return `${diffMins}分钟前`;
      if (diffHours < 24) return `${diffHours}小时前`;
      if (diffDays < 7) return `${diffDays}天前`;

      // 返回日期格式
      return dateString.substring(0, 10).replace(/-/g, '/');
    } catch (e) {
      return dateString;
    }
  }

  // 切换点赞状态
  private async toggleLike(feed: FeedItem) {
    const originalLiked = feed.liked;
    const originalLikes = feed.likes;

    // 立即更新UI
    feed.liked = !feed.liked;
    feed.likes = feed.liked ? feed.likes + 1 : Math.max(0, feed.likes - 1);
    this.feedItems = [...this.feedItems]; // 触发重新渲染

    try {
      if (feed.liked) {
        // 点赞
        const result = await likeFeed(feed.feedId);
        if (result) {
          console.log('点赞成功:', result);
          // 更新数据
          feed.likes = result.likes;
          feed.liked = result.liked;
          this.feedItems = [...this.feedItems];
        } else {
          // 如果请求失败，恢复原状态
          feed.liked = originalLiked;
          feed.likes = originalLikes;
          this.feedItems = [...this.feedItems];
        }
      } else {
        // 取消点赞
        const result = await unlikeFeed(feed.feedId);
        if (result) {
          console.log('取消点赞成功:', result);
          // 更新数据
          feed.likes = result.likes;
          feed.liked = result.liked;
          this.feedItems = [...this.feedItems];
        } else {
          // 如果请求失败，恢复原状态
          feed.liked = originalLiked;
          feed.likes = originalLikes;
          this.feedItems = [...this.feedItems];
        }
      }
    } catch (error) {
      console.error('点赞操作失败:', error);
      // 恢复原状态
      feed.liked = originalLiked;
      feed.likes = originalLikes;
      this.feedItems = [...this.feedItems];
    }
  }

  // 查看动态详情
  private viewFeedDetail(feedId: number) {
    console.log('查看动态详情:', feedId);
    // TODO: 跳转到动态详情页面
    // router.push({
    //   url: 'pages/FeedDetailPage',
    //   params: { feedId }
    // });
  }

  // 发布动态
  private onPublish() {
    console.log('发布动态');
    // TODO: 跳转到发布页面
    // router.push({
    //   url: 'pages/PublishFeedPage'
    // });
  }

  // ==================== 生命周期方法 ====================

  aboutToAppear() {
    console.log('动态列表页面显示');
    this.loadFeeds();
  }

  // 加载动态数据
  private async loadFeeds() {
    console.log('开始加载动态数据，页码:', this.currentPage, '排序:', this.sortBy);
    this.isLoading = true;

    try {
      // 指定 params 的类型为 FeedsParams
      const params: FeedsParams = {
        page: this.currentPage,
        pageSize: 10,
        sort: this.sortBy,
        keyword: this.searchKeyword || undefined
      };

      const result = await getFeeds(params);
      if (result) {
        this.pageInfo = result;
        this.feedItems = result.list;
        console.log('动态数据加载成功，共', result.total, '条动态，当前页', result.list.length, '条');
        // for test ,use false data
        this.pageInfo = mockFeedsPageResponse;
        this.feedItems = mockFeedItems;
      } else {
        // 如果API返回空，使用假数据
        console.log('API返回空数据，使用假数据');
        this.pageInfo = mockFeedsPageResponse;
        this.feedItems = mockFeedItems;
      }
    } catch (error) {
      console.error('加载动态数据失败:', error);
      // 使用假数据
      this.pageInfo = mockFeedsPageResponse;
      this.feedItems = mockFeedItems;
    } finally {
      this.isLoading = false;
    }
  }

  aboutToDisappear() {
    console.log('动态列表页面即将消失');
  }
}