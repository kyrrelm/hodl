const Koa = require("koa");
const Router = require("koa-router");
const BodyParser = require("koa-bodyparser");
const logger = require('koa-logger');
const secure = require("./middleware/secure.js");
const error = require("./middleware/error.js");
const authResource = require('./resource/authResource.js');
const userResource = require('./resource/userResource.js');

const app = new Koa();

app.use(logger());
app.use(BodyParser());

require("./mongo")(app);

const router = new Router();

router.use(error.errorHandler());
router.use(secure.apiKey());

const secureRouter = new Router();

secureRouter.use(error.errorHandler());
secureRouter.use(secure.apiKey());
secureRouter.use(secure.jwt());

authResource.register(router);
userResource.register(secureRouter);

router.get("/", async function (ctx) {
  ctx.body = {message: `Endepunkter på /auth og /user`}
});


app.use(router.routes()).use(router.allowedMethods());
app.use(secureRouter.routes()).use(secureRouter.allowedMethods());

app.listen(process.env.PORT || 8080);