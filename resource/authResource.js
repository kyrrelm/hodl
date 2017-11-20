const secure = require('../middleware/secure.js');
const bcrypt = require('bcrypt');

const path = '/auth';

module.exports.register =  (router) => {

  router.post(`${path}/register`, async (ctx) => {

    await validateUser(ctx);

    let email = ctx.request.body.email;
    let password = ctx.request.body.password;

    const emailExists = await ctx.app.user.find({ email }).limit(1).hasNext();

    if(emailExists) {
      ctx.throw(409, 'Email already in use');
    }

    await bcrypt.hash(password, 10, function(err, hash) {
      ctx.app.user.insert({email, hash});
    });

    ctx.body = {
      token: secure.issueJwt({
        email,
        role: "user"
      })
    }
  });

  router.post(path, async (ctx) => {

    await validateUser(ctx);

    let email = ctx.request.body.email;
    let password = ctx.request.body.password;

    const user = await ctx.app.user.findOne({ email }, {email: true, hash: true});

    if(!user) {
      ctx.throw(409, 'Incorrect email or password');
    }
    const passwordIsCorrect = bcrypt.compareSync(password, user.hash);

    if(!passwordIsCorrect) {
      return ctx.throw(409, 'Incorrect email or password2');
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