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
  status: number;
}

export interface PaymentDetail {
  id: number;
  order_no: string;
  amount: number;
  payment_time: string;
  dept_name: string;
  doctor_name: string;
  patient_name: string;
  patient_id_card: string;
}