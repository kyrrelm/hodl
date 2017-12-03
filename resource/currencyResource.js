const path = '/currency';
const validate = require('../utils.js').validate;

module.exports.register =  (router) => {

  router.get(path, async (ctx) => {
    const currency = await ctx.app.currency.findOne();
    ctx.body = currency.currencies;
  });

  router.post(`${path}/rates`, async (ctx) => {

    validate(ctx, {symbols: 'array', amount: 'string'});
    const currenciesString = Object.keys(balanceOverview).reduce((out, symbol) => `${out},${symbol}`);

    const rates = await fetch(`https://min-api.cryptocompare.com/data/pricemulti?fsyms=${currenciesString}&tsyms=BTC,ETH,USD,EUR`)
        .then(res => res.json())
        .catch(err => console.log(err));

    const currency = await ctx.app.currency.findOne();
    ctx.body = currency.currencies;
  });

};