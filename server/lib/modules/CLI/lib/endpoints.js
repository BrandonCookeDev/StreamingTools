var express = require('express');
var router  = express.Router();

var ctrl    = require('./controller');

module.exports = function(server){
    router.route('/cli/createClip').post(ctrl.createClip);
    server.use(router);
};