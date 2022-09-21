import React from 'react';
import { render } from 'react-dom';
import App from './app';
import { RecoilRoot } from 'recoil';
import MuiThemeProvider from './shared/mui-theme.provider';

const root = document.getElementById('root') as HTMLElement;
const app = (
  <MuiThemeProvider>
    <RecoilRoot>
      <App />
    </RecoilRoot>
  </MuiThemeProvider>
);
render(app, root);
