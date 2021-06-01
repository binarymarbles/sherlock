# encoding: utf-8

module Sherlock #:nodoc
  module Models #:nodoc

    # Defines a label for a node and metric path.
    class Label

      include MongoMapper::Document
      set_collection_name 'labels'

      # Define the fields for a label.
      key :node_id, String
      key :path, String
      key :value, String

      # Validate that the label has a node id set.
      validates :node_id, :presence => true

      # Validate that the label has a path set.
      validates :path, :presence => true

      # Validate that the label has a value set.
      validates :value, :presence => true

      # Add a compound index on node_id and path
      Label.ensure_index([[:node_id, 1], [:path, 1]], :unique => true)

    end

  end
end
