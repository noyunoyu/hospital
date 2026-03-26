import { Http } from './Http';

export async function getPaymentRecords(idCard: string) {
  return await Http.get('/payment/records/' + idCard);
}

export async function getPaymentDetail(id: number) {
  return await Http.get('/payment/detail/' + id);
}