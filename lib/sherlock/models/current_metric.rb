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
