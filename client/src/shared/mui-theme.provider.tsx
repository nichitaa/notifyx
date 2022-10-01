import {
  alpha,
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
        maxHeight: '100vh',
        // overflow: 'hidden',
      },
      '&::-webkit-scrollbar': {
        width: 7,
        height: 7,
      },
      '&::-webkit-scrollbar-track': {
        background: 'transparent',
        // borderRadius: 2,
      },
      '&::-webkit-scrollbar-thumb': {
        background: `${alpha(theme.palette.primary.main, 0.2)}`,
        // borderRadius: 2,
      },
      '&::-webkit-scrollbar-thumb:hover': {
        background: `${alpha(theme.palette.primary.main, 0.5)}!important`,
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
