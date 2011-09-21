should = require 'should'
assert = require 'assert'
fs = require 'fs'

configModule = require '../lib/config'
configModule.setConfigDirectory './test/config'

dbConnection = (require '../lib/db_connection').aquire()
dbConnection.on 'open', ->
  console.log 'DB connection is now open'

SnapshotParser = require '../lib/snapshot_parser'
Snapshot = require '../lib/models/snapshot'

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

module.exports =
  'accept valid json data': ->
    assert.doesNotThrow ->
      new SnapshotParser validJson

  'do not accept missing node': ->
    assert.throws ->
      new SnapshotParser jsonWithoutNode

  'do not accept invalid node': ->
    assert.throws ->
      new SnapshotParser jsonWithInvalidNode

  'do not accept missing agent version': ->
    assert.throws ->
      new SnapshotParser jsonWithoutAgentVersion

  'do not accept invalid agent version': ->
    assert.throws ->
      new SnapshotParser jsonWithInvalidAgentVersion

  'do not accept missing data': ->
    assert.throws ->
      new SnapshotParser jsonWithoutData

  'store snapshot without failing': ->
    parser = new SnapshotParser validJson
    assert.doesNotThrow ->
      parser.storeSnapshot()

  'create a snapshot instance': ->
    parser = new SnapshotParser validJson
    parser.storeSnapshot()
    dbConnection.on 'open', (arg) ->
      console.log 'Attempting to query using dbConnection', dbConnection
      r = Snapshot.count()# {}, (err, doc) ->
        # console.log 'Err:', err
        # console.log 'Doc:', doc
      console.log 'Done querying for count, r=', r
