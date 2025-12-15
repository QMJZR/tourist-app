// entry/src/main/ets/pages/AssistantPage.ets

import { router } from '@kit.ArkUI';
import { askSimple, AskAssistantApiResponse } from '../api/assistant';

// 消息类型定义
interface GeneratedTypeLiteralInterface_1 {
  type: string;
  id: number;
  name: string;
  latitude: number;
  longitude: number;
  distance: number;
}

interface Message {
  id: number;
  content: string;
  isUser: boolean;  // true: 用户消息, false: 助手消息
  timestamp: number;
  recommendations?: GeneratedTypeLiteralInterface_1[];  // 助手消息的推荐列表 - 内联定义
}

interface GeneratedTypeLiteralInterface_2 {
  type: string;
  id: number;
  name: string;
  latitude: number;
  longitude: number;
  distance: number;
}

interface GeneratedTypeLiteralInterface_3 {
  type: string;
  id: number;
  name: string;
  latitude: number;
  longitude: number;
  distance: number;
}

@Entry
@Component
struct AssistantPage {
  @State messages: Message[] = [];
  @State inputText: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State showError: boolean = false;

  // 用于生成消息ID
  private messageIdCounter: number = 0;

  // 生命周期：页面显示时
  aboutToAppear() {
    console.log('智能问答页面显示');
    // 添加欢迎消息
    this.addWelcomeMessage();
  }

  // 添加欢迎消息
  private addWelcomeMessage() {
    const welcomeMessage: Message = {
      id: this.getMessageId(),
      content: '您好！我是您的旅行智能助手。我可以为您推荐景点、餐厅，解答旅行相关问题。请问有什么可以帮助您的吗？',
      isUser: false,
      timestamp: Date.now()
    };
    this.messages = [welcomeMessage];
  }

  // 生成唯一消息ID
  private getMessageId(): number {
    return ++this.messageIdCounter;
  }

  // 发送消息
  private async sendMessage() {
    if (!this.inputText.trim() || this.isLoading) {
      return;
    }

    // 添加用户消息
    const userMessage: Message = {
      id: this.getMessageId(),
      content: this.inputText.trim(),
      isUser: true,
      timestamp: Date.now()
    };

    this.messages = [...this.messages, userMessage];
    const userInput = this.inputText;
    this.inputText = '';
    this.isLoading = true;
    this.showError = false;

    // 发送到智能助手
    try {
      const result = await askSimple(userInput);

      if (result && result.code === 200 && result.data) {
        // 添加助手回复
        const assistantMessage: Message = {
          id: this.getMessageId(),
          content: result.data.answer,
          isUser: false,
          timestamp: Date.now(),
          recommendations: result.data.recommendations || []
        };

        this.messages = [...this.messages, assistantMessage];
        console.log('✅ 助手回复成功，包含推荐:', result.data.recommendations?.length || 0);
      } else {
        // 处理错误响应 - 使用msg字段
        let errorMsg = '智能助手暂时无法响应，请稍后再试';
        if (result && result.msg) {
          errorMsg = result.msg;
          console.log('❌ 智能助手返回错误:', result.msg);
        } else if (result && result.code === 1201) {
          errorMsg = '请先登录后再使用智能助手功能';
          console.log('❌ 用户未登录或Token无效');
        }
        this.showErrorToast(errorMsg);
      }
    } catch (error) {
      console.error('请求智能助手异常:', error);
      this.showErrorToast('网络请求失败，请检查网络连接');
    } finally {
      this.isLoading = false;
    }
  }

  // 显示错误提示
  private showErrorToast(message: string) {
    this.errorMessage = message;
    this.showError = true;

    // 3秒后自动隐藏错误提示
    setTimeout(() => {
      this.showError = false;
    }, 3000);
  }

  // 格式化时间
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  // 构建推荐内容
  @Builder
  buildRecommendations(recommendations: GeneratedTypeLiteralInterface_2[]) {
    if (!recommendations || recommendations.length === 0) {

    }

    Column({ space: 10 }) {
      Text('✨ 相关推荐')
        .fontSize(14)
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 8 })

      ForEach(recommendations, (item: GeneratedTypeLiteralInterface_3) => {
        Column({ space: 4 }) {
          Row({ space: 8 }) {
            // 根据类型显示不同图标
            if (item.type === 'restaurant') {
              Text('🍽️')
                .fontSize(16)
            } else if (item.type === 'spot') {
              Text('📍')
                .fontSize(16)
            } else {
              Text('⭐')
                .fontSize(16)
            }

            Column({ space: 2 }) {
              Text(item.name)
                .fontSize(15)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start)
                .width('100%')

              Row({ space: 12 }) {
                if (item.distance > 0) {
                  Text(`距离${item.distance}米`)
                    .fontSize(12)
                    .fontColor('#666666')
                }

                if (item.type) {
                  Text(item.type === 'restaurant' ? '餐厅' : '景点')
                    .fontSize(12)
                    .fontColor('#007AFF')
                    .backgroundColor('#E6F2FF')
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .borderRadius(4)
                }
              }
              .margin({ top: 2 })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .backgroundColor('#F9F9F9')
          .borderRadius(8)
          .border({ width: 1, color: '#EEEEEE' })

          // 分隔线
          if (item.id !== recommendations[recommendations.length - 1].id) {
            Divider()
              .color('#F0F0F0')
              .margin({ left: 20, right: 20 })
              .strokeWidth(0.5)
          }
        }
        .width('100%')
      })
    }
    .width('100%')
    .margin({ top: 12, bottom: 8 })
  }

  // 构建用户消息（右对齐）
  @Builder
  buildUserMessage(message: Message) {
    Row() {
      // 占位空间
      Blank()
        .layoutWeight(1)

      // 消息内容
      Column({ space: 4 }) {
        Text(message.content)
          .fontSize(16)
          .fontColor(Color.White)
          .textAlign(TextAlign.Start)
          .width('100%')

        Text(this.formatTime(message.timestamp))
          .fontSize(11)
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#007AFF')
      .borderRadius(12)
      .border({ width: 1, color: '#007AFF' })
      .width('80%')
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  // 构建助手消息（左对齐）
  @Builder
  buildAssistantMessage(message: Message) {
    Row() {
      // 消息内容
      Column({ space: 4 }) {
        Text(message.content)
          .fontSize(16)
          .fontColor('#333333')
          .textAlign(TextAlign.Start)
          .width('100%')

        Text(this.formatTime(message.timestamp))
          .fontSize(11)
          .fontColor('#999999')
          .margin({ top: 2 })

        // 推荐内容
        if (message.recommendations && message.recommendations.length > 0) {
          this.buildRecommendations(message.recommendations)
        }
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#F0F0F0')
      .borderRadius(12)
      .border({ width: 1, color: '#E0E0E0' })
      .width('80%')

      // 占位空间
      Blank()
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }

  // 构建消息气泡
  @Builder
  buildMessageBubble(message: Message) {
    if (message.isUser) {
      this.buildUserMessage(message)
    } else {
      this.buildAssistantMessage(message)
    }
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
        Column({ space: 2 }) {
          Text('智能助手')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text('旅行问答与推荐')
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        // 占位
        Text('')
          .width(32)
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .width('100%')
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // 消息列表区域
      Stack() {
        Scroll() {
          Column({ space: 0 }) {
            // 消息列表
            ForEach(this.messages, (message: Message) => {
              this.buildMessageBubble(message)
            })

            // 加载指示器
            if (this.isLoading) {
              Column({ space: 8 }) {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .color('#007AFF')

                Text('思考中...')
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .width('100%')
              .padding(20)
              .alignItems(HorizontalAlign.Center)
              .margin({ top: 20, bottom: 20 })
            }
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          .width('100%')
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)

        // 错误提示
        if (this.showError) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor(Color.White)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor('#FF3B30')
            .borderRadius(20)
            .margin({ top: 16 })
            .alignSelf(ItemAlign.Center)
        }
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F9F9F9')

      // 输入区域
      Row({ space: 12 }) {
        // 输入框
        TextInput({ text: this.inputText, placeholder: '输入您的问题...' })
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontColor('#333333')
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#E0E0E0' })
          .borderRadius(22)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.inputText = value;
          })
          .onSubmit(() => {
            this.sendMessage();
          })

        // 发送按钮 - 使用上箭头
        Button() {
          if (this.isLoading) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color(Color.White)
          } else {
            Text('↑')
              .fontSize(20)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
        }
        .width(44)
        .height(44)
        .backgroundColor(this.inputText.trim() && !this.isLoading ? '#007AFF' : '#CCCCCC')
        .borderRadius(22)
        .enabled(!!this.inputText.trim() && !this.isLoading)
        .onClick(() => {
          this.sendMessage();
        })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .width('100%')
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: '#F0F0F0' })

      // 安全区域占位
      Row()
        .height(24)
        .width('100%')
        .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9F9F9')
  }
}