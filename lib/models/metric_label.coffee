mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "metric_labels" collection.
MetricLabel = new Schema
  snapshot:
    type: Schema.ObjectId
    ref: 'Snapshot'
    required: true

  path:
    type: [String]
    required: true

  value:
    type: String
    required: true

mongoose.model 'MetricLabel', MetricLabel
module.exports = mongoose.model 'MetricLabel'
