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

  # Collect metrics from the database for any given node and time period.
  class MetricCollector

    # Initialize a new metric collector.
    #
    # @param [ String ] node_id The ID of the node to collect metrics for.
    # @param [ Array<String> ] paths An array of metric paths to collect.
    # @param [ Hash ] options A hash of options to use when constructing the
    #   metric collector.
    #
    # === Options
    # * <tt>:from => Time</tt> - Defines how far back in time to go when
    #   collecting metrics. This automatically affects the resolution of the
    #   averages returned from the operation.
    # * <tt>:to => Time</tt> - Defines at what point to stop collecting
    #   metrics. This automatically affects the resolution of the averages
    #   returned from the operation.
    # * <tt>:type => String</tt> - Defines the type of metric that should be
    #   collected. Defaults to 'counter' which returns the metrics as-is.
    #   Other valid options are 'incremental', which will return a set of
    #   numbers with the incremental value between each metric (useful for
    #   network interface graphs and similar).
    def initialize(node_id, paths, *args)

      options = args.extract_options!
      @node_id = node_id
      @paths = paths
      @from = options[:from] || Time.now - 12.hours
      @to = options[:to] || Time.now
      @type = options[:type] || 'counter'
      @conversion = options[:conversion]

    end

    # Returns the metrics matching the conditions set when initializing the
    # metric collector.
    #
    # @return [ Hash ] A hash of arrays containing the metrics. The hash keys
    #   are the path to each of the metrics, the array value is an array of
    #   key/value pairs containing timestamp and counter values.
    def metrics
      @metrics ||= collect_metrics
    end

    private

    # Collect the metrics matching the conditions set when initializing the
    # metric collector.
    #
    # @return [ Hash ] A hash of arrays containing the metrics. The hash keys
    #   are the path to each of the metrics, the array value is an array of
    #   key/value pairs containing timestamp and counter values.
    def collect_metrics

      # Build a set of matchers to match the paths we need to find metrics
      # for.
      path_matchers = []
      @paths.each do |path|
        path_matchers << { :path => matcher_for_path(path) }
      end

      # Figure out what metric model to use (Metric or one of the average
      # models).
      metric_model = metric_model_for_timespan

      # Build a query to locate the metrics.
      query = metric_model.where(:$or => path_matchers)
      query = query.where(:node_id => @node_id)
      query = query.where(:timestamp.gte => @from)
      query = query.where(:timestamp.lte => @to)
      query = query.sort(:timestamp.asc)
      metrics = query.all

      # Return a data set based on the collection of metrics.
      data_set_for_metrics(metrics)

    end

    # Returns a MongoMapper matcher for the specified path. If the path
    # contains a wildcard, it will return a regexp match - otherwise it will
    # just return the string passed in.
    #
    # @param [ String ] path The path to match.
    #
    # @return [ Object ] The matcher for the path.
    def matcher_for_path(path)

      path = path.to_s

      if path.include?('*')
        quoted_path = path.gsub('.', '\.')
        quoted_path = quoted_path.gsub('*', '.+?')
        Regexp.new("^#{quoted_path}$")
      else
        path
      end

    end

    # Returns the appropriate model to use when querying for metrics based on
    # the difference between the from and to times.
    #
    # @return [ Class ] The metric model that should be used when querying for
    #   metrics.
    def metric_model_for_timespan

      time_diff = (@from - @to).to_i
      if time_diff >= 180.days # If 6 months or more, return weekly averages.
        Sherlock::Models::MetricAvg1w
      elsif time_diff >= 90.days # If 3 months or more, return daily averages.
        Sherlock::Models::MetricAvg1d
      elsif time_diff >= 30 # If one month or more, return hourly averages.
        Sherlock::Models::MetricAvg1h
      elsif time_diff >= 1.day # If one day or more, return 5 minute averages.
        Sherlock::Models::MetricAvg5m
      else # If none of the above, just use the raw Metric model.
        Sherlock::Models::Metric
      end

    end

    # Build a data set for the metrics returned from a query.
    #
    # @param [ Array ] metrics A collection of Metric models (or one of the
    #   average models) containing the matched metrics.
    # 
    # @return [ Hash ] A hash of arrays containing the metrics. The hash keys
    #   are the path to each of the metrics, the array value is an array of
    #   key/value pairs containing timestamp and counter values.
    def data_set_for_metrics(metrics)

      data_set = {}
      previous_counters = {}

      metrics.each do |metric|

        path = metric.path
        timestamp = metric.timestamp
        current_counter = metric.counter
        counter = current_counter

        # If this is an incremental graph, calculate the difference between
        # the previous counter value for this path and the current counter
        # value, and use the difference as the counter value. If we have no
        # previous counter value, 0 is used.
        #
        # Also, if the differential between previous and current is below 0,
        # its assumed that the counter has reset and we will start counting
        # from 0 again instead of returning a negative value.
        if @type == 'incremental'
          if !previous_counters[path].blank?

            counter = current_counter - previous_counters[path]

            # Reset the counter if we have a negative value.
            if counter < 0
              counter = current_counter
            end

          else
            counter = 0
          end
        end

        # Define the previous counter value for this path.
        previous_counters[path] = current_counter

        # Add the counter to the data set.
        data_set[path] ||= []
        data_set[path] << Sherlock::Models::MetricData.new(timestamp, counter)

      end

      # Apply the requested conversion on the data set if requested.
      unless @conversion.blank?
        converter = Sherlock::MetricConverter.new(data_set)
        data_set = converter.apply_conversion(@conversion)
      end

      data_set

    end

  end

end
