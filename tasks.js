const fetch = require('node-fetch');

module.exports.currencies = (app) => {
  updateCurrencies(app);

};

const updateCurrencies = (app) => {
  console.log("Updating currencies");
  fetch('https://www.cryptocompare.com/api/data/coinlist/')
      .then(res => res.json())
      .then(json => {
        const currencies = Object
            .values(json.Data)
            .filter(currency => parseInt(currency.SortOrder) <= 100)
            .map(currency =>
            {
              return {
                symbol: currency.Symbol,
                name: currency.CoinName,
              }
            });
        app.currency.update({}, {$addToSet: {currencies: {$each: currencies}}}, {upsert: true});
      }).catch(err => console.log(err));
};
