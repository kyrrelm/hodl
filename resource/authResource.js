const secure = require('../middleware/secure.js');

const path = '/auth';

module.exports.register =  (router) => {

  router.post(`${path}/register`, async (ctx) => {

    validateUser(ctx);

    let email = ctx.request.body.email;
    let password = ctx.request.body.password;

    const emailExists = await ctx.app.user.find({ email }).limit(1).hasNext();

    if(emailExists) {
      ctx.throw(409, 'Email already in use');
    }

    await ctx.app.user.insert({email, password});

    ctx.body = {
      token: secure.issueJwt({
        email,
        role: "user"
      })
    }
  });

  router.post(path, async (ctx) => {

    validateUser(ctx);

    let email = ctx.request.body.email;
    let password = ctx.request.body.password;

    const user = await ctx.app.user.findOne({ email, password }, {email});

    if(!user) {
      ctx.throw(409, 'Incorrect email or password');
    }

    ctx.body = {
      token: secure.issueJwt({
        email: user.email,
        role: "user"
      })
    }
  });

};

const validateUser = async (ctx) => {

  validateFields(ctx, { email: 'string', password: 'string' });

  ctx.sanitize('email').trim();
  ctx.sanitize('email').escape();
  ctx.sanitize('password').trim();

  ctx.checkBody('email').isEmail();
  let errors = await ctx.validationErrors();

  if (errors) {
    ctx.throw(400, 'Invalid email');
  }
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