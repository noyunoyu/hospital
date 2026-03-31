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

  @State currentId : number = 0 ; //保存当前预约ID

  // 页面加载时请求后端
  async aboutToAppear() {
    try {
      // 获取路由传递的参数
      const params = router.getParams() as Record<string, Object>;
      const appointmentId = params?.['appointmentId'] as number;
      if (!appointmentId) {
        console.error('未获取到预约ID');
        return;
      }
      this.currentId = appointmentId;  // 保存ID
      let res = await HttpUtil.get(`/api/appointment/${appointmentId}`);
      console.log("后端返回数据:", JSON.stringify(res));

      if (res.code === 200) {
        this.appointment = res.data;
      } else {
        console.error('获取详情失败', res.msg);
      }
    } catch (e) {
      console.error("请求失败", e);
    }
  }

  build() {
    Scroll() {
      Column() {
        // === 顶部导航栏（完全不变） ===
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
        .padding({ left:16, right:16 })
        .backgroundColor('#FFFFFF')
        .borderWidth(1)
        .borderColor('#EEEEEE')

        // === 成功提示（不变） ===
        Column() {
          Image($r('app.media.success'))
            .width(60)
            .height(60)
            .margin({ bottom:12 })
          Text('预约成功')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
        .width('100%')
        .padding({ top:32, bottom:32 })
        .alignItems(HorizontalAlign.Center)

        // === 信息卡片 ===
        Column() {
          Row() {
            Image($r('app.media.background'))
              .width(48)
              .height(48)
              .borderRadius(8)
              .backgroundColor('#E6F7FF')
              .margin({ right:12 })
            Row() {
              Text(this.appointment.doctorName)
                .fontSize(17)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Text(this.appointment.doctorTitle)
                .fontSize(13)
                .fontColor('#999999')
                .margin({ top:2 ,left:5})
            }
          }
          .width('100%')
          .padding({ bottom:10,top:10 })
          Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })
        Row(){
          Text('就诊医院')
            .fontSize(14)
            .fontColor('#999999')
            .width(80)
          Text(this.appointment.hospital)
            .fontSize(14)
            .fontColor('#999999')
            .layoutWeight(1)

        }.width('100%')
        .padding({ top:12, bottom:12 })
          Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })

          Row() {
            Text('医院地址')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.address)
              .fontSize(14)
              .fontColor('#999999')
              .layoutWeight(1)
            Image($r('app.media.address'))
              .width(16)
              .height(16)
              .margin({ right:50 })
          }
          .width('100%')
          .padding({ top:12, bottom:12 })

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })

          Row() {
            Text('就诊科室')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.department)
              .fontSize(14)
              .fontColor('#999999')
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ top:12, bottom:12 })
          Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })

          Row() {
            Text('门诊时间')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.clinicTime)
              .fontSize(14)
              .fontColor('#999999')
              .layoutWeight(1)
          }.width('100%')
          .padding({ top:12, bottom:12 })
          Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })

          Row() {
            Text('候诊时间')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.waitTime)
              .fontSize(14)
              .fontColor('#999999')
              .layoutWeight(1)
          }.width('100%')
          .padding({ top:12, bottom:12 })
          Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })

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
              .margin({right:110})
          }
          .width('100%')
          .padding({ top:12, bottom:12 })

          Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })

          Row() {
            Text('预约时间')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.appointmentTime)
              .fontSize(14)
              .fontColor('#999999')
              .layoutWeight(1)
          }.width('100%')
          .padding({ top:12, bottom:12 })
        }
        .width('94%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius:8, color:'#10000000', offsetX:0, offsetY:2 })
        .margin({ top:16, bottom:16 })

        // === 就诊人信息 ===
        Column() {
          Row() {
            Text('就诊人')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.patientName)
              .fontSize(14)
              .fontColor('#999999')
              .layoutWeight(1)
          }.width('100%')
          .padding({ top:12, bottom:12 })
          Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })
          Row() {
            Text('身份证号')
              .fontSize(14)
              .fontColor('#999999')
              .width(80)
            Text(this.appointment.idCard)
              .fontSize(14)
              .fontColor('#999999')
              .layoutWeight(1)
          }.width('100%')
          .padding({ top:12, bottom:12 })
        }
        .width('94%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius:8, color:'#10000000', offsetX:0, offsetY:2 })
        .margin({ bottom:24 })

        // === 取消预约（不变） ===
        Button('取消预约')
          .width('94%')
          .height(48)
          .backgroundColor('#E6F7FF')
          .fontColor('#007DFF')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(8)
          .onClick(async () => {
            try {
              // 1. 调用取消预约接口
              let res = await HttpUtil.cancelAppointment(this.currentId);

              if (res.code === 200) {
                console.log("取消预约成功");
                // 2. 跳转到已取消页面
                router.pushUrl({
                  url: "pages/appointment03",
                  params: {
                    appointmentId: this.currentId
                  }
                });
              } else {
                console.error("取消预约失败：", res.msg);
              }
            } catch (e) {
              console.error("取消预约异常：", e);
            }
          })
          .margin({ bottom:32 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .scrollBar(BarState.Off)
  }

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
    .padding({ top:12, bottom:12 })
  }
}