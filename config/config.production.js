// Generated by CoffeeScript 1.4.0
var _config;

_config = {
  mongoUri: process.env.MONGOLAB_URI,
  port: process.env.PORT,
  expandURL: function(path) {
    return 'http://www.werminal.net' + path;
  }
};

module.exports = _config;