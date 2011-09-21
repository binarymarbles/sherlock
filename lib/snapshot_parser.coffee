config = (require './config').load()
# Snapshot = require './models/snapshot'
# Process = require './models/process'
# MetricLabel = require './models/metric_label'
# Metric = require './models/metric'

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

    # We require that the data has a "data" hash.
    throw new Error 'Missing data element in payload' unless @json.data?

  # Store the snapshot data in the database.
  storeSnapshot: ->


module.exports = SnapshotParser
