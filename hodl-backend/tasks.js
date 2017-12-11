const fetch = require('node-fetch');

module.exports.currencies = (app) => {
  updateCurrencies(app);

};

const updateCurrencies = (app) => {
  console.log("Updating currencies...");
  fetch('https://www.cryptocompare.com/api/data/coinlist/')
      .then(res => res.json())
      .then(json => {
        const currencies = Object
            .values(json.Data)
            .sort((a, b) => parseInt(a.SortOrder) - parseInt(b.SortOrder))
            .map(currency =>
            {
              return {
                symbol: currency.Symbol,
                name: currency.CoinName,
                sortOrder: currency.SortOrder,
              }
            });
        app.currency.update({}, {$addToSet: {currencies: {$each: currencies}}}, {upsert: true});
        console.log("Done updating currencies");
      }).catch(err => console.log(err));
};
