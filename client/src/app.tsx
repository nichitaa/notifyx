import { PhxSocketStates, usePhxSocket } from './hooks/use-phx-socket';
import LoginFields from './components/login-fields';
import UserNotifications from './components/user-notifications';

const App = () => {
  const { status } = usePhxSocket();

  if (status === PhxSocketStates.OPEN) return <UserNotifications />;

  return <LoginFields />;
};

export default App;
