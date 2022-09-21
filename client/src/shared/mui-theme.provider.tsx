import {
  createTheme,
  CssBaseline,
  GlobalStyles,
  ThemeProvider,
} from '@mui/material';
import { FC } from 'react';

const darkTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#7d37e0',
    },
    background: {
      default: '#030913',
    },
  },
  typography: {
    fontFamily: 'Poppins',
  },
});

const globalStyles = (
  <GlobalStyles
    styles={(theme) => ({
      '#root': {
        height: '100vh',
        overflow: 'hidden',
      },
    })}
  />
);

const MuiThemeProvider: FC = ({ children }) => {
  return (
    <ThemeProvider theme={darkTheme}>
      <CssBaseline />
      {globalStyles}
      {children}
    </ThemeProvider>
  );
};

export default MuiThemeProvider;
