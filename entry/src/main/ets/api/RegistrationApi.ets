import { Http } from './Http';

export async function getRegistrationRecords(idCard: string) {
  return await Http.get('/registration/records/' + idCard);
}

export async function getRegistrationDetail(id: number) {
  return await Http.get('/registration/detail/' + id);
}