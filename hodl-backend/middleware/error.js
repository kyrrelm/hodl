
module.exports.errorHandler = () => (ctx, next) => {
  return next().catch((err) => {
    console.log(`Error: ${err.status} Message: ${err.message}`);
    if (err.status === 401) {
      ctx.status = 401;
      ctx.body = {
        error: err.message || 'Unauthorized'
      };
    } else if (err.status === 403) {
      ctx.status = 403;
      ctx.body = {
        error: err.message || 'Forbidden'
      };
    } else if (err.status === 409) {
      ctx.status = 409;
      ctx.body = {
        error: err.message || 'Conflict'
      };
    } else if (err.status === 400) {
      ctx.status = 400;
      ctx.body = {
        error: err.message || 'Bad Request'
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