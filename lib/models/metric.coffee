mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "metrics" collection.
MetricSchema = new Schema
  snapshot:
    type: Schema.ObjectId
    ref: 'Snapshot'
    required: true

  path:
    type: [String]
    required: true

  counter:
    type: Number
    required: true
    default: 0

mongoose.model 'Metric', MetricSchema
module.exports = mongoose.model 'Metric'
