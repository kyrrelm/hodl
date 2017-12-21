const fetch = require('node-fetch');
const Big = require('big.js');
const validate = require('../utils.js').validate;
const isNumber = require('../utils.js').isNumber;


const path = '/portfolio';

module.exports.register =  (router) => {

  router.post(path, async function (ctx) {
    validate(ctx, {symbol: 'string', amount: 'stringNum', priceBtc: 'string'});

    const userId = ctx.state.user._id;
    const symbol = ctx.request.body.symbol;
    const amount = Big(ctx.request.body.amount);
    const priceBtc = ctx.request.body.priceBtc;

    if(priceBtc !== '' && !isNumber(priceBtc)){
      ctx.throw(400, `field priceBtc must be of type string and contain a number or be an empty string`);
    }
    else if (Number(priceBtc) < 0) {
      ctx.throw(400, `field priceBtc must be of type string and represent a number > 0 or an empty string`);
    }

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

    await ctx.app.portfolio.insert({userId, symbol, amount: amount.toString(), priceBtc});
    

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
        eurBalance: "0",
        currencies: []
      };
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

    const overview = {
      usdBalance: 0,
      eurBalance: 0,
    };

    Object.keys(balanceOverview).forEach(symbol => {
      const rate = rates[symbol];
      rate.balance = balanceOverview[symbol].balance;
      rate.symbol = symbol;
      rate.USD = rate.USD.toString();
      rate.EUR = rate.EUR.toString();
      rate.BTC = rate.BTC.toString();
      rate.ETH = rate.ETH.toString();

      const usdBalance = Big(rate.balance).times(Big(rate.USD));
      const eurBalance = Big(rate.balance).times(Big(rate.EUR));

      overview.usdBalance = Big(overview.usdBalance).add(Big(usdBalance)).toFixed(2);
      overview.eurBalance = Big(overview.eurBalance).add(Big(eurBalance)).toFixed(2);

      rate.usdBalance = usdBalance.toFixed(2);
      rate.eurBalance = eurBalance.toFixed(2);


    });

    overview.currencies = Object.values(rates).sort((a, b) => b.usdBalance - a.usdBalance);

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