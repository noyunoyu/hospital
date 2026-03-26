/**
 * 最终版 HttpUtil.ets（无任何类型报错）
 */
import http from '@ohos.net.http';
import { BusinessError } from '@ohos.base';
import List from '@ohos.util.List';

// 后端返回数据结构（必填字段，无undefined）
export interface ResponseDataContent {
  title: string;
  content: string;
  list: Array<string>;
}

// 接口返回完整结构（data 必填，无?）
export interface HttpResponseData {
  code: number;
  msg: string;
  data: ResponseDataContent; // 核心：移除?，确保必填
}

// POST请求参数（无索引签名，明确类型）
export interface RequestParams {
  title: string;
  content: string;
  list : Array<string>;
}

export class HttpUtil {
  private static baseUrl: string = "http://222.24.75.114:5000";

  static async get(url: string): Promise<HttpResponseData> {
    const httpRequest: http.HttpRequest = http.createHttp();
    try {
      const fullUrl: string = `${HttpUtil.baseUrl}${url}`;
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' }
      };
      const response: http.HttpResponse = await httpRequest.request(fullUrl, requestOptions);

      if (response.responseCode === 200 && typeof response.result === 'string') {
        const parsedResult: object = JSON.parse(response.result);
        return parsedResult as HttpResponseData;
      } else {
        // 兜底返回：确保data字段必有值（无undefined）
        return {
          code: response.responseCode,
          msg: `请求失败，状态码：${response.responseCode}`,
          data: { title: "", content: "", list: [] } // 核心：必填data
        };
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      // 兜底返回：确保data字段必有值
      return {
        code: 500,
        msg: `请求失败：${err.message || '网络异常'}`,
        data: { title: "", content: "", list: [] } // 核心：必填data
      };
    } finally {
      httpRequest.destroy();
    }
  }

  static async post(url: string, data: RequestParams): Promise<HttpResponseData> {
    const httpRequest: http.HttpRequest = http.createHttp();
    try {
      const fullUrl: string = `${HttpUtil.baseUrl}${url}`;
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(data) as string
      };
      const response: http.HttpResponse = await httpRequest.request(fullUrl, requestOptions);

      if (response.responseCode === 200 && typeof response.result === 'string') {
        const parsedResult: object = JSON.parse(response.result);
        return parsedResult as HttpResponseData;
      } else {
        return {
          code: response.responseCode,
          msg: `请求失败，状态码：${response.responseCode}`,
          data: { title: "", content: "", list: [] }
        };
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      return {
        code: 500,
        msg: `请求失败：${err.message || '网络异常'}`,
        data: { title: "", content: "", list: [] }
      };
    } finally {
      httpRequest.destroy();
    }
  }
}