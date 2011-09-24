mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "metric_labels" collection.
metricLabelSchema = new Schema(
  {
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

    value:
      type: String
      required: true
  },
  {
    collection: 'metric_labels'
  }
)

# Add a unique compound index on snapshot and path.
metricLabelSchema.index(
  {
    snapshot: 1,
    path: 1
  },
  { unique: true }
)

# Add a compound index on node id and timestamp.
metricLabelSchema.index
  node_id: 1
  timestamp: 1

mongoose.model 'MetricLabel', metricLabelSchema
module.exports = mongoose.model 'MetricLabel'
