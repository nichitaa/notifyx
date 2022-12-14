import { atom } from 'recoil';
import { Socket } from 'phoenix';

export const userCredentialsAtom = atom<{ email: string; password: string }>({
  key: 'userCredentialsAtom',
  default: {
    email: '1@gmail.com',
    password: '123',
  },
});

export const socketAtom = atom<Socket | undefined>({
  dangerouslyAllowMutability: true,
  key: 'socketAtom',
  default: undefined,
});

export const avatarSrcAtom = atom<undefined | string>({
  key: 'avatarSrcAtom',
  default: undefined,
});
