async = require 'async'
mongoose = require 'mongoose'
connection = require './lib/db_connection'

Snapshot = require './lib/models/snapshot'
Process = require './lib/models/process'
MetricLabel = require './lib/models/metric_label'
Metric = require './lib/models/metric'

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

  console.log 'Collections are reset.'
  mongoose.disconnect()
