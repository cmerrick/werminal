mongoose = require 'mongoose'
Schema = mongoose.Schema
Config = require '../config/config'
db = mongoose.createConnection Config.mongoUri

# Define schema
UserSchema = new Schema
  openId:
    type: String
    unique: true
    required: true
  provider:
    type: String
    required: true
  displayName: String
  name:
    familyName: String
    givenName: String
    middleName: String
  emails: [
    value:
      type: String
      required: true
  ]

module.exports = db.model 'User', UserSchema