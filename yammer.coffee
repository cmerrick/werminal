Credential = require './models/credential'
OAuth2Strategy = require('passport-oauth').OAuth2Strategy
OAuth2 = require './oauth2'
_ = require 'underscore'
Config = require './config/config'
querystring = require 'querystring'

class yammer
  constructor: (@user) ->

  authStrategy: () =>
    new OAuth2Strategy
      authorizationURL: 'https://www.yammer.com/dialog/oauth'
      tokenURL: 'https://www.yammer.com/oauth2/access_token.json'
      callbackURL: Config.expandURL '/auth/callback/yammer'
      passReqToCallback: true
      clientID: process.env.YAMMER_CLIENT_ID
      clientSecret: process.env.YAMMER_CLIENT_SECRET

      (request, accessToken, refreshToken, profile, done) =>
        Credential.findOne
          userId: @user.id
          service: 'yammer',
          (err, credential) =>
            if not credential
              credential = new Credential
                userId: @user.id
                service: 'yammer'
                oauth:
                  accessToken: accessToken.token
              credential.save (err) ->
                if err
                  console.log err
            done err, request.user # this is important - we aren't using this strategy for authentication, so we don't change request.user

  exe: (args, response) ->
    if args.length == 1
      @read 10, response
    else
      if @[args[1]]
        @[args[1]] args, response
      else
        throw new Error 'Command not recognized'

  authorize: (args, response) ->
      response.send
        redirect: Config.expandURL '/auth/yammer'
  
  post: (args, response) ->
    if not @user
      throw new Error "You must login to use this command"
    args.shift()
    args.shift()
    message = args.join ' '
    query = Credential.findOne
      userId: @user.id
      service: 'yammer'

    query.select('oauth')

    query.exec (err, credential) => 
      try
        if not credential
          throw new Error "First run 'yammer authorize' to connect werminal to your Yammer account"

        oauth2 = new OAuth2()
        oauth2.post 'https://www.yammer.com/api/v1/messages.json?body=' + querystring.escape(message),
          '',
          credential.oauth.accessToken,
          (err, apiResult, apiResponse) =>
            if err
              console.log err
            response.send
              stdout: JSON.parse apiResult
              template: Config.expandURL '/yammer.html'
      catch error
        response.send error:
          "Authorization error. Run 'yammer authorize' to connect werminal to your Yammer account"

  read: (args, response) ->
    if not @user
      throw new Error "You must login to use this command"

    count = if args[2] then args[2] else 10
    query = Credential.findOne
      userId: @user.id
      service: 'yammer'

    query.select('oauth')

    query.exec (err, credential) =>
      try
        oauth2 = new OAuth2()
        oauth2.get 'https://www.yammer.com/api/v1/messages.json?threaded=extended&limit=' + querystring.escape(count),
          credential.oauth.accessToken,
          (err, apiResult, apiResponse) =>
            if err
              console.log err
  
            output = @_transformMessages JSON.parse apiResult
            response.send
              stdout: output
              template: Config.expandURL '/yammer.html'
      catch error
        response.send error:
          "Authorization error. Run 'yammer authorize' to connect werminal to your Yammer account"


  _transformMessages: (rawOutput) ->
    get_sender = (sender_id) ->
        _.find rawOutput.references, (reference) ->
          sender_id == reference.id
  
    messages =  _.map rawOutput.messages, (message) ->
      message.sender = get_sender message.sender_id
      extended_thread = rawOutput.threaded_extended[message.thread_id]
      message.extended_thread = _.map extended_thread, (thread_item) ->
        thread_item.sender = get_sender thread_item.sender_id
        return thread_item

      return message
    
    return { messages: messages }

module.exports = yammer
