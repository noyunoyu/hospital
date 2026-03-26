/**
 * 最终版 Index.ets（无任何类型报错）
 */

import { HttpUtil, HttpResponseData, ResponseDataContent, RequestParams } from '../utils/HttpUtil';

@Entry
@Component
struct Index {
  // 明确状态变量类型
  @State title: string = "";
  @State content: string = "";
  @State list: string[] = [];

  // 明确方法返回值类型
  async aboutToAppear(): Promise<void> {
    // 调用接口，类型完全匹配
    const res: HttpResponseData = await HttpUtil.get('/api/get_data');

    // 仅判断状态码，无需判断data（因为data必填）
    if (res.code === 200) {
      // 直接赋值：res.data 是必填的 ResponseDataContent 类型，无undefined
      const data: ResponseDataContent = res.data;
      this.title = data.title ?? "";
      this.content = data.content ?? "";
      this.list = data.list ?? [];
    }
  }
  async submitToDb(): Promise<void> {
    // 修复核心：显式声明params为RequestParams类型，而非匿名对象
    const params: RequestParams = {
      title: "前端提交的标题",
      content: "前端提交的内容",
      list: ["提交数据1", "提交数据2"]
    };
    // 显式声明res类型，符合规范
    const res: HttpResponseData = await HttpUtil.post('/api/submit_data', params);
    if (res.code === 200) {
      console.log("提交成功");
      // 重新获取数据刷新UI
      this.aboutToAppear();
    }
  }



  // 原UI结构完全保留，仅补充ForEach的item类型
  build() {
    Column() {
      Text(this.title)
        .fontSize(30)
        .fontWeight(FontWeight.Bold);
      Text(this.content)
        .fontSize(20)
        .margin({ top: 10 });
      List() {
        // 显式指定item类型为string，消除隐式any
        ForEach(this.list, (item: string) => {
          ListItem() {
            Text(item)
              .fontSize(16)
              .margin({ top: 5 });
          }
        })
      }
      // build() 中新增按钮（仅示例，不改动原有UI）
      Button("提交数据")
        .onClick(() => this.submitToDb())
        .margin({ top: 20 })
    }
    .padding(20)

  }

}