# encoding: utf-8

module Sherlock #:nodoc
  module Models #:nodoc

    # Defines the most recently received values for each metric for a node.
    class CurrentMetric

      include MongoMapper::Document
      set_collection_name 'metrics.current'

      # Define the fields for a metric.
      key :node_id, String
      key :path, String
      key :counter, Float

      # Add a compound index on node_id and path.
      CurrentMetric.ensure_index([[:node_id, 1], [:path, 1]], :unique => true)
      
    end

  end
end
