mongoose = require 'mongoose'
Schema = mongoose.Schema

# Define the schema for the "labels" collection.
labelSchema = new Schema
  node_id:
    type: String
    required: true

  path:
    type: String
    required: true

  value:
    type: String
    required: true

# Add a unique compound index on snapshot and path.
labelSchema.index(
  {
    node_id: 1,
    path: 1
  },
  { unique: true }
)

mongoose.model 'Label', labelSchema
module.exports = mongoose.model 'Label'
