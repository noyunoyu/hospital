import http from '@ohos.net.http';

const BASE_URL = "http://192.168.0.7:5000";

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
      console.error("请求失败", err);
      return getEmptyResponse();
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