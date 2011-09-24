require 'date-utils'
async = require 'async'
mongoose = require 'mongoose'
connection = require '../lib/db_connection'

Snapshot = require '../models/snapshot'
Process = require '../models/process'
MetricLabel = require '../models/metric_label'
Metric = require '../models/metric'

class TestDataSeeder

  constructor: (nodeId) ->
    @nodeId = nodeId

  # Reset all existing collections
  resetCollections: (callback) ->
    async.parallel [
        (callback) ->
          Snapshot.collection.remove callback
      , (callback) ->
          Process.collection.remove callback
      , (callback) ->
          MetricLabel.collection.remove callback
      , (callback) ->
          Metric.collection.remove callback
    ], (error, results) ->
      callback(error, results)

  # Seed the database with some test data.
  seed: (completedCallback) ->

    snapshotTime = new Date().addDays -1
    endTime = new Date()
    
    @resetCollections (error, results) =>

      if error?
        throw new "Unable to reset collections: #{error.message}"

      # Build an array of dates to store snapshots for.
      snapshotTimestamps = []
      while snapshotTime.valueOf() < endTime.valueOf() + (60 * 1000)
        snapshotTimestamps.push snapshotTime.clone()
        snapshotTime.setTime snapshotTime.valueOf() + (60 * 1000)

      eachCallback = (timestamp, callback) =>
        @seedForTimestamp timestamp, callback

      async.forEach snapshotTimestamps, eachCallback, (error) =>
        console.log 'Done seeding data!'
        completedCallback()

  seedForTimestamp: (timestamp, completedCallback) ->

    models = []

    snapshot = new Snapshot
      node_id: @nodeId
      timestamp:  timestamp
    models.push snapshot

    # Seed processes.
    processCount = Math.floor(Math.random() * 50) + 1
    for i in [1..processCount]
      models.push @seedProcess(timestamp, snapshot)

    # Seed labels.
    models = models.concat @seedLabels(timestamp, snapshot)

    # Seed metrics.
    models = models.concat @seedMetrics(timestamp, snapshot)

    # In parallel, persist all our models.
    persistCallback = (model, callback) ->
      model.save (error) ->
        if error?
          console.log 'Saving', model, 'failed:', error.message
        callback()
    async.forEach models, persistCallback, (error) ->
      console.log 'Done persisting', models.length, 'models'
      completedCallback()

  seedProcess: (timestamp, snapshot) ->
    randomUsernames = ['root', 'nobody', 'httpd']
    randomTtys = ['?', 'tty1', 'tty2', 'tty3']
    randomStates = ['S','Sl', 'Ss', 'S<s', 'S+']
    randomCommands = ['httpd', '-bash', 'SCREEN', 'sshd', 'portmap', 'ntpd']

    process = new Process
      snapshot: snapshot.id
      timestamp: timestamp
      user: randomUsernames[Math.floor(Math.random() * randomUsernames.length)]
      pid: Math.floor(Math.random() * 10000) + 1
      cpu_usage: Math.floor(Math.random() * 100)
      memory_usage: Math.floor(Math.random() * 100)
      virtual_memory_size: Math.floor(Math.random() * 10000)
      residential_set_size: Math.floor(Math.random() * 10000)
      tty: randomTtys[Math.floor(Math.random() * randomTtys.length)]
      state: randomStates[Math.floor(Math.random() * randomStates.length)]
      started_at: new Date().addDays(Math.floor(Math.random() * 10))
      cpu_time: '0:00'
      command: randomCommands[Math.floor(Math.random() * randomCommands.length)]
    process

  seedLabels: (timestamp, snapshot) ->

    labelModels = []

    eth0Label = new MetricLabel
      snapshot: snapshot.id
      node_id: snapshot.node_id
      timestamp: snapshot.timestamp
      path: 'network_interfaces.eth0.labels.ipv4_address'
      value: '10.0.0.1'
    labelModels.push eth0Label

    eth1Label = new MetricLabel
      snapshot: snapshot.id
      node_id: snapshot.node_id
      timestamp: snapshot.timestamp
      path: 'network_interfaces.eth1.labels.ipv4_address'
      value: '192.168.0.1'
    labelModels.push eth1Label

    labelModels

  seedMetrics: (timestamp, snapshot) ->

    metricModels = []

    loadAverage = new Metric
      snapshot: snapshot.id
      node_id: snapshot.node_id
      timestamp: snapshot.timestamp
      path: 'load.average'
      counter: Math.random().toFixed 2
    metricModels.push loadAverage

    eth0RxBytes = new Metric
      snapshot: snapshot.id
      node_id: snapshot.node_id
      timestamp: snapshot.timestamp
      path: 'network_interfaces.eth0.bytes.rx'
      counter: timestamp.valueOf()
    metricModels.push eth0RxBytes

    eth0TxBytes = new Metric
      snapshot: snapshot.id
      node_id: snapshot.node_id
      timestamp: snapshot.timestamp
      path: 'network_interfaces.eth0.bytes.tx'
      counter: timestamp.valueOf() / 2
    metricModels.push eth0TxBytes

    eth1RxBytes = new Metric
      snapshot: snapshot.id
      node_id: snapshot.node_id
      timestamp: snapshot.timestamp
      path: 'network_interfaces.eth1.bytes.rx'
      counter: timestamp.valueOf() * 3
    metricModels.push eth1RxBytes

    eth1TxBytes = new Metric
      snapshot: snapshot.id
      node_id: snapshot.node_id
      timestamp: snapshot.timestamp
      path: 'network_interfaces.eth1.bytes.tx'
      counter: timestamp.valueOf() * 2
    metricModels.push eth1TxBytes

    metricModels

nodeId = process.argv[2]
throw new Error "Usage: generate-test-data.coffee <node id>" unless nodeId?
new TestDataSeeder(nodeId).seed ->
  process.nextTick ->
    mongoose.disconnect()
