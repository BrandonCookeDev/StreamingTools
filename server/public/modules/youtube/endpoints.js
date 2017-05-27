'use strict';

let log     = require('winston');
let Youtube = require('./youtube');

module.exports = function(server){
    server.get('/youtube/auth', function(req, res){
        Youtube.oauth();
    });

    server.get('/youtube/authenticate', function(req, res){
        var code = req.query.code;
        var verify = Youtube.verifyOAuth(code);
    });

    server.get('/uploadStatus', function(req, res){
        var id = req.query.id;
        var uploadStatus = Youtube.getUploadStatus(id);
        res.send(uploadStatus);
    });

    server.post('/upload', function(req, res){
        var file = req.body.file;

        var input 		= file.inputFileName;
        var tournament 	= file.tournamentName;
        var round 		= file.round;
        var p1name 		= file.player1.smashtag;
        var p2name 		= file.player2.smashtag;
        var output 		= file.outputFileName;
        var bracket 	= file.bracketUrl;

        var yt = new Youtube(output, p1name, p2name, tournament, round, bracket);
        if(!Youtube.isAuthenticated())
            res.sendStatus(500);
        else{
            yt.upload()
                .then(function(){
                    var statusUrl = '/uploadStatus?id='+yt.id;
                    res.header('Location', statusUrl);
                    res.status(202);
                    res.end();
                })
                .catch(function(err){
                    log.error(err);
                    res.sendStatus(500);
                })
        }
    });
}