import { useCallback, useEffect, useState } from 'react';
import { useRecoilState } from 'recoil';
import { socketAtom } from '../recoil/atoms';
import { Socket } from 'phoenix';

export enum PhxSocketStates {
  UNINSTANTIATED = 'UNINSTANTIATED',
  CONNECTING = 'CONNECTING',
  OPEN = 'OPEN',
  CLOSING = 'CLOSING',
  CLOSED = 'CLOSED',
}

export const usePhxSocket = () => {
  const [socket, setSocket] = useRecoilState(socketAtom);
  const [status, setStatus] = useState<PhxSocketStates>(
    PhxSocketStates.UNINSTANTIATED
  );

  useEffect(() => {
    socket?.onOpen(() => setStatus(PhxSocketStates.OPEN));
    socket?.onClose(() => {
      setStatus(PhxSocketStates.CLOSING);
      disconnect();
    });
    socket?.onError(() => setStatus(PhxSocketStates.CLOSED));
  }, [socket]);

  const connect = useCallback((socket: Socket) => {
    setStatus(PhxSocketStates.CONNECTING);
    socket.connect();
    setSocket(socket);
  }, []);

  const disconnect = useCallback(() => {
    socket?.disconnect();
  }, [socket]);

  return {
    socket,
    connect,
    status,
    disconnect,
  };
};
