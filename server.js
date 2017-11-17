const Koa = require("koa");
const Router = require("koa-router");
const BodyParser = require("koa-bodyparser");
const logger = require('koa-logger');

const app = new Koa();
const router = new Router();

app.use(logger());
app.use(BodyParser());

//require("./mongo")(app);

router.post("/", async function (ctx) {
  let name = ctx.request.body.name || "World";
  ctx.body = {message: `Hello ${name}!`}
});

router.get("/", async function (ctx) {
  ctx.body = {message: `Hello World!`}
});

router.get("/_ah/health", async function (ctx) {
  ctx.body = {message: `Im good :)`}
});

app.use(router.routes()).use(router.allowedMethods());

app.listen(process.env.PORT || 8080);