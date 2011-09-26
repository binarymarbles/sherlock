async = require 'async'
mongoose = require 'mongoose'
_ = require 'underscore'
require 'date-utils'

configModule = require '../lib/config'

Snapshot = require '../models/snapshot'
Process = require '../models/process'
MetricLabel = require '../models/metric_label'
Metric = require '../models/metric'

class TestHelper

  # Connect to the MongoDB test database.
  @connectToDatabase: ->
    mongoose.connect 'mongodb://localhost/sherlock_test'

  # Disconnect from the MongoDB test database.
  @disconnectFromDatabase: (callback) ->
    process.nextTick ->
      mongoose.disconnect ->
        callback()

  # Reset all MongoDB collections.
  @resetCollections: (callback) ->
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
      callback err, results

  # Build a snapshot with a set of metrics. The metrics attribute is an array
  # of hashes containing the following data structure:
  #
  # [
  #   {path: 'load.average', counter: 1.4}
  # ]
  @createSnapshot: (node_id, timestamp, metrics, callback) ->
    models = []

    # Set some defaults.
    node_id ||= 'test'
    timestamp ||= new Date()

    # Create the snapshot.
    snapshot = new Snapshot
      node_id: node_id
      timestamp: timestamp
    models.push snapshot

    # Create the metrics.
    for metric in metrics
      models.push new Metric
        snapshot: snapshot.id
        node_id: node_id
        timestamp: timestamp
        path: metric.path
        counter: metric.counter

    # Save the models and call the callback when its done.
    async.forEach models,
      (model, modelCallback) ->
        model.save (errors) ->
          modelCallback errors
      ,
      (error) ->
        callback error, snapshot

  # Build snapshots, each containing a set of metrics.
  @createSnapshots: (snapshots, callback) ->
    snapshotModels = []

    async.forEach snapshots,
      (snapshotDefinition, snapshotCallback) ->
        node_id = snapshotDefinition.node_id
        timestamp = snapshotDefinition.timestamp
        metrics = snapshotDefinition.metrics
        TestHelper.createSnapshot node_id, timestamp, metrics, (error, snapshot) ->
          snapshotModels.push snapshot
          snapshotCallback error, snapshot
      ,
      (error) ->
        callback error, snapshotModels

  # Create a simple collection of snapshot. This function is a wrapper around
  # @createSnapshot, but requires less arguments and has more default values for
  # simplicity.
  @createSimpleSnapshots: (snapshots, callback) ->

    snapshotDefinitions = []

    # Make sure each snapshot ends up one minute apart.
    minuteOffset = (snapshots.length - 1) * -1

    for snapshot in snapshots

      node_id = snapshot.node_id || 'test'
      timestamp = snapshot.timestamp || new Date().addMinutes minuteOffset
      path = snapshot.path || 'test.metric'
      counter = snapshot.counter || 1

      snapshotDefinitions.push
        node_id: node_id
        timestamp: timestamp
        metrics: [ { path: path, counter: counter } ]

      minuteOffset++

    TestHelper.createSnapshots snapshotDefinitions, callback

configModule.setConfigDirectory './test/config'
module.exports = TestHelper
