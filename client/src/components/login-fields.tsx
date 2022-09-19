import { useRecoilState } from 'recoil';
import { userCredentialsAtom } from '../recoil/atoms';
import { PhxSocketStates, usePhxSocket } from '../hooks/use-phx-socket';
import {
  alpha,
  Box,
  BoxProps,
  styled,
  TextField,
  Typography,
} from '@mui/material';
import { LoadingButton } from '@mui/lab';
import { FC } from 'react';

const LoginFields = () => {
  const [credentials, setCredentials] = useRecoilState(userCredentialsAtom);

  const { connect, status } = usePhxSocket();

  return (
    <StyledLoginBox>
      <StyledCodeTypography>join `notification:*`</StyledCodeTypography>
      <TextField
        required
        size={'small'}
        label='email'
        value={credentials.email}
        onChange={(event) =>
          setCredentials((prev) => ({
            ...prev,
            email: event.target.value,
          }))
        }
      />
      <TextField
        required
        size={'small'}
        label='password'
        value={credentials.password}
        onChange={(event) =>
          setCredentials((prev) => ({
            ...prev,
            password: event.target.value,
          }))
        }
      />
      <LoadingButton
        variant={'contained'}
        loading={status === PhxSocketStates.CONNECTING}
        onClick={() => connect(credentials)}
      >
        <code>connect</code>
      </LoadingButton>
    </StyledLoginBox>
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
