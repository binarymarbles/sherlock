mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "metrics" collection.
metricSchema = new Schema
  snapshot:
    type: Schema.ObjectId
    required: true

  node_id:
    type: String
    required: true

  timestamp:
    type: Date
    required: true

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

# Add a compound index on node id and timestamp.
metricSchema.index
  node_id: 1
  timestamp: 1

mongoose.model 'Metric', metricSchema
module.exports = mongoose.model 'Metric'
