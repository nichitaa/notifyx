import { atom } from 'recoil';

export const notificationsAtom = atom<string[]>({
  key: 'notificationsAtom',
  default: [],
});