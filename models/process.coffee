mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "processes" collection.
processSchema = new Schema
  snapshot:
    type: Schema.ObjectId
    required: true
    index: true

  timestamp:
    type: Date
    required: true
    index: true

  user: String
  pid: Number
  cpu_usage: Number
  memory_usage: Number
  virtual_memory_size: Number
  residental_set_size: Number
  tty: String
  state: String
  started_at: String
  cpu_time: String
  command: String

mongoose.model 'Process', processSchema
module.exports = mongoose.model 'Process'
