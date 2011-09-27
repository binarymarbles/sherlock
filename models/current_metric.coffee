mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "metrics.current" collection.
metricSchema = new Schema(
  {
    node_id:
      type: String
      required: true

    path:
      type: String
      required: true

    counter:
      type: Number
      required: true
      default: 0
  },
  { collection_name: 'metrics.current' }
)

# Add a compound index on node id and timestamp.
metricSchema.index(
  {
    node_id: 1
    path: 1
  },
  { unique: true }
)

mongoose.model 'CurrentMetric', metricSchema
module.exports = mongoose.model 'CurrentMetric'
