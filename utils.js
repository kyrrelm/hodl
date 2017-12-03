
module.exports.validate = (ctx, fields, userId) => {
  if (userId) {
    if (!ctx.state.user._id || ctx.state.user._id !== userId) {
      ctx.throw(403, `Illegal action, user with _id ${ctx.state.user._id} must match userId ${userId}`);
    }
  }
  if (fields) {
    for (const key of Object.keys(fields)) {
      console.log(key, fields[key]);
      const value = ctx.request.body[key];
      if (!value) {
        ctx.throw(400, `field ${key} of type ${fields[key]} missing`);
      }
      if (fields[key] === 'array') {
        if (!Array.isArray(ctx.request.body[key])) {
          ctx.throw(400, `field ${key} must be of type ${fields[key]}`);
        }
      } else if (typeof ctx.request.body[key] !== fields[key]) {
        ctx.throw(400, `field ${key} must be of type ${fields[key]}`);
      }

    }
  }
};