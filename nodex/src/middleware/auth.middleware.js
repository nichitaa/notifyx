const fetch = require('node-fetch');

class AuthMiddleware {
  BASE_URL = process.env.AUTH_SERVICE_BASE_URL || 'http://localhost:5000';

  constructor() {}

  isValidUser = async (req, res, next) => {
    const token = req.headers['durian-token'];
    const response = await fetch(`${this.BASE_URL}/api/users/self`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'durian-token': token,
      },
    }).then((res) => res.json());
    if (!response.success) {
      return res.status(401).send({ success: false, error: 'unauthorized' });
    }
    next();
  };
}

module.exports = { AuthMiddleware };
