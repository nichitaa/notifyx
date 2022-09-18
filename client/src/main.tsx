import React from 'react';
import { render } from 'react-dom';
import App from './App';
import './index.css';

const root = document.getElementById('root') as HTMLElement;
const app = <App />;
render(app, root);