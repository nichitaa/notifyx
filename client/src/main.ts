import './style.css';

import { Socket } from 'phoenix';

let socket = new Socket('ws://localhost:5000/socket', { params: { token: 'some_token' } });

socket.connect();

let channel = socket.channel('room:lobby', {});

channel.on('new_msg', payload => {
  console.log('received new_msg: ', payload);
});

channel.join()
  .receive('ok', resp => {
    console.log('Joined successfully', resp);
  })
  .receive('error', resp => {
    console.log('Unable to join', resp);
  });

setTimeout(() => {
  channel.push('new_msg', { body: 'hello' });
}, 1000);