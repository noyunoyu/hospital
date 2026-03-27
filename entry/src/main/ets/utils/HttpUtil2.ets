import http from '@ohos.net.http';

const BASE_URL = "http://222.24.75.128:5000";

// 定义就诊人数据结构
export interface PatientData {
  id: number;
  name: string;
  relation: string;
  idNumber: string;   // 完整身份证号
  isDefault: number;  // 1-默认，0-非默认
}

export interface PatientListResponse {
  code: number;
  msg: string;
  data: PatientData[];
}

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

  // 新增：获取预约记录列表
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

  // 辅助函数：身份证脱敏（显示前3位+****+后4位）
  static maskIdNumber(idNumber: string): string {
    if (!idNumber || idNumber.length < 8) return idNumber;
    const start = idNumber.substring(0, 3);
    const end = idNumber.substring(idNumber.length - 4);
    return `${start}********${end}`;
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
