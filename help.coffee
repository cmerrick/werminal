_ = require 'underscore'
Config = require './config/config'
querystring = require 'querystring'

class help

  constructor: (@user) ->

  helpText:
    """
  <p>werminal is a command line interface wired for the web, and designed with simplicity in mind.</p>
  <p>Type commands in the input box, and press ENTER to execute them.</p>
  <p>werminal is built around <strong>services</strong> that perform various functions.  Some, like this <strong>help</strong> service, just output helpful text.  Others perform transformations or interface with third party platforms.</p>
  <p>Many services, particularly those that connect to third parties, require you to login by clicking the link at the top of this page.</p>
  <p>Type <strong>services</strong> to see a list of available services.</p>
    """
  
  exe: (args, response) =>
    response.send
      stdout: @helpText
      template: Config.expandURL '/blank.html'

module.exports = help