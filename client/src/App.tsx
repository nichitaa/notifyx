import { useEffect } from 'react';
import { Socket } from 'phoenix';

const socket = new Socket('ws://localhost:5000/socket', { params: { token: 'some_token' } });

const App = () => {
  useEffect(() => {
    socket.connect();

    const channel = socket.channel('notification:all', {});

    channel.on('new_notification', payload => {
      console.log('[new_notification] recv: ', payload);
    });

    channel.join()
      .receive('ok', resp => {
        console.log('Joined successfully', resp);
      })
      .receive('error', resp => {
        console.log('Unable to join', resp);
      });

    setTimeout(() => {
      channel.push('new_notification', { body: 'a new push notification' });
    }, 1000);
  }, []);
  return <>app</>;
};

export default App;