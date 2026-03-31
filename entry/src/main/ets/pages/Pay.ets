import router from '@ohos.router';
import { HttpUtil, PaymentListResponse } from '../utils/HttpUtil2';

// 页面使用的订单项
interface PayItem {
  orderNo: string;
  title: string;
  department: string;
  name: string; // 医生姓名（原 UI 中使用的字段名）
  patientName: string;
  time: string;
  money: string;
  url: string;
}

// 就诊人
interface PatientItem {
  id: number;
  name: string;
  tag: string;
  displayId: string; // 脱敏身份证
  realId: string;
  relation: string;
  medicalCardNo: string; // 就诊卡号
}

interface DatePickerValue {
  year?: number;
  month?: number;
  day?: number;
}


@Entry
@Component
struct Pay {
  @State isShowDialog: boolean = false;
  @State selectedTimeRange: string = '1year';
  @State selectedTimeText: string = '选择时间';
  // 日期选择器状态
  @State showDatePicker: boolean = false;
  @State startDate: string = '2020-01-01';
  @State endDate: string = '2020-01-01';
  @State pickerMode: 'start' | 'end' = 'start';
  @State currentPatient: PatientItem = {
    id: 0,
    name: '',
    tag: '',
    displayId: '',
    realId: '',
    relation: '',
    medicalCardNo: ''
  };
  @State patients: PatientItem[] = [];
  @State payment: PayItem[] = [];

  aboutToAppear() {
    this.loadPatients();
  }

  async loadPatients() {
    let res = await HttpUtil.getPatients();
    if (res.code === 200 && res.data.length > 0) {
      const patientList: PatientItem[] = res.data.map(p => ({
        id: p.id,
        name: p.name,
        tag: p.relation,
        displayId: HttpUtil.maskIdNumber(p.idNumber),
        realId: p.idNumber,
        relation: p.relation,
        medicalCardNo: p.cardNumber || ''
      } as PatientItem));
      this.patients = patientList;

      // 设置默认就诊人（优先 isDefault=1 的）
      const defaultPatient = patientList.find(p => p.id === res.data.find(d => d.isDefault === 1)?.id);
      this.currentPatient = defaultPatient || patientList[0];

      this.loadPayments();
    } else {
      console.error('加载就诊人列表失败', res.msg);
    }
  }

  async loadPayments() {
    console.log("当前就诊人信息:", JSON.stringify(this.currentPatient));
    console.log("当前时间范围:", this.selectedTimeRange);
    if (!this.currentPatient.medicalCardNo) {
      return;
    }
    console.log("加载缴费记录，患者卡号:", this.currentPatient.medicalCardNo);
    let res: PaymentListResponse;
    if (this.selectedTimeRange === 'custom') {
      // 自定义日期区间
      res = await HttpUtil.getPaymentListByDate(
        this.currentPatient.medicalCardNo,
        this.startDate,
        this.endDate
      );
    } else {
      // 保留近一年
      res = await HttpUtil.getPaymentList(this.currentPatient.medicalCardNo, this.selectedTimeRange);
    }
    if (res.code === 200) {
      this.payment = res.data.map(order => ({
        orderNo: order.orderNo,
        title: order.feeType,
        department: order.department,
        name: order.doctorName, // 保持原 UI 字段名
        patientName: order.patientName,
        time: order.orderTime,
        money: order.orderTotal,
        url: "pages/detail"
      } as PayItem));
      console.log("获取到的支付记录:", this.payment); // 添加调试信息
      console.log("获取到的支付记录数量:", this.payment.length);
      console.log("接口返回完整数据:", JSON.stringify(res));
    } else {
      this.payment = [];
      console.error('加载缴费记录失败：' + res.msg);
    }
  }

  // 🟢 日期选择格式化
  onDateChange(value: DatePickerValue) {
    const year = value.year ?? 2024;
    const month = value.month ?? 0;
    const day = value.day ?? 1;

    const dateStr = `${year}-${(month + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;

    if (this.pickerMode === 'start') {
      this.startDate = dateStr;
    } else {
      this.endDate = dateStr;
    }
  }

  // 格式：2020-01-01 → 2020年01月01日
  formatToChineseDate(dateStr: string): string {
    const GeneratedDestructArray_1 = dateStr.split('-');
    const year = GeneratedDestructArray_1[0];
    const month = GeneratedDestructArray_1[1];
    const day = GeneratedDestructArray_1[2];
    return `${year}年${month}月${day}日`;
  }

  build() {
    Stack() {
      Column() {
        // 导航栏
        Row() {
          Image($r('app.media.u482'))
            .width(15)
            .height(24)
            .margin({ left: 16, right: 80 })
            .onClick(() => {
              try {
                router.back();
              } catch (e) {
                console.error("Back failed", JSON.stringify(e));
              }
            });

          Text('门诊缴费记录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 12 });

          Blank();
        }
        .width('100%')
        .height(48)
        .alignItems(VerticalAlign.Center)
        .backgroundColor(Color.White);

        // 个人名片
        Column() {
          Row() {
            Text(this.currentPatient.name)
              .margin({ top: 30 ,right:10 });

            Text(this.currentPatient.tag)
              .fontSize(12)
              .margin({ top: 28, right: 165 })
              .backgroundColor('#E2EDFE')
              .fontColor('#4C98FF')
              .borderWidth(4)
              .borderColor('#E2EDFE')
              .borderRadius(8);

            Image($r('app.media.qiehuan'))
              .width(22)
              .height(22)
              .margin({ top: 30, right:22 })
              .onClick(() => {
                this.isShowDialog = true;
              });
          }

          Blank();
          Row() {
            // 显示脱敏身份证（原 UI 中显示 id）
            Text(this.currentPatient.displayId)
              .fontColor("#D3D5D8")
              .position({ x: 16, y: 65 });

            Text("切换就诊人")
              .fontColor("#D3D7DC")
              .fontSize(12)
              .position({ x: 243, y: 63 })
              .onClick(() => {
                this.isShowDialog = true;
              });
          }
        }
        .height(100)
        .width("90%")
        .backgroundColor("#F5F9FF")
        .margin({ top: 23 })
        .borderRadius(5);

        Blank(18);

        // 时间筛选器
        // === 时间筛选器 ===
        Row() {
          Button('近一年')
            .backgroundColor(this.selectedTimeRange === '1year' ? '#007DFF' : '#E6F7FF')
            .fontColor(this.selectedTimeRange === '1year' ? '#FFFFFF' : '#007DFF')
            .fontSize(14)
            .padding({
              left: 20,
              right: 20,
              top: 4,
              bottom: 8
            })
            .borderRadius(13)
            .margin({ right: 12 })
            .height(26)
            .onClick(() => {
              this.selectedTimeRange = '1year';
              this.selectedTimeText = '选择时间';
              this.loadPayments();
            })


          Button(this.selectedTimeText)
            .backgroundColor('#E4F0FF')
            .fontColor('#79B3FF')
            .fontSize(14)
            .padding({ left: 20, right: 20 })
            .borderRadius(16)
            .height(26)
            .onClick(() => {
              this.showDatePicker = true;
            })
        }
        .width('94%')
        .padding({ left: 16, bottom: 16 })

        Blank(20);

        // 门诊缴费列表
        List() {
          ForEach(this.payment, (item: PayItem) => {
            ListItem() {
              this.buildPaymentCard(item);
            }
            .padding({ bottom: 12, left: 15 })
            .onClick(() => {
              router.pushUrl({
                url: "pages/detail",
                params: {
                  orderNo: item.orderNo
                }   // 直接传递
              });
            });
          }, (item: PayItem) => item.orderNo);
        }
        .width("100%")
        .height("100%");
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FDFEFF');

      // 弹窗遮罩层
      if (this.isShowDialog) {
        Column() {
          Blank();

          Column() {
            Row() {
              Text('选择就诊人')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333');

              Blank();

              Text('×')
                .fontSize(24)
                .fontColor('#999999')
                .onClick(() => {
                  this.isShowDialog = false;
                });
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 });

            Row()
              .width('100%')
              .height(1)
              .backgroundColor('#EEEEEE');

            List() {
              ForEach(this.patients, (patient: PatientItem) => {
                ListItem() {
                  Row() {
                    Column() {
                      Row() {
                        Text(patient.name)
                          .fontSize(16)
                          .fontColor('#333333')
                          .fontWeight(FontWeight.Medium);

                        Text(patient.tag)
                          .fontSize(12)
                          .padding({
                            left: 6,
                            right: 6,
                            top: 2,
                            bottom: 2
                          })
                          .backgroundColor('#E8F3FF')
                          .borderRadius(4)
                          .fontColor('#007AFF')
                          .margin({ left: 8 });
                      }

                      Text(patient.displayId)   // 显示脱敏身份证
                        .fontSize(14)
                        .fontColor('#999999')
                        .margin({ top: 4 });
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1);

                    Text('>')
                      .fontSize(18)
                      .fontColor('#CCCCCC')
                      .margin({ right: 5 });
                  }
                  .width('100%')
                  .height(70)
                  .padding({ left: 16, right: 16 })
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .onClick(() => {
                    this.currentPatient = patient;
                    this.isShowDialog = false;
                    this.loadPayments();
                  });
                }
                .backgroundColor('#FFFFFF');
              }, (patient: PatientItem) => patient.id.toString());
            }
            .width('100%')
            .backgroundColor('#FFFFFF');
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 16, topRight: 16 })
          .padding({ bottom: 20 });
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000000')
        .justifyContent(FlexAlign.End);
      }
      // ====================== 日期选择弹窗 ======================
      if (this.showDatePicker) {
        Column() {
          Blank()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.4)
        .position({ top: 0, left: 0 });

        Column() {
          Row() {
            Text('取消')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ left: 16 })
              .onClick(() => {
                this.showDatePicker = false;
              });

            Blank();

            Text('确定')
              .fontSize(16)
              .fontColor('#007DFF')
              .margin({ right: 16 })
              .onClick(() => {
                this.selectedTimeText = `${this.startDate} 至 ${this.endDate}`;
                this.selectedTimeRange = 'custom';
                this.showDatePicker = false;
                this.loadPayments();
              });
          }
          .width('100%')
          .height(44)
          .alignItems(VerticalAlign.Center);

          Row() {
            Text(this.formatToChineseDate(this.startDate))
              .width(135)
              .height(35)
              .fontSize(12)
              .backgroundColor(this.pickerMode === 'start' ? '#006EFF' : '#E6F1FF')
              .fontColor(this.pickerMode === 'start' ? '#F2F2F2' : '#62A6FF')
              .borderWidth(1)
              .borderColor('#FFFFFF')
              .borderRadius(6)
              .textAlign(TextAlign.Center)
              .onClick(() => { this.pickerMode = 'start'; });

            Text(' 至 ')
              .fontSize(14)
              .fontColor('#666666')
              .margin({left:8 , right:8})

            Text(this.formatToChineseDate(this.endDate))
              .width(135)
              .height(35)
              .fontSize(14)
              .backgroundColor(this.pickerMode === 'end' ? '#006EFF' : '#E6F1FF')
              .fontColor(this.pickerMode === 'end' ? '#F2F2F2' : '#62A6FF')
              .borderWidth(1)
              .borderColor('#FFFFFF')
              .borderRadius(6)
              .textAlign(TextAlign.Center)
              .onClick(() => { this.pickerMode = 'end'; });
          }
          .width('100%')
          .margin({ top: 12, bottom: 12 })
          .justifyContent(FlexAlign.Center);

          DatePicker({
            start: new Date('2020-01-01'),
            end: new Date('2030-12-31'),
            selected: this.pickerMode === 'start' ? new Date(this.startDate) : new Date(this.endDate)
          })
            .onChange((value : DatePickerValue) => this.onDateChange(value))
            .width('100%')
            .height(200)
            .backgroundColor('#FFFFFF')
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 16, topRight: 16 })
        .position({ bottom: 0 });
      }
    }
  }

  @Builder
  buildPaymentCard(item: PayItem) {
    Row() {
      Column() {
        Text(item.title)
          .fontSize(16)
          .fontColor("#838383")
          .fontWeight(500)
          .margin({ right: 24, bottom: 10 });

        Text(item.department + ' ' + item.name)
          .fontColor("#D3D3D3")
          .fontSize(12)


        Text(item.time)
          .fontColor("#D3D3D3")
          .fontSize(13)
          .letterSpacing(-1)
          .margin({ left: 20, top: 9 });
      }

      Column() {
        Text("￥" + item.money)
          .fontColor("#F57979")
          .fontSize(18)
          .fontWeight(600);
      }
      .margin({ left: 120 });
    }
    .borderWidth(2)
    .height(110)
    .width(330)
    .borderColor("#E3E3E3")
  }
}