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

describe Sherlock::Models::Metric do
  context '#attributes' do
    let(:metric) { Sherlock::Models::Metric.new }

    it 'should belong to snapshot' do
      metric.should respond_to(:snapshot)
      metric.should respond_to(:snapshot=)
    end
  end
  
  context '#validations' do
    let(:metric) { Sherlock::Models::Metric.new(:node_id => 'test_node', :timestamp => Time.now, :path => 'test.metric', :counter => 10.0) }

    it 'should be valid' do
      metric.should be_valid
    end

    it 'should validate presence of node_id' do
      metric.node_id = nil
      metric.should_not be_valid
    end

    it 'should validate presence of timestamp' do
      metric.timestamp = nil
      metric.should_not be_valid
    end
    
    it 'should validate presence of path' do
      metric.path = nil
      metric.should_not be_valid
    end

    it 'should validate presence of counter' do
      metric.counter = nil
      metric.should_not be_valid
    end
  end
end
