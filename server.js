const Koa = require("koa");
const Router = require("koa-router");
const bodyParser = require("koa-bodyparser");
const logger = require('koa-logger');
const koaValidator = require('koa-async-validator');
const secure = require("./middleware/secure.js");
const error = require("./middleware/error.js");
const authResource = require('./resource/authResource.js');
const userResource = require('./resource/userResource.js');
const DISABLE_API_KEY = process.env.API_KEY || 'true';
const DISABLE_JWT = process.env.API_KEY || 'true';

const app = new Koa();

app.use(logger());
app.use(bodyParser());
app.use(koaValidator());

require("./mongo")(app);

const router = new Router();
const secureRouter = new Router();

router.use(error.errorHandler());
secureRouter.use(error.errorHandler());

if (DISABLE_API_KEY !== 'true') {
  router.use(secure.apiKey());
  secureRouter.use(secure.apiKey());
}
if (DISABLE_JWT !== 'true') {
  secureRouter.use(secure.jwt());
}

authResource.register(router);
userResource.register(secureRouter);

router.get("/", async function (ctx) {
  ctx.body = {message: `Endepunkter på /auth og /user`}
});


app.use(router.routes()).use(router.allowedMethods());
app.use(secureRouter.routes()).use(secureRouter.allowedMethods());

app.listen(process.env.PORT || 8080);