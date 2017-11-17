const MongoClient = require('mongodb').MongoClient;
const MONGO_URL = process.env.MONGODB_URI || "mongodb://localhost:27017/hodl";


module.exports = function (app) {
  MongoClient.connect(MONGO_URL)
      .then((connection) => {
        app.user = connection.collection("user");
        console.log("Database connection established")
      })
      .catch((err) => console.error(err))

};