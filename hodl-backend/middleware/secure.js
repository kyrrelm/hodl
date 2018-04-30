const jwt = require('koa-jwt');
const jsonwebtoken = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || '123';
const API_KEY = process.env.API_KEY || '123';
const jwtInstance = jwt({secret: JWT_SECRET});

module.exports.apiKey = () => {
  return async function(ctx, next) {
    const apiKey = ctx.header['api-key'];
    if (!apiKey) {
      ctx.throw(401, 'Missing api key');
    } else if (apiKey !== API_KEY) {
      ctx.throw(401, 'Wrong api key');
    } {
      return next();
    }
  }
};

module.exports.issueJwt =  (payload) => {
  return jsonwebtoken.sign(payload, JWT_SECRET, {});
};

module.exports.jwt = () => jwtInstance;
