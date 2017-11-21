const fetch = require('node-fetch');

module.exports.currencies = () => {
  updateCurrencies();

};

const updateCurrencies = () => {
  console.log("Updating currencies");
  fetch('https://api.github.com/users/github')
      .then(function(res) {
        return res.json();
      }).then(function(json) {
    console.log(json);
  });
};
