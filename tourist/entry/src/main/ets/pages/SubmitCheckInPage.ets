// entry/src/main/ets/pages/SubmitCheckinPage.ets
import router from '@ohos.router';
import { Submit, SubmitReq, SubmitResData } from '../api/checkIn';

interface RouterParams {
  spotId:number;
  spotName:string;
  latitude:number;
  longitude:number;
}
@Entry
@Component
export default struct SubmitCheckinPage {
  // 路由参数
  @State spotId: number = 0;
  @State spotName: string = '';

  // 表单数据
  @State formData: SubmitReq = {
    spotId: 301, // 默认值用于测试
    latitude: 23.112300, // 默认值用于测试
    longitude: 113.332200, // 默认值用于测试
    image: '' // 用户上传的图片
  };

  // 加载状态
  @State isLoading: boolean = false;

  // 图片上传状态
  @State hasImage: boolean = false;
  @State imagePreview: string = '';

  // 提交结果
  @State submitResult: SubmitResData = {
    checkInId: 1,
    points: 1,
    spotId: 1,
    checkInTime: "1981",
    msg: "success"
  } ;
  @State showSuccess: boolean = false;

  // 页面构建
  build() {
    Column() {
      // 顶部导航栏
      this.buildNavigationBar()

      if (this.showSuccess) {
        this.buildSuccessView()
      } else {
        // 表单区域
        Scroll() {
          Column() {
            // 打卡点信息
            this.buildSpotInfoCard()

            // 位置信息
            this.buildLocationInfoCard()

            // 图片上传
            this.buildImageUploadCard()

            // 提交按钮
            this.buildSubmitButton()

            // 底部间距
            Row()
              .height(80)
              .width('100%')
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
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
            if (this.showSuccess) {
              // 成功后返回上一页
              router.back();
            } else {
              // 取消打卡
              this.onCancel();
            }
          })

        // 标题
        Text(this.showSuccess ? '打卡成功' : '提交打卡')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .layoutWeight(1)
      }
      .width('100%')
      .height(60)
      .padding({ left: 15, right: 15 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .shadow({ radius: 2, color: '#00000008' })
  }

  // ==================== 打卡成功视图 ====================
  @Builder
  buildSuccessView() {
    Column({ space: 25 }) {
      // 成功图标
      Column() {
        Text('✓')
          .fontSize(48)
          .fontColor('#34C759')
      }
      .width(80)
      .height(80)
      .backgroundColor('#34C75920')
      .borderRadius(40)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 成功标题
      Text('打卡成功！')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      // 成功信息
      if (this.submitResult) {
        Column({ space: 12 }) {
          Text(`获得 ${this.submitResult.points || 100} 积分`)
            .fontSize(18)
            .fontColor('#FF9500')
            .fontWeight(FontWeight.Medium)

          Text(this.submitResult.msg || '恭喜完成打卡！')
            .fontSize(16)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)

          Text(`打卡时间：${this.submitResult.checkInTime || new Date().toLocaleString()}`)
            .fontSize(14)
            .fontColor('#999999')
        }
      } else {
        Column({ space: 12 }) {
          Text('获得 100 积分')
            .fontSize(18)
            .fontColor('#FF9500')
            .fontWeight(FontWeight.Medium)

          Text('恭喜完成打卡！')
            .fontSize(16)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
        }
      }

      // 返回按钮
      Button('返回打卡点列表')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#007AFF')
        .width('80%')
        .height(50)
        .borderRadius(25)
        .margin({ top: 20 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 20, right: 20 })
  }

  // ==================== 打卡点信息卡片 ====================
  @Builder
  buildSpotInfoCard() {
    Column({ space: 12 }) {
      // 标题
      Text('打卡点信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')

      // 信息列表
      Column({ space: 10 }) {
        // 打卡点ID
        Row() {
          Text('打卡点ID')
            .fontSize(15)
            .fontColor('#666666')
            .layoutWeight(1)
          Text(this.formData.spotId.toString())
            .fontSize(15)
            .fontColor('#1A1A1A')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        // 打卡点名称（如果有）
        if (this.spotName) {
          Row() {
            Text('打卡点名称')
              .fontSize(15)
              .fontColor('#666666')
              .layoutWeight(1)
            Text(this.spotName)
              .fontSize(15)
              .fontColor('#1A1A1A')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
        }
      }
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .margin({ top: 20 })
    .alignSelf(ItemAlign.Center)
    .shadow({ radius: 8, color: '#0000000D' })
  }

  // ==================== 位置信息卡片 ====================
  @Builder
  buildLocationInfoCard() {
    Column({ space: 12 }) {
      // 标题
      Text('位置信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')

      // 位置信息
      Column({ space: 10 }) {
        // 纬度
        Row() {
          Text('纬度')
            .fontSize(15)
            .fontColor('#666666')
            .layoutWeight(1)
          Text(this.formData.latitude.toFixed(6))
            .fontSize(15)
            .fontColor('#1A1A1A')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        // 经度
        Row() {
          Text('经度')
            .fontSize(15)
            .fontColor('#666666')
            .layoutWeight(1)
          Text(this.formData.longitude.toFixed(6))
            .fontSize(15)
            .fontColor('#1A1A1A')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        // 位置状态
        Row() {
          Text('位置状态')
            .fontSize(15)
            .fontColor('#666666')
            .layoutWeight(1)
          Text('已获取')
            .fontSize(15)
            .fontColor('#34C759')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
      }
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .margin({ top: 15 })
    .alignSelf(ItemAlign.Center)
    .shadow({ radius: 8, color: '#0000000D' })
  }

  // ==================== 图片上传卡片 ====================
  @Builder
  buildImageUploadCard() {
    Column({ space: 12 }) {
      // 标题
      Text('上传图片（可选）')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')

      // 图片预览区域
      if (this.hasImage && this.imagePreview) {
        Column() {
          Image(this.imagePreview)
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)

          // 删除按钮
          Row({ space: 5 }) {
            Button('删除图片')
              .fontSize(14)
              .fontColor('#FF3B30')
              .backgroundColor('#FF3B3010')
              .height(32)
              .borderRadius(16)
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                this.removeImage();
              })
          }
          .margin({ top: 10 })
          .justifyContent(FlexAlign.Center)
        }
      } else {
        // 上传按钮
        Column() {
          // Image($r('app.media.ic_add_image'))
          //   .width(48)
          //   .height(48)
          //   .margin({ bottom: 10 })

          Text('添加打卡图片')
            .fontSize(16)
            .fontColor('#007AFF')
            .margin({ bottom: 5 })

          Text('可选，记录美好瞬间')
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .height(120)
        .backgroundColor('#F5F7FA')
        .border({ width: 2, style: BorderStyle.Dashed, color: '#E0E0E0' })
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.selectImage();
        })
      }

      // 提示信息
      Text('支持 JPG/PNG 格式，大小不超过 5MB')
        .fontSize(12)
        .fontColor('#999999')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 5 })
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({ left: 20, right: 20, top: 20, bottom: 20 })
    .margin({ top: 15 })
    .alignSelf(ItemAlign.Center)
    .shadow({ radius: 8, color: '#0000000D' })
  }

  // ==================== 提交按钮 ====================
  @Builder
  buildSubmitButton() {
    Column() {
      if (this.isLoading) {
        // 加载中
        Row({ space: 10 }) {
          LoadingProgress()
            .color(Color.White)
            .width(20)
            .height(20)
          Text('正在提交...')
            .fontSize(16)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(50)
        .backgroundColor('#007AFF80')
        .borderRadius(25)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      } else {
        // 提交按钮
        Button('提交打卡')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#007AFF')
          .width('100%')
          .height(50)
          .borderRadius(25)
          .onClick(() => {
            this.handleSubmit();
          })
      }
    }
    .width('90%')
    .margin({ top: 25, bottom: 20 })
    .alignSelf(ItemAlign.Center)
  }

  // ==================== 交互方法 ====================

  // 选择图片
  private selectImage() {
    console.log('选择图片');
    // TODO: 实现图片选择功能
    // 这里模拟选择图片
    this.imagePreview = 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&auto=format&fit=crop';
    this.hasImage = true;

    // 实际应该获取 Base64 编码的图片
    // this.formData.image = 'base64_encoded_image_data_here';
  }

  // 删除图片
  private removeImage() {
    console.log('删除图片');
    this.imagePreview = '';
    this.hasImage = false;
    this.formData.image = '';
  }

  // 处理提交
  private async handleSubmit() {
    console.log('提交打卡数据:', this.formData);

    // 验证数据
    if (!this.formData.spotId) {
      console.warn('请选择打卡点');
      return;
    }

    if (!this.formData.latitude || !this.formData.longitude) {
      console.warn('请获取位置信息');
      return;
    }

    this.isLoading = true;

    try {
      // 调用提交接口
      await Submit(this.formData);

      // 模拟成功返回
      this.submitResult = {
        checkInId: 50011,
        points: 100,
        spotId: this.formData.spotId,
        checkInTime: new Date().toLocaleString(),
        msg: '恭喜完成打卡！获得 100 积分'
      };

      console.log('打卡成功:', this.submitResult);

      // 显示成功页面
      this.showSuccess = true;

    } catch (error) {
      console.error('打卡失败:', error);
      // TODO: 显示错误提示
    } finally {
      this.isLoading = false;
    }
  }

  // 取消打卡
  private onCancel() {
    console.log('取消打卡');
    router.back();
  }

  // ==================== 生命周期方法 ====================

  aboutToAppear() {
    console.log('提交打卡页面显示');

    // 获取路由参数
    const params = router.getParams() as RouterParams;
    if (params) {
      if (params.spotId) {
        this.spotId = params.spotId;
        this.formData.spotId = params.spotId;
      }
      if (params.spotName) {
        this.spotName = params.spotName;
      }
      if (params.latitude) {
        this.formData.latitude = params.latitude;
      }
      if (params.longitude) {
        this.formData.longitude = params.longitude;
      }
    }

    console.log('接收到的参数:', params);
    console.log('表单数据:', this.formData);

    // 获取当前位置（如果参数中没有）
    this.getCurrentLocation();
  }

  // 获取当前位置
  private getCurrentLocation() {
    // TODO: 调用鸿蒙定位API获取当前位置
    console.log('获取当前位置...');

    // 如果表单中已经有位置数据，不再获取
    if (this.formData.latitude && this.formData.longitude) {
      console.log('已使用传入的位置数据');
      return;
    }

    // 模拟获取位置
    setTimeout(() => {
      this.formData.latitude = 23.112300; // 测试数据
      this.formData.longitude = 113.332200; // 测试数据
      console.log('当前位置已设置:', this.formData.latitude, this.formData.longitude);
    }, 500);
  }

  aboutToDisappear() {
    console.log('提交打卡页面即将消失');
  }
}