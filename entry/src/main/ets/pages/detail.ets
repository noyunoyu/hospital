// Index.ets
import router from '@ohos.router';

@Entry
@Component
struct PaymentDetailPage {
  @State orderTotal: string = '600.00元'
  @State cardBalance: string = '1400.00元'
  @State orderNumber: string = '202010090900001'
  @State orderTime: string = '2020/10/09 09:00:00'

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.u482')) // 替换为你的返回图标资源
          .width(12)
          .height(20)
          .onClick(() => {
            router.back();
          })

        Text('缴费详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .margin({
            left:110
          })

        Row() {
          Image($r('app.media.youshangjiao')) // 更多图标
            .width(104)
            .height(34)
            .margin({ right: 1})

        }
      }
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderWidth(1)
      .borderColor('#EEEEEE')

      // 主体内容区域
      Scroll() {
        Column() {
          // 成功提示区
          Column() {
            Image($r('app.media.duigou')) // 成功勾选图标
              .width(60)
              .height(60)
              .margin({ bottom: 12 })

            Text('缴费成功')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
          }
          .width('100%')
          .padding({ top: 32, bottom: 32 })
          .alignItems(HorizontalAlign.Center)

          // 基本信息卡片
          Column() {
            this.buildInfoRow('费用类型', '西药费')
            this.buildInfoRow('就诊科室', '消化内科')
            this.buildInfoRow('医生姓名', '李梅')
            this.buildInfoRow('就诊人', '牛韦')
            this.buildInfoRow('就诊卡号', '610*********0989')
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
          .margin({ top: 16, bottom: 16 })

          // 费用明细卡片
          Column() {
            Text('费用明细')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#666666')
              .margin({ bottom: 16 })

            this.buildMedicineItem('普罗布考片', 50.00, 3, 150.00)
            Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })
            this.buildMedicineItem('阿司匹林肠溶片', 50.00, 3, 150.00)
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
          .margin({ bottom: 16 })

          // 支付信息卡片
          Column() {
            this.buildInfoRow('支付方式', '余额')
            this.buildInfoRow('卡内余额', this.cardBalance)
            this.buildInfoRow('订单总额', this.orderTotal, true) // 红色高亮
            this.buildInfoRow('订单编号', this.orderNumber)
            this.buildInfoRow('订单时间', this.orderTime)
            this.buildInfoRow('订单状态', '已支付')
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
          .margin({ bottom: 32 })

        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FDFEFF')
  }

  // 辅助函数：构建单行信息
  @Builder
  buildInfoRow(label: string, value: string, isHighlight: boolean = false) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#999999')
        .width(100)

      Text(value)
        .fontSize(14)
        .fontColor(isHighlight ? '#FF4D4F' : '#333333')
        .fontWeight(isHighlight ? FontWeight.Medium : FontWeight.Normal)
        .layoutWeight(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  // 辅助函数：构建药品项
  @Builder
  buildMedicineItem(name: string, unitPrice: number, quantity: number, total: number) {
    Column() {
      Row() {
        Text(name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Text(`¥${total.toFixed(2)}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(`单价：¥${unitPrice.toFixed(2)}  数量：${quantity}`)
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({top:4})
    }
    .width('100%')
  }
}
