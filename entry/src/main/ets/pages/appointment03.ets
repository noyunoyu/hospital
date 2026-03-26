import router from '@ohos.router';
import { HttpUtil, HttpResponseData, AppointmentData } from '../utils/HttpUtil2';

@Entry
@Component
struct AppointmentDetailPage {
  @State appointment: AppointmentData = {
    doctorName: '',
    doctorTitle: '',
    hospital: '',
    address: '',
    department: '',
    clinicTime: '',
    waitTime: '',
    fee: '',
    appointmentTime: '',
    patientName: '',
    idCard: '',
    status: ''
  };

  // 页面加载时请求后端
  async aboutToAppear() {
    try {
      let res = await HttpUtil.get("/api/appointment/1");
      console.log("后端返回数据:", JSON.stringify(res));
      if (res.code === 200) {
        this.appointment = res.data;
      }
    } catch (e) {
      console.error("请求失败", e);
    }
  }

  build() {
    Scroll() {
      Column() {
        // === 顶部导航栏
        Row() {
          Image($r('app.media.u482'))
            .width(14)
            .height(24)
            .onClick(() => {
              router.back();
            })

          Text('预约挂号详情')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)


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
              Text(this.appointment.doctorName)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Text(this.appointment.doctorTitle)
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
          Row(){
            Text('就诊医院')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.hospital)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)

          }.width('100%')
          .padding({ top:12, bottom:12 })

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          // 医院地址
          Row() {
            Text('医院地址')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)

            Text(this.appointment.address)
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
          Row() {
            Text('就诊科室')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.department)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ top:12, bottom:12 })

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          // 门诊时间
          Row() {
            Text('门诊时间')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.clinicTime)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
          }.width('100%')
          .padding({ top:12, bottom:12 })

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          // 候诊时间
          Row() {
            Text('候诊时间')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.waitTime)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
          }.width('100%')
          .padding({ top:12, bottom:12 })

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          // 费用
          Row() {
            Text('费　用')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)

            Text(this.appointment.fee)
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
          Row() {
            Text('预约时间')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.appointmentTime)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
          }.width('100%')
          .padding({ top:12, bottom:12 })
        }
        .width('94%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
        .margin({ top: 16, bottom: 16 })

        // === 就诊人信息卡片 ===
        Column() {
          Row() {
            Text('就诊人')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.patientName)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
          }.width('100%')
          .padding({ top:12, bottom:12 })

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 })

          Row() {
            Text('身份证号')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.idCard)
              .fontSize(14)
              .fontColor('#333333')
              .layoutWeight(1)
          }.width('100%')
          .padding({ top:12, bottom:12 })
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