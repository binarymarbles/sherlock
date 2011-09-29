# encoding: utf-8

# Copyright 2011 Binary Marbles.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

    end

  end
end
