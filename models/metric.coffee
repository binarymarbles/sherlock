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
    index: true

  path:
    type: String
    required: true

  counter:
    type: Number
    required: true
    default: 0

# Add a unique compound index on snapshot and path.
metricSchema.index(
  {
    snapshot: 1,
    path: 1
  },
  { unique: true }
)

mongoose.model 'Metric', metricSchema
module.exports = mongoose.model 'Metric'
