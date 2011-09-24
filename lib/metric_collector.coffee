require 'date-utils'
_ = require 'underscore'
async = require 'async'

mongoose = require 'mongoose'
Schema = mongoose.Schema

MetricMapReduce = require './metric_map_reduce'
Snapshot = require '../models/snapshot'
Metric = require '../models/metric'

# Collects metrics from the database for use in graphs.
class MetricCollector

  constructor: (node, graph, fromTime, toTime) ->

    @node = node
    @graph = graph

    # If no from/to time is specified, we default to the last 24 hours.
    @toTime = fromTime || new Date()
    @fromTime = if fromTime?
      fromTime
    else
      @toTime.clone().addDays -1 # 

    # Figure out the number of hours and the number of days between our from and
    # to time.
    @timespanInHours = @fromTime.getHoursBetween(@toTime)
    @timespanInDays = @fromTime.getDaysBetween(@toTime)

  # Build a data set of metrics matching the time period and node.
  metrics: (completedCallback) ->

    dataSet = {}

    # Build the path match group based on the graph keys.
    pathMatchers = []
    for path in @graph.keys
      matcher = @queryMatcherForPath path
      pathMatchers.push matcher

    # Figure out what map function to use in the mapreduce operation.
    if @timespanInHours <= 12
      mapFunction = MetricMapReduce.rawMapFunction.toString()
    else if @timespanInHours <= 24
      mapFunction = MetricMapReduce.fiveMinuteAverageMapFunction.toString()
    else
      mapFunction = MetricMapReduce.mapFunctionForTimespan(@timespanInDays).toString()

    # Figure out what reduce function to use in the mapreduce operation.
    reduceFunction = MetricMapReduce.reduceFunction.toString()

    # Figure out what finalize function to use in the mapreduce operation.
    finalizeFunction = MetricMapReduce.finalizeFunction.toString()

    # Define the collection name that should be used to store the results.
    collectionName = _.uniqueId 'tmp.metric_collector_results.'

    # Build a Mongoose mapreduce command to fetch all the relevant metrics and
    # smooth out the data set with averages - depending on the timespan
    # between the from and to date.
    command =
      mapreduce: 'metrics'
      query:
        node_id: @node.id
        timestamp:
          '$gte': @fromTime
          '$lte': @toTime
        '$or': pathMatchers

      map: mapFunction
      reduce: reduceFunction
      finalize: finalizeFunction

      out:
        replace: collectionName

    # Execute the mapreduce command.
    mongoose.connection.db.executeDbCommand command, (error, dbResults) =>

      # If we failed, break out now.
      if error?
        completedCallback error

      else

        # Define a temporary model to read data from the mapreduce collection.
        mapReduceSchema = new Schema { value: {} }, { collection: collectionName }
        MapReduceModel = mongoose.model collectionName, mapReduceSchema
        MapReduceModel.find().asc('value.timestamp').run (error, docs) =>

          if error?
            completedCallback error
          else

            # Build a data set from the results.
            dataSet = @buildDataSet docs

            # Remove the temporary collection we used.
            MapReduceModel.collection.drop =>
              completedCallback null, dataSet

  # Build a Mongoose OR-query matcher for the specified metric path.
  queryMatcherForPath: (path) ->
    if path.indexOf('*') > -1

      quotedPath = path.replace '.', '\\.'
      quotedPath = quotedPath.replace '*', '.*?'

      regex = new RegExp("^#{quotedPath}$")
      return {path: { '$regex': regex }}

    else
      return {path: path}

  # Build a metric data set based on the collection of metric objects.
  buildDataSet: (metrics) ->
    dataSet = {}

    for metric in metrics

      path = metric.value.path
      timestamp = metric.value.timestamp
      counter = metric.value.counter

      dataSet[path] ||= []
      dataSet[path].push
        timestamp: timestamp
        value: counter

    dataSet

module.exports = MetricCollector
