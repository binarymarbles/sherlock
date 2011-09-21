testCase = (require 'nodeunit').testCase
fs = require 'fs'
mongoose = require 'mongoose'

configModule = require '../lib/config'
configModule.setConfigDirectory './test/config'
 
SnapshotParser = require '../lib/snapshot_parser'
Snapshot = require '../lib/models/snapshot'
Process = require '../lib/models/snapshot'
MetricLabel = require '../lib/models/snapshot'
Metric = require '../lib/models/snapshot'
 
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
    console.log 'In setUp'
    try
      @db = mongoose.connect 'mongodb://localhost/sherlock_test'
      # @db = mongoose.createConnection 'mongodb://localhost/sherlock_test'
      console.log 'Started connection, waiting for it to open'
      @db.connection.on 'open', ->
      # @db.on 'open', ->

        console.log 'Opened connection'

        # Remove all collections
        Snapshot.collection.remove()
        Process.collection.remove()
        MetricLabel.collection.remove()
        Metric.collection.remove()

        callback()

    catch err
      console.log 'Setting up failed:', err.message

  tearDown: (callback) ->
    console.log 'In tearDown'
    try
      console.log 'Closing connection'
      @db.disconnect()
      # @db.close()
      callback()
    catch err
      console.log 'Tearing down failed:', err.message

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
      new SnapshotPArser jsonWithEmptyProcesses
    test.done()

  'store snapshot without failing': (test) ->
    parser = new SnapshotParser validJson
    test.doesNotThrow ->
      parser.storeSnapshot()
    test.done()
 
  'create a snapshot instance': (test) ->
    parser = new SnapshotParser validJson
    parser.storeSnapshot()

    # console.log 'About to query for snapshots using connection', @db

    console.log 'Executing count on Snapshot'
    Snapshot.count {}, (count) ->
      console.log 'Got count callback', count
      test.done()
  #   console.log 'Fired off count'
