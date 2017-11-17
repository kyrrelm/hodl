const Koa = require("koa");
const Router = require("koa-router");
const BodyParser = require("koa-bodyparser");
const logger = require('koa-logger');
const ObjectID = require("mongodb").ObjectID;

const app = new Koa();
const router = new Router();

app.use(logger());
app.use(BodyParser());

require("./mongo")(app);

router.get("/", async function (ctx) {
  ctx.body = {message: `Hello World! ${process.env.MONGODB_URI}`}
});

router.post("/", async function (ctx) {
  let name = ctx.request.body.name || "World";
  ctx.body = {message: `Hello ${name}!`}
});

router.get("/user", async function (ctx) {
  ctx.body = await ctx.app.user.find().toArray();
});

router.get("/user/:id", async (ctx) => {
  ctx.body = await ctx.app.user.findOne({"_id": ObjectID(ctx.params.id)});
});

router.post("/user", async function (ctx) {
  ctx.body = await ctx.app.user.insert(ctx.request.body);
});

router.put("/user/:id", async (ctx) => {
  let documentQuery = {"_id": ObjectID(ctx.params.id)}; // Used to find the document
  let valuesToUpdate = ctx.request.body;
  ctx.body = await ctx.app.user.updateOne(documentQuery, valuesToUpdate);
});

router.delete("/user/:id", async (ctx) => {
  let documentQuery = {"_id": ObjectID(ctx.params.id)}; // Used to find the document
  ctx.body = await ctx.app.user.deleteOne(documentQuery);
});

router.get("/_ah/health", async function (ctx) {
  ctx.body = {message: `Im good :)`}
});

app.use(router.routes()).use(router.allowedMethods());

app.listen(process.env.PORT || 8080);