module.exports =
  _tokens:
    echo:
      _leaf: true
      _desc: 'echo echo echo echo...'
    yammer:
      _leaf: true
      _desc: 'A social network for your workplace. http://www.yammer.com'
      _tokens:
        authorize:
          _leaf: true
          _desc: 'Run this first to authorize werminal to access your Yammer account'
        post:
          _leaf: true
          _desc: 'What are you working on?  Share an update on Yammer.'
        read:
          _leaf: true
          _desc: 'Optional argument N. Reads the N most recent updates from those you are following.'
    twitter:
      _tokens:
        post:
          _leaf: true
          _desc: 'Compose a new tweet'
        read:
          _leaf: true
          _desc: 'Read the latest tweets in your feed'
