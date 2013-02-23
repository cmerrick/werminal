_ = require 'underscore'
Config = require './config/config'
querystring = require 'querystring'
tokenTree = require './tokenTree'

class services

  constructor: (@user) ->
  
  exe: (args, response) ->
    serviceNames = _(tokenTree._tokens).map (value, key) -> '<li><span class="service-name">' + key + '</span><span class="description">'+ value._desc + '</span></li>'
    servicesHTML = '<ul class="services">' + serviceNames.join('') + '</ul>'
    response.send
      stdout: servicesHTML
      template: Config.expandURL '/blank.html'

module.exports = services