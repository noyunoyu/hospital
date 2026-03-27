import router from '@ohos.router';
import { HttpUtil, AppointmentListItem } from '../utils/HttpUtil2';

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
      }as PatientItem));
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
    let res = await HttpUtil.getAppointmentList(this.currentPatient.realId, this.selectedTimeRange);
    if (res.code === 200) {
      this.appointments = res.data.map((item: AppointmentListItem) => {
        return {
          id: item.id,
          title: item.title,
          status: item.status,
          department: item.department,
          time: item.time,
          patient: item.patient
        }as AppointmentItem;
      });
    } else {
      this.appointments = [];
      console.error('加载预约记录失败：' + res.msg);
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
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
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
            .padding({ left: 20, right: 20, top: 4, bottom: 8 })
            .borderRadius(13)
            .margin({ right: 12 })
            .height(26)
            .onClick(() => {
              this.selectedTimeRange = '1year';
              this.selectedTimeText = '选择时间';
              this.loadAppointments();
            })


          // === 修改点：兼容旧版 Select 写法 ===
          // 旧版 Select 直接传字符串数组，不支持 label 属性
          Select([
            { value: "近三个月" },
            { value: "近六个月" },
            { value: "全部时间" }
          ])
            .value(this.selectedTimeText)
            .backgroundColor('#E6F7FF')
            .fontColor('#007DFF')
            .padding({ left: 20, right: 20, top: 8, bottom: 8 })
            .borderRadius(16)
            .controlSize(ControlSize.SMALL)
            .onSelect((index: number) => {
              if (index === 0) {
                this.selectedTimeRange = '3months';
                this.selectedTimeText = '近三个月';
              } else if (index === 1) {
                this.selectedTimeRange = '6months';
                this.selectedTimeText = '近六个月';
              } else if (index === 2) {
                this.selectedTimeRange = 'all';
                this.selectedTimeText = '全部时间';
              }
              this.loadAppointments();
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
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
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
    .padding({ left: 16, right: 16, top: 0, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
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
