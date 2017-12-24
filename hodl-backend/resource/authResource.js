const bcrypt = require('bcrypt');
const ObjectID = require('mongodb').ObjectID;
const secure = require('../middleware/secure.js');
const validate = require('../utils.js').validate;

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

    const hash = bcrypt.hashSync(password, 10);
    const _id = new ObjectID();
    await ctx.app.user.insert({_id, email, hash});

    ctx.body = {
      token: secure.issueJwt({
        _id: _id.toString(),
        role: "user"
      })
    }
  });

  router.post(path, async (ctx) => {

    await validateUser(ctx);

    let email = ctx.request.body.email;
    let password = ctx.request.body.password;

    const user = await ctx.app.user.findOne({ email }, {_id: true, email: true, hash: true});

    if(!user) {
      ctx.throw(409, 'Incorrect email or password');
    }
    const passwordIsCorrect = bcrypt.compareSync(password, user.hash);

    if(!passwordIsCorrect) {
      return ctx.throw(409, 'Incorrect email or password');
    }

    ctx.body = {
      token: secure.issueJwt({
        _id: user._id.toString(),
        role: "user"
      })
    }
  });

};

const validateUser = async (ctx) => {

  validate(ctx, { email: 'string', password: 'string' });

  ctx.sanitize('email').trim();
  ctx.sanitize('email').escape();
  ctx.sanitize('password').trim();

  ctx.checkBody('email').isEmail();
  let errors = await ctx.validationErrors();

  if (errors) {
    ctx.throw(400, 'Invalid email');
  }
};
