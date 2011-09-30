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

describe Sherlock::Models::MetricAvg1h do
  context '#validations' do
    let(:metric_avg) { Sherlock::Models::MetricAvg1h.new(:node_id => 'test_node', :timestamp => Time.now, :path => 'test.metric') }

    it 'should be valid' do
      metric_avg.should be_valid
    end

    it 'should validate presence of node_id' do
      metric_avg.node_id = nil
      metric_avg.should_not be_valid
    end

    it 'should validate presence of timestamp' do
      metric_avg.timestamp = nil
      metric_avg.should_not be_valid
    end
    
    it 'should validate presence of path' do
      metric_avg.path = nil
      metric_avg.should_not be_valid
    end
  end
end
