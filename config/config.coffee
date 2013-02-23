_env = process.env.NODE_ENV or 'development'
_config = require './config.' + _env
module.exports = _config