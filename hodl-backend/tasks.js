const fetch = require('node-fetch');

module.exports.currencies = (app) => {
  updateCurrencies(app);

};

const updateCurrencies = (app) => {
  console.log("Updating currencies...");
  fetch('https://api.coinmarketcap.com/v1/ticker/?convert=NOK&limit=10000')
      .then(res => res.json())
      .then(json => {
        const currencies = json
            .sort((a, b) => parseInt(a.rank) - parseInt(b.rank));
        app.currency.deleteMany({});
        app.currency.insertMany(currencies);
        console.log("Done updating currencies");
      }).catch(err => console.log(err));
};
