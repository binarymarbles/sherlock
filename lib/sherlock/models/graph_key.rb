# encoding: utf-8

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
