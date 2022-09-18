import React from 'react';
import { render } from 'react-dom';
import App from './app';
import { RecoilRoot } from 'recoil';
import './index.css';

const root = document.getElementById('root') as HTMLElement;
const app = (
  <RecoilRoot>
    <App />
  </RecoilRoot>
);
render(app, root);
