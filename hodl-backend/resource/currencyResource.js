const fetch = require('node-fetch');

const path = '/currency';

module.exports.register =  (router) => {

  router.get(path, async (ctx) => {

    const currencies = await ctx.app.currency.find({}).toArray();

    ctx.body = currencies.map(currency => {return {
      name: currency.name,
      symbol: currency.symbol,
    }});
  });

  router.get(`${path}/rates`, async (ctx) => {

    const symbols = ctx.request.query.symbols;

    if (!symbols) {
      ctx.throw(400, `Query string symbols is missing. Example: symbols=ETH,BTC`);
    }

    const symbolsArray = symbols.split(',');

    const currencies = await ctx.app.currency.find({symbol: {$in: symbolsArray}}).toArray();

    if (currencies.length === 1) {
      ctx.body = currencies[0];
    } else {
      ctx.body = currencies;
    }

  });

};