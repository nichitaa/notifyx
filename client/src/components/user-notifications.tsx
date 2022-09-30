import {Box, BoxProps, Button, Divider, styled, TextField, Typography,} from '@mui/material';
import {usePhxSocket} from '../hooks/use-phx-socket';
import {useRecoilValue} from 'recoil';
import {userCredentialsAtom} from '../recoil/atoms';
import JoinTopic from './join-topic';
import {useState} from "react";

const UserNotifications = () => {
  const {disconnect} = usePhxSocket();
  const [topicsNo, setTopicsNo] = useState(1);
  const userCredentials = useRecoilValue(userCredentialsAtom);

  return (
    <StyledUserNotificationBox>
      <Box sx={{display: 'flex', justifyContent: 'space-between'}}>
        <Typography component={'div'}>
          <TextField
            required
            size={'small'}
            label='Logged in as'
            disabled
            value={userCredentials.email}
          />
        </Typography>
        <Button onClick={() => setTopicsNo(prev => prev + 1)} variant={'text'} size={'small'}>
          <code>new topic</code>
        </Button>
        <Button onClick={disconnect} variant={'contained'} size={'small'}>
          <code>disconnect</code>
        </Button>
      </Box>
      <Divider textAlign={'left'} sx={{m: '10px 0'}}>
        Topics
      </Divider>
      {Array.from({length: topicsNo}).map((_, i) => <JoinTopic key={`topic_${i}`} defaultTopicName={`topic_${i}`}/>)}
    </StyledUserNotificationBox>
  );
};

const StyledUserNotificationBox = styled(Box)<BoxProps>(({theme}) => ({
  padding: 10,
}));

export default UserNotifications;
