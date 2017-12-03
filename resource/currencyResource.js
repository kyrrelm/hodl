const fetch = require('node-fetch');
const validate = require('../utils.js').validate;

const path = '/currency';

module.exports.register =  (router) => {

  router.get(path, async (ctx) => {
    const currency = await ctx.app.currency.findOne();
    ctx.body = currency.currencies;
  });

  router.get(`${path}/rates`, async (ctx) => {

    const symbols = ctx.request.query.symbols;

    if (!symbols) {
      ctx.throw(400, `Query string symbols is missing. Example: symbols=ETH,BTC`);
    }

    ctx.body = await fetch(`https://min-api.cryptocompare.com/data/pricemulti?fsyms=${symbols}&tsyms=BTC,ETH,USD,EUR`)
        .then(res => res.json())
        .catch(err => console.log(err));
  });

};