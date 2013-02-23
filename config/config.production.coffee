_config = 
  mongoUri: process.env.MONGOLAB_URI
  port: process.env.PORT
  expandURL: (path) ->
    return 'http://www.werminal.net' + path

module.exports = _config
