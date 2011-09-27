require 'date-utils'
mongoose = require 'mongoose'
Schema = mongoose.Schema

DateSupport = require '../lib/date_support'

# Define the schema for the "snapshots" collection.
snapshotSchema = new Schema
  node_id:
    type: String
    required: true

  timestamp:
    type: Date
    required: true
    set: DateSupport.stripSeconds

  key:
    type: String
    index:
      unique: true

# Add a pre-save hook to define the key of the snapshot.
snapshotSchema.pre 'save', (next) ->
  @key = "#{@node_id}:#{@timestamp.toFormat('YYYYMMDDHH24MISS')}"
  next()

# Add a unique compound index on node_id and timestamp.
snapshotSchema.index(
  {
    node_id: 1,
    timestamp: 1
  },
  { unique: true }
)

mongoose.model 'Snapshot', snapshotSchema
module.exports = mongoose.model 'Snapshot'
