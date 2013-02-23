_ = require 'underscore'
express = require 'express'
mongoose = require 'mongoose'
passport = require 'passport'
GoogleStrategy = require('passport-google').Strategy
mongoStore = require 'connect-mongodb'
Config = require './config/config'
User = require './models/user'
Credential = require './models/credential'
grammar = require './grammar'
app = express.createServer express.logger()

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
    User.findById id, (err, user) ->
      done(err, user)

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.set 'view options', { pretty: true }
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session
    secret: process.env.SESSION_SECRET
    cookie:
      expires: new Date(2099,1,1,0,0,0,0)
    store: new mongoStore
      url: Config.mongoUri
  app.use passport.initialize()
  app.use passport.session()
  app.use express.static __dirname + '/public'

app.configure 'development', () ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.configure 'production', () ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

passport.use new GoogleStrategy {
  returnURL: Config.expandURL('/signin/google/return'),
  realm: Config.expandURL('/')
  },
  (identifier, profile, done) ->
    profile.provider = 'google'
    User.findOne
      openId: identifier, (err, user) ->
        if not user
          profile.openId = identifier
          user = new User profile
          user.save (err) ->
            if err
              console.log err
        done err, user

app.get '/signin/google', passport.authenticate 'google'

app.get '/signin/google/return', passport.authenticate 'google',
  failureRedirect: '/',
  successRedirect: '/'

app.get '/', (request, response) ->
  response.render 'index',
    user: request.user
    title: 'werminal'

app.get '/logout', (request, response) ->
  request.logout()
  response.redirect Config.expandURL('/')

app.get '/e', (request, response) ->
 	query = request.query.q
  args = grammar.tokenize query
  token = args[0]
  try
    try
      module = require './' + token
    catch moduleNotFoundError
      throw new Error 'Command not recognized'
    executable = new module request.user
    executable.exe args, response
  catch error
    response.send
      error: error.message

app.get '/auth/:service', (request, response) ->
  module = require './' + request.params.service
  executable = new module request.user
  tmpPassport = require 'passport'
  authStrategy = executable.authStrategy()
  tmpPassport.use(request.params.service, authStrategy);
  tmpPassport.authenticate(request.params.service)(request, response)

app.get '/auth/callback/:service', (request, response, next) ->
  module = require './' + request.params.service
  executable = new module request.user
  tmpPassport = require 'passport'
  authStrategy = executable.authStrategy()
  tmpPassport.use(request.params.service, authStrategy);
  tmpPassport.authenticate(request.params.service,
    successRedirect: '/',
    failureRedirect: '/'
    )(request, response)

app.get '/terms', (request, response) ->
  response.render 'terms',
    user: request.user
    title: 'werminal'

app.get '/privacy', (request, response) ->
  response.render 'privacy',
    user: request.user
    title: 'werminal'

app.get '/autocomplete', (request, response) ->
  tokenTree = require './tokenTree'
  response.send tokenTree

app.listen Config.port, ->
	console.log "Listening on " + Config.port
