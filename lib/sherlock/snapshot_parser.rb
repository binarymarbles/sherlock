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

    attr_reader :snapshot

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
      @snapshot = parse_json(raw_json)

      # Validate the contents of the snapshot.
      validate_snapshot_contents
      
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
      raise_parser_error('Missing "node_id" in JSON data') if snapshot[:node_id].blank?
      raise_parser_error('Unknown node id referenced in JSON data') if Sherlock::Config.node_by_id(snapshot[:node_id]).blank?

      # Require that the version is set and that it's a valid value.
      raise_parser_error('Missing "version" in JSON data') if snapshot[:version].blank?
      raise_parser_error('Unknown version number referenced in JSON data') if snapshot[:version] != '1.0.0'

      # Require that the process list is set and that its an array.
      raise_parser_error('Missing "processes" in JSON data') if snapshot[:processes].blank?
      raise_parser_error('Invalid process list referenced in JSON data') unless snapshot[:processes].is_a?(Array) && snapshot[:processes].size > 0

      # Require that the data attribute is set, and that its a hash with at
      # least one key.
      raise_parser_error('Missing "data" in JSON data') if snapshot[:data].blank?
      raise_parser_error('Invalid data referenced in JSON data') unless snapshot[:data].is_a?(Hash) && snapshot[:data].keys.size > 0

    end

  end
end
