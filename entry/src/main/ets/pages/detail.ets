import router from '@ohos.router';
import { HttpUtil, PaymentItem, PaymentDetail } from '../utils/HttpUtil2';
import { EditableLeftIconType } from '@kit.ArkUI';
import { StartOptions } from '@kit.AbilityKit';

// 定义路由参数类型（解决ArkTS类型报错）
interface RouterParams {
  orderNo: string;
}

@Entry
@Component
struct PaymentDetailPage {
  // 保留你原来的变量名，只是初始值清空，等待接口赋值
  @State orderTotal: string = '';
  @State cardBalance: string = '';
  @State orderNumber: string = '';
  @State orderTime: string = '';

  // 新增需要的字段
  @State feeType: string = '';
  @State department: string = '';
  @State doctorName: string = '';
  @State patientName: string = '';
  @State medicalCardNo: string = '';
  @State paymentMethod: string = '';
  @State items: PaymentItem[] = [];

  aboutToAppear() {
    // 获取跳转传来的订单号
    const params = router.getParams() as RouterParams;
    if (params?.orderNo) {
      this.loadPaymentDetail(params.orderNo);
    }
  }

  // 加载真实订单详情
  async loadPaymentDetail(orderNo: string) {
    const res = await HttpUtil.getPaymentDetail(orderNo);
    if (res.code === 200) {
      const data = res.data;
      this.feeType = data.feeType;
      this.department = data.department;
      this.doctorName = data.doctorName;
      this.patientName = data.patientName;
      this.medicalCardNo = data.medicalCardNo;
      this.paymentMethod = data.paymentMethod;
      this.cardBalance = data.cardBalance + '元';
      this.orderTotal = data.orderTotal + '元';
      this.orderNumber = data.orderNo;
      this.orderTime = data.orderTime;
      this.items = data.items;
    }
  }

  build() {
    Column() {
      // 顶部导航栏 —— 完全不变
      Row() {
        Image($r('app.media.u482'))
          .width(12)
          .height(20)
          .onClick(() => {
            router.back();
          });

        Text('缴费详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .margin({ left: 110 });

      }
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderWidth(1)
      .borderColor('#EEEEEE');

      // 主体内容区域 —— 布局完全不变
      Scroll() {
        Column() {
          // 成功提示区 —— 不变
          Column() {
            Image($r('app.media.duigou'))
              .width(60)
              .height(60)
              .margin({ bottom: 12 });

            Text('缴费成功')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333');
          }
          .width('100%')
          .padding({ top: 32, bottom: 32 })
          .alignItems(HorizontalAlign.Center);

          // 基本信息卡片 —— 只替换文字为变量，样式完全不变
          Column() {
            Row() {
              Text('费用类型')
                .fontSize(14)
                .fontColor('#999999')
                .width(80)
              Text(this.feeType)
                .fontSize(14)
                .fontColor('#999999')
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top:12, bottom:12 })

            Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })
            Row() {
              Text('就诊科室')
                .fontSize(14)
                .fontColor('#999999')
                .width(80)
              Text(this.department)
                .fontSize(14)
                .fontColor('#999999')
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top:12, bottom:12 })

            Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })

            Row() {
              Text('医生姓名')
                .fontSize(14)
                .fontColor('#999999')
                .width(80)
              Text(this.doctorName)
                .fontSize(14)
                .fontColor('#999999')
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top:12, bottom:12 })

            Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })

            Row() {
              Text('就诊人')
                .fontSize(14)
                .fontColor('#999999')
                .width(80)
              Text(this.patientName)
                .fontSize(14)
                .fontColor('#999999')
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top:12, bottom:12 })

            Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })

            Row() {
              Text('就诊卡号')
                .fontSize(14)
                .fontColor('#999999')
                .width(80)
              Text(this.medicalCardNo)
                .fontSize(14)
                .fontColor('#999999')
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top:12, bottom:12 })
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
          .margin({ top: 16, bottom: 16 });

          // 费用明细卡片 —— 动态渲染，样式保留
          Column() {
            Text('费用明细')
              .fontSize(16)
              .fontColor('#B0B0B0')
              .margin({right:220})
              .textAlign(TextAlign.Start);



            // 动态循环药品列表
            ForEach(this.items, (item: PaymentItem) => {
              Divider().strokeWidth(1).color('#EEEEEE').margin({ top: 12, bottom: 12 });
              Column() {
                this.buildMedicineItem(
                  item.drugName,
                  parseFloat(item.unitPrice),
                  item.quantity,
                  parseFloat(item.drugTotal)
                );

              }
            });
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
          .margin({ bottom: 16 });

          // 支付信息卡片 —— 完全不变
          Column() {
            Row() {
              Text('支付方式')
                .fontSize(14)
                .fontColor('#999999')
                .width(80)
              Text(this.paymentMethod)
                .fontSize(14)
                .fontColor('#999999')
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top:12, bottom:12 })
            Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })
            Row() {
                Text('卡内余额')
                  .fontSize(14)
                  .fontColor('#999999')
                  .width(80)
                Text(this.cardBalance)
                  .fontSize(14)
                  .fontColor('#999999')
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ top:12, bottom:12 })
              Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })
            Row() {
              Text('订单总额')
                .fontSize(14)
                .fontColor('#999999')
                .width(80)
              Text(this.orderTotal)
                .fontSize(14)
                .fontColor('#F56F6F')
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top:12, bottom:12 })
            Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })
            Row() {
              Text('订单编号')
                .fontSize(14)
                .fontColor('#999999')
                .width(80)
              Text(this.orderNumber)
                .fontSize(14)
                .fontColor('#999999')
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top:12, bottom:12 })
            Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })
            Row() {
              Text('订单时间')
                .fontSize(14)
                .fontColor('#999999')
                .width(80)
              Text(this.orderTime)
                .fontSize(14)
                .fontColor('#999999')
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top:12, bottom:12 })
            Divider().strokeWidth(1).color('#EEEEEE').margin({ top:12, bottom:12 })
            Row() {
              Text('订单状态')
                .fontSize(14)
                .fontColor('#999999')
                .width(80)
              Text('已支付')
                .fontSize(14)
                .fontColor('#999999')
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top:12, bottom:12 })


          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
          .margin({ bottom: 32 });
        }
        .width('100%')
        .padding({ bottom: 20 });
      }
      .scrollBar(BarState.Auto)
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FDFEFF');
  }


  // 辅助函数 —— 完全不变
  @Builder
  buildMedicineItem(name: string, unitPrice: number, quantity: number, total: number) {
    Column() {
      Row() {
        Text(name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333');


        Text(`¥${total.toFixed(2)}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.End);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      Blank(8)

      Row() {
        Text(`单价：¥${unitPrice.toFixed(2)}  数量：${quantity}`)
          .fontSize(12)
          .fontColor('#999999');
      }
      .width('100%')
      .margin({ top: 4 });
    }
    .width('100%');
  }
}