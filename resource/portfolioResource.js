const fetch = require('node-fetch');
const validate = require('../utils.js').validate;


const path = '/portfolio';

module.exports.register =  (router) => {

  router.post(path, async function (ctx) {
    ctx.request.body.userId = ctx.state.user._id;
    validate(ctx, {symbol: 'string', amount: 'number'});

    const userId = ctx.request.body.userId;
    const symbol = ctx.request.body.symbol;
    const amount = ctx.request.body.amount;

    const currencyExists = await ctx.app.currency.find({ currencies: { $elemMatch: { symbol }}}).limit(1).hasNext();

    if (!currencyExists) {
      ctx.throw(400, "Unsupported currency");
    }

    const portfolioForSymbol = await ctx.app.portfolio.find({ userId, symbol }).toArray();

    const balance = portfolioForSymbol
        .map(entry => entry.amount)
        .reduce((tot, value) => tot + value, 0);

    if (balance + amount < 0) {
      ctx.throw(400, `This will result in a negative balance of ${symbol}. Current balance: ${balance}, Attempted deposit: ${amount}`);
    }

    await ctx.app.portfolio.insert({userId, symbol, amount});
    

    ctx.body = {
      symbol,
      balance: balance + amount,
    };
  });

  router.get(path, async (ctx) => {
    const portfolio = await ctx.app.portfolio.find().toArray();

    if(portfolio.length === 0) {
      ctx.body = [];
      return;
    }

    const allCurrencies = [...new Set(portfolio.map(entry => entry.symbol))];

    const balanceOverview = {};

    //Add currencies to balanceOverview with balance !== 0
    allCurrencies.forEach(currency => {
      const balance = portfolio
          .filter(entry => entry.symbol === currency)
          .map(entry => entry.amount)
          .reduce((tot, value) => tot + value);
      if (balance !== 0) {
        balanceOverview[currency] = { balance };
      }
    });

    const currenciesString = Object.keys(balanceOverview).reduce((out, symbol) => `${out},${symbol}`);

    const rates = await fetch(`https://min-api.cryptocompare.com/data/pricemulti?fsyms=${currenciesString}&tsyms=BTC,ETH,USD,EUR`)
        .then(res => res.json())
        .catch(err => console.log(err));

    Object.keys(balanceOverview).forEach(symbol => {
      rates[symbol].balance = balanceOverview[symbol].balance;
    });

    ctx.body = rates;
  });

  router.get(`${path}/transactions`, async (ctx) => {
    const symbolsString = ctx.request.query.symbols;
    if (!symbolsString) {
      ctx.body = await ctx.app.portfolio.find().toArray();
      return;
    }
    const symbols = symbolsString.split(',');
    ctx.body = await ctx.app.portfolio.find({ symbol: { $in: symbols}}).toArray();
  });

};