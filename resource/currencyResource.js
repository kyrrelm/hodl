const path = '/currency';

module.exports.register =  (router) => {

  router.get(path, async (ctx) => {
    ctx.body = await ctx.app.currency.find().toArray();
  });

};