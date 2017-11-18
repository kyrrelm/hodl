
module.exports.errorHandler = () => (ctx, next) => {
  return next().catch((err) => {
    console.log(`Error: ${err.status} Message: ${err.message}`);
    if (401 === err.status) {
      ctx.status = 401;
      ctx.body = {
        error: err.message || 'Not authorized'
      };
    } else {
      console.log(err);
      ctx.status = 500;
      ctx.body = {
        error: 'Internal Server Error'
      };
    }
  });
};