_config =
  mongoUri: 'mongodb://localhost:27017/local'
  port: 5000
  expandURL: (path) ->
    return 'http://localhost:5000' + path
    
module.exports = _config
