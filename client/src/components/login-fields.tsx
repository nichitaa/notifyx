import { useRecoilState } from 'recoil';
import { userCredentialsAtom } from '../recoil/atoms';
import { PhxSocketStates, usePhxSocket } from '../hooks/use-phx-socket';
import {
  Alert,
  alpha,
  Box,
  BoxProps,
  Grid,
  Snackbar,
  styled,
  TextField,
  Typography,
} from '@mui/material';
import { LoadingButton } from '@mui/lab';
import { FC, useState } from 'react';
import { Socket } from 'phoenix';
import { config } from '../config/config';

const LoginFields = () => {
  const [credentials, setCredentials] = useRecoilState(userCredentialsAtom);
  const { status, connect } = usePhxSocket();
  const [registerStatus, setRegisterStatus] = useState<
    'idle' | 'loading' | 'error' | 'success'
  >('idle');

  const handleConnect = () => {
    const socket = new Socket(config.WSGatewayBaseUrl, {
      params: credentials,
    });
    connect(socket);
  };

  const handleChange = (field: 'password' | 'email', value: string) => {
    setCredentials((prev) => ({
      ...prev,
      [field]: value,
    }));
  };

  const handleRegister = async () => {
    if (credentials.email.trim() !== '' && credentials.password.trim() !== '') {
      setRegisterStatus('loading');
      const response = await fetch(
        `${config.APIGatewayBaseUrl}/api/register_user`,
        {
          method: 'POST',
          headers: {
            Accept: 'application/json',
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ ...credentials }),
        }
      ).then((res) => res.json());
      if (!response.success) {
        setRegisterStatus('error');
      } else {
        setRegisterStatus('success');
      }
    }
  };

  return (
    <>
      <StyledLoginBox>
        <StyledCodeTypography>join `notification:*`</StyledCodeTypography>
        <TextField
          required
          size={'small'}
          label='email'
          autoComplete={'off'}
          value={credentials.email}
          onChange={(event) => handleChange('email', event.target.value)}
        />
        <TextField
          required
          size={'small'}
          autoComplete={'off'}
          label='password'
          value={credentials.password}
          onChange={(event) => handleChange('password', event.target.value)}
        />
        <Grid container columnSpacing={1}>
          <Grid item xs={6}>
            <LoadingButton
              fullWidth
              variant={'outlined'}
              color={'secondary'}
              loading={registerStatus === 'loading'}
              onClick={handleRegister}
            >
              <code>register</code>
            </LoadingButton>
          </Grid>
          <Grid item xs={6}>
            <LoadingButton
              fullWidth
              variant={'outlined'}
              color={'success'}
              loading={status === PhxSocketStates.CONNECTING}
              onClick={handleConnect}
            >
              <code>connect</code>
            </LoadingButton>
          </Grid>
        </Grid>
      </StyledLoginBox>
      <Snackbar
        open={registerStatus === 'error'}
        autoHideDuration={3000}
        onClose={() => setRegisterStatus('idle')}
      >
        <Alert elevation={6} variant='filled' severity={'error'}>
          Could not register a new user
        </Alert>
      </Snackbar>
      <Snackbar
        open={registerStatus === 'success'}
        autoHideDuration={3000}
        onClose={() => setRegisterStatus('idle')}
      >
        <Alert elevation={6} variant='filled' severity={'success'}>
          Successfully register a new user
        </Alert>
      </Snackbar>
    </>
  );
};

// ################## Styled #####################

export const StyledCodeTypography: FC = ({ children }) => (
  <Typography
    component={'div'}
    sx={{
      background: alpha('#fff', 0.1),
      padding: 0.1,
      textAlign: 'center',
      borderRadius: 1,
    }}
  >
    <code>{children}</code>
  </Typography>
);

const StyledLoginBox = styled(Box)<BoxProps>(({ theme }) => ({
  maxWidth: 250,
  margin: 'auto',
  marginTop: 100,
  padding: 20,
  borderRadius: 5,
  border: `2px solid ${alpha('#fff', 0.1)}`,
  flexDirection: 'column',
  gap: 20,
  display: 'flex',
}));

export default LoginFields;
