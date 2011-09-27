testCase = (require 'nodeunit').testCase
fs = require 'fs'
async = require 'async'
mongoose = require 'mongoose'
_ = require 'underscore'
require 'date-utils'

TestHelper = require './test_helper'

configModule = require '../lib/config'
config = configModule.load()
 
MetricCollector = require '../lib/metric_collector'

json = JSON.parse(fs.readFileSync "#{__dirname}/assets/agent_data.json", 'utf-8')

module.exports = testCase
  setUp: (callback) ->
    TestHelper.connectToDatabase()
    TestHelper.resetCollections ->
      callback()

  tearDown: (callback) ->
    TestHelper.disconnectFromDatabase callback
    
  'test constructing new metric collector without specifying type': (test) ->
    from = new Date().addHours -12
    to = new Date()
    collector = new MetricCollector 'test', ['test.metric'], from, to
    test.equals collector.node_id, 'test'
    test.equals collector.paths[0], 'test.metric'
    test.equals collector.type, 'counter'
    test.equals collector.fromTime, from
    test.equals collector.toTime, to
    test.done()

  'test constructing new metric collector by only specifying from date': (test) ->
    from = new Date().addDays -1
    collector = new MetricCollector 'test', ['test.metric'], from
    test.equals collector.node_id, 'test'
    test.equals collector.paths[0], 'test.metric'
    test.equals collector.type, 'counter'
    test.equals collector.fromTime, from
    test.ok typeof(collector.toTime) == 'object'
    test.done()

  'test constructing new metric collector with specifying type': (test) ->
    from = new Date().addHours -12
    to = new Date()
    collector = new MetricCollector 'test', ['test.metric'], 'incremental', from, to
    test.equals collector.node_id, 'test'
    test.equals collector.paths[0], 'test.metric'
    test.equals collector.type, 'incremental'
    test.equals collector.fromTime, from
    test.equals collector.toTime, to
    test.done()

  'test constructing new metric collector without specifying dates': (test) ->
    collector = new MetricCollector 'test', ['test.metric'], 'incremental'
    test.equals collector.node_id, 'test'
    test.equals collector.paths[0], 'test.metric'
    test.equals collector.type, 'incremental'
    test.ok typeof(collector.fromTime) == 'object'
    test.ok typeof(collector.toTime) == 'object'
    test.done()

  'test constructing new metric collector without specifying type or dates': (test) ->
    collector = new MetricCollector 'test', ['test.metric']
    test.equals collector.node_id, 'test'
    test.equals collector.paths[0], 'test.metric'
    test.equals collector.type, 'counter'
    test.ok typeof(collector.fromTime) == 'object'
    test.ok typeof(collector.toTime) == 'object'
    test.done()

  'limit metrics to the requested node': (test) ->

    # Create two snapshots for two different nodes.
    TestHelper.createSimpleSnapshots [ { node_id: 'test' }, { node_id: 'test2'} ], (error, snapshots) ->
      test.ok !error?

      # Ask for metrics on one of the nodes, and only expect one result.
      collector = new MetricCollector 'test', ['test.metric']
      collector.metrics (error, dataSet) ->
        test.ok !error?
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 1
        test.done()

  'limit metrics to the requested paths': (test) ->

    # Create two snapshots with two different paths.
    TestHelper.createSimpleSnapshots [ { path: 'test.metric.1' }, { path: 'test.metric.2' } ], (error, snapshots) ->
      test.ok !error?

      # Ask for metrics for one of the paths, and only expect one result
      collector = new MetricCollector 'test', ['test.metric.1']
      collector.metrics (error, dataSet) ->
        test.ok !error?
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric.1'].length, 1
        test.done()

  'limit metrics to the requested paths with wildcard': (test) ->

    # Create three snapshots with two different paths.
    TestHelper.createSimpleSnapshots [ { path: 'test.metric.1' }, { path: 'test.metric.2' }, { path: 'test.othermetric.1' } ], (error, snapshots) ->
      test.ok !error?

      # Ask for metrics for one of the paths, and only expect one result
      collector = new MetricCollector 'test', ['test.*.1']
      collector.metrics (error, dataSet) ->
        test.ok !error?
        test.equals _.keys(dataSet).length, 2
        test.equals dataSet['test.metric.1'].length, 1
        test.equals dataSet['test.othermetric.1'].length, 1
        test.done()

  'limit metrics to the requested time span': (test) ->

    now = new Date()
    one_hour_ago = new Date().addHours -1
    two_days_ago = new Date().addDays -2

    # Create two snapshots with two different dates.
    TestHelper.createSimpleSnapshots [ { timestamp: two_days_ago }, { timestamp: now } ], (error, snapshots) ->
      test.ok !error?

      # Ask for metrics within the last hour, and only expect one result.
      collector = new MetricCollector 'test', ['test.metric'], one_hour_ago, new Date()
      collector.metrics (error, dataSet) ->
        test.ok !error?
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 1
        test.done()

  'return values as-is for counter type': (test) ->

    # Create four snapshots with different values.
    TestHelper.createSimpleSnapshots [ { counter: 1 }, { counter: 2 }, { counter: 3 }, { counter: 4 } ], (error, snapshots) ->
      test.ok !error?

      # Ask for metrics and expect all 4 results returned with their original
      # value.
      collector = new MetricCollector 'test', ['test.metric']
      collector.metrics (error, dataSet) ->
        test.ok !error?
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 4
        test.equals dataSet['test.metric'][0].value, 1
        test.equals dataSet['test.metric'][1].value, 2
        test.equals dataSet['test.metric'][2].value, 3
        test.equals dataSet['test.metric'][3].value, 4
        test.done()

  'return incremental values for incremental type': (test) ->

    # Create four snapshots with different values.
    TestHelper.createSimpleSnapshots [ { counter: 10 }, { counter: 12 }, { counter: 20 }, { counter: 22 } ], (error, snapshots) ->
      test.ok !error?

      # Ask for metrics and expect all 4 results returned with the incremental
      # value calculated for each.
      collector = new MetricCollector 'test', ['test.metric'], 'incremental'
      collector.metrics (error, dataSet) ->
        test.ok !error?
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 4
        test.equals dataSet['test.metric'][0].value, 0
        test.equals dataSet['test.metric'][1].value, 2
        test.equals dataSet['test.metric'][2].value, 8
        test.equals dataSet['test.metric'][3].value, 2
        test.done()

  'properly reset counter for incremental values': (test) ->

    # Create four snapshots with different values, where the counter is reset.
    TestHelper.createSimpleSnapshots [ { counter: 10 }, { counter: 12 }, { counter: 2 }, { counter: 22 } ], (error, snapshots) ->
      test.ok !error?

      # Ask for metrics and expect all 4 results returned with the incremental
      # value calculated for each. When the counter is reset, we start back at 0
      # instead of returning a negative value.
      collector = new MetricCollector 'test', ['test.metric'], 'incremental'
      collector.metrics (error, dataSet) ->
        test.ok !error?
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 4
        test.equals dataSet['test.metric'][0].value, 0
        test.equals dataSet['test.metric'][1].value, 2
        test.equals dataSet['test.metric'][2].value, 2
        test.equals dataSet['test.metric'][3].value, 20
        test.done()
