const path = '/health';

module.exports.register =  (router) => {

  router.get(path, async (ctx) => {

    ctx.body = "all good"
  });

};