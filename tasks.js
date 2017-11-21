const fetch = require('node-fetch');

module.exports.currencies = () => {
  updateCurrencies();
  setInterval(function(){
    console.log("HERE HERE");
    //app.portfolio.insert({userId:"34", code:"TEST", amount:"123"});
  }, 3000);

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
