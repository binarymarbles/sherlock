mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "metrics_avg_1w" collection.
metricSchema = new Schema(
  {
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
  },
  { collection: 'metrics_avg_1w' }
)

# Add a compound index on node id and timestamp.
metricSchema.index(
  {
    node_id: 1
    timestamp: 1
    path: 1
  },
  { unique: true }
)

mongoose.model 'MetricAvg1w', metricSchema
module.exports = mongoose.model 'MetricAvg1w'