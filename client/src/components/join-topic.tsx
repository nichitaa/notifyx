import { Box, Divider, TextField } from '@mui/material';
import { LoadingButton } from '@mui/lab';
import { useState } from 'react';
import { usePhxSocket } from '../hooks/use-phx-socket';
import ReactJson from 'react-json-view';


const channelPrefix = 'notification';

const JoinTopic = () => {
  const { socket } = usePhxSocket();

  const [loadingJoinChannel, setLoadingJoinChannel] = useState(false);
  const [joinedChannel, setJoinedChannel] = useState(false);
  const [topicName, setTopicName] = useState('topic_name');
  const [broadcast, setBroadcast] = useState(() => console.log('connect to topic before broadcasting'));
  const [unsubscribe, setUnsubscribe] = useState<() => void>(() => {
    console.log('connect to topic before broadcasting');
  });
  const [channelNotifications, setChannelNotifications] = useState<any[]>([]);
  const [message, setMessage] = useState('default_message');

  const broadcastNewNotification = () => {
    // @ts-ignore
    broadcast(`new_notification`, {
      message,
      to: null,
    });
  };

  const handleUnsubscribe = () => {
    unsubscribe();
    setBroadcast(() => console.log('connect to topic before broadcasting'));
    setJoinedChannel(false);
    setChannelNotifications([]);
    setUnsubscribe(() => {
      console.log('connect to topic before broadcasting');
    });
  };

  const handleSubscribeToTopic = () => {
    if (topicName.trim() === '') return;
    const channelTopic = `${channelPrefix}:${topicName}`;
    console.log('channelTopic: ', channelTopic);
    setLoadingJoinChannel(true);
    const channel = socket!.channel(channelTopic, {});

    channel.onMessage = (event: string, payload: any, ref) => {
      console.log('[channelTopic]: channelTopic recv: ', { event, payload, ref });
      if (event === 'new_notification') {
        setChannelNotifications(prev => [...prev, payload]);
      }
      return payload;
    };
    channel
      .join()
      .receive('ok', ({ messages }) => {
          setJoinedChannel(true);
          setLoadingJoinChannel(false);
          console.log('successfully joined channel', messages || '');
        },
      )
      .receive('error', ({ reason }) => {
          setJoinedChannel(false);
          setLoadingJoinChannel(false);
          console.error('failed to join channel', reason);
        },
      );
    setBroadcast(() => channel.push.bind(channel));
    setUnsubscribe(() => channel.leave.bind(channel));
  };

  return (
    <>
      <Divider textAlign={'left'} sx={{ m: '10px 0' }}>
        Topics
      </Divider>
      <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
        <TextField
          required
          size={'small'}
          label='topic name'
          value={topicName}
          disabled={joinedChannel}
          onChange={event => setTopicName(event.target.value)}
        />
        {
          joinedChannel
          && <LoadingButton
            // disabled={state.loading}
            onClick={handleUnsubscribe}
            variant={'contained'}
          >
            <code>unsubscribe</code>
          </LoadingButton>
        }
        <LoadingButton
          disabled={loadingJoinChannel}
          onClick={handleSubscribeToTopic}
          variant={'contained'}
        >
          <code>create || subscribe</code>
        </LoadingButton>
      </Box>

      {joinedChannel &&
        <>
          <Divider textAlign={'left'} sx={{ m: '10px 0' }}>
            Send notification for {`notification:${topicName.trim()}`}
          </Divider>
          <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
            <TextField
              required
              size={'small'}
              label='notification'
              value={message}
              onChange={(event) => setMessage(event.target.value)}
            />
            <LoadingButton
              // disabled={state.loading}
              onClick={broadcastNewNotification}
              variant={'contained'}
            >
              <code>broadcast</code>
            </LoadingButton>
          </Box>

          <br />
          <Box sx={{ height: 300, overflow: 'auto' }}>
            <ReactJson src={channelNotifications} theme={'tomorrow'} name={'notifications'} />
          </Box>
        </>
      }
    </>
  );
};

export default JoinTopic;