#werminal#

A web-based terminal for interacting with web-based services.  Users authenticate with the werminal service using a google account, and then connect their werminal account to supported third party services, typically using OAuth.

###Supported Services###
- Yammer

##Contribute##

werminal is built on node.js, mongodb, and angular.js, and currently deployed to heroku.

The easiest way to run werminal is to use the heroku foreman from https://toolbelt.heroku.com/.  werminal also needs a running mongodb server.

The following environmental variables must be set
- SESSION_SECRET (to anything)
- YAMMER_CLIENT_ID
- YAMMER_CLIENT_SECRET

To set these environmental variables locally, follow [heroku's instructions](https://devcenter.heroku.com/articles/config-vars#local-setup).