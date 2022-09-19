import { atom } from 'recoil';

export const notificationsAtom = atom<string[]>({
  key: 'notificationsAtom',
  default: [],
});

export const userCredentialsAtom = atom<{ email: string; password: string }>({
  key: 'userCredentialsAtom',
  default: {
    email: 'first@gmail.com',
    password: '123',
  },
});