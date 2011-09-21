testCase = (require 'nodeunit').testCase
fs = require 'fs'
async = require 'async'
mongoose = require 'mongoose'

configModule = require '../lib/config'
configModule.setConfigDirectory './test/config'
 
mongoose.connect 'mongodb://localhost/sherlock_test'

SnapshotParser = require '../lib/snapshot_parser'
Snapshot = (require '../lib/models/snapshot')
Process = (require '../lib/models/process')
MetricLabel = (require '../lib/models/metric_label')
Metric = (require '../lib/models/metric')
 
validJson = fs.readFileSync "#{__dirname}/assets/agent_data.json", 'utf-8'

#
# Build some invalid JSON structures to use in the tests.
#
# Missing "node" element.
jsonWithoutNode = JSON.parse(validJson)
delete jsonWithoutNode.node
jsonWithoutNode = JSON.stringify(jsonWithoutNode)

# Invalid "node" element.
jsonWithInvalidNode = JSON.parse(validJson)
jsonWithInvalidNode.node = 'invalid'
jsonWithInvalidNode = JSON.stringify(jsonWithInvalidNode)

# Missing agent version.
jsonWithoutAgentVersion = JSON.parse(validJson)
delete jsonWithoutAgentVersion.agent_version
jsonWithoutAgentVersion = JSON.stringify(jsonWithoutAgentVersion)

# Invalid agent version.
jsonWithInvalidAgentVersion = JSON.parse(validJson)
jsonWithInvalidAgentVersion.agent_version = 'invalid'
jsonWithInvalidAgentVersion = JSON.stringify(jsonWithInvalidAgentVersion)

# Missing data.
jsonWithoutData = JSON.parse(validJson)
delete jsonWithoutData.data
jsonWithoutData = JSON.stringify(jsonWithoutData)

# Missing processes.
jsonWithoutProcesses = JSON.parse(validJson)
delete jsonWithoutProcesses.processes
jsonWithoutProcesses = JSON.stringify(jsonWithoutProcesses)

# Invalid processes.
jsonWithInvalidProcesses = JSON.parse(validJson)
jsonWithInvalidProcesses.processes = 'invalid'
jsonWithInvalidProcesses = JSON.stringify(jsonWithInvalidProcesses)

# Empty processes.
jsonWithEmptyProcesses = JSON.parse(validJson)
jsonWithEmptyProcesses.processes = []
jsonWithEmptyProcesses = JSON.stringify(jsonWithEmptyProcesses)

module.exports = testCase
  setUp: (callback) ->
    callback()

  tearDown: (callback) ->

    # Remove all collections and call the callback.
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

      callback()

  'accept valid json data': (test) ->
    test.doesNotThrow ->
      new SnapshotParser validJson
    test.done()

  'do not accept missing node': (test) ->
    test.throws ->
      new SnapshotParser jsonWithoutNode
    test.done()

  'do not accept invalid node': (test) ->
    test.throws ->
      new SnapshotParser jsonWithInvalidNode
    test.done()

  'do not accept missing agent version': (test) ->
    test.throws ->
      new SnapshotParser jsonWithoutAgentVersion
    test.done()

  'do not accept invalid agent version': (test) ->
    test.throws ->
      new SnapshotParser jsonWithInvalidAgentVersion
    test.done()

  'do not accept missing data': (test) ->
    test.throws ->
      new SnapshotParser jsonWithoutData
    test.done()

  'do not accept missing processes': (test) ->
    test.throws ->
      new SnapshotParser jsonWithoutProcesses
    test.done()

  'do not accept non-array processes': (test) ->
    test.throws ->
      new SnapshotParser jsonWithInvalidProcesses
    test.done()

  'do not accept empty processes': (test) ->
    test.throws ->
      new SnapshotParser jsonWithEmptyProcesses
    test.done()

  'store snapshot without failing': (test) ->
    parser = new SnapshotParser validJson
    test.doesNotThrow ->
      parser.storeSnapshot()
    test.done()
