testCase = (require 'nodeunit').testCase
fs = require 'fs'
mongoose = require 'mongoose'
_ = require 'underscore'

TestHelper = require './test_helper'

SnapshotParser = require '../lib/snapshot_parser'
Snapshot = require '../models/snapshot'
Process = require '../models/process'
MetricLabel = require '../models/metric_label'
Metric = require '../models/metric'
 
validJson = JSON.parse(fs.readFileSync "#{__dirname}/assets/agent_data.json", 'utf-8')

#
# Build some invalid JSON structures to use in the tests.
#
# Missing "node" element.
jsonWithoutNode = _.clone validJson
delete jsonWithoutNode.node

# Invalid "node" element.
jsonWithInvalidNode = _.clone validJson
jsonWithInvalidNode.node = 'invalid'

# Missing agent version.
jsonWithoutAgentVersion = _.clone validJson
delete jsonWithoutAgentVersion.agent_version

# Invalid agent version.
jsonWithInvalidAgentVersion = _.clone validJson
jsonWithInvalidAgentVersion.agent_version = 'invalid'

# Missing data.
jsonWithoutData = _.clone validJson
delete jsonWithoutData.data

# Missing processes.
jsonWithoutProcesses = _.clone validJson
delete jsonWithoutProcesses.processes

# Invalid processes.
jsonWithInvalidProcesses = _.clone validJson
jsonWithInvalidProcesses.processes = 'invalid'

# Empty processes.
jsonWithEmptyProcesses = _.clone validJson
jsonWithEmptyProcesses.processes = []

module.exports = testCase
  setUp: (callback) ->
    TestHelper.connectToDatabase()
    callback()

  tearDown: (callback) ->
    TestHelper.resetCollections ->
      TestHelper.disconnectFromDatabase callback

  'accept valid json data': (test) ->
    new SnapshotParser validJson, (error) ->
      test.ok !error?
      test.done()

  'do not accept missing node': (test) ->
    new SnapshotParser jsonWithoutNode, (error) ->
      test.ok error?
      test.done()

  'do not accept invalid node': (test) ->
    new SnapshotParser jsonWithInvalidNode, (error) ->
      test.ok error?
      test.done()

  'do not accept missing agent version': (test) ->
    new SnapshotParser jsonWithoutAgentVersion, (error) ->
      test.ok error?
      test.done()

  'do not accept invalid agent version': (test) ->
    new SnapshotParser jsonWithInvalidAgentVersion, (error) ->
      test.ok error?
      test.done()

  'do not accept missing data': (test) ->
    new SnapshotParser jsonWithoutData, (error) ->
      test.ok error?
      test.done()

  'do not accept missing processes': (test) ->
    new SnapshotParser jsonWithoutProcesses, (error) ->
      test.ok error?
      test.done()

  'do not accept non-array processes': (test) ->
    new SnapshotParser jsonWithInvalidProcesses, (error) ->
      test.ok error?
      test.done()

  'do not accept empty processes': (test) ->
    new SnapshotParser jsonWithEmptyProcesses, (error) ->
      test.ok error?
      test.done()

  'have 1 snapshot': (test) ->
    new SnapshotParser validJson, (error) ->
      test.ifError(error)

      Snapshot.count (error, count) ->
        test.ifError error
        test.equals count, 1
        test.done()

  'have 2 processes': (test) ->
    new SnapshotParser validJson, (error) ->
      test.ifError(error)

      Process.count (error, count) ->
        test.ifError error
        test.equals count, 2
        test.done()

  'have 3 labels': (test) ->
    new SnapshotParser validJson, (error) ->
      test.ifError(error)

      MetricLabel.count (error, count) ->
        test.ifError error
        test.equals count, 4
        test.done()

  'have 27 metrics': (test) ->
    new SnapshotParser validJson, (error) ->
      test.ifError(error)

      Metric.count (error, count) ->
        test.ifError error
        test.equals count, 27
        test.done()
