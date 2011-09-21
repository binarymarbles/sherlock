mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "metric_labels" collection.
metricLabelSchema = new Schema(
  {
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
  },
  {
    collection: 'metric_labels'
  }
)

mongoose.model 'MetricLabel', metricLabelSchema

module.exports = mongoose.model 'MetricLabel'
