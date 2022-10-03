const express = require('express');
const { AvatarRouter } = require('./feature/avatar/avatar.router');
const { AvatarController } = require('./feature/avatar/avatar.controller');
const { AuthMiddleware } = require('./middleware/auth.middleware');
const fetch = require('node-fetch');
require('express-async-errors');

class App {
  PORT = parseInt(process.env.PORT || '9000');
  SERVICE_DISCOVERY_BASE_URL =
    process.env.SERVICE_DISCOVERY_BASE_URL || 'http://localhost:8000';

  constructor() {
    this.app = express();
    this.bootstrap();
  }

  bootstrap = () => {
    this.initMiddlewares();
    this.initRoutes();
  };

  initMiddlewares = () => {
    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: true }));

    // all routes will require auth token `durian-token` header
    const authMiddleware = new AuthMiddleware();
    this.app.use(authMiddleware.isValidUser);
  };

  initRoutes = () => {
    const routes = [new AvatarRouter(new AvatarController())];
    this.app.get('/api/health_check', (req, res) => {
      res.send({ success: true, port: this.PORT });
    });
    routes.forEach((route) => this.app.use(route.router));
    // error handler
    this.app.use((err, req, res, next) => {
      res.status(500).json({ success: false, error: err.message });
    });
  };

  /** Register in Service Discovery */
  register = async (listener) => {
    const response = await fetch(
      `${this.SERVICE_DISCOVERY_BASE_URL}/api/register`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          service: 'generator',
          address: `http://localhost:${listener.address().port}`,
        }),
      }
    )
      .then((res) => res.json())
      .catch((err) => {
        console.log('[Error] at registering Generator Service: ', err.message);
        return { success: false };
      });
    if (response.success) {
      console.log('Successfully registered Generator Service');
    } else {
      console.log('Retrying to register after 1 sec!');
      setTimeout(() => {
        this.register(listener);
      }, 1000);
    }
  };

  start = () => {
    const listener = this.app.listen(this.PORT, () => {
      console.log(`App listening on port ${this.PORT}`);
      this.register(listener);
    });
  };
}

module.exports = { App };
