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
    callback()

  tearDown: (callback) ->
    TestHelper.resetCollections ->
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
      test.ifError error

      # Ask for metrics on one of the nodes, and only expect one result.
      collector = new MetricCollector 'test', ['test.metric']
      collector.metrics (error, dataSet) ->
        test.ifError error
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 1
        test.done()

  'limit metrics to the requested paths': (test) ->

    # Create two snapshots with two different paths.
    TestHelper.createSimpleSnapshots [ { path: 'test.metric.1' }, { path: 'test.metric.2' } ], (error, snapshots) ->
      test.ifError error

      # Ask for metrics for one of the paths, and only expect one result
      collector = new MetricCollector 'test', ['test.metric.1']
      collector.metrics (error, dataSet) ->
        test.ifError error
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric.1'].length, 1
        test.done()

  'limit metrics to the requested time span': (test) ->

    now = new Date()
    one_hour_ago = new Date().addHours -1
    two_days_ago = new Date().addDays -2

    # Create two snapshots with two different dates.
    TestHelper.createSimpleSnapshots [ { timestamp: two_days_ago }, { timestamp: now } ], (error, snapshots) ->
      test.ifError error

      # Ask for metrics within the last hour, and only expect one result.
      collector = new MetricCollector 'test', ['test.metric'], one_hour_ago, new Date()
      collector.metrics (error, dataSet) ->
        test.ifError error
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 1
        test.done()

  'return values as-is for counter type': (test) ->

    # Create four snapshots with different values.
    TestHelper.createSimpleSnapshots [ { counter: 1 }, { counter: 2 }, { counter: 3 }, { counter: 4 } ], (error, snapshots) ->
      test.ifError error

      # Ask for metrics and expect all 4 results returned with their original
      # value.
      collector = new MetricCollector 'test', ['test.metric']
      collector.metrics (error, dataSet) ->
        test.ifError error
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
      test.ifError error

      # Ask for metrics and expect all 4 results returned with the incremental
      # value calculated for each.
      collector = new MetricCollector 'test', ['test.metric'], 'incremental'
      collector.metrics (error, dataSet) ->
        test.ifError error
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
      test.ifError error

      # Ask for metrics and expect all 4 results returned with the incremental
      # value calculated for each. When the counter is reset, we start back at 0
      # instead of returning a negative value.
      collector = new MetricCollector 'test', ['test.metric'], 'incremental'
      collector.metrics (error, dataSet) ->
        test.ifError error
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 4
        test.equals dataSet['test.metric'][0].value, 0
        test.equals dataSet['test.metric'][1].value, 2
        test.equals dataSet['test.metric'][2].value, 2
        test.equals dataSet['test.metric'][3].value, 20
        test.done()

  'calculate five minute averages': (test) ->

    base_date = new Date().clearTime().addHours(3)

    avg1_date_1 = base_date.clone().addMinutes 5
    avg1_date_2 = base_date.clone().addMinutes 6
    avg2_date_1 = base_date.clone().addMinutes 10
    avg2_date_2 = base_date.clone().addMinutes 11

    # Create three snapshots with different values and timestamps where half of
    # the values are in one average, the rest in another.
    TestHelper.createSimpleSnapshots [
      { timestamp: avg1_date_1, counter: 4 },
      { timestamp: avg1_date_2, counter: 8 },
      { timestamp: avg2_date_1, counter: 2 },
    ], (error, snapshots) ->
      test.ifError error

      # Ask for metrics for the last 24 hours, which will return 5 minute
      # averages.
      collector = new MetricCollector 'test', ['test.metric'], new Date().addHours(-24)
      collector.metrics (error, dataSet) ->
        test.ifError error
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 2
        test.equals dataSet['test.metric'][0].value, 6
        test.equals dataSet['test.metric'][1].value, 2
        test.done()

  'calculate one hour averages': (test) ->

    base_date = new Date().addDays(-1).clearTime().addHours(10)

    avg1_date_1 = base_date.clone().addMinutes 30
    avg1_date_2 = base_date.clone().addMinutes 31
    avg2_date_1 = base_date.clone().addHours(1).addMinutes 31

    # Create three snapshots with different values and timestamps where half of
    # the values are in one average, the rest in another.
    TestHelper.createSimpleSnapshots [
      { timestamp: avg1_date_1, counter: 4 },
      { timestamp: avg1_date_2, counter: 8 },
      { timestamp: avg2_date_1, counter: 2 },
    ], (error, snapshots) ->
      test.ifError error

      # Ask for metrics for the last 2 days, which will return one hour
      # averages.
      collector = new MetricCollector 'test', ['test.metric'], new Date().addDays(-2)
      collector.metrics (error, dataSet) ->
        test.ifError error
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 2
        test.equals dataSet['test.metric'][0].value, 6
        test.equals dataSet['test.metric'][1].value, 2
        test.done()
   
   'calculate six hour averages': (test) ->

    base_date = new Date().addDays(-1).clearTime()

    avg1_date_1 = base_date.clone().addHours 3
    avg1_date_2 = base_date.clone().addHours 4
    avg2_date_1 = base_date.clone().addHours 8

    # Create three snapshots with different values and timestamps where half of
    # the values are in one average, the rest in another.
    TestHelper.createSimpleSnapshots [
      { timestamp: avg1_date_1, counter: 4 },
      { timestamp: avg1_date_2, counter: 8 },
      { timestamp: avg2_date_1, counter: 2 },
    ], (error, snapshots) ->
      test.ifError error

      # Ask for metrics for the last 5 days, which will return six hour
      # averages.
      collector = new MetricCollector 'test', ['test.metric'], new Date().addDays(-5)
      collector.metrics (error, dataSet) ->
        test.ifError error
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 2
        test.equals dataSet['test.metric'][0].value, 6
        test.equals dataSet['test.metric'][1].value, 2
        test.done()

   'calculate twelve hour averages': (test) ->

    base_date = new Date().addDays(-1).clearTime()

    avg1_date_1 = base_date.clone().addHours 3
    avg1_date_2 = base_date.clone().addHours 4
    avg2_date_1 = base_date.clone().addHours 15

    # Create three snapshots with different values and timestamps where half of
    # the values are in one average, the rest in another.
    TestHelper.createSimpleSnapshots [
      { timestamp: avg1_date_1, counter: 4 },
      { timestamp: avg1_date_2, counter: 8 },
      { timestamp: avg2_date_1, counter: 2 },
    ], (error, snapshots) ->
      test.ifError error

      # Ask for metrics for the last 15 days, which will return twelve hour
      # averages.
      collector = new MetricCollector 'test', ['test.metric'], new Date().addDays(-15)
      collector.metrics (error, dataSet) ->
        test.ifError error
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 2
        test.equals dataSet['test.metric'][0].value, 6
        test.equals dataSet['test.metric'][1].value, 2
        test.done()

   'calculate one day averages': (test) ->

    base_date = new Date().addDays(-2).clearTime()

    avg1_date_1 = base_date.clone().addHours 3
    avg1_date_2 = base_date.clone().addHours 4
    avg2_date_1 = base_date.clone().addDays(1).addHours 15

    # Create three snapshots with different values and timestamps where half of
    # the values are in one average, the rest in another.
    TestHelper.createSimpleSnapshots [
      { timestamp: avg1_date_1, counter: 4 },
      { timestamp: avg1_date_2, counter: 8 },
      { timestamp: avg2_date_1, counter: 2 },
    ], (error, snapshots) ->
      test.ifError error

      # Ask for metrics for the last 40 days, which will return one day
      # averages.
      collector = new MetricCollector 'test', ['test.metric'], new Date().addDays(-40)
      collector.metrics (error, dataSet) ->
        test.ifError error
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 2
        test.equals dataSet['test.metric'][0].value, 6
        test.equals dataSet['test.metric'][1].value, 2
        test.done()

   'calculate four day averages': (test) ->

    base_date = new Date().addDays(-5).clearTime()

    avg1_date_1 = base_date.clone().addHours 3
    avg1_date_2 = base_date.clone().addHours 4
    avg2_date_1 = base_date.clone().addDays(4).addHours 15

    # Create three snapshots with different values and timestamps where half of
    # the values are in one average, the rest in another.
    TestHelper.createSimpleSnapshots [
      { timestamp: avg1_date_1, counter: 4 },
      { timestamp: avg1_date_2, counter: 8 },
      { timestamp: avg2_date_1, counter: 2 },
    ], (error, snapshots) ->
      test.ifError error

      # Ask for metrics for the last 120 days, which will return twelve hour
      # averages.
      collector = new MetricCollector 'test', ['test.metric'], new Date().addDays(-40)
      collector.metrics (error, dataSet) ->
        test.ifError error
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 2
        test.equals dataSet['test.metric'][0].value, 6
        test.equals dataSet['test.metric'][1].value, 2
        test.done()

   'calculate one week averages': (test) ->

    base_date = new Date().addDays(-8).clearTime()

    avg1_date_1 = base_date.clone().addHours 3
    avg1_date_2 = base_date.clone().addHours 4
    avg2_date_1 = base_date.clone().addDays(7).addHours 15

    # Create three snapshots with different values and timestamps where half of
    # the values are in one average, the rest in another.
    TestHelper.createSimpleSnapshots [
      { timestamp: avg1_date_1, counter: 4 },
      { timestamp: avg1_date_2, counter: 8 },
      { timestamp: avg2_date_1, counter: 2 },
    ], (error, snapshots) ->
      test.ifError error

      # Ask for metrics for the last year, which will return one week averages.
      collector = new MetricCollector 'test', ['test.metric'], new Date().addYears(-1)
      collector.metrics (error, dataSet) ->
        test.ifError error
        test.equals _.keys(dataSet).length, 1
        test.equals dataSet['test.metric'].length, 2
        test.equals dataSet['test.metric'][0].value, 6
        test.equals dataSet['test.metric'][1].value, 2
        test.done()
