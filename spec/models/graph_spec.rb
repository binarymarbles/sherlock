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

describe Sherlock::Models::Graph do

  context '#validations' do
    let(:graph) { Sherlock::Models::Graph.new(:id => 'test-graph', :name => 'Test Graph', :type => 'counter', :unit => 'test-unit', :conversion => 'bytes_to_mb', :keys => [Sherlock::Models::GraphKey.new(:metric => 'test.metric', :label => 'Test Label')]) }

    it 'should be valid' do
      graph.should be_valid
    end

    it 'should validate presence of id' do
      graph.id = nil
      graph.should_not be_valid
    end

    it 'should validate presence of name' do
      graph.name = nil
      graph.should_not be_valid
    end

    it 'should validate presence of type' do
      graph.type = nil
      graph.should_not be_valid
    end

    it 'should not allow invalid types' do
      graph.type = 'invalid'
      graph.should_not be_valid
    end

    it 'should validate presence of unit' do
      graph.unit = nil
      graph.should_not be_valid
    end

    it 'should not validate presence of conversion' do
      graph.conversion = nil
      graph.should be_valid
    end

    it 'should not allow invalid conversions' do
      graph.conversion = 'invalid'
      graph.should_not be_valid
    end

    it 'should not allow a blank list of keys' do
      graph.keys = []
      graph.should_not be_valid
    end
  end
  
end
