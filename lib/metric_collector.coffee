_ = require 'underscore'
async = require 'async'
mongoose = require 'mongoose'
Snapshot = require '../lib/models/snapshot'
Metric = require '../lib/models/metric'

# Collects metrics from the database for use in graphs.
class MetricCollector

  constructor: (node, graph, fromTime, toTime) ->

    @node = node
    @graph = graph

    @toTime = fromTime || new Date()

    @fromTime = if fromTime?
      fromTime
    else
      d = new Date(@toTime.getTime())
      d.setDate d.getDate() - 6
      d

  # Build a data set of metrics matching the time period and node.
  metrics: (completedCallback) ->

    # Find all snapshots from our time period.
    @findSnapshots (snapshots) =>

      dataSet = {}

      # Build the path match group based on the graph keys.
      pathMatchers = []
      for path in @graph.keys
        matcher = @queryMatcherForPath path
        pathMatchers.push matcher

      # Build a Mongoose query to fetch all the relevant metrics, sorted by
      # the snapshot timestamp ascending.
      query = Metric.find
        snapshot:
          '$in': _.pluck snapshots, 'id'
        '$or': pathMatchers
      query = query.asc('snapshot_timestamp')
      query.run (error, metrics) =>
        if error?
          completedCallback error

        else
          dataSet = @buildDataSet metrics
          completedCallback null, dataSet

  # Find all snapshot IDs for the requested time period matching the specified
  # node.
  findSnapshots: (callback) ->
    query = Snapshot.find {'node_id': @node.id}
    query = query.select ['id', 'timestamp']
    query = query.where('timestamp').gte(@fromTime)
    query = query.where('timestamp').lte(@toTime)
    query.run (error, docs) ->
      callback docs

  # Build a Mongoose OR-query matcher for the specified metric path.
  queryMatcherForPath: (path) ->
    if path.indexOf('*') > -1
      quotedPath = path.replace '.', '\\.'
      quotedPath = quotedPath.replace '*', '.*?'
      matcher = new RegExp("^#{quotedPath}$")
    else
      matcher = path

    { path: matcher }

  # Build a metric data set based on the collection of metric objects.
  buildDataSet: (metrics) ->
    dataSet = {}

    for metric in metrics

      path = metric.path
      timestamp = metric.snapshot_timestamp
      counter = metric.counter

      dataSet[path] ||= []
      dataSet[path].push
        timestamp: timestamp
        value: counter

    dataSet

module.exports = MetricCollector
