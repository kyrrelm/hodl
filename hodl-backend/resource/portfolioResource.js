const fetch = require('node-fetch');
const Big = require('big.js');
const validate = require('../utils.js').validate;


const path = '/portfolio';

module.exports.register =  (router) => {

  router.post(path, async function (ctx) {
    validate(ctx, {symbol: 'string', amount: 'string'});

    const userId = ctx.state.user._id;
    const symbol = ctx.request.body.symbol;
    const amount = Big(ctx.request.body.amount);

    const currencyExists = await ctx.app.currency.find({ currencies: { $elemMatch: { symbol }}}).limit(1).hasNext();

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

    await ctx.app.portfolio.insert({userId, symbol, amount: amount.toString()});
    

    ctx.body = {
      symbol,
      balance: balance.plus(amount),
    };
  });

  router.get(path, async (ctx) => {

    const userId = ctx.state.user._id;

    const portfolio = await ctx.app.portfolio.find({ userId }).toArray();

    if(portfolio.length === 0) {
      ctx.body = [];
      return;
    }

    const allCurrencies = [...new Set(portfolio.map(entry => entry.symbol))];

    const balanceOverview = {};

    //Add currencies to balanceOverview if currency balance !== 0
    allCurrencies.forEach(currency => {
      const balance = Big(portfolio
          .filter(entry => entry.symbol === currency)
          .map(entry => entry.amount)
          .reduce((tot, value) => Big(tot).plus(Big(value))));
      if (!balance.eq(0)) {
        balanceOverview[currency] = { balance };
      }
    });

    const currenciesString = Object.keys(balanceOverview).reduce((out, symbol) => `${out},${symbol}`);

    const rates = await fetch(`https://min-api.cryptocompare.com/data/pricemulti?fsyms=${currenciesString}&tsyms=BTC,ETH,USD,EUR`)
        .then(res => res.json())
        .catch(err => console.log(err));

    Object.keys(balanceOverview).forEach(symbol => {
      const rate = rates[symbol];
      rate.balance = balanceOverview[symbol].balance;
      rate.symbol = symbol;
      rate.USD = rate.USD.toString();
      rate.EUR = rate.EUR.toString();
      rate.BTC = rate.BTC.toString();
      rate.ETH = rate.ETH.toString();
      rate.usdBalance = Big(rate.balance).times(Big(rate.USD));
      rate.eurBalance = Big(rate.balance).times(Big(rate.EUR));
    });


    ctx.body = Object.values(rates).sort((a, b) => b.usdBalance - a.usdBalance);
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