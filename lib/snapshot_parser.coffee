_ = require 'underscore'

config = (require './config').load()
Snapshot = require './models/snapshot'
Process = require './models/process'
MetricLabel = require './models/metric_label'
Metric = require './models/metric'

class SnapshotParser

  constructor: (rawJson) ->
    @json = JSON.parse(rawJson)
    @validateJson()

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
      process.save()

  # Extract and write all labels in the JSON data structure.
  extractAndWriteLabels: ->

  # Write the metrics found in the JSON data structure.
  writeMetrics: ->

module.exports = SnapshotParser
