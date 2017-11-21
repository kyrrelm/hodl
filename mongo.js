const MongoClient = require('mongodb').MongoClient;
const MONGO_URL = process.env.MONGODB_URI || "mongodb://localhost:27017/hodl";


module.exports.connect = function (app) {
 return MongoClient.connect(MONGO_URL)
      .then((connection) => {
        app.user = connection.collection("user");
        app.portfolio = connection.collection("portfolio");
        app.currency = connection.collection("currency");
        console.log("Database connection established")
      })
      .catch((err) => console.error(err))

};