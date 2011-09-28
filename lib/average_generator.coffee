async = require 'async'
mongoose = require 'mongoose'

BenchmarkTimer = require './benchmark_timer'

Metric = require '../models/metric'
MetricAvg5m = require '../models/metric_avg_5m'
MetricAvg1h = require '../models/metric_avg_1h'
MetricAvg1d = require '../models/metric_avg_1d'
MetricAvg1w = require '../models/metric_avg_1w'

# Generates metric averages for the specified node.
class AverageGenerator

  constructor: (endTime) ->
    @endTime = endTime || new Date()

    # Strip off seconds and milliseconds on the end time since that's not
    # interesting data.
    @endTime.setSeconds 0
    @endTime.setMilliseconds 0

  # Calculate all types of averages.
  calculateAllAverages: (completedCallback) ->

    totalTimer = new BenchmarkTimer 'calculating all averages'
    async.series [
        (callback) =>
          timer = new BenchmarkTimer 'calculate five minute averages'
          @calculateFiveMinuteAverages (error, results) ->
            timer.end()
            callback error, results
      , (callback) =>
          timer = new BenchmarkTimer 'calculate one hour averages'
          @calculateOneHourAverages (error, results) ->
            timer.end()
            callback error, results
      , (callback) =>
          timer = new BenchmarkTimer 'calculate one day averages'
          @calculateOneDayAverages (error, results) ->
            timer.end()
            callback error, results
      , (callback) =>
          timer = new BenchmarkTimer 'calculate one week averages'
          @calculateOneWeekAverages (error, results) ->
            timer.end()
            callback error, results
    ], (error, results) ->
      totalTimer.end()
      completedCallback error, results

  # Build a set of averages using MongoDBs aggregation functionality, and
  # persist a new set of aggregated data.
  buildAverages: (targetModel, startTime, completedCallback) ->

    # Define the map function to use.
    map = ->
      emit { path: @path, node_id: @node_id },
        count: 1
        counter: @counter

    # Define the reduce function to use.
    reduce = (key, data) ->
      result =
        count: 0
        counter: 0

      data.forEach (value) ->
        result.count += 1
        result.counter += value.counter

      result

    # Define the finalize function to use.
    finalize = (path, data) ->
      if data.count > 1
        data.counter = data.counter / data.count
      data

    # Prepare the mapreduce command.
    command =
      mapreduce: Metric.collection.name
      query:
        timestamp:
          '$gte': startTime
          '$lte': @endTime
      map: map.toString()
      reduce: reduce.toString()
      finalize: finalize.toString()
      out:
        inline: 1

    # Run the mapreduce command.
    mongoose.connection.db.executeDbCommand command, (error, dbResults) =>
      if error?
        completedCallback error
      else

        results = dbResults.documents[0].results

        # Don't do anything if we had no results - if the operation returned a
        # blank array, there was no data within the defined time frame.
        if results.length == 0
          completedCallback null
        else

          # Iterate through all results and persist a target model for each.
          targetModels = []
          for result in results

            targetModels.push new targetModel
              node_id: result._id.node_id
              timestamp: startTime
              path: result._id.path
              counter: result.value.counter
          
          timer = new BenchmarkTimer 'persisting average models'
          async.forEach targetModels,
            (model, callback) =>

              # Persist the target model using an upsert.

              targetConditions =
                node_id: model.node_id
                path: model.path
                timestamp: model.timestamp

              targetAttributes =
                counter: model.counter

              targetModel.update targetConditions, targetAttributes, { upsert: true }, callback
            ,
            (error) ->
              timer.end()
              completedCallback error

  # Calculate five minute averages for the current node. These averages are
  # based on the raw metrics.
  calculateFiveMinuteAverages: (completedCallback) ->

    # Calculate the timestamp of the most recent 5 minute average.
    timestamp = @endTime.clone()
    timestamp.setMinutes 5 * Math.floor(timestamp.getMinutes() / 5)
    
    @buildAverages MetricAvg5m, timestamp, completedCallback

  # Calculate the one hour averages for the current node. These averages are
  # based on the 5 minute metric averages.
  calculateOneHourAverages: (completedCallback) ->

    # Calculate the timestamp of the most recent one hour average.
    timestamp = @endTime.clone()
    timestamp.setMinutes 0

    @buildAverages MetricAvg1h, timestamp, completedCallback

  # Calculate the one day averages for the current node. These averages are
  # based on the one hour metric averages.
  calculateOneDayAverages: (completedCallback) ->

    # Calculate the timestamp of the most recent one day average.
    timestamp = @endTime.clone()
    timestamp.setHours 0
    timestamp.setMinutes 0

    @buildAverages MetricAvg1d, timestamp, completedCallback

  # Calculate the one week averages for the current node. These averages are
  # based on the one day metric averages.
  calculateOneWeekAverages: (completedCallback) ->

    # Calculate the timestamp of the most recent one week average.
    timestamp = @endTime.clone()
    firstDayOfYear = new Date timestamp.getFullYear(), 0, 0, 0, 0, 0
    
    firstDayTime = Math.floor firstDayOfYear.valueOf() / 86400000
    timestampTime = Math.ceil timestamp.valueOf() / 86400000
    timestampDayOfYear = timestampTime - firstDayTime

    averageDayOfYear = (7 * Math.floor(timestampDayOfYear / 7))
    offset = averageDayOfYear - timestampDayOfYear

    timestamp.setDate timestamp.getDate() + offset
    timestamp.setHours 0
    timestamp.setMinutes 0

    @buildAverages MetricAvg1w, timestamp, completedCallback

module.exports = AverageGenerator
