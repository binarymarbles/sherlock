testCase = (require 'nodeunit').testCase
fs = require 'fs'
async = require 'async'
mongoose = require 'mongoose'
_ = require 'underscore'

configModule = require '../lib/config'
configModule.setConfigDirectory './test/config'
config = configModule.load()
 
SnapshotParser = require '../lib/snapshot_parser'
Snapshot = require '../models/snapshot'
Process = require '../models/process'
MetricLabel = require '../models/metric_label'
Metric = require '../models/metric'
MetricCollector = require '../lib/metric_collector'

json = fs.readFileSync "#{__dirname}/assets/agent_data.json", 'utf-8'

module.exports = testCase
  setUp: (callback) ->
    mongoose.connect 'mongodb://localhost/sherlock_test'
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
      mongoose.disconnect ->
        callback()

  'construct new metric collector': (test) ->
    collector = new MetricCollector config.nodeById('test1'), config.graphById('load_average')
    test.equals collector.graph.id, 'load_average'
    test.done()

  'calculate metrics for single-key graph': (test) ->
    collector = new MetricCollector config.nodeById('test1'), config.graphById('load_average')
    collector.metrics (error, dataSet) ->
      test.ifError error
      test.equals _.keys(dataSet).length, 1
      test.done()

  'calculate metrics for multi-key graph': (test) ->
    collector = new MetricCollector config.nodeById('test1'), config.graphById('network_traffic')
    collector.metrics (error, dataSet) ->
      console.log 'Collected metrics, error=', error, ', dataSet=', dataSet
      test.ifError error
      test.equals _.keys(dataSet).length, 4
      test.done()
