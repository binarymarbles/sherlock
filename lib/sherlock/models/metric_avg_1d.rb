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

    # Defines average metrics for a 1 day period.
    class MetricAvg1d

      include MongoMapper::Document
      set_collection_name 'metrics.1d'

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
      MetricAvg1d.ensure_index([[:node_id, 1], [:path, 1], [:timestamp, 1]], :unique => true)

    end

  end
end
