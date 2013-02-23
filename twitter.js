// Generated by CoffeeScript 1.4.0
var Config, CredentialProvider, OAuth, twitter;

OAuth = require('oauth').OAuth;

CredentialProvider = require('./credential').CredentialProvider;

Config = require('./config/config');

twitter = (function() {

  twitter.prototype.consumer_key = '';

  twitter.prototype.consumer_secret = '';

  twitter.prototype.request_token_url = "https://api.twitter.com/oauth/request_token";

  twitter.prototype.access_token_url = "https://api.twitter.com/oauth/access_token";

  twitter.prototype.oauth_version = '1.0';

  function twitter(user) {
    this.user = user;
  }

  twitter.prototype.exe = function(args, response) {
    if (args.length === 1) {
      return this.read(10, response);
    } else {
      return this[args[1]](args, response);
    }
  };

  twitter.prototype.setup = function(args, response) {
    return response.send({
      redirect: Config.expandURL('/auth/twitter')
    });
  };

  twitter.prototype.read = function(args, response) {
    var count, cred_provider,
      _this = this;
    count = args[2] ? args[2] : 10;
    cred_provider = new CredentialProvider(Config.mongoUri);
    return cred_provider.find(this.user.id, 'twitter', function(err, credential) {
      var url;
      url = "https://api.twitter.com/1.1/statuses/home_timeline.json?count=" + count;
      return _this.oauth().get(url, credential.access_token, credential.access_token_secret, function(error, data, res) {
        return response.send({
          stdout: data
        });
      });
    });
  };

  twitter.prototype.post = function(args, response) {
    var cred_provider, status,
      _this = this;
    status = args[2];
    cred_provider = new CredentialProvider(Config.mongoUri);
    return cred_provider.find(this.user.id, 'twitter', function(err, credential) {
      var url;
      url = "https://api.twitter.com/1.1/statuses/update.json?status=" + status;
      return _this.oauth().post(url, credential.access_token, credential.access_token_secret, function(error, data, res) {
        return response.send({
          stdout: data
        });
      });
    });
  };

  return twitter;

})();

module.exports = twitter;
