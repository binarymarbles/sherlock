express = require 'express'
app = module.exports = express.createServer()

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

app.listen(6750)
console.log 'Sherlock listening on port %d in %s mode', app.address().port, app.settings.env
