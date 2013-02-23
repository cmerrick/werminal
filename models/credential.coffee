mongoose = require 'mongoose'
Schema = mongoose.Schema
Config = require '../config/config'
db = mongoose.createConnection Config.mongoUri

# Define schema
CredentialSchema = new Schema
  userId:
    type: String
    required: true
  service:
    type: String
    required: true
  oauth:
    accessToken:
      type: String
      required: false
    accessTokenSecret:
      type: String
      required: false
    refreshToken:
      type: String
      required: false

module.exports = db.model 'Credential', CredentialSchema