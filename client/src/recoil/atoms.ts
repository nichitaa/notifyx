import { atom } from 'recoil';
import { Socket } from 'phoenix';

export const userCredentialsAtom = atom<{ email: string; password: string }>({
  key: 'userCredentialsAtom',
  default: {
    email: 'first@gmail.com',
    password: '123',
  },
});

export const socketAtom = atom<Socket | undefined>({
  dangerouslyAllowMutability: true,
  key: 'socketAtom',
  default: undefined,
});
