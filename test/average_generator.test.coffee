testCase = (require 'nodeunit').testCase
_ = require 'underscore'
TestHelper = require './test_helper'

AverageGenerator = require '../lib/average_generator'
MetricCollector = require '../lib/metric_collector'

module.exports = testCase
  setUp: (callback) ->
    TestHelper.connectToDatabase()
    TestHelper.resetCollections ->
      callback()

  tearDown: (callback) ->
    TestHelper.disconnectFromDatabase callback

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
      test.ok !error?

      # Calculate the averages for the two five minute periods.
      averageGenerator = new AverageGenerator avg1_date_2
      averageGenerator.calculateAllAverages (error) ->
        test.ok !error?

        averageGenerator = new AverageGenerator avg2_date_2
        averageGenerator.calculateAllAverages (error) ->
          test.ok !error?
      
          # Ask for metrics for the last 24 hours, which will return 5 minute
          # averages.
          collector = new MetricCollector 'test', ['test.metric'], new Date().addHours(-24)
          collector.metrics (error, dataSet) ->
            test.ok !error?
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
      test.ok !error?

      # Calculate the averages for the two one hour periods.
      averageGenerator = new AverageGenerator avg1_date_2
      averageGenerator.calculateAllAverages (error) ->
        test.ok !error?

        averageGenerator = new AverageGenerator avg2_date_1
        averageGenerator.calculateAllAverages (error) ->
          test.ok !error?

          # Ask for metrics for the last 40 days, which will return one hour
          # averages.
          collector = new MetricCollector 'test', ['test.metric'], new Date().addDays(-40)
          collector.metrics (error, dataSet) ->
            test.ok !error?
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
      test.ok !error?

      # Calculate the averages for the two one day periods.
      averageGenerator = new AverageGenerator avg1_date_2
      averageGenerator.calculateAllAverages (error) ->
        test.ok !error?

        averageGenerator = new AverageGenerator avg2_date_1
        averageGenerator.calculateAllAverages (error) ->
          test.ok !error?

          # Ask for metrics for the last 100 days, which will return one day
          # averages.
          collector = new MetricCollector 'test', ['test.metric'], new Date().addDays(-100)
          collector.metrics (error, dataSet) ->
            test.ok !error?
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
      test.ok !error?

      # Calculate the averages for the two one hour periods.
      averageGenerator = new AverageGenerator avg1_date_2
      averageGenerator.calculateAllAverages (error) ->
        test.ok !error?

        averageGenerator = new AverageGenerator avg2_date_1
        averageGenerator.calculateAllAverages (error) ->
          test.ok !error?
      
          # Ask for metrics for the 200 days, which will return one week averages.
          collector = new MetricCollector 'test', ['test.metric'], new Date().addDays(-200)
          collector.metrics (error, dataSet) ->
            test.ok !error?
            test.equals _.keys(dataSet).length, 1
            test.equals dataSet['test.metric'].length, 2
            test.equals dataSet['test.metric'][0].value, 6
            test.equals dataSet['test.metric'][1].value, 2
            test.done()

  'calculate averages separately for each node': (test) ->

    base_date = new Date().clearTime().addHours(3)

    avg1_date_1 = base_date.clone().addMinutes 5
    avg1_date_2 = base_date.clone().addMinutes 6
    avg2_date_1 = base_date.clone().addMinutes 10

    # Create three snapshots with different values and timestamps where half of
    # the values are in one average, the rest in another.
    TestHelper.createSimpleSnapshots [
      { timestamp: avg1_date_1, counter: 4 },
      { timestamp: avg1_date_2, counter: 8, node_id: 'test2' },
      { timestamp: avg2_date_1, counter: 2 },
    ], (error, snapshots) ->
      test.ok !error?

      # Calculate the averages for the two five minute periods.
      averageGenerator = new AverageGenerator avg1_date_2
      averageGenerator.calculateAllAverages (error) ->
        test.ok !error?

        averageGenerator = new AverageGenerator avg2_date_1
        averageGenerator.calculateAllAverages (error) ->
          test.ok !error?
      
          collector = new MetricCollector 'test', ['test.metric'], new Date().addHours(-24)
          collector.metrics (error, dataSet) ->
            test.ok !error?
            test.equals _.keys(dataSet).length, 1
            test.equals dataSet['test.metric'].length, 2
            test.equals dataSet['test.metric'][0].value, 4
            test.equals dataSet['test.metric'][1].value, 2

            collector = new MetricCollector 'test2', ['test.metric'], new Date().addHours(-24)
            collector.metrics (error, dataSet) ->
              test.ok !error?
              test.equals _.keys(dataSet).length, 1
              test.equals dataSet['test.metric'].length, 1
              test.equals dataSet['test.metric'][0].value, 8
              test.done()
