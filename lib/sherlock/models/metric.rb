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

    # Defines a metric for a node within a snapshot.
    class Metric

      include MongoMapper::Document

      # Metrics belong to snapshots.
      belongs_to :snapshot

      # Define the fields for a metric.
      key :node_id, String
      key :timestamp, String
      key :path, String
      key :counter, Float

      # Validate that the metric has a node id set.
      validates :node_id, :presence => true

      # Validate that the metric has a timestamp set.
      validates :timestamp, :presence => true

      # Validate that the metric has a path set.
      validates :path, :presence => true

      # Validate that the metric has a counter set.
      validates :counter, :presence => true

    end

  end
end