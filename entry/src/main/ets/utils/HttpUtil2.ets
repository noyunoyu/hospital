import http from '@ohos.net.http';

const BASE_URL = "http://222.24.72.8:5000";

// 定义就诊人数据结构
export interface PatientData {
  id: number;
  name: string;
  relation: string;
  idNumber: string;   // 完整身份证号
  isDefault: number;  // 1-默认，0-非默认
  cardNumber: string;
}

export interface PatientListResponse {
  code: number;
  msg: string;
  data: PatientData[];
}

// 预约记录详情
export interface AppointmentData {
  doctorName: string;
  doctorTitle: string;
  hospital: string;
  address: string;
  department: string;
  clinicTime: string;
  waitTime: string;
  fee: string;
  appointmentTime: string;
  patientName: string;
  idCard: string;
  status: string;
}

export interface HttpResponseData {
  code: number;
  msg: string;
  data: AppointmentData;
}

// 新增：预约记录列表项
export interface AppointmentListItem {
  id: number;
  title: string;
  status: string;
  department: string;
  time: string;
  patient: string;
}

// 新增：预约记录列表响应
export interface AppointmentListResponse {
  code: number;
  msg: string;
  data: AppointmentListItem[];
}

// 缴费相关接口定义
// 药品明细项接口
export interface PaymentItem {
  drugName: string;
  unitPrice: string;
  quantity: number;
  drugTotal: string;
}

export interface PaymentOrder {
  orderNo: string;
  feeType: string;
  department: string;
  doctorName: string;
  patientName: string;
  medicalCardNo: string;
  paymentMethod: string;
  cardBalance: string;
  orderTotal: string;
  orderTime: string;
  drugCount: number;
}

export interface PaymentListResponse {
  code: number;
  msg: string;
  data: PaymentOrder[];
}

export interface PaymentDetail {
  orderNo: string;
  feeType: string;
  department: string;
  doctorName: string;
  patientName: string;
  medicalCardNo: string;
  paymentMethod: string;
  cardBalance: string;
  orderTotal: string;
  orderTime: string;
  items: PaymentItem[];  // 修复：使用接口类型而不是对象字面量
}

export interface PaymentDetailResponse {
  code: number;
  msg: string;
  data: PaymentDetail;
}


export class HttpUtil {
  static async get(url: string): Promise<HttpResponseData> {
    let httpRequest = http.createHttp();
    try {
      let result = await httpRequest.request(BASE_URL + url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000
      });

      if (result.responseCode === 200 && result.result) {
        return JSON.parse(result.result.toString());
      } else {
        return getEmptyResponse();
      }
    } catch (err) {
      console.error("请求失败", JSON.stringify(err));
      return getEmptyResponse();
    } finally {
      httpRequest.destroy();
    }
  }

  // 获取预约记录列表
  static async getAppointmentList(patientIdCard: string, timeRange: string): Promise<AppointmentListResponse> {
    let httpRequest = http.createHttp();
    try {
      let url = `${BASE_URL}/api/appointments?patient_id_card=${encodeURIComponent(patientIdCard)}&time_range=${encodeURIComponent(timeRange)}`;
      let result = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000
      });

      if (result.responseCode === 200 && result.result) {
        return JSON.parse(result.result.toString()) as AppointmentListResponse;
      } else {
        return {
          code: 500,
          msg: '获取预约记录失败',
          data: []
        };
      }
    } catch (err) {
      console.error("获取预约记录失败", JSON.stringify(err));
      return {
        code: 500,
        msg: '请求异常',
        data: []
      };
    } finally {
      httpRequest.destroy();
    }
  }

  // 取消预约接口
  static async cancelAppointment(appointmentId: number): Promise<HttpResponseData> {
    let httpRequest = http.createHttp();
    try {
      let url = `${BASE_URL}/api/appointment/cancel/${appointmentId}`;
      let result = await httpRequest.request(url, {
        method: http.RequestMethod.PUT,  // 使用PUT修改状态
        connectTimeout: 10000
      });

      if (result.responseCode === 200 && result.result) {
        return JSON.parse(result.result.toString()) as HttpResponseData;
      } else {
        return getEmptyResponse();
      }
    } catch (err) {
      console.error("取消预约失败", JSON.stringify(err));
      return getEmptyResponse();
    } finally {
      httpRequest.destroy();
    }
  }

  // 获取就诊人列表
  static async getPatients(): Promise<PatientListResponse> {
    let httpRequest = http.createHttp();
    try {
      let result = await httpRequest.request(BASE_URL + "/api/patients", {
        method: http.RequestMethod.GET,
        connectTimeout: 10000
      });
      if (result.responseCode === 200 && result.result) {
        return JSON.parse(result.result.toString()) as PatientListResponse;
      } else {
        return { code: 500, msg: "获取就诊人列表失败", data: [] };
      }
    } catch (err) {
      console.error("获取就诊人列表异常", JSON.stringify(err));
      return { code: 500, msg: "请求异常", data: [] };
    } finally {
      httpRequest.destroy();
    }
  }

  // 获取缴费订单列表
  static async getPaymentList(medicalCardNo: string, timeRange: string): Promise<PaymentListResponse> {
    let httpRequest = http.createHttp();
    try {
      let url = `${BASE_URL}/api/payments?medical_card_no=${encodeURIComponent(medicalCardNo)}&time_range=${encodeURIComponent(timeRange)}`;
      let result = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000
      });
      if (result.responseCode === 200 && result.result) {
        return JSON.parse(result.result.toString()) as PaymentListResponse;
      } else {
        return { code: 500, msg: '获取缴费记录失败', data: [] };
      }
    } catch (err) {
      console.error("获取缴费记录失败", JSON.stringify(err));
      return { code: 500, msg: '请求异常', data: [] };
    } finally {
      httpRequest.destroy();
    }
  }

  // 获取缴费订单详情
  static async getPaymentDetail(orderNo: string): Promise<PaymentDetailResponse> {
    let httpRequest = http.createHttp();
    try {
      let result = await httpRequest.request(BASE_URL + `/api/payment/${orderNo}`, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000
      });
      if (result.responseCode === 200 && result.result) {
        return JSON.parse(result.result.toString()) as PaymentDetailResponse;
      } else {
        // 修复：创建默认的空对象而不是使用 null
        const emptyDetail: PaymentDetail = {
          orderNo: '',
          feeType: '',
          department: '',
          doctorName: '',
          patientName: '',
          medicalCardNo: '',
          paymentMethod: '',
          cardBalance: '',
          orderTotal: '',
          orderTime: '',
          items: []
        };
        return { code: 500, msg: '获取订单详情失败', data: emptyDetail };
      }
    } catch (err) {
      console.error("获取订单详情失败", JSON.stringify(err));
      const emptyDetail: PaymentDetail = {
        orderNo: '',
        feeType: '',
        department: '',
        doctorName: '',
        patientName: '',
        medicalCardNo: '',
        paymentMethod: '',
        cardBalance: '',
        orderTotal: '',
        orderTime: '',
        items: []
      };
      return { code: 500, msg: '请求异常', data: emptyDetail };
    } finally {
      httpRequest.destroy();
    }
  }

  // 辅助函数：身份证脱敏（显示前3位+****+后4位）
  static maskIdNumber(idNumber: string): string {
    if (!idNumber || idNumber.length < 8) return idNumber;
    const start = idNumber.substring(0, 3);
    const end = idNumber.substring(idNumber.length - 4);
    return `${start}********${end}`;
  }

  // 根据 开始日期 + 结束日期 获取缴费记录
  static async getPaymentListByDate(medicalCardNo: string, startTime: string, endTime: string): Promise<PaymentListResponse> {
    let httpRequest = http.createHttp();
    try {
      let url = `${BASE_URL}/api/payments/custom?medical_card_no=${encodeURIComponent(medicalCardNo)}&start_time=${encodeURIComponent(startTime)}&end_time=${encodeURIComponent(endTime)}`;

      let result = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000
      });

      if (result.responseCode === 200 && result.result) {
        return JSON.parse(result.result.toString()) as PaymentListResponse;
      } else {
        return { code: 500, msg: '获取失败', data: [] };
      }
    } catch (err) {
      console.error("err", err);
      return { code: 500, msg: '异常', data: [] };
    } finally {
      httpRequest.destroy();
    }
  }

  // 根据 开始日期 + 结束日期 获取【预约记录】
  static async getAppointmentListByDate(
    patientIdCard: string,
    startTime: string,
    endTime: string
  ): Promise<AppointmentListResponse> {
    let httpRequest = http.createHttp();
    try {
      let url = `${BASE_URL}/api/appointments/custom?patient_id_card=${encodeURIComponent(patientIdCard)}&start_time=${encodeURIComponent(startTime)}&end_time=${encodeURIComponent(endTime)}`;

      let result = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000
      });

      if (result.responseCode === 200 && result.result) {
        return JSON.parse(result.result.toString()) as AppointmentListResponse;
      } else {
        return { code: 500, msg: '获取失败', data: [] };
      }
    } catch (err) {
      console.error("err", err);
      return { code: 500, msg: '异常', data: [] };
    } finally {
      httpRequest.destroy();
    }
  }


}


function getEmptyResponse(): HttpResponseData {
  return {
    code: 500,
    msg: "",
    data: {
      doctorName: "",
      doctorTitle: "",
      hospital: "",
      address: "",
      department: "",
      clinicTime: "",
      waitTime: "",
      fee: "",
      appointmentTime: "",
      patientName: "",
      idCard: "",
      status: ""
    }
  };
}
