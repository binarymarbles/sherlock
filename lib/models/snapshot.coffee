require 'node-date'
mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "snapshots" collection.
Snapshot = new Schema
  node_id:
    type: String
    required: true

  timestamp:
    type: Date
    required: true

  key:
    type: String
    # required: true
    index:
      unique: true

Snapshot.pre 'save', (next) ->
  @key = "#{@node_id}:#{@timestamp.toFormat('YYYY-MM-DD-HH24-MI-SS')}"
  next()

mongoose.model 'Snapshot', Snapshot
module.exports = mongoose.model 'Snapshot'
