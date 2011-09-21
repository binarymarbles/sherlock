mongoose = require 'mongoose'

# The default hostname to connect to.
mongoHostname = 'localhost'

# The default database to use.
mongoDatabase = 'sherlock'

module.exports =
  aquire: ->
    connectionString = "mongodb://#{mongoHostname}/#{mongoDatabase}"
    console.log 'Connecting to', connectionString
    mongoose.connect connectionString
    mongoose.connection
