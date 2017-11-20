const ObjectID = require('mongodb').ObjectID;
const validate = require('../utils.js').validate;


const path = '/portfolio';

module.exports.register =  (router) => {

  router.get(path, async (ctx) => {
    const allEntries = await ctx.app.portfolio.find().toArray();
  });

  router.post(path, async function (ctx) {
    ctx.request.body.userId = ctx.state.user._id;
    validate(ctx, {code: 'string', amount: 'string'});

    const userId = ctx.request.body.userId;
    const code = ctx.request.body.code;
    const amount = ctx.request.body.amount;

    await ctx.app.portfolio.insert({userId, code, amount});

    ctx.body = true;
  });                                           

  // router.put(`${path}/:id`, async (ctx) => {
  //   let documentQuery = {'_id': ObjectID(ctx.params.id)}; // Used to find the document
  //   let valuesToUpdate = ctx.request.body;
  //   ctx.body = await ctx.app.user.updateOne(documentQuery, valuesToUpdate);
  // });

  // router.delete(`${path}/:id`, async (ctx) => {
  //   let documentQuery = {'_id': ObjectID(ctx.params.id)}; // Used to find the document
  //   ctx.body = await ctx.app.user.deleteOne(documentQuery);
  // });

};