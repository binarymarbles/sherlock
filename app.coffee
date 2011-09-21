express = require 'express'
app = module.exports = express.createServer()

dbConnection = (require './lib/db_connection').get()
SnapshotParser = require './lib/snapshot_parser'

# Configuration
app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.compiler
    src: __dirname + '/public'
    enable: ['sass']
  app.use app.router
  app.use express.static __dirname + '/public'

app.configure 'development', ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.configure 'production', ->
  app.use express.errorHandler()

app.get '/', (req, res) ->
  res.render 'index',
    title: 'Sherlock'

app.post '/watson/snapshot', (req, res) ->

  response_code = 200
  response_message = 'OK'

  try
    parser = new SnapshotParser req.body.payload
    parser.storeSnapshot()
  catch err
    response_code = 422
    response_message = err.message

  console.log 'Handled Watson snapshot - response code =', response_code, ', response message =', response_message

  # Dump the response to the client.
  res.writeHead response_code,
    'Content-Type': 'text/plain'
  res.end response_message

app.listen(6750)
console.log 'Sherlock listening on port %d in %s mode', app.address().port, app.settings.env
