// Http.ets 完全无 any、无 unknown、100% 合规
import http from '@ohos.net.http';

export interface RegistrationDetail {
  id: number;
  doctor_name: string;
  doctor_title: string;
  hospital_name: string;
  hospital_address: string;
  department: string;
  clinic_time: string;
  waiting_time: string;
  fee: number;
  appointment_time: string;
  patient_name: string;
  patient_id_card: string;
}

export interface PaymentDetail {
  id: number;
  price: number;
  pay_time: string;
  status: number;
}

// 明确分离：列表接口 / 详情接口
export type RegistrationList = RegistrationDetail[];
export type PaymentList = PaymentDetail[];

const baseURL = 'http://127.0.0.1:8000';

export class Http {
  // 获取预约详情（返回单个对象）
  static async getRegistrationDetail(id: number): Promise<RegistrationDetail | null> {
    const req = http.createHttp();
    try {
      const res = await req.request(`${baseURL}/registration/detail/${id}`, {
        method: http.RequestMethod.GET
      });
      if (res.responseCode === 200) {
        return JSON.parse(res.result.toString()) as RegistrationDetail;
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      req.destroy();
    }
  }

  // 获取预约列表（返回数组）
  static async getRegistrationList(): Promise<RegistrationList | null> {
    const req = http.createHttp();
    try {
      const res = await req.request(`${baseURL}/registration/list`, {
        method: http.RequestMethod.GET
      });
      if (res.responseCode === 200) {
        return JSON.parse(res.result.toString()) as RegistrationList;
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      req.destroy();
    }
  }
}