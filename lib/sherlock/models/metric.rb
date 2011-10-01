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
      set_collection_name 'metrics'

      # Metrics belong to snapshots.
      belongs_to :snapshot

      # Define the fields for a metric.
      key :node_id, String
      key :timestamp, Time
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

      # Add a compound index on node_id, path and timestamp.
      Metric.ensure_index([[:node_id, 1], [:path, 1], [:timestamp, -1]], :unique => true)

      # After creating a metric, update all relevant averages.
      after_create :update_averages

      private

      # Update all averages relevant to this metric. This will calculate 5
      # minute, 1 hour, 1 day and 1 week averages for the the time period this
      # timestamp is created within.
      def update_averages

        # Calculate the timestamps for the averages related to this metrics
        # timestamp.
        timestamp_5m = timestamp.floor(5.minutes)
        timestamp_1h = timestamp.change(:min => 0)
        timestamp_1d = timestamp.beginning_of_day
        timestamp_1w = timestamp.beginning_of_week

        # Write the averages using an upsert with $inc so we just increment the
        # value of any pre-defined average for the timespan, or create them if
        # they don't exist.
        conditions = { :node_id => node_id, :path => path }
        value = {
          '$set' => { :node_id => node_id, :path => path },
          '$inc' => { :total => counter, :count => 1 }
        }

        # Write the averages for the last 5 minutes.
        conditions_5m = conditions.merge(:timestamp => timestamp_5m)
        value_5m = value.merge('$set' => { :timestamp => timestamp_5m })
        Sherlock::Models::MetricAvg5m.collection.update(conditions_5m, value_5m, :upsert => true)
        calculate_metric_average(Sherlock::Models::MetricAvg5m, node_id, path, timestamp_5m)

        # Write the averages for the last hour.
        conditions_1h = conditions.merge(:timestamp => timestamp_1h)
        value_1h = value.merge('$set' => { :timestamp => timestamp_1h })
        Sherlock::Models::MetricAvg1h.collection.update(conditions_1h, value_1h, :upsert => true)
        calculate_metric_average(Sherlock::Models::MetricAvg1h, node_id, path, timestamp_1h)

        # Write the averages for the last day.
        conditions_1d = conditions.merge(:timestamp => timestamp_1d)
        value_1d = value.merge('$set' => { :timestamp => timestamp_1d })
        Sherlock::Models::MetricAvg1d.collection.update(conditions_1d, value_1d, :upsert => true)
        calculate_metric_average(Sherlock::Models::MetricAvg1d, node_id, path, timestamp_1d)
        
        # Write the averages for the last week.
        conditions_1w = conditions.merge(:timestamp => timestamp_1w)
        value_1w = value.merge('$set' => { :timestamp => timestamp_1w })
        Sherlock::Models::MetricAvg1w.collection.update(conditions_1w, value_1w, :upsert => true)
        calculate_metric_average(Sherlock::Models::MetricAvg1w, node_id, path, timestamp_1w)

      end

      # Calculate the average value for a metric average.
      #
      # @param [ Class ] model_class The model class to update averages for.
      # @param [ String ] node_id The node id to query for.
      # @param [ String ] path The metric path to query for.
      # @param [ Time ] timestamp The timestamp to query for.
      def calculate_metric_average(model_class, node_id, path, timestamp)
        average = model_class.find_by_node_id_and_path_and_timestamp!(node_id, path, timestamp)
        average.set(:counter => average.total / average.count)
      end

    end

  end
end
