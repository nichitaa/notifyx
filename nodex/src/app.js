const express = require('express');
const { AvatarRouter } = require('./feature/avatar/avatar.router');
const { AvatarController } = require('./feature/avatar/avatar.controller');
const { AuthMiddleware } = require('./middleware/auth.middleware');
require('express-async-errors');

class App {
  PORT = parseInt(process.env.PORT || '9000');

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

  start = () => {
    this.app.listen(this.PORT, () =>
      console.log(`App listening on port ${this.PORT}`)
    );
  };
}

module.exports = { App };
