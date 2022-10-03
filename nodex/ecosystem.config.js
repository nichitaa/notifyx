module.exports = {
  apps: [
    {
      name: 'nodex-api',
      script: './src/main.js',
      instances: 'max',
      exec_mode: 'cluster',
      env: {
        PORT: 9000,
        NODE_ENV: 'development',
        AUTH_SERVICE_BASE_URL: 'http://localhost:5000',
      },
    },
  ],
};
