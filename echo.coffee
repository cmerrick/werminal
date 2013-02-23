class echo
  exe: (args, response) ->
    args.shift()
    return response.send
      stdout: args 

module.exports = echo

