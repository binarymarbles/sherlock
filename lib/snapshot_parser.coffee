_ = require 'underscore'
mongoose = require 'mongoose'

config = (require './config').load()

Snapshot = (require './models/snapshot')
Process = (require './models/process')
MetricLabel = (require './models/metric_label')
Metric = (require './models/metric')

class SnapshotParser

  constructor: (rawJson) ->
    @json = JSON.parse(rawJson)
    @validateJson()
    @flattenData()

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

  # Store the snapshot data in the database.
  storeSnapshot: ->
    @snapshot = @writeSnapshot()

    # Store all the processes
    @writeProcesses()

    # Extract and store all the labels in the JSON structure.
    @extractAndWriteLabels()

    # Write the metrics found in the JSON structure.
    @writeMetrics()

  # Create a snapshot instance for the JSON data.
  writeSnapshot: ->
    snapshot = new Snapshot
      node_id: @json.node
      timestamp: new Date()
    snapshot.save()
    snapshot

  # Write the process list to the snapshot instance for the JSON data.
  writeProcesses: ->
    for processInfo in @json.processes

      process = new Process
        snapshot: @snapshot._id
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
      process.save (error) ->
        if error?
          throw new Error error

  # Find the label information from the @data list and remove them, while
  # writing the label information to the database.
  extractAndWriteLabels: ->

    # Holds a list of index positions in the @data array where labels are
    # stored, since we need to remove them after we're done processing them.
    labelIndexes = []
    for dataIndex in [0 .. @data.length - 1]

      key = @data[dataIndex].key
      value = @data[dataIndex].value

      if _.include key, 'labels'
        labelIndexes.push dataIndex

        label = new MetricLabel
          snapshot: @snapshot._id
          path: key
          value: value
        label.save (error) ->
          if error?
            throw new Error error

    # Remove the identified label indexes from the data array.
    for labelIndex in labelIndexes.reverse()
      @data.splice labelIndex, 1

  # Write the metrics found in the JSON data structure.
  writeMetrics: ->
    for element in @data

      metric = new Metric
        snapshot: @snapshot._id
        path: element.key
        counter: element.value
      metric.save (error) ->
        if error?
          throw new Error error

module.exports = SnapshotParser
