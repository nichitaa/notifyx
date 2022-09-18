import { useEffect, useState } from 'react';
import { Socket } from 'phoenix';
import { useRecoilState } from 'recoil';
import { notificationsAtom } from './recoil/atoms';

const socket = new Socket('ws://localhost:5000/socket', {
  params: {
    email: 'email4@gma2il.com',
    password: '122',
  },
});
const allNotificationsChannel = socket.channel('notification:all', {});

const App = () => {
  const [notifications, setNotifications] = useRecoilState(notificationsAtom);

  useEffect(() => {
    socket.connect();

    allNotificationsChannel.on(
      'new_notification',
      ({ body }: { body: string }) => {
        setNotifications((prev) => [...prev, body]);
        console.log('[new_notification] recv: ', body);
      }
    );

    allNotificationsChannel
      .join()
      .receive('ok', (resp) => {
        console.log('Joined successfully', resp);
      })
      .receive('error', (resp) => {
        console.log('Unable to join', resp);
      });

    setTimeout(() => {
      allNotificationsChannel.push('new_notification', {
        body: 'a new push notification',
      });
    }, 1000);
  }, []);

  const sendNotification = () => {
    allNotificationsChannel.push('new_notification', {
      body: 'something dummy',
    });
  };
  return (
    <>
      <pre>{JSON.stringify(notifications, null, 2)}</pre>
      <button onClick={sendNotification}>send</button>
    </>
  );
};

export default App;
