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
        SERVICE_DISCOVERY_BASE_URL: 'http://localhost:8000',
        SERVICE_NETWORK: 'localhost', // for Service Discovery registration
      },
      env_production: {
        PORT: 9000,
        NODE_ENV: 'production',
        SERVICE_DISCOVERY_BASE_URL: 'http://julik:8000',
        SERVICE_NETWORK: 'nodex' // docker container name
      }
    },
  ],
};
