import {
  Box,
  BoxProps,
  Button,
  Divider,
  styled,
  TextField,
  Typography,
} from '@mui/material';
import { LoadingButton } from '@mui/lab';
import { usePhxSocket } from '../hooks/use-phx-socket';
import { usePhxChannel } from '../hooks/use-phx-channel';
import { useState } from 'react';
import { useRecoilValue } from 'recoil';
import { userCredentialsAtom } from '../recoil/atoms';

type Notification = {
  from: string;
  message: string;
  seen_date: string | null;
  send_date: string | null;
  to: string | null;
};
type State = { notifications: Notification[]; loading: boolean };
type Actions =
  | {
      event: 'new_notification';
      payload: Notification;
    }
  | {
      event: 'send_notification';
      payload?: undefined;
    }
  | {
      event: 'phx_reply';
      payload: {
        response: {
          success: boolean;
        };
      };
    };

const channelName = 'notification:all';
const reducer = (state: State, { event, payload }: Actions) => {
  switch (event) {
    case 'new_notification': {
      return {
        ...state,
        notifications: [...state.notifications, payload],
      };
    }
    case 'phx_reply': {
      return {
        ...state,
        loading: false,
      };
    }
    case 'send_notification': {
      return {
        ...state,
        loading: true,
      };
    }
    default: {
      return state;
    }
  }
};
const initialState: State = {
  loading: false,
  notifications: [],
};

const UserNotifications = () => {
  const { disconnect } = usePhxSocket();
  const userCredentials = useRecoilValue(userCredentialsAtom);
  const [message, setMessage] = useState('default message');
  const [to, setTo] = useState('second@gmail.com');
  const { state, broadcast, dispatch } = usePhxChannel(
    channelName,
    reducer,
    initialState
  );

  const broadcastNewNotification = () => {
    dispatch({ event: 'send_notification' });
    broadcast('new_notification', {
      message,
      to,
    });
  };
  return (
    <StyledUserNotificationBox>
      <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
        <Typography component={'div'}>
          <TextField
            required
            size={'small'}
            label='Logged in as'
            disabled
            value={userCredentials.email}
          />
        </Typography>
        <Button onClick={disconnect} variant={'contained'} size={'small'}>
          <code>disconnect</code>
        </Button>
      </Box>
      <Divider sx={{ m: '20px 0' }} />
      <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
        <TextField
          required
          size={'small'}
          label='notification'
          value={message}
          onChange={(event) => setMessage(event.target.value)}
        />
        <TextField
          required
          size={'small'}
          label='to'
          value={to}
          onChange={(event) => setTo(event.target.value)}
        />
        <LoadingButton
          disabled={state.loading}
          onClick={broadcastNewNotification}
          variant={'contained'}
        >
          <code>broadcast</code>
        </LoadingButton>
      </Box>
      <Divider textAlign={'left'} sx={{ m: '40px 0' }}>
        Notifications area
      </Divider>
      {/*TODO: add overflow*/}
      <Box>
        <pre>{JSON.stringify(state.notifications, null, 2)}</pre>
      </Box>
    </StyledUserNotificationBox>
  );
};

const StyledUserNotificationBox = styled(Box)<BoxProps>(({ theme }) => ({
  padding: 10,
}));

export default UserNotifications;
