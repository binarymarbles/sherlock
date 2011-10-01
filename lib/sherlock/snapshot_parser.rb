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

require 'json'

module Sherlock #:nodoc

  # Parse a snapshot sent to Sherlock from an agent, and persist all metrics
  # collected from the snapshot JSON.
  class SnapshotParser

    attr_reader :snapshot_json, :data, :snapshot, :processes, :labels, :metrics

    # Create a new instance of the snapshot parser. This will parse the raw JSON
    # passed in to an internal data structure, then extract all metrics from the
    # data structure and persist them to the underlying data layer.
    #
    # @example Create a new snapshot parser.
    #   SnapshotParser.new('{"node_id": "test"}')
    #
    # @param [ String ] raw_json The raw, unparsed JSON passed in from an agent.
    #
    # @raise [ Sherlock::Errors::ParserError ] If the JSON data is invalid, or
    #   the resulting data structure after parsing the JSON is not valid.
    def initialize(raw_json)

      # Parse the JSON data.
      @snapshot_json = parse_json(raw_json)

      # Validate the contents of the snapshot.
      validate_snapshot_contents

      # Build the snapshot model for the snapshot JSON.
      @snapshot = build_snapshot

      # Parse the process list in the snapshot.
      @processes = parse_processes

      # Flatten the data hash in the snapshot.
      @data = flatten_snapshot_data

      # Extract the labels from the data.
      @labels = extract_labels_from_data

      # Extract the metrics from the data.
      @metrics = extract_metrics_from_data

    end

    # Persist all snapshot data to the underlying MongoDB.
    def persist!
      @snapshot.save!
      @processes.each(&:save!)
      persist_labels
      persist_metrics
    end

    private

    # Raise a parser error.
    #
    # @param [ String ] message The message to use when raising the error.
    #
    # @raise [ Sherlock::Errors::ParserError ] The requested parser error.
    def raise_parser_error(message)
      raise Errors::ParserError.new(message)
    end

    # Parse the raw JSON data passed in from an agent and return it as a Ruby
    # hash.
    #
    # @param [ String ] raw_json The raw, unparsed JSON passed in from an agent.
    #
    # @return [ Hash ] A hash representing the JSON data.
    #
    # @raise [ Sherlock::Errors::ParserError ] If the JSON data is invalid.
    def parse_json(raw_json)
      begin
        JSON.parse(raw_json, :symbolize_names => true)
      rescue
        raise_parser_error('Unable to parse JSON data')
      end
    end

    # Validate that the contents of the snapshot passed into the snapshot parser
    # is valid.
    #
    # @raise [ Sherlock::Errors::ParserError ] If the snapshot is not valid.
    def validate_snapshot_contents

      # Require that a node_id is set and that the node_id is registered in the
      # node configuration.
      raise_parser_error('Missing "node_id" in JSON data') if snapshot_json[:node_id].blank?
      raise_parser_error('Unknown node id referenced in JSON data') if Sherlock::Config.node_by_id(snapshot_json[:node_id]).blank?

      # Require that the version is set and that it's a valid value.
      raise_parser_error('Missing "version" in JSON data') if snapshot_json[:version].blank?
      raise_parser_error('Unknown version number referenced in JSON data') if snapshot_json[:version] != '1.0.0'

      # Require that the process list is set and that its an array.
      raise_parser_error('Missing "processes" in JSON data') if snapshot_json[:processes].blank?
      raise_parser_error('Invalid process list referenced in JSON data') unless snapshot_json[:processes].is_a?(Array) && snapshot_json[:processes].size > 0

      # Require that the data attribute is set, and that its a hash with at
      # least one key.
      raise_parser_error('Missing "data" in JSON data') if snapshot_json[:data].blank?
      raise_parser_error('Invalid data referenced in JSON data') unless snapshot_json[:data].is_a?(Hash) && snapshot_json[:data].keys.size > 0

    end

    # Build a Snapshot model instance containing the basic information from the
    # snapshot JSON.
    #
    # @return [ Sherlock::Models::Snapshot ] The generated Snapshot model.
    def build_snapshot
      Sherlock::Models::Snapshot.new(
        :node_id => snapshot_json[:node_id],
        :timestamp => Time.now
      )
    end

    # Parse the process list in the snapshot JSON. This will iterate through all
    # process definitions and create Process model instances containing the
    # process information.
    #
    # @return [ Array<Sherlock::Models::Process> ] An array of processes.
    #
    # @raise [ Sherlock::Errors::ParserError ] If the process contains an
    #   invalid process.
    def parse_processes

      processes = []
      snapshot_json[:processes].each do |process_info|

        process = Sherlock::Models::Process.new(
          :snapshot => @snapshot,
          :timestamp => @snapshot.timestamp,
          :user => process_info[:user],
          :pid => process_info[:pid],
          :cpu_usage => process_info[:cpu],
          :memory_usage => process_info[:memory],
          :virtual_memory_size => process_info[:virtual_memory_size],
          :residential_set_size => process_info[:residential_set_size],
          :tty => process_info[:tty],
          :state => process_info[:state],
          :started_at => process_info[:started_at],
          :cpu_time => process_info[:cpu_time],
          :command => process_info[:command]
        )
        unless process.valid?
          raise_parser_error("Invalid process found in JSON: #{process.errors.inspect}")
        end

        processes << process

      end

      processes

    end

    # Flatten the data hash in the snapshot JSON. This will recursively extract
    # all keys from the data hash and store them in a non-nested hash, with
    # nested keys separated by dots.
    #
    # @return [ Hash ] Flattened data hash.
    def flatten_snapshot_data
      flatten_snapshot_data_level({}, [], snapshot_json[:data])
    end

    # Flatten one level of the data hash in the snapshot JSON. This will extract
    # all keys from the data hash and store them in the input hash using a dot
    # as the separator for nested keys.
    #
    # If one of the values in this hash level is another hash, it will traverse
    # down the tree until it reaches the bottom.
    #
    # @param [ Hash ] input The current input hash containing the extracted keys
    #   and values so far.
    # @param [ Array ] prefix The current prefix for the level hash keys.
    # @param [ Hash ] data The current level of the data hash to parse.
    #
    # @return [ Hash ] The keys extracted from this level of the data hash.
    def flatten_snapshot_data_level(input, prefix, data)

      data.keys.each do |key|

        value = data[key]

        # Traverse down if we have a hash, add the key/value pairs if we don't.
        if value.is_a?(Hash)
          input = flatten_snapshot_data_level(input, prefix + [key], value)
        else
          input[(prefix + [key]).join('.')] = value
        end

      end

      input

    end

    # Extract all label definitions from the flat data hash. This will search
    # the hash for any keys that include 'label' in the path and make Label
    # instances of the information there - plus remove the label from the flat
    # data hash so that only valid metrics remain there.
    #
    # @return [ Array<Sherlock::Models::Label> ] A list of all labels found in
    #   the data hash.
    #
    # @raise [ Sherlock::Errors::ParserError ] If the data contains an invalid
    #   label.
    def extract_labels_from_data

      labels = []

      @data.keys.each do |key|

        value = @data[key]

        # If the path includes the string 'labels', then extract the label
        # information and remove this key from the data hash.
        path = key.split('.')
        if path.include?('labels')

          # Build a new label and validate it.
          label = Sherlock::Models::Label.new(:node_id => @snapshot.node_id, :path => key, :value => value)
          unless label.valid?
            raise_parser_error("Invalid label found in JSON data: #{label.errors.inspect}")
          end
          labels << label

          # Remove this key from the data hash.
          @data.delete(key)

        end

      end

      labels

    end

    # Extract all metric information from the flat data hash. This will iterate
    # through all keys in the data hash and build Metric object instances for
    # each of the metrics.
    #
    # @return [ Array<Sherlock::Models::Metric> ] A list of all metrics found in
    #   the data hash.
    #
    # @raise [ Sherlock::Errors::ParserError ] If the data contains an invalid
    #   metric.
    def extract_metrics_from_data

      metrics = []

      @data.each do |key, value|

        metric = Sherlock::Models::Metric.new(:node_id => @snapshot.node_id, :timestamp => @snapshot.timestamp, :path => key, :counter => value)
        unless metric.valid?
          raise_parser_error("Invalid metric found in JSON data: #{metric.errors.inspect}")
        end

        metrics << metric

      end

      metrics

    end

    # Persist all the labels found in the snapshot JSON.
    def persist_labels
      self.labels.each do |label|

        # Write the label using an upsert so that we just replace the value of
        # any pre-defined matching labels if they already exist.
        conditions = { :node_id => label.node_id, :path => label.path }
        value = label.to_mongo.delete_if { |k, v| k == '_id' }
        
        Sherlock::Models::Label.collection.update(conditions, value, :upsert => true)

      end
    end

    # Persist all the metrics found in the snapshot JSON. This will also update
    # any averages for the last 5 minutes, 1 hour, 1 day and 1 week within the
    # metric timestamp via callbacks inside the metric model.
    def persist_metrics
      self.metrics.each(&:save)
    end

  end
end
