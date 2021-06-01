# encoding: utf-8

module Sherlock #:nodoc
  module Models #:nodoc

    # Holds a set of metric data collected with the metric collector class.
    class MetricData

      attr_reader :timestamp
      attr_accessor :counter

      # Initialize a new metric data model.
      def initialize(timestamp, counter)
        @timestamp = timestamp
        @counter = counter
      end

    end

  end
end
