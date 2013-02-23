querystring = require 'querystring'
crypto = require 'crypto'
https = require 'https'
http = require 'http'
URL = require 'url'

class oauth2

  constructor: (customHeaders) ->
    @_accessTokenName = "access_token"
    @_authMethod= "Bearer"
    @_customHeaders = customHeaders || {}

  # This 'hack' method is required for sites that don't use
  # 'access_token' as the name of the access token (for requests).
  # ( http://tools.ietf.org/html/draft-ietf-oauth-v2-16#section-7 )
  # it isn't clear what the correct value should be atm, so allowing
  # for specific (temporary?) override for now.
  setAccessToken: (name) ->
    @_accessTokenName = name

  # Sets the authorization method for Authorization header.
  # e.g. Authorization: Bearer <token>  # "Bearer" is the authorization method.
  setAuthMethod: (authMethod) ->
    @_authMethod = authMethod

  # Build the authorization header. In particular, build the part after the colon.
  # e.g. Authorization: Bearer <token>  # Build "Bearer <token>"
  _buildAuthHeader: (token) ->
    return @_authMethod + ' ' + token

  _request: (method, url, headers, post_body, access_token, callback) ->
    http_library = https
    parsedUrl = URL.parse url, true
    if parsedUrl.protocol == "https:" and not parsedUrl.port
      parsedUrl.port = 443

    # As this is OAUth2, we *assume* https unless told explicitly otherwise.
    if parsedUrl.protocol != "https:"
      http_library = http

    realHeaders = @_customHeaders
    if headers
      for key in headers
        realHeaders[key] = headers[key]

    realHeaders['Host'] = parsedUrl.host
    realHeaders['Content-Length'] = if post_body then Buffer.byteLength(post_body) else 0
    realHeaders['Authorization'] = @_buildAuthHeader(access_token)

    if access_token
      if not parsedUrl.query
        parsedUrl.query = {}
      parsedUrl.query[@_accessTokenName] = access_token

    result= "";

    queryStr = querystring.stringify parsedUrl.query
    if queryStr
      queryStr =  "?" + queryStr;
    options =
      host: parsedUrl.hostname,
      port: parsedUrl.port,
      path: parsedUrl.pathname + queryStr,
      method: method,
      headers: realHeaders

    # Some hosts *cough* google appear to close the connection early / send no content-length header
    # allow this behaviour.  Disabled for now
    allowEarlyClose = false
    callbackCalled = false
    passBackControl = (response, result) ->
      if not callbackCalled
        callbackCalled=true;
        if response.statusCode != 200 and response.statusCode != 201 and response.statusCode != 301 and response.statusCode != 302
          callback
            statusCode: response.statusCode,
            data: result
        else
          callback null, result, response

    request = http_library.request options, (response) ->
      response.on "data", (chunk) ->
        result+= chunk

      response.on "close", (err) ->
        if allowEarlyClose
          passBackControl response, result

      response.addListener "end", () ->
        passBackControl response, result

    request.on 'error', (e) ->
      callbackCalled = true
      callback e

    if method == 'POST' and post_body
      request.write post_body

    request.end()

  request: (method, url, body, access_token, callback) ->
    @_request method, url, body, access_token, callback

  get: (url, access_token, callback) ->
    @_request 'GET', url, {}, "", access_token, callback

  post: (url, post_body, access_token, callback) ->
    @_request 'POST', url, {}, post_body, access_token, callback

module.exports = oauth2