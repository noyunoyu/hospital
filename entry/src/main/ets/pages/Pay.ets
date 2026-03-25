import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { EditableLeftIconType } from '@kit.ArkUI';

// 1. 显式定义接口
interface PayItem {
  title: string;
  department: string;
  name: string;
  time: string;
  money: string;
  url: string;
}

interface PatientItem {
  name: string;
  tag: string;
  id: string;
  relation: string;
}

@Entry
@Component
struct Pay {
  // 控制弹窗显示
  @State isShowDialog: boolean = false;

  // 【新增】当前选中的就诊人状态变量
  // 初始值设为列表中的第一个，确保界面初始化时有数据
  @State currentPatient: PatientItem = {
    name: '蒋峰',
    tag: '本人',
    id: '622*********0909',
    relation: ''
  };

  // 初始化数据
  private patients: PatientItem[] = [
    { name: '蒋峰', tag: '本人', id: '622*********0909', relation: '' },
    { name: '范东升', tag: '父母', id: '622*********9090', relation: '父亲' }
  ];

  @State payment: PayItem[] = [
    { title: "西药费", department: "神经内科", name: "刘美", time: "2020-06-10 11:05", money: "60.00", url: "pages/detail" },
    { title: "西药费", department: "神经内科", name: "刘美", time: "2020-06-10 11:05", money: "60.00", url: "pages/detail" },
    { title: "西药费", department: "神经内科", name: "刘美", time: "2020-06-10 11:05", money: "60.00", url: "pages/detail" }
  ];

  build() {
    Stack() {
      // --- 主页面内容 ---
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

          Image($r('app.media.youshangjiao'))
            .width(96)
            .height(35)
            .margin({ right: 16, bottom: 5 });
        }
        .width('100%')
        .height(48)
        .alignItems(VerticalAlign.Center)
        .backgroundColor(Color.White);

        // 个人名片
        Column() {
          Row() {
            // 【修改】绑定 currentPatient.name
            Text(this.currentPatient.name)
              .margin({
                top:30
              })


            // 【修改】绑定 currentPatient.tag
            Text(this.currentPatient.tag)
              .fontSize(12)
              .margin({
                top:28,
                left:10,
                right:120

              })
              .backgroundColor('#E2EDFE')
              .fontColor('#4C98FF')
              .borderWidth(4)
              .borderColor('#E2EDFE')
              .borderRadius(8);

            Image($r('app.media.qiehuan'))
              .width(25)
              .height(25)
              .margin({
                top: 30,
                left:25
              })
              .onClick(() => {
                this.isShowDialog = true;
              });
          }
          Blank();
          Row() {
            // 【修改】绑定 currentPatient.id
            Text(this.currentPatient.id)
              .fontColor("#D3D5D8")
              .position({ x: 16, y: 65 });

            Text("切换就诊人")
              .fontColor("#D3D7DC")
              .position({ x: 230, y: 65 })
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

        // 选择时间
        Row() {
          Text("   近一年")
            .height(25)
            .width(65)
            .backgroundColor("#006EFF")
            .fontColor("#86BAFF")
            .borderRadius(13)
            .fontSize(14)
            .position({ x: -85 });

          // 注意：如果这里编译报错，请参照之前的建议简化 Select 写法
          Select([
            { value: "时间1" },
            { value: "时间2" }
          ]).value("选择时间")
            .backgroundColor("#E4F0FF")
            .fontColor("#87BBFF")
            .controlSize(ControlSize.SMALL)
            .margin({ right: 40 })

        }

        Blank(20);

        // 门诊缴费列表
        List() {
          ForEach(this.payment, (item: PayItem) => {
            ListItem() {
              this.buildPaymentCard(item);
            }
            .padding({ bottom: 12, left: 15 })
          });
        }
        .width("100%")
        .height("100%");
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FDFEFF');

      // --- 弹窗遮罩层 (条件渲染) ---
      if (this.isShowDialog) {
        Column() {
          Blank();

          Column() {
            // 标题栏
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

            // 就诊人列表
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
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .backgroundColor('#E8F3FF')
                          .borderRadius(4)
                          .fontColor('#007AFF')
                          .margin({ left: 8 });
                      }

                      Text(patient.id)
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
                    // 【核心修改】更新状态变量，触发界面刷新
                    this.currentPatient = patient;
                    console.info(`选择了就诊人: ${patient.name}`);

                    // 关闭弹窗
                    this.isShowDialog = false;
                  });
                }
                .backgroundColor('#FFFFFF');
              }, (patient: PatientItem) => patient.id);
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
    }
  }

  @Builder
  buildPaymentCard(item: PayItem) {
    Row() {
      Column() {
        Text(item.title)
          .fontSize(18)
          .fontColor("#838383")
          .fontWeight(500)
          .margin({ right: 13, bottom: 10 });

        Text(item.department + ' ' + item.name)
          .fontColor("#D3D3D3")
          .fontSize(12)
          .margin({ left: 5 });

        Text(item.time)
          .fontColor("#D3D3D3")
          .fontSize(12)
          .letterSpacing(-1)
          .margin({ left: 15, top: 4 });
      }

      Column() {
        Text("￥" + item.money)
          .fontColor("#F57979")
          .fontSize(20)
          .fontWeight(600);
      }
      .margin({ left: 130 });
    }
    .borderWidth(2)
    .height(110)
    .width(330)
    .borderColor("#E3E3E3")
    .onClick(() => {
      router.pushUrl({ url: item.url })
    })
  }
}