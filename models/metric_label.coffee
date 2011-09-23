mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "metric_labels" collection.
metricLabelSchema = new Schema(
  {
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

mongoose.model 'MetricLabel', metricLabelSchema
module.exports = mongoose.model 'MetricLabel'
