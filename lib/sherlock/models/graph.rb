# encoding: utf-8

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

      # Returns all the paths requested by this graph.
      def paths
        keys.collect(&:metric)
      end

      # Returns true if the data for this graph needs a conversion.
      def needs_conversion?
        !conversion.blank?
      end

    end

  end
end
