express = require 'express'
eco = require 'eco'
app = module.exports = express.createServer()
require './lib/db_connection'

# App configuration.
app.set 'views', __dirname + '/views'
app.set 'view engine', 'eco'
app.register '.eco', eco

# Middleware configuration.
app.configure ->
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static __dirname + '/public'
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

# Routes
(require './routes/watson') app
(require './routes/nodes') app

# Start Express.
app.listen(6750)
console.log 'Sherlock listening on port %d in %s mode', app.address().port, app.settings.env
