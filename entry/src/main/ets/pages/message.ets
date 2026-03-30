import router from '@ohos.router';
import { HttpUtil, AppointmentListItem ,AppointmentListResponse } from '../utils/HttpUtil2';

// 1. 定义就诊人数据接口
interface PatientItem {
  id: number;
  name: string;
  tag: string;
  displayId: string;
  realId: string;
  relation: string;
}

// 2. 定义预约记录数据接口
interface AppointmentItem {
  id: number;
  title: string;
  status: string;
  department: string;
  time: string;
  patient: string;
}

// 日期选择器类型
interface DatePickerValue {
  year?: number;
  month?: number;
  day?: number;
}

@Entry
@Component
struct AppointmentRecordPage {
  // 控制弹窗显示的状态
  @State isShowDialog: boolean = false;
  @State selectedTimeRange: string = '1year';
  @State selectedTimeText: string = '选择时间';
  // 就诊人列表数据
  @State patients: PatientItem[] = [];
  // 当前选中的就诊人
  @State currentPatient: PatientItem = {
    id: 0,
    name: '',
    tag: '',
    displayId: '',
    realId: '',
    relation: ''
  };
  @State appointments: AppointmentItem[] = [];
  // 日期选择器
  @State showDatePicker: boolean = false;
  @State startDate: string = '2024-01-01';
  @State endDate: string = '2024-01-01';
  @State pickerMode: 'start' | 'end' = 'start';

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
        relation: p.relation
      } as PatientItem));
      this.patients = patientList;

      // 设置默认就诊人（isDefault=1）
      const defaultPatient = patientList.find(p => p.id === res.data.find(d => d.isDefault === 1)?.id);
      this.currentPatient = defaultPatient || patientList[0];

      this.loadAppointments();
    } else {
      console.error('加载就诊人列表失败', res.msg);
    }
  }

  async loadAppointments() {
    if (!this.currentPatient.realId) {
      return;
    }

    let res: AppointmentListResponse;

    if (this.selectedTimeRange === 'custom') {
      // 自定义日期
      res = await HttpUtil.getAppointmentListByDate(
        this.currentPatient.realId,
        this.startDate,
        this.endDate
      );
    } else {
      // 近一年
      res = await HttpUtil.getAppointmentList(
        this.currentPatient.realId,
        this.selectedTimeRange
      );
    }

    if (res.code === 200) {
      this.appointments = res.data.map((item: AppointmentListItem) => ({
        id: item.id,
        title: item.title,
        status: item.status,
        department: item.department,
        time: item.time,
        patient: item.patient
      } as AppointmentItem));
    } else {
      this.appointments = [];
    }
  }

  // 格式化日期：2024-01-01 → 2024年01月01日
  formatToChineseDate(dateStr: string): string {
    const GeneratedDestructArray_1 = dateStr.split('-');
    const year = GeneratedDestructArray_1[0];
    const month = GeneratedDestructArray_1[1];
    const day = GeneratedDestructArray_1[2];
    return `${year}年${month}月${day}日`;
  }

  // 日期选择回调
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

  build() {

    Stack() {
      Column() {
        // === 顶部导航栏 ===
        Row() {
          Image($r('app.media.u482'))
            .width(13)
            .height(24)
            .margin({ left: 10, right: 80 })
            .onClick(() => {
              // 兼容旧版：直接使用 back()
              try {
                router.back();
              } catch (e) {
                console.error("Back failed", JSON.stringify(e));
              }
            })

          Text('预约挂号记录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          // 占位，保持标题居中
          Row().width(96).height(35).margin({ left: 10, bottom: 5 })
        }
        .height(56)
        .padding({ left: 16, right: 9 })
        .backgroundColor('#FFFFFF')
        .borderWidth(1)
        .borderColor('#EEEEEE')

        // === 就诊人信息卡片 ===
        Column() {
          Row() {
            Column() {
              Row() {
                Text(this.currentPatient.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')

                Text(this.currentPatient.tag)
                  .fontSize(12)
                  .fontColor('#007DFF')
                  .backgroundColor('#E6F7FF')
                  .padding({
                    left: 6,
                    right: 6,
                    top: 2,
                    bottom: 2
                  })
                  .borderRadius(4)
                  .margin({ left: 8 })
              }

              Text(this.currentPatient.displayId)
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 8 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Column() {
              Image($r('app.media.qiehuan'))
                .width(30)
                .height(30)
                .onClick(() => {
                  this.isShowDialog = true;
                })
              Text('切换就诊人')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 6 })
            }
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
        }
        .width('94%')
        .padding(16)
        .backgroundColor('#F5F8FF')
        .borderRadius(12)
        .margin({ top: 16, bottom: 16 })

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
              this.loadAppointments();
            })

          Button(this.selectedTimeText)
            .backgroundColor('#E6F7FF')
            .fontColor('#007DFF')
            .fontSize(14)
            .padding({
              left: 20,
              right: 20,
            })
            .borderRadius(16)
            .height(26)
            .onClick(() => {
              this.showDatePicker = true;
            })
        }
        .width('94%')
        .padding({ left: 16, top: 0, bottom: 16 })

        // === 预约记录列表 ===
        List() {
          ForEach(this.appointments, (item: AppointmentItem) => {
            ListItem() {
              this.buildAppointmentCard(item)
            }
            .padding({ bottom: 12 })
            .onClick(() => {
              this.goToDetailPage(item);
            })
          })
        }
        .width('94%')
        .padding({ bottom: 20 })
        .divider({ strokeWidth: 0 })

      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FDFEFF')

      // === 弹窗遮罩层 ===
      if (this.isShowDialog) {
        Column() {
          Blank()

          Column() {
            Row() {
              Text('选择就诊人')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Blank()

              Text('×')
                .fontSize(24)
                .fontColor('#999999')
                .onClick(() => {
                  this.isShowDialog = false;
                })
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })

            // 分割线
            Row()
              .width('100%')
              .height(1)
              .backgroundColor('#EEEEEE')

            List() {
              ForEach(this.patients, (patient: PatientItem) => {
                ListItem() {
                  Row() {
                    Column() {
                      Row() {
                        Text(patient.name)
                          .fontSize(16)
                          .fontColor('#333333')
                          .fontWeight(FontWeight.Medium)

                        Text(patient.tag)
                          .fontSize(12)
                          .padding({
                            left: 6,
                            right: 6,
                            top: 2,
                            bottom: 2
                          })
                          .backgroundColor('#E6F7FF')
                          .borderRadius(4)
                          .fontColor('#007DFF')
                          .margin({ left: 8 })
                      }

                      Text(patient.displayId)
                        .fontSize(14)
                        .fontColor('#999999')
                        .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    Text('>')
                      .fontSize(18)
                      .fontColor('#CCCCCC')
                      .margin({ right: 5 })
                  }
                  .width('100%')
                  .height(70)
                  .padding({ left: 16, right: 16 })
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .onClick(() => {
                    this.currentPatient = patient;
                    this.isShowDialog = false;
                    this.loadAppointments();
                  })
                }
                .backgroundColor('#FDFEFF')
              }, (patient: PatientItem) => patient.id.toString())
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 16, topRight: 16 })
          .padding({ bottom: 20 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000000')
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          this.isShowDialog = false;
        })
      }

      // ====================== 日期选择弹窗 ======================
      if (this.showDatePicker) {
        // 遮罩
        Column() { Blank() }
        .width('100%').height('100%').backgroundColor('#000').opacity(0.4)
        .position({ top: 0 })

        // 弹窗主体
        Column() {
          // 取消 / 确定
          Row() {
            Text('取消').fontSize(16).fontColor('#666').margin({left:16})
              .onClick(() => this.showDatePicker = false);
            Blank();
            Text('确定').fontSize(16).fontColor('#007DFF').margin({right:16})
              .onClick(() => {
                this.selectedTimeText = `${this.formatToChineseDate(this.startDate)} 至 ${this.formatToChineseDate(this.endDate)}`;
                this.selectedTimeRange = 'custom';
                this.showDatePicker = false;
                this.loadAppointments();
              });
          }.width('100%').height(44)

          // 日期显示
          Row() {
            Text(this.formatToChineseDate(this.startDate))
              .width(135).height(35).borderWidth(1).borderColor('#FFFFFF').borderRadius(6)
              .backgroundColor(this.pickerMode === 'start' ? '#006EFF' : '#E6F1FF')
              .fontColor(this.pickerMode === 'start' ? '#F2F2F2' : '#62A6FF')
              .fontSize(12)
              .textAlign(TextAlign.Center)
              .onClick(() => this.pickerMode = 'start');

            Text('至').fontSize(16).margin({ left: 12, right: 12 });

            Text(this.formatToChineseDate(this.endDate))
              .width(135).height(35).borderWidth(1).borderColor('#FFFFFF').borderRadius(6)
              .backgroundColor(this.pickerMode === 'end' ? '#006EFF' : '#E6F1FF')
              .fontColor(this.pickerMode === 'end' ? '#F2F2F2' : '#62A6FF')
              .fontSize(12)
              .textAlign(TextAlign.Center)
              .onClick(() => this.pickerMode = 'end');
          }.margin({ top: 12, bottom: 12 })

          // 日期滚轮（无中文）
          DatePicker({
            start: new Date('2020-01-01'),
            end: new Date('2030-12-31'),
            selected: this.pickerMode === 'start' ? new Date(this.startDate) : new Date(this.endDate)
          })
            .onChange((value: DatePickerValue) => this.onDateChange(value))
            .width('100%').height(200).backgroundColor('#fff')
        }
        .width('100%').backgroundColor('#fff').borderRadius({ topLeft: 16, topRight: 16 })
        .position({ bottom: 0 })
      }
    }
  }

  @Builder
  buildAppointmentCard(item: AppointmentItem) {
    Column() {
      Row() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Text(item.status)
          .fontSize(14)
          .fontColor(this.getStatusColor(item.status))
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .padding({ top: 16, bottom: 8 })

      Divider()
        .strokeWidth(1)
        .color('#EEEEEE')
        .margin({ top: 8, bottom: 12 })

      Text('就诊科室 ' + item.department)
        .fontSize(12)
        .fontColor('#999999')
        .width('100%')
        .padding({ bottom: 8 })

      Blank(5)

      Text('就诊时间 ' + item.time)
        .fontSize(12)
        .fontColor('#999999')
        .width('100%')
        .padding({ bottom: 8 })

      Blank(5)

      Text('就诊人     ' + item.patient)
        .fontSize(12)
        .fontColor('#999999')
        .width('100%')
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 0,
      bottom: 16
    })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#10000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  getStatusColor(status: string): string {
    switch (status) {
      case '预约成功':
      case '已完成':
        return '#007DFF';
      case '已取消':
        return '#999999';
      default:
        return '#333333';
    }
  }

  goToDetailPage(item: AppointmentItem) {
    let url = '';

    switch (item.status) {
      case '预约成功':
        url = 'pages/appointment01';
        break;
      case '已完成':
        url = 'pages/appointment02';
        break;
      case '已取消':
        url = 'pages/appointment03';
        break;
      default:
        url = 'pages/appointment01';
        break;
    }


    router.pushUrl({
      url: url,
      params: {
        appointmentId: item.id
      }
    });
  }
}


function getDepartmentName(fullName: undefined, string: undefined) {
  throw new Error('Function not implemented.');
}
