const fetch = require('node-fetch');

class AuthMiddleware {
  BASE_URL = undefined;

  constructor() {
    this.getAuthServiceBaseUrl();
  }

  getAuthServiceBaseUrl = async () => {
    const url = process.env.SERVICE_DISCOVERY_BASE_URL;
    const response = await fetch(`${url}/api/service_address/auth`,
      {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      })
      .then((res) => res.json())
      .catch((err) => {
        console.error('[Error] at retrieving Auth Service address: ', err.message);
        return { success: false };
      });
    if (response.success) {
      console.log('Successfully retrieved Auth Service address: ', response.address);
      this.BASE_URL = response.address;
    } else {
      console.error('[Error] could not receive Auth Service address, will retry: ', response);
      setTimeout(() => {
        this.getAuthServiceBaseUrl();
      }, 2000);
    }
  };

  isValidUser = async (req, res, next) => {
    if (!this.BASE_URL) {
      return res.status(500).send({ success: false, error: 'could not receive auth service base url' });
    }
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
