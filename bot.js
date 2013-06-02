require('coffee-script')

var PlugAPI = require('plugapi')
  , repl = require('repl')
  , config = require('./config')
  , Quorum = require('./quorum');

var bot = new PlugAPI(config.auth);

bot.connect();

bot.on('connected', function(){
	bot.joinRoom(config.room);
});

bot.on('roomChanged', function(data) {
	console.log('>> Joined Room!');
});

bot.on('error', function(e){
	console.log("Error: ", e);
});

bot.on('close', function(e){
	console.log("Closed");
});

var quorum = new Quorum(bot);
quorum.on('split', function(){
	console.log('Dang we are split')
});
// deal with plug.djs's failure to serve disconnection events
// by expecting the next djAdvance event based on the time of the 
// current media.
// var antiPDJSuckageTimer;
// bot.on('djAdvance', function(data) {
//   clearTimeout(antiPDJSuckageTimer);
//   antiPDJSuckageTimer = setTimeout(function() {
//     console.log('PLUG.DJ FAILED TO SEND DJADVANCE EVENT IN EXPECTED TIMEFRAME.');
//     //reconnect();
//     bot.joinRoom('test', function() {
//       bot.joinRoom('coding-soundtrack');
//     });
//   }, (data.media.duration + 10) * 1000);
// });

// var _reconnect = function() { bot.connect(config.room); };
// var reconnect = function() { setTimeout(_reconnect, 500); };
// bot.on('close', reconnect);
// bot.on('error', reconnect);

r = repl.start("node> ");
r.context.bot = bot;
r.context.repl = r;
r.context.q = quorum;