# encoding: utf-8

module Sherlock #:nodoc
  module Models #:nodoc

    # Defines average metrics for a 1 hour period.
    class MetricAvg1h

      include MongoMapper::Document
      set_collection_name 'metrics.1h'

      # Define the fields for a metric average.
      key :node_id, String
      key :timestamp, Time
      key :path, String
      key :count, Float
      key :total, Float
      key :counter, Float

      # Validate that the metric average has a node id set.
      validates :node_id, :presence => true

      # Validate that the metric average has a timestamp set.
      validates :timestamp, :presence => true

      # Validate that the metric average has a path set.
      validates :path, :presence => true

      # Add a compound index on node_id, path and timestamp.
      MetricAvg1h.ensure_index([[:node_id, 1], [:path, 1], [:timestamp, 1]], :unique => true)

    end

  end
end
