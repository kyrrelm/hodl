const secure = require('../middleware/secure.js');

const path = '/auth';

module.exports.register =  (router) => {

  router.post(path, async (ctx) => {

    validateFields(ctx, { email: 'string', password: 'string' });

    ctx.sanitize('email').trim();
    ctx.sanitize('email').escape();
    ctx.sanitize('password').trim();

    ctx.checkBody('email').isEmail();
    let errors = await ctx.validationErrors();

    if (errors) {
      ctx.throw(400, 'Invalid email');
    }

    let email = ctx.request.body.email;
    let password = ctx.request.body.password;

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


const validateFields = (ctx, fields) => {
  for (const key of Object.keys(fields)) {
    console.log(key, fields[key]);
    const value = ctx.request.body[key];
    if(!value) {
      ctx.throw(400, `field ${key} of type ${fields[key]} missing`);
    }

  }

};