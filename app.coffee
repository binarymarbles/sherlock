express = require 'express'
eco = require 'eco'
cron = require 'cron'
app = module.exports = express.createServer()
require './lib/db_connection'

BenchmarkTimer = require './lib/benchmark_timer'
AverageGenerator = require './lib/average_generator'

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

# Set up an internal cron job that calculates some averages for our metrics.
cron.CronJob '30 */5 * * * *', ->

  timer = new BenchmarkTimer 'calculate averages'
  averageGenerator = new AverageGenerator
  averageGenerator.calculateAllAverages (error) ->
    timer.end()
    console.log 'Recalculated all averages'
