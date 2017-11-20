const ObjectID = require('mongodb').ObjectID;
const validate = require('../utils.js').validate;


const path = '/portfolio';

module.exports.register =  (router) => {

  router.get(`${path}/:userId`, async (ctx) => {
    ctx.body = await ctx.app.user.findOne({'_id': ObjectID(ctx.params.id)});
  });

  router.post(path, async function (ctx) {
    ctx.body = await ctx.app.user.insert(ctx.request.body);
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