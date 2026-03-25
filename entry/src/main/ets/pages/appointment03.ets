import router from '@ohos.router';

@Entry
@Component
struct AppointmentDetailPage {
  @State doctorName: string = '赵马'
  @State doctorTitle: string = '主任医师'
  @State hospital: string = '北京市第一人民医院-东院区'
  @State address: string = '北京市大兴区**路990号'
  @State department: string = '消化内科-门诊3楼东区501'
  @State clinicTime: string = '2020年12月30日 周一 上午'
  @State waitTime: string = '9:30'
  @State fee: string = '¥60'
  @State bookTime: string = '2020年12月12号'
  @State patientName: string = '牛韦'
  @State idCard: string = '610*********0989'

  build() {
    Scroll() {
      Column() {
        // === 顶部导航栏
        Row() {
          Image($r('app.media.u482'))
            .width(14)
            .height(24)
            .margin({right:60})
            .onClick(() => {
              router.back();
            })

          Text('预约挂号详情')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Row() {
            Image($r('app.media.youshangjiao'))
              .width(96)
              .height(35)
              .margin({
                left:15 ,
                bottom:5
              })

          }
        }
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .borderWidth(1)
        .borderColor('#EEEEEE')

        // === 取消提示区 ===
        Column() {
          Image($r('app.media.cancel'))
            .width(60)
            .height(60)
            .margin({ bottom: 12 })

          Text('已取消')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .width('100%')
        .padding({ top: 32, bottom: 32 })
        .alignItems(HorizontalAlign.Center)

        // === 医生及医院信息卡片 ===
        Column() {
          // 医生头像 + 姓名职称
          Row() {
            Image($r('app.media.background'))
              .width(48)
              .height(48)
              .borderRadius(8)
              .backgroundColor('#E6F7FF')
              .margin({ right: 12 })

            Column() {
              Text(this.doctorName)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Text(this.doctorTitle)
                .fontSize(12)
                .fontColor('#999999')
                .margin({
                  top:2
                })
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding({ bottom: 16 })

          Divider().strokeWidth(1).color('#EEEEEE').margin({ bottom: 16 })

          // 就诊医院
          this.buildInfoRow('就诊医院', this.hospital)

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          // 医院地址
          Row() {
            Text('医院地址')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)

            Text(this.address)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)

            Image($r('app.media.address'))
              .width(16)
              .height(16)
              .margin({ right:50 })
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          // 就诊科室
          this.buildInfoRow('就诊科室', this.department)

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          // 门诊时间
          this.buildInfoRow('门诊时间', this.clinicTime)

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          // 候诊时间
          this.buildInfoRow('候诊时间', this.waitTime)

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          // 费用
          Row() {
            Text('费　用')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)

            Text(this.fee)
              .fontSize(14)
              .fontColor('#FF4D4F')
              .layoutWeight(1)

            Text('(就诊时支付)')
              .fontSize(12)
              .fontColor('#999999')
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          // 预约时间
          this.buildInfoRow('预约时间', this.bookTime)
        }
        .width('94%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
        .margin({ top: 16, bottom: 16 })

        // === 就诊人信息卡片 ===
        Column() {
          this.buildInfoRow('就 诊 人', this.patientName)

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          this.buildInfoRow('身份证号', this.idCard)
        }
        .width('94%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
        .margin({ bottom: 24 })


      }
      .width('100%')
      // 注意：内部 Column 不需要设 height('100%')，让它自然撑开
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    // 可选：隐藏滚动条，让界面更美观
    .scrollBar(BarState.Off)
  }

  // 辅助函数：构建单行信息
  @Builder
  buildInfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#999999')
        .width(80)

      Text(value)
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }
}