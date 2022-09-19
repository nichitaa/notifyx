import { Socket } from 'phoenix';
import { useEffect, useState } from 'react';

const socket = new Socket('ws://localhost:5000/socket', {});

export enum PhxSocketStates {
  UNINSTANTIATED = 'UNINSTANTIATED',
  CONNECTING = 'CONNECTING',
  OPEN = 'OPEN',
  CLOSING = 'CLOSING',
  CLOSED = 'CLOSED',
}

export const usePhxSocket = () => {
  const [status, setStatus] = useState<PhxSocketStates>(
    PhxSocketStates.UNINSTANTIATED
  );

  useEffect(() => {
    socket.onOpen(() => setStatus(PhxSocketStates.OPEN));
    socket.onClose(() => {
      setStatus(PhxSocketStates.CLOSING);
      disconnect();
    });
    socket.onError(() => setStatus(PhxSocketStates.CLOSED));
  }, []);

  const connect = (params: { email: string; password: string }) => {
    setStatus(PhxSocketStates.CONNECTING);
    socket.connect(params);
  };

  const disconnect = () => {
    socket.disconnect();
  };

  return {
    connect,
    status,
    disconnect,
    socket,
  };
};
