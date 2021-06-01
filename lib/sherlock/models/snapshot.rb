# encoding: utf-8

module Sherlock #:nodoc
  module Models #:nodoc

    # Defines a snapshot containing data pushed from an agent to Sherlock.
    class Snapshot

      include MongoMapper::Document
      set_collection_name 'snapshots'

      # Snapshots have many processes.
      many :processes, :class_name => 'Sherlock::Models::Process'

      # Snapshots have many metrics.
      many :metrics, :class_name => 'Sherlock::Models::Metric'

      # Define the fields for a snapshot.
      key :node_id, String
      key :timestamp, Time
      key :key, String

      # Validate that the snapshot has a node id set.
      validates :node_id, :presence => true
      
      # Validate that the snapshot has a timestamp set.
      validates :timestamp, :presence => true

      # Add a index on node_id and timestamp.
      Snapshot.ensure_index([[:node_id, 1], [:timestamp, -1]])

      # Add a index on key.
      Snapshot.ensure_index(:key, :unique => true)

      # Before validating or saving the model, build a unique, identifiable key
      # for this snapshot.
      before_validation :generate_key
      before_save :generate_key

      private

      # Generate a unique, identifiable key for this snapshot. This key is based
      # on the node id and the timestamp, making the key easy to calculate
      # without having to load the model first.
      def generate_key
        if self.key.blank? && !(self.node_id.blank? || self.timestamp.blank?)
          self.key = "#{node_id}-#{timestamp.strftime('%Y%m%d%H%M%S')}"
        end
      end

    end

  end
end
