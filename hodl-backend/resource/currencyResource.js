const fetch = require('node-fetch');

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

    const response = await fetch(`https://min-api.cryptocompare.com/data/pricemulti?fsyms=${symbols}&tsyms=BTC,ETH,USD,EUR`)
        .then(res => res.json())
        .catch(err => console.log(err));

    const currencyArray = Object
        .values(response)
        .map((currency, index) => {
          return {
            btc: String(currency.BTC),
            eth: String(currency.ETH),
            usd: String(currency.USD),
            eur: String(currency.EUR),
            symbol: Object.keys(response)[index]
          }
    });

    if (currencyArray.length === 1) {
      ctx.body = currencyArray[0];
    } else {
      ctx.body = currencyArray;
    }

  });

};