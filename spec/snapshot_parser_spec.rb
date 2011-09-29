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

require 'spec_helper'

describe Sherlock::SnapshotParser do

  context '#instantiating snapshot parser' do
    before(:each) { stub_config_directory }

    let(:valid_json) { read_asset_file('agent-data/valid.json') }
    let(:invalid_json) { read_asset_file('agent-data/invalid.json') }
    let(:json_without_node_id) { read_asset_file('agent-data/without_node_id.json') }
    let(:json_with_invalid_node_id) { read_asset_file('agent-data/invalid_node_id.json') }
    let(:json_without_version) { read_asset_file('agent-data/without_version.json') }
    let(:json_with_invalid_version) { read_asset_file('agent-data/invalid_version.json') }
    let(:json_without_processes) { read_asset_file('agent-data/without_processes.json') }
    let(:json_with_empty_processes) { read_asset_file('agent-data/empty_processes.json') }
    let(:json_with_invalid_processes) { read_asset_file('agent-data/invalid_processes.json') }
    let(:json_without_data) { read_asset_file('agent-data/without_data.json') }
    let(:json_with_invalid_data) { read_asset_file('agent-data/invalid_data.json') }

    it 'should accept valid json' do
      lambda { Sherlock::SnapshotParser.new(valid_json) }.should_not raise_error
    end

    it 'should not accept invalid json' do
      lambda { Sherlock::SnapshotParser.new(invalid_json) }.should raise_error(Sherlock::Errors::ParserError)
    end

    it 'should not accept missing node id' do
      lambda { Sherlock::SnapshotParser.new(json_without_node_id) }.should raise_error(Sherlock::Errors::ParserError)
    end

    it 'should not accept invalid node id' do
      lambda { Sherlock::SnapshotParser.new(json_with_invalid_node_id) }.should raise_error(Sherlock::Errors::ParserError)
    end

    it 'should not accept missing version' do
      lambda { Sherlock::SnapshotParser.new(json_without_version) }.should raise_error(Sherlock::Errors::ParserError)
    end

    it 'should not accept invalid version' do
      lambda { Sherlock::SnapshotParser.new(json_with_invalid_version) }.should raise_error(Sherlock::Errors::ParserError)
    end

    it 'should not accept missing process list' do
      lambda { Sherlock::SnapshotParser.new(json_without_processes) }.should raise_error(Sherlock::Errors::ParserError)
    end      

    it 'should not accept empty process list' do
      lambda { Sherlock::SnapshotParser.new(json_with_empty_processes) }.should raise_error(Sherlock::Errors::ParserError)
    end

    it 'should not accept a non-array process list' do
      lambda { Sherlock::SnapshotParser.new(json_with_invalid_processes) }.should raise_error(Sherlock::Errors::ParserError)
    end

    it 'should not accept missing data' do
      lambda { Sherlock::SnapshotParser.new(json_without_data) }.should raise_error(Sherlock::Errors::ParserError)
    end

    it 'should not accept non-hash data' do
      lambda { Sherlock::SnapshotParser.new(json_with_invalid_data) }.should raise_error(Sherlock::Errors::ParserError)
    end
  end

end
