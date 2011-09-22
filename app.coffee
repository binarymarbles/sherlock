express = require 'express'
app = module.exports = express.createServer()

require './lib/db_connection'
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

  new SnapshotParser req.body.payload, (error, snapshot) ->

    if error?
      console.log 'Handling watson snapshot failed, error is', error.message
      res.writeHead 422, 'Content-Type': 'text/plain'
      res.end "ERROR: #{error.message}"

    else

      console.log 'Successfully handled Watson snapshot, stored with ID', snapshot.id, 'and key', snapshot.key
      res.writeHead 200, 'Content-Type': 'text/plain'
      res.end "OK: #{snapshot.id}"

app.listen(6750)
console.log 'Sherlock listening on port %d in %s mode', app.address().port, app.settings.env
