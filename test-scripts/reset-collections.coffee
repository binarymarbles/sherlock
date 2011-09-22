async = require 'async'
mongoose = require 'mongoose'
connection = require '../lib/db_connection'

Snapshot = require '../models/snapshot'
Process = require '../models/process'
MetricLabel = require '../models/metric_label'
Metric = require '../models/metric'

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
  process.nextTick ->
    mongoose.disconnect()
