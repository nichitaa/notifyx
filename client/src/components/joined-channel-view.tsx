import {
  alpha,
  Box,
  ButtonGroup,
  Divider,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Tooltip,
  Typography,
} from '@mui/material';
import { LoadingButton } from '@mui/lab';
import { FC, useState } from 'react';
import { usePhxSocket } from '../hooks/use-phx-socket';
import SendIcon from '@mui/icons-material/Send';
import EmailIcon from '@mui/icons-material/Email';
import { useSetRecoilState } from 'recoil';
import { avatarSrcAtom } from '../recoil/atoms';

const channelPrefix = 'notification';

interface MainProps {
  defaultTopicName: string;
}

const JoinedChannelView = (props: MainProps) => {
  const { defaultTopicName } = props;
  const { socket } = usePhxSocket();

  const [loadingJoinChannel, setLoadingJoinChannel] = useState(false);
  const [joinedChannel, setJoinedChannel] = useState(false);
  const [topicName, setTopicName] = useState(defaultTopicName);
  const [canBroadcast, setCanBroadcast] = useState(false);
  const [broadcast, setBroadcast] = useState(() =>
    console.log('connect to topic before broadcasting')
  );
  const [unsubscribe, setUnsubscribe] = useState<() => void>(() => {
    console.log('connect to topic before broadcasting');
  });
  const [oldChannelNotification, setOldChannelNotifications] = useState<any[]>(
    []
  );
  const [channelNotifications, setChannelNotifications] = useState<any[]>([]);
  const [message, setMessage] = useState('default_message');
  const [toEmailAddress, setToEmailAddress] = useState('nichittaa@gmail.com');
  const [loadingSendEmail, setLoadingSendEmail] = useState(false);
  const setAvatarSrc = useSetRecoilState(avatarSrcAtom);

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

  const handleSendEmail = () => {
    let msg = message.trim();
    let adr = toEmailAddress.trim();
    if (msg !== undefined && adr !== undefined) {
      setLoadingSendEmail(true);
      // @ts-ignore
      broadcast('send_email', {
        to: adr,
        message: msg,
      });
    }
  };

  const handleGenerateAvatar = () => {
    let msg = message.trim();
    if (msg !== undefined) {
      // @ts-ignore
      broadcast('generate_avatar', {
        size: 128,
        name: msg,
        type: 'github',
      });
    }
  };

  const handleSubscribeToTopic = () => {
    if (topicName.trim() === '') return;
    const channelTopic = `${channelPrefix}:${topicName}`;
    console.log('channelTopic: ', channelTopic);
    setLoadingJoinChannel(true);
    const channel = socket!.channel(channelTopic, {});

    channel.on('phx_reply', ({ response }) => {
      console.log('[phx_reply] response: ', response);
      if (response.from_join) {
        setCanBroadcast(response.can_broadcast);
      }
      if (response.from_send_email) {
        setLoadingSendEmail(false);
      }
    });

    channel.on('generate_avatar', (response) => {
      if (response instanceof ArrayBuffer) {
        const blob = new Blob([response]);
        const url = URL.createObjectURL(blob);
        setAvatarSrc(url);
      }
    });
    channel.on('new_notification', (response) => {
      console.log('[new_notification] response: ', response);
      setChannelNotifications((prev) => [...prev, response]);
    });
    channel.on('own_notifications_for_topic', (response) => {
      console.log('[own_notifications_for_topic] response: ', response);
      if (response.success) {
        setOldChannelNotifications(response.notifications);
      }
    });
    channel
      .join()
      .receive('ok', ({ messages }) => {
        setJoinedChannel(true);
        setLoadingJoinChannel(false);
        console.log('successfully joined channel', messages || '');
        // get notifications
        channel.push('own_notifications_for_topic', {});
      })
      .receive('error', ({ reason }) => {
        setJoinedChannel(false);
        setLoadingJoinChannel(false);
        console.error('failed to join channel', reason);
      });
    setBroadcast(() => channel.push.bind(channel));
    setUnsubscribe(() => channel.leave.bind(channel));
  };

  return (
    <>
      <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
        <TextField
          required
          size={'small'}
          label='topic name'
          value={topicName}
          disabled={joinedChannel}
          onChange={(event) => setTopicName(event.target.value)}
        />
        {joinedChannel ? (
          <ButtonGroup>
            <LoadingButton
              size={'medium'}
              onClick={handleGenerateAvatar}
              variant={'outlined'}
              color={'warning'}
            >
              <code>generate avatar</code>
            </LoadingButton>
            <LoadingButton
              size={'medium'}
              onClick={handleUnsubscribe}
              variant={'outlined'}
              color={'error'}
            >
              <code>unsubscribe</code>
            </LoadingButton>
          </ButtonGroup>
        ) : (
          <LoadingButton
            disabled={loadingJoinChannel || joinedChannel}
            onClick={handleSubscribeToTopic}
            variant={'outlined'}
            color={'success'}
          >
            <code>subscribe</code>
          </LoadingButton>
        )}
      </Box>

      {joinedChannel && (
        <>
          <Divider textAlign={'left'} sx={{ m: '20px 0' }}>
            <CodeStyles>notification:{topicName.trim()}</CodeStyles>
          </Divider>
          <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
            <TextField
              required
              size={'small'}
              label='message'
              value={message}
              onChange={(event) => setMessage(event.target.value)}
            />
            <TextField
              required
              size={'small'}
              label='to_address'
              value={toEmailAddress}
              onChange={(event) => setToEmailAddress(event.target.value)}
            />
            <ButtonGroup>
              <Tooltip title='Sends email to the specified address'>
                <LoadingButton
                  onClick={handleSendEmail}
                  variant={'outlined'}
                  loading={loadingSendEmail}
                  color={'warning'}
                  endIcon={<EmailIcon />}
                >
                  <code>mail</code>
                </LoadingButton>
              </Tooltip>
              <Tooltip title='Broadcasts message to all topic subscribers'>
                <span>
                  <LoadingButton
                    disabled={!canBroadcast}
                    onClick={broadcastNewNotification}
                    variant={'outlined'}
                    color={'primary'}
                    sx={{ height: 40 }}
                    endIcon={<SendIcon />}
                  >
                    <code>broadcast</code>
                  </LoadingButton>
                </span>
              </Tooltip>
            </ButtonGroup>
          </Box>
          <br />
          {/* OLD Notification */}
          <Divider textAlign={'left'} sx={{ m: '10px 0' }}>
            <CodeStyles>Previous</CodeStyles>
          </Divider>
          <TableContainer component={Paper} sx={{ maxHeight: 300 }}>
            <Table size={'small'} stickyHeader>
              <TableHead>
                <TableRow>
                  <TableCell>NotificationId</TableCell>
                  <TableCell>Topic</TableCell>
                  <TableCell>From</TableCell>
                  <TableCell>Notification</TableCell>
                  <TableCell>Status</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {oldChannelNotification.map((row, index) => (
                  <TableRow
                    key={row.notification_id}
                    sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                  >
                    <TableCell sx={{ whiteSpace: 'nowrap' }}>
                      {row.notification_id}
                    </TableCell>
                    <TableCell>{row.topic_name}</TableCell>
                    <TableCell>{row.from}</TableCell>
                    <TableCell>{row.message}</TableCell>
                    <TableCell>{row.status}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>

          {/* NEW Notifications */}
          <Divider textAlign={'left'} sx={{ m: '10px 0' }}>
            <CodeStyles>New</CodeStyles>
          </Divider>
          <TableContainer component={Paper} sx={{ maxHeight: 300 }}>
            <Table size={'small'} stickyHeader>
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
                    sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                  >
                    <TableCell>{row.from}</TableCell>
                    <TableCell>{row.message}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </>
      )}
      <Divider textAlign={'left'} sx={{ m: '50px 0' }}></Divider>
    </>
  );
};

const CodeStyles: FC = ({ children }) => {
  return (
    <Typography
      component={'div'}
      sx={{
        background: alpha('#fff', 0.1),
        padding: '3px',
        border: (theme) =>
          `2px solid ${alpha(theme.palette.primary.main, 0.3)}`,
        textAlign: 'center',
        borderRadius: 1,
      }}
    >
      <code>{children}</code>
    </Typography>
  );
};

export default JoinedChannelView;
