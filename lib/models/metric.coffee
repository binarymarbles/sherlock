mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "metrics" collection.
metricSchema = new Schema
  snapshot:
    type: Schema.ObjectId
    required: true

  snapshot_timestamp:
    type: Date
    required: true

  path:
    # type: [String]
    type: String
    required: true

  counter:
    type: Number
    required: true
    default: 0

mongoose.model 'Metric', metricSchema

module.exports = mongoose.model 'Metric'
