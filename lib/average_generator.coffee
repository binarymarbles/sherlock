async = require 'async'
mongoose = require 'mongoose'

Metric = require '../models/metric'
MetricAvg5m = require '../models/metric_avg_5m'
MetricAvg1h = require '../models/metric_avg_1h'
MetricAvg1d = require '../models/metric_avg_1d'
MetricAvg1w = require '../models/metric_avg_1w'

# Generates metric averages for the specified node.
class AverageGenerator

  constructor: (node_id, endTime) ->
    @node_id = node_id
    @endTime = endTime || new Date()

    # Strip off seconds and milliseconds on the end time since that's not
    # interesting data.
    @endTime.setSeconds 0
    @endTime.setMilliseconds 0

  # Calculate all types of averages.
  calculateAllAverages: (completedCallback) ->

    async.series [
        (callback) =>
          @calculateFiveMinuteAverages callback
      , (callback) =>
          @calculateOneHourAverages callback
      , (callback) =>
          @calculateOneDayAverages callback
      , (callback) =>
          @calculateOneWeekAverages callback
    ], (error, results) ->
      completedCallback error, results

  # Build a set of averages using MongoDBs aggregation functionality, and
  # persist a new set of aggregated data.
  buildAverages: (targetModel, startTime, completedCallback) ->

    # Prepare the conditions for the group query.
    conditions =
      node_id: @node_id
      timestamp:
        '$gte': startTime
        '$lte': @endTime

    # Set the initial value of the aggregation counter.
    initialValue =
      total: 0
      count: 0

    # Define the reduce function to use.
    reduce = (doc, out) ->
      out.count++
      out.total += doc.counter
      out.path = doc.path

    # Execute the query.
    Metric.collection.group ['node_id, path'], conditions, initialValue, reduce.toString(), (error, results) =>

      if error?
        completedCallback error
      else

        # Don't do anything if we had no results - if the group query returned
        # a blank array, there was no data within the defined time frame.
        if results.length == 0
          completedCallback null
        else

          # Iterate through all results and persist a target model for each.
          targetModels = []
          for result in results

            average = result.total / result.count
            targetModels.push new targetModel
              node_id: @node_id
              timestamp: startTime
              path: result.path
              counter: average

          async.forEach targetModels,
            (model, callback) =>

              # Persist the target model using an upsert.

              targetConditions =
                node_id: @node_id
                timestamp: model.timestamp
                path: model.path

              targetAttributes =
                counter: model.counter

              targetModel.update targetConditions, targetAttributes, { upsert: true }, callback

            ,
            (error) ->
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
