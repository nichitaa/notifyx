import { usePhxSocket } from './use-phx-socket';
import { useEffect, useReducer, useState } from 'react';

type Reducer<S, A> = (prevState: S, action: A) => S;

export const usePhxChannel = <S, A>(
  channelTopic: string,
  reducer: Reducer<S, A>,
  initialState: S
) => {
  const { socket } = usePhxSocket();

  const [state, dispatch] = useReducer(reducer, initialState);
  const [broadcast, setBroadcast] = useState<
    (event: string, payload: object) => void
  >(() => console.log('must join a channel before broadcasting'));

  useEffect(() => {
    const channel = socket.channel(channelTopic, {});

    channel.onMessage = (event: string, payload: any, ref) => {
      console.log({ event, payload, ref });
      // @ts-ignore
      dispatch({ event, payload });
      return payload;
    };

    channel
      .join()
      .receive('ok', ({ messages }) =>
        console.log('successfully joined channel', messages || '')
      )
      .receive('error', ({ reason }) =>
        console.error('failed to join channel', reason)
      );

    setBroadcast(() => channel.push.bind(channel));
    return () => {
      channel.leave();
    };
  }, [channelTopic]);

  return {
    state,
    broadcast,
    dispatch,
  };
};
