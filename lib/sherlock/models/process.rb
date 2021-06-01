# encoding: utf-8

module Sherlock #:nodoc
  module Models #:nodoc

    # Defines a process within a snapshot.
    class Process

      include MongoMapper::Document
      set_collection_name 'processes'

      # Processes belong to snapshots.
      belongs_to :snapshot

      # Define the fields for a process.
      key :timestamp, Time
      key :user, String
      key :pid, Integer
      key :cpu_usage, Integer
      key :memory_usage, Integer
      key :virtual_memory_size, Integer
      key :residential_set_size, Integer
      key :tty, String
      key :state, String
      key :started_at, String # We don't use dates here as we never really get the full date from the agent.
      key :cpu_time, String
      key :command, String

      # Validate that the process is associated with a snapshot.
      validates :snapshot, :presence => true

      # Validate that the process has a timestamp set.
      validates :timestamp, :presence => true

      # Validate that the process has a user set.
      validates :user, :presence => true

      # Validate that the process has a pid set.
      validates :pid, :presence => true

      # Validate that the process has the CPU usage set.
      validates :cpu_usage, :presence => true

      # Validate that the process has the memory usage set.
      validates :memory_usage, :presence => true

      # Validate that the process has the command set.
      validates :command, :presence => true

      # Add a index on snapshot_id.
      Process.ensure_index(:snapshot_id)
      
    end

  end
end
