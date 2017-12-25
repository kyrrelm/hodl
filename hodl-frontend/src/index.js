'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./hodl.css');

// Require index.html so it gets copied to dist
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

// .embed() can take an optional second argument. This would be an object describing the data we need to start a program, i.e. a userID or some token
var app = Elm.Main.embed(mountNode);

app.ports.storeJwtToken.subscribe(function(jwt) {
  console.log("PORT reporting in:", jwt);
  localStorage.setItem('jwt', jwt.token);
  app.ports.receiveJwtToken.send(jwt);
});

app.ports.retrieveJwtToken.subscribe(function() {
  console.log("PORT 2 reporting in.");
  const jwt = {token: localStorage.getItem("jwt")};
  console.log(jwt);
  app.ports.receiveJwtToken.send(jwt);
});