mongoose = require 'mongoose'

# The default hostname to connect to.
mongoHostname = 'localhost'

# The default database to use.
mongoDatabase = 'sherlock'

console.log 'aquiring connection'
connection = mongoose.connect "mongodb://#{mongoHostname}/#{mongoDatabase}"
console.log 'connection aquired'

module.exports = connection
