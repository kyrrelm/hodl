const Koa = require("koa");
const Router = require("koa-router");
const BodyParser = require("koa-bodyparser");
const logger = require('koa-logger');
const jwt = require("./jwt");
const authResource = require('./resource/authResource.js');
const userResource = require('./resource/userResource.js');

const app = new Koa();

app.use(logger());
app.use(BodyParser());

require("./mongo")(app);

const router = new Router();
const secureRouter = new Router();
secureRouter.use(jwt.errorHandler());

secureRouter.use(jwt.jwt());

authResource.register(router);
userResource.register(secureRouter);

router.get("/", async function (ctx) {
  ctx.body = {message: `Endepunkter på /auth og /user`}
});


app.use(router.routes()).use(router.allowedMethods());
app.use(secureRouter.routes()).use(secureRouter.allowedMethods());

app.listen(process.env.PORT || 8080);