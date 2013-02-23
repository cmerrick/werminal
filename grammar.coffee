_ = require 'underscore'
_.str = require 'underscore.string'

module.exports.tokenize = (input) ->
  pattern = new RegExp '\w+|"[^"]+"', 'gi'
  matches = input.match /\w+|"(?:\\"|[^"])+"/g
  trimmedMatches = _(matches).map (token) ->
    _.str.trim token, '"'
  return trimmedMatches
