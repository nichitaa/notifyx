import {
  Avatar,
  Box,
  BoxProps,
  Button,
  ButtonGroup,
  Divider,
  styled,
  TextField,
} from '@mui/material';
import { usePhxSocket } from '../hooks/use-phx-socket';
import { useRecoilValue } from 'recoil';
import { avatarSrcAtom, userCredentialsAtom } from '../recoil/atoms';
import JoinedChannelView from './joined-channel-view';
import { useState } from 'react';
import AddIcon from '@mui/icons-material/Add';

const UserNotifications = () => {
  const { disconnect } = usePhxSocket();
  const [topicsNo, setTopicsNo] = useState(1);
  const userCredentials = useRecoilValue(userCredentialsAtom);
  const avatarSrc = useRecoilValue(avatarSrcAtom);

  return (
    <StyledUserNotificationBox>
      <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
        <TextField
          required
          size={'small'}
          label='Logged in as'
          disabled
          value={userCredentials.email}
        />
        <Avatar alt='Avatar' src={avatarSrc} />
        <ButtonGroup>
          <Button
            onClick={() => setTopicsNo((prev) => prev + 1)}
            size={'medium'}
            endIcon={<AddIcon />}
            color={'info'}
          >
            <code>new topic</code>
          </Button>
          <Button onClick={disconnect} size={'medium'} color={'error'}>
            <code>disconnect</code>
          </Button>
        </ButtonGroup>
      </Box>
      <br/>
      {Array.from({ length: topicsNo }).map((_, i) => (
        <JoinedChannelView key={`topic_${i}`} defaultTopicName={`topic_${i}`} />
      ))}
    </StyledUserNotificationBox>
  );
};

const StyledUserNotificationBox = styled(Box)<BoxProps>(({ theme }) => ({
  padding: 10,
}));

export default UserNotifications;
