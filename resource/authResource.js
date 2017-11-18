const secure = require('../middleware/secure.js');

const path = '/auth';

module.exports.register =  (router) => {

  router.post(path, async (ctx) => {
    let email = ctx.request.body.email;
    let password = ctx.request.body.password;
    if(!email || !password) {
      ctx.throw(400, 'Username or password missing');
    }
    const emailExists = await ctx.app.user.find({email: email}).limit(1).hasNext();
    if(emailExists) {
      ctx.throw(409, 'Email already in use');
    }
    await ctx.app.user.insert({email, password});
    ctx.body = {
      token: secure.issueJwt({
        email,
        role: "admin"
      })
    }
  });

};