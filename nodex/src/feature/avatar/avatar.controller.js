const crypto = require('crypto');
const Avatar = require('avatar-builder').default;

class AvatarController {
  constructor() {}

  generateAvatar = async (req, res) => {
    const params = req.query;
    const size = parseInt(params.size) || 128;
    const type = ['github', 'identicon'].includes(params.type)
      ? params.type
      : 'github';
    const name = params.name || crypto.randomBytes(10).toString('hex');
    console.log(`[PID=${process.pid}] will generate avatar for name: ${name}`);

    let builder;
    switch (type) {
      case 'github': {
        builder = Avatar.githubBuilder(size);
        break;
      }
      case 'identicon': {
        builder = Avatar.identiconBuilder(size);
        break;
      }
      default: {
        throw new Error(`invalid avatar type: ${type}`);
      }
    }

    const buffer = await builder.create(name);
    res.contentType('image/png');
    res.send(buffer);
  };

  hardWorkBlockMainThread = (req, res) => {
    console.log(`[PID=${process.pid}] will do the hard work`);
    for (let i = 0; i < 5000000000; i++) {}
    res.send({ success: true, from: process.pid, count: 0 });
  };
}

module.exports = { AvatarController };
