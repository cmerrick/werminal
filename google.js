// Generated by CoffeeScript 1.4.0
var google;

google = (function() {

  function google() {}

  google.prototype.exe = function(args, response) {
    return this.search(args, response);
  };

  google.prototype.search = function(args, response) {
    var query;
    args.shift();
    query = args.join(' ');
    return response.send({
      popup: 'https://encrypted.google.com/search?q=' + query
    });
  };

  return google;

})();

module.exports = google;
