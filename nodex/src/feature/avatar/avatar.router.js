const { Router } = require('express');

class AvatarRouter {
  constructor(controller) {
    this.router = Router();
    this.controller = controller;
    this.initRoutes();
  }

  initRoutes = () => {
    this.router.route('/api/avatar').get(this.controller.generateAvatar);
    this.router.route('/api/work').get(this.controller.hardWorkBlockMainThread);
  };
}

module.exports = { AvatarRouter };
