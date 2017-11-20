const ObjectID = require('mongodb').ObjectID;
const validate = require('../utils.js').validate;


const path = '/portfolio';

module.exports.register =  (router) => {

  router.get(path, async (ctx) => {
    ctx.body = await ctx.app.portfolio.find({ 'userId': ctx.state.user._id }).toArray();
  });

  router.post(path, async function (ctx) {
    //validate(ctx, ctx.request.body.userId);
    const result = await ctx.app.portfolio.insert(ctx.request.body);
    ctx.body = result.ops;
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