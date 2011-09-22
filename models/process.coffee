mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "processes" collection.
processSchema = new Schema
  snapshot:
    type: Schema.ObjectId
    required: true

  snapshot_timestamp:
    type: Date
    required: true

  user: String
  pid: Number
  cpu_usage: Number
  memory_usage: Number
  virtual_memory_size: Number
  residental_set_size: Number
  tty: String
  state: String
  started_at: Date
  cpu_time: String
  command: String

mongoose.model 'Process', processSchema

module.exports = mongoose.model 'Process'

