_ = require 'underscore'
async = require 'async'
mongoose = require 'mongoose'

config = (require './config').load()

Snapshot = (require './models/snapshot')
Process = (require './models/process')
MetricLabel = (require './models/metric_label')
Metric = (require './models/metric')

class SnapshotParser

  constructor: (rawJson, callback) ->

    callback = callback || (error) ->

    # Parse the JSON.
    try
      @json = JSON.parse(rawJson)
    catch error
      callback error
      return

    # Validate the JSON data.
    try
      @validateJson()
    catch error
      callback error
      return

    # Flatten the metric data and extract metric labels.
    @flattenData()
    @extractLabels()

    # Store the snapshot and call our callback when its complete.
    @storeSnapshot callback

  # Validate the contents of the JSON data structure.
  validateJson: ->

    # We require that a node has been set, and that the node is registered in
    # the node registry.
    throw new Error 'Missing node element in payload' unless @json.node?
    throw new Error 'Unregistered node in payload' unless (config.nodeById @json.node)?

    # We require an agent version in the data. For now we only support agent
    # version 1.0.0.
    throw new Error 'Missing agent version element in payload' unless @json.agent_version?
    throw new Error 'Unknown agent version in payload' unless @json.agent_version == '1.0.0'

    # We require that we have at least one process in the process list.
    throw new Error 'Missing processes element in payload' unless @json.processes?
    throw new Error 'Invalid processes element in payload' unless _.isArray(@json.processes) && @json.processes.length > 0

    # We require that the data has a "data" hash.
    throw new Error 'Missing data element in payload' unless @json.data?

  # Extract all keys from the data hash in the JSON data structure and store it
  # as an array where each element contains a hash with the keys "key" (an array
  # of each keys identifying the path of the value) and "value" (the value of
  # the path).
  #
  # Example:
  # [
  #   {
  #     key: ['path', 'to', 'value'],
  #     value: 14
  #   },
  #   {
  #     key: ['path', 'to', 'other', 'value'],
  #     value: 0
  #   }
  # ]
  flattenData: ->
    @data = []

    walk = (prefixKeys, obj) =>
      for property of obj
        value = obj[property]
        if typeof value == 'object'

          newPrefix = _.clone prefixKeys
          newPrefix.push property
          walk newPrefix, value

        else

          keys = _.clone prefixKeys
          keys.push property
          @data.push
            key: keys
            value: value

    walk [], @json.data

  # Extract labels from the data array and place them in its own array.
  # Find the label information from the @data list and add them to the @label
  # array, while removing all label information from the @data list.
  extractLabels: ->
    @labels = []

    # Holds a list of index positions in the @data array where labels are
    # stored, since we need to remove them after we're done processing them.
    labelIndexes = []
    for dataIndex in [0 .. @data.length - 1]

      key = @data[dataIndex].key
      value = @data[dataIndex].value

      if _.include key, 'labels'

        labelIndexes.push dataIndex

        @labels.push
          key: key
          value: value

    # Remove the identified label indexes from the data array.
    for labelIndex in labelIndexes.reverse()
      @data.splice labelIndex, 1

  # Store the snapshot data in the database.
  storeSnapshot: (callback) ->

    callback = callback || ->

    @writeSnapshot (error, snapshot) =>

      if error?
        callback error
      else

        @snapshot = snapshot

        # Store all snapshot meta data in parallel.
        async.parallel [

          # Store all the processes.
          (callback) =>
            @writeProcesses callback
          ,

          # Store all the labels.
          (callback) =>
            @writeLabels callback
          ,

          # Store all the metrics.
          (callback) =>
            @writeMetrics callback

        ], (err, result) =>
          callback err, @snapshot

  # Create a snapshot instance for the JSON data.
  writeSnapshot: (callback) ->
    snapshot = new Snapshot
      node_id: @json.node
      timestamp: new Date()
    snapshot.save (error) ->
      callback error, snapshot

  # Write the process list to the snapshot instance for the JSON data.
  writeProcesses: (callback) ->

    processModels = []
    for processInfo in @json.processes

      process = new Process
        snapshot: @snapshot.id
        snapshot_timestamp: @snapshot.timestamp
        user: processInfo.user
        pid: processInfo.pid
        cpu_usage: processInfo.cpu
        memory_usage: processInfo.memory
        virtual_memory_size: processInfo.virtual_memory_size
        residental_set_size: processInfo.residental_set_size
        tty: processInfo.tty
        state: processInfo.state
        started_at: new Date(processInfo.started_at)
        cpu_time: processInfo.cpu_time
        command: processInfo.command
      processModels.push process

    # Save all the process models in parallel.
    async.forEach processModels,
      (processModel, modelCallback) ->
        processModel.save modelCallback
      ,
      (error) ->
        callback error, processModels

  # Write the labels to the snapshot instance.
  writeLabels: (callback) ->

    labelModels = []
    for label in @labels

        labelModel = new MetricLabel
          snapshot: @snapshot.id
          snapshot_timestamp: @snapshot.timestamp
          # path: label.key
          path: label.key.join '.'
          value: label.value
        labelModels.push labelModel

    # Save all the label models in parallel.
    async.forEach labelModels,
      (labelModel, modelCallback) ->
        labelModel.save modelCallback
      ,
      (error) ->
        callback error, labelModels

  # Write the metrics found in the JSON data structure.
  writeMetrics: (callback) ->

    metricModels = []
    for element in @data

      metric = new Metric
        snapshot: @snapshot.id
        snapshot_timestamp: @snapshot.timestamp
        # path: element.key
        path: element.key.join '.'
        counter: element.value
      metricModels.push metric

    # Save all the metric models in parallel.
    async.forEach metricModels,
      (metricModel, modelCallback) ->
        metricModel.save modelCallback
      ,
      (error) ->
        callback error, metricModels

module.exports = SnapshotParser
