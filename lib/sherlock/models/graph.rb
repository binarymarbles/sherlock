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

    # Defines a graph registered in the graph configuration file.
    class Graph

      include ActiveModel::Validations

      GRAPH_TYPES = %w(counter incremental)
      GRAPH_CONVERSIONS = %w(bytes_to_mbit_per_second bytes_to_mb)

      attr_accessor :attributes
      attr_accessor :id, :name, :type, :unit, :conversion, :keys

      # Validate that graphs have an ID attribute set.
      validates :id, :presence => true

      # Validate that graphs have a name set.
      validates :name, :presence => true

      # Validate that graphs have a type set, and that its a valid type.
      validates :type, :presence => true, :inclusion => { :in => GRAPH_TYPES }

      # Validate that graphs have a unit set.
      validates :unit, :presence => true

      # Validate that graphs have a valid conversion set, unless the
      # conversion value is blank.
      validates :conversion, :inclusion => { :in => GRAPH_CONVERSIONS, :allow_blank => true }

      # Validate that graphs have a list of keys defined.
      validates :keys, :presence => true

      # Initialize a new graph.
      #
      # @example Initialize a new graph
      #   new Graph(:id => 'test-graph')
      def initialize(attributes = {})
        attributes.each do |name, value|
          send(:"#{name}=", value)
        end
        self.keys ||= []
      end

    end

  end
end
