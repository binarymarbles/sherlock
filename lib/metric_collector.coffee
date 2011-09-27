require 'date-utils'
_ = require 'underscore'
async = require 'async'

mongoose = require 'mongoose'
Schema = mongoose.Schema

MetricMapReduce = require './metric_map_reduce'
Snapshot = require '../models/snapshot'
Metric = require '../models/metric'
MetricAvg1w = require '../models/metric_avg_1w'
MetricAvg1d = require '../models/metric_avg_1d'
MetricAvg1h = require '../models/metric_avg_1h'
MetricAvg5m = require '../models/metric_avg_5m'

# Collects metrics from the database for use in graphs.
class MetricCollector

  constructor: (node_id, paths, type, fromTime, toTime) ->

    @node_id = node_id
    @paths = paths

    # If the type attribute is an object, and fromTime is an object or blank,
    # and toTime is blank - no type was passed in. Shift the attributes one
    # place right and set type to be null.
    if typeof(type) == 'object' && (typeof(fromTime) == 'object' || !fromTime?) && !toTime?
      toTime = fromTime
      fromTime = type
      type = null

    @type = type || 'counter'

    # If no from/to time is specified, we default to the last 12 hours.
    @toTime = toTime || new Date()
    @fromTime = if fromTime?
      fromTime
    else
      @toTime.clone().addHours -12

    # Figure out the number of hours and the number of days between our from and
    # to time.
    @timespanInHours = @fromTime.getHoursBetween(@toTime)
    @timespanInDays = @fromTime.getDaysBetween(@toTime)

  # Build a data set of metrics matching the time period and node.
  metrics: (completedCallback) ->
    
    dataSet = {}

    # Build the path match group based on the graph keys.
    pathMatchers = []
    for path in @paths
      matcher = @queryMatcherForPath path
      pathMatchers.push matcher

    # Figure out what model to start the query from. This depends on the amount
    # of hours or days covered by the requested from and two date.
    metricModel = Metric

    if @timespanInDays >= 180 # If more than 6 months, return weekly averages.
      metricModel = MetricAvg1w
    else if @timespanInDays >= 90 # If more than 3 months, return daily averages
      metricModel = MetricAvg1d
    else if @timespanInDays >= 30 # If more than one month, return hourly averages.
      metricModel = MetricAvg1h
    else if @timespanInDays >= 1 # If more than 1 day, return 5 minute averages.
      metricModel = MetricAvg5m

    # Query for all the metrics requested.
    query = metricModel.find
      '$or': pathMatchers

    query = query.where('node_id', @node_id)
    query = query.where('timestamp').gte(@fromTime)
    query = query.where('timestamp').lte(@toTime)

    query.run (error, metrics) =>
      if error?
        completedCallback error
      else

        # Build a data set from the results.
        dataSet = @buildDataSet metrics
        completedCallback null, dataSet

  # Build a Mongoose OR-query matcher for the specified metric path.
  queryMatcherForPath: (path) ->
    if path.indexOf('*') > -1

      quotedPath = path.replace '.', '\\.'
      quotedPath = quotedPath.replace '*', '.*?'

      regex = new RegExp("^#{quotedPath}$")
      return { path: regex }
      # return {path: { '$regex': regex }}

    else
      return { path: path }

  # Build a metric data set based on the collection of metric objects.
  buildDataSet: (metrics) ->
    dataSet = {}

    previousCounter = null
    for metric in metrics

      path = metric.path
      timestamp = metric.timestamp
      originalCounter = metric.counter

      # If this is a incremental graph, calculate the difference between
      # previousCounter and counter and use that as the value. If we have no
      # previous counter, use 0.
      if @type == 'incremental'
        if previousCounter == null
          counter = 0
        else

          counter = originalCounter - previousCounter

          # If we get a negative value after calculating the incremental value,
          # the counter has been reset and we should handle this properly. Here,
          # we return the original counter value and start off at 0.
          if counter < 0
            counter = originalCounter

      else
        counter = originalCounter

      previousCounter = originalCounter

      dataSet[path] ||= []
      dataSet[path].push
        timestamp: timestamp
        value: counter

    dataSet

module.exports = MetricCollector
