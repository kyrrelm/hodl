const path = '/currency';

module.exports.register =  (router) => {

  router.get(path, async (ctx) => {
    const currency = await ctx.app.currency.findOne();
    ctx.body = currency.currencies;
  });

};