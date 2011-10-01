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

  # Apply conversions on a metric data set.
  class MetricConverter

    def initialize(data_set)
      @data_set = data_set
    end

    # Apply the specified conversion method to the current data set.
    #
    # @return [ Hash ] The converted data set.
    #
    # @raise [ ArgumentError ] If the requested conversion method does not
    #   exist.
    def apply_conversion(conversion)
      if respond_to?(:"#{conversion}_conversion")
        send(:"#{conversion}_conversion")
      else
        raise ArgumentError.new("Invalid conversion: #{conversion}")
      end
    end

    protected

    # Returns the current data set.
    #
    # @return [ Hash ] The current data wet.
    def data_set
      @data_set
    end

    # Convert the current data by passing in a block that handles the
    # conversion for each metric in the list.
    #
    # @return [ Hash ] The converted data set.
    def convert_data_set(&block)

      converted_set = {}
      data_set.each do |path, data|
        
        converted_set[path] ||= []
        previous_metric = nil
        data.each do |metric|

          converted_metric = yield(metric.dup, previous_metric)

          # Round the value to two decimal points.
          converted_metric.counter = converted_metric.counter.to_f.round(2)

          converted_set[path] << converted_metric
          previous_metric = metric

        end

      end

      converted_set

    end

    # Convert bytes to Mbit per second.
    #
    # @return [ Hash ] The converted data set.
    def bytes_to_mbit_per_second_conversion
      convert_data_set do |metric, previous_metric|

        time_diff = 0
        if !previous_metric.blank?
          current_time = metric.timestamp
          previous_time = previous_metric.timestamp
          time_diff = (current_time - previous_time).to_i
        end

        metric.counter = (metric.counter.to_f * 8) / 1024 / 1024 # 1 byte = 8 bits / 1024 = kbits / 1024 = mbits
        metric.counter = time_diff > 0 ? metric.counter.to_f / time_diff.to_f : 0 # mbits per second
        metric

      end
    end

    # Convert bytes to MB.
    #
    # @return [ Hash ] The converted data set.
    def bytes_to_mb_conversion
      convert_data_set do |metric, previous_metric|
        metric.counter = metric.counter.to_f / 1024 / 1024 # 1 byte / 1024 = kb / 1024 = mb
        metric
      end
    end

  end

end
