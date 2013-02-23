
class google
  exe: (args, response) ->
    @search args, response

  search: (args, response) ->
    args.shift()
    query = args.join ' '
    response.send popup:
        'https://encrypted.google.com/search?q=' + query

module.exports = google