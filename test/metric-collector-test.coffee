testCase = (require 'nodeunit').testCase
fs = require 'fs'
async = require 'async'
mongoose = require 'mongoose'

configModule = require '../lib/config'
configModule.setConfigDirectory './test/config'
config = configModule.load()
 
mongoose.connect 'mongodb://localhost/sherlock_test'

SnapshotParser = require '../lib/snapshot_parser'
Snapshot = (require '../lib/models/snapshot')
Process = (require '../lib/models/process')
MetricLabel = (require '../lib/models/metric_label')
Metric = (require '../lib/models/metric')
MetricCollector = require '../lib/metric_collector'

json = fs.readFileSync "#{__dirname}/assets/agent_data.json", 'utf-8'

module.exports = testCase
  setUp: (callback) ->
    new SnapshotParser json, ->
      callback()

  tearDown: (callback) ->

    # Remove all collections and call the callback.
    async.parallel [
        (callback) ->
          Snapshot.collection.remove callback
      , (callback) ->
          Process.collection.remove callback
      , (callback) ->
          MetricLabel.collection.remove callback
      , (callback) ->
          Metric.collection.remove callback
    ], (err, results) ->
      callback()

  'construct new metric collector': (test) ->
    collector = new MetricCollector config.nodeById('test1'), config.graphById('load_average')
    test.equals collector.graph.id, 'load_average'
    test.done()

  'calculate metrics': (test) ->
    collector = new MetricCollector config.nodeById('test1'), config.graphById('load_average')
    collector.metrics ->
      test.done()
