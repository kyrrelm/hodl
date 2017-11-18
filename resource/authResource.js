const jwt = require("../jwt");

const path = '/auth';

module.exports.register =  (router) => {

  router.post(path, async (ctx) => {
    let username = ctx.request.body.username;
    let password = ctx.request.body.password;

    if (username === "user" && password === "pwd") {
      ctx.body = {
        token: jwt.issue({
          user: "user",
          role: "admin"
        })
      }
    } else {
      ctx.status = 401;
      ctx.body = {error: "Invalid login"}
    }
  });

};