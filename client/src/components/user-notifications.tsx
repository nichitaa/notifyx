import {
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
import { userCredentialsAtom } from '../recoil/atoms';
import JoinTopic from './join-topic';
import { useState } from 'react';
import AddIcon from '@mui/icons-material/Add';

const UserNotifications = () => {
  const { disconnect } = usePhxSocket();
  const [topicsNo, setTopicsNo] = useState(1);
  const userCredentials = useRecoilValue(userCredentialsAtom);

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
      <Divider textAlign={'left'} sx={{ m: '10px 0' }}>
        Topics
      </Divider>
      {Array.from({ length: topicsNo }).map((_, i) => (
        <JoinTopic key={`topic_${i}`} defaultTopicName={`topic_${i}`} />
      ))}
    </StyledUserNotificationBox>
  );
};

const StyledUserNotificationBox = styled(Box)<BoxProps>(({ theme }) => ({
  padding: 10,
}));

export default UserNotifications;
