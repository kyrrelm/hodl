
module.exports.validate = (ctx, fields, userId) => {
  if (userId) {
    if (!ctx.state.user._id || ctx.state.user._id !== userId) {
      ctx.throw(403, `Illegal action, user with _id ${ctx.state.user._id} must match userId ${userId}`);
    }
  }
  if (fields) {
    for (const key of Object.keys(fields)) {
      const value = ctx.request.body[key];
      if (!value && value !== "") {
        ctx.throw(400, `field ${key} of type ${fields[key]} missing`);
      }
      if (fields[key] === 'array') {
        if (!Array.isArray(ctx.request.body[key])) {
          ctx.throw(400, `field ${key} must be of type ${fields[key]}`);
        }
      }
      else if (fields[key] === 'stringNum') {
        if(typeof ctx.request.body[key] !== 'string' || !isNumber(ctx.request.body[key]))
        ctx.throw(400, `field ${key} must be of type string and contain a number`);
      }
      else if (typeof ctx.request.body[key] !== fields[key]) {
        ctx.throw(400, `field ${key} must be of type ${fields[key]}`);
      }

    }
  }
};

const isNumber = (value) => {
  return (/^(\-|\+)?([0-9]+(\.[0-9]+)?|Infinity)$/
          .test(value));
};

module.exports.isNumber = isNumber;