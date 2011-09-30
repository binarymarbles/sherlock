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

  before(:each) { stub_config_directory }
  let(:valid_json) { read_asset_file('agent-data/valid.json') }

  context '#instantiating snapshot parser' do

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

  context '#parsing snapshot json' do
    let(:parser) { Sherlock::SnapshotParser.new(valid_json) }

    it 'should have found two processes' do
      parser.processes.size.should == 2
    end

    it 'should have found three labels' do
      parser.labels.size.should == 4
    end

    it 'should have found 27 metrics' do
      parser.metrics.size.should == 27
    end
  end

  context '#persisting snapshot' do
    let(:parser) { Sherlock::SnapshotParser.new(valid_json) }
    let(:snapshot_time) { Time.local(2011, 9, 29, 18, 11) }

    # Freeze Time.now at a specific time.
    before(:each) { Timecop.freeze(snapshot_time) }

    # Release the frozen time.
    after(:each) { Timecop.return }

    it 'should persist the snapshot' do
      parser.persist!
      Sherlock::Models::Snapshot.count.should == 1
    end

    it 'should persist the processes' do
      parser.persist!
      Sherlock::Models::Process.count.should == 2
    end

    it 'should persist the labels' do
      parser.persist!
      Sherlock::Models::Label.count.should == 4
    end

    it 'should persist the metrics' do
      parser.persist!
      Sherlock::Models::Metric.count.should == 27
    end

    it 'should persist 5 minute averages' do
      parser.persist!
      Sherlock::Models::MetricAvg5m.count.should == 27
    end

    it 'should persist 1 hour averages' do
      parser.persist!
      Sherlock::Models::MetricAvg1h.count.should == 27
    end

    it 'should persist 1 day averages' do
      parser.persist!
      Sherlock::Models::MetricAvg1d.count.should == 27
    end

    it 'should persist 1 week averages' do
      parser.persist!
      Sherlock::Models::MetricAvg1w.count.should == 27
    end

    context '#labels' do
      it 'should update pre-existing labels instead of creating new ones' do
        Timecop.freeze(snapshot_time + 1.minute) do
          second_parser = Sherlock::SnapshotParser.new(valid_json)
          second_parser.persist!
          Sherlock::Models::Label.count.should == 4
        end
      end
    end

    context '#averages' do
      let(:create_second_snapshot) do
        p = Sherlock::SnapshotParser.new(valid_json)
        p.persist!
      end

      before(:each) do
        parser.persist!
      end

      context '#5 minute averages' do
        it 'should only have one set per 5 minutes' do
          Timecop.freeze(snapshot_time + 1.minute) do
            create_second_snapshot
            Sherlock::Models::MetricAvg5m.count.should == 27
          end
        end
        
        it 'should create a new set of averages after 5 minutes' do
          Timecop.freeze(snapshot_time + 5.minutes) do
            create_second_snapshot
            Sherlock::Models::MetricAvg5m.count.should == 54
          end
        end
      end

      context '#1 hour averages' do
        it 'should only have one set per hour' do
          Timecop.freeze(snapshot_time + 40.minutes) do
            create_second_snapshot
            Sherlock::Models::MetricAvg1h.count.should == 27
          end
        end
        
        it 'should create a new set of averages after one hour' do
          Timecop.freeze(snapshot_time + 1.hour) do
            create_second_snapshot
            Sherlock::Models::MetricAvg1h.count.should == 54
          end
        end
      end

      context '#1 day averages' do
        it 'should only have one set per day' do
          Timecop.freeze(snapshot_time + 3.hours) do
            create_second_snapshot
            Sherlock::Models::MetricAvg1d.count.should == 27
          end
        end

        it 'should create a new set of averages after one day' do
          Timecop.freeze(snapshot_time + 1.day) do
            create_second_snapshot
            Sherlock::Models::MetricAvg1d.count.should == 54
          end
        end
      end

      context '#1 week averages' do
        it 'should only have one set per week' do
          Timecop.freeze(snapshot_time + 2.days) do
            create_second_snapshot
            Sherlock::Models::MetricAvg1w.count.should == 27
          end
        end

        it 'should create a new set of averages after one week' do
          Timecop.freeze(snapshot_time + 1.week) do
            create_second_snapshot
            Sherlock::Models::MetricAvg1w.count.should == 54
          end
        end
      end
    end
  end

end
