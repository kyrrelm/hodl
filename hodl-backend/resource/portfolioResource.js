const fetch = require('node-fetch');
const Big = require('big.js');
const validate = require('../utils.js').validate;
const isNumber = require('../utils.js').isNumber;


const path = '/portfolio';

module.exports.register =  (router) => {

  router.post(path, async function (ctx) {
    validate(ctx, {symbol: 'string', amount: 'stringNum', price_btc: 'string'});

    const userId = ctx.state.user._id;
    const symbol = ctx.request.body.symbol.toUpperCase();
    const amount = Big(ctx.request.body.amount);
    const price_btc = ctx.request.body.price_btc;

    if(price_btc !== '' && !isNumber(price_btc)){
      ctx.throw(400, `field priceBtc must be of type string and contain a number or be an empty string`);
    }
    else if (Number(price_btc) < 0) {
      ctx.throw(400, `field priceBtc must be of type string and represent a number > 0 or an empty string`);
    }

    const currencyExists = await ctx.app.currency.find({symbol}).limit(1).hasNext();

    if (!currencyExists) {
      ctx.throw(400, "Unsupported currency");
    }

    const portfolioForSymbol = await ctx.app.portfolio.find({ userId, symbol }).toArray();

    const balance = portfolioForSymbol
        .map(entry => entry.amount)
        .reduce((tot, value) => Big(tot).plus(Big(value)), Big(0));

    if (balance.plus(amount).cmp(0) < 0) {
      ctx.throw(400, `This will result in a negative balance of ${symbol}. Current balance: ${balance}, Attempted deposit: ${amount}`);
    }

    await ctx.app.portfolio.insert({userId, symbol, amount: amount.toString(), priceBtc: price_btc});
    

    ctx.body = {
      symbol,
      balance: balance.plus(amount),
    };
  });

  router.get(path, async (ctx) => {

    const userId = ctx.state.user._id;

    const portfolio = await ctx.app.portfolio.find({ userId }).toArray();

    if(portfolio.length === 0) {
      ctx.body = {
        usdBalance: "0",
        btcBalance: "0",
        currencies: []
      };
      return;
    }

    const allSymbols = [...new Set(portfolio.map(entry => entry.symbol))];

    const balanceOverview = {};

    //Add currencies to balanceOverview if currency balance !== 0
    allSymbols.forEach(currency => {
      const balance = Big(portfolio
          .filter(entry => entry.symbol === currency)
          .map(entry => entry.amount)
          .reduce((tot, value) => Big(tot).plus(Big(value))));
      if (!balance.eq(0)) {
        balanceOverview[currency] = { balance };
      }
    });


    const currencies = await ctx.app.currency.find({symbol: {$in: allSymbols}}).toArray();

    const overview = {
      usdBalance: 0,
      btcBalance: 0,
    };

    Object.keys(balanceOverview).forEach(symbol => {
      const currency = currencies.find(currency => currency.symbol === symbol);
      currency.balance = balanceOverview[symbol].balance;

      const usdBalance = Big(currency.balance).times(Big(currency.price_usd));
      const btcBalance = Big(currency.balance).times(Big(currency.price_btc));

      overview.usdBalance = Big(overview.usdBalance).add(Big(usdBalance)).toFixed(2);
      overview.btcBalance = Big(overview.btcBalance).add(Big(btcBalance)).toFixed(2);

      currency.usdBalance = usdBalance.toFixed(2);
      currency.btcBalance = btcBalance.toFixed(2);

    });

    overview.currencies = currencies.sort((a, b) => b.usdBalance - a.usdBalance);

    ctx.body = overview;

  });

  router.get(`${path}/transactions`, async (ctx) => {

    const userId = ctx.state.user._id;
    const symbolsString = ctx.request.query.symbols;

    if (!symbolsString) {
      ctx.body = await ctx.app.portfolio.find({ userId }).toArray();
      return;
    }

    const symbols = symbolsString.split(',');
    ctx.body = await ctx.app.portfolio.find({ userId, symbol: { $in: symbols}}).toArray();
  });

};