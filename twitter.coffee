OAuth = require('oauth').OAuth
CredentialProvider = require('./credential').CredentialProvider
Config = require './config/config'

#THIS IS BROKEN - AUTH DOES NOT WORK
class twitter
  consumer_key: ''
  consumer_secret: ''
  request_token_url: "https://api.twitter.com/oauth/request_token"
  access_token_url: "https://api.twitter.com/oauth/access_token"
  oauth_version: '1.0'

  constructor: (@user) ->

  exe: (args, response) ->
    if args.length == 1
      @read 10, response
    else
      @[args[1]] args, response

  setup: (args, response) ->
      response.send
        redirect: Config.expandURL '/auth/twitter'

  read: (args, response) ->
    count = if args[2] then args[2] else 10
    cred_provider = new CredentialProvider Config.mongoUri
    cred_provider.find @user.id, 'twitter', (err, credential) =>
      url = "https://api.twitter.com/1.1/statuses/home_timeline.json?count=" + count
      @oauth().get url,
        credential.access_token,
        credential.access_token_secret,
        (error, data, res) ->
          response.send
            stdout: data

  post: (args, response) ->
    status = args[2]
    cred_provider = new CredentialProvider Config.mongoUri
    cred_provider.find @user.id, 'twitter', (err, credential) =>
      url = "https://api.twitter.com/1.1/statuses/update.json?status=" + status
      @oauth().post url,
        credential.access_token,
        credential.access_token_secret,
        (error, data, res) ->
          response.send
            stdout: data

module.exports = twitter