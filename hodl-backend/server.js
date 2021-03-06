const Koa = require("koa");
const Router = require("koa-router");
const bodyParser = require("koa-bodyparser");
const logger = require('koa-logger');
const koaValidator = require('koa-async-validator');
const secure = require("./middleware/secure.js");
const error = require("./middleware/error.js");
const healthResource = require('./resource/healthResource.js');
const authResource = require('./resource/authResource.js');
const userResource = require('./resource/userResource.js');
const portfolioResource = require('./resource/portfolioResource.js');
const currencyResource = require('./resource/currencyResource.js');
const tasks = require('./tasks.js');
const mongo = require('./mongo.js');
const cors = require('koa-cors');
const DISABLE_API_KEY = process.env.DISABLE_API_KEY || 'true';

const DISABLE_JWT = process.env.DISABLE_JWT || 'false';

const app = new Koa();
app.use(logger());
app.use(cors());
app.use(bodyParser());

app.use(koaValidator());

mongo.connect(app)
    .then(() =>
        tasks.currencies(app)
    );

const router = new Router();
const routerNoApiKey = new Router();
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
healthResource.register(routerNoApiKey);
userResource.register(secureRouter);
portfolioResource.register(secureRouter);
currencyResource.register(secureRouter);

router.get("/", async function (ctx) {
  ctx.body = {message: `Endepunkter på /auth og /user`}
});


app.use(router.routes()).use(router.allowedMethods());
app.use(routerNoApiKey.routes()).use(routerNoApiKey.allowedMethods());
app.use(secureRouter.routes()).use(secureRouter.allowedMethods());

app.listen(process.env.PORT || 8080);