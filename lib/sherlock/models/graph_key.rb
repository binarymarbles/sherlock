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

    # Defines a key within a graph registered in the graph configuration file.
    class GraphKey

      include ActiveModel::Validations

      attr_accessor :attributes
      attr_accessor :metric, :label

      # Validate that graph keys have a metric set.
      validates :metric, :presence => true

      # Validate that graph keys have a label set.
      validates :label, :presence => true

      # Initialize a new graph key.
      #
      # @example Initialize a new graph key
      #   new GraphKey(:metric => 'test.metric')
      def initialize(attributes = {})
        attributes.each do |name, value|
          send(:"#{name}=", value)
        end
      end

    end

  end
end
