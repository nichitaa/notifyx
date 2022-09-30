import {
  Box,
  Divider,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField
} from '@mui/material';
import {LoadingButton} from '@mui/lab';
import {useState} from 'react';
import {usePhxSocket} from '../hooks/use-phx-socket';

const channelPrefix = 'notification';

interface MainProps {
  defaultTopicName: string
}

const JoinTopic = (props: MainProps) => {
  const {defaultTopicName} = props;
  const {socket} = usePhxSocket();

  const [loadingJoinChannel, setLoadingJoinChannel] = useState(false);
  const [joinedChannel, setJoinedChannel] = useState(false);
  const [topicName, setTopicName] = useState(defaultTopicName);
  const [canBroadcast, setCanBroadcast] = useState(false);
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
      to: [],
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

    channel.on('phx_reply', ({response}) => {
      console.log('[phx_reply] response: ', response);
      if (response.from_join) {
        console.log('broadcast: ', response.can_broadcast)
        setCanBroadcast(response.can_broadcast);
      }

    })

    channel.on('new_notification', (response) => {
      console.log('[new_notification] response: ', response);
      setChannelNotifications(prev => [...prev, response]);
    })
    channel
      .join()
      .receive('ok', ({messages}) => {
          setJoinedChannel(true);
          setLoadingJoinChannel(false);
          console.log('successfully joined channel', messages || '');
        },
      )
      .receive('error', ({reason}) => {
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
      <Box sx={{display: 'flex', justifyContent: 'space-between'}}>
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
            onClick={handleUnsubscribe}
            variant={'contained'}
          >
            <code>unsubscribe</code>
          </LoadingButton>
        }
        <LoadingButton
          disabled={loadingJoinChannel || joinedChannel}
          onClick={handleSubscribeToTopic}
          variant={'contained'}
        >
          <code>create || subscribe</code>
        </LoadingButton>
      </Box>

      {joinedChannel &&
        <>
          <Divider textAlign={'left'} sx={{m: '10px 0'}}>
            Send notification for {`notification:${topicName.trim()}`}
          </Divider>
          <Box sx={{display: 'flex', justifyContent: 'space-between'}}>
            <TextField
              required
              size={'small'}
              label='notification'
              value={message}
              onChange={(event) => setMessage(event.target.value)}
            />
            <LoadingButton
              disabled={!canBroadcast}
              onClick={broadcastNewNotification}
              variant={'contained'}
            >
              <code>broadcast</code>
            </LoadingButton>
          </Box>
          <Divider textAlign={'left'} sx={{m: '10px 0'}}>
            Notification list
          </Divider>
          <TableContainer component={Paper} sx={{maxHeight: 300}}>
            <Table aria-label="simple table" stickyHeader>
              <TableHead>
                <TableRow>
                  <TableCell>From</TableCell>
                  <TableCell>Notification</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {channelNotifications.map((row, index) => (
                  <TableRow
                    // TODO
                    key={index}
                    sx={{'&:last-child td, &:last-child th': {border: 0}}}
                  >
                    <TableCell>
                      {row.from}
                    </TableCell>
                    <TableCell>{row.message}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </>
      }
      <Divider textAlign={'left'} sx={{m: '10px 0'}}></Divider>
    </>
  );
};

export default JoinTopic;