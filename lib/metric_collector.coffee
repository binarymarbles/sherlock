_ = require 'underscore'
async = require 'async'
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

      # Define the callback function for async.foreach
      forEachCallback = (key, callback) =>
        @findMetricsForKey snapshots, key, (error, metrics) ->
          console.log 'Found metrics', metrics, 'for key', key, 'and snapshots', snapshots
          callback()

      # Find metrics for all keys.
      async.forEach @graph.keys, forEachCallback, (error) =>
        console.log 'Completed fetching metrics for', @graph.keys, ':', dataSet
        console.log 'Error is:', error
        completedCallback()

  # Find all snapshot IDs for the requested time period matching the specified
  # node.
  findSnapshots: (callback) ->
    query = Snapshot.find {'node_id': @node.id}
    query = query.select ['id', 'timestamp']
    query = query.where('timestamp').gte(@fromTime)
    query = query.where('timestamp').lte(@toTime)
    query.run (error, docs) ->
      callback docs

  # Find the metrics for the specified key within the collection of snapshots.
  findMetricsForKey: (snapshots, key, callback) ->

    keyFragments = key.split '.'
    query = Metric.find()
    query = query.where('snapshot').in _.pluck snapshots, 'id'
    query = query.where('key', keyFragments)
    query.run (error, docs) ->
      console.log 'Found metrics for key', key, ', error=', error, ', docs=', docs
      callback()

module.exports = MetricCollector
